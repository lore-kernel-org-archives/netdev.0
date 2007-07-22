From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [ofa-general] [PATCH 04/12 -Rev2] Ethtool changes
Date: Sun, 22 Jul 2007 14:35:35 +0530
Message-ID: <20070722090534.7787.8673.sendpatchset@K50wks273871wss.in.ibm.com>
References: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	kaber@trash.net, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, sri@us.ibm.com, hadi@cyberus.ca, netdev@vger.kernel.org
To: davem@davemloft.net, rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

diff -ruNp org/include/linux/ethtool.h rev2/include/linux/ethtool.h
--- org/include/linux/ethtool.h	2007-07-21 13:39:50.000000000 +0530
+++ rev2/include/linux/ethtool.h	2007-07-21 13:40:57.000000000 +0530
@@ -414,6 +414,8 @@ struct ethtool_ops {
 #define ETHTOOL_SUFO		0x00000022 /* Set UFO enable (ethtool_value) */
 #define ETHTOOL_GGSO		0x00000023 /* Get GSO enable (ethtool_value) */
 #define ETHTOOL_SGSO		0x00000024 /* Set GSO enable (ethtool_value) */
+#define ETHTOOL_GBTX		0x00000025 /* Get Batching (ethtool_value) */
+#define ETHTOOL_SBTX		0x00000026 /* Set Batching (ethtool_value) */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff -ruNp org/net/core/ethtool.c rev2/net/core/ethtool.c
--- org/net/core/ethtool.c	2007-07-21 13:37:17.000000000 +0530
+++ rev2/net/core/ethtool.c	2007-07-21 22:55:38.000000000 +0530
@@ -648,6 +648,26 @@ static int ethtool_set_gso(struct net_de
 	return 0;
 }
 
+static int ethtool_get_batch(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GBTX };
+
+	edata.data = BATCHING_ON(dev);
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		 return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_batch(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+
+	return dev_change_tx_batching(dev, edata.data);
+}
+
 static int ethtool_self_test(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_test test;
@@ -959,6 +979,12 @@ int dev_ethtool(struct ifreq *ifr)
 	case ETHTOOL_SGSO:
 		rc = ethtool_set_gso(dev, useraddr);
 		break;
+	case ETHTOOL_GBTX:
+		rc = ethtool_get_batch(dev, useraddr);
+		break;
+	case ETHTOOL_SBTX:
+		rc = ethtool_set_batch(dev, useraddr);
+		break;
 	default:
 		rc =  -EOPNOTSUPP;
 	}
