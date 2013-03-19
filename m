From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3] packet: packet fanout rollover during
 socket overload
Date: Tue, 19 Mar 2013 13:37:17 -0700
Message-ID: <1363725437.2558.22.camel@edumazet-glaptop>
References: <1363724291-27580-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:45200 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933697Ab3CSUhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 16:37:22 -0400
Received: by mail-pd0-f179.google.com with SMTP id x10so310726pdj.38
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 13:37:21 -0700 (PDT)
In-Reply-To: <1363724291-27580-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-19 at 16:18 -0400, Willem de Bruijn wrote:
> Changes:
>   v3->v2: rebase (no other changes)
>           passes selftest
>   v2->v1: read f->num_members only once
>           fix bug: test rollover mode + flag
> 
> Minimize packet drop in a fanout group. If one socket is full,
> roll over packets to another from the group. Maintain flow
> affinity during normal load using an rxhash fanout policy, while
> dispersing unexpected traffic storms that hit a single cpu, such
> as spoofed-source DoS flows. Rollover breaks affinity for flows
> arriving at saturated sockets during those conditions.
> 
> The patch adds a fanout policy ROLLOVER that rotates between sockets,
> filling each socket before moving to the next. It also adds a fanout
> flag ROLLOVER. If passed along with any other fanout policy, the
> primary policy is applied until the chosen socket is full. Then,
> rollover selects another socket, to delay packet drop until the
> entire system is saturated.
> 
> Probing sockets is not free. Selecting the last used socket, as
> rollover does, is a greedy approach that maximizes chance of
> success, at the cost of extreme load imbalance. In practice, with
> sufficiently long queues to absorb bursts, sockets are drained in
> parallel and load balance looks uniform in `top`.
> 
> To avoid contention, scales counters with number of sockets and
> accesses them lockfree. Values are bounds checked to ensure
> correctness.
> 
> Tested using an application with 9 threads pinned to CPUs, one socket
> per thread and sufficient busywork per packet operation to limits each
> thread to handling 32 Kpps. When sent 500 Kpps single UDP stream
> packets, a FANOUT_CPU setup processes 32 Kpps in total without this
> patch, 270 Kpps with the patch. Tested with read() and with a packet
> ring (V1). Also, passes unit test (perhaps for selftests) at
> http://kernel.googlecode.com/files/psock_fanout.c
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  include/uapi/linux/if_packet.h |   2 +
>  net/packet/af_packet.c         | 109 ++++++++++++++++++++++++++++++++---------
>  net/packet/internal.h          |   3 +-
>  3 files changed, 90 insertions(+), 24 deletions(-)

Reviewed-by: Eric Dumazet <edumazet@google.com>
