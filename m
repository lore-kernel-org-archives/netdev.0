From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] select appropriate skb size in tcp_sendmsg when TSO is used
Date: Wed, 27 Oct 2004 09:51:26 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026235126.GA4733@gondor.apana.org.au>
References: <OF96546AB5.ACE12043-ONC1256F33.0027BC6B-C1256F33.002D4A6E@de.ibm.com> <E1CKE5P-0005SP-00@gondolin.me.apana.org.au> <20041020163510.6d13e9c7.davem@davemloft.net> <20041026111912.GA18095@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="pf9I7BMVVzbSWLtt"
Cc: thomas.spatzier@de.ibm.com, netdev@oss.sgi.com,
        Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041026111912.GA18095@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Oct 26, 2004 at 09:19:12PM +1000, herbert wrote:
> On Wed, Oct 20, 2004 at 04:35:10PM -0700, David S. Miller wrote:
> > 
> > BTW, we allow mucking of all of these SG, TSO, CSUM settings
> > via ethtool yet the "X needs Y" rules are not enforced.  I
> > can't think of an easy way to do this without touching a lot
> > of drivers.  Perhaps something like:
> 
> Well since they're all being invoked through ethtool, you can
> just enforce the policy there.  So let's take set_tx_csum

Alright, here is a patch to do exactly that.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/core/ethtool.c 1.15 vs edited =====
--- 1.15/net/core/ethtool.c	2004-06-14 05:59:15 +10:00
+++ edited/net/core/ethtool.c	2004-10-27 09:39:09 +10:00
@@ -452,9 +452,23 @@
 	return 0;
 }
 
+static int __ethtool_set_sg(struct net_device *dev, u32 data)
+{
+	int err;
+
+	if (!data && dev->ethtool_ops->set_tso) {
+		err = dev->ethtool_ops->set_tso(dev, 0);
+		if (err)
+			return err;
+	}
+
+	return dev->ethtool_ops->set_sg(dev, data);
+}
+
 static int ethtool_set_tx_csum(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_value edata;
+	int err;
 
 	if (!dev->ethtool_ops->set_tx_csum)
 		return -EOPNOTSUPP;
@@ -462,6 +476,12 @@
 	if (copy_from_user(&edata, useraddr, sizeof(edata)))
 		return -EFAULT;
 
+	if (!edata.data && dev->ethtool_ops->set_sg) {
+		err = __ethtool_set_sg(dev, 0);
+		if (err)
+			return err;
+	}
+
 	return dev->ethtool_ops->set_tx_csum(dev, edata.data);
 }
 
@@ -489,7 +509,13 @@
 	if (copy_from_user(&edata, useraddr, sizeof(edata)))
 		return -EFAULT;
 
-	return dev->ethtool_ops->set_sg(dev, edata.data);
+	if (edata.data && 
+	    !(dev->features & (NETIF_F_IP_CSUM |
+			       NETIF_F_NO_CSUM |
+			       NETIF_F_HW_CSUM)))
+		return -EINVAL;
+
+	return __ethtool_set_sg(dev, edata.data);
 }
 
 static int ethtool_get_tso(struct net_device *dev, char __user *useraddr)
@@ -515,6 +541,9 @@
 
 	if (copy_from_user(&edata, useraddr, sizeof(edata)))
 		return -EFAULT;
+
+	if (edata.data && !(dev->features & NETIF_F_SG))
+		return -EINVAL;
 
 	return dev->ethtool_ops->set_tso(dev, edata.data);
 }

--pf9I7BMVVzbSWLtt--
