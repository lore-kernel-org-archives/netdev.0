From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: Deprecate All-on-link Assumption
Date: Fri, 10 Sep 2004 10:48:30 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910.104830.121402882.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, netdev@oss.sgi.com, kunitake@linux-ipv6.org,
        yoshfuji@linux-ipv6.org, aesop-core@kame.net
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

If we don't have IPv6 default routes, we assume all ipv6 destinations 
are on-link as specified in RFC2461. It, however, is considered harmful now;
it is problematic with IPv6-capable nodes that do not have off-link
IPv6 connectivity (eg no default routers) and such nodes will take
a few seconds until they fall back to use IPv4.

See <draft-ietf-v6ops-onlinkassumption-02.txt> for details.

Thanks.

From: KUNITAKE Koichi <kunitake@anchor.jp>
Signed-off-by: KUNITAKE Koichi <kunitake@anchor.jp>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

===== net/ipv6/addrconf.c 1.106 vs edited =====
--- 1.106/net/ipv6/addrconf.c	2004-08-17 11:25:06 +09:00
+++ edited/net/ipv6/addrconf.c	2004-09-10 01:49:17 +09:00
@@ -2107,21 +2107,13 @@
 
 		ndisc_send_rs(ifp->idev->dev, &ifp->addr, &all_routers);
 	} else {
-		struct in6_rtmsg rtmsg;
-
 		spin_unlock(&ifp->lock);
-
+		/*
+		 * Note: we do not support deprecated "all on-link"
+		 * assumption any longer.
+		 */
 		printk(KERN_DEBUG "%s: no IPv6 routers present\n",
 		       ifp->idev->dev->name);
-
-		memset(&rtmsg, 0, sizeof(struct in6_rtmsg));
-		rtmsg.rtmsg_type = RTMSG_NEWROUTE;
-		rtmsg.rtmsg_metric = IP6_RT_PRIO_ADDRCONF;
-		rtmsg.rtmsg_flags = (RTF_ALLONLINK | RTF_DEFAULT | RTF_UP);
-
-		rtmsg.rtmsg_ifindex = ifp->idev->dev->ifindex;
-
-		ip6_route_add(&rtmsg, NULL, NULL);
 	}
 
 out:

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
