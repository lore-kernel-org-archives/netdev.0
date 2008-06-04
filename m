From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL net-2.6] IPv6 fixes.
Date: Wed, 04 Jun 2008 12:02:50 +0900 (JST)
Message-ID: <20080604.120250.131119978.yoshfuji@linux-ipv6.org>
References: <4845EDB0.7030809@hp.com>
	<4845FDA1.1040009@cn.fujitsu.com>
	<20080604.113751.123223388.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: shanwei@cn.fujitsu.com, Brian.Haley@hp.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:58062 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbYFDDCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 23:02:13 -0400
In-Reply-To: <20080604.113751.123223388.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080604.113751.123223388.yoshfuji@linux-ipv6.org> (at Wed, 04 Jun 2008 11:37:51 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> > the attached patch fix it.
> 
> Ah, this reminds me I used wrong patch, sorry...

How about this?

If okay, tree is available at
    git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-fix.git net-2.6-misc-20080604d

Thanks.

If it is okay, I'll prepare -stable with some adjustments.

---
[IPV6]: Check outgoing interface even if source address is unspecified.

The outgoing interface index (ipi6_ifindex) in IPV6_PKTINFO
ancillary data, is not checked if the source address (ipi6_addr)
is unspecified.  If the ipi6_ifindex is the not-exist interface,
it should be fail and the errno should be set ENODEV.

Based on patch from Shan Wei <shanwei@cn.fujitsu.com> and
Brian Haley <brian.haley@hp.com>.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
Signed-off-by: Brian Haley <brian.haley@hp.com>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/datagram.c |   39 ++++++++++++++++++++-------------------
 1 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 94fa6ae..8091b20 100644
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
@@ -537,30 +539,29 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
 
 			addr_type = ipv6_addr_type(&src_info->ipi6_addr);
 
-			if (addr_type == IPV6_ADDR_ANY)
-				break;
+			if (fl->oif) {
+				dev = dev_get_by_index(&init_net, fl->oif);
+				if (!dev)
+					return -ENODEV;
+			} else if (addr_type & IPV6_ADDR_LINKLOCAL)
+				return -EINVAL;
 
-			if (addr_type & IPV6_ADDR_LINKLOCAL) {
-				if (!src_info->ipi6_ifindex)
-					return -EINVAL;
-				else {
-					dev = dev_get_by_index(&init_net, src_info->ipi6_ifindex);
-					if (!dev)
-						return -ENODEV;
-				}
-			}
-			if (!ipv6_chk_addr(&init_net, &src_info->ipi6_addr,
-					   dev, 0)) {
-				if (dev)
-					dev_put(dev);
-				err = -EINVAL;
-				goto exit_f;
+			if (addr_type != IPV6_ADDR_ANY) {
+				if (!ipv6_chk_addr(&init_net, &src_info->ipi6_addr,
+						   addr_type & IPV6_ADDR_LINKLOCAL ? dev : NULL, 0))
+					err = -EINVAL;
+				else
+					ipv6_addr_copy(&fl->fl6_src, &src_info->ipi6_addr);
 			}
+
 			if (dev)
 				dev_put(dev);
 
-			ipv6_addr_copy(&fl->fl6_src, &src_info->ipi6_addr);
+			if (err)
+				goto exit_f;
+
 			break;
+		    }
 
 		case IPV6_FLOWINFO:
 			if (cmsg->cmsg_len < CMSG_LEN(4)) {
-- 
1.4.4.4

