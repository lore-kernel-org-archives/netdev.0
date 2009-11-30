From: sjur.brandeland@stericsson.com
Subject: [RFC PATCH v3  5/8] CAIF Protocol Stack
Date: Mon, 30 Nov 2009 16:00:49 +0100
Message-ID: <1259593252-2493-6-git-send-email-sjur.brandeland@stericsson.com>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-2-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-3-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-4-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-5-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: randy.dunlap@oracle.com, kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, stefano.babic@babic.homelinux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:55205 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702AbZK3QBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 11:01:52 -0500
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KTX0011ZGEVKF20@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Mon, 30 Nov 2009 16:01:43 +0100 (CET)
Received: from localhost.localdomain ([84.49.68.131])
 by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KTX00IAMGDW9QV1@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Mon, 30 Nov 2009 16:01:43 +0100 (CET)
In-reply-to: <1259593252-2493-5-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Braendeland <sjur.brandeland@stericsson.com>

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/caif/Kconfig            |   51 ++
 net/caif/Makefile           |   51 ++
 net/caif/caif_chnlif.c      |  205 ++++++
 net/caif/caif_config_util.c |  163 +++++
 net/caif/caif_dev.c         |  520 ++++++++++++++
 net/caif/caif_socket.c      | 1560 +++++++++++++++++++++++++++++++++++=
++++++++
 net/caif/chnl_net.c         |  655 ++++++++++++++++++
 7 files changed, 3205 insertions(+), 0 deletions(-)
 create mode 100644 net/caif/Kconfig
 create mode 100644 net/caif/Makefile
 create mode 100644 net/caif/caif_chnlif.c
 create mode 100644 net/caif/caif_config_util.c
 create mode 100644 net/caif/caif_dev.c
 create mode 100644 net/caif/caif_socket.c
 create mode 100644 net/caif/chnl_net.c

diff --git a/net/caif/Kconfig b/net/caif/Kconfig
new file mode 100644
index 0000000..9349123
--- /dev/null
+++ b/net/caif/Kconfig
@@ -0,0 +1,51 @@
+#
+# CAIF net configurations
+#
+
+#menu "CAIF Support"
+comment "CAIF Support"
+
+menuconfig CAIF
+	tristate "Enable CAIF support"
+	default n
+	---help---
+	Say Y here if you need to use a phone modem that uses CAIF as transpo=
rt.
+	You will also need to say yes to any CAIF physical devices that your =
platform
+	supports.
+	This can be either built-in or a loadable module; if you select to bu=
ild it as module
+	then the rest of CAIF also needs to built as modules.
+	See Documentation/CAIF for a further explanation on how to use and co=
nfigure.
+
+if CAIF
+
+config CAIF_NETDEV
+	tristate "CAIF Network device"
+	default CAIF
+	---help---
+	Say Y if you will be using the CAIF based network device.
+	This can be either built-in or a loadable module.
+	If you select to build it as a built-in then the main CAIF device mus=
t also be a built-in.
+	If unsure say Y.
+
+config CAIF_SOCK
+	tristate "CAIF Sockets"
+	default CAIF
+	---help---
+	Say Y if you will be using the CAIF Sockets.
+	This can be either built-in or a loadable module.
+	If you select to build it as a built-in then the main CAIF device mis=
t also be a built-in.
+	If unsure say Y.
+
+config  CAIF_DEBUG
+	bool "Enable Debug"
+	default n
+	--- help ---
+	Enable the inclusion of debug code in the CAIF stack.
+	Be aware that doing this will impact performance.
+	If unsure say N.
+
+
+# Include physical drivers
+source "drivers/net/caif/Kconfig"
+endif
+#endmenu
diff --git a/net/caif/Makefile b/net/caif/Makefile
new file mode 100644
index 0000000..2b87906
--- /dev/null
+++ b/net/caif/Makefile
@@ -0,0 +1,51 @@
+ifeq ($(CONFIG_CAIF_USE_PLAIN),1)
+CFPKT:=3Dplain
+else
+CFPKT:=3Dskbuff
+CAIF_FLAGS+=3D-DCAIF_USE_SKB
+endif
+
+ifeq ($(CONFIG_CAIF_DEBUG),1)
+CAIF_FLAGS+=3D-DCAIF_DEBUG_ON
+endif
+ccflags-y :=3D $(CAIF_FLAGS)
+
+caif-objs :=3D caif_dev.o caif_chnlif.o \
+	generic/cfcnfg.o generic/cfmuxl.o generic/cfctrl.o \
+	generic/cffrml.o generic/cfveil.o generic/cflist.o  \
+	generic/fcs.o    generic/cfserl.o generic/cfdgml.o \
+	generic/cfspil.o generic/cfrfml.o generic/cfvidl.o \
+	generic/cfmsll.o generic/cfusbl.o generic/cfutill.o  \
+	generic/cfloopcfg.o  generic/cflooplayer.o generic/cfsrvl.o \
+	generic/cfshml.o generic/cfpkt_$(CFPKT).o caif_config_util.o
+
+clean-dirs:=3D .tmp_versions
+
+clean-files:=3D Module.symvers modules.order *.cmd *~ \
+	generic/loopback/Module.symvers \
+	generic/loopback/modules.order \
+	generic/loopback/*.cmd \
+	generic/loopback/*.o \
+	generic/loopback/*~ \
+	generic/Module.symvers \
+	generic/modules.order \
+	generic/*.cmd \
+	generic/*.o \
+	generic/*~
+
+# Main CAIF module
+obj-$(CONFIG_CAIF) +=3D caif.o
+
+# CAIF net device
+obj-$(CONFIG_CAIF_NETDEV) +=3D chnl_net.o
+
+obj-$(CONFIG_CAIF_SOCK) +=3D caif_socket.o
+
+export-objs :=3D caif.o
+
+clean:
+	${MAKE} -C generic clean
+	rm generic/modules.order  generic/Module.symvers \
+	generic/*.cmd generic/*~ \
+	generic/modules.order generic/Module.symvers \
+	generic/*.o generic/loopback/*.o
diff --git a/net/caif/caif_chnlif.c b/net/caif/caif_chnlif.c
new file mode 100644
index 0000000..9c8a656
--- /dev/null
+++ b/net/caif/caif_chnlif.c
@@ -0,0 +1,205 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Daniel Martensson / Daniel.Martensson@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/skbuff.h>
+#include <net/caif/caif_kernel.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/caif_config_util.h>
+#include <net/caif/caif_log.h>
+#include <net/caif/generic/cfpkt.h>
+#include <net/caif/generic/cfcnfg.h>
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/caif_chr.h>
+struct caif_kernelif {
+	struct layer layer;
+	struct caif_device *dev;
+	struct cfctrl_link_param param;
+};
+
+
+/**
+ * func caif_create_skb - Creates a CAIF SKB buffer
+ * @data:		data to add to buffer
+ * @data_length:	length of data
+ */
+struct sk_buff *caif_create_skb(unsigned char *data, unsigned int data=
_length)
+{
+	/* NOTE: Make room for CAIF headers when using SKB inside CAIF. */
+	struct sk_buff *skb =3D
+	    alloc_skb(data_length + CAIF_SKB_HEAD_RESERVE +
+		      CAIF_SKB_TAIL_RESERVE, GFP_ATOMIC);
+	if (skb =3D=3D NULL)
+		return NULL;
+	skb_reserve(skb, CAIF_SKB_HEAD_RESERVE);
+
+	memcpy(skb_put(skb, data_length), data, data_length);
+	return skb;
+}
+EXPORT_SYMBOL(caif_create_skb);
+
+int caif_extract_and_destroy_skb(struct sk_buff *skb, unsigned char *d=
ata,
+			     unsigned int max_length)
+{
+	unsigned int len;
+	len =3D skb->len;
+	/* What should actually be done here ?
+	 * skb_linearize only fails on an out of memory condition
+	 * if we fail here we are NOT freeing the skb
+	 */
+	if (!skb_linearize(skb) || skb->len > max_length)
+		return CFGLU_EOVERFLOW;
+	memcpy(data, skb->data, skb->len);
+	kfree_skb(skb);
+	return len;
+}
+EXPORT_SYMBOL(caif_extract_and_destroy_skb);
+
+/* NOTE: transmit takes ownership of the SKB.
+ *       I.e. transmit only fails on severe errors.
+ *       flow_off is not checked on transmit; this is client's responc=
ibility.
+ */
+int caif_transmit(struct caif_device *dev, struct sk_buff *skb)
+{
+	struct caif_kernelif *chnlif =3D
+	    (struct caif_kernelif *) dev->_caif_handle;
+	struct cfpkt *pkt;
+#ifdef CAIF_USE_SKB
+	pkt =3D cfpkt_fromnative(CAIF_DIR_OUT, (void *) skb);
+#else
+	pkt =3D cfpkt_create(skb->len);
+	cfpkt_add_body(pkt, skb->data, skb->len);
+	kfree_skb(skb);
+#endif
+	CAIFLOG_TRACE2("Transmit (%p)", chnlif->layer.dn);
+	return chnlif->layer.dn->transmit(chnlif->layer.dn, NULL, pkt);
+}
+EXPORT_SYMBOL(caif_transmit);
+
+int caif_flow_control(struct caif_device *dev, enum caif_flowctrl flow=
)
+{
+	enum caif_modemcmd modemcmd;
+	struct caif_kernelif *chnlif =3D
+	    (struct caif_kernelif *) dev->_caif_handle;
+	switch (flow) {
+	case CAIF_FLOWCTRL_ON:
+		modemcmd =3D CAIF_MODEMCMD_FLOW_ON_REQ;
+		break;
+	case CAIF_FLOWCTRL_OFF:
+		modemcmd =3D CAIF_MODEMCMD_FLOW_OFF_REQ;
+		break;
+	default:
+		return -EINVAL;
+	}
+	return chnlif->layer.dn->modemcmd(chnlif->layer.dn, modemcmd);
+}
+EXPORT_SYMBOL(caif_flow_control);
+
+static int chnlif_receive(struct layer *layr, struct cfpkt *cfpkt)
+{
+	/* FIXME: Use container of */
+	struct caif_kernelif *chnl =3D (struct caif_kernelif *) layr;
+
+	struct sk_buff *skb;
+#ifndef CAIF_USE_SKB
+	unsigned int pktlen =3D cfpkt_getlen(cfpkt);
+	unsigned int actual_len;
+	skb =3D alloc_skb(pktlen, GFP_ATOMIC);
+	if (skb =3D=3D NULL)
+		return CFGLU_ENOMEM;
+
+	/* Extract data from the caif packet and copy it to the skb. */
+	cfpkt_extract(cfpkt, skb_put(skb, pktlen), pktlen, &actual_len);
+	caif_assert(pktlen =3D=3D actual_len);
+	cfpkt_destroy(cfpkt);
+#else
+	skb =3D (struct sk_buff *) cfpkt_tonative(cfpkt);
+#endif
+	chnl->dev->receive_cb(chnl->dev, skb);
+	return CFGLU_EOK;
+}
+
+static void chnlif_flowctrl(struct layer *layr, enum caif_ctrlcmd ctrl=
,
+			int phyid)
+{
+	struct caif_kernelif *chnl =3D (struct caif_kernelif *) layr;
+	enum caif_control ctl;
+
+	CAIFLOG_TRACE("Flow Control received %d\n", ctrl);
+
+	switch (ctrl) {
+	case CAIF_CTRLCMD_FLOW_OFF_IND:
+		ctl =3D CAIF_CONTROL_FLOW_OFF;
+		break;
+	case CAIF_CTRLCMD_FLOW_ON_IND:
+		ctl =3D CAIF_CONTROL_FLOW_ON;
+		break;
+	case CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND:
+		ctl =3D CAIF_CONTROL_REMOTE_SHUTDOWN;
+		break;
+	case CAIF_CTRLCMD_DEINIT_RSP:
+		ctl =3D CAIF_CONTROL_DEV_DEINIT;
+		chnl->dev->_caif_handle =3D NULL;
+		chnl->dev->control_cb(chnl->dev, ctl);
+		memset(chnl, 0, sizeof(chnl));
+		cfglu_free(chnl);
+		return;
+
+	case CAIF_CTRLCMD_INIT_RSP:
+		ctl =3D CAIF_CONTROL_DEV_INIT;
+		break;
+	case CAIF_CTRLCMD_INIT_FAIL_RSP:
+		ctl =3D CAIF_CONTROL_DEV_INIT_FAILED;
+		break;
+	default:
+		return;
+	}
+	chnl->dev->control_cb(chnl->dev, ctl);
+}
+
+int caif_add_device(struct caif_device *dev)
+{
+	int ret;
+	struct caif_kernelif *chnl =3D cfglu_alloc(sizeof(struct caif_kerneli=
f));
+	chnl->dev =3D dev;
+	chnl->layer.ctrlcmd =3D chnlif_flowctrl;
+	chnl->layer.receive =3D chnlif_receive;
+	ret =3D
+	    channel_config_2_link_param(get_caif_conf(), &dev->caif_config,
+				&chnl->param);
+
+
+	if (ret < 0) {
+		CAIFLOG_WARN("Bad Channel Configuration\n");
+		ret =3D CFGLU_EBADPARAM;
+		goto error;
+	}
+
+	if (!cfcnfg_add_adaptation_layer(get_caif_conf(), &chnl->param,
+				&chnl->layer)) {
+		ret =3D CFGLU_ENOTCONN;
+		goto error;
+	}
+
+	dev->_caif_handle =3D chnl;
+
+	return CFGLU_EOK;
+error:
+	chnl->dev->_caif_handle =3D NULL;
+	memset(chnl, 0, sizeof(chnl));
+	cfglu_free(chnl);
+	return ret;
+}
+EXPORT_SYMBOL(caif_add_device);
+
+int caif_remove_device(struct caif_device *caif_dev)
+{
+
+	struct caif_kernelif *chnl =3D
+	    container_of(caif_dev->_caif_handle, struct caif_kernelif, layer)=
;
+	bool ok =3D cfcnfg_del_adapt_layer(get_caif_conf(), &chnl->layer);
+	return ok ? CFGLU_EOK : CFGLU_EIO;
+}
+EXPORT_SYMBOL(caif_remove_device);
diff --git a/net/caif/caif_config_util.c b/net/caif/caif_config_util.c
new file mode 100644
index 0000000..8311a7f
--- /dev/null
+++ b/net/caif/caif_config_util.c
@@ -0,0 +1,163 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Daniel Martensson / Daniel.Martensson@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <net/caif/generic/cfglue.h>
+#include <net/caif/generic/cfctrl.h>
+#include <net/caif/generic/cfcnfg.h>
+#include <net/caif/caif_config_util.h>
+#include <linux/caif/caif_config.h>
+#include <linux/caif/caif_ioctl.h>
+#include <net/caif/caif_actions.h>
+
+int
+channel_config_2_link_param(struct cfcnfg *cnfg,
+		struct caif_channel_config *s, struct cfctrl_link_param *l)
+{
+
+	enum cfcnfg_phy_preference pref;
+
+	memset(l, 0, sizeof(*l));
+
+	l->priority =3D s->priority;
+
+	if (s->phy_name[0] !=3D '\0') {
+		l->phyid =3D cfcnfg_get_named(cnfg, s->phy_name);
+		CFLOG_TRACE(("PHYNAME: '%s' -> id:%d\n", s->phy_name,
+			     l->phyid));
+
+	} else {
+		switch (s->phy_pref) {
+		case CAIF_PHYPREF_UNSPECIFIED:
+			pref =3D CFPHYPREF_UNSPECIFIED;
+			break;
+		case CAIF_PHYPREF_LOW_LAT:
+			pref =3D CFPHYPREF_LOW_LAT;
+			break;
+		case CAIF_PHYPREF_HIGH_BW:
+			pref =3D CFPHYPREF_HIGH_BW;
+			break;
+		case _CAIF_PHYPREF_LOOP:
+			pref =3D CFPHYPREF_LOOP;
+			break;
+		default:
+			CFLOG_TRACE(("PHYPREF: "
+				     "No Preferered Device Specified '%d'\n",
+				     s->phy_pref));
+			return -CFGLU_ENODEV;
+		}
+		l->phyid =3D cfcnfg_get_phyid(cnfg, pref);
+		CFLOG_TRACE(("PHYPREF: '%d' -> id:%d\n", pref, l->phyid));
+	}
+
+	switch (s->type) {
+	case CAIF_CHTY_AT:
+		l->linktype =3D CFCTRL_SRV_VEI;
+		l->chtype =3D 0x02;
+		l->endpoint =3D 0x00;
+		CFLOG_TRACE(("CHTY: AT\n"));
+		break;
+
+	case CAIF_CHTY_AT_CTRL:
+		CFLOG_TRACE(("CHTY: AT_CTRL\n"));
+		l->linktype =3D CFCTRL_SRV_VEI;
+		l->chtype =3D 0x00;
+		l->endpoint =3D 0x00;
+		break;
+
+	case CAIF_CHTY_AT_PAIRED:
+		CFLOG_TRACE(("CHTY: AT_PAIRED\n"));
+		l->linktype =3D CFCTRL_SRV_VEI;
+		l->chtype =3D 0x03;
+		l->endpoint =3D 0x00;
+		break;
+
+	case CAIF_CHTY_VIDEO:
+		CFLOG_TRACE(("CHTY: VIDEO\n"));
+		l->linktype =3D CFCTRL_SRV_VIDEO;
+		l->chtype =3D 0x00;
+		l->endpoint =3D 0x00;
+		l->u.video.connid =3D s->u.dgm.connection_id;
+		break;
+
+	case CAIF_CHTY_DATAGRAM:
+		CFLOG_TRACE(("CHTY: DATAGRAM\n"));
+		l->linktype =3D CFCTRL_SRV_DATAGRAM;
+		l->chtype =3D 0x00;
+		l->u.datagram.connid =3D s->u.dgm.connection_id;
+		break;
+
+	case CAIF_CHTY_DATAGRAM_LOOP:
+		CFLOG_TRACE(("CHTY: DATAGRAM\n"));
+		l->linktype =3D CFCTRL_SRV_DATAGRAM;
+		l->chtype =3D 0x03;
+		l->endpoint =3D 0x00;
+		l->u.datagram.connid =3D s->u.dgm.connection_id;
+		break;
+
+	case CAIF_CHTY_DEBUG:
+		CFLOG_TRACE(("CHTY: DEBUG\n"));
+		l->linktype =3D CFCTRL_SRV_DBG;
+		l->endpoint =3D 0x01;	/* ACC SIDE */
+		l->chtype =3D 0x00;	/* Single channel with interactive
+					 * debug and print-out mixed.
+					 */
+		break;
+
+	case CAIF_CHTY_DEBUG_INTERACT:
+		CFLOG_TRACE(("CHTY: IDEBUG\n"));
+		l->linktype =3D CFCTRL_SRV_DBG;
+		l->endpoint =3D 0x01;	/* ACC SIDE */
+		l->chtype =3D 0x02;	/* Interactive debug only */
+		break;
+
+	case CAIF_CHTY_DEBUG_TRACE:
+		CFLOG_TRACE(("CHTY: TRACE\n"));
+		l->linktype =3D CFCTRL_SRV_DBG;
+		l->endpoint =3D 0x01;	/* ACC SIDE */
+		l->chtype =3D 0x01;	/* Debug print-out only */
+		break;
+
+	case CAIF_CHTY_RFM:
+
+		CFLOG_TRACE(("CHTY: RFN\n"));
+		l->linktype =3D CFCTRL_SRV_RFM;
+		l->u.datagram.connid =3D s->u.rfm.connection_id;
+		strncpy(l->u.rfm.volume, s->u.rfm.volume,
+			sizeof(l->u.rfm.volume)-1);
+		l->u.rfm.volume[sizeof(l->u.rfm.volume)-1] =3D 0;
+		break;
+
+	case CAIF_CHTY_UTILITY:
+		CFLOG_TRACE(("CHTY: UTILTY\n"));
+		l->linktype =3D CFCTRL_SRV_UTIL;
+		l->endpoint =3D 0x00;
+		l->chtype =3D 0x00;
+		l->u.utility.fifosize_bufs =3D s->u.utility.fifosize_bufs;
+		l->u.utility.fifosize_kb =3D s->u.utility.fifosize_kb;
+		strncpy(l->u.utility.name, s->u.utility.name,
+			sizeof(l->u.utility.name)-1);
+		l->u.utility.name[sizeof(l->u.utility.name)-1] =3D 0;
+		l->u.utility.paramlen =3D s->u.utility.paramlen;
+		if (l->u.utility.paramlen > sizeof(l->u.utility.params))
+			l->u.utility.paramlen =3D sizeof(l->u.utility.params);
+		memcpy(l->u.utility.params, s->u.utility.params,
+		       l->u.utility.paramlen);
+		break;
+
+	case CAIF_CHTY_RAW:
+		l->linktype =3D s->u._raw.channeltype;
+		l->endpoint =3D s->u._raw.endpoint;
+		l->chtype =3D s->u._raw.subtype;
+		break;
+
+	default:
+		CFLOG_TRACE(("CAIF_CHTY: Specified bad channel type '%d'\n",
+			     s->type));
+		return -CFGLU_EINVAL;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(channel_config_2_link_param);
diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
new file mode 100644
index 0000000..3c05340
--- /dev/null
+++ b/net/caif/caif_dev.c
@@ -0,0 +1,520 @@
+/*
+ * CAIF Interface registration.
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ *
+ * Borrowed heavily from file: pn_dev.c. Thanks to
+ *  Remi Denis-Courmont <remi.denis-courmont@nokia.com>
+ *  and Sakari Ailus <sakari.ailus@nokia.com>
+ */
+
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/kernel.h>
+#include <linux/net.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <net/netns/generic.h>
+#include <net/netns/generic.h>
+#include <net/net_namespace.h>
+#include <net/caif/caif_dev.h>
+#include <net/caif/caif_chr.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfpkt.h>
+#include <net/caif/generic/cfcnfg.h>
+#include <net/caif/caif_log.h>
+#include <net/pkt_sched.h>
+#include <net/caif/caif_config_util.h>
+MODULE_LICENSE("GPL");
+
+#define TIMEOUT (HZ*1000)
+/* Used for local tracking of the caif net devices */
+struct caif_device_entry {
+	struct layer layer;
+	struct list_head list;
+	atomic_t in_use;
+	atomic_t state;
+	uint16 phyid;
+	struct net_device *netdev;
+	wait_queue_head_t event;
+};
+
+struct caif_device_entry_list {
+	struct list_head list;
+	spinlock_t lock;
+};
+
+struct caif_net {
+	struct caif_device_entry_list caifdevs;
+};
+
+struct cfcnfg *cfg;
+int caif_net_id;
+
+
+int caif_dbg_level =3D CAIFLOG_LEVEL_WARNING;
+EXPORT_SYMBOL(caif_dbg_level);
+
+
+struct class caif_class =3D {
+	.name =3D "caif",
+};
+
+static ssize_t dbg_lvl_show(struct class *class, char *buf)
+{
+	return sprintf(buf, "%d\n", caif_dbg_level);
+}
+
+static ssize_t dbg_lvl_store(struct class *class, const char *buf,
+			     size_t count)
+{
+	int val;
+
+
+	if ((sscanf(buf, "%d", &val) !=3D 1) || (val < CAIFLOG_MIN_LEVEL)
+			|| (val > CAIFLOG_MAX_LEVEL)) {
+		printk(KERN_WARNING "caif_dbg_level: Invalid value\n");
+		return -EINVAL;
+	}
+	caif_dbg_level =3D val;
+	return count;
+}
+
+CLASS_ATTR(dbg_lvl, 0644, dbg_lvl_show, dbg_lvl_store);
+
+struct caif_device_entry_list *caif_device_list(struct net *net)
+{
+	struct caif_net *caifn;
+	BUG_ON(!net);
+	caifn =3D net_generic(net, caif_net_id);
+	BUG_ON(!caifn);
+	return &caifn->caifdevs;
+}
+
+/* Allocate new CAIF device. */
+static struct caif_device_entry *caif_device_alloc(struct net_device *=
dev)
+{
+	struct caif_device_entry_list *caifdevs;
+	struct caif_device_entry *caifd;
+	caifdevs =3D caif_device_list(dev_net(dev));
+	BUG_ON(!caifdevs);
+	caifd =3D kzalloc(sizeof(*caifd), GFP_ATOMIC);
+	if (!caifd)
+		return NULL;
+	caifd->netdev =3D dev;
+	list_add(&caifd->list, &caifdevs->list);
+	init_waitqueue_head(&caifd->event);
+	return caifd;
+}
+
+static struct caif_device_entry *caif_get(struct net_device *dev)
+{
+	struct caif_device_entry_list *caifdevs =3D
+	    caif_device_list(dev_net(dev));
+	struct caif_device_entry *caifd;
+	BUG_ON(!caifdevs);
+	list_for_each_entry(caifd, &caifdevs->list, list) {
+		if (caifd->netdev =3D=3D dev)
+			return caifd;
+	}
+	return NULL;
+}
+
+static void caif_device_destroy(struct net_device *dev)
+{
+	struct caif_device_entry_list *caifdevs =3D
+	    caif_device_list(dev_net(dev));
+	struct caif_device_entry *caifd;
+	ASSERT_RTNL();
+	if (dev->type !=3D ARPHRD_CAIF)
+		return;
+
+	spin_lock_bh(&caifdevs->lock);
+	caifd =3D caif_get(dev);
+	if (caifd =3D=3D NULL) {
+		spin_unlock_bh(&caifdevs->lock);
+		return;
+	}
+
+	list_del(&caifd->list);
+	spin_unlock_bh(&caifdevs->lock);
+
+	kfree(caifd);
+	return;
+}
+
+struct net_device *caif_device_get(struct net *net)
+{
+	struct caif_device_entry_list *caifdevs =3D caif_device_list(net);
+	struct caif_device_entry *caifd;
+	struct net_device *dev =3D NULL;
+	spin_lock_bh(&caifdevs->lock);
+	list_for_each_entry(caifd, &caifdevs->list, list) {
+		dev =3D caifd->netdev;
+		BUG_ON(!dev);
+		if ((dev->reg_state =3D=3D NETREG_REGISTERED) &&
+		    ((caifd->netdev->flags & IFF_UP)) =3D=3D IFF_UP)
+			break;
+		dev =3D NULL;
+	}
+	spin_unlock_bh(&caifdevs->lock);
+	return dev;
+}
+
+static int transmit(struct layer *layer,
+		    struct transmt_info *info, struct cfpkt *pkt)
+{
+	struct caif_device_entry *caifd =3D
+	    container_of(layer, struct caif_device_entry, layer);
+	struct sk_buff *skb, *skb2;
+	int ret =3D -EINVAL;
+	struct transmt_info tmp;
+
+	skb =3D cfpkt_tonative(pkt);
+	memcpy(&tmp, skb->cb, sizeof(tmp));
+	memcpy(skb->cb, info, sizeof(*info));
+	skb->dev =3D caifd->netdev;
+
+	/*
+	 * Don't allow SKB to be destroyed upon error, but signal resend
+	 * notification to clients. We can't rely on the return value as
+	 * congestion (NET_XMIT_CN) sometimes drops the packet, sometimes don=
't.
+	 */
+	if (netif_queue_stopped(caifd->netdev))
+		return -EAGAIN;
+	skb2 =3D skb_get(skb);
+
+	ret =3D dev_queue_xmit(skb2);
+
+	if (!ret)
+		kfree_skb(skb);
+	else {
+		/* Restore the original skb private data */
+		memcpy(skb->cb, &tmp, sizeof(tmp));
+		return -EAGAIN;
+	}
+
+	return 0;
+}
+
+static int modemcmd(struct layer *layr, enum caif_modemcmd ctrl)
+{
+	struct caif_device_entry *caifd;
+	struct caif_dev_common *caifdev;
+	caifd =3D container_of(layr, struct caif_device_entry, layer);
+	caifdev =3D netdev_priv(caifd->netdev);
+	if (ctrl =3D=3D _CAIF_MODEMCMD_PHYIF_USEFULL) {
+		try_module_get(THIS_MODULE);
+		try_module_get(caifdev->net_dev_module);
+		atomic_set(&caifdev->in_use, 1);
+		atomic_set(&caifd->in_use, 1);
+		wake_up_interruptible(&caifd->event);
+
+	} else if (ctrl =3D=3D _CAIF_MODEMCMD_PHYIF_USELESS) {
+		module_put(THIS_MODULE);
+		module_put(caifdev->net_dev_module);
+		atomic_set(&caifdev->in_use, 0);
+		atomic_set(&caifd->in_use, 0);
+		wake_up_interruptible(&caifd->event);
+	}
+	return 0;
+}
+
+/*
+ * Stuff received packets to associated sockets.
+ * On error, returns non-zero and releases the skb.
+ */
+static int receive(struct sk_buff *skb, struct net_device *dev,
+		   struct packet_type *pkttype, struct net_device *orig_dev)
+{
+	struct net *net;
+	struct cfpkt *pkt;
+	struct caif_device_entry *caifd;
+	net =3D dev_net(dev);
+	pkt =3D cfpkt_fromnative(CAIF_DIR_IN, skb);
+	caifd =3D caif_get(dev);
+
+	if (!caifd || !caifd->layer.up || !caifd->layer.up->ctrlcmd)
+		return NET_RX_DROP;
+
+	if (caifd->layer.up->receive(caifd->layer.up, pkt))
+		return NET_RX_DROP;
+
+	return 0;
+}
+
+static struct packet_type caif_packet_type __read_mostly =3D {
+	.type =3D cpu_to_be16(ETH_P_CAIF),
+	.func =3D receive,
+};
+
+static void dev_flowctrl(struct net_device *dev, int on)
+{
+	struct caif_device_entry *caifd =3D caif_get(dev);
+	if (!caifd || !caifd->layer.up || !caifd->layer.up->ctrlcmd)
+		return;
+
+	caifd->layer.up->ctrlcmd(caifd->layer.up,
+				 on ?
+				 _CAIF_CTRLCMD_PHYIF_FLOW_ON_IND :
+				 _CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND,
+				 caifd->layer.id);
+}
+
+/* notify Caif of device events */
+static int caif_device_notify(struct notifier_block *me, unsigned long=
 what,
+			      void *arg)
+{
+	struct net_device *dev =3D arg;
+	struct caif_device_entry *caifd =3D NULL;
+	struct caif_dev_common *caifdev;
+	int res =3D -EINVAL;
+
+	if (dev->type !=3D ARPHRD_CAIF)
+		return 0;
+
+	switch (what) {
+	case NETDEV_REGISTER:
+		printk(KERN_INFO "CAIF register:%s\n", dev->name);
+		caifd =3D caif_device_alloc(dev);
+		if (caifd =3D=3D NULL)
+			break;
+		caifdev =3D netdev_priv(dev);
+		caifdev->flowctrl =3D dev_flowctrl;
+		atomic_set(&caifd->state, what);
+		res =3D dev_open(dev);
+		break;
+
+	case NETDEV_UP:
+		printk(KERN_INFO "CAIF up:%s\n", dev->name);
+		caifd =3D caif_get(dev);
+		if (caifd =3D=3D NULL)
+			break;
+		caifdev =3D netdev_priv(dev);
+		if (atomic_read(&caifd->state) =3D=3D NETDEV_UP) {
+			printk(KERN_INFO "CAIF dev:%s already up\n", dev->name);
+			break;
+		}
+		atomic_set(&caifd->state, what);
+		caifd->layer.transmit =3D transmit;
+		caifd->layer.modemcmd =3D modemcmd;
+
+		cfcnfg_add_phy_layer(get_caif_conf(),
+				     caifdev->phy_type,
+				     &caifd->layer,
+				     &caifd->phyid,
+				     caifdev->phy_pref);
+		strncpy(caifd->layer.name, dev->name,
+			sizeof(caifd->layer.name) - 1);
+		caifd->layer.name[sizeof(caifd->layer.name) - 1] =3D 0;
+		break;
+
+	case NETDEV_GOING_DOWN:
+		caifd =3D caif_get(dev);
+		if (caifd =3D=3D NULL)
+			break;
+		printk(KERN_INFO "CAIF Going down:%s\n", dev->name);
+		atomic_set(&caifd->state, what);
+		if (!caifd || !caifd->layer.up || !caifd->layer.up->ctrlcmd)
+			return -EINVAL;
+		caifd->layer.up->ctrlcmd(caifd->layer.up,
+					 _CAIF_CTRLCMD_PHYIF_DOWN_IND,
+					 caifd->layer.id);
+		res =3D wait_event_interruptible_timeout(caifd->event,
+					atomic_read(&caifd->in_use) =3D=3D 0,
+						       10);
+		break;
+
+	case NETDEV_DOWN:
+		caifd =3D caif_get(dev);
+		if (caifd =3D=3D NULL)
+			break;
+		printk(KERN_INFO "CAIF Down:%s\n", dev->name);
+		if (atomic_read(&caifd->in_use))
+			CAIFLOG_WARN("Unregistering an active CAIF device:"
+				     "%s\n", dev->name);
+		cfcnfg_del_phy_layer(get_caif_conf(), &caifd->layer);
+		atomic_set(&caifd->state, what);
+		break;
+
+	case NETDEV_UNREGISTER:
+		caifd =3D caif_get(dev);
+		printk(KERN_INFO "CAIF unregister:%s\n", dev->name);
+		atomic_set(&caifd->state, what);
+		caif_device_destroy(dev);
+		break;
+	}
+	return 0;
+}
+
+static struct notifier_block caif_device_notifier =3D {
+	.notifier_call =3D caif_device_notify,
+	.priority =3D 0,
+};
+
+/* Per-namespace Caif devices handling */
+static int caif_init_net(struct net *net)
+{
+	struct caif_net *caifn;
+	int ret;
+	caifn =3D kmalloc(sizeof(*caifn), GFP_KERNEL);
+	if (!caifn)
+		return -ENOMEM;
+	INIT_LIST_HEAD(&caifn->caifdevs.list);
+	spin_lock_init(&caifn->caifdevs.lock);
+	ret =3D net_assign_generic(net, caif_net_id, caifn);
+	if (ret)
+		kfree(caifn);
+
+	return 0;
+}
+
+static void caif_exit_net(struct net *net)
+{
+	struct caif_net *caifn =3D net_generic(net, caif_net_id);
+	struct net_device *dev;
+	int res;
+	rtnl_lock();
+	for_each_netdev(net, dev) {
+		if (dev->type !=3D ARPHRD_CAIF)
+			continue;
+		res =3D dev_close(dev);
+		caif_device_destroy(dev);
+	}
+	rtnl_unlock();
+	kfree(caifn);
+}
+
+struct cfcnfg *get_caif_conf(void)
+{
+	return cfg;
+}
+EXPORT_SYMBOL(get_caif_conf);
+
+int (*netdev_mgmt_func) (int action, union caif_action *param);
+EXPORT_SYMBOL(netdev_mgmt_func);
+
+static int (*caif_ioctl_func)(unsigned int cmd, unsigned long arg);
+
+void caif_register_ioctl(
+			 int (*ioctl)(unsigned int cmd,
+				      unsigned long arg))
+{
+	caif_ioctl_func =3D ioctl;
+}
+EXPORT_SYMBOL(caif_register_ioctl);
+
+int caif_ioctl(unsigned int cmd, unsigned long arg)
+{
+	printk(KERN_INFO "Enter: caif_ioctl\n");
+	if (caif_ioctl_func =3D=3D NULL)
+		return -EINVAL;
+	return caif_ioctl_func(cmd, arg);
+}
+EXPORT_SYMBOL(caif_ioctl);
+
+int caifdev_adapt_register(struct caif_channel_config *config,
+			   struct layer *adap_layer)
+{
+	struct cfctrl_link_param param;
+
+	if (channel_config_2_link_param(get_caif_conf(), config, &param) =3D=3D=
 0)
+		/* Hook up the adaptation layer. */
+		if (cfcnfg_add_adaptation_layer(get_caif_conf(),
+						&param, adap_layer))
+			return 0;
+
+	return -EINVAL;
+}
+EXPORT_SYMBOL(caifdev_adapt_register);
+
+int caifdev_adapt_unregister(struct layer *adap_layer)
+{
+	return cfcnfg_del_adapt_layer(get_caif_conf(), adap_layer);
+}
+EXPORT_SYMBOL(caifdev_adapt_unregister);
+
+
+int caif_register_netdev(int (*netdev_mgmt)
+			  (int action, union caif_action *param))
+{
+	netdev_mgmt_func =3D netdev_mgmt;
+	return 0;
+}
+EXPORT_SYMBOL(caif_register_netdev);
+
+void caif_unregister_netdev()
+{
+	netdev_mgmt_func =3D NULL;
+}
+EXPORT_SYMBOL(caif_unregister_netdev);
+
+static struct pernet_operations caif_net_ops =3D {
+	.init =3D caif_init_net,
+	.exit =3D caif_exit_net,
+};
+
+/* Initialize Caif devices list */
+int __init caif_device_init(void)
+{
+	int result;
+
+	cfg =3D cfcnfg_create();
+	if (!cfg) {
+		printk(KERN_WARNING "caifdev: err: can't create cfcnfg.\n");
+		goto err_cfcnfg_create_failed;
+	}
+
+	result =3D register_pernet_gen_device(&caif_net_id, &caif_net_ops);
+	if (result)
+		return result;
+	dev_add_pack(&caif_packet_type);
+	register_netdevice_notifier(&caif_device_notifier);
+
+	/* Register class for SYSFS. */
+	result =3D class_register(&caif_class);
+	if (unlikely(result)) {
+		printk(KERN_WARNING
+		       "caifdev: err: %d, can't create sysfs node.\n", result);
+		goto err_class_register_failed;
+	}
+
+	/* Create SYSFS nodes. */
+	result =3D class_create_file(&caif_class, &class_attr_dbg_lvl);
+	if (unlikely(result)) {
+		printk(KERN_WARNING
+		       "caifdev: err: %d, can't create sysfs node.\n", result);
+		goto err_sysfs_create_failed;
+	}
+	return result;
+
+err_sysfs_create_failed:
+	class_unregister(&caif_class);
+err_class_register_failed:
+err_cfcnfg_create_failed:
+	return -ENODEV;
+}
+
+void __exit caif_device_exit(void)
+{
+	class_remove_file(&caif_class, &class_attr_dbg_lvl);
+	class_unregister(&caif_class);
+	dev_remove_pack(&caif_packet_type);
+	unregister_pernet_gen_device(caif_net_id, &caif_net_ops);
+	unregister_netdevice_notifier(&caif_device_notifier);
+
+}
+
+module_init(caif_device_init);
+module_exit(caif_device_exit);
+
+
+
+
+
+
+
+
+
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
new file mode 100644
index 0000000..492fcfb
--- /dev/null
+++ b/net/caif/caif_socket.c
@@ -0,0 +1,1560 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Br=C3=A6ndeland sjur.brandlenad@stericsson.com
+ *              Per Sigmond / Per.Sigmond@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/fs.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/sched.h>
+#include <linux/spinlock.h>
+#include <linux/mutex.h>
+#include <linux/list.h>
+#include <linux/wait.h>
+#include <linux/poll.h>
+#include <linux/tcp.h>
+#include <asm/uaccess.h>
+#include <asm/atomic.h>
+
+/* Caif header files. */
+#include <linux/caif/caif_socket.h>
+#include <net/caif/generic/caif_layer.h>
+#include <linux/caif/caif_config.h>
+#include <net/caif/caif_log.h>
+#include <net/caif/caif_chr.h>
+
+MODULE_LICENSE("GPL");
+
+#define CHNL_SKT_READ_QUEUE_HIGH 2000
+#define CHNL_SKT_READ_QUEUE_LOW 100
+
+#ifdef CAIF_USE_CACHE
+int caif_max_links =3D 32;
+#endif
+
+int caif_sockbuf_size =3D 40000; /* FIXME: Check this value! */
+static struct kmem_cache *caif_sk_cachep;
+static atomic_t caif_nr_socks =3D ATOMIC_INIT(0);
+
+#define CONN_STATE_OPEN_BIT           1
+#define CONN_STATE_PENDING_BIT        2
+#define CONN_STATE_PEND_DESTROY_BIT   3
+#define CONN_REMOTE_SHUTDOWN_BIT      4
+
+#define TX_FLOW_ON_BIT                1
+#define RX_FLOW_ON_BIT                2
+
+#define STATE_IS_OPEN(cf_sk) test_bit(CONN_STATE_OPEN_BIT,\
+				    (void *) &(cf_sk)->conn_state)
+#define STATE_IS_REMOTE_SHUTDOWN(cf_sk) test_bit(CONN_REMOTE_SHUTDOWN_=
BIT,\
+				    (void *) &(cf_sk)->conn_state)
+#define STATE_IS_PENDING(cf_sk) test_bit(CONN_STATE_PENDING_BIT,\
+				       (void *) &(cf_sk)->conn_state)
+#define STATE_IS_PENDING_DESTROY(cf_sk) test_bit(CONN_STATE_PEND_DESTR=
OY_BIT,\
+				       (void *) &(cf_sk)->conn_state)
+
+#define SET_STATE_PENDING_DESTROY(cf_sk) set_bit(CONN_STATE_PEND_DESTR=
OY_BIT,\
+				    (void *) &(cf_sk)->conn_state)
+#define SET_STATE_OPEN(cf_sk) set_bit(CONN_STATE_OPEN_BIT,\
+				    (void *) &(cf_sk)->conn_state)
+#define SET_STATE_CLOSED(cf_sk) clear_bit(CONN_STATE_OPEN_BIT,\
+					(void *) &(cf_sk)->conn_state)
+#define SET_PENDING_ON(cf_sk) set_bit(CONN_STATE_PENDING_BIT,\
+				    (void *) &(cf_sk)->conn_state)
+#define SET_PENDING_OFF(cf_sk) clear_bit(CONN_STATE_PENDING_BIT,\
+				       (void *) &(cf_sk)->conn_state)
+#define SET_REMOTE_SHUTDOWN(cf_sk) set_bit(CONN_REMOTE_SHUTDOWN_BIT,\
+				    (void *) &(cf_sk)->conn_state)
+
+#define RX_FLOW_IS_ON(cf_sk) test_bit(RX_FLOW_ON_BIT,\
+				    (void *) &(cf_sk)->flow_state)
+#define TX_FLOW_IS_ON(cf_sk) test_bit(TX_FLOW_ON_BIT,\
+				    (void *) &(cf_sk)->flow_state)
+
+#define SET_RX_FLOW_OFF(cf_sk) clear_bit(RX_FLOW_ON_BIT,\
+				       (void *) &(cf_sk)->flow_state)
+#define SET_RX_FLOW_ON(cf_sk) set_bit(RX_FLOW_ON_BIT,\
+				    (void *) &(cf_sk)->flow_state)
+#define SET_TX_FLOW_OFF(cf_sk) clear_bit(TX_FLOW_ON_BIT,\
+				       (void *) &(cf_sk)->flow_state)
+#define SET_TX_FLOW_ON(cf_sk) set_bit(TX_FLOW_ON_BIT,\
+				    (void *) &(cf_sk)->flow_state)
+
+#define SKT_READ_FLAG 0x01
+#define SKT_WRITE_FLAG 0x02
+
+#define MAX_CAIF_SOCKETS	200
+
+#ifdef CONFIG_DEBUG_FS
+struct dentry *debugfsdir;
+#include <linux/debugfs.h>
+
+static int max_caif_sockets =3D MAX_CAIF_SOCKETS;
+#endif
+
+/* The AF_CAIF socket */
+struct caifsock {
+	struct sock sk;		/* NOTE: sk has to be the first member */
+	struct layer layer;
+	char name[CAIF_LAYER_NAME_SZ];
+	u32 conn_state;
+	u32 flow_state;
+	struct cfpktq *pktq;
+	int file_mode;
+	struct caif_channel_config config;
+	int read_queue_len;
+	spinlock_t read_queue_len_lock;
+
+#ifdef CONFIG_DEBUG_FS
+	struct dentry *debugfs_device_dir;
+	atomic_t num_open;
+	atomic_t num_close;
+	atomic_t num_init;
+	atomic_t num_init_resp;
+	atomic_t num_init_fail_resp;
+	atomic_t num_deinit;
+	atomic_t num_deinit_resp;
+	atomic_t num_remote_shutdown_ind;
+	atomic_t num_tx_flow_off_ind;
+	atomic_t num_tx_flow_on_ind;
+	atomic_t num_rx_flow_off;
+	atomic_t num_rx_flow_on;
+#endif
+};
+
+static void drain_queue(struct caifsock *cf_sk);
+
+/** Packet Receive Callback function called from CAIF Stack */
+static int caif_sktrecv_cb(struct layer *layr, struct cfpkt *pkt)
+{
+	struct caifsock *cf_sk;
+	int read_queue_high;
+	CAIFLOG_TRACE("Enter %s\n", __func__);
+	cf_sk =3D container_of(layr, struct caifsock, layer);
+
+	CAIFLOG_TRACE2("[%s] data received: %d bytes.\n",
+		       __func__, cfpkt_getlen(pkt));
+
+	if (!STATE_IS_OPEN(cf_sk)) {
+		/*FIXME: This should be allowed finally!*/
+		CAIFLOG_TRACE("caif_sktrecv_cb called after close request\n");
+		cfpkt_destroy(pkt);
+		return 0;
+	}
+	/** NOTE: This function may be called in Tasklet context! */
+
+	/* The queue has its own lock */
+	CAIFLOG_TRACE("here %p %p\n", pkt, cf_sk->pktq);
+	cfpkt_queue(cf_sk->pktq, pkt, 0);
+
+	spin_lock(&cf_sk->read_queue_len_lock);
+	cf_sk->read_queue_len++;
+
+	read_queue_high =3D (cf_sk->read_queue_len > CHNL_SKT_READ_QUEUE_HIGH=
);
+	spin_unlock(&cf_sk->read_queue_len_lock);
+
+	if (RX_FLOW_IS_ON(cf_sk) && read_queue_high) {
+
+#ifdef CONFIG_DEBUG_FS
+		atomic_inc(&cf_sk->num_rx_flow_off);
+#endif
+		SET_RX_FLOW_OFF(cf_sk);
+
+		/* Send flow off (NOTE: must not sleep) */
+		CAIFLOG_TRACE2
+		    ("caif_sktrecv_cb(): sending flow OFF (queue len =3D %d)\n",
+		     cf_sk->read_queue_len);
+		caif_assert(cf_sk->layer.dn);
+		caif_assert(cf_sk->layer.dn->ctrlcmd);
+
+		(void) cf_sk->layer.dn->modemcmd(cf_sk->layer.dn,
+					       CAIF_MODEMCMD_FLOW_OFF_REQ);
+	}
+
+	/* Signal reader that data is available. */
+
+	wake_up_interruptible(cf_sk->sk.sk_sleep);
+
+	return 0;
+}
+
+/** Packet Flow Control Callback function called from CAIF */
+static void caif_sktflowctrl_cb(struct layer *layr, enum caif_ctrlcmd =
flow, int phyid)
+{
+	struct caifsock *cf_sk;
+
+	CAIFLOG_TRACE("Enter %s\n", __func__);
+
+	/** NOTE: This function may be called in Tasklet context! */
+	CAIFLOG_TRACE("AT flowctrl func called flow: %s.\n",
+		      flow =3D=3D CAIF_CTRLCMD_FLOW_ON_IND ? "ON" :
+		      flow =3D=3D CAIF_CTRLCMD_FLOW_OFF_IND ? "OFF" :
+		      flow =3D=3D CAIF_CTRLCMD_INIT_RSP ? "INIT_RSP" :
+		      flow =3D=3D CAIF_CTRLCMD_DEINIT_RSP ? "DEINIT_RSP" :
+		      flow =3D=3D CAIF_CTRLCMD_INIT_FAIL_RSP ? "INIT_FAIL_RSP" :
+		      flow =3D=3D
+		      CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND ? "REMOTE_SHUTDOWN" :
+		      "UKNOWN CTRL COMMAND");
+
+	cf_sk =3D container_of(layr, struct caifsock, layer);
+	switch (flow) {
+	case CAIF_CTRLCMD_FLOW_ON_IND:
+		CAIFLOG_TRACE("[%s:%d] CAIF_CTRLCMD_FLOW_ON_IND\n",
+			      __func__, __LINE__);
+#ifdef CONFIG_DEBUG_FS
+		atomic_inc(&cf_sk->num_tx_flow_on_ind);
+#endif
+		/* Signal reader that data is available. */
+		SET_TX_FLOW_ON(cf_sk);
+		wake_up_interruptible(cf_sk->sk.sk_sleep);
+		break;
+
+	case CAIF_CTRLCMD_FLOW_OFF_IND:
+#ifdef CONFIG_DEBUG_FS
+		atomic_inc(&cf_sk->num_tx_flow_off_ind);
+#endif
+		CAIFLOG_TRACE("[%s:%d] CAIF_CTRLCMD_FLOW_OFF_IND\n",
+			      __func__, __LINE__);
+		SET_TX_FLOW_OFF(cf_sk);
+		break;
+
+	case CAIF_CTRLCMD_INIT_RSP:
+		CAIFLOG_TRACE("[%s:%d] CAIF_CTRLCMD_INIT_RSP\n",
+			      __func__, __LINE__);
+#ifdef CONFIG_DEBUG_FS
+		atomic_inc(&cf_sk->num_init_resp);
+#endif
+		/* Signal reader that data is available. */
+		caif_assert(STATE_IS_OPEN(cf_sk));
+		SET_PENDING_OFF(cf_sk);
+		SET_TX_FLOW_ON(cf_sk);
+		wake_up_interruptible(cf_sk->sk.sk_sleep);
+		break;
+
+	case CAIF_CTRLCMD_DEINIT_RSP:
+		CAIFLOG_TRACE("[%s:%d] CAIF_CTRLCMD_DEINIT_RSP\n",
+			      __func__, __LINE__);
+
+#ifdef CONFIG_DEBUG_FS
+		atomic_inc(&cf_sk->num_deinit_resp);
+#endif
+
+		caif_assert(!STATE_IS_OPEN(cf_sk));
+
+		SET_PENDING_OFF(cf_sk);
+
+		if (!STATE_IS_PENDING_DESTROY(cf_sk)) {
+			if (cf_sk->sk.sk_sleep !=3D NULL)
+				wake_up_interruptible(cf_sk->sk.sk_sleep);
+		}
+
+		sock_put(&cf_sk->sk);
+
+		break;
+
+	case CAIF_CTRLCMD_INIT_FAIL_RSP:
+		CAIFLOG_TRACE("[%s:%d] CAIF_CTRLCMD_INIT_FAIL_RSP\n",
+			      __func__, __LINE__);
+#ifdef CONFIG_DEBUG_FS
+		atomic_inc(&cf_sk->num_init_fail_resp);
+#endif
+		caif_assert(STATE_IS_OPEN(cf_sk));
+		SET_STATE_CLOSED(cf_sk);
+		SET_PENDING_OFF(cf_sk);
+		SET_TX_FLOW_OFF(cf_sk);
+		wake_up_interruptible(cf_sk->sk.sk_sleep);
+		break;
+
+	case CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND:
+		CAIFLOG_TRACE("[%s:%d] CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND\n",
+			      __func__, __LINE__);
+#ifdef CONFIG_DEBUG_FS
+		atomic_inc(&cf_sk->num_remote_shutdown_ind);
+#endif
+		caif_assert(STATE_IS_OPEN(cf_sk));
+		caif_assert(STATE_IS_PENDING(cf_sk));
+
+		SET_REMOTE_SHUTDOWN(cf_sk);
+		SET_TX_FLOW_OFF(cf_sk);
+
+		drain_queue(cf_sk);
+		SET_RX_FLOW_ON(cf_sk);
+		cf_sk->file_mode =3D 0;
+
+		wake_up_interruptible(cf_sk->sk.sk_sleep);
+		break;
+
+	default:
+		CAIFLOG_TRACE("[%s:%d] Unexpected flow command %d\n",
+			      __func__, __LINE__, flow);
+	}
+}
+
+
+
+static struct sk_buff *caif_alloc_send_skb(struct sock *sk,
+				    unsigned long data_len,
+				    int *err)
+{
+	struct sk_buff *skb;
+	unsigned int sk_allocation =3D sk->sk_allocation;
+
+	sk->sk_allocation |=3D GFP_KERNEL;
+
+	/* Allocate a buffer structure to hold the signal. */
+	skb =3D sock_alloc_send_skb(sk, data_len, 1, err);
+
+	sk->sk_allocation =3D sk_allocation;
+
+	return skb;
+}
+
+static int caif_recvmsg(struct kiocb *iocb, struct socket *sock,
+				struct msghdr *m, size_t buf_len, int flags)
+
+{
+	struct sock *sk =3D sock->sk;
+	struct caifsock *cf_sk =3D container_of(sk, struct caifsock, sk);
+	struct cfpkt *pkt =3D NULL;
+	size_t len;
+	int result;
+	struct sk_buff *skb;
+	ssize_t ret =3D -EIO;
+	int read_queue_low;
+	CAIFLOG_TRACE("Enter %s\n", __func__);
+
+	if (cf_sk =3D=3D NULL) {
+		CAIFLOG_TRACE("[%s:%d] private_data not set!\n",
+			      __func__, __LINE__);
+		ret =3D -EBADFD;
+		goto read_error;
+	}
+
+	if (m->msg_iovlen !=3D 1)
+		return -EOPNOTSUPP;   /* Don't do multiple iovec entries yet */
+
+	if (unlikely(!buf_len))
+		return -EINVAL;
+
+	lock_sock(&(cf_sk->sk));
+
+	caif_assert(cf_sk->pktq);
+
+	if (!STATE_IS_OPEN(cf_sk)) {
+		/* Socket is closed or closing. */
+		if (!STATE_IS_PENDING(cf_sk)) {
+			CAIFLOG_TRACE("socket is closed (by remote end)\n");
+			ret =3D -EPIPE;
+		} else {
+			CAIFLOG_TRACE("socket is closing...\n");
+			ret =3D -EBADF;
+		}
+		goto read_error;
+	}
+
+	/* Socket is open or opening. */
+	if (STATE_IS_PENDING(cf_sk)) {
+		CAIFLOG_TRACE("socket is opening...\n");
+
+		if (flags & MSG_DONTWAIT) {
+			/* We can't block. */
+			CAIFLOG_TRACE("state pending and MSG_DONTWAIT\n");
+			ret =3D -EAGAIN;
+			goto read_error;
+		}
+
+		/* Blocking mode; state is pending and we need to wait
+		 * for its conclusion.
+		 */
+		release_sock(&cf_sk->sk);
+
+		result =3D
+		    wait_event_interruptible(*cf_sk->sk.sk_sleep,
+					     !STATE_IS_PENDING(cf_sk));
+
+		lock_sock(&(cf_sk->sk));
+
+		if (result =3D=3D -ERESTARTSYS) {
+			CAIFLOG_TRACE
+			    (" wait_event_interruptible woken by a signal (1)");
+			ret =3D -ERESTARTSYS;
+			goto read_error;
+		}
+	}
+
+	if (STATE_IS_REMOTE_SHUTDOWN(cf_sk)) {
+		CAIFLOG_TRACE("received remote_shutdown indication\n");
+		ret =3D -ESHUTDOWN;
+		goto read_error;
+	}
+
+	/* Block if we don't have any received buffers.
+	 * The queue has its own lock.
+	 */
+	while ((pkt =3D cfpkt_qpeek(cf_sk->pktq)) =3D=3D NULL) {
+
+		if (flags & MSG_DONTWAIT) {
+			CAIFLOG_TRACE("caif_recvmsg: MSG_DONTWAIT\n");
+			ret =3D -EAGAIN;
+			goto read_error;
+		}
+		CAIFLOG_TRACE2("[%s:%d] wait_event\n", __func__, __LINE__);
+
+		/* Let writers in. */
+		release_sock(&cf_sk->sk);
+
+		/* Block reader until data arrives or socket is closed. */
+		if (wait_event_interruptible(*cf_sk->sk.sk_sleep,
+					cfpkt_qpeek(cf_sk->pktq)
+					|| STATE_IS_REMOTE_SHUTDOWN(cf_sk)
+					|| !STATE_IS_OPEN(cf_sk)) =3D=3D
+		    -ERESTARTSYS) {
+			CAIFLOG_TRACE
+				("caif_recvmsg:"
+				" wait_event_interruptible woken by "
+				"a signal, signal_pending(current) =3D %d\n",
+				signal_pending(current));
+			return -ERESTARTSYS;
+		}
+
+		CAIFLOG_TRACE2("[%s:%d] awake\n", __func__, __LINE__);
+		if (STATE_IS_REMOTE_SHUTDOWN(cf_sk)) {
+			CAIFLOG_TRACE("received remote_shutdown indication\n");
+			ret =3D -ESHUTDOWN;
+			goto read_error_no_unlock;
+		}
+
+		/* I want to be alone on cf_sk (except status and queue). */
+		lock_sock(&(cf_sk->sk));
+
+		if (!STATE_IS_OPEN(cf_sk)) {
+			/* Someone closed the link, report error. */
+			CAIFLOG_TRACE("[%s:%d] remote end shutdown!\n",
+				      __func__, __LINE__);
+			ret =3D -EPIPE;
+			goto read_error;
+		}
+	}
+
+	/* The queue has its own lock. */
+	len =3D cfpkt_getlen(pkt);
+
+	/* Check max length that can be copied. */
+	if (len > buf_len) {
+		CAIFLOG_TRACE("caif_recvmsg: user buffer too small\n");
+		ret =3D -EINVAL;
+		goto read_error;
+	}
+
+	/* Get packet from queue.
+	 * The queue has its own lock.
+	 */
+	pkt =3D cfpkt_dequeue(cf_sk->pktq);
+
+	spin_lock(&cf_sk->read_queue_len_lock);
+	cf_sk->read_queue_len--;
+	read_queue_low =3D (cf_sk->read_queue_len < CHNL_SKT_READ_QUEUE_LOW);
+	spin_unlock(&cf_sk->read_queue_len_lock);
+
+	if (!RX_FLOW_IS_ON(cf_sk) && read_queue_low) {
+#ifdef CONFIG_DEBUG_FS
+		atomic_inc(&cf_sk->num_rx_flow_on);
+#endif
+		SET_RX_FLOW_ON(cf_sk);
+
+		/* Send flow on. */
+		CAIFLOG_TRACE2
+			("caif_recvmsg(): sending flow ON (queue len =3D %d)\n",
+			cf_sk->read_queue_len);
+		caif_assert(cf_sk->layer.dn);
+		caif_assert(cf_sk->layer.dn->ctrlcmd);
+		(void) cf_sk->layer.dn->modemcmd(cf_sk->layer.dn,
+					       CAIF_MODEMCMD_FLOW_ON_REQ);
+
+		caif_assert(cf_sk->read_queue_len >=3D 0);
+	}
+	skb =3D cfpkt_tonative(pkt);
+	result =3D skb_copy_datagram_iovec(skb, 0, m->msg_iov, len);
+	if (result) {
+		CAIFLOG_TRACE("caif_recvmsg: cfpkt_raw_extract failed\n");
+		cfpkt_destroy(pkt);
+		ret =3D -EFAULT;
+		goto read_error;
+	}
+	if (unlikely(buf_len < len)) {
+		len =3D buf_len;
+		m->msg_flags |=3D MSG_TRUNC;
+	}
+
+	/* Free packet. */
+	skb_free_datagram(sk, skb);
+
+	/* Let the others in. */
+	release_sock(&cf_sk->sk);
+	CAIFLOG_EXIT("");
+	return len;
+
+read_error:
+	release_sock(&cf_sk->sk);
+read_error_no_unlock:
+	CAIFLOG_EXIT("");
+	return ret;
+}
+
+/* Send a signal as a consequence of sendmsg, sendto or caif_sendmsg. =
*/
+static int caif_sendmsg(struct kiocb *kiocb, struct socket *sock,
+			struct msghdr *msg, size_t len)
+{
+
+	struct sock *sk =3D sock->sk;
+	struct caifsock *cf_sk =3D container_of(sk, struct caifsock, sk);
+	void *payload;
+	size_t payload_size =3D msg->msg_iov->iov_len;
+	struct cfpkt *pkt =3D NULL;
+	struct transmt_info info;
+	unsigned char *txbuf;
+	int err =3D 0;
+	ssize_t ret =3D -EIO;
+	int result;
+	struct sk_buff *skb;
+	CAIFLOG_TRACE("Enter %s\n", __func__);
+	caif_assert(msg->msg_iovlen =3D=3D 1);
+
+	if (cf_sk =3D=3D NULL) {
+		CAIFLOG_TRACE("[%s:%d] private_data not set!\n",
+			      __func__, __LINE__);
+		ret =3D -EBADFD;
+		goto write_error_no_unlock;
+	}
+
+	if (unlikely(msg->msg_iov->iov_base =3D=3D NULL)) {
+		CAIFLOG_WARN("Buffer is NULL.\n");
+		ret =3D -EINVAL;
+		goto write_error_no_unlock;
+	}
+
+	payload =3D msg->msg_iov->iov_base;
+	if (payload_size > CAIF_MAX_PAYLOAD_SIZE) {
+		CAIFLOG_TRACE("[%s:%d] buffer too long\n", __func__, __LINE__);
+		ret =3D -EINVAL;
+		goto write_error_no_unlock;
+	}
+	/* I want to be alone on cf_sk (except status and queue) */
+	lock_sock(&(cf_sk->sk));
+
+	caif_assert(cf_sk->pktq);
+
+	if (!STATE_IS_OPEN(cf_sk)) {
+		/* Socket is closed or closing */
+		if (!STATE_IS_PENDING(cf_sk)) {
+			CAIFLOG_TRACE("socket is closed (by remote end)\n");
+			ret =3D -EPIPE;
+		} else {
+			CAIFLOG_TRACE("socket is closing...\n");
+			ret =3D -EBADF;
+		}
+		goto write_error;
+	}
+
+	/* Socket is open or opening */
+	if (STATE_IS_PENDING(cf_sk)) {
+		CAIFLOG_TRACE("socket is opening...\n");
+
+		if (msg->msg_flags & MSG_DONTWAIT) {
+			/* We can't block */
+			CAIFLOG_TRACE("state pending and MSG_DONTWAIT\n");
+			ret =3D -EAGAIN;
+			goto write_error;
+		}
+
+		/* Let readers in */
+		release_sock(&cf_sk->sk);
+
+		/* Blocking mode; state is pending and we need to wait
+		   for its conclusion */
+		result =3D
+		    wait_event_interruptible(*cf_sk->sk.sk_sleep,
+					     !STATE_IS_PENDING(cf_sk));
+
+		/* I want to be alone on cf_sk (except status and queue) */
+		lock_sock(&(cf_sk->sk));
+
+		if (result =3D=3D -ERESTARTSYS) {
+			CAIFLOG_TRACE
+			    (" wait_event_interruptible woken by a signal (1)");
+			ret =3D -ERESTARTSYS;
+			goto write_error;
+		}
+	}
+
+	if (STATE_IS_REMOTE_SHUTDOWN(cf_sk)) {
+		CAIFLOG_TRACE("received remote_shutdown indication\n");
+		ret =3D -ESHUTDOWN;
+		goto write_error;
+	}
+
+	if (!TX_FLOW_IS_ON(cf_sk)) {
+
+		/* Flow is off. Check non-block flag */
+		if (msg->msg_flags & MSG_DONTWAIT) {
+			CAIFLOG_TRACE
+			("caif_sendmsg: MSG_DONTWAIT and tx flow off");
+			ret =3D -EAGAIN;
+			goto write_error;
+		}
+
+		/* release lock before waiting */
+		release_sock(&cf_sk->sk);
+
+		/* Wait until flow is on or socket is closed */
+		if (wait_event_interruptible(*cf_sk->sk.sk_sleep,
+					TX_FLOW_IS_ON(cf_sk)
+					|| !STATE_IS_OPEN(cf_sk)
+					|| STATE_IS_REMOTE_SHUTDOWN(cf_sk)
+					) =3D=3D -ERESTARTSYS) {
+			CAIFLOG_TRACE
+				("caif_sendmsg:"
+				" wait_event_interruptible woken by a signal");
+			ret =3D -ERESTARTSYS;
+			goto write_error_no_unlock;
+		}
+
+		/* I want to be alone on cf_sk (except status and queue) */
+		lock_sock(&(cf_sk->sk));
+
+		if (!STATE_IS_OPEN(cf_sk)) {
+			/* someone closed the link, report error */
+			CAIFLOG_TRACE("[%s:%d] remote end shutdown!\n",
+				      __func__, __LINE__);
+			ret =3D -EPIPE;
+			goto write_error;
+		}
+
+		if (STATE_IS_REMOTE_SHUTDOWN(cf_sk)) {
+			CAIFLOG_TRACE("received remote_shutdown indication\n");
+			ret =3D -ESHUTDOWN;
+			goto write_error;
+		}
+	}
+
+	/* Create packet, buf=3DNULL means no copying */
+	skb =3D caif_alloc_send_skb(sk,
+				payload_size + CAIF_NEEDED_HEADROOM +
+				CAIF_NEEDED_TAILROOM,
+				&err);
+	skb_reserve(skb, CAIF_NEEDED_HEADROOM);
+	pkt =3D cfpkt_fromnative(CAIF_DIR_OUT, skb);
+	caif_assert((void *)pkt =3D=3D (void *)skb);
+
+	if (pkt =3D=3D NULL) {
+		CAIFLOG_TRACE
+			("caif_sendmsg: cfpkt_create_pkt returned NULL\n");
+		ret =3D -EIO;
+		goto write_error;
+	}
+
+	if (!cfpkt_raw_append(pkt, (void **) &txbuf, payload_size)) {
+		CAIFLOG_TRACE("caif_sendmsg: cfpkt_raw_append failed\n");
+		cfpkt_destroy(pkt);
+		ret =3D -EINVAL;
+		goto write_error;
+	}
+
+	/* Copy data into buffer. */
+	if (copy_from_user(txbuf, payload, payload_size)) {
+		CAIFLOG_TRACE
+			("caif_sendmsg: copy_from_user returned non zero.\n");
+		cfpkt_destroy(pkt);
+		ret =3D -EINVAL;
+		goto write_error;
+	}
+	memset(&info, 0, sizeof(info));
+
+	/* Send the packet down the stack. */
+	caif_assert(cf_sk->layer.dn);
+	caif_assert(cf_sk->layer.dn->transmit);
+
+	do {
+			ret =3D cf_sk->layer.dn->transmit(cf_sk->layer.dn,
+							&info, pkt);
+
+		if (likely((ret >=3D 0) || (ret !=3D -EAGAIN)))
+			break;
+
+		/* EAGAIN - retry */
+		if (msg->msg_flags & MSG_DONTWAIT) {
+			CAIFLOG_TRACE
+			    ("NONBLOCK and transmit failed, error =3D %d\n",
+			     ret);
+			ret =3D -EAGAIN;
+			goto write_error;
+		}
+
+		/* Let readers in */
+		release_sock(&cf_sk->sk);
+
+		/* Wait until flow is on or socket is closed */
+		if (wait_event_interruptible(*cf_sk->sk.sk_sleep,
+					TX_FLOW_IS_ON(cf_sk)
+					|| !STATE_IS_OPEN(cf_sk)
+					|| STATE_IS_REMOTE_SHUTDOWN(cf_sk)
+					) =3D=3D -ERESTARTSYS) {
+			CAIFLOG_TRACE
+			    ("wait_event_interruptible woken by a signal");
+			ret =3D -ERESTARTSYS;
+			goto write_error_no_unlock;
+		}
+
+		/* I want to be alone on cf_sk (except status and queue) */
+		lock_sock(&(cf_sk->sk));
+
+	} while (ret =3D=3D -EAGAIN);
+
+	if (ret < 0) {
+		cfpkt_destroy(pkt);
+		CAIFLOG_TRACE("transmit failed, error =3D %d\n",
+			      ret);
+
+		goto write_error;
+	}
+
+	release_sock(&cf_sk->sk);
+	CAIFLOG_EXIT("");
+	return payload_size;
+
+write_error:
+	release_sock(&cf_sk->sk);
+write_error_no_unlock:
+	CAIFLOG_EXIT("");
+	return ret;
+}
+
+static unsigned int caif_poll(struct file *file, struct socket *sock,
+						poll_table *wait)
+{
+	struct sock *sk =3D sock->sk;
+	struct caifsock *cf_sk =3D container_of(sk, struct caifsock, sk);
+	u32 mask =3D 0;
+	CAIFLOG_ENTER("");
+
+	poll_wait(file, sk->sk_sleep, wait);
+	lock_sock(&(cf_sk->sk));
+	if (cfpkt_qpeek(cf_sk->pktq) !=3D NULL)
+		mask |=3D (POLLIN | POLLRDNORM);
+	if (!STATE_IS_OPEN(cf_sk))
+		mask |=3D POLLHUP;
+	else if (TX_FLOW_IS_ON(cf_sk))
+		mask |=3D (POLLOUT | POLLWRNORM);
+	release_sock(&cf_sk->sk);
+	CAIFLOG_TRACE("[%s:%d] poll mask=3D0x%04x...\n",
+		      __func__, __LINE__, mask);
+	CAIFLOG_EXIT("");
+	return mask;
+}
+
+static void drain_queue(struct caifsock *cf_sk)
+{
+	struct cfpkt *pkt =3D NULL;
+	CAIFLOG_TRACE("Enter %s\n", __func__);
+	CAIFLOG_TRACE("pktq =3D %p pkt=3D%p\n", cf_sk->pktq, pkt);
+
+	/* Empty the queue */
+	do {
+		/* The queue has its own lock */
+		pkt =3D cfpkt_dequeue(cf_sk->pktq);
+		CAIFLOG_TRACE("pktq =3D %p pkt=3D%p\n", cf_sk->pktq, pkt);
+
+		if (!pkt)
+			break;
+
+		CAIFLOG_TRACE
+		    ("[%s:%d] drain_queue(): freeing packet from read queue\n",
+		     __func__, __LINE__);
+		cfpkt_destroy(pkt);
+
+	} while (1);
+
+	spin_lock(&cf_sk->read_queue_len_lock);
+	cf_sk->read_queue_len =3D 0;
+	spin_unlock(&cf_sk->read_queue_len_lock);
+}
+
+
+static int setsockopt(struct socket *sock,
+			int lvl, int opt, char __user *ov, int ol)
+{
+	struct sock *sk =3D sock->sk;
+	struct caifsock *cf_sk =3D container_of(sk, struct caifsock, sk);
+	struct caif_channel_opt confopt;
+	int res;
+
+	if (lvl !=3D SOL_CAIF) {
+		CAIFLOG_TRACE("setsockopt bad level\n");
+			return -ENOPROTOOPT;
+	}
+
+	switch (opt) {
+	case CAIF_CHANNEL_OPT:
+		if (ol < sizeof(struct caif_channel_opt)) {
+			CAIFLOG_TRACE("setsockopt"
+					" CAIF_CHANNEL_CONFIG bad size\n");
+				return -EINVAL;
+		}
+		res =3D copy_from_user(&confopt, ov, sizeof(confopt));
+		if (res)
+			return res;
+		lock_sock(&(cf_sk->sk));
+		cf_sk->config.priority =3D confopt.priority;
+		cf_sk->config.phy_pref =3D confopt.link_selector;
+		strncpy(cf_sk->config.phy_name, confopt.link_name,
+			sizeof(cf_sk->config.phy_name));
+		CAIFLOG_TRACE("Setting sockopt pri=3D%d pref=3D%d name=3D%s\n",
+			      cf_sk->config.priority,
+			      cf_sk->config.phy_pref,
+			      cf_sk->config.phy_name);
+		release_sock(&cf_sk->sk);
+		return 0;
+/* TODO: Implement the remaining options:
+ *	case CAIF_REQ_PARAM_OPT:
+ *	case CAIF_RSP_PARAM_OPT:
+ *	case CAIF_UTIL_FLOW_OPT:
+ *	case CAIF_CONN_INFO_OPT:
+ *	case CAIF_CONN_ID_OPT:
+ */
+	default:
+		CAIFLOG_TRACE("setsockopt: unhandled option %d\n",
+			      opt);
+		return -EINVAL;
+	}
+
+
+}
+
+static int getsockopt(struct socket *sock,
+			int lvl, int opt, char __user *ov, int __user *ol)
+{
+	return -EINVAL;
+}
+
+static int caif_channel_config(struct caifsock *cf_sk,
+				struct sockaddr *sock_addr, int len,
+				struct caif_channel_config *config)
+{
+	struct sockaddr_caif *addr =3D (struct sockaddr_caif *)sock_addr;
+
+
+		if (len !=3D sizeof(struct sockaddr_caif)) {
+			CAIFLOG_TRACE("Bad address len (%d,%d)\n",
+			      len, sizeof(struct sockaddr_caif));
+			return -EINVAL;
+	}
+	if (sock_addr->sa_family !=3D AF_CAIF) {
+		CAIFLOG_TRACE("Bad address family (%d)\n",
+				sock_addr->sa_family);
+		return -EAFNOSUPPORT;
+	}
+
+	switch (cf_sk->sk.sk_protocol) {
+	case CAIFPROTO_AT:
+		config->type =3D CAIF_CHTY_AT;
+		break;
+	case CAIFPROTO_DATAGRAM:
+		config->type =3D CAIF_CHTY_DATAGRAM;
+		break;
+	case CAIFPROTO_DATAGRAM_LOOP:
+		config->type =3D CAIF_CHTY_DATAGRAM_LOOP;
+		config->u.dgm.connection_id =3D addr->u.dgm.connection_id;
+		break;
+	case CAIFPROTO_UTIL:
+		config->type =3D CAIF_CHTY_UTILITY;
+		strncpy(config->u.utility.name, addr->u.util.service,
+				sizeof(config->u.utility.name));
+		/* forcing the end of string to be null-terminated  */
+		config->u.utility.name[sizeof(config->u.utility.name)-1] =3D '\0';
+		break;
+	case CAIFPROTO_RFM:
+		config->type =3D CAIF_CHTY_RFM;
+		config->u.rfm.connection_id =3D addr->u.rfm.connection_id;
+		strncpy(config->u.rfm.volume, addr->u.rfm.volume,
+			sizeof(config->u.rfm.volume));
+		/* forcing the end of string to be null-terminated  */
+		config->u.rfm.volume[sizeof(config->u.rfm.volume)-1] =3D '\0';
+		break;
+	default:
+		CAIFLOG_TRACE("Bad caif protocol type (%d)\n",
+						cf_sk->sk.sk_protocol);
+		return -EINVAL;
+	}
+	CAIFLOG_TRACE("Setting connect param PROTO=3D%s\n",
+			(cf_sk->sk.sk_protocol =3D=3D CAIFPROTO_AT) ?
+			"CAIFPROTO_AT" :
+			(cf_sk->sk.sk_protocol =3D=3D CAIFPROTO_DATAGRAM) ?
+			"CAIFPROTO_DATAGRAM" :
+			(cf_sk->sk.sk_protocol =3D=3D CAIFPROTO_DATAGRAM_LOOP) ?
+			"CAIFPROTO_DATAGRAM_LOOP" :
+			(cf_sk->sk.sk_protocol =3D=3D CAIFPROTO_UTIL) ?
+			"CAIFPROTO_UTIL" :
+			(cf_sk->sk.sk_protocol =3D=3D CAIFPROTO_RFM) ?
+			"CAIFPROTO_RFM" : "ERROR");
+	return 0;
+}
+
+
+int caif_connect(struct socket *sock, struct sockaddr *uservaddr,
+	       int sockaddr_len, int flags)
+{
+	struct caifsock *cf_sk =3D NULL;
+	int result =3D -1;
+	int mode =3D 0;
+	int ret =3D -EIO;
+    struct sock *sk =3D sock->sk;
+
+	CAIFLOG_TRACE("Enter %s\n", __func__);
+
+	BUG_ON(sk =3D=3D NULL);
+
+	cf_sk =3D container_of(sk, struct caifsock, sk);
+
+	CAIFLOG_TRACE("cf_sk=3D%p OPEN=3D%d, TX_FLOW=3D%d, RX_FLOW=3D%d\n", c=
f_sk,
+		      STATE_IS_OPEN(cf_sk),
+		      TX_FLOW_IS_ON(cf_sk), RX_FLOW_IS_ON(cf_sk));
+
+	sk->sk_state    =3D TCP_CLOSE;
+	sock->state     =3D SS_UNCONNECTED;
+
+	/* FIXME: SOCK_DGRAM should be removed? */
+	if (sock->type =3D=3D SOCK_DGRAM || sock->type =3D=3D SOCK_SEQPACKET)=
 {
+		sock->state     =3D SS_CONNECTED;
+		sk->sk_state    =3D TCP_ESTABLISHED;
+	} else
+		goto out;
+
+	/* I want to be alone on cf_sk (except status and queue) */
+	lock_sock(&(cf_sk->sk));
+
+	ret =3D caif_channel_config(cf_sk, uservaddr, sockaddr_len,
+				&cf_sk->config);
+	if (ret) {
+		CAIFLOG_TRACE
+		    ("[%s:%d] Cannot set socket address\n",
+		     __func__, __LINE__);
+		goto open_error;
+	}
+
+
+#ifdef CONFIG_DEBUG_FS
+	atomic_inc(&cf_sk->num_open);
+#endif
+	mode =3D SKT_READ_FLAG | SKT_WRITE_FLAG;
+
+	/* If socket is not open, make sure socket is in fully closed state *=
/
+	if (!STATE_IS_OPEN(cf_sk)) {
+		/* Has link close response been received
+		   (if we ever sent it)? */
+		if (STATE_IS_PENDING(cf_sk)) {
+			/* Still waiting for close response from remote.
+			   If opened non-blocking, report "would block" */
+			if (flags & MSG_DONTWAIT) {
+				CAIFLOG_TRACE("MSG_DONTWAIT"
+					" && close pending\n");
+				ret =3D -EAGAIN;
+				goto open_error;
+			}
+
+			CAIFLOG_TRACE
+			    ("wait for close response from remote...\n");
+
+			release_sock(&cf_sk->sk);
+
+			/* Blocking mode; close is pending and we need to wait
+			   for its conclusion */
+			result =3D
+			    wait_event_interruptible(*cf_sk->sk.sk_sleep,
+						     !STATE_IS_PENDING(cf_sk));
+
+			lock_sock(&(cf_sk->sk));
+			if (result =3D=3D -ERESTARTSYS) {
+				CAIFLOG_TRACE
+				    ("wait_event_interruptible woken"
+				     "by a signal (1)");
+				ret =3D -ERESTARTSYS;
+				goto open_error;
+			}
+		}
+	}
+
+	/* socket is now either closed, pending open or open */
+	if (STATE_IS_OPEN(cf_sk) && !STATE_IS_PENDING(cf_sk)) {
+		/* Open */
+		CAIFLOG_TRACE
+		    ("[%s:%d] Socket is already opened (cf_sk=3D%p) check access "
+		     "f_flags =3D 0x%x file_mode =3D 0x%x\n",
+		     __func__, __LINE__, cf_sk, mode, cf_sk->file_mode);
+
+		if (mode & cf_sk->file_mode) {
+			CAIFLOG_TRACE
+			    ("[%s:%d] Access mode already in use 0x%x \n",
+			     __func__, __LINE__, mode);
+			ret =3D -EBUSY;
+			goto open_error;
+		}
+	} else {
+		/* We are closed or pending open.
+		 * If closed:       send link setup
+		 * If pending open: link setup already sent (we could have been
+		 *                  interrupted by a signal last time)
+		 */
+		if (!STATE_IS_OPEN(cf_sk)) {
+			/* First opening of file; connect lower layers: */
+					/* Drain queue (very unlikely) */
+			drain_queue(cf_sk);
+
+			cf_sk->layer.receive =3D caif_sktrecv_cb;
+
+			SET_STATE_OPEN(cf_sk);
+			SET_PENDING_ON(cf_sk);
+
+			/* Register this channel. */
+			result =3D
+			    caifdev_adapt_register(&cf_sk->config,
+						&cf_sk->layer);
+			if (result < 0) {
+				CAIFLOG_TRACE
+					("[%s:%d]: can't register channel\n",
+					__func__, __LINE__);
+				ret =3D -EIO;
+				SET_STATE_CLOSED(cf_sk);
+				SET_PENDING_OFF(cf_sk);
+				goto open_error;
+			}
+#ifdef CONFIG_DEBUG_FS
+			atomic_inc(&cf_sk->num_init);
+#endif
+		}
+
+		/* If opened non-blocking, report "success".
+		 */
+		if (flags & MSG_DONTWAIT) {
+			CAIFLOG_TRACE("[%s:%d]: MSG_DONTWAIT success\n",
+				__func__, __LINE__);
+			ret =3D 0;
+			goto open_success;
+		}
+
+		CAIFLOG_TRACE("WAIT FOR CONNECT RESPONSE \n");
+
+		/* release lock before waiting */
+		release_sock(&cf_sk->sk);
+
+		result =3D
+		    wait_event_interruptible(*cf_sk->sk.sk_sleep,
+					     !STATE_IS_PENDING(cf_sk));
+
+		lock_sock(&(cf_sk->sk));
+
+		if (result =3D=3D -ERESTARTSYS) {
+			CAIFLOG_TRACE
+			("%s: "
+			"wait_event_interruptible woken by a signal (2)",
+			__func__);
+			ret =3D -ERESTARTSYS;
+			goto open_error;
+		}
+
+		if (!STATE_IS_OPEN(cf_sk)) {
+			/* Lower layers said "no" */
+			CAIFLOG_TRACE
+			    ("[%s:%d]: CLOSED RECEIVED\n",
+			     __func__, __LINE__);
+			ret =3D -EPIPE;
+			goto open_error;
+		}
+
+		CAIFLOG_TRACE("[%s:%d]: CONNECT RECEIVED\n",
+			      __func__, __LINE__);
+	}
+open_success:
+	/* Open is ok */
+	cf_sk->file_mode |=3D mode;
+
+	CAIFLOG_TRACE("[%s:%d] Open - file mode =3D %x\n",
+		      __func__, __LINE__, cf_sk->file_mode);
+
+	CAIFLOG_TRACE("[%s:%d] CONNECTED \n", __func__, __LINE__);
+
+	release_sock(&cf_sk->sk);
+	CAIFLOG_EXIT("");
+	return 0;
+open_error:
+	release_sock(&cf_sk->sk);
+out:
+	CAIFLOG_EXIT("");
+	return ret;
+}
+
+static int caif_shutdown(struct socket *sock, int how)
+{
+	struct caifsock *cf_sk =3D NULL;
+	int result;
+	int tx_flow_state_was_on;
+	struct sock *sk =3D sock->sk;
+	int res =3D 0;
+
+	CAIFLOG_TRACE("Enter %s\n", __func__);
+
+	if (how !=3D SHUT_RDWR)
+		return -EOPNOTSUPP; /* FIXME: ENOTSUP in userland for POSIX */
+
+	cf_sk =3D container_of(sk, struct caifsock, sk);
+	if (cf_sk =3D=3D NULL) {
+		CAIFLOG_TRACE("[%s] COULD NOT FIND SOCKET\n", __func__);
+		return -EBADF;
+	}
+
+	/* I want to be alone on cf_sk (except status queue) */
+	lock_sock(&(cf_sk->sk));
+#ifdef CONFIG_DEBUG_FS
+	atomic_inc(&cf_sk->num_close);
+#endif
+
+	/* Is the socket open? */
+	if (!STATE_IS_OPEN(cf_sk)) {
+		CAIFLOG_TRACE("[%s:%d] socket not open (cf_sk=3D%p) \n",
+			      __func__, __LINE__, cf_sk);
+		release_sock(&cf_sk->sk);
+		return 0;
+	}
+
+	/* Is the socket waiting for link setup response? */
+	if (STATE_IS_PENDING(cf_sk)) {
+		CAIFLOG_TRACE("[%s:%d] Socket is open pending (cf_sk=3D%p) \n",
+				__func__, __LINE__, cf_sk);
+		release_sock(&cf_sk->sk);
+		/* What to return here? Seems that EBADF is the closest :-| */
+		return -EBADF;
+	}
+	/* IS_CLOSED have double meaning:
+	 * 1) Spontanous Remote Shutdown Request.
+	 * 2) Ack on a channel teardown(disconnect)
+	 * Must clear bit in case we previously received
+	 * remote shudown request.
+	 */
+
+	SET_STATE_CLOSED(cf_sk);
+	SET_PENDING_ON(cf_sk);
+	sock->state =3D SS_DISCONNECTING; /* FIXME: Update the sock->states *=
/
+	tx_flow_state_was_on =3D TX_FLOW_IS_ON(cf_sk);
+	SET_TX_FLOW_OFF(cf_sk);
+	sock_hold(&cf_sk->sk);
+	result =3D caifdev_adapt_unregister(&cf_sk->layer);
+
+	if (result < 0) {
+		CAIFLOG_TRACE
+		("caif_shutdown: caifdev_adapt_unregister() failed\n");
+		SET_STATE_CLOSED(cf_sk);
+		SET_PENDING_OFF(cf_sk);
+		SET_TX_FLOW_OFF(cf_sk);
+		release_sock(&cf_sk->sk);
+		return -EIO;
+	}
+#ifdef CONFIG_DEBUG_FS
+	atomic_inc(&cf_sk->num_deinit);
+#endif
+
+	/* We don't wait for close response here. Close pending state will be
+	   cleared by flow control callback when response arrives. */
+
+	/* Empty the queue */
+	drain_queue(cf_sk);
+	SET_RX_FLOW_ON(cf_sk);
+	cf_sk->file_mode =3D 0;
+
+
+	release_sock(&cf_sk->sk);
+	return res;
+}
+static ssize_t caif_sock_no_sendpage(struct socket *sock,
+				     struct page *page,
+				     int offset, size_t size, int flags)
+{
+	return -EOPNOTSUPP;
+}
+
+/* This function is called as part of close. */
+static int caif_release(struct socket *sock)
+{
+	struct sock *sk =3D sock->sk;
+	struct caifsock *cf_sk =3D NULL;
+	CAIFLOG_TRACE("Enter %s\n", __func__);
+
+	caif_assert(sk !=3D NULL);
+	cf_sk =3D container_of(sk, struct caifsock, sk);
+
+	caif_shutdown(sock, SHUT_RDWR);
+	lock_sock(&(cf_sk->sk));
+	/* NOTE: This is how the sock->sk structure is used all over the linu=
x
+	 *       socket implementation. Since there is no locking protecting
+	 *       the sock->sk pointer, the linux socket implementation do not
+	 *       support multiple threads using the same socket descriptor,
+	 *       since if one of the threads close the socket, the other
+	 *       threads may end up accessing a pointer to NULL. See for
+	 *       instance sock_setsockopt in net/socket.c, it uses sock->sk
+	 *       without checking if its value is NULL. */
+	sock->sk =3D NULL;
+
+	/* Unlink the socket from the hunt name table. */
+
+
+	/* Trigger the pending attachs from and to the socket.  This needs to
+	 * be done before the socket starts to be released. */
+
+
+	/* Remove pending new link requests. */
+
+	/* Detach the socket from its process context by making it orphan. */
+	sock_orphan(sk);
+
+	/* Setting SHUTDOWN_MASK means that both send and receive are shutdow=
n
+	 * for the socket. */
+	sk->sk_shutdown =3D SHUTDOWN_MASK;
+
+	/* Set the socket state to closed, the TCP_CLOSE macro is used when
+	 * closing any socket. */
+	sk->sk_state =3D TCP_CLOSE;
+
+	/* Flush out this sockets receive queue. */
+	drain_queue(cf_sk);
+
+	/* Finally release the socket. */
+	STATE_IS_PENDING_DESTROY(cf_sk);
+	release_sock(&cf_sk->sk);
+	sock_put(sk);
+
+	return 0;
+
+	/* The rest of the cleanup will be handled from the
+	 * caif_sock_destructor */
+}
+static int caif_sock_ioctl(struct socket *sock,
+		       unsigned int cmd,
+		       unsigned long arg)
+
+{
+	return caif_ioctl(cmd, arg);
+}
+
+static struct proto_ops caif_ops =3D {
+	.family =3D PF_CAIF,
+	.owner =3D THIS_MODULE,
+	.release =3D caif_release,
+	.bind =3D sock_no_bind,
+	.connect =3D caif_connect,
+	.socketpair =3D sock_no_socketpair,
+	.accept =3D sock_no_accept,
+	.getname =3D sock_no_getname,
+	.poll =3D caif_poll,
+	.ioctl =3D caif_sock_ioctl,
+	.listen =3D sock_no_listen,
+	.shutdown =3D caif_shutdown,
+	.setsockopt =3D setsockopt,
+	.getsockopt =3D getsockopt,
+	.sendmsg =3D caif_sendmsg,
+	.recvmsg =3D caif_recvmsg,
+	.mmap =3D sock_no_mmap,
+	.sendpage =3D caif_sock_no_sendpage,
+};
+
+/* This function is called when a socket is finally destructed. */
+static void caif_sock_destructor(struct sock *sk)
+{
+	struct caifsock *cf_sk =3D NULL;
+	CAIFLOG_TRACE("Enter %s\n", __func__);
+	cf_sk =3D container_of(sk, struct caifsock, sk);
+
+	/* Error checks. */
+	caif_assert(!atomic_read(&sk->sk_wmem_alloc));
+	caif_assert(sk_unhashed(sk));
+	caif_assert(!sk->sk_socket);
+
+	if (!sock_flag(sk, SOCK_DEAD)) {
+		CAIFLOG_TRACE("Attempt to release alive caif socket: 0x%p", sk);
+		return;
+	}
+
+	lock_sock(&(cf_sk->sk));
+
+	if (STATE_IS_OPEN(cf_sk)) {
+		CAIFLOG_TRACE
+			("[%s:%d] socket is opened (cf_sk=3D%p)"
+				" file_mode =3D 0x%x\n", __func__, __LINE__,
+				cf_sk, cf_sk->file_mode);
+		release_sock(&cf_sk->sk);
+		return;
+	}
+
+	CAIFLOG_TRACE("pktq =3D %p \n", cf_sk->pktq);
+	drain_queue(cf_sk);
+	CAIFLOG_TRACE("pktq =3D %p \n", cf_sk->pktq);
+
+	cfglu_free(cf_sk->pktq);
+
+#ifdef CONFIG_DEBUG_FS
+	if (cf_sk->debugfs_device_dir !=3D NULL)
+		debugfs_remove_recursive(cf_sk->debugfs_device_dir);
+#endif
+
+	release_sock(&cf_sk->sk);
+	CAIFLOG_WARN("caif_sock_destructor: Removing socket %s\n",
+		cf_sk->name);
+	/* Decrease the global caif socket counter. */
+	atomic_dec(&caif_nr_socks);
+	return;
+}
+
+
+
+static int caif_create(struct net *net, struct socket *sock, int proto=
col)
+{
+	struct sock *sk =3D NULL;
+	struct caifsock *cf_sk =3D NULL;
+	int result =3D 0;
+
+	static struct proto prot =3D {.name =3D "PF_CAIF",
+		.owner =3D THIS_MODULE,
+		.obj_size =3D sizeof(struct caifsock),
+	};
+	prot.slab =3D caif_sk_cachep;
+	CAIFLOG_TRACE("Enter %s\n", __func__);
+
+	if (net !=3D &init_net)
+		return -EAFNOSUPPORT;
+
+
+	if (protocol < 0 || protocol >=3D CAIFPROTO_MAX)
+		return -EPROTONOSUPPORT;
+
+	/* Set the socket state to unconnected.  The socket state is really
+	 * not used at all in the net/core or socket.c but the
+	 * initialization makes sure that sock->state is not uninitialized.
+	 * An CAIF socket is always unconnected, since it is connectionless.
+	 */
+	sock->state =3D SS_UNCONNECTED;
+
+	/* Allocate the CAIF sock structure from the socket cache.  Upon
+	 * success the struct sock data structure is zeroed and thus partiall=
y
+	 * initialized. The caif specific part of the data structure is left =
as
+	 * is to avoid clearing the spid instance number.
+	 */
+
+	sk =3D sk_alloc(net, PF_CAIF, GFP_KERNEL, &prot);
+
+	BUG_ON(sk =3D=3D NULL);
+
+	cf_sk =3D container_of(sk, struct caifsock, sk);
+
+	/* Store the protocol */
+	sk->sk_protocol =3D (unsigned char) protocol;
+
+	CAIFLOG_TRACE("[%s:%d] cf_sk=3D%p \n", __func__, __LINE__, cf_sk);
+
+	spin_lock_init(&cf_sk->read_queue_len_lock);
+
+	/* Fill in some information concerning the misc socket. */
+	snprintf(cf_sk->name, sizeof(cf_sk->name), "cf_sk%d",
+		atomic_read(&caif_nr_socks));
+	snprintf(cf_sk->config.name, sizeof(cf_sk->config.name), "caifconf%d"=
,
+		atomic_read(&caif_nr_socks));
+
+
+	/* The sock->type specifies the socket type to use. The CAIF socket i=
s
+	 * a datagram in the sence that it is packet based. The reliability o=
f
+	 * the CAIF socket is not a typical SOCK_DGRAM characteristic, but
+	 * SOCK_DGRAM is close enough. */
+	switch (sock->type) {
+	case SOCK_DGRAM:
+	case SOCK_SEQPACKET:
+		/* NOTE: After this line, caif_release() will be called for
+		 *       this socket if this caif_create fails. */
+		sock->ops =3D &caif_ops;
+		break;
+	default:
+		sk_free(sk);
+		return -ESOCKTNOSUPPORT;
+	}
+
+	/* Lock in order to try to stop someone from opening the socket
+	too early. The misc socket has its own lock. We cannot take our
+	lock until misc_register() is finished, because in open() the
+	locks are taken in this order (misc first and then cf_sk).
+	So anyone managing to open the device between the misc_register
+	and the mutex_lock will get a "device not found" error. Don't
+	think it can be avoided.
+		*/
+	lock_sock(&(cf_sk->sk));
+
+	/* Initialize the nozero default sock structure data. */
+	sock_init_data(sock, sk);
+
+	sk->sk_destruct =3D caif_sock_destructor;
+
+	sk->sk_sndbuf =3D caif_sockbuf_size;
+	sk->sk_rcvbuf =3D caif_sockbuf_size;
+
+	cf_sk->pktq =3D cfpktq_create();
+	CAIFLOG_TRACE("pktq =3D %p \n", cf_sk->pktq);
+
+	if (!cf_sk->pktq) {
+		CAIFLOG_ERROR("caif_create: queue create failed.\n");
+		result =3D -ENOMEM;
+		release_sock(&cf_sk->sk);
+		goto err_failed;
+	}
+
+	cf_sk->layer.ctrlcmd =3D caif_sktflowctrl_cb;
+	SET_STATE_CLOSED(cf_sk);
+	SET_PENDING_OFF(cf_sk);
+	SET_TX_FLOW_OFF(cf_sk);
+	SET_RX_FLOW_ON(cf_sk);
+
+	/* Increase the number of sockets created. */
+	atomic_inc(&caif_nr_socks);
+
+#ifdef CONFIG_DEBUG_FS
+	if (debugfsdir !=3D NULL) {
+		cf_sk->debugfs_device_dir =3D
+		    debugfs_create_dir(cf_sk->name, debugfsdir);
+		debugfs_create_u32("conn_state", S_IRUSR | S_IWUSR,
+				cf_sk->debugfs_device_dir, &cf_sk->conn_state);
+		debugfs_create_u32("flow_state", S_IRUSR | S_IWUSR,
+				cf_sk->debugfs_device_dir, &cf_sk->flow_state);
+		debugfs_create_u32("num_open", S_IRUSR | S_IWUSR,
+				cf_sk->debugfs_device_dir,
+				(u32 *) &cf_sk->num_open);
+		debugfs_create_u32("num_close", S_IRUSR | S_IWUSR,
+				cf_sk->debugfs_device_dir,
+				(u32 *) &cf_sk->num_close);
+		debugfs_create_u32("num_init", S_IRUSR | S_IWUSR,
+				cf_sk->debugfs_device_dir,
+				(u32 *) &cf_sk->num_init);
+		debugfs_create_u32("num_init_resp", S_IRUSR | S_IWUSR,
+				cf_sk->debugfs_device_dir,
+				(u32 *) &cf_sk->num_init_resp);
+		debugfs_create_u32("num_init_fail_resp", S_IRUSR | S_IWUSR,
+				cf_sk->debugfs_device_dir,
+				(u32 *) &cf_sk->num_init_fail_resp);
+		debugfs_create_u32("num_deinit", S_IRUSR | S_IWUSR,
+				cf_sk->debugfs_device_dir,
+				(u32 *) &cf_sk->num_deinit);
+		debugfs_create_u32("num_deinit_resp", S_IRUSR | S_IWUSR,
+				cf_sk->debugfs_device_dir,
+				(u32 *) &cf_sk->num_deinit_resp);
+		debugfs_create_u32("num_remote_shutdown_ind",
+				S_IRUSR | S_IWUSR, cf_sk->debugfs_device_dir,
+				(u32 *) &cf_sk->num_remote_shutdown_ind);
+		debugfs_create_u32("num_tx_flow_off_ind", S_IRUSR | S_IWUSR,
+				cf_sk->debugfs_device_dir,
+				(u32 *) &cf_sk->num_tx_flow_off_ind);
+		debugfs_create_u32("num_tx_flow_on_ind", S_IRUSR | S_IWUSR,
+				cf_sk->debugfs_device_dir,
+				(u32 *) &cf_sk->num_tx_flow_on_ind);
+		debugfs_create_u32("num_rx_flow_off", S_IRUSR | S_IWUSR,
+				cf_sk->debugfs_device_dir,
+				(u32 *) &cf_sk->num_rx_flow_off);
+		debugfs_create_u32("num_rx_flow_on", S_IRUSR | S_IWUSR,
+				cf_sk->debugfs_device_dir,
+				(u32 *) &cf_sk->num_rx_flow_on);
+		debugfs_create_u32("read_queue_len", S_IRUSR | S_IWUSR,
+				cf_sk->debugfs_device_dir,
+				(u32 *) &cf_sk->read_queue_len);
+		debugfs_create_u32("max_caif_sockets", S_IRUSR | S_IWUSR,
+				cf_sk->debugfs_device_dir,
+				(u32 *) &max_caif_sockets);
+	}
+#endif
+	CAIFLOG_EXIT("");
+	release_sock(&cf_sk->sk);
+	return 0;
+err_failed:
+	sk_free(sk);
+	CAIFLOG_EXIT("");
+	return result;
+}
+
+
+static struct net_proto_family caif_family_ops =3D {
+	.family =3D PF_CAIF,
+	.create =3D caif_create,
+	.owner =3D THIS_MODULE,
+};
+
+int af_caif_init(void)
+{
+	int err;
+	CAIFLOG_TRACE("Enter %s\n", __func__);
+#ifdef CAIF_USE_CACHE
+	caif_sk_cachep =3D kmem_cache_create_compat("caifsock",
+						  sizeof(struct caifsock) +
+						  (sizeof(uint32_t) *
+						   caif_max_links), 0,
+						  SLAB_HWCACHE_ALIGN, NULL,
+						  NULL);
+	if (!caif_sk_cachep) {
+		CAIFLOG_EXIT("");
+		return -ENOMEM;
+	}
+#endif
+	err =3D sock_register(&caif_family_ops);
+
+	if (err !=3D 0) {
+#ifdef CAIF_USE_CACHE
+		kmem_cache_destroy(caif_sk_cachep);
+#endif
+		CAIFLOG_EXIT("");
+		return err;
+	}
+
+	return 0;
+}
+
+static int __init caif_sktinit_module(void)
+{
+	int stat;
+	CAIFLOG_TRACE("Enter %s\n", __func__);
+	CAIFLOG_TRACE("\nCompiled:%s:%s\n", __DATE__, __TIME__);
+
+#ifdef CONFIG_DEBUG_FS
+	debugfsdir =3D debugfs_create_dir("chnl_skt", NULL);
+#endif
+
+	stat =3D af_caif_init();
+	if (stat) {
+		CAIFLOG_ERROR("Failed to initialize CAIF socket layer.");
+		return stat;
+	}
+	return 0;
+}
+
+static void __exit caif_sktexit_module(void)
+{
+	CAIFLOG_TRACE("Enter %s\n", __func__);
+
+	sock_unregister(PF_CAIF);
+
+	/* Destroy the CAIF socket cache. */
+#ifdef CAIF_USE_CACHE
+	kmem_cache_destroy(caif_sk_cachep);
+#endif
+
+#ifdef CONFIG_DEBUG_FS
+	if (debugfsdir !=3D NULL)
+		debugfs_remove_recursive(debugfsdir);
+#endif
+
+	CAIFLOG_EXIT("");
+}
+
+module_init(caif_sktinit_module);
+module_exit(caif_sktexit_module);
+
diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
new file mode 100644
index 0000000..fbc8a64
--- /dev/null
+++ b/net/caif/chnl_net.c
@@ -0,0 +1,655 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Daniel Martensson / Daniel.Martensson@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/version.h>
+#include <linux/fs.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/if_ether.h>
+#include <linux/moduleparam.h>
+#include <linux/ip.h>
+#include <linux/sched.h>
+#include <linux/sockios.h>
+
+/* CAIF header files. */
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfcnfg.h>
+#include <net/caif/generic/cfpkt.h>
+#include <net/caif/caif_chr.h>
+#include <net/caif/caif_log.h>
+
+/*NetLink Header files*/
+#include <net/rtnetlink.h>
+#include <linux/caif/if_caif.h>
+
+#define CAIF_CONNECT_TIMEOUT 30
+#define SIZE_MTU 1500
+#define SIZE_MTU_MAX 4080
+#define SIZE_MTU_MIN 68
+
+static LIST_HEAD(chnl_net_list);
+static spinlock_t list_lock;
+
+MODULE_LICENSE("GPL");
+
+struct chnl_net {
+	struct layer chnl;
+	struct net_device_stats stats;
+	spinlock_t lock;
+	struct caif_channel_config config;
+	struct list_head list_field;
+	struct net_device *netdev;
+	char name[256];
+	wait_queue_head_t netmgmt_wq;
+	/* Flow status to remember and control the transmission. */
+	bool flowenabled;
+};
+
+
+static struct chnl_net *find_device(char *name, bool remove_from_list)
+{
+	struct list_head *list_node;
+	struct list_head *n;
+	struct chnl_net *dev =3D NULL;
+	struct chnl_net *tmp;
+	CAIFLOG_ENTER("");
+	spin_lock(&list_lock);
+	CAIFLOG_TRACE("[%s:%d] start looping \n", __func__,
+		__LINE__);
+	list_for_each_safe(list_node, n, &chnl_net_list) {
+		tmp =3D
+			list_entry(list_node, struct chnl_net, list_field);
+		/* Find from name. */
+		if (name) {
+			if (!strncmp(tmp->name, name, sizeof(tmp->name)))
+				dev =3D tmp;
+		} else
+			/* Get the first element if name is not specified. */
+			dev =3D tmp;
+		if (dev) {
+			CAIFLOG_TRACE("[%s:%d] match %s \n",
+				__func__, __LINE__,  name);
+			if (remove_from_list)
+				list_del(list_node);
+			break;
+		}
+	}
+	spin_unlock(&list_lock);
+	return dev;
+}
+
+static int chnl_recv_cb(struct layer *layr, struct cfpkt *pkt)
+{
+	struct sk_buff *skb;
+	struct caif_packet_funcs f;
+	struct chnl_net *priv  =3D NULL;
+	int pktlen;
+
+#ifdef CAIF_USE_SKB
+#else
+	int actual_len;
+#endif
+	int err =3D 0;
+
+	priv =3D container_of(layr, struct chnl_net, chnl);
+
+	if (!priv) {
+		CAIFLOG_TRACE("chnl_recv_cb: netdev container not found\n");
+		return -EINVAL;
+	}
+
+	/* Get CAIF packet functions. */
+	f =3D cfcnfg_get_packet_funcs();
+
+	/* Get length of CAIF packet. */
+	pktlen =3D f.cfpkt_getlen(pkt);
+
+#ifdef CAIF_USE_SKB
+	skb =3D (struct sk_buff *) f.cfpkt_tonative(pkt);
+#else
+	skb =3D dev_alloc_skb(pktlen);
+
+	if (!skb) {
+		CAIFLOG_TRACE("chnl_recv_cb: dev_alloc_skb failed.\n");
+		/* Update statistics. */
+		priv->netdev->stats.rx_dropped++;
+		err =3D -ENOMEM;
+		goto err_alloc_skb;
+	}
+
+	/* Extract data from the caif packet and copy it to the SKB. */
+	f.cfpkt_extract(pkt, skb_put(skb, pktlen), pktlen, &actual_len);
+#endif
+	/* Pass some minimum information and
+	 * send the packet to the net stack.
+	 */
+	skb->dev =3D priv->netdev;
+	skb->protocol =3D htons(ETH_P_IP);
+
+	if (priv->config.type =3D=3D CAIF_CHTY_DATAGRAM_LOOP) {
+		/* We change the header, so the checksum is corrupted. */
+		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
+	} else {
+		skb->ip_summed =3D CHECKSUM_COMPLETE;
+	}
+
+	/* FIXME: Drivers should call this in tasklet context. */
+	if (in_interrupt())
+		netif_rx(skb);
+	else
+		netif_rx_ni(skb);
+
+	/* Update statistics. */
+	priv->netdev->stats.rx_packets++;
+	priv->netdev->stats.rx_bytes +=3D pktlen;
+
+#ifdef CAIF_USE_SKB
+#else
+err_alloc_skb:
+	f.cfpkt_destroy(pkt);
+#endif
+	return err;
+}
+
+static void chnl_flowctrl_cb(struct layer *layr, enum caif_ctrlcmd flo=
w,
+				int phyid)
+{
+	struct chnl_net *priv  =3D NULL;
+	CAIFLOG_TRACE("NET flowctrl func called flow: %s.\n",
+		flow =3D=3D CAIF_CTRLCMD_FLOW_ON_IND ? "ON" :
+		flow =3D=3D CAIF_CTRLCMD_INIT_RSP ? "INIT" :
+		flow =3D=3D CAIF_CTRLCMD_FLOW_OFF_IND ? "OFF" :
+		flow =3D=3D CAIF_CTRLCMD_DEINIT_RSP ? "CLOSE/DEINIT" :
+		flow =3D=3D CAIF_CTRLCMD_INIT_FAIL_RSP ? "OPEN_FAIL" :
+		flow =3D=3D CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND ?
+		 "REMOTE_SHUTDOWN" : "UKNOWN CTRL COMMAND");
+
+	priv =3D container_of(layr, struct chnl_net, chnl);
+
+	switch (flow) {
+	case CAIF_CTRLCMD_FLOW_OFF_IND:
+	case CAIF_CTRLCMD_DEINIT_RSP:
+	case CAIF_CTRLCMD_INIT_FAIL_RSP:
+	case CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND:
+		priv->flowenabled =3D false;
+		netif_tx_disable(priv->netdev);
+		wake_up_interruptible(&priv->netmgmt_wq);
+	break;
+	case CAIF_CTRLCMD_FLOW_ON_IND:
+	case CAIF_CTRLCMD_INIT_RSP:
+		priv->flowenabled =3D true;
+		netif_wake_queue(priv->netdev);
+		wake_up_interruptible(&priv->netmgmt_wq);
+	break;
+	default:
+		break;
+	}
+}
+
+static int chnl_net_hard_start_xmit(struct sk_buff *skb, struct net_de=
vice *dev)
+{
+	struct chnl_net *priv;
+	struct cfpkt *pkt =3D NULL;
+	int len;
+	struct caif_packet_funcs f;
+	int result =3D -1;
+
+	/* Get our private data. */
+	priv =3D (struct chnl_net *)netdev_priv(dev);
+	if (!priv) {
+		CAIFLOG_TRACE("chnl_write: priv not found\n");
+#ifndef CAIF_USE_SKB
+			goto err_cfpkt_create;
+#else
+			return -ENOSPC;
+#endif
+	}
+
+	if (skb->len > priv->netdev->mtu) {
+		CAIFLOG_TRACE("chnl_write ERR:"
+			" Size of skb packet exceeded size of set MTU\n");
+#ifndef CAIF_USE_SKB
+			goto err_cfpkt_create;
+#else
+			return -ENOSPC;
+#endif
+	}
+
+	if (!priv->flowenabled) {
+#ifndef CAIF_USE_SKB
+			dev_kfree_skb(skb);
+#endif
+		CAIFLOG_TRACE("Dropping packets Flow OFF\n");
+		return NETDEV_TX_BUSY;
+	}
+
+	if (priv->config.type =3D=3D CAIF_CHTY_DATAGRAM_LOOP) {
+		struct iphdr *hdr;
+		__be32 swap;
+		/* Retrieve IP header. */
+		hdr =3D ip_hdr(skb);
+		/* Change source and destination address. */
+		swap =3D hdr->saddr;
+		hdr->saddr =3D hdr->daddr;
+		hdr->daddr =3D swap;
+	}
+	/* Store original SKB length. */
+	len =3D skb->len;
+
+	/* Get CAIF packet functions. */
+	f =3D cfcnfg_get_packet_funcs();
+
+#ifdef CAIF_USE_SKB
+	pkt =3D f.cfpkt_fromnative(CAIF_DIR_OUT, (void *) skb);
+#else
+	/* Create a CAIF packet based on the SKB. */
+	pkt =3D f.cfpkt_create_xmit_pkt(skb->data, skb->len);
+	if (!pkt) {
+		CAIFLOG_TRACE("chnl_write: cfpkt_create failed.\n");
+		goto err_cfpkt_create;
+	}
+#endif
+
+	/* Send the packet down the stack. */
+	result =3D priv->chnl.dn->transmit(priv->chnl.dn, NULL, pkt);
+	if (result) {
+		if (result =3D=3D CFGLU_ERETRY)
+			result =3D NETDEV_TX_BUSY;
+
+#ifndef CAIF_USE_SKB
+		f.cfpkt_destroy(pkt);
+#endif
+		return result;
+	}
+
+	/* Update statistics. */
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes +=3D len;
+
+#ifndef CAIF_USE_SKB
+	dev_kfree_skb(skb);
+#endif
+	return NETDEV_TX_OK;
+
+#ifndef CAIF_USE_SKB
+err_cfpkt_create:
+	dev_kfree_skb(skb);
+	return -ENOSPC;
+#endif
+}
+
+
+static int chnl_net_open(struct net_device *dev)
+{
+	struct chnl_net *priv =3D NULL;
+	int result =3D -1;
+
+	CAIFLOG_ENTER("chnl_net_open:\n");
+	priv =3D (struct chnl_net *)netdev_priv(dev);
+	CAIFLOG_TRACE("chnl_net_open dev name: %s\n", priv->name);
+
+	if (!priv) {
+		CAIFLOG_TRACE("chnl_net_open: no priv\n");
+		return -ENODEV;
+	}
+	result =3D caifdev_adapt_register(&priv->config, &priv->chnl);
+	if (result !=3D 0) {
+		CAIFLOG_TRACE("chnl_net_open: err: "
+			      "Unable to register and open device, Err:%d\n",
+			       result);
+		return -ENODEV;
+	}
+	result =3D wait_event_interruptible(priv->netmgmt_wq, priv->flowenabl=
ed);
+
+	if (result =3D=3D -ERESTARTSYS) {
+		CAIFLOG_TRACE
+		   ("chnl_net_open: "
+		     "wait_event_interruptible woken by a signal\n");
+		return -ERESTARTSYS;
+	} else
+		CAIFLOG_TRACE("chnl_net_open: Flow on recieved\n");
+
+
+	CAIFLOG_EXIT("chnl_net_open:\n");
+	return 0;
+}
+
+static int chnl_net_stop(struct net_device *dev)
+{
+	struct chnl_net *priv;
+	int result =3D -1;
+	CAIFLOG_ENTER("chnl_net_stop:\n");
+	CAIFLOG_TRACE("chnl_net_stop: %s \n", dev->name);
+	priv =3D (struct chnl_net *)netdev_priv(dev);
+
+	result =3D caifdev_adapt_unregister(&priv->chnl);
+	if (result !=3D 0) {
+		CAIFLOG_TRACE("chnl_net_stop: err: "
+			      "Unable to STOP device, Err:%d\n", result);
+		return -EBUSY;
+	}
+	result =3D wait_event_interruptible(priv->netmgmt_wq,
+					  !priv->flowenabled);
+
+	if (result =3D=3D -ERESTARTSYS) {
+		CAIFLOG_TRACE
+		    ("chnl_net_stop: "
+		     "wait_event_interruptible woken by signal,"
+		     " signal_pending(current) =3D %d\n",
+		     signal_pending(current));
+	} else {
+		CAIFLOG_TRACE("[%s:%d] chnl_net_stop: DISCONNECT RECEIVED\n",
+			      __func__, __LINE__);
+	}
+
+	CAIFLOG_EXIT("chnl_net_stop:\n");
+	return 0;
+}
+#if (LINUX_VERSION_CODE > KERNEL_VERSION(2, 6, 28))
+static const struct net_device_ops netdev_ops =3D {
+	.ndo_open =3D chnl_net_open,
+	.ndo_stop =3D chnl_net_stop,
+	.ndo_start_xmit =3D chnl_net_hard_start_xmit,
+};
+#endif
+
+static void chnl_net_init(struct net_device *dev)
+{
+	struct chnl_net *priv;
+
+#if (LINUX_VERSION_CODE <=3D KERNEL_VERSION(2, 6, 28))
+	CAIFLOG_ENTER("chnl_net_init:\n");
+	dev->open =3D chnl_net_open;
+	dev->stop =3D chnl_net_stop;
+	dev->hard_start_xmit =3D chnl_net_hard_start_xmit;
+#else
+
+	CAIFLOG_ENTER("chnl_net_init:\n");
+	dev->netdev_ops =3D &netdev_ops;
+#endif
+	dev->flags |=3D IFF_NOARP;
+	dev->needed_headroom =3D CAIF_NEEDED_HEADROOM;
+	dev->needed_tailroom =3D CAIF_NEEDED_TAILROOM;
+	dev->mtu =3D SIZE_MTU;
+
+	priv =3D (struct chnl_net *)netdev_priv(dev);
+	priv->chnl.receive =3D chnl_recv_cb;
+	priv->chnl.ctrlcmd =3D chnl_flowctrl_cb;
+	priv->netdev =3D dev;
+
+	strncpy(priv->config.name, dev->name, sizeof(priv->config.name));
+	priv->config.type =3D CAIF_CHTY_DATAGRAM;
+	priv->config.phy_pref =3D CFPHYPREF_HIGH_BW;
+	priv->config.priority =3D CAIF_PRIO_LOW;
+	priv->config.u.dgm.connection_id =3D -1; /* Insert illegal value */
+
+	priv->flowenabled =3D false;
+	init_waitqueue_head(&priv->netmgmt_wq);
+	strncpy(priv->name, dev->name, sizeof(priv->name));
+	netif_tx_disable(priv->netdev);
+
+	spin_lock_init(&priv->lock);
+	spin_lock(&list_lock);
+	list_add(&priv->list_field, &chnl_net_list);
+	spin_unlock(&list_lock);
+
+	CAIFLOG_EXIT("chnl_net_init:\n");
+}
+
+static int netdev_create(struct caif_channel_create_action *action)
+{
+	struct chnl_net *priv;
+	int result =3D -1;
+	struct net_device *netdevptr;
+
+	netdevptr =3D alloc_netdev(sizeof(struct chnl_net),
+				 action->name.name, chnl_net_init);
+
+	if (!netdevptr) {
+		CAIFLOG_TRACE("chnl: can't allocate netdev.\n");
+		return	-ENODEV;
+	}
+
+	priv =3D (struct chnl_net *)netdev_priv(netdevptr);
+	priv->config =3D action->config;
+
+	result =3D register_netdev(priv->netdev);
+	if (result < 0) {
+		CAIFLOG_TRACE("chnl: err: %d, can't register netdev.\n",
+			      result);
+		free_netdev(priv->netdev);
+		return	-ENODEV;
+	}
+	CAIFLOG_TRACE("netdev_create: Created channel: %s\n", priv->name);
+	/* Add the device to the list */
+	return 0;
+}
+
+static int delete_device(struct chnl_net *dev)
+{
+	CAIFLOG_TRACE("delete_device: Removing Device: %s\n", dev->name);
+	if (dev->netdev) {
+		unregister_netdev(dev->netdev);
+		free_netdev(dev->netdev);
+	}
+	return 0;
+}
+
+static int netdev_remove(char *name)
+{
+	struct chnl_net *dev =3D NULL;
+	/* Find device from name. */
+	dev =3D find_device(name, true);
+	if (!dev)
+		return -EBADF;
+	else
+		if (delete_device(dev) !=3D 0)
+			return -EBUSY;
+	return 0;
+}
+
+static int netdev_mgmt(int action, union caif_action *param)
+{
+	switch (action) {
+	case CAIF_ACT_CREATE_DEVICE:
+		return netdev_create(&param->create_channel);
+	case CAIF_ACT_DELETE_DEVICE:
+		return netdev_remove(param->delete_channel.name);
+	default:
+		return -EINVAL;
+	}
+}
+
+static int ipcaif_fill_info(struct sk_buff *skb, const struct net_devi=
ce *dev)
+{
+	struct chnl_net *priv;
+	u8 loop;
+	priv =3D (struct chnl_net *)netdev_priv(dev);
+	NLA_PUT_U32(skb, IFLA_CAIF_IPV4_CONNID,
+		    priv->config.u.dgm.connection_id);
+	NLA_PUT_U32(skb, IFLA_CAIF_IPV6_CONNID,
+		    priv->config.u.dgm.connection_id);
+	loop =3D priv->config.type =3D=3D CAIF_CHTY_DATAGRAM_LOOP;
+	NLA_PUT_U8(skb, IFLA_CAIF_LOOPBACK, loop);
+
+
+	return 0;
+nla_put_failure:
+	return -EMSGSIZE;
+
+}
+
+static void caif_netlink_parms(struct nlattr *data[],
+				struct caif_channel_config *parms)
+{
+	if (!data) {
+		caif_assert("caif_netlink_parms():No params data found\n");
+		return;
+	}
+	if (data[IFLA_CAIF_IPV4_CONNID])
+		parms->u.dgm.connection_id =3D
+			nla_get_u32(data[IFLA_CAIF_IPV4_CONNID]);
+	if (data[IFLA_CAIF_IPV6_CONNID])
+		parms->u.dgm.connection_id =3D
+			nla_get_u32(data[IFLA_CAIF_IPV6_CONNID]);
+	if (data[IFLA_CAIF_LOOPBACK]) {
+		if (nla_get_u8(data[IFLA_CAIF_LOOPBACK]))
+			parms->type =3D CAIF_CHTY_DATAGRAM_LOOP;
+		else
+			parms->type =3D CAIF_CHTY_DATAGRAM;
+	}
+}
+
+static int ipcaif_newlink(struct net_device *dev, struct nlattr *tb[],
+			struct nlattr *data[])
+{
+	int err;
+	struct chnl_net *caifdev;
+	caifdev =3D netdev_priv(dev);
+	caif_netlink_parms(data, &caifdev->config);
+	err =3D register_netdevice(dev);
+	if (err) {
+		caif_assert("ipcaif_newlink(): Device Reg. failed\n");
+		goto out;
+	}
+	dev_hold(dev);
+out:
+	return err;
+}
+
+static int ipcaif_changelink(struct net_device *dev, struct nlattr *tb=
[],
+				struct nlattr *data[])
+{
+	struct chnl_net *caifdev;
+	caifdev =3D netdev_priv(dev);
+	caif_netlink_parms(data, &caifdev->config);
+	netdev_state_change(dev);
+	return 0;
+}
+
+static void ipcaif_dellink(struct net_device *dev)
+{
+	unregister_netdevice(dev);
+	dev_put(dev);
+}
+
+static size_t ipcaif_get_size(const struct net_device *dev)
+{
+	return
+		/* IFLA_CAIF_IPV4_CONNID */
+		nla_total_size(4) +
+		/* IFLA_CAIF_IPV6_CONNID */
+		nla_total_size(4) +
+		/* IFLA_CAIF_LOOPBACK */
+		nla_total_size(2) +
+		0;
+}
+
+static const struct nla_policy caif_policy[IFLA_CAIF_MAX + 1] =3D {
+	[IFLA_CAIF_IPV4_CONNID]       =3D { .type =3D NLA_U32 },
+	[IFLA_CAIF_IPV6_CONNID]       =3D { .type =3D NLA_U32 },
+	[IFLA_CAIF_LOOPBACK]          =3D { .type =3D NLA_U8 }
+};
+
+
+static struct rtnl_link_ops ipcaif_link_ops __read_mostly =3D {
+	.kind           =3D "caif",
+	.priv_size      =3D (size_t)sizeof(struct chnl_net),
+	.setup          =3D chnl_net_init,
+	.maxtype        =3D IFLA_CAIF_MAX,
+	.policy         =3D caif_policy,
+	.newlink        =3D ipcaif_newlink,
+	.changelink	=3D ipcaif_changelink,
+	.dellink     	=3D ipcaif_dellink,
+	.get_size       =3D ipcaif_get_size,
+	.fill_info      =3D ipcaif_fill_info,
+
+};
+
+int chnl_net_ioctl(unsigned int cmd, unsigned long arg)
+{
+	struct chnl_net *priv;
+	int result =3D -1;
+	struct net_device *netdevptr;
+	int ret;
+	struct ifreq ifreq;
+	struct ifcaif_param param;
+	printk(KERN_INFO "Enter %s %d\n", __func__, cmd);
+
+	if (copy_from_user(&ifreq, (const void *)arg, sizeof(ifreq)))
+		return -EFAULT;
+
+	if (cmd !=3D SIOCCAIFNETNEW)
+		return -ENOIOCTLCMD;
+
+	if (ifreq.ifr_ifru.ifru_data !=3D NULL) {
+		ret =3D copy_from_user(&param,
+				   ifreq.ifr_ifru.ifru_data,
+				   sizeof(param));
+		if (ret)
+			return -EFAULT;
+		ifreq.ifr_ifru.ifru_data =3D &param;
+	}
+
+
+	CAIFLOG_TRACE("Allocte netdev: %s\n", ifreq.ifr_name);
+	netdevptr =3D alloc_netdev(sizeof(struct chnl_net),
+				 ifreq.ifr_name, chnl_net_init);
+
+	if (!netdevptr)
+		return	-ENODEV;
+
+	priv =3D (struct chnl_net *)netdev_priv(netdevptr);
+
+	priv->config.u.dgm.connection_id =3D param.ipv4_connid;
+	if (param.loop)
+		priv->config.type =3D CAIF_CHTY_DATAGRAM_LOOP;
+	else
+		priv->config.type =3D CAIF_CHTY_DATAGRAM;
+
+	result =3D register_netdev(priv->netdev);
+
+	if (result < 0) {
+		CAIFLOG_TRACE("chnl: err: %d, can't register netdev.\n",
+			      result);
+		free_netdev(priv->netdev);
+		return	-ENODEV;
+	}
+	CAIFLOG_TRACE("Created channel: %s\n", priv->name);
+	/* Add the device to the list */
+	return 0;
+
+};
+
+int chnl_init_module(void)
+{
+	int err =3D -1;
+	caif_register_netdev(netdev_mgmt);
+	caif_register_ioctl(chnl_net_ioctl);
+	err =3D rtnl_link_register(&ipcaif_link_ops);
+	if (err < 0) {
+		CAIFLOG_ENTER("chnl_init_module: rtnl_link_register failed\n");
+		rtnl_link_unregister(&ipcaif_link_ops);
+		return err;
+	}
+	return 0;
+}
+
+void chnl_exit_module(void)
+{
+	struct chnl_net *dev =3D NULL;
+
+	/* Find_device with NULL removes the first
+	 * element from the list and updates the list.
+	 */
+	while ((dev =3D find_device(NULL, true)) !=3D NULL)
+		delete_device(dev);
+	caif_unregister_netdev();
+}
+
+module_init(chnl_init_module);
+module_exit(chnl_exit_module);
--=20
1.6.2.2.1669.g7eaf8

