From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Move inetdev/ifa over to RCU
Date: Sat, 14 Aug 2004 16:32:35 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040814063235.GB18907@gondor.apana.org.au>
References: <20040813090314.448c971d@dell_ss3.pdx.osdl.net> <20040813093838.6961c0d4.davem@redhat.com> <20040813215602.GA15870@gondor.apana.org.au> <20040813151923.3311b4f0.davem@redhat.com> <20040814003428.GA17760@gondor.apana.org.au> <20040813173924.6d05be15.davem@redhat.com> <20040814005411.GA18350@gondor.apana.org.au> <20040814012513.GA721@gondor.apana.org.au> <20040814013030.GA2042@gondor.apana.org.au> <20040814063119.GA18907@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="EuxKj2iCbKjpUGkD"
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040814063119.GA18907@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--EuxKj2iCbKjpUGkD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

On Sat, Aug 14, 2004 at 04:31:19PM +1000, herbert wrote:
> 
> Missed one in sdlamain.c because it was marked BROKEN.

And a couple of them which are S390 only.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--EuxKj2iCbKjpUGkD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p2

===== drivers/s390/net/lcs.c 1.31 vs edited =====
--- 1.31/drivers/s390/net/lcs.c	2004-08-08 04:05:36 +10:00
+++ edited/drivers/s390/net/lcs.c	2004-08-14 15:34:58 +10:00
@@ -1002,7 +1002,7 @@
 	in4_dev = in_dev_get(card->dev);
 	if (in4_dev == NULL)
 		return 0;
-	read_lock(&in4_dev->lock);
+	read_lock(&in4_dev->mc_list_lock);
 	spin_lock(&card->ipm_lock);
 	/* Check for multicast addresses to be removed. */
 	list_for_each(l, &card->ipm_list) {
@@ -1046,7 +1046,7 @@
 		list_add(&ipm->list, &card->ipm_list);
 	}
 	spin_unlock(&card->ipm_lock);
-	read_unlock(&in4_dev->lock);
+	read_unlock(&in4_dev->mc_list_lock);
 	in_dev_put(in4_dev);
 	lcs_fix_multicast_list(card);
 	return 0;
===== drivers/s390/net/qeth_main.c 1.11 vs edited =====
--- 1.11/drivers/s390/net/qeth_main.c	2004-08-08 04:05:36 +10:00
+++ edited/drivers/s390/net/qeth_main.c	2004-08-14 16:27:11 +10:00
@@ -73,6 +73,7 @@
 #include <linux/reboot.h>
 #include <asm/qeth.h>
 #include <linux/mii.h>
+#include <linux/rcupdate.h>
 
 #include "qeth.h"
 #include "qeth_mpc.h"
@@ -4733,9 +4734,10 @@
 	QETH_DBF_TEXT(trace, 4, "frvaddr4");
 	if (!card->vlangrp)
 		return;
-	in_dev = in_dev_get(card->vlangrp->vlan_devices[vid]);
+	rcu_read_lock();
+	in_dev = __in_dev_get(card->vlangrp->vlan_devices[vid]);
 	if (!in_dev)
-		return;
+		goto out;
 	for (ifa = in_dev->ifa_list; ifa; ifa = ifa->ifa_next){
 		addr = qeth_get_addr_buffer(QETH_PROT_IPV4);
 		if (addr){
@@ -4746,7 +4748,8 @@
 				kfree(addr);
 		}
 	}
-	in_dev_put(in_dev);
+out:
+	rcu_read_unlock();
 }
 
 static void
@@ -4918,9 +4921,9 @@
 		in_dev = in_dev_get(vg->vlan_devices[i]);
 		if (!in_dev)
 			continue;
-		read_lock(&in_dev->lock);
+		read_lock(&in_dev->mc_list_lock);
 		qeth_add_mc(card,in_dev);
-		read_unlock(&in_dev->lock);
+		read_unlock(&in_dev->mc_list_lock);
 		in_dev_put(in_dev);
 	}
 #endif
@@ -4935,10 +4938,10 @@
 	in4_dev = in_dev_get(card->dev);
 	if (in4_dev == NULL)
 		return;
-	read_lock(&in4_dev->lock);
+	read_lock(&in4_dev->mc_list_lock);
 	qeth_add_mc(card, in4_dev);
 	qeth_add_vlan_mc(card);
-	read_unlock(&in4_dev->lock);
+	read_unlock(&in4_dev->mc_list_lock);
 	in_dev_put(in4_dev);
 }
 

--EuxKj2iCbKjpUGkD--
