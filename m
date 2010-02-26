From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] Re: [net-next-2.6 PATCH] ethtool: Add n-tuple string length to drvinfo and return it
Date: Fri, 26 Feb 2010 08:44:46 -0500
Message-ID: <20100226134446.GA19194@havoc.gtf.org>
References: <20100226115355.20213.59254.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:56830 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964795Ab0BZOGW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2010 09:06:22 -0500
Content-Disposition: inline
In-Reply-To: <20100226115355.20213.59254.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 26, 2010 at 03:54:20AM -0800, Jeff Kirsher wrote:
> From: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> The drvinfo struct should include the number of strings that
> get_rx_ntuple will return.  It will be variable if an underlying
> driver implements its own get_rx_ntuple routine, so userspace
> needs to know how much data is coming.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

As noted in the other email, your patch breaks ABI.  The proper path is
to decrease the size of reserved struct member, and NOT shift the offset
of other members.



However, perhaps consider the following patch for returning n-tuple
count, for four reasons:

1) space in ethtool_drvinfo is limited

2) the patch below permits trivial string set addition, without
   ABI changes beyond adding a new ETH_SS_xxx constant.

3) the patch below permits direct access to ops->get_sset_count(),
   rather than implicit access via ethtool_drvinfo

4) ethtool_drvinfo interface does not permit indication of 
   ops->get_sset_count() failure, versus returning zero value.  The
   patch below does so, via output sset_mask.

WARNING: this patch is compile-tested only.

NOTE: I added a cosmetic fix to ETHTOOL_[GS]RXNTUPLE constants, making
their indentation consistent with the rest of the list of constants.

Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index f7992a2..04ecf18 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -254,6 +254,17 @@ struct ethtool_gstrings {
 	__u8	data[0];
 };
 
+struct ethtool_sset_info {
+	__u32	cmd;		/* ETHTOOL_GSSET_INFO */
+	__u32	reserved;
+	__u64	sset_mask;	/* input: each bit selects an sset to query */
+				/* output: each bit a returned sset */
+	__u32	data[0];	/* ETH_SS_xxx count, in order, based on bits
+				   in sset_mask.  One bit implies one
+				   __u32, two bits implies two
+				   __u32's, etc. */
+};
+
 enum ethtool_test_flags {
 	ETH_TEST_FL_OFFLINE	= (1 << 0),	/* online / offline */
 	ETH_TEST_FL_FAILED	= (1 << 1),	/* test passed / failed */
@@ -607,9 +618,9 @@ struct ethtool_ops {
 #define	ETHTOOL_SRXCLSRLINS	0x00000032 /* Insert RX classification rule */
 #define	ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
 #define	ETHTOOL_RESET		0x00000034 /* Reset hardware */
-
-#define ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
-#define ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
+#define	ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
+#define	ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
+#define	ETHTOOL_GSSET_INFO	0x00000037 /* Get string set info */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 1c94f48..c019f92 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -241,6 +241,69 @@ static noinline int ethtool_get_drvinfo(struct net_device *dev, void __user *use
 /*
  * noinline attribute so that gcc doesnt use too much stack in dev_ethtool()
  */
+static noinline int ethtool_get_sset_info(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_sset_info info;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+	u64 sset_mask;
+	int i, idx = 0, n_bits = 0, ret, rc;
+	u32 *info_buf = NULL;
+
+	if (!ops->get_sset_count)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&info, useraddr, sizeof(info)))
+		return -EFAULT;
+
+	/* store copy of mask, because we zero struct later on */
+	sset_mask = info.sset_mask;
+	if (!sset_mask)
+		return 0;
+
+	/* calculate size of return buffer */
+	for (i = 0; i < 64; i++)
+		if (sset_mask & (1ULL << i))
+			n_bits++;
+
+	memset(&info, 0, sizeof(info));
+	info.cmd = ETHTOOL_GSSET_INFO;
+
+	info_buf = kzalloc(n_bits * sizeof(u32), GFP_USER);
+	if (!info_buf)
+		return -ENOMEM;
+
+	/* fill return buffer based on input bitmask and successful 
+	 * get_sset_count return
+	 */
+	for (i = 0; i < 64; i++) {
+		if (!(sset_mask & (1ULL << i)))
+			continue;
+
+		rc = ops->get_sset_count(dev, i);
+		if (rc >= 0) {
+			info.sset_mask |= (1ULL << i);
+			info_buf[idx++] = rc;
+		}
+	}
+
+	ret = -EFAULT;
+	if (copy_to_user(useraddr, &info, sizeof(info)))
+		goto out;
+
+	useraddr += offsetof(struct ethtool_sset_info, data);
+	if (copy_to_user(useraddr, info_buf, idx * sizeof(u32)))
+		goto out;
+
+	ret = 0;
+
+out:
+	kfree(info_buf);
+	return ret;
+}
+
+/*
+ * noinline attribute so that gcc doesnt use too much stack in dev_ethtool()
+ */
 static noinline int ethtool_set_rxnfc(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_rxnfc cmd;
@@ -1472,6 +1535,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GRXNTUPLE:
 		rc = ethtool_get_rx_ntuple(dev, useraddr);
 		break;
+	case ETHTOOL_GSSET_INFO:
+		rc = ethtool_get_sset_info(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
