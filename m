From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/4] bridge: improve cache utilization
Date: Sat, 4 Feb 2017 22:58:45 +0100
Message-ID: <cba97e67-90cc-09bc-a8b6-764feae156e9@cumulusnetworks.com>
References: <1486227909-18319-1-git-send-email-nikolay@cumulusnetworks.com>
 <20170204134626.311e3742@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        davem@davemloft.net, bridge@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:34575 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750944AbdBDV6r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 16:58:47 -0500
Received: by mail-wm0-f42.google.com with SMTP id 196so24873448wmm.1
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 13:58:47 -0800 (PST)
In-Reply-To: <20170204134626.311e3742@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/02/17 22:46, Stephen Hemminger wrote:
> On Sat,  4 Feb 2017 18:05:05 +0100
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
> 
>> Hi all,
>> This is the first set which begins to deal with the bad bridge cache
>> access patterns. The first patch rearranges the bridge and port structs
>> a little so the frequently (and closely) accessed members are in the same
>> cache line. The second patch then moves the garbage collection to a
>> workqueue trying to improve system responsiveness under load (many fdbs)
>> and more importantly removes the need to check if the matched entry is
>> expired in __br_fdb_get which was a major source of false-sharing.
>> The third patch is a preparation for the final one which
>> If properly configured, i.e. ports bound to CPUs (thus updating "updated"
>> locally) then the bridge's HitM goes from 100% to 0%, but even without
>> binding we get a win because previously every lookup that iterated over
>> the hash chain caused false-sharing due to the first cache line being
>> used for both mac/vid and used/updated fields.
>>
>> Some results from tests I've run:
>> (note that these were run in good conditions for the baseline, everything
>>  ran on a single NUMA node and there were only 3 fdbs)
>>
>> 1. baseline
>> 100% Load HitM on the fdbs (between everyone who has done lookups and hit
>>                             one of the 3 hash chains of the communicating
>>                             src/dst fdbs)
>> Overall 5.06% Load HitM for the bridge, first place in the list
>>
>> 2. patched & ports bound to CPUs
>> 0% Local load HitM, bridge is not even in the c2c report list
>> Also there's 3% consistent improvement in netperf tests.
> 
> What tool are you using to measure this?
> 

I use perf c2c and perf custom cache events, for the traffic tested with
netperf (stream and RR) and Jesper's udp_flood/udp_sink (showed over 200ns
per packet saving by the way).
The tests I ran on bare metal between namespaces with veth devices in a bridge,
each namespace got its core bound.

>>
>> Thanks,
>>  Nik
>>
>> Nikolay Aleksandrov (4):
>>   bridge: modify bridge and port to have often accessed fields in one
>>     cache line
>>   bridge: move to workqueue gc
>>   bridge: move write-heavy fdb members in their own cache line
>>   bridge: fdb: write to used and updated at most once per jiffy
>>
>>  net/bridge/br_device.c    |  1 +
>>  net/bridge/br_fdb.c       | 34 +++++++++++++++++-----------
>>  net/bridge/br_if.c        |  2 +-
>>  net/bridge/br_input.c     |  3 ++-
>>  net/bridge/br_ioctl.c     |  2 +-
>>  net/bridge/br_netlink.c   |  2 +-
>>  net/bridge/br_private.h   | 57 +++++++++++++++++++++++------------------------
>>  net/bridge/br_stp.c       |  2 +-
>>  net/bridge/br_stp_if.c    |  4 ++--
>>  net/bridge/br_stp_timer.c |  2 --
>>  net/bridge/br_sysfs_br.c  |  2 +-
>>  11 files changed, 59 insertions(+), 52 deletions(-)
> 
> Looks good thanks, I wounder this impacts smaller work loads.
> 
> Reviewed-by: Stephen Hemminger <stephen@networkplumber.org>
> 
