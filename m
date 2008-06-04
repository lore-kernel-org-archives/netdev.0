From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL net-2.6] IPv6 fixes.
Date: Wed, 04 Jun 2008 11:24:25 +0900 (JST)
Message-ID: <20080604.112425.32281350.yoshfuji@linux-ipv6.org>
References: <20080604.094917.75827853.yoshfuji@linux-ipv6.org>
	<4845EDB0.7030809@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brian.Haley@hp.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:58048 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbYFDCXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 22:23:47 -0400
In-Reply-To: <4845EDB0.7030809@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <4845EDB0.7030809@hp.com> (at Tue, 03 Jun 2008 21:19:44 -0400), Brian Haley <Brian.Haley@hp.com> says:

> I think this !src_info->ipi6_ifindex here should be !fl->oif - that will 
> have been assigned correctly if it was zero and src_info->ipi6_ifindex 
> was passed-in, and is what we used to do the device lookup.

Okay here's the update one.
Tree: git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-fix.git net-2.6-misc-20080604c

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
 net/ipv6/datagram.c |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 94fa6ae..bc50bb0 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -535,27 +535,28 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
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
-			if (!ipv6_chk_addr(&init_net, &src_info->ipi6_addr,
+
+			if (((addr_type & IPV6_ADDR_LINKLOCAL) && !fl->oif) ||
+			    !ipv6_chk_addr(&init_net, &src_info->ipi6_addr,
 					   dev, 0)) {
 				if (dev)
 					dev_put(dev);
 				err = -EINVAL;
 				goto exit_f;
 			}
+
 			if (dev)
 				dev_put(dev);
 
-- 
1.4.4.4

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
