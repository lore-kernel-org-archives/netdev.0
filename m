From: Ben Greear <greearb@candelatech.com>
Subject: [PATCH]  Send-to-Self patch, against 2.4.20-rc1
Date: Tue, 05 Nov 2002 21:59:11 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DC8AFAF.5070803@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000507000602040501040901"
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000507000602040501040901
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Here is the send-to-self patch again.  Dave, earlier you had asked to
have the same changes applied to ipv6 as ipv4.  Turns out, nothing
needs to be done to ipv4, so I imagine nothing needs to be done to ipv6
either....

So, are you more interested in the patch now?  If not, please tell me
what theoretical action on my part would make the patch more palatable!
If you just don't like it, let me know so I quit wasting my time.

I have cobbled this patch together somewhat manually, trying to break
out other network changes in my tree, so it may take a bit of pushing
to get it to apply.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear


--------------000507000602040501040901
Content-Type: text/plain;
 name="sts_pub_2.4.19.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sts_pub_2.4.19.patch"

--- linux-2.4.19/net/core/dev.c	Tue Oct 22 22:50:05 2002
+++ linux-2.4.19.p4/net/core/dev.c	Tue Oct 22 20:50:01 2002
@@ -2153,7 +2183,25 @@
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
@@ -2249,7 +2307,8 @@
 		case SIOCGIFMAP:
 		case SIOCGIFINDEX:
 		case SIOCGIFTXQLEN:
+                case SIOCGACCEPTLOCALADDRS:
 			dev_load(ifr.ifr_name);
 			read_lock(&dev_base_lock);
 			ret = dev_ifsioc(&ifr, cmd);
--- linux-2.4.19/include/linux/if.h	Thu Nov 22 11:47:07 2001
+++ linux-2.4.19.p4/include/linux/if.h	Tue Oct 22 20:54:58 2002
@@ -47,7 +47,13 @@
 
 /* Private (from user) interface flags (netdevice->priv_flags). */
 #define IFF_802_1Q_VLAN 0x1             /* 802.1Q VLAN device.          */
+#define IFF_PKTGEN_RCV  0x2             /* Registered to receive & consume  Pktgen skbs */
+#define IFF_ACCEPT_LOCAL_ADDRS 0x4      /**  Accept pkts even if they come from a local
+                                         * address.  This lets use send pkts to ourselves
+                                         * over external interfaces (when used in conjunction
+                                         * with SO_BINDTODEVICE
+                                         */
 
 /*
  *	Device mapping structure. I'd just gone off and designed a 
--- linux-2.4.19.p3/include/linux/sockios.h	Wed Nov  7 14:39:36 2001
+++ linux-2.4.19.p4/include/linux/sockios.h	Tue Nov  5 21:38:41 2002
@@ -65,6 +65,8 @@
 #define SIOCDIFADDR	0x8936		/* delete PA address		*/
 #define	SIOCSIFHWBROADCAST	0x8937	/* set hardware broadcast addr	*/
 #define SIOCGIFCOUNT	0x8938		/* get number of devices */
+#define SIOCGIFWEIGHT	0x8939		/* get weight of device, in stones */
+#define SIOCSIFWEIGHT	0x893a		/* set weight of device, in stones */
 
 #define SIOCGIFBR	0x8940		/* Bridging support		*/
 #define SIOCSIFBR	0x8941		/* Set bridging options 	*/
@@ -114,6 +116,16 @@
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
--- linux-2.4.19.p3/net/ipv4/arp.c	Tue Nov  5 21:33:43 2002
+++ linux-2.4.19.p4/net/ipv4/arp.c	Tue Nov  5 21:38:41 2002
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
--- linux-2.4.19.p3/net/ipv4/fib_frontend.c	Fri Aug  2 17:39:46 2002
+++ linux-2.4.19.p4/net/ipv4/fib_frontend.c	Tue Nov  5 21:38:41 2002
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
--- linux-2.4.19.p3/net/ipv4/tcp_ipv4.c	Tue Nov  5 21:33:46 2002
+++ linux-2.4.19.p4/net/ipv4/tcp_ipv4.c	Tue Nov  5 21:38:41 2002
@@ -1394,7 +1394,7 @@
 #define want_cookie 0 /* Argh, why doesn't gcc optimize this :( */
 #endif
 
-	/* Never answer to SYNs send to broadcast or multicast */
+	/* Never answer to SYNs sent to broadcast or multicast */
 	if (((struct rtable *)skb->dst)->rt_flags & 
 	    (RTCF_BROADCAST|RTCF_MULTICAST))
 		goto drop; 

--------------000507000602040501040901--
