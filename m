From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Move inetdev/ifa over to RCU
Date: Sat, 14 Aug 2004 16:31:19 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040814063119.GA18907@gondor.apana.org.au>
References: <20040812165954.00429e65.davem@redhat.com> <20040813090314.448c971d@dell_ss3.pdx.osdl.net> <20040813093838.6961c0d4.davem@redhat.com> <20040813215602.GA15870@gondor.apana.org.au> <20040813151923.3311b4f0.davem@redhat.com> <20040814003428.GA17760@gondor.apana.org.au> <20040813173924.6d05be15.davem@redhat.com> <20040814005411.GA18350@gondor.apana.org.au> <20040814012513.GA721@gondor.apana.org.au> <20040814013030.GA2042@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="vtzGhvizbBRQ85DL"
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040814013030.GA2042@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

On Sat, Aug 14, 2004 at 11:30:30AM +1000, herbert wrote:
> 
> Here are some more ifa_list fixes outside net/ipv4.

Missed one in sdlamain.c because it was marked BROKEN.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p1

===== drivers/net/wan/sdlamain.c 1.23 vs edited =====
--- 1.23/drivers/net/wan/sdlamain.c	2003-10-06 02:23:10 +10:00
+++ edited/drivers/net/wan/sdlamain.c	2004-08-14 15:16:40 +10:00
@@ -68,6 +68,7 @@
 #include <linux/inetdevice.h>
 
 #include <linux/ip.h>
+#include <linux/rcupdate.h>
 #include <net/route.h>
  
 #define KMEM_SAFETYZONE 8
@@ -1268,37 +1269,39 @@
 	
 	struct in_ifaddr *ifaddr;
 	struct in_device *in_dev;
+	unsigned long addr = 0;
 
+	rcu_read_lock();
 	if ((in_dev = __in_dev_get(dev)) == NULL){
-		return 0;
+		goto out;
 	}
 
 	if ((ifaddr = in_dev->ifa_list)== NULL ){
-		return 0;
+		goto out;
 	}
 	
 	switch (option){
 
 	case WAN_LOCAL_IP:
-		return ifaddr->ifa_local;
+		addr = ifaddr->ifa_local;
 		break;
 	
 	case WAN_POINTOPOINT_IP:
-		return ifaddr->ifa_address;
+		addr = ifaddr->ifa_address;
 		break;	
 
 	case WAN_NETMASK_IP:
-		return ifaddr->ifa_mask;
+		addr = ifaddr->ifa_mask;
 		break;
 
 	case WAN_BROADCAST_IP:
-		return ifaddr->ifa_broadcast;
+		addr = ifaddr->ifa_broadcast;
 		break;
-	default:
-		return 0;
 	}
 
-	return 0;
+out:
+	rcu_read_unlock();
+	return addr;
 }	
 
 void add_gateway(sdla_t *card, struct net_device *dev)

--vtzGhvizbBRQ85DL--
