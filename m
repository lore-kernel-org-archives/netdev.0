From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Move inetdev/ifa over to RCU
Date: Sat, 14 Aug 2004 11:30:30 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040814013030.GA2042@gondor.apana.org.au>
References: <20040812165954.00429e65.davem@redhat.com> <20040813090314.448c971d@dell_ss3.pdx.osdl.net> <20040813093838.6961c0d4.davem@redhat.com> <20040813215602.GA15870@gondor.apana.org.au> <20040813151923.3311b4f0.davem@redhat.com> <20040814003428.GA17760@gondor.apana.org.au> <20040813173924.6d05be15.davem@redhat.com> <20040814005411.GA18350@gondor.apana.org.au> <20040814012513.GA721@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="RnlQjJ0d97Da+TV1"
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040814012513.GA721@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--RnlQjJ0d97Da+TV1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

Here are some more ifa_list fixes outside net/ipv4.
 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--RnlQjJ0d97Da+TV1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=q

===== drivers/net/wan/syncppp.c 1.19 vs edited =====
--- 1.19/drivers/net/wan/syncppp.c	2004-07-13 23:29:35 +10:00
+++ edited/drivers/net/wan/syncppp.c	2004-08-14 10:57:25 +10:00
@@ -50,6 +50,7 @@
 #include <linux/random.h>
 #include <linux/pkt_sched.h>
 #include <linux/spinlock.h>
+#include <linux/rcupdate.h>
 
 #include <net/syncppp.h>
 
@@ -767,9 +768,9 @@
 		struct in_ifaddr *ifa;
 		u32 addr = 0, mask = ~0; /* FIXME: is the mask correct? */
 #ifdef CONFIG_INET
-		if ((in_dev=in_dev_get(dev)) != NULL)
+		rcu_read_lock();
+		if ((in_dev = __in_dev_get(dev)) != NULL)
 		{
-			read_lock(&in_dev->lock);
 			for (ifa=in_dev->ifa_list; ifa != NULL;
 				ifa=ifa->ifa_next) {
 				if (strcmp(dev->name, ifa->ifa_label) == 0) 
@@ -779,9 +780,8 @@
 					break;
 				}
 			}
-			read_unlock(&in_dev->lock);
-			in_dev_put(in_dev);
 		}
+		rcu_read_unlock();
 #endif		
 		/* I hope both addr and mask are in the net order */
 		sppp_cisco_send (sp, CISCO_ADDR_REPLY, addr, mask);
===== drivers/net/wireless/strip.c 1.24 vs edited =====
--- 1.24/drivers/net/wireless/strip.c	2004-07-13 23:29:35 +10:00
+++ edited/drivers/net/wireless/strip.c	2004-08-14 11:05:22 +10:00
@@ -106,6 +106,7 @@
 #include <linux/seq_file.h>
 #include <linux/serial.h>
 #include <linux/serialP.h>
+#include <linux/rcupdate.h>
 #include <net/arp.h>
 
 #include <linux/ip.h>
@@ -1348,14 +1349,17 @@
 	 */
 	if (haddr.c[0] == 0xFF) {
 		u32 brd = 0;
-		struct in_device *in_dev = in_dev_get(strip_info->dev);
-		if (in_dev == NULL)
+		struct in_device *in_dev;
+
+		rcu_read_lock();
+		in_dev = __in_dev_get(strip_info->dev);
+		if (in_dev == NULL) {
+			rcu_read_unlock();
 			return NULL;
-		read_lock(&in_dev->lock);
+		}
 		if (in_dev->ifa_list)
 			brd = in_dev->ifa_list->ifa_broadcast;
-		read_unlock(&in_dev->lock);
-		in_dev_put(in_dev);
+		rcu_read_unlock();
 
 		/* arp_query returns 1 if it succeeds in looking up the address, 0 if it fails */
 		if (!arp_query(haddr.c, brd, strip_info->dev)) {
@@ -1500,17 +1504,18 @@
 	}
 
 	if (1) {
-		struct in_device *in_dev = in_dev_get(strip_info->dev);
+		struct in_device *in_dev;
+
 		brd = addr = 0;
+		rcu_read_lock();
+		in_dev = __in_dev_get(strip_info->dev);
 		if (in_dev) {
-			read_lock(&in_dev->lock);
 			if (in_dev->ifa_list) {
 				brd = in_dev->ifa_list->ifa_broadcast;
 				addr = in_dev->ifa_list->ifa_local;
 			}
-			read_unlock(&in_dev->lock);
-			in_dev_put(in_dev);
 		}
+		rcu_read_unlock();
 	}
 
 
===== net/core/netpoll.c 1.12 vs edited =====
--- 1.12/net/core/netpoll.c	2004-07-03 06:38:38 +10:00
+++ edited/net/core/netpoll.c	2004-08-14 10:58:29 +10:00
@@ -18,6 +18,7 @@
 #include <linux/interrupt.h>
 #include <linux/netpoll.h>
 #include <linux/sched.h>
+#include <linux/rcupdate.h>
 #include <net/tcp.h>
 #include <net/udp.h>
 
@@ -572,16 +573,18 @@
 		memcpy(np->local_mac, ndev->dev_addr, 6);
 
 	if (!np->local_ip) {
-		in_dev = in_dev_get(ndev);
+		rcu_read_lock();
+		in_dev = __in_dev_get(ndev);
 
 		if (!in_dev) {
+			rcu_read_unlock();
 			printk(KERN_ERR "%s: no IP address for %s, aborting\n",
 			       np->name, np->dev_name);
 			goto release;
 		}
 
 		np->local_ip = ntohl(in_dev->ifa_list->ifa_local);
-		in_dev_put(in_dev);
+		rcu_read_unlock();
 		printk(KERN_INFO "%s: local IP %d.%d.%d.%d\n",
 		       np->name, HIPQUAD(np->local_ip));
 	}
===== net/core/pktgen.c 1.12 vs edited =====
--- 1.12/net/core/pktgen.c	2004-07-29 12:06:49 +10:00
+++ edited/net/core/pktgen.c	2004-08-14 11:01:55 +10:00
@@ -70,6 +70,7 @@
 #include <linux/delay.h>
 #include <linux/init.h>
 #include <linux/inet.h>
+#include <linux/rcupdate.h>
 #include <asm/byteorder.h>
 #include <asm/bitops.h>
 #include <asm/io.h>
@@ -263,14 +264,17 @@
 	info->saddr_min = 0;
 	info->saddr_max = 0;
 	if (strlen(info->src_min) == 0) {
-		struct in_device *in_dev = in_dev_get(odev);
+		struct in_device *in_dev;
+
+		rcu_read_lock();
+		in_dev = __in_dev_get(odev);
 		if (in_dev) {
 			if (in_dev->ifa_list) {
 				info->saddr_min = in_dev->ifa_list->ifa_address;
 				info->saddr_max = info->saddr_min;
 			}
-			in_dev_put(in_dev);
 		}
+		rcu_read_unlock();
 	}
 	else {
 		info->saddr_min = in_aton(info->src_min);
===== net/econet/af_econet.c 1.42 vs edited =====
--- 1.42/net/econet/af_econet.c	2004-07-17 00:13:45 +10:00
+++ edited/net/econet/af_econet.c	2004-08-14 11:09:32 +10:00
@@ -39,6 +39,7 @@
 #include <net/udp.h>
 #include <net/ip.h>
 #include <linux/spinlock.h>
+#include <linux/rcupdate.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -401,16 +402,17 @@
 	   y.x maps to IP a.b.c.x.  This should be replaced with something
 	   more flexible and more aware of subnet masks.  */
 	{
-		struct in_device *idev = in_dev_get(dev);
+		struct in_device *idev;
 		unsigned long network = 0;
+
+		rcu_read_lock();
+		idev = __in_dev_get(dev);
 		if (idev) {
-			read_lock(&idev->lock);
 			if (idev->ifa_list)
 				network = ntohl(idev->ifa_list->ifa_address) & 
 					0xffffff00;		/* !!! */
-			read_unlock(&idev->lock);
-			in_dev_put(idev);
 		}
+		rcu_read_unlock();
 		udpdest.sin_addr.s_addr = htonl(network | addr.station);
 	}
 

--RnlQjJ0d97Da+TV1--
