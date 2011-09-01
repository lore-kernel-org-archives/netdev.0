From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH net-next] can-gw: add netlink based CAN routing
Date: Thu, 01 Sep 2011 16:23:23 +0200
Message-ID: <4E5F955B.8030806@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Michal Sojka <sojkam1@fel.cvut.cz>,
	=?windows-1252?Q?Pavel_P=ED=9Aa?= <pisa@cmp.felk.cvut.cz>,
	=?windows-1252?Q?Zdenek_Hanz=E1lek?= <hanzalek@fel.cvut.cz>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:16853 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757552Ab1IAOXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 10:23:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a CAN Gateway/Router to route (and modify) CAN frames.

It is based on the PF_CAN core infrastructure for msg filtering and msg
sending and can optionally modify routed CAN frames on the fly.
CAN frames can *only* be routed between CAN network interfaces (one hop=
).
They can be modified with AND/OR/XOR/SET operations as configured by th=
e
netlink configuration interface known e.g. from iptables. From the netl=
ink
view this can-gw implements RTM_{NEW|DEL|GET}ROUTE for PF_CAN.

The CAN specific userspace tool to manage CAN routing entries can be fo=
und in
the CAN utils http://svn.berlios.de/wsvn/socketcan/trunk/can-utils/cang=
w.c
at the SocketCAN SVN on BerliOS.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

The in-kernel CAN frame routing has been implemented to due performance
issues and has turned out to be a valuable tool in multiple projects.
It relies on the networking stack and uses the efficient PF_CAN CAN fil=
ters.
It has been analyzed and checked against -rt kernels by University of P=
rague
(DCE), where a real good performace of this approach could be shown. On=
ly
with heavy ethernet load the routing times increased - but that's netwo=
rking.
See at http://rtime.felk.cvut.cz/can/benchmark/1/ and .../benchmark/2/

Special thanks for review, feedback, bug-reports & measurements to Mich=
al
Sojka, Pavel P=ED=9Aa and Zdenek Hanz=E1lek from department of control =
engineering.

 include/linux/can/Kbuild |    1=20
 include/linux/can/gw.h   |  164 ++++++
 net/can/Kconfig          |   11=20
 net/can/Makefile         |    3=20
 net/can/gw.c             |  959 +++++++++++++++++++++++++++++++++++++
 5 files changed, 1138 insertions(+)

diff -u -r -N a/include/linux/can/gw.h b/include/linux/can/gw.h
--- a/include/linux/can/gw.h	1970-01-01 01:00:00.000000000 +0100
+++ b/include/linux/can/gw.h	2011-09-01 11:33:47.966271223 +0200
@@ -0,0 +1,164 @@
+/*
+ * linux/can/gw.h
+ *
+ * Definitions for CAN frame Gateway/Router/Bridge
+ *
+ * Author: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
+ * Copyright (c) 2011 Volkswagen Group Electronic Research
+ * All rights reserved.
+ *
+ * Send feedback to <socketcan-users@lists.berlios.de>
+ *
+ */
+
+#ifndef CAN_GW_H
+#define CAN_GW_H
+
+#include <linux/types.h>
+#include <linux/can.h>
+
+struct rtcanmsg {
+	__u8  can_family;
+	__u8  gwtype;
+	__u16 flags;
+};
+
+/* CAN gateway types */
+enum {
+	CGW_TYPE_UNSPEC,
+	CGW_TYPE_CAN_CAN,	/* CAN->CAN routing */
+	__CGW_TYPE_MAX
+};
+
+#define CGW_TYPE_MAX (__CGW_TYPE_MAX - 1)
+
+/* CAN rtnetlink attribute definitions */
+enum {
+	CGW_UNSPEC,
+	CGW_MOD_AND,	/* CAN frame modification binary AND */
+	CGW_MOD_OR,	/* CAN frame modification binary OR */
+	CGW_MOD_XOR,	/* CAN frame modification binary XOR */
+	CGW_MOD_SET,	/* CAN frame modification set alternate values */
+	CGW_CS_XOR,	/* set data[] XOR checksum into data[index] */
+	CGW_CS_CRC8,	/* set data[] CRC8 checksum into data[index] */
+	CGW_HANDLED,	/* number of handled CAN frames */
+	CGW_DROPPED,	/* number of dropped CAN frames */
+	CGW_SRC_IF,	/* ifindex of source network interface */
+	CGW_DST_IF,	/* ifindex of destination network interface */
+	CGW_FILTER,	/* specify struct can_filter on source CAN device */
+	__CGW_MAX
+};
+
+#define CGW_MAX (__CGW_MAX - 1)
+
+#define CGW_FLAGS_CAN_ECHO 0x01
+#define CGW_FLAGS_CAN_SRC_TSTAMP 0x02
+
+#define CGW_MOD_FUNCS 4 /* AND OR XOR SET */
+
+/* CAN frame elements that are affected by curr. 3 CAN frame modificat=
ions */
+#define CGW_MOD_ID	0x01
+#define CGW_MOD_DLC	0x02
+#define CGW_MOD_DATA	0x04
+
+#define CGW_FRAME_MODS 3 /* ID DLC DATA */
+
+#define MAX_MODFUNCTIONS (CGW_MOD_FUNCS * CGW_FRAME_MODS)
+
+struct cgw_frame_mod {
+	struct can_frame cf;
+	__u8 modtype;
+} __attribute__((packed));
+
+#define CGW_MODATTR_LEN sizeof(struct cgw_frame_mod)
+
+struct cgw_csum_xor {
+	__s8 from_idx;
+	__s8 to_idx;
+	__s8 result_idx;
+	__u8 init_xor_val;
+} __attribute__((packed));
+
+struct cgw_csum_crc8 {
+	__s8 from_idx;
+	__s8 to_idx;
+	__s8 result_idx;
+	__u8 init_crc_val;
+	__u8 final_xor_val;
+	__u8 crctab[256];
+	__u8 profile;
+	__u8 profile_data[20];
+} __attribute__((packed));
+
+/* length of checksum operation parameters. idx =3D index in CAN frame=
 data[] */
+#define CGW_CS_XOR_LEN  sizeof(struct cgw_csum_xor)
+#define CGW_CS_CRC8_LEN  sizeof(struct cgw_csum_crc8)
+
+/* CRC8 profiles (compute CRC for additional data elements - see below=
) */
+enum {
+	CGW_CRC8PRF_UNSPEC,
+	CGW_CRC8PRF_1U8,	/* compute one additional u8 value */
+	CGW_CRC8PRF_16U8,	/* u8 value table indexed by data[1] & 0xF */
+	CGW_CRC8PRF_SFFID_XOR,	/* (can_id & 0xFF) ^ (can_id >> 8 & 0xFF) */
+	__CGW_CRC8PRF_MAX
+};
+
+#define CGW_CRC8PRF_MAX (__CGW_CRC8PRF_MAX - 1)
+
+/*
+ * CAN rtnetlink attribute contents in detail
+ *
+ * CGW_XXX_IF (length 4 bytes):
+ * Sets an interface index for source/destination network interfaces.
+ * For the CAN->CAN gwtype the indices of _two_ CAN interfaces are man=
datory.
+ *
+ * CGW_FILTER (length 8 bytes):
+ * Sets a CAN receive filter for the gateway job specified by the
+ * struct can_filter described in include/linux/can.h
+ *
+ * CGW_MOD_XXX (length 17 bytes):
+ * Specifies a modification that's done to a received CAN frame before=
 it is
+ * send out to the destination interface.
+ *
+ * <struct can_frame> data used as operator
+ * <u8> affected CAN frame elements
+ *
+ * CGW_CS_XOR (length 4 bytes):
+ * Set a simple XOR checksum starting with an initial value into
+ * data[result-idx] using data[start-idx] .. data[end-idx]
+ *
+ * The XOR checksum is calculated like this:
+ *
+ * xor =3D init_xor_val
+ *
+ * for (i =3D from_idx .. to_idx)
+ *      xor ^=3D can_frame.data[i]
+ *
+ * can_frame.data[ result_idx ] =3D xor
+ *
+ * CGW_CS_CRC8 (length 282 bytes):
+ * Set a CRC8 value into data[result-idx] using a given 256 byte CRC8 =
table,
+ * a given initial value and a defined input data[start-idx] .. data[e=
nd-idx].
+ * Finally the result value is XOR'ed with the final_xor_val.
+ *
+ * The CRC8 checksum is calculated like this:
+ *
+ * crc =3D init_crc_val
+ *
+ * for (i =3D from_idx .. to_idx)
+ *      crc =3D crctab[ crc ^ can_frame.data[i] ]
+ *
+ * can_frame.data[ result_idx ] =3D crc ^ final_xor_val
+ *
+ * The calculated CRC may contain additional source data elements that=
 can be
+ * defined in the handling of 'checksum profiles' e.g. shown in AUTOSA=
R specs
+ * like http://www.autosar.org/download/R4.0/AUTOSAR_SWS_E2ELibrary.pd=
f
+ * E.g. the profile_data[] may contain additional u8 values (called DA=
TA_IDs)
+ * that are used depending on counter values inside the CAN frame data=
[].
+ * So far only three profiles have been implemented for illustration.
+ *
+ * Remark: In general the attribute data is a linear buffer.
+ *         Beware of sending unpacked or aligned structs!
+ */
+
+#endif
diff -u -r -N a/include/linux/can/Kbuild b/include/linux/can/Kbuild
--- a/include/linux/can/Kbuild	2011-08-31 21:28:47.515610142 +0200
+++ b/include/linux/can/Kbuild	2011-08-31 21:29:24.343608873 +0200
@@ -1,4 +1,5 @@
 header-y +=3D raw.h
 header-y +=3D bcm.h
+header-y +=3D gw.h
 header-y +=3D error.h
 header-y +=3D netlink.h
diff -u -r -N a/net/can/gw.c b/net/can/gw.c
--- a/net/can/gw.c	1970-01-01 01:00:00.000000000 +0100
+++ b/net/can/gw.c	2011-09-01 11:26:56.898284721 +0200
@@ -0,0 +1,959 @@
+/*
+ * gw.c - CAN frame Gateway/Router/Bridge with netlink interface
+ *
+ * Copyright (c) 2011 Volkswagen Group Electronic Research
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyrigh=
t
+ *    notice, this list of conditions and the following disclaimer in =
the
+ *    documentation and/or other materials provided with the distribut=
ion.
+ * 3. Neither the name of Volkswagen nor the names of its contributors
+ *    may be used to endorse or promote products derived from this sof=
tware
+ *    without specific prior written permission.
+ *
+ * Alternatively, provided that this notice is retained in full, this
+ * software may be distributed under the terms of the GNU General
+ * Public License ("GPL") version 2, in which case the provisions of t=
he
+ * GPL apply INSTEAD OF those given above.
+ *
+ * The provided data structures and external interfaces from this code
+ * are not restricted to be used by modules with a GPL compatible lice=
nse.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS F=
OR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGH=
T
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTA=
L,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF US=
E,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON A=
NY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE U=
SE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
+ * DAMAGE.
+ *
+ * Send feedback to <socketcan-users@lists.berlios.de>
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/rcupdate.h>
+#include <linux/rculist.h>
+#include <linux/net.h>
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+#include <linux/skbuff.h>
+#include <linux/can.h>
+#include <linux/can/core.h>
+#include <linux/can/gw.h>
+#include <net/rtnetlink.h>
+#include <net/net_namespace.h>
+#include <net/sock.h>
+
+#define CAN_GW_VERSION "20101209"
+static __initdata const char banner[] =3D
+	KERN_INFO "can: netlink gateway (rev " CAN_GW_VERSION ")\n";
+
+MODULE_DESCRIPTION("PF_CAN netlink gateway");
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_AUTHOR("Oliver Hartkopp <oliver.hartkopp@volkswagen.de>");
+MODULE_ALIAS("can-gw");
+
+HLIST_HEAD(cgw_list);
+static struct notifier_block notifier;
+
+static struct kmem_cache *cgw_cache __read_mostly;
+
+/* structure that contains the (on-the-fly) CAN frame modifications */
+struct cf_mod {
+	struct {
+		struct can_frame and;
+		struct can_frame or;
+		struct can_frame xor;
+		struct can_frame set;
+	} modframe;
+	struct {
+		u8 and;
+		u8 or;
+		u8 xor;
+		u8 set;
+	} modtype;
+	void (*modfunc[MAX_MODFUNCTIONS])(struct can_frame *cf,
+					  struct cf_mod *mod);
+
+	/* CAN frame checksum calculation after CAN frame modifications */
+	struct {
+		struct cgw_csum_xor xor;
+		struct cgw_csum_crc8 crc8;
+	} csum;
+	struct {
+		void (*xor)(struct can_frame *cf, struct cgw_csum_xor *xor);
+		void (*crc8)(struct can_frame *cf, struct cgw_csum_crc8 *crc8);
+	} csumfunc;
+};
+
+
+/*
+ * So far we just support CAN -> CAN routing and frame modifications.
+ *
+ * The internal can_can_gw structure contains data and attributes for
+ * a CAN -> CAN gateway job.
+ */
+struct can_can_gw {
+	struct can_filter filter;
+	int src_idx;
+	int dst_idx;
+};
+
+/* list entry for CAN gateways jobs */
+struct cgw_job {
+	struct hlist_node list;
+	struct rcu_head rcu;
+	u32 handled_frames;
+	u32 dropped_frames;
+	struct cf_mod mod;
+	union {
+		/* CAN frame data source */
+		struct net_device *dev;
+	} src;
+	union {
+		/* CAN frame data destination */
+		struct net_device *dev;
+	} dst;
+	union {
+		struct can_can_gw ccgw;
+		/* tbc */
+	};
+	u8 gwtype;
+	u16 flags;
+};
+
+/* modification functions that are invoked in the hot path in can_can_=
gw_rcv */
+
+#define MODFUNC(func, op) static void func(struct can_frame *cf, \
+					   struct cf_mod *mod) { op ; }
+
+MODFUNC(mod_and_id, cf->can_id &=3D mod->modframe.and.can_id)
+MODFUNC(mod_and_dlc, cf->can_dlc &=3D mod->modframe.and.can_dlc)
+MODFUNC(mod_and_data, *(u64 *)cf->data &=3D *(u64 *)mod->modframe.and.=
data)
+MODFUNC(mod_or_id, cf->can_id |=3D mod->modframe.or.can_id)
+MODFUNC(mod_or_dlc, cf->can_dlc |=3D mod->modframe.or.can_dlc)
+MODFUNC(mod_or_data, *(u64 *)cf->data |=3D *(u64 *)mod->modframe.or.da=
ta)
+MODFUNC(mod_xor_id, cf->can_id ^=3D mod->modframe.xor.can_id)
+MODFUNC(mod_xor_dlc, cf->can_dlc ^=3D mod->modframe.xor.can_dlc)
+MODFUNC(mod_xor_data, *(u64 *)cf->data ^=3D *(u64 *)mod->modframe.xor.=
data)
+MODFUNC(mod_set_id, cf->can_id =3D mod->modframe.set.can_id)
+MODFUNC(mod_set_dlc, cf->can_dlc =3D mod->modframe.set.can_dlc)
+MODFUNC(mod_set_data, *(u64 *)cf->data =3D *(u64 *)mod->modframe.set.d=
ata)
+
+static inline void canframecpy(struct can_frame *dst, struct can_frame=
 *src)
+{
+	/*
+	 * Copy the struct members separately to ensure that no uninitialized
+	 * data are copied in the 3 bytes hole of the struct. This is needed
+	 * to make easy compares of the data in the struct cf_mod.
+	 */
+
+	dst->can_id =3D src->can_id;
+	dst->can_dlc =3D src->can_dlc;
+	*(u64 *)dst->data =3D *(u64 *)src->data;
+}
+
+static int cgw_chk_csum_parms(s8 fr, s8 to, s8 re)
+{
+	/*
+	 * absolute dlc values 0 .. 7 =3D> 0 .. 7, e.g. data [0]
+	 * relative to received dlc -1 .. -8 :
+	 * e.g. for received dlc =3D 8
+	 * -1 =3D> index =3D 7 (data[7])
+	 * -3 =3D> index =3D 5 (data[5])
+	 * -8 =3D> index =3D 0 (data[0])
+	 */
+
+	if (fr > -9 && fr < 8 &&
+	    to > -9 && to < 8 &&
+	    re > -9 && re < 8)
+		return 0;
+	else
+		return -EINVAL;
+}
+
+static inline int calc_idx(int idx, int rx_dlc)
+{
+	if (idx < 0)
+		return rx_dlc + idx;
+	else
+		return idx;
+}
+
+static void cgw_csum_xor_rel(struct can_frame *cf, struct cgw_csum_xor=
 *xor)
+{
+	int from =3D calc_idx(xor->from_idx, cf->can_dlc);
+	int to =3D calc_idx(xor->to_idx, cf->can_dlc);
+	int res =3D calc_idx(xor->result_idx, cf->can_dlc);
+	u8 val =3D xor->init_xor_val;
+	int i;
+
+	if (from < 0 || to < 0 || res < 0)
+		return;
+
+	if (from <=3D to) {
+		for (i =3D from; i <=3D to; i++)
+			val ^=3D cf->data[i];
+	} else {
+		for (i =3D from; i >=3D to; i--)
+			val ^=3D cf->data[i];
+	}
+
+	cf->data[res] =3D val;
+}
+
+static void cgw_csum_xor_pos(struct can_frame *cf, struct cgw_csum_xor=
 *xor)
+{
+	u8 val =3D xor->init_xor_val;
+	int i;
+
+	for (i =3D xor->from_idx; i <=3D xor->to_idx; i++)
+		val ^=3D cf->data[i];
+
+	cf->data[xor->result_idx] =3D val;
+}
+
+static void cgw_csum_xor_neg(struct can_frame *cf, struct cgw_csum_xor=
 *xor)
+{
+	u8 val =3D xor->init_xor_val;
+	int i;
+
+	for (i =3D xor->from_idx; i >=3D xor->to_idx; i--)
+		val ^=3D cf->data[i];
+
+	cf->data[xor->result_idx] =3D val;
+}
+
+static void cgw_csum_crc8_rel(struct can_frame *cf, struct cgw_csum_cr=
c8 *crc8)
+{
+	int from =3D calc_idx(crc8->from_idx, cf->can_dlc);
+	int to =3D calc_idx(crc8->to_idx, cf->can_dlc);
+	int res =3D calc_idx(crc8->result_idx, cf->can_dlc);
+	u8 crc =3D crc8->init_crc_val;
+	int i;
+
+	if (from < 0 || to < 0 || res < 0)
+		return;
+
+	if (from <=3D to) {
+		for (i =3D crc8->from_idx; i <=3D crc8->to_idx; i++)
+			crc =3D crc8->crctab[crc^cf->data[i]];
+	} else {
+		for (i =3D crc8->from_idx; i >=3D crc8->to_idx; i--)
+			crc =3D crc8->crctab[crc^cf->data[i]];
+	}
+
+	switch (crc8->profile) {
+
+	case CGW_CRC8PRF_1U8:
+		crc =3D crc8->crctab[crc^crc8->profile_data[0]];
+		break;
+
+	case  CGW_CRC8PRF_16U8:
+		crc =3D crc8->crctab[crc^crc8->profile_data[cf->data[1] & 0xF]];
+		break;
+
+	case CGW_CRC8PRF_SFFID_XOR:
+		crc =3D crc8->crctab[crc^(cf->can_id & 0xFF)^
+				   (cf->can_id >> 8 & 0xFF)];
+		break;
+
+	}
+
+	cf->data[crc8->result_idx] =3D crc^crc8->final_xor_val;
+}
+
+static void cgw_csum_crc8_pos(struct can_frame *cf, struct cgw_csum_cr=
c8 *crc8)
+{
+	u8 crc =3D crc8->init_crc_val;
+	int i;
+
+	for (i =3D crc8->from_idx; i <=3D crc8->to_idx; i++)
+		crc =3D crc8->crctab[crc^cf->data[i]];
+
+	switch (crc8->profile) {
+
+	case CGW_CRC8PRF_1U8:
+		crc =3D crc8->crctab[crc^crc8->profile_data[0]];
+		break;
+
+	case  CGW_CRC8PRF_16U8:
+		crc =3D crc8->crctab[crc^crc8->profile_data[cf->data[1] & 0xF]];
+		break;
+
+	case CGW_CRC8PRF_SFFID_XOR:
+		crc =3D crc8->crctab[crc^(cf->can_id & 0xFF)^
+				   (cf->can_id >> 8 & 0xFF)];
+		break;
+	}
+
+	cf->data[crc8->result_idx] =3D crc^crc8->final_xor_val;
+}
+
+static void cgw_csum_crc8_neg(struct can_frame *cf, struct cgw_csum_cr=
c8 *crc8)
+{
+	u8 crc =3D crc8->init_crc_val;
+	int i;
+
+	for (i =3D crc8->from_idx; i >=3D crc8->to_idx; i--)
+		crc =3D crc8->crctab[crc^cf->data[i]];
+
+	switch (crc8->profile) {
+
+	case CGW_CRC8PRF_1U8:
+		crc =3D crc8->crctab[crc^crc8->profile_data[0]];
+		break;
+
+	case  CGW_CRC8PRF_16U8:
+		crc =3D crc8->crctab[crc^crc8->profile_data[cf->data[1] & 0xF]];
+		break;
+
+	case CGW_CRC8PRF_SFFID_XOR:
+		crc =3D crc8->crctab[crc^(cf->can_id & 0xFF)^
+				   (cf->can_id >> 8 & 0xFF)];
+		break;
+	}
+
+	cf->data[crc8->result_idx] =3D crc^crc8->final_xor_val;
+}
+
+/* the receive & process & send function */
+static void can_can_gw_rcv(struct sk_buff *skb, void *data)
+{
+	struct cgw_job *gwj =3D (struct cgw_job *)data;
+	struct can_frame *cf;
+	struct sk_buff *nskb;
+	int modidx =3D 0;
+
+	/* do not handle already routed frames - see comment below */
+	if (skb_mac_header_was_set(skb))
+		return;
+
+	if (!(gwj->dst.dev->flags & IFF_UP)) {
+		gwj->dropped_frames++;
+		return;
+	}
+
+	/*
+	 * clone the given skb, which has not been done in can_rcv()
+	 *
+	 * When there is at least one modification function activated,
+	 * we need to copy the skb as we want to modify skb->data.
+	 */
+	if (gwj->mod.modfunc[0])
+		nskb =3D skb_copy(skb, GFP_ATOMIC);
+	else
+		nskb =3D skb_clone(skb, GFP_ATOMIC);
+
+	if (!nskb) {
+		gwj->dropped_frames++;
+		return;
+	}
+
+	/*
+	 * Mark routed frames by setting some mac header length which is
+	 * not relevant for the CAN frames located in the skb->data section.
+	 *
+	 * As dev->header_ops is not set in CAN netdevices no one is ever
+	 * accessing the various header offsets in the CAN skbuffs anyway.
+	 * E.g. using the packet socket to read CAN frames is still working.
+	 */
+	skb_set_mac_header(nskb, 8);
+	nskb->dev =3D gwj->dst.dev;
+
+	/* pointer to modifiable CAN frame */
+	cf =3D (struct can_frame *)nskb->data;
+
+	/* perform preprocessed modification functions if there are any */
+	while (modidx < MAX_MODFUNCTIONS && gwj->mod.modfunc[modidx])
+		(*gwj->mod.modfunc[modidx++])(cf, &gwj->mod);
+
+	/* check for checksum updates when the CAN frame has been modified */
+	if (modidx) {
+		if (gwj->mod.csumfunc.crc8)
+			(*gwj->mod.csumfunc.crc8)(cf, &gwj->mod.csum.crc8);
+
+		if (gwj->mod.csumfunc.xor)
+			(*gwj->mod.csumfunc.xor)(cf, &gwj->mod.csum.xor);
+	}
+
+	/* clear the skb timestamp if not configured the other way */
+	if (!(gwj->flags & CGW_FLAGS_CAN_SRC_TSTAMP))
+		nskb->tstamp.tv64 =3D 0;
+
+	/* send to netdevice */
+	if (can_send(nskb, gwj->flags & CGW_FLAGS_CAN_ECHO))
+		gwj->dropped_frames++;
+	else
+		gwj->handled_frames++;
+}
+
+static inline int cgw_register_filter(struct cgw_job *gwj)
+{
+	return can_rx_register(gwj->src.dev, gwj->ccgw.filter.can_id,
+			       gwj->ccgw.filter.can_mask, can_can_gw_rcv,
+			       gwj, "gw");
+}
+
+static inline void cgw_unregister_filter(struct cgw_job *gwj)
+{
+	can_rx_unregister(gwj->src.dev, gwj->ccgw.filter.can_id,
+			  gwj->ccgw.filter.can_mask, can_can_gw_rcv, gwj);
+}
+
+static int cgw_notifier(struct notifier_block *nb,
+			unsigned long msg, void *data)
+{
+	struct net_device *dev =3D (struct net_device *)data;
+
+	if (!net_eq(dev_net(dev), &init_net))
+		return NOTIFY_DONE;
+	if (dev->type !=3D ARPHRD_CAN)
+		return NOTIFY_DONE;
+
+	if (msg =3D=3D NETDEV_UNREGISTER) {
+
+		struct cgw_job *gwj =3D NULL;
+		struct hlist_node *n, *nx;
+
+		ASSERT_RTNL();
+
+		hlist_for_each_entry_safe(gwj, n, nx, &cgw_list, list) {
+
+			if (gwj->src.dev =3D=3D dev || gwj->dst.dev =3D=3D dev) {
+				hlist_del(&gwj->list);
+				cgw_unregister_filter(gwj);
+				kfree(gwj);
+			}
+		}
+	}
+
+	return NOTIFY_DONE;
+}
+
+static int cgw_put_job(struct sk_buff *skb, struct cgw_job *gwj)
+{
+	struct cgw_frame_mod mb;
+	struct rtcanmsg *rtcan;
+	struct nlmsghdr *nlh =3D nlmsg_put(skb, 0, 0, 0, sizeof(*rtcan), 0);
+	if (!nlh)
+		return -EMSGSIZE;
+
+	rtcan =3D nlmsg_data(nlh);
+	rtcan->can_family =3D AF_CAN;
+	rtcan->gwtype =3D gwj->gwtype;
+	rtcan->flags =3D gwj->flags;
+
+	/* add statistics if available */
+
+	if (gwj->handled_frames) {
+		if (nla_put_u32(skb, CGW_HANDLED, gwj->handled_frames) < 0)
+			goto cancel;
+		else
+			nlh->nlmsg_len +=3D NLA_HDRLEN + NLA_ALIGN(sizeof(u32));
+	}
+
+	if (gwj->dropped_frames) {
+		if (nla_put_u32(skb, CGW_DROPPED, gwj->dropped_frames) < 0)
+			goto cancel;
+		else
+			nlh->nlmsg_len +=3D NLA_HDRLEN + NLA_ALIGN(sizeof(u32));
+	}
+
+	/* check non default settings of attributes */
+
+	if (gwj->mod.modtype.and) {
+		memcpy(&mb.cf, &gwj->mod.modframe.and, sizeof(mb.cf));
+		mb.modtype =3D gwj->mod.modtype.and;
+		if (nla_put(skb, CGW_MOD_AND, sizeof(mb), &mb) < 0)
+			goto cancel;
+		else
+			nlh->nlmsg_len +=3D NLA_HDRLEN + NLA_ALIGN(sizeof(mb));
+	}
+
+	if (gwj->mod.modtype.or) {
+		memcpy(&mb.cf, &gwj->mod.modframe.or, sizeof(mb.cf));
+		mb.modtype =3D gwj->mod.modtype.or;
+		if (nla_put(skb, CGW_MOD_OR, sizeof(mb), &mb) < 0)
+			goto cancel;
+		else
+			nlh->nlmsg_len +=3D NLA_HDRLEN + NLA_ALIGN(sizeof(mb));
+	}
+
+	if (gwj->mod.modtype.xor) {
+		memcpy(&mb.cf, &gwj->mod.modframe.xor, sizeof(mb.cf));
+		mb.modtype =3D gwj->mod.modtype.xor;
+		if (nla_put(skb, CGW_MOD_XOR, sizeof(mb), &mb) < 0)
+			goto cancel;
+		else
+			nlh->nlmsg_len +=3D NLA_HDRLEN + NLA_ALIGN(sizeof(mb));
+	}
+
+	if (gwj->mod.modtype.set) {
+		memcpy(&mb.cf, &gwj->mod.modframe.set, sizeof(mb.cf));
+		mb.modtype =3D gwj->mod.modtype.set;
+		if (nla_put(skb, CGW_MOD_SET, sizeof(mb), &mb) < 0)
+			goto cancel;
+		else
+			nlh->nlmsg_len +=3D NLA_HDRLEN + NLA_ALIGN(sizeof(mb));
+	}
+
+	if (gwj->mod.csumfunc.crc8) {
+		if (nla_put(skb, CGW_CS_CRC8, CGW_CS_CRC8_LEN,
+			    &gwj->mod.csum.crc8) < 0)
+			goto cancel;
+		else
+			nlh->nlmsg_len +=3D NLA_HDRLEN + \
+				NLA_ALIGN(CGW_CS_CRC8_LEN);
+	}
+
+	if (gwj->mod.csumfunc.xor) {
+		if (nla_put(skb, CGW_CS_XOR, CGW_CS_XOR_LEN,
+			    &gwj->mod.csum.xor) < 0)
+			goto cancel;
+		else
+			nlh->nlmsg_len +=3D NLA_HDRLEN + \
+				NLA_ALIGN(CGW_CS_XOR_LEN);
+	}
+
+	if (gwj->gwtype =3D=3D CGW_TYPE_CAN_CAN) {
+
+		if (gwj->ccgw.filter.can_id || gwj->ccgw.filter.can_mask) {
+			if (nla_put(skb, CGW_FILTER, sizeof(struct can_filter),
+				    &gwj->ccgw.filter) < 0)
+				goto cancel;
+			else
+				nlh->nlmsg_len +=3D NLA_HDRLEN +
+					NLA_ALIGN(sizeof(struct can_filter));
+		}
+
+		if (nla_put_u32(skb, CGW_SRC_IF, gwj->ccgw.src_idx) < 0)
+			goto cancel;
+		else
+			nlh->nlmsg_len +=3D NLA_HDRLEN + NLA_ALIGN(sizeof(u32));
+
+		if (nla_put_u32(skb, CGW_DST_IF, gwj->ccgw.dst_idx) < 0)
+			goto cancel;
+		else
+			nlh->nlmsg_len +=3D NLA_HDRLEN + NLA_ALIGN(sizeof(u32));
+	}
+
+	return skb->len;
+
+cancel:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
+/* Dump information about all CAN gateway jobs, in response to RTM_GET=
ROUTE */
+static int cgw_dump_jobs(struct sk_buff *skb, struct netlink_callback =
*cb)
+{
+	struct cgw_job *gwj =3D NULL;
+	struct hlist_node *n;
+	int idx =3D 0;
+	int s_idx =3D cb->args[0];
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(gwj, n, &cgw_list, list) {
+		if (idx < s_idx)
+			goto cont;
+
+		if (cgw_put_job(skb, gwj) < 0)
+			break;
+cont:
+		idx++;
+	}
+	rcu_read_unlock();
+
+	cb->args[0] =3D idx;
+
+	return skb->len;
+}
+
+/* check for common and gwtype specific attributes */
+static int cgw_parse_attr(struct nlmsghdr *nlh, struct cf_mod *mod,
+			  u8 gwtype, void *gwtypeattr)
+{
+	struct nlattr *tb[CGW_MAX+1];
+	struct cgw_frame_mod mb;
+	int modidx =3D 0;
+	int err =3D 0;
+
+	/* initialize modification & checksum data space */
+	memset(mod, 0, sizeof(*mod));
+
+	err =3D nlmsg_parse(nlh, sizeof(struct rtcanmsg), tb, CGW_MAX, NULL);
+	if (err < 0)
+		return err;
+
+	/* check for AND/OR/XOR/SET modifications */
+
+	if (tb[CGW_MOD_AND] &&
+	    nla_len(tb[CGW_MOD_AND]) =3D=3D CGW_MODATTR_LEN) {
+		nla_memcpy(&mb, tb[CGW_MOD_AND], CGW_MODATTR_LEN);
+
+		canframecpy(&mod->modframe.and, &mb.cf);
+		mod->modtype.and =3D mb.modtype;
+
+		if (mb.modtype & CGW_MOD_ID)
+			mod->modfunc[modidx++] =3D mod_and_id;
+
+		if (mb.modtype & CGW_MOD_DLC)
+			mod->modfunc[modidx++] =3D mod_and_dlc;
+
+		if (mb.modtype & CGW_MOD_DATA)
+			mod->modfunc[modidx++] =3D mod_and_data;
+	}
+
+	if (tb[CGW_MOD_OR] &&
+	    nla_len(tb[CGW_MOD_OR]) =3D=3D CGW_MODATTR_LEN) {
+		nla_memcpy(&mb, tb[CGW_MOD_OR], CGW_MODATTR_LEN);
+
+		canframecpy(&mod->modframe.or, &mb.cf);
+		mod->modtype.or =3D mb.modtype;
+
+		if (mb.modtype & CGW_MOD_ID)
+			mod->modfunc[modidx++] =3D mod_or_id;
+
+		if (mb.modtype & CGW_MOD_DLC)
+			mod->modfunc[modidx++] =3D mod_or_dlc;
+
+		if (mb.modtype & CGW_MOD_DATA)
+			mod->modfunc[modidx++] =3D mod_or_data;
+	}
+
+	if (tb[CGW_MOD_XOR] &&
+	    nla_len(tb[CGW_MOD_XOR]) =3D=3D CGW_MODATTR_LEN) {
+		nla_memcpy(&mb, tb[CGW_MOD_XOR], CGW_MODATTR_LEN);
+
+		canframecpy(&mod->modframe.xor, &mb.cf);
+		mod->modtype.xor =3D mb.modtype;
+
+		if (mb.modtype & CGW_MOD_ID)
+			mod->modfunc[modidx++] =3D mod_xor_id;
+
+		if (mb.modtype & CGW_MOD_DLC)
+			mod->modfunc[modidx++] =3D mod_xor_dlc;
+
+		if (mb.modtype & CGW_MOD_DATA)
+			mod->modfunc[modidx++] =3D mod_xor_data;
+	}
+
+	if (tb[CGW_MOD_SET] &&
+	    nla_len(tb[CGW_MOD_SET]) =3D=3D CGW_MODATTR_LEN) {
+		nla_memcpy(&mb, tb[CGW_MOD_SET], CGW_MODATTR_LEN);
+
+		canframecpy(&mod->modframe.set, &mb.cf);
+		mod->modtype.set =3D mb.modtype;
+
+		if (mb.modtype & CGW_MOD_ID)
+			mod->modfunc[modidx++] =3D mod_set_id;
+
+		if (mb.modtype & CGW_MOD_DLC)
+			mod->modfunc[modidx++] =3D mod_set_dlc;
+
+		if (mb.modtype & CGW_MOD_DATA)
+			mod->modfunc[modidx++] =3D mod_set_data;
+	}
+
+	/* check for checksum operations after CAN frame modifications */
+	if (modidx) {
+
+		if (tb[CGW_CS_CRC8] &&
+		    nla_len(tb[CGW_CS_CRC8]) =3D=3D CGW_CS_CRC8_LEN) {
+
+			struct cgw_csum_crc8 *c =3D (struct cgw_csum_crc8 *)\
+				nla_data(tb[CGW_CS_CRC8]);
+
+			err =3D cgw_chk_csum_parms(c->from_idx, c->to_idx,
+						 c->result_idx);
+			if (err)
+				return err;
+
+			nla_memcpy(&mod->csum.crc8, tb[CGW_CS_CRC8],
+				   CGW_CS_CRC8_LEN);
+
+			/*
+			 * select dedicated processing function to reduce
+			 * runtime operations in receive hot path.
+			 */
+			if (c->from_idx < 0 || c->to_idx < 0 ||
+			    c->result_idx < 0)
+				mod->csumfunc.crc8 =3D cgw_csum_crc8_rel;
+			else if (c->from_idx <=3D c->to_idx)
+				mod->csumfunc.crc8 =3D cgw_csum_crc8_pos;
+			else
+				mod->csumfunc.crc8 =3D cgw_csum_crc8_neg;
+		}
+
+		if (tb[CGW_CS_XOR] &&
+		    nla_len(tb[CGW_CS_XOR]) =3D=3D CGW_CS_XOR_LEN) {
+
+			struct cgw_csum_xor *c =3D (struct cgw_csum_xor *)\
+				nla_data(tb[CGW_CS_XOR]);
+
+			err =3D cgw_chk_csum_parms(c->from_idx, c->to_idx,
+						 c->result_idx);
+			if (err)
+				return err;
+
+			nla_memcpy(&mod->csum.xor, tb[CGW_CS_XOR],
+				   CGW_CS_XOR_LEN);
+
+			/*
+			 * select dedicated processing function to reduce
+			 * runtime operations in receive hot path.
+			 */
+			if (c->from_idx < 0 || c->to_idx < 0 ||
+			    c->result_idx < 0)
+				mod->csumfunc.xor =3D cgw_csum_xor_rel;
+			else if (c->from_idx <=3D c->to_idx)
+				mod->csumfunc.xor =3D cgw_csum_xor_pos;
+			else
+				mod->csumfunc.xor =3D cgw_csum_xor_neg;
+		}
+	}
+
+	if (gwtype =3D=3D CGW_TYPE_CAN_CAN) {
+
+		/* check CGW_TYPE_CAN_CAN specific attributes */
+
+		struct can_can_gw *ccgw =3D (struct can_can_gw *)gwtypeattr;
+		memset(ccgw, 0, sizeof(*ccgw));
+
+		/* check for can_filter in attributes */
+		if (tb[CGW_FILTER] &&
+		    nla_len(tb[CGW_FILTER]) =3D=3D sizeof(struct can_filter))
+			nla_memcpy(&ccgw->filter, tb[CGW_FILTER],
+				   sizeof(struct can_filter));
+
+		err =3D -ENODEV;
+
+		/* specifying two interfaces is mandatory */
+		if (!tb[CGW_SRC_IF] || !tb[CGW_DST_IF])
+			return err;
+
+		if (nla_len(tb[CGW_SRC_IF]) =3D=3D sizeof(u32))
+			nla_memcpy(&ccgw->src_idx, tb[CGW_SRC_IF],
+				   sizeof(u32));
+
+		if (nla_len(tb[CGW_DST_IF]) =3D=3D sizeof(u32))
+			nla_memcpy(&ccgw->dst_idx, tb[CGW_DST_IF],
+				   sizeof(u32));
+
+		/* both indices set to 0 for flushing all routing entries */
+		if (!ccgw->src_idx && !ccgw->dst_idx)
+			return 0;
+
+		/* only one index set to 0 is an error */
+		if (!ccgw->src_idx || !ccgw->dst_idx)
+			return err;
+	}
+
+	/* add the checks for other gwtypes here */
+
+	return 0;
+}
+
+static int cgw_create_job(struct sk_buff *skb,  struct nlmsghdr *nlh,
+			  void *arg)
+{
+	struct rtcanmsg *r;
+	struct cgw_job *gwj;
+	int err =3D 0;
+
+	if (nlmsg_len(nlh) < sizeof(*r))
+		return -EINVAL;
+
+	r =3D nlmsg_data(nlh);
+	if (r->can_family !=3D AF_CAN)
+		return -EPFNOSUPPORT;
+
+	/* so far we only support CAN -> CAN routings */
+	if (r->gwtype !=3D CGW_TYPE_CAN_CAN)
+		return -EINVAL;
+
+	gwj =3D kmem_cache_alloc(cgw_cache, GFP_KERNEL);
+	if (!gwj)
+		return -ENOMEM;
+
+	gwj->handled_frames =3D 0;
+	gwj->dropped_frames =3D 0;
+	gwj->flags =3D r->flags;
+	gwj->gwtype =3D r->gwtype;
+
+	err =3D cgw_parse_attr(nlh, &gwj->mod, CGW_TYPE_CAN_CAN, &gwj->ccgw);
+	if (err < 0)
+		goto out;
+
+	err =3D -ENODEV;
+
+	/* ifindex =3D=3D 0 is not allowed for job creation */
+	if (!gwj->ccgw.src_idx || !gwj->ccgw.dst_idx)
+		goto out;
+
+	gwj->src.dev =3D dev_get_by_index(&init_net, gwj->ccgw.src_idx);
+
+	if (!gwj->src.dev)
+		goto out;
+
+	/* check for CAN netdev not using header_ops - see gw_rcv() */
+	if (gwj->src.dev->type !=3D ARPHRD_CAN || gwj->src.dev->header_ops)
+		goto put_src_out;
+
+	gwj->dst.dev =3D dev_get_by_index(&init_net, gwj->ccgw.dst_idx);
+
+	if (!gwj->dst.dev)
+		goto put_src_out;
+
+	/* check for CAN netdev not using header_ops - see gw_rcv() */
+	if (gwj->dst.dev->type !=3D ARPHRD_CAN || gwj->dst.dev->header_ops)
+		goto put_src_dst_out;
+
+	ASSERT_RTNL();
+
+	err =3D cgw_register_filter(gwj);
+	if (!err)
+		hlist_add_head_rcu(&gwj->list, &cgw_list);
+
+put_src_dst_out:
+	dev_put(gwj->dst.dev);
+put_src_out:
+	dev_put(gwj->src.dev);
+out:
+	if (err)
+		kmem_cache_free(cgw_cache, gwj);
+
+	return err;
+}
+
+static void cgw_remove_all_jobs(void)
+{
+	struct cgw_job *gwj =3D NULL;
+	struct hlist_node *n, *nx;
+
+	ASSERT_RTNL();
+
+	hlist_for_each_entry_safe(gwj, n, nx, &cgw_list, list) {
+		hlist_del(&gwj->list);
+		cgw_unregister_filter(gwj);
+		kfree(gwj);
+	}
+}
+
+static int cgw_remove_job(struct sk_buff *skb,  struct nlmsghdr *nlh, =
void *arg)
+{
+	struct cgw_job *gwj =3D NULL;
+	struct hlist_node *n, *nx;
+	struct rtcanmsg *r;
+	struct cf_mod mod;
+	struct can_can_gw ccgw;
+	int err =3D 0;
+
+	if (nlmsg_len(nlh) < sizeof(*r))
+		return -EINVAL;
+
+	r =3D nlmsg_data(nlh);
+	if (r->can_family !=3D AF_CAN)
+		return -EPFNOSUPPORT;
+
+	/* so far we only support CAN -> CAN routings */
+	if (r->gwtype !=3D CGW_TYPE_CAN_CAN)
+		return -EINVAL;
+
+	err =3D cgw_parse_attr(nlh, &mod, CGW_TYPE_CAN_CAN, &ccgw);
+	if (err < 0)
+		return err;
+
+	/* two interface indices both set to 0 =3D> remove all entries */
+	if (!ccgw.src_idx && !ccgw.dst_idx) {
+		cgw_remove_all_jobs();
+		return 0;
+	}
+
+	err =3D -EINVAL;
+
+	ASSERT_RTNL();
+
+	/* remove only the first matching entry */
+	hlist_for_each_entry_safe(gwj, n, nx, &cgw_list, list) {
+
+		if (gwj->flags !=3D r->flags)
+			continue;
+
+		if (memcmp(&gwj->mod, &mod, sizeof(mod)))
+			continue;
+
+		/* if (r->gwtype =3D=3D CGW_TYPE_CAN_CAN) - is made sure here */
+		if (memcmp(&gwj->ccgw, &ccgw, sizeof(ccgw)))
+			continue;
+
+		hlist_del(&gwj->list);
+		cgw_unregister_filter(gwj);
+		kfree(gwj);
+		err =3D 0;
+		break;
+	}
+
+	return err;
+}
+
+static __init int cgw_module_init(void)
+{
+	printk(banner);
+
+	cgw_cache =3D kmem_cache_create("can_gw", sizeof(struct cgw_job),
+				      0, 0, NULL);
+
+	if (!cgw_cache)
+		return -ENOMEM;
+
+	/* set notifier */
+	notifier.notifier_call =3D cgw_notifier;
+	register_netdevice_notifier(&notifier);
+
+	if (__rtnl_register(PF_CAN, RTM_GETROUTE, NULL, cgw_dump_jobs, NULL))=
 {
+		unregister_netdevice_notifier(&notifier);
+		kmem_cache_destroy(cgw_cache);
+		return -ENOBUFS;
+	}
+
+	/* Only the first call to __rtnl_register can fail */
+	__rtnl_register(PF_CAN, RTM_NEWROUTE, cgw_create_job, NULL, NULL);
+	__rtnl_register(PF_CAN, RTM_DELROUTE, cgw_remove_job, NULL, NULL);
+
+	return 0;
+}
+
+static __exit void cgw_module_exit(void)
+{
+	rtnl_unregister_all(PF_CAN);
+
+	unregister_netdevice_notifier(&notifier);
+
+	rtnl_lock();
+	cgw_remove_all_jobs();
+	rtnl_unlock();
+
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
+
+	kmem_cache_destroy(cgw_cache);
+}
+
+module_init(cgw_module_init);
+module_exit(cgw_module_exit);
diff -u -r -N a/net/can/Kconfig b/net/can/Kconfig
--- a/net/can/Kconfig	2011-08-31 21:10:58.399595821 +0200
+++ b/net/can/Kconfig	2011-08-31 21:09:29.939596430 +0200
@@ -40,5 +40,16 @@
 	  CAN messages are used on the bus (e.g. in automotive environments).
 	  To use the Broadcast Manager, use AF_CAN with protocol CAN_BCM.
=20
+config CAN_GW
+	tristate "CAN Gateway/Router (with netlink configuration)"
+	depends on CAN
+	default N
+	---help---
+	  The CAN Gateway/Router is used to route (and modify) CAN frames.
+	  It is based on the PF_CAN core infrastructure for msg filtering and
+	  msg sending and can optionally modify routed CAN frames on the fly.
+	  CAN frames can be routed between CAN network interfaces (one hop).
+	  They can be modified with AND/OR/XOR/SET operations as configured
+	  by the netlink configuration interface known e.g. from iptables.
=20
 source "drivers/net/can/Kconfig"
diff -u -r -N a/net/can/Makefile b/net/can/Makefile
--- a/net/can/Makefile	2011-08-31 21:10:53.355595713 +0200
+++ b/net/can/Makefile	2011-08-31 21:09:34.483599007 +0200
@@ -10,3 +10,6 @@
=20
 obj-$(CONFIG_CAN_BCM)	+=3D can-bcm.o
 can-bcm-y		:=3D bcm.o
+
+obj-$(CONFIG_CAN_GW)	+=3D can-gw.o
+can-gw-y		:=3D gw.o
