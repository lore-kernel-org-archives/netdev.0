From: Peter Kosyh <p.kosyh@gmail.com>
Subject: [PATCH] xfrm: fix xfrm by MARK logic in mangle table, POSTROUTING chain
Date: Wed, 2 Mar 2011 17:24:55 +0300
Message-ID: <AANLkTim9ib8FHJsPR1btMnudxWN5a6iSf_3CZ=cvKP53@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:44671 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881Ab1CBOY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 09:24:56 -0500
Received: by vxi39 with SMTP id 39so5212787vxi.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 06:24:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Kosyh <p.kosyh@gmail.com>

While using xfrm by MARK feature in >= 2.6.35 kernels, i found some
strange behaviour in MARK and xfrm logic.

After doing MARK target in POSTROUTING chain in mangle table, new mark
is not used in policy lookup logic.
That is because that mark logic is a part of routing logic, and
rerouting is done only in LOCALOUT hook. Here is the code from
/net/ipv4/netfilter/iptable_mangle.c:

/* The work comes in here from netfilter.c. */
static unsigned int
iptable_mangle_hook(unsigned int hook,
		     struct sk_buff *skb,
		     const struct net_device *in,
		     const struct net_device *out,
		     int (*okfn)(struct sk_buff *))
{
	if (hook == NF_INET_LOCAL_OUT)
		return ipt_mangle_out(skb, out);
	if (hook == NF_INET_POST_ROUTING)
		return ipt_do_table(skb, hook, in, out,
				    dev_net(out)->ipv4.iptable_mangle);
...

Looking NF_INET_LOCAL_OUT case, in ipt_mangle_out  there is a call to
ip_route_me_harder, that will call xfrm_decode_session and new mark
will be applied to xfrm flow.

But in NF_INET_POST_ROUTING there is nothing. So we can not use xfrm
by MARK logic from POSTROUTING chain at all.

It's like due the fact, that in postrouting we are not doing
rerouting, BUT in NAT case (in POSTROUTING chain), there is call to
ip_xfrm_me_harder(skb) in nf_nat_out, so, i suppose it is a bug in
iptable_mangle.c.

Here it is my patch that works for me. I ask anyone to help me, if it
is wrong, and i have no ideas how to fix ipv6 layer.

Signed-off-by: Peter Kosyh <p.kosyh@gmail.com>

---

diff -Nur linux-2.6.35.7/net/ipv4/netfilter/iptable_mangle.c
linux-2.6.35.7-mark/net/ipv4/netfilter/iptable_mangle.c
--- linux-2.6.35.7/net/ipv4/netfilter/iptable_mangle.c	2010-09-29
05:09:08.000000000 +0400
+++ linux-2.6.35.7-mark/net/ipv4/netfilter/iptable_mangle.c	2011-03-02
15:54:14.000000000 +0300
@@ -84,9 +84,22 @@
 {
 	if (hook == NF_INET_LOCAL_OUT)
 		return ipt_mangle_out(skb, out);
-	if (hook == NF_INET_POST_ROUTING)
+	if (hook == NF_INET_POST_ROUTING) {
+#ifdef CONFIG_XFRM
+		int ret;
+		u_int32_t mark = skb->mark;
+		ret = ipt_do_table(skb, hook, in, out,
+				    dev_net(out)->ipv4.iptable_mangle);
+		if (skb->mark != mark && ret != NF_DROP && ret != NF_STOLEN) {
+			if (ip_xfrm_me_harder(skb))
+				ret = NF_DROP;
+		}
+		return ret;
+#else
 		return ipt_do_table(skb, hook, in, out,
 				    dev_net(out)->ipv4.iptable_mangle);
+#endif
+	}
 	/* PREROUTING/INPUT/FORWARD: */
 	return ipt_do_table(skb, hook, in, out,
 			    dev_net(in)->ipv4.iptable_mangle);
