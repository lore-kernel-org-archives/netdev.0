From: Ben Greear <greearb@candelatech.com>
Subject: Re: routing bug report for 2.4
Date: Sat, 28 Jun 2003 15:13:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EFE131E.1080807@candelatech.com>
References: <Pine.LNX.4.44.0306282332380.1804-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010105070505030601090008"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0306282332380.1804-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010105070505030601090008
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Julian Anastasov wrote:
> 	Hello,
> 
> On Sat, 28 Jun 2003, Ben Greear wrote:
> 
> 
>>What results do you get?  And did you set up policy based routing?
> 
> 
> 	I now see, the kernel sends "who-has local_IP" when you
> use 'ping -I device local_IP'. If this is considered bad we can extend
> the checks when fib_lookup fails:
> 
> - check for UP state (is it needed? return ENETDOWN?)
> - check if target IP is local and select "lo" instead of oif

Well, why should it try to route locally in this case (I'm assuming that
by using 'lo' it will not try to send on the external link)

Why not instead make it send to the router for that source-ip, if it is
configured.  If it is not configured, then I think arping is the best that
can be expected, as the behaviour becomes quite undefined and we really
have 'no route to host'.

My send-to-self patch that I have been using is attached.  I also have some other
patches for mac-vlans and packet-gen applied, but I don't believe these will have any
impact on the behaviour we have been discussing.

There is example code on how to use it (and an original, more crufty patch) here:
http://lwn.net/Articles/9897/

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>          <Ben_Greear@excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear

--------------010105070505030601090008
Content-Type: text/plain;
 name="sts.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sts.diff"

--- linux-2.4.20/include/linux/sockios.h        2001-11-07 14:39:36.000000000 -0800
+++ linux-2.4.20.c3/include/linux/sockios.h     2003-03-18 14:32:53.000000000 -0800
@@ -65,6 +65,8 @@
 #define SIOCDIFADDR    0x8936          /* delete PA address            */
 #define        SIOCSIFHWBROADCAST      0x8937  /* set hardware broadcast addr  */
 #define SIOCGIFCOUNT   0x8938          /* get number of devices */
+#define SIOCGIFWEIGHT  0x8939          /* get weight of device, in stones */
+#define SIOCSIFWEIGHT  0x893a          /* set weight of device, in stones */
  
 #define SIOCGIFBR      0x8940          /* Bridging support             */
 #define SIOCSIFBR      0x8941          /* Set bridging options         */
@@ -92,6 +94,10 @@
 #define SIOCGRARP      0x8961          /* get RARP table entry         */
 #define SIOCSRARP      0x8962          /* set RARP table entry         */
  
+/* MAC address based VLAN control calls */
+#define SIOCGIFMACVLAN 0x8965          /* Mac address multiplex/demultiplex support */
+#define SIOCSIFMACVLAN 0x8966          /* Set macvlan options  */
+
 /* Driver configuration calls */
  
 #define SIOCGIFMAP     0x8970          /* Get device parameters        */
@@ -114,6 +120,16 @@
 #define SIOCBONDINFOQUERY      0x8994  /* rtn info about bond state    */
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
--- linux-2.4.20/net/Config.in  2002-08-02 17:39:46.000000000 -0700
+++ linux-2.4.20.c3/net/Config.in       2003-03-18 14:32:53.000000000 -0800
@@ -48,6 +48,7 @@
             bool '    Per-VC IP filter kludge' CONFIG_ATM_BR2684_IPFILTER
       fi
    fi
+   tristate 'MAC address based VLANs (EXPERIMENTAL)' CONFIG_MACVLAN
 fi
 tristate '802.1Q VLAN Support' CONFIG_VLAN_8021Q
  
--- linux-2.4.20/net/ipv4/arp.c 2002-11-28 15:53:15.000000000 -0800
+++ linux-2.4.20.c3/net/ipv4/arp.c      2003-03-18 14:32:53.000000000 -0800
@@ -1,4 +1,4 @@
-/* linux/net/inet/arp.c
+/* linux/net/inet/arp.c  -*-linux-c-*-
  *
  * Version:    $Id: arp.c,v 1.99 2001/08/30 22:55:42 davem Exp $
  *
@@ -351,12 +351,22 @@
        int flag = 0;
        /*unsigned long now; */
  
-       if (ip_route_output(&rt, sip, tip, 0, 0) < 0)
+       if (ip_route_output(&rt, sip, tip, 0, 0) < 0)
                return 1;
-       if (rt->u.dst.dev != dev) {
-               NET_INC_STATS_BH(ArpFilter);
-               flag = 1;
-       }
+
+       if (rt->u.dst.dev != dev) {
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
--- linux-2.4.20/net/ipv4/fib_frontend.c        2002-08-02 17:39:46.000000000 -0700
+++ linux-2.4.20.c3/net/ipv4/fib_frontend.c     2003-03-18 14:32:53.000000000 -0800
@@ -233,8 +233,17 @@
                                                                                                    
        if (fib_lookup(&key, &res))
                goto last_resort;
-       if (res.type != RTN_UNICAST)
-               goto e_inval_res;
+
+       if (res.type != RTN_UNICAST) {
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
--- linux-2.4.20/net/ipv4/tcp_ipv4.c    2002-11-28 15:53:15.000000000 -0800
+++ linux-2.4.20.c3/net/ipv4/tcp_ipv4.c 2003-03-18 14:32:53.000000000 -0800
@@ -1394,7 +1394,7 @@
 #define want_cookie 0 /* Argh, why doesn't gcc optimize this :( */
 #endif
                                                                                                    
-       /* Never answer to SYNs send to broadcast or multicast */
+       /* Never answer to SYNs sent to broadcast or multicast */
        if (((struct rtable *)skb->dst)->rt_flags &
            (RTCF_BROADCAST|RTCF_MULTICAST))
                goto drop;


--------------010105070505030601090008--
