From: Peter Kosyh <p.kosyh@gmail.com>
Subject: [PATCH] xfrm bugs with mark logic
Date: Fri, 2 Jul 2010 14:40:17 +0400
Message-ID: <AANLkTimsVHoNk3B1oTI6awlNtrmNED7vwe2flzTap9aP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47725 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869Ab0GBKk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 06:40:27 -0400
Received: by fxm14 with SMTP id 14so2188405fxm.19
        for <netdev@vger.kernel.org>; Fri, 02 Jul 2010 03:40:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello! I am currently working with 2.6.34, trying to use iptables ...
-j MARK with XFRM policy. So, i found at least
two bugs in 2.6.34 kernel.

First bug is just typo in  xfrm_mark_get (net/xfrm.h):

memcpy(m, nla_data(attrs[XFRMA_MARK]), sizeof(m));

must be:

memcpy(m, nla_data(attrs[XFRMA_MARK]), sizeof(*m));

The second one, is clearing mark in flowi structure via memset in
_decode_session4 (net/ipv4/xfrm4_policy.c).
(see net/ipv4/netfilter.c, ip_route_me_harder function)
int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
/* ... */
        if (addr_type == RTN_LOCAL) {
/* ... */
                fl.mark = skb->mark; /* here, set mark from skb */
/* ... */
#ifdef CONFIG_XFRM
        if (!(IPCB(skb)->flags & IPSKB_XFRM_TRANSFORMED) &&
            xfrm_decode_session(skb, &fl, AF_INET) == 0) { /* here
fl->mark will be zeroed */
            /* ... */
            if (xfrm_lookup(net, &dst, &fl, skb->sk, 0)) /* here
policy lookup will fail */

Do not know about ipv6 anything, but it's like that it affected by
this bug too. :(

P.S. Sorry for my bad English. :)

w.b.r. Peter Kosyh

diff -Nur linux-2.6.34/include/net/xfrm.h linux-2.6.34.fix/include/net/xfrm.h
--- linux-2.6.34/include/net/xfrm.h	2010-05-16 21:17:36.000000000 +0000
+++ linux-2.6.34.fix/include/net/xfrm.h	2010-07-02 10:05:33.000000000 +0000
@@ -1587,7 +1587,7 @@
 static inline int xfrm_mark_get(struct nlattr **attrs, struct xfrm_mark *m)
 {
 	if (attrs[XFRMA_MARK])
-		memcpy(m, nla_data(attrs[XFRMA_MARK]), sizeof(m));
+		memcpy(m, nla_data(attrs[XFRMA_MARK]), sizeof(*m));
 	else
 		m->v = m->m = 0;
diff -Nur linux-2.6.34/net/ipv4/xfrm4_policy.c
linux-2.6.34.fix/net/ipv4/xfrm4_policy.c
--- linux-2.6.34/net/ipv4/xfrm4_policy.c	2010-05-16 21:17:36.000000000 +0000
+++ linux-2.6.34.fix/net/ipv4/xfrm4_policy.c	2010-07-02 10:17:51.000000000 +0000
@@ -186,6 +186,7 @@
 	fl->fl4_dst = reverse ? iph->saddr : iph->daddr;
 	fl->fl4_src = reverse ? iph->daddr : iph->saddr;
 	fl->fl4_tos = iph->tos;
+	fl->mark = skb->mark;
 }

 static inline int xfrm4_garbage_collect(struct dst_ops *ops)
