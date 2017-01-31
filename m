From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH RFC net-next 0/4] bridge: improve cache utilization
Date: Tue, 31 Jan 2017 08:39:19 -0800
Message-ID: <20170131083919.51a3ac9f@xeon-e3>
References: <1485876718-18091-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33247 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751064AbdAaQj0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 11:39:26 -0500
Received: by mail-pf0-f180.google.com with SMTP id y143so108221685pfb.0
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 08:39:26 -0800 (PST)
In-Reply-To: <1485876718-18091-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Jan 2017 16:31:54 +0100
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> Hi all,
> This is the first set which begins to deal with the bad bridge cache
> access patterns. The first patch rearranges the bridge and port structs
> a little so the frequently (and closely) accessed members are in the same
> cache line. The second patch then moves the garbage collection to a
> workqueue trying to improve system responsiveness under load (many fdbs)
> and more importantly removes the need to check if the matched entry is
> expired in __br_fdb_get which was a source of false-sharing.
> The third patch is a preparation for the final one which adds a new option
> that allows to turn off "used" updates on transmit to a fdb which is the
> other source of false-sharing in the bridge. If properly configured, i.e.
> ports bound to CPUs (thus updating "updated" locally) and "used_enabled"
> set to 0 then the bridge's HitM goes from 100% to 0%, but even with
> "used_enabled" = 1 we still get a win because lookups which iterated over
> the hash chain caused false-sharing due to the first cache line being
> used for both mac/vid and used/updated fields.
> I'm not a fan of adding new options to the bridge, so I'm open to
> suggestions for this one. Things I've tried before that:
> - dynamically allocate a pool of percpu memory for used/updated fields
>   (works but it's more complicated as we need dynamic resizing, too)
> - dynamically allocate percpu memory for each fdb separately (I'm not a fan
>   of this one, but it's much simpler to implement)
> 
> Of these two obviously the first approach worked best, but the complexity
> it brings is considerable, while with this patchset we can achieve the same
> result with proper configuration. Any feedback on this one would be greatly
> appreciated.
> 
> Some results from tests I've run:
> (note that these were run in good conditions for the baseline, everything
>  ran on a single NUMA node and there were only 3 fdbs)
> 
> 1. baseline
> 100% Load HitM on the fdbs (between everyone who has done lookups and hit
>                             one of the 3 hash chains of the communicating
>                             src/dst fdbs)
> Overall 5.06% Load HitM for the bridge, first place in the list
> 
> bridge udp rr between 3 cores/ports/fdbs test:
>    0.35%  ksoftirqd/0  [k] br_fdb_update
>    0.30%  ksoftirqd/0  [k] __br_fdb_get
>    0.17%  ksoftirqd/0  [k] br_handle_frame_finish
> 
> 2. used = 1
> 0% Local Load HitM
> bridge udp rr between 3 cores/ports/fdbs test:
>    0.24%  ksoftirqd/0    [k] br_fdb_update
>    0.23%  ksoftirqd/0    [k] __br_fdb_get
>    0.12%  ksoftirqd/0    [k] br_handle_frame_finish
> 
> 3. used = 0
> 0% Local Load HitM
> bridge udp rr between 3 cores/ports/fdbs test:
>    0.23%  ksoftirqd/0    [k] __br_fdb_get
>    0.22%  ksoftirqd/0    [k] br_fdb_update
>    0.10%  ksoftirqd/0    [k] br_handle_frame_finish
> 
> 
> Thanks,
>  Nik
> 
> Nikolay Aleksandrov (4):
>   bridge: modify bridge and port to have often accessed fields in one
>     cache line
>   bridge: move to workqueue gc
>   bridge: move write-heavy fdb members in their own cache line
>   bridge: add ability to turn off fdb used updates
> 
>  include/uapi/linux/if_link.h |  1 +
>  net/bridge/br_device.c       |  2 ++
>  net/bridge/br_fdb.c          | 31 ++++++++++++++---------
>  net/bridge/br_if.c           |  2 +-
>  net/bridge/br_input.c        |  3 ++-
>  net/bridge/br_ioctl.c        |  2 +-
>  net/bridge/br_netlink.c      | 12 +++++++--
>  net/bridge/br_private.h      | 58 ++++++++++++++++++++++----------------------
>  net/bridge/br_stp.c          |  2 +-
>  net/bridge/br_stp_if.c       |  4 +--
>  net/bridge/br_stp_timer.c    |  2 --
>  net/bridge/br_sysfs_br.c     | 25 ++++++++++++++++++-
>  12 files changed, 92 insertions(+), 52 deletions(-)
> 

I agree with the first 3 patches, but not the last one.
Changing the API just for a performance hack is not necessary. Instead make
the algorithm smarter and use per-cpu values.
