From: Ben Greear <greearb@candelatech.com>
Subject: PATCH:  send-to-self:  smaller & better
Date: Sat, 05 Oct 2002 21:29:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D9FBC28.8050807@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I went and took out all the code that Alexey said was dead.  It appears
he was right :)

Anyway, here is a smaller patch that seems to work fine:

--- linux-2.4.19/include/linux/sockios.h	Wed Nov  7 15:39:36 2001
+++ linux-2.4.19.dev/include/linux/sockios.h	Sat Oct  5 20:23:48 2002
@@ -114,6 +114,16 @@
  #define SIOCBONDINFOQUERY      0x8994	/* rtn info about bond state    */
  #define SIOCBONDCHANGEACTIVE   0x8995   /* update to a new active slave */
  			
+
+/* Ben's little hack land */
+#define SIOCSACCEPTLOCALADDRS  0x89a0   /*  Allow interfaces to accept pkts from
+                                         * local interfaces...use with SO_BINDTODEVICE
+                                         */
+#define SIOCGACCEPTLOCALADDRS  0x89a1   /*  Allow interfaces to accept pkts from
+                                         * local interfaces...use with SO_BINDTODEVICE
+                                         */
+
+
  /* Device private ioctl calls */

  /*
--- linux-2.4.19/net/ipv4/arp.c	Fri Aug  2 17:39:46 2002
+++ linux-2.4.19.dev/net/ipv4/arp.c	Sat Oct  5 20:23:48 2002
@@ -1,4 +1,4 @@
-/* linux/net/inet/arp.c
+/* linux/net/inet/arp.c  -*-linux-c-*-
   *
   * Version:	$Id: arp.c,v 1.99 2001/08/30 22:55:42 davem Exp $
   *
@@ -351,12 +351,22 @@
  	int flag = 0;
  	/*unsigned long now; */

-	if (ip_route_output(&rt, sip, tip, 0, 0) < 0)
+	if (ip_route_output(&rt, sip, tip, 0, 0) < 0)
  		return 1;
-	if (rt->u.dst.dev != dev) {
-		NET_INC_STATS_BH(ArpFilter);
-		flag = 1;
-	}
+
+	if (rt->u.dst.dev != dev) {
+                if ((dev->priv_flags & IFF_ACCEPT_LOCAL_ADDRS) &&
+                    (rt->u.dst.dev == &loopback_dev))  {
+                        /* OK, we'll let this special case slide, so that we can arp from one
+                         * local interface to another.  This seems to work, but could use some
+                         * review. --Ben
+                         */
+                }
+                else {
+                        NET_INC_STATS_BH(ArpFilter);
+                        flag = 1;
+                }
+        }
  	ip_rt_put(rt);
  	return flag;
  }
--- linux-2.4.19/net/ipv4/fib_frontend.c	Fri Aug  2 17:39:46 2002
+++ linux-2.4.19.dev/net/ipv4/fib_frontend.c	Sat Oct  5 20:23:48 2002
@@ -233,8 +233,17 @@

  	if (fib_lookup(&key, &res))
  		goto last_resort;
-	if (res.type != RTN_UNICAST)
-		goto e_inval_res;
+
+	if (res.type != RTN_UNICAST) {
+                if ((res.type == RTN_LOCAL) &&
+                    (dev->priv_flags & IFF_ACCEPT_LOCAL_ADDRS)) {
+                        /* All is OK */
+                }
+                else {
+                        goto e_inval_res;
+                }
+        }
+
  	*spec_dst = FIB_RES_PREFSRC(res);
  	fib_combine_itag(itag, &res);
  #ifdef CONFIG_IP_ROUTE_MULTIPATH
--- linux-2.4.19/net/ipv4/tcp_ipv4.c	Fri Aug  2 17:39:46 2002
+++ linux-2.4.19.dev/net/ipv4/tcp_ipv4.c	Sat Oct  5 20:24:45 2002
@@ -1394,7 +1394,7 @@
  #define want_cookie 0 /* Argh, why doesn't gcc optimize this :( */
  #endif

-	/* Never answer to SYNs send to broadcast or multicast */
+	/* Never answer to SYNs sent to broadcast or multicast */
  	if (((struct rtable *)skb->dst)->rt_flags &
  	    (RTCF_BROADCAST|RTCF_MULTICAST))
  		goto drop;
--- linux-2.4.19/net/core/dev.c	Sat Oct  5 20:40:21 2002
+++ linux-2.4.19.dev/net/core/dev.c	Sat Oct  5 20:25:30 2002
@@ -2153,6 +2183,24 @@
  			notifier_call_chain(&netdev_chain, NETDEV_CHANGENAME, dev);
  			return 0;

+                case SIOCSACCEPTLOCALADDRS:
+                        if (ifr->ifr_flags) {
+                                dev->priv_flags |= IFF_ACCEPT_LOCAL_ADDRS;
+                        }
+                        else {
+                                dev->priv_flags &= ~IFF_ACCEPT_LOCAL_ADDRS;
+                        }
+                        return 0;
+
+                case SIOCGACCEPTLOCALADDRS:
+                        if (dev->priv_flags & IFF_ACCEPT_LOCAL_ADDRS) {
+                                ifr->ifr_flags = 1;
+                        }
+                        else {
+                                ifr->ifr_flags = 0;
+                        }
+                        return 0;
+
  		/*
  		 *	Unknown or private ioctl
  		 */
@@ -2249,6 +2297,7 @@
  		case SIOCGIFMAP:
  		case SIOCGIFINDEX:
  		case SIOCGIFTXQLEN:
+                case SIOCGACCEPTLOCALADDRS:
  			dev_load(ifr.ifr_name);
  			read_lock(&dev_base_lock);
  			ret = dev_ifsioc(&ifr, cmd);
@@ -2312,6 +2361,7 @@
  		case SIOCBONDSLAVEINFOQUERY:
  		case SIOCBONDINFOQUERY:
  		case SIOCBONDCHANGEACTIVE:
+                case SIOCSACCEPTLOCALADDRS:
  			if (!capable(CAP_NET_ADMIN))
  				return -EPERM;
  			dev_load(ifr.ifr_name);




-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
