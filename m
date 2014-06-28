From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [net-next v2 02/13] tcp: tcp_v[46]_conn_request: fix snt_synack initialization
Date: Fri, 27 Jun 2014 22:16:35 -0400
Message-ID: <CADVnQykKYPVt-g8WtE29Xu_0Si-Lx_pMxnix4i2BqFhAV9BD8Q@mail.gmail.com>
References: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
	<1403705402-14388-3-git-send-email-octavian.purdila@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Daniel Lee <longinus00@gmail.com>,
	Yuchung Cheng <ycheng@google.com>, Jerry Chu <hkchu@google.com>
To: Octavian Purdila <octavian.purdila@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:34861 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196AbaF1CQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 22:16:37 -0400
Received: by mail-we0-f175.google.com with SMTP id k48so6020836wev.20
        for <netdev@vger.kernel.org>; Fri, 27 Jun 2014 19:16:35 -0700 (PDT)
In-Reply-To: <1403705402-14388-3-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 25, 2014 at 10:09 AM, Octavian Purdila
<octavian.purdila@intel.com> wrote:
> Commit 016818d07 (tcp: TCP Fast Open Server - take SYNACK RTT after
> completing 3WHS) changes the code to only take a snt_synack timestamp
> when a SYNACK transmit or retransmit succeeds. This behaviour is later
> broken by commit 843f4a55e (tcp: use tcp_v4_send_synack on first
> SYN-ACK), as snt_synack is now updated even if tcp_v4_send_synack
> fails.
>
> Also, commit 3a19ce0ee (tcp: IPv6 support for fastopen server) misses
> the required IPv6 updates for 016818d07.
>
> This patch makes sure that snt_synack is updated only when the SYNACK
> trasnmit/retransmit succeeds, for both IPv4 and IPv6.
>
> Cc: Cardwell <ncardwell@google.com>
> Cc: Daniel Lee <longinus00@gmail.com>
> Cc: Yuchung Cheng <ycheng@google.com>
>
> Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>

> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 08ae3da..a962455 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -497,6 +497,8 @@ static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
>                 skb_set_queue_mapping(skb, queue_mapping);
>                 err = ip6_xmit(sk, skb, fl6, np->opt, np->tclass);
>                 err = net_xmit_eval(err);
> +               if (!tcp_rsk(req)->snt_synack && !err)
> +                       tcp_rsk(req)->snt_synack = tcp_time_stamp;
>         }

Octavian, thanks for finding this issue!

I think we should resolve the inconsistency you have discovered by
converging on the approach in Yuchung's 843f4a55e (tcp: use
tcp_v4_send_synack on first SYN-ACK), which restores the original
behavior of snt_synack from the commit where it was added by Jerry:
9ad7c049f0f79 ("tcp: RFC2988bis + taking RTT sample from 3WHS for the
passive open side") in v3.1. In that commit tcp_v4_conn_request() and
tcp_v6_conn_request() unconditionally store the time at which the
server received the first client SYN in snt_synack:

  tcp_rsk(req)->snt_synack = tcp_time_stamp;

At Google we have found that behavior very useful because it allows
extracting useful performance metrics summarizing how long it took to
establish a passive TCP connection.

So I would suggest that we fix this inconsistency you have noted by
removing the two lines in tcp_v4_send_synack() that touch snt_synack.
That is the approach we have been using at Google recently, and I
think it was an oversight that we didn't remove those two lines.

Thanks!

neal
