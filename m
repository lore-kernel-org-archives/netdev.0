From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip6_tunnel: allow to change mode for the ip6tnl0
Date: Tue, 28 Oct 2014 23:46:53 -0700
Message-ID: <1414565213.631.77.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414563898-10347-1-git-send-email-alan@al-an.info>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Alexey Andriyanov <alan@al-an.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:62979 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680AbaJ2Gqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 02:46:54 -0400
Received: by mail-pa0-f47.google.com with SMTP id kx10so2531882pab.20
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 23:46:54 -0700 (PDT)
In-Reply-To: <1414563898-10347-1-git-send-email-alan@al-an.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-29 at 09:24 +0300, Alexey Andriyanov wrote:

...
> The fallback device can not be hidden from the packet receiver
> as a regular tunnel, but there is no need for synchronization
> as long as we do single assignment.

This is not exact, I believe you need to add following changes :

 net/ipv6/ip6_tunnel.c |   16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 9409887fb664dd78d13937b89ea1b5044afdbc94..9d43b99073d656a5a8a38976ca593a41b3cbdca4 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -477,6 +477,7 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 	int rel_msg = 0;
 	u8 rel_type = ICMPV6_DEST_UNREACH;
 	u8 rel_code = ICMPV6_ADDR_UNREACH;
+	u8 tproto;
 	__u32 rel_info = 0;
 	__u16 len;
 	int err = -ENOENT;
@@ -490,7 +491,8 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 					&ipv6h->saddr)) == NULL)
 		goto out;
 
-	if (t->parms.proto != ipproto && t->parms.proto != 0)
+	tproto = ACCESS_ONCE(t->parms.proto);
+	if (tproto != ipproto && tproto != 0)
 		goto out;
 
 	err = 0;
@@ -791,6 +793,7 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 {
 	struct ip6_tnl *t;
 	const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+	u8 tproto;
 	int err;
 
 	rcu_read_lock();
@@ -799,7 +802,8 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 					&ipv6h->daddr)) != NULL) {
 		struct pcpu_sw_netstats *tstats;
 
-		if (t->parms.proto != ipproto && t->parms.proto != 0) {
+		tproto = ACCESS_ONCE(t->parms.proto);
+		if (tproto != ipproto && tproto != 0) {
 			rcu_read_unlock();
 			goto discard;
 		}
@@ -1078,9 +1082,11 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct flowi6 fl6;
 	__u8 dsfield;
 	__u32 mtu;
+	u8 tproto;
 	int err;
 
-	if ((t->parms.proto != IPPROTO_IPIP && t->parms.proto != 0) ||
+	tproto = ACCESS_ONCE(t->parms.proto);
+	if ((tproto != IPPROTO_IPIP && tproto != 0) ||
 	    !ip6_tnl_xmit_ctl(t))
 		return -1;
 
@@ -1120,9 +1126,11 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct flowi6 fl6;
 	__u8 dsfield;
 	__u32 mtu;
+	u8 tproto;
 	int err;
 
-	if ((t->parms.proto != IPPROTO_IPV6 && t->parms.proto != 0) ||
+	tproto = ACCESS_ONCE(t->parms.proto);
+	if ((tproto != IPPROTO_IPV6 && tproto != 0) ||
 	    !ip6_tnl_xmit_ctl(t) || ip6_tnl_addr_conflict(t, ipv6h))
 		return -1;
 
