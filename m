From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [RFC net-next 1/1] ethtool: Add support for set eeprom metadata.
Date: Thu, 26 May 2016 09:33:35 -0400
Message-ID: <1464269615-4937-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:15035 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754069AbcEZOQs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2016 10:16:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently ethtool implementation does not have a way to pass the metada=
ta
for eeprom related operations. Some adapters have a complicated
non-volatile memory implementation that requires additional information=
 =E2=80=93
there are drivers [bnx2x and bnxt] that use the =E2=80=98magic=E2=80=99=
 field in the
{G,S}EEPROM  for that purpose, although that=E2=80=99s not its intended=
 usage.

This patch adds a provision to pass the eeprom metadata for
%ETHTOOL_SEEPROM/%ETHTOOL_GEEPROM implementations. User provided metada=
ta
will be cached by the driver and assigns a magic value which the
application need to use for the subsequent {G,S}EEPROM command.
---
 include/linux/ethtool.h      |  1 +
 include/uapi/linux/ethtool.h | 29 +++++++++++++++++++++++++++++
 net/core/ethtool.c           | 25 +++++++++++++++++++++++++
 3 files changed, 55 insertions(+)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 9ded8c6..6f98c2a 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -316,6 +316,7 @@ struct ethtool_ops {
 			      struct ethtool_eeprom *, u8 *);
 	int	(*set_eeprom)(struct net_device *,
 			      struct ethtool_eeprom *, u8 *);
+	int	(*set_meeprom)(struct net_device *, struct ethtool_meeprom *);
 	int	(*get_coalesce)(struct net_device *, struct ethtool_coalesce *);
 	int	(*set_coalesce)(struct net_device *, struct ethtool_coalesce *);
 	void	(*get_ringparam)(struct net_device *,
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.=
h
index 9222db8..f0f28a8 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -279,6 +279,13 @@ struct ethtool_regs {
  *	The value passed in to %ETHTOOL_SEEPROM must match the value
  *	returned by %ETHTOOL_GEEPROM for the same device.  This is
  *	unused when @cmd is %ETHTOOL_GMODULEEEPROM.
+ *	Depending on @cmd, the value passed must match:
+ *	- For %ETHTOOL_GMODULEEEPROM, no requirements.
+ *	- For %ETHTOOL_GEEPROM, must match the value returned by the
+ *		previous %ETHTOOL_SEEPROMMETA in case device supports it.
+ *	- For %ETHTOOL_SEEPROM, must match value returned by the previous
+ *		%ETHTOOL_SEEPROMMETA in case device supports it, or by
+ *		previous %ETHTOOL_GEEPROM otherwise.
  * @offset: Offset within the EEPROM to begin reading/writing, in byte=
s
  * @len: On entry, number of bytes to read/write.  On successful
  *	return, number of bytes actually read/written.  In case of
@@ -298,6 +305,27 @@ struct ethtool_eeprom {
 };
=20
 /**
+ * struct ethtool_meeprom - Set EEPROM metadata
+ * @cmd: Command number =3D %ETHTOOL_SEEPROMMETA
+ * @metadata: eeprom metadata corresponds to the successive %ETHTOOL_S=
EEPROM or
+ * 	%ETHTOOL_GEEPROM command.
+ * @magic: A 'magic cookie' value to be used by the successive %ETHTOO=
L_SEEPROM/
+ * 	%ETHTOOL_GEEPROM command. User provided eeprom metadata will be
+ *	assoicated with a magic value. The value passed in to %ETHTOOL_SEEP=
ROM
+ * 	or %ETHTOOL_GEEPROM must match with the value returned by
+ * 	%ETHTOOL_SEEPROMMETA for the same device.
+ *	Essentialy user will send eeprom meta data, followed by %ETHTOOL_SE=
EPROM
+ *	or %ETHTOOL_GEEPROM command. It's driver's responsibility to map th=
e
+ *	metadata to the subsequent eeprom command, using the magic to valid=
ate
+ *	correctness.
+ */
+struct ethtool_meeprom {
+	__u32 cmd;
+	__u32 metadata;
+	__u32 magic;
+};
+
+/**
  * struct ethtool_eee - Energy Efficient Ethernet information
  * @cmd: ETHTOOL_{G,S}EEE
  * @supported: Mask of %SUPPORTED_* flags for the speed/duplex combina=
tions
@@ -1315,6 +1343,7 @@ struct ethtool_per_queue_op {
 #define ETHTOOL_GLINKSETTINGS	0x0000004c /* Get ethtool_link_settings =
*/
 #define ETHTOOL_SLINKSETTINGS	0x0000004d /* Set ethtool_link_settings =
*/
=20
+#define ETHTOOL_SEEPROMMETA	0x0000004e /* Set eeprom metadata */
=20
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index bdb4013..c5efadd 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -2421,6 +2421,28 @@ static int ethtool_set_per_queue(struct net_devi=
ce *dev, void __user *useraddr)
 	};
 }
=20
+static int ethtool_set_meeprom(struct net_device *dev, void __user *us=
eraddr)
+{
+	const struct ethtool_ops *ops =3D dev->ethtool_ops;
+	struct ethtool_meeprom meeprom;
+	int ret;
+
+	if (!ops->set_meeprom)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&meeprom, useraddr, sizeof(meeprom)))
+		return -EFAULT;
+
+	ret =3D ops->set_meeprom(dev, &meeprom);
+	if (ret)
+		return ret;
+
+	if (copy_to_user(useraddr, &meeprom, sizeof(meeprom)))
+		return -EFAULT;
+
+	return 0;
+}
+
 /* The main entry point in this file.  Called from net/core/dev_ioctl.=
c */
=20
 int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -2683,6 +2705,9 @@ int dev_ethtool(struct net *net, struct ifreq *if=
r)
 	case ETHTOOL_SLINKSETTINGS:
 		rc =3D ethtool_set_link_ksettings(dev, useraddr);
 		break;
+	case ETHTOOL_SEEPROMMETA:
+		rc =3D ethtool_set_meeprom(dev, useraddr);
+		break;
 	default:
 		rc =3D -EOPNOTSUPP;
 	}
--=20
1.8.3.1
