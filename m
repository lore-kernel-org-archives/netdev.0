From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH v2] IPv6: fix bug when specifying the non-exist
 outgoing interface
Date: Tue, 03 Jun 2008 13:52:49 +0900 (JST)
Message-ID: <20080603.135249.31016680.yoshfuji@linux-ipv6.org>
References: <20080603.014819.38527291.yoshfuji@linux-ipv6.org>
	<20080603.020734.75959629.yoshfuji@linux-ipv6.org>
	<4844303E.1040104@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: shanwei@cn.fujitsu.com, davem@davemloft.net,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:57997 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbYFCEwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 00:52:15 -0400
In-Reply-To: <4844303E.1040104@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <4844303E.1040104@hp.com> (at Mon, 02 Jun 2008 13:39:10 -0400), Brian Haley <brian.haley@hp.com> says:

> YOSHIFUJI Hideaki / 吉藤英明 wrote:
> > -			if (addr_type == IPV6_ADDR_ANY)
> > +			addr_type = ipv6_addr_type(&src_info->ipi6_addr);
> > +			if (addr_type == IPV6_ADDR_ANY ||
> > +			    addr_type & IPV6_ADDR_MULTICAST) {
> > +				if (dev)
> > +					dev_put(dev);
> >  				break;
> 
> What about link-local multicast?  We should check ifindex there too.  I
> think that check should just be for IPV6_ADDR_ANY.  I think making this
> more like inet6_bind() and not doing the ipv6_chk_addr() call for
> Multicast would be the best thing, right?

My brain was sleeping.  I intended to check if the source
address is NOT an multicast, but I think we can let ipv6_chk_addr()
check it.

BTW we do not check if the address is valid unicast when we assign new
address on interface.  That does not seem good to me...
(but (some?) BSDs do not seem to check this, hmm...)

---
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 94fa6ae..f55269a 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -509,7 +509,6 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
 
 	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
 		int addr_type;
-		struct net_device *dev = NULL;
 
 		if (!CMSG_OK(msg, cmsg)) {
 			err = -EINVAL;
@@ -522,6 +521,9 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
 		switch (cmsg->cmsg_type) {
 		case IPV6_PKTINFO:
 		case IPV6_2292PKTINFO:
+		    {
+			struct net_device *dev = NULL;
+
 			if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct in6_pktinfo))) {
 				err = -EINVAL;
 				goto exit_f;
@@ -535,32 +537,34 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
 				fl->oif = src_info->ipi6_ifindex;
 			}
 
-			addr_type = ipv6_addr_type(&src_info->ipi6_addr);
+			if (fl->oif) {
+				dev = dev_get_by_index(&init_net, fl->oif);
+				if (!dev)
+					return -ENODEV;
+			}
 
-			if (addr_type == IPV6_ADDR_ANY)
+			addr_type = ipv6_addr_type(&src_info->ipi6_addr);
+			if (addr_type == IPV6_ADDR_ANY) {
+				if (dev)
+					dev_put(dev);
 				break;
-
-			if (addr_type & IPV6_ADDR_LINKLOCAL) {
-				if (!src_info->ipi6_ifindex)
-					return -EINVAL;
-				else {
-					dev = dev_get_by_index(&init_net, src_info->ipi6_ifindex);
-					if (!dev)
-						return -ENODEV;
-				}
 			}
+
 			if (!ipv6_chk_addr(&init_net, &src_info->ipi6_addr,
-					   dev, 0)) {
+					   addr_type & IPV6_ADDR_LINKLOCAL ? dev : NULL,
+					   0)) {
 				if (dev)
 					dev_put(dev);
 				err = -EINVAL;
 				goto exit_f;
 			}
+
 			if (dev)
 				dev_put(dev);
 
 			ipv6_addr_copy(&fl->fl6_src, &src_info->ipi6_addr);
 			break;
+		    }
 
 		case IPV6_FLOWINFO:
 			if (cmsg->cmsg_len < CMSG_LEN(4)) {

--yoshfuji
