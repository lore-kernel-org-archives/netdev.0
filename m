From: Sebastian.Poehn@Belden.com
Subject: [PATCH 1/3] RFC gianfar: add rx_ntuple feature
Date: Tue, 10 May 2011 08:53:46 -0400
Message-ID: <OF8DC44D74.14E3752A-ON8525788C.0046D726-8525788C.0046D72B@BeldenCDT.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.belden.com ([12.161.118.90]:47957 "EHLO mx1.belden.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751146Ab1EJMxx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 08:53:53 -0400
In-Reply-To: 
References: 
MIME-Version: 1.0
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patches created against net-next-2.6!

This  series implements the set_rx_ntuple feature for ethtool. Code is =
well  tested and should be stable. Some code rework and better integrat=
ion  into gianfar_ethtool.c have to been done! Note that all rx flow ha=
shing  stuff on hardware will be overwritten!

This part extends some hardware bit-flags and adds some data structures=
 for ntuple conversion and storage.

--- gianfar.h.orig=A0=A0=A0 2011-05-10 11:26:43.113744000 +0200
+++ gianfar.h=A0=A0=A0 2011-05-10 12:59:15.301744599 +0200
@@ -168,6 +168,7 @@ extern const char gfar_driver_version[];
=A0#define MACCFG2_LENGTHCHECK=A0=A0=A0 0x00000010
=A0#define MACCFG2_MPEN=A0=A0=A0 =A0=A0=A0 0x00000008
=A0
+#define ECNTRL_FIFM=A0=A0=A0 =A0=A0=A0 0x00008000
=A0#define ECNTRL_INIT_SETTINGS=A0=A0=A0 0x00001000
=A0#define ECNTRL_TBI_MODE=A0=A0=A0=A0=A0=A0=A0=A0 0x00000020
=A0#define ECNTRL_REDUCED_MODE=A0=A0=A0 0x00000010
@@ -271,6 +272,7 @@ extern const char gfar_driver_version[];
=A0#define RCTRL_TUCSEN=A0=A0=A0 =A0=A0=A0 0x00000100
=A0#define RCTRL_PRSDEP_MASK=A0=A0=A0 0x000000c0
=A0#define RCTRL_PRSDEP_INIT=A0=A0=A0 0x000000c0
+#define RCTRL_PRSFM=A0=A0=A0 =A0=A0=A0 0x00000020
=A0#define RCTRL_PROM=A0=A0=A0 =A0=A0=A0 0x00000008
=A0#define RCTRL_EMEN=A0=A0=A0 =A0=A0=A0 0x00000002
=A0#define RCTRL_REQ_PARSER=A0=A0=A0 (RCTRL_VLEX | RCTRL_IPCSEN | \
@@ -870,6 +872,7 @@ struct gfar {
=A0#define FSL_GIANFAR_DEV_HAS_BD_STASHING=A0=A0=A0 =A0=A0=A0 0x0000020=
0
=A0#define FSL_GIANFAR_DEV_HAS_BUF_STASHING=A0=A0=A0 0x00000400
=A0#define FSL_GIANFAR_DEV_HAS_TIMER=A0=A0=A0 =A0=A0=A0 0x00000800
+#define FSL_GIANFAR_DEV_HAS_RX_FILER=A0=A0=A0 =A0=A0=A0 0x00001000
=A0
=A0#if (MAXGROUPS =3D=3D 2)
=A0#define DEFAULT_MAPPING =A0=A0=A0 0xAA
@@ -1140,6 +1143,16 @@ static inline void gfar_write_filer(stru
=A0=A0=A0=A0 gfar_write(&regs->rqfpr, fpr);
=A0}
=A0
+static inline void gfar_read_filer(struct gfar_private *priv,
+=A0=A0=A0 =A0=A0=A0 unsigned int far, unsigned int *fcr, unsigned int =
*fpr)
+{
+=A0=A0=A0 struct gfar __iomem *regs =3D priv->gfargrp[0].regs;
+
+=A0=A0=A0 gfar_write(&regs->rqfar, far);
+=A0=A0=A0 *fcr =3D gfar_read(&regs->rqfcr);
+=A0=A0=A0 *fpr =3D gfar_read(&regs->rqfpr);
+}
+
=A0extern void lock_rx_qs(struct gfar_private *priv);
=A0extern void lock_tx_qs(struct gfar_private *priv);
=A0extern void unlock_rx_qs(struct gfar_private *priv);
@@ -1157,4 +1170,39 @@ int gfar_set_features(struct net_device=20
=A0
=A0extern const struct ethtool_ops gfar_ethtool_ops;
=A0
+#define ESWFULL 160
+#define EHWFULL 161
+#define EOUTOFRANGE 162
+#define PRINT_MAX 100
+#define MAX_FILER_CACHE_IDX (2*(MAX_FILER_IDX))
+
+extern struct interf *queue;
+
+struct and_entry {
+=A0=A0=A0 unsigned int mask; /*The mask value which is valid for a blo=
ck with*/
+=A0=A0=A0 unsigned int start; /*start*/
+=A0=A0=A0 unsigned int end; /*till end*/
+=A0=A0=A0 unsigned int block; /*Same block values indicate depended en=
tries*/
+};
+
+/*For exactly one device*/
+struct interf {
+=A0=A0=A0 struct ethtool_rx_ntuple_list ntuple_list;
+=A0=A0=A0 char name[IFNAMSIZ]; /*Name from struct net_device*/
+};
+
+/*Table which represents a receive filer table entry */
+struct filer_entry {
+=A0=A0=A0 u32 ctrl; /*The control field from HW*/
+=A0=A0=A0 u32 prop; /*The property field from HW*/
+};
+
+/*Full table*/
+struct filer_table {
+=A0=A0=A0 struct filer_entry fe[MAX_FILER_CACHE_IDX];
+};
+
+int do_action(struct ethtool_rx_ntuple_flow_spec *flow, struct gfar_pr=
ivate *p);
+
+
=A0#endif /* __GIANFAR_H */
=A0
Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>
DISCLAIMER:

Privileged and/or Confidential information may be contained in this
message. If you are not the addressee of this message, you may not
copy, use or deliver this message to anyone. In such event, you
should destroy the message and kindly notify the sender by reply
e-mail. It is understood that opinions or conclusions that do not
relate to the official business of the company are neither given
nor endorsed by the company.

Thank You.

