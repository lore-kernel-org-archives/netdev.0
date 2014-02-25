From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net 1/2] ipv4: allow IP_PMTUDISC_INTERFACE generate fragments if packet size is larger than interface mtu
Date: Tue, 25 Feb 2014 01:58:14 +0100
Message-ID: <20140225005814.GA12189@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: fweimer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50465 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752000AbaBYA6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 19:58:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Relax IP_PMTUDISC_INTERFACE socket option to allow generation of
fragmented IP packets if the packet size is greater than the interface
MTU.

I introduced this socket option in commit 482fc6094afad5 ("ipv4: introduce
new IP_MTU_DISCOVER mode IP_PMTUDISC_INTERFACE") to prevent DNS servers
from ever generating fragments. While preparing patches for DNS software,
I encoutered the problem that it is very problematic to track the reported
MTU size from the socket error queue in case a EMSGSIZE error is reported
on the socket, because the internal architecture of DNS software does
not easily allow so (or doesn't easily allow to regenerate the DNS answer
packet with truncation bit set).

That said, I propose to slightly relax the semantics behind
IP_PMTUDISC_INTERFACE to allow fragments being generated only if the
packet size exceeds the interface mtu. As such, this option could be
used as a drop-in replacement for IP_PMTUDISC_DONT, which is currently
in use by most DNS software.  This would help to get this option in
use much sooner. DNS software already allows setting an upper bound
on the outgoing maximum UDP packet size. With this patch and an faulty
maximum UDP packet size configuration, which exceeds the minimum mtu of
the system, it is now possible to generate fragments. Admins must take
care of this.

The main benefit of this option, ignoring path MTU information on the
socket, is still preserved.

Fixes: 482fc6094afad5 ("ipv4: introduce new IP_MTU_DISCOVER mode IP_PMTUDISC_INTERFACE")
Cc: Florian Weimer <fweimer@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
I hope changing this socket option slightly to be more permissive while
already being in a released kernel is acceptable.

I hope this patch could also be enqueued for stable 3.13 kernels. If
that happens, I could finally push out the changes for DNS software to
use this new mode, which would be much more easier than with the old
semantics (which is nearly impossible to get into all DNS software in
the next time).

The IPv6 option was first introduced in 3.14 so the IPv6 patch is only
applicable for net.

I am aware that the original inclusion of the IP_PMTUDISC_INTERFACE
mode wasn't received that well, but I hope to have users for this socket
option very soon (e.g. unbound).

Thanks a lot!

 include/net/ip.h     |  8 ++++++++
 net/ipv4/ip_output.c | 16 +++++++---------
 2 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 23be0fd..8080e4c 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -274,6 +274,14 @@ static inline bool ip_sk_use_pmtu(const struct sock *sk)
 	return inet_sk(sk)->pmtudisc < IP_PMTUDISC_PROBE;
 }
 
+static inline bool ip_sk_allow_local_frag(const struct sock *sk)
+{
+	struct inet_sock *inet = inet_sk(sk);
+
+	return inet->pmtudisc != IP_PMTUDISC_DO &&
+	       inet->pmtudisc != IP_PMTUDISC_PROBE;
+}
+
 static inline unsigned int ip_dst_mtu_maybe_forward(const struct dst_entry *dst,
 						    bool forwarding)
 {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 73c6b63..c5887be 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -822,8 +822,7 @@ static int __ip_append_data(struct sock *sk,
 
 	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
-	maxnonfragsize = (inet->pmtudisc >= IP_PMTUDISC_DO) ?
-			 mtu : 0xFFFF;
+	maxnonfragsize = ip_sk_allow_local_frag(sk) ? 0xFFFF : mtu;
 
 	if (cork->length + length > maxnonfragsize - fragheaderlen) {
 		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport,
@@ -1146,8 +1145,7 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 
 	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
-	maxnonfragsize = (inet->pmtudisc >= IP_PMTUDISC_DO) ?
-			 mtu : 0xFFFF;
+	maxnonfragsize = ip_sk_allow_local_frag(sk) ? 0xFFFF : mtu;
 
 	if (cork->length + size > maxnonfragsize - fragheaderlen) {
 		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport,
@@ -1304,12 +1302,12 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 		tmp_skb->sk = NULL;
 	}
 
-	/* Unless user demanded real pmtu discovery (IP_PMTUDISC_DO), we allow
-	 * to fragment the frame generated here. No matter, what transforms
-	 * how transforms change size of the packet, it will come out.
+	/* Unless user demanded real pmtu discovery (IP_PMTUDISC_DO,
+	 * IP_PMTUDISC_PROBE), we allow to fragment the frame
+	 * generated here. No matter, what transforms how transforms
+	 * change size of the packet, it will come out.
 	 */
-	if (inet->pmtudisc < IP_PMTUDISC_DO)
-		skb->local_df = 1;
+	skb->local_df = ip_sk_allow_local_frag(sk);
 
 	/* DF bit is set when we want to see DF on outgoing frames.
 	 * If local_df is set too, we still allow to fragment this frame
-- 
1.8.5.3
