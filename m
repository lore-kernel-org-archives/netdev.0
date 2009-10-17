From: Julian Anastasov <ja@ssi.bg>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Sat, 17 Oct 2009 14:48:44 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0910171417260.7818@u.domain.uli>
References: <20091014045226.GA15655@1wt.eu> <Pine.LNX.4.58.0910140912420.2714@u.domain.uli>
 <20091014201706.GA24298@1wt.eu> <20091014.154349.83940908.davem@davemloft.net>
 <20091015060834.GB29564@1wt.eu> <Pine.LNX.4.58.0910151120340.2879@u.domain.uli>
 <20091015124134.GB1073@1wt.eu> <Pine.LNX.4.58.0910152257410.3047@u.domain.uli>
 <20091016050310.GA5574@1wt.eu> <Pine.LNX.4.58.0910161137490.3886@u.domain.uli>
 <4AD84D8B.5020103@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:40860 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750948AbZJQLr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2009 07:47:57 -0400
In-Reply-To: <4AD84D8B.5020103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 16 Oct 2009, Eric Dumazet wrote:

> I wonder if tcp_diag should be extented a bit to reflect fact that the ACK was received from client
> (ie forward the inet_rsk(req)->acked information to idiag_rqueue)

	It is a good idea.

> diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
> index cb73fde..c172bd4 100644
> --- a/net/ipv4/inet_diag.c
> +++ b/net/ipv4/inet_diag.c
> @@ -589,7 +589,7 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
>  	r->id.idiag_src[0] = ireq->loc_addr;
>  	r->id.idiag_dst[0] = ireq->rmt_addr;
>  	r->idiag_expires = jiffies_to_msecs(tmo);
> - 	r->idiag_rqueue = 0;
> +	r->idiag_rqueue = ireq->acked;
>  	r->idiag_wqueue = 0;
>  	r->idiag_uid = sock_i_uid(sk);
>  	r->idiag_inode = 0;

	I tested both patches. It seems the current algorithm to
convert seconds to retransmissions does not match well the TCP
SYN-ACK timer and sometimes can convert the seconds to
retransmissions which are 1 above the expected. For example,
you set 9 seconds (expecting 2 retrans) but you get 3 retrans,
visible with TCP_SYNCNT=1.

	Also, it is limited to period of 32 retransmissions.

	The following patch changes the TCP_DEFER_ACCEPT
period calculation to match TCP SYN-ACK retransmissions and to
help those folks who select the seconds with TCP SYN-ACK
timing in mind. It also allows the retransmission threshold
to be up to 255.

Signed-off-by: Julian Anastasov <ja@ssi.bg>

diff -urp v2.6.31/linux/net/ipv4/tcp.c linux/net/ipv4/tcp.c
--- v2.6.31/linux/net/ipv4/tcp.c	2009-09-11 10:27:17.000000000 +0300
+++ linux/net/ipv4/tcp.c	2009-10-17 12:34:38.000000000 +0300
@@ -2165,13 +2165,20 @@ static int do_tcp_setsockopt(struct sock
 	case TCP_DEFER_ACCEPT:
 		icsk->icsk_accept_queue.rskq_defer_accept = 0;
 		if (val > 0) {
+			int timeout = TCP_TIMEOUT_INIT / HZ;
+			int period = timeout;
+
 			/* Translate value in seconds to number of
 			 * retransmits */
-			while (icsk->icsk_accept_queue.rskq_defer_accept < 32 &&
-			       val > ((TCP_TIMEOUT_INIT / HZ) <<
-				       icsk->icsk_accept_queue.rskq_defer_accept))
+			icsk->icsk_accept_queue.rskq_defer_accept = 1;
+			while (icsk->icsk_accept_queue.rskq_defer_accept < 255 &&
+			       val > period) {
 				icsk->icsk_accept_queue.rskq_defer_accept++;
-			icsk->icsk_accept_queue.rskq_defer_accept++;
+				timeout <<= 1;
+				if (timeout > TCP_RTO_MAX / HZ)
+					timeout = TCP_RTO_MAX / HZ;
+				period += timeout;
+			}
 		}
 		break;
 

	FYI, the old algorithm selects the following retransmissions
for the configured seconds:

defer_accept=1 retrans for 1-3 secs
defer_accept=2 retrans for 4-6 secs
defer_accept=3 retrans for 7-12 secs
defer_accept=4 retrans for 13-24 secs
defer_accept=5 retrans for 25-48 secs
defer_accept=6 retrans for 49-96 secs
defer_accept=7 retrans for 97-192 secs
defer_accept=8 retrans for 193-384 secs

	While the new algorithm is as follows:

defer_accept=1 retrans for 1-3 secs
defer_accept=2 retrans for 4-9 secs
defer_accept=3 retrans for 10-21 secs
defer_accept=4 retrans for 22-45 secs
defer_accept=5 retrans for 46-93 secs
defer_accept=6 retrans for 94-189 secs
defer_accept=7 retrans for 190-309 secs
defer_accept=8 retrans for 310-429 secs

	Comments? Next step is to post the 3 patches separately
for final review and applying.

Regards

--
Julian Anastasov <ja@ssi.bg>
