From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] Netfilter crossover module.
Date: Thu, 10 Jul 2003 09:52:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0D99DB.5040206@candelatech.com>
References: <20030710084820.909D12C0DA@lists.samba.org> <20030710090643.A10820@mindspring.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010705080708070503070404"
Cc: Rusty Russell <rusty@rustcorp.com.au>, netdev@oss.sgi.com,
   netfilter-devel@lists.netfilter.org, anton@samba.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jleu@mindspring.com
In-Reply-To: <20030710090643.A10820@mindspring.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010705080708070503070404
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

James R. Leu wrote:
> Between you and Ben Greear the linux kernel will have every possible
> scheme for sending packets to your self.
> 
> I still think my work on this (Virtual routing and forwarding:
> http://linux-vrf.sf.net/) is the less perverted(*) then the work that either
> you or Ben have come up with.  Plus it has other applications besides
> just being able to send packets to your self.
> 
> * in terms of the concept, not necessarily the actual implementation.

>>It'd be nice to have the module hardwire the arps itself, but this was
>>quickest.  Patch welcome.

It's likely that with my patch you wouldn't have to hard-wire arps at
all.  The primary thing that my patch does is to let a machine answer
arps from a local interface (over the external interface).

Then routing to self can happen by simply(?) binding to the local IP
of your choice and using policy-based routing to route correctly.
(You can loop-back through a router with this patch, for example.)

So, maybe both patches are useful together....

I can't find where I posted my patch last time, so it is
attached again for reference.  It contains a typo-fix in a comment
that may be worthy of inclusion by itself some day :)
Also, when nettool (ethtool) becomes generic, the ioctl code can be
configured through the nettool api, so that new ioctl will go a way.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear


--------------010705080708070503070404
Content-Type: text/plain;
 name="sts_2.4.20.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sts_2.4.20.patch"

--- linux-2.4.20/include/linux/sockios.h	2001-11-07 14:39:36.000000000 -0800
+++ linux-2.4.20.c3/include/linux/sockios.h	2003-03-18 14:32:53.000000000 -0800
@@ -65,6 +65,8 @@
 #define SIOCDIFADDR	0x8936		/* delete PA address		*/
 #define	SIOCSIFHWBROADCAST	0x8937	/* set hardware broadcast addr	*/
 #define SIOCGIFCOUNT	0x8938		/* get number of devices */
+#define SIOCGIFWEIGHT	0x8939		/* get weight of device, in stones */
+#define SIOCSIFWEIGHT	0x893a		/* set weight of device, in stones */
 
 #define SIOCGIFBR	0x8940		/* Bridging support		*/
 #define SIOCSIFBR	0x8941		/* Set bridging options 	*/
@@ -92,6 +94,10 @@
 #define SIOCGRARP	0x8961		/* get RARP table entry		*/
 #define SIOCSRARP	0x8962		/* set RARP table entry		*/
 
+/* MAC address based VLAN control calls */
+#define SIOCGIFMACVLAN	0x8965		/* Mac address multiplex/demultiplex support */
+#define SIOCSIFMACVLAN	0x8966		/* Set macvlan options 	*/
+
 /* Driver configuration calls */
 
 #define SIOCGIFMAP	0x8970		/* Get device parameters	*/
@@ -114,6 +120,16 @@
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
--- linux-2.4.20/net/Config.in	2002-08-02 17:39:46.000000000 -0700
+++ linux-2.4.20.c3/net/Config.in	2003-03-18 14:32:53.000000000 -0800
@@ -48,6 +48,7 @@
             bool '    Per-VC IP filter kludge' CONFIG_ATM_BR2684_IPFILTER
       fi
    fi
+   tristate 'MAC address based VLANs (EXPERIMENTAL)' CONFIG_MACVLAN
 fi
 tristate '802.1Q VLAN Support' CONFIG_VLAN_8021Q
 
--- linux-2.4.20/net/ipv4/arp.c	2002-11-28 15:53:15.000000000 -0800
+++ linux-2.4.20.c3/net/ipv4/arp.c	2003-03-18 14:32:53.000000000 -0800
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
--- linux-2.4.20/net/ipv4/fib_frontend.c	2002-08-02 17:39:46.000000000 -0700
+++ linux-2.4.20.c3/net/ipv4/fib_frontend.c	2003-03-18 14:32:53.000000000 -0800
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
--- linux-2.4.20/net/ipv4/tcp_ipv4.c	2002-11-28 15:53:15.000000000 -0800
+++ linux-2.4.20.c3/net/ipv4/tcp_ipv4.c	2003-03-18 14:32:53.000000000 -0800
@@ -1394,7 +1394,7 @@
 #define want_cookie 0 /* Argh, why doesn't gcc optimize this :( */
 #endif
 
-	/* Never answer to SYNs send to broadcast or multicast */
+	/* Never answer to SYNs sent to broadcast or multicast */
 	if (((struct rtable *)skb->dst)->rt_flags & 
 	    (RTCF_BROADCAST|RTCF_MULTICAST))
 		goto drop; 

--------------010705080708070503070404--
