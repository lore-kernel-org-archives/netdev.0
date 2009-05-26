From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 2/5] net: add IEEE 802.15.4 partial implementation
Date: Tue, 26 May 2009 15:23:05 +0400
Message-ID: <1243336988-20109-2-git-send-email-dbaryshkov@gmail.com>
References: <20090526112157.GA19976@doriath.ww600.siemens.net>
 <1243336988-20109-1-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: slapin@ossfans.org, maxim.osipov@siemens.com,
	dmitry.baryshkov@siemens.com, oliver.fendt@siemens.com,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
To: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:59098 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753167AbZEZLXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 07:23:30 -0400
In-Reply-To: <1243336988-20109-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for communication over IEEE 802.15.4 networks. This impleme=
ntation
is neither certified nor complete, but aims to that goal. This commit c=
ontains
only parts of MAC implementation, socket code and drivers supporting th=
is stack
will follow.

Initial implementation was done by Maxim Gorbachyov, Maxim Osipov and P=
avel
Smolensky as a research project at Siemens AG. Later the stack was heav=
ily
reworked to better suit the linux networking model, and is now maitaine=
d
as an open project partially sponsored by Siemens.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Signed-off-by: Sergey Lapin <slapin@ossfans.org>
---
 include/net/ieee802154/af_ieee802154.h |   65 +++
 include/net/ieee802154/beacon.h        |   53 ++
 include/net/ieee802154/beacon_hash.h   |   40 ++
 include/net/ieee802154/const.h         |  696 ++++++++++++++++++++++++
 include/net/ieee802154/crc.h           |   38 ++
 include/net/ieee802154/dev.h           |  107 ++++
 include/net/ieee802154/mac_def.h       |   96 ++++
 include/net/ieee802154/netdev.h        |   74 +++
 include/net/ieee802154/nl.h            |  166 ++++++
 include/net/ieee802154/phy.h           |  117 ++++
 net/Kconfig                            |    1 +
 net/Makefile                           |    1 +
 net/ieee802154/Kconfig                 |   12 +
 net/ieee802154/Makefile                |    5 +
 net/ieee802154/beacon.c                |  251 +++++++++
 net/ieee802154/beacon_hash.c           |  105 ++++
 net/ieee802154/crc.c                   |   73 +++
 net/ieee802154/dev.c                   |  935 ++++++++++++++++++++++++=
++++++++
 net/ieee802154/mac_cmd.c               |  226 ++++++++
 net/ieee802154/main.c                  |  175 ++++++
 net/ieee802154/mdev.c                  |  189 +++++++
 net/ieee802154/netlink.c               |  637 ++++++++++++++++++++++
 net/ieee802154/scan.c                  |  211 +++++++
 net/ieee802154/start.c                 |   46 ++
 24 files changed, 4319 insertions(+), 0 deletions(-)
 create mode 100644 include/net/ieee802154/af_ieee802154.h
 create mode 100644 include/net/ieee802154/beacon.h
 create mode 100644 include/net/ieee802154/beacon_hash.h
 create mode 100644 include/net/ieee802154/const.h
 create mode 100644 include/net/ieee802154/crc.h
 create mode 100644 include/net/ieee802154/dev.h
 create mode 100644 include/net/ieee802154/mac_def.h
 create mode 100644 include/net/ieee802154/netdev.h
 create mode 100644 include/net/ieee802154/nl.h
 create mode 100644 include/net/ieee802154/phy.h
 create mode 100644 net/ieee802154/Kconfig
 create mode 100644 net/ieee802154/Makefile
 create mode 100644 net/ieee802154/beacon.c
 create mode 100644 net/ieee802154/beacon_hash.c
 create mode 100644 net/ieee802154/crc.c
 create mode 100644 net/ieee802154/dev.c
 create mode 100644 net/ieee802154/mac_cmd.c
 create mode 100644 net/ieee802154/main.c
 create mode 100644 net/ieee802154/mdev.c
 create mode 100644 net/ieee802154/netlink.c
 create mode 100644 net/ieee802154/scan.c
 create mode 100644 net/ieee802154/start.c

diff --git a/include/net/ieee802154/af_ieee802154.h b/include/net/ieee8=
02154/af_ieee802154.h
new file mode 100644
index 0000000..6eb7f51
--- /dev/null
+++ b/include/net/ieee802154/af_ieee802154.h
@@ -0,0 +1,65 @@
+/*
+ * IEEE 802.15.4 inteface for userspace
+ *
+ * Copyright 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long
+ * with this program; if not, write to the Free Software Foundation, I=
nc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Sergey Lapin <sergey.lapin@siemens.com>
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ */
+
+#ifndef _AF_IEEE802154_H
+#define _AF_IEEE802154_H
+
+#include <linux/socket.h> /* for sa_family_t */
+
+enum {
+	IEEE802154_ADDR_NONE =3D 0x0,
+	/* RESERVED =3D 0x01, */
+	IEEE802154_ADDR_SHORT =3D 0x2, /* 16-bit address + PANid */
+	IEEE802154_ADDR_LONG =3D 0x3, /* 64-bit address + PANid */
+};
+
+/* address length, octets */
+#define IEEE802154_ADDR_LEN	8
+
+struct ieee802154_addr {
+	int addr_type;
+	u16 pan_id;
+	union {
+		u8 hwaddr[IEEE802154_ADDR_LEN];
+		u16 short_addr;
+	};
+};
+
+struct sockaddr_ieee802154 {
+	sa_family_t family; /* AF_IEEE802154 */
+	struct ieee802154_addr addr;
+};
+
+/* master device */
+#define IEEE802154_SIOC_ADD_SLAVE		(SIOCDEVPRIVATE + 0)
+
+#ifdef __KERNEL__
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+extern struct proto ieee802154_raw_prot;
+extern struct proto ieee802154_dgram_prot;
+void ieee802154_raw_deliver(struct net_device *dev, struct sk_buff *sk=
b);
+int ieee802154_dgram_deliver(struct net_device *dev, struct sk_buff *s=
kb);
+#endif
+
+#endif
diff --git a/include/net/ieee802154/beacon.h b/include/net/ieee802154/b=
eacon.h
new file mode 100644
index 0000000..baca263
--- /dev/null
+++ b/include/net/ieee802154/beacon.h
@@ -0,0 +1,53 @@
+/*
+ * beacon.h
+ *
+ * Copyright (C) 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long
+ * with this program; if not, write to the Free Software Foundation, I=
nc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Pavel Smolenskiy <pavel.smolenskiy@gmail.com>
+ * Maxim Gorbachyov <maxim.gorbachev@siemens.com>
+ */
+
+#ifndef IEEE802154_BEACON_H
+#define IEEE802154_BEACON_H
+
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include "af_ieee802154.h"
+
+/* Per spec; optimizations are needed */
+struct ieee802154_pandsc {
+	struct list_head	list;
+	struct ieee802154_addr	addr; /* Contains panid */
+	int			channel;
+	u16			sf;
+	bool			gts_permit;
+	u8			lqi;
+	u32			timestamp; /* FIXME */
+	bool			security;
+	u8			mac_sec;
+	bool			sec_fail;
+};
+
+int parse_beacon_frame(struct sk_buff *skb, u8 * buf,
+		int *flags, struct list_head *al);
+
+int ieee802154_send_beacon(struct net_device *dev, struct ieee802154_a=
ddr *saddr,
+		u16 pan_id, const u8 *buf, int len,
+		int flags, struct list_head *al);
+
+#endif /* IEEE802154_BEACON_H */
+
diff --git a/include/net/ieee802154/beacon_hash.h b/include/net/ieee802=
154/beacon_hash.h
new file mode 100644
index 0000000..db8457c
--- /dev/null
+++ b/include/net/ieee802154/beacon_hash.h
@@ -0,0 +1,40 @@
+/*
+ * MAC beacon hash storage
+ *
+ * Copyright 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long
+ * with this program; if not, write to the Free Software Foundation, I=
nc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Sergey Lapin <sergey.lapin@siemens.com>
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ */
+
+#ifndef IEEE802154_BEACON_HASH_H
+#define IEEE802154_BEACON_HASH_H
+
+#define IEEE802154_BEACON_HTABLE_SIZE 256
+
+struct beacon_node {
+	struct hlist_node list;
+	struct ieee802154_addr coord_addr;
+	u16 pan_addr;
+};
+struct beacon_node *ieee802154_beacon_find_pan(struct ieee802154_addr =
*coord_addr,
+			u16 pan_addr);
+void ieee802154_beacon_hash_add(struct ieee802154_addr *coord_addr);
+void ieee802154_beacon_hash_del(struct ieee802154_addr *coord_addr);
+void ieee802154_beacon_hash_dump(void);
+#endif
+
diff --git a/include/net/ieee802154/const.h b/include/net/ieee802154/co=
nst.h
new file mode 100644
index 0000000..d6e0a2e
--- /dev/null
+++ b/include/net/ieee802154/const.h
@@ -0,0 +1,696 @@
+/*
+ * ieee802154_const.h
+ *
+ * Description: IEEE 802.15.4 Constants and return codes.
+ *
+ * Copyright (C) 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long
+ * with this program; if not, write to the Free Software Foundation, I=
nc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Pavel Smolenskiy <pavel.smolenskiy@gmail.com>
+ * Maxim Gorbachyov <maxim.gorbachev@siemens.com>
+ */
+
+#ifndef IEEE802154_CONST_H
+#define IEEE802154_CONST_H
+
+#define IEEE802154_ACK_LEN	3	/* Size of acknowledge frame */
+
+/* Time related constants, in microseconds.
+ *
+ * The 1SYM_TIME values are shown how much time is needed to transmit =
one
+ * symbol across media.
+ * The callculation is following:
+ * For a 2450 MHZ radio freq rate is 62,5 ksym/sec. A byte (8 bit) tra=
nsfered
+ * by low 4 bits in first symbol, high 4 bits in next symbol. So, to t=
ransmit
+ * 1 byte in 2450Mhz freq 2 symbols are needed. Therefore we have 31,2=
5 kbyte/sec
+ * rate. 1 symbol transfered in 16*10^(-6) sec, or 16 microseconds.
+ * For a 868Mhz and 915Mhz, 1 symbol is equal to 1 byte. So, we have 2=
0kbyte/sec
+ * and 40 kbyte/sec respectively. And 5*10^(-5) sec and 2,5*10(-5) sec=
,
+ * or 50 and 25 microseconds respectively for 868Mhz and 915Mhz freq.
+ */
+#define IEEE802154_2450MHZ_1SYM_TIME	16
+#define IEEE802154_868MHZ_1SYM_TIME	50
+#define IEEE802154_915MHZ_1SYM_TIME	25
+
+/*********************************************************************=
*********/
+/* MAC constants */
+/*********************************************************************=
*********/
+/** The number of symbols forming a superframe slot when the superfram=
e order
+ * is equal to 0.
+ */
+#define IEEE802154_BASE_SD	60
+
+/** The number of slots contained in any superframe. */
+#define IEEE802154_NUM_SFS	16
+
+/** The number of symbols forming a superframe when the superframe ord=
er is
+ * equal to 0.
+ */
+#define IEEE802154_BASE_SFD	(IEEE802154_BASE_SD*IEEE802154_NUM_SFS)
+
+/** The 64 bit (IEEE) address assigned to the device. */
+#define IEEE802154_EXT_ADDR		0
+
+/** The maximum value of the backoff exponent in the CSMA-CA algorithm=
=2E */
+#define IEEE802154_MAXBE			5
+
+/** The maximum number of octets added by the MAC sublayer to the payl=
oad of
+ * its beacon frame.
+ */
+#define IEEE802154_MAX_BOVERHEAD		75
+
+/** The maximum size, in octets, of a beacon payload. */
+#define IEEE802154_MAX_BPAYLOAD	(IEEE802154_MAX_PHY_PACKET_SIZE - IEEE=
802154_MAX_BOVERHEAD)
+
+/** The number of superframes in which a GTS descriptor exists in the =
beacon
+ * frame of a PAN coordinator.
+ */
+#define IEEE802154_GTS_DESC_PERS_TIME	4
+
+/** The maximum number of octets added by the MAC sublayer to its payl=
oad
+ * without security. If security is required on a frame, its secure pr=
ocessing
+ * may inflate the frame length so that it is greater than this value.=
 In
+ * this case, an error is generated through the appropriate .confirm o=
r
+ * MLME-COMM-STATUS.indication primitives.
+ */
+#define IEEE802154_MAX_FRAME_OVERHEAD	25
+
+/** The maximum number of CAP symbols in a beaconenabled PAN, or symbo=
ls in a
+ * nonbeacon-enabled PAN, to wait for a frame intended as a response t=
o a
+ * data request frame.
+ */
+#define IEEE802154_MAX_FRAME_RESP_TIME	1220
+
+/** The maximum number of retries allowed after a transmission failure=
=2E */
+#define IEEE802154_MAX_FRAME_RETRIES		3
+
+/** The number of consecutive lost beacons that will cause the MAC sub=
layer of
+ * a receiving device to declare a loss of synchronization.
+ */
+#define IEEE802154_MAX_LOST_BEACONS		4
+
+/** The maximum number of octets that can be transmitted in the MAC fr=
ame
+ * payload field.
+ */
+#define IEEE802154_MAX_FRAME_SIZE		(IEEE802154_MAX_PHY_PACKET_SIZE - I=
EEE802154_MAX_FRAME_OVERHEAD)
+
+/** The maximum size of an MPDU, in octets, that can be followed by a =
short
+ * interframe spacing (SIFS) period.
+ */
+#define IEEE802154_MAX_SIFS_FRAME_SIZE	18
+
+/** The minimum number of symbols forming the CAP. This ensures that M=
AC
+ * commands can still be transferred to devices when GTSs are being us=
ed.
+ * An exception to this minimum shall be allowed for the accommodation=
 of the
+ * temporary increase in the beacon frame length needed to perform GTS
+ * maintenance (see 802.15.4-2003.pdf, item 7.2.2.1.3). */
+#define IEEE802154_MIN_CAP_LEN		440
+
+/** The minimum number of symbols forming a long interframe spacing (L=
IFS) period. */
+#define IEEE802154_MIN_LIFS_PERIOD		40
+
+/** The minimum number of symbols forming a SIFS period. */
+#define IEEE802154_MIN_SIFS_PERIOD		12
+
+/** The maximum number of symbols a device shall wait for a response c=
ommand to
+ * be available following a request command.
+ */
+#define IEEE802154_RESPONSE_WAIT_TIME	(32*IEEE802154_BASE_SFD)
+
+/** The number of symbols forming the basic time period used by the CS=
MA-CA
+ * algorithm.
+ */
+#define IEEE802154_UNIT_BACKOFF_PERIOD	20
+
+/*********************************************************************=
*********/
+/* PAN Information Base (PIB), MAC attribute identifiers */
+/* See IEEE802.15.4-2003 draft, Table 71 */
+/*********************************************************************=
*********/
+/** The maximum number of symbols to wait for an acknowledgment frame =
to arrive
+ * following a transmitted data frame. This value is dependent on the =
currently
+ * selected logical channel. For 0 =E2=89=A4 phyCurrentChannel =E2=89=A4=
 10, this value is equal
+ * to 120. For 11 =E2=89=A4 phyCurrentChannel =E2=89=A4 26, this value=
 is equal to 54.
+ */
+#define IEEE802154_ACK_WAIT_DURATION		0x40
+
+/** Indication of whether a coordinator is currently allowing associat=
ion.
+ * A value of TRUE indicates that association is permitted.
+ */
+#define IEEE802154_ASSOCIATION_PERMIT	0x41
+
+/** Indication of whether a device automatically sends a data request =
command
+ * if its address is listed in the beacon frame. A value of TRUE indic=
ates that
+ * the data request command is automatically sent.
+ */
+#define IEEE802154_AUTO_REQUEST		0x42
+
+/** Indication of whether battery life extension, by reduction of coor=
dinator
+ * receiver operation time during the CAP, is enabled. A value of TRUE=
 indicates
+ * that it is enabled.
+ */
+#define IEEE802154_BAT_LIFE_EXT		0x43
+
+/** The number of backoff periods during which the receiver is enabled=
 following
+ * a beacon in battery life extension mode. This value is dependent on=
 the
+ * currently selected logical channel. For 0 =E2=89=A4 phyCurrentChann=
el =E2=89=A4 10, this
+ * value is equal to 8. For 11 =E2=89=A4 phyCurrentChannel =E2=89=A4 2=
6, this value is equal
+ * to 6.
+ */
+#define IEEE802154_BAT_LIFE_EXT_PERIOD	0x44
+
+/** The contents of the beacon payload.*/
+#define IEEE802154_BEACON_PAYLOAD		0x45
+
+/** The length, in octets, of the beacon payload.*/
+#define IEEE802154_BEACON_PAYLOAD_LEN	0x46
+
+/** Specification of how often the coordinator transmits a beacon. The
+ * macBeaconOrder, BO, and the beacon interval, BI, are related as fol=
lows:
+ * for 0 =E2=89=A4 BO =E2=89=A4 14, BI =3D aBaseSuperframeDuration * 2=
BO symbols. If BO =3D 15,
+ * the coordinator will not transmit a beacon.
+ */
+#define IEEE802154_BEACON_ORDER		0x47
+
+/** The time that the device transmitted its last beacon frame, in sym=
bol
+ * periods. The measurement shall be taken at the same symbol boundary=
 within
+ * every transmitted beacon frame, the location of which is implementa=
tion
+ * specific. The precision of this value shall be a minimum of 20 bits=
, with the
+ * lowest four bits being the least significant.
+ */
+#define IEEE802154_BEACON_TX_TIME		0x48
+
+/** The sequence number added to the transmitted beacon frame. */
+#define IEEE802154_BSN			0x49
+
+/** The 64 bit address of the coordinator with which the device is ass=
ociated. */
+#define IEEE802154_COORD_EXTENDED_ADDRESS	0x4a
+
+/** The 16 bit short address assigned to the coordinator with which th=
e device
+ * is associated. A value of 0xfffe indicates that the coordinator is =
only
+ * using its 64 bit extended address. A value of 0xffff indicates that=
 this
+ * value is unknown.
+ */
+#define IEEE802154_COORD_SHORT_ADDRESS	0x4b
+
+/** The sequence number added to the transmitted data or MAC command f=
rame. */
+#define IEEE802154_DSN			0x4c
+
+/** TRUE if the PAN coordinator is to accept GTS requests. FALSE other=
wise. */
+#define IEEE802154_GTS_PERMIT		0x4d
+
+/** The maximum number of backoffs the CSMA-CA algorithm will attempt =
before
+ * declaring a channel access failure.
+ */
+#define IEEE802154_MAX_CSMA_BACKOFF		0x4e
+
+/** The minimum value of the backoff exponent in the CSMA-CA algorithm=
=2E Note
+ * that if this value is set to 0, collision avoidance is disabled dur=
ing the
+ * first iteration of the algorithm. Also note that for the slotted ve=
rsion of
+ * the CSMACA algorithm with the battery life extension enabled, the m=
inimum
+ * value of the backoff exponent will be the lesser of 2 and the value=
 of
+ * macMinBE.
+ */
+#define IEEE802154_MIN_BE			0x4f
+
+/** The 16 bit identifier of the PAN on which the device is operating.=
 If this
+ * value is 0 x ffff, the device is not associated.
+ */
+#define IEEE802154_PANID			0x50
+
+/** This indicates whether the MAC sublayer is in a promiscuous (recei=
ve all)
+ * mode. A value of TRUE indicates that the MAC sublayer accepts all f=
rames
+ * received from the PHY.
+ */
+#define IEEE802154_PROMISCOUS_MODE		0x51
+
+/** This indicates whether the MAC sublayer is to enable its receiver =
during
+ * idle periods.
+ */
+#define IEEE802154_RXON_WHEN_IDLE		0x52
+
+/** The 16 bit address that the device uses to communicate in the PAN.=
 If the
+ * device is a PAN coordinator, this value shall be chosen before a PA=
N is
+ * started. Otherwise, the address is allocated by a coordinator durin=
g
+ * association. A value of 0xfffe indicates that the device has associ=
ated but
+ * has not been allocated an address. A value of 0xffff indicates that=
 the
+ * device does not have a short address.
+ */
+#define IEEE802154_SHORT_ADDRESS		0x53
+
+/** This specifies the length of the active portion of the superframe,=
 including
+ * the beacon frame. The macSuperframeOrder, SO, and the superframe du=
ration,
+ * SD, are related as follows: for 0 =E2=89=A4 SO =E2=89=A4 BO =E2=89=A4=
 14, SD =3D aBaseSuperframeDuration * 2SO
+ * symbols. If SO =3D 15, the superframe will not be active following =
the beacon.
+ */
+#define IEEE802154_SUPERFRAME_ORDER		0x54
+
+/** The maximum time (in superframe periods) that a transaction is sto=
red by a
+ * coordinator and indicated in its beacon.
+ */
+#define IEEE802154_TRANSACTION_PERSISTENSE_TIME	0x55
+
+/*********************************************************************=
*********/
+/* PAN Information Base (PIB), MAC attribute ranges */
+/* See IEEE802.15.4-2003 draft, Table 71 */
+/*********************************************************************=
*********/
+/**
+ * The maximum number of symbols to wait for an acknowledgment frame t=
o arrive
+ * following a transmitted data frame. This value is dependent on the =
currently
+ * selected logical channel. For 0 =E2=89=A4 phyCurrentChannel =E2=89=A4=
 10, this value is equal
+ * to 120. For 11 =E2=89=A4 phyCurrentChannel =E2=89=A4 26, this value=
 is equal to 54.
+ */
+#define IEEE802154_ACK_WAIT_DURATION_DEF	0x36
+#define IEEE802154_ACK_WAIT_DURATION_MIN	0x36
+#define IEEE802154_ACK_WAIT_DURATION_MAX	0x78
+
+/**
+ * Indication of whether a coordinator is currently allowing associati=
on. A
+ * value of TRUE indicates that association is permitted.
+ */
+#define IEEE802154_ASSOCIATION_PERMIT_DEF	false
+
+/**
+ * Indication of whether a device automatically sends a data request c=
ommand if
+ * its address is listed in the beacon frame. A value of TRUE indicate=
s that the
+ * data request command is automatically sent.
+ */
+#define IEEE802154_AUTO_REQUEST_DEF		true
+
+/**
+ * Indication of whether battery life extension, by reduction of coord=
inator
+ * receiver operation time during the CAP, is enabled. A value of TRUE=
 indicates
+ * that it is enabled.
+ */
+#define IEEE802154_BAT_LIFE_EXT_DEF		true
+
+/**
+ * The number of backoff periods during which the receiver is enabled =
following
+ * a beacon in battery life extension mode. This value is dependent on=
 the
+ * currently selected logical channel. For 0 =E2=89=A4 phyCurrentChann=
el =E2=89=A4 10, this
+ * value is equal to 8. For 11 =E2=89=A4 phyCurrentChannel =E2=89=A4 2=
6, this value is equal
+ * to 6.
+ */
+#define IEEE802154_BAT_LIFE_EXT_PERIOD_DEF	0x6
+#define IEEE802154_BAT_LIFE_EXT_PERIOD_MIN	0x6
+#define IEEE802154_BAT_LIFE_EXT_PERIOD_MAX	0x8
+
+/**
+ * The contents of the beacon payload.
+ */
+#define IEEE802154_BEACON_PAYLOAD_DEF	NULL
+
+/**
+ * The length, in octets, of the beacon payload.
+ */
+#define IEEE802154_BEACON_PAYLOAD_LEN_DEF	0x0
+#define IEEE802154_BEACON_PAYLOAD_LEN_MIN	0x0
+#define IEEE802154_BEACON_PAYLOAD_LEN_MAX	IEEE802154_BEACON_PAYLOAD_LE=
N
+
+/**
+ * Specification of how often the coordinator transmits a beacon. The
+ * macBeaconOrder, BO, and the beacon interval, BI, are related as fol=
lows:
+ * for 0 =E2=89=A4 BO =E2=89=A4 14, BI =3D aBaseSuperframeDuration * 2=
BO symbols. If BO =3D 15, the
+ * coordinator will not transmit a beacon.
+ */
+#define IEEE802154_BEACON_ORDER_DEF		0xf
+#define IEEE802154_BEACON_ORDER_MIN		0x0
+#define IEEE802154_BEACON_ORDER_MAX		0xf
+
+/**
+ * The time that the device transmitted its last beacon frame, in symb=
ol periods.
+ * The measurement shall be taken at the same symbol boundary within e=
very
+ * transmitted beacon frame, the location of which is implementation s=
pecific.
+ * The precision of this value shall be a minimum of 20 bits, with the=
 lowest
+ * four bits being the least significant.
+ */
+#define IEEE802154_BEACON_TX_TIME_DEF	0x0
+#define IEEE802154_BEACON_TX_TIME_MIN	0x0
+#define IEEE802154_BEACON_TX_TIME_MAX	0xffffffff
+
+/**
+ * The sequence number added to the transmitted beacon frame.
+ */
+#define IEEE802154_BSN_MIN			0x0
+#define IEEE802154_BSN_MAX			0xff
+
+/**
+ * The 16 bit short address assigned to the coordinator with which the=
 device is
+ * associated. A value of 0xfffe indicates that the coordinator is onl=
y using
+ * its 64 bit extended address. A value of 0xffff indicates that this =
value is
+ * unknown.
+ */
+#define IEEE802154_COORD_SHORT_ADDRESS_DEF	0xffff
+#define IEEE802154_COORD_SHORT_ADDRESS_MIN	0x0
+#define IEEE802154_COORD_SHORT_ADDRESS_MAX	0xffff
+#define IEEE802154_COORD_SHORT_ADDRESS_64BIT	0xfffe
+
+#define IEEE802154_COORD_EXT_ADDRESS_DEF		0xffffffff
+
+/**
+ * The sequence number added to the transmitted data or MAC command fr=
ame.
+ */
+#define IEEE802154_DSN_MIN			0x0
+#define IEEE802154_DSN_MAX			0xff
+
+/**
+ * TRUE if the PAN coordinator is to accept GTS requests. FALSE otherw=
ise.
+ */
+#define IEEE802154_GTS_PERMIT_DEF		true
+
+/**
+ * The maximum number of backoffs the CSMA-CA algorithm will attempt b=
efore
+ * declaring a channel access failure.
+ */
+#define IEEE802154_MAX_CSMA_BACKOFF_DEF	0x4
+#define IEEE802154_MAX_CSMA_BACKOFF_MIN	0x0
+#define IEEE802154_MAX_CSMA_BACKOFF_MAX	0x5
+
+/**
+ * The minimum value of the backoff exponent in the CSMA-CA algorithm.=
 Note that
+ * if this value is set to 0, collision avoidance is disabled during t=
he first
+ * iteration of the algorithm. Also note that for the slotted version =
of the
+ * CSMA-CA algorithm with the battery life extension enabled, the mini=
mum value
+ * of the backoff exponent will be the lesser of 2 and the value of ma=
cMinBE.
+ */
+#define IEEE802154_MIN_BE_DEF		0x3
+#define IEEE802154_MIN_BE_MIN		0x0
+#define IEEE802154_MIN_BE_MAX		0x3
+
+/**
+ * The 16 bit identifier of the PAN on which the device is operating. =
If this
+ * value is 0xffff, the device is not associated.
+ */
+#define IEEE802154_PANID_DEF			0xffff
+#define IEEE802154_PANID_MIN			0x0
+#define IEEE802154_PANID_MAX			0xffff
+
+/**
+ * This indicates whether the MAC sublayer is in a promiscuous (receiv=
e all)
+ * mode. A value of TRUE indicates that the MAC sublayer accepts all f=
rames
+ * received from the PHY.
+ */
+#define IEEE802154_PROMISCOUS_MODE_DEF	false
+
+/**
+ * This indicates whether the MAC sublayer is to enable its receiver d=
uring idle
+ * periods.
+ */
+#define IEEE802154_RXON_WHEN_IDLE_DEF	false
+
+/**
+ * The 16 bit address that the device uses to communicate in the PAN. =
If the
+ * device is a PAN coordinator, this value shall be chosen before a PA=
N is
+ * started. Otherwise, the address is allocated by a coordinator durin=
g
+ * association. A value of 0xfffe indicates that the device has associ=
ated but
+ * has not been allocated an address. A value of 0xffff indicates that=
 the
+ * device does not have a short address.
+ */
+#define IEEE802154_SHORT_ADDRESS_DEF		0xffff
+#define IEEE802154_SHORT_ADDRESS_MIN		0x0
+#define IEEE802154_SHORT_ADDRESS_MAX		0xffff
+
+/**
+ * This specifies the length of the active portion of the superframe, =
including
+ * the beacon frame. The macSuperframeOrder, SO, and the superframe du=
ration,
+ * SD, are related as follows: for 0 =E2=89=A4 SO =E2=89=A4 BO =E2=89=A4=
 14,
+ * SD =3D aBaseSuperframeDuration * 2SO symbols. If SO =3D 15, the sup=
erframe will
+ * not be active following the beacon.
+ */
+#define IEEE802154_SUPERFRAME_ORDER_DEF	0xf
+#define IEEE802154_SUPERFRAME_ORDER_MIN	0x0
+#define IEEE802154_SUPERFRAME_ORDER_MAX	0xf
+
+/**
+ * The maximum time (in superframe periods) that a transaction is stor=
ed by a
+ * coordinator and indicated in its beacon.
+ */
+#define IEEE802154_TRANSACTION_PERSISTENSE_TIME_DEF	0x1f4
+#define IEEE802154_TRANSACTION_PERSISTENSE_TIME_MIN	0x0
+#define IEEE802154_TRANSACTION_PERSISTENSE_TIME_MAX	0xffff
+
+/*********************************************************************=
*********/
+/* PAN Information Base (PIB), MAC security attribute identifiers */
+/* See IEEE802.15.4-2003 draft, Table 71 */
+/*********************************************************************=
*********/
+/** A set of ACL entries, each containing address information, securit=
y suite
+ * information, and security material to be used to protect frames bet=
ween the
+ * MAC sublayer and the specified device.
+ */
+#define IEEE802154_ACL_ENTRY_DESCRIPTOR_SET	0x70
+
+/** The number of entries in the ACL descriptor set. */
+#define IEEE802154_ACL_ENTRY_DESCRIPTOR_SET_SIZE	0x71
+
+/** Indication of whether the device is able to transmit secure frames=
 to or
+ * accept secure frames from devices that are not explicitly listed in=
 the ACL.
+ * It is also used to communicate with multiple devices at once. A val=
ue of
+ * TRUE indicates that such transmissions are permitted.
+ */
+#define IEEE802154_DEFAULT_SECURITY		0x72
+
+/** The number of octets contained in ACLSecurityMaterial. */
+#define IEEE802154_DEFAULT_SECURITY_MLEN	0x73
+
+/** The specific security material to be used to protect frames betwee=
n the MAC
+ * sublayer and devices not in the ACL (see 802.15.4-2003.pdf, item 7.=
6.1.8).
+ */
+#define IEEE802154_DEFAULT_SECURITY_MATERIAL	0x74
+
+/** The unique identifier of the security suite to be used to protect
+ * communications between the MAC and devices not in the ACL as specif=
ied in
+ * 802.15.4-2003.pdf, Table 75.
+ */
+#define IEEE802154_DEFAULT_SECURITY_SUITE	0x75
+
+/** The identifier of the security use as specified in 802.15.4-2003.p=
df, item
+ * 7.5.8.
+ * 0 x 00 =3D Unsecured mode.
+ * 0 x 01 =3D ACL mode.
+ * 0 x 02 =3D Secured mode.
+ */
+#define IEEE802154_SECURITY_MODE		0x76
+
+/*********************************************************************=
*********/
+/* PAN Information Base (PIB), MAC security attribute ranges */
+/* See IEEE802.15.4-2003 draft, Table 72 */
+/*********************************************************************=
*********/
+/** A set of ACL entries, each containing address information, securit=
y suite
+ * information, and security material to be used to protect frames bet=
ween the
+ * MAC sublayer and the specified device.
+ */
+#define IEEE802154_ACL_ENTRY_DESCRIPTOR_SET_DEF	NULL
+
+/** The number of entries in the ACL descriptor set. */
+#define IEEE802154_ACL_ENTRY_DESCRIPTOR_SET_SIZE_DEF	0x0
+#define IEEE802154_ACL_ENTRY_DESCRIPTOR_SET_SIZE_MIN	0x0
+#define IEEE802154_ACL_ENTRY_DESCRIPTOR_SET_SIZE_MAX	0xff
+
+/** Indication of whether the device is able to transmit secure frames=
 to or
+ * accept secure frames from devices that are not explicitly listed in=
 the ACL.
+ * It is also used to communicate with multiple devices at once. A val=
ue of
+ * TRUE indicates that such transmissions are permitted.
+ */
+#define IEEE802154_DEFAULT_SECURITY_DEF		false
+
+/** The number of octets contained in ACLSecurityMaterial. */
+#define IEEE802154_DEFAULT_SECURITY_MLEN_DEF		0x15
+#define IEEE802154_DEFAULT_SECURITY_MLEN_MIN		0x0
+#define IEEE802154_DEFAULT_SECURITY_MLEN_MAX		0x1a
+
+/** The specific security material to be used to protect frames betwee=
n the MAC
+ * sublayer and devices not in the ACL (see 802.15.4-2003.pdf, item 7.=
6.1.8).
+ */
+/*#warning "FIXME: IEEE802154_DEFAULT_SECURITY_MATERIAL_MAX value"*/
+#define IEEE802154_DEFAULT_SECURITY_MATERIAL_DEF	NULL
+#define IEEE802154_DEFAULT_SECURITY_MATERIAL_MIN	NULL
+#define IEEE802154_DEFAULT_SECURITY_MATERIAL_MAX	0x20
+
+/** The unique identifier of the security suite to be used to protect
+ * communications between the MAC and devices not in the ACL as specif=
ied in
+ * 802.15.4-2003.pdf, Table 75.
+ */
+#define IEEE802154_DEFAULT_SECURITY_SUITE_DEF	0x0
+#define IEEE802154_DEFAULT_SECURITY_SUITE_MIN	0x0
+#define IEEE802154_DEFAULT_SECURITY_SUITE_MAX	0x7
+
+/** The identifier of the security use as specified in 802.15.4-2003.p=
df, item
+ * 7.5.8.
+ * 0 x 00 =3D Unsecured mode.
+ * 0 x 01 =3D ACL mode.
+ * 0 x 02 =3D Secured mode.
+ */
+#define IEEE802154_SECURITY_MODE_DEF			0x0
+#define IEEE802154_SECURITY_MODE_MIN			0x0
+#define IEEE802154_SECURITY_MODE_MAX			0x2
+
+
+/****************/
+/* Result codes */
+/****************/
+/**
+ * \brief PHY return codes description
+ *
+ * The return values of PHY operations
+ */
+enum ieee802154_rcodes {
+	/**< The CCA attempt has detected a busy channel */
+	IEEE802154_BUSY =3D 0x0,
+	/** The transceiver is asked to change its state while receiving */
+	IEEE802154_BUSY_RX =3D 0x1,
+	/** The transceiver is asked to change its state while transmitting *=
/
+	IEEE802154_BUSY_TX =3D 0x2,
+	/** The transceiver is to be switched off */
+	IEEE802154_FORCE_TRX_OFF =3D 0x3,
+	/** The CCA attempt has detected an idle channel */
+	IEEE802154_IDLE =3D 0x4,
+	/**
+	 * A SET/GET request was issued with a parameter in the primitive tha=
t
+	 * is out of the valid range
+	 */
+	IEEE802154_PHY_INVALID_PARAMETER =3D 0x5,
+	/**
+	 * The transceiver is in or is to be configured into the receiver
+	 * enabled state
+	 */
+	IEEE802154_RX_ON =3D 0x6,
+	/**
+	 * A SET/GET, an ED operation, or a transceiver state change was
+	 * successful
+	 */
+	IEEE802154_PHY_SUCCESS =3D 0x7,
+	/**
+	 * The transceiver is in or is to be configured into the transceiver
+	 * disabled state
+	 */
+	IEEE802154_TRX_OFF =3D 0x8,
+	/**
+	 * The transceiver is in or is to be configured into the transmitter
+	 * enabled state
+	 */
+	IEEE802154_TX_ON =3D 0x9,
+	/**
+	 * A SET/GET request was issued with the identifier of an attribute t=
hat
+	 * is not supported
+	 */
+	IEEE802154_UNSUPPORTED_ATTRIBUTE =3D 0xa,
+};
+
+/**
+ * \brief MAC return codes description
+ *
+ * The return values of MAC operations
+ */
+enum ieee802154_mac_rcodes {
+	/**
+	 * The requested operation was completed successfully. For a transmis=
sion
+	 * request, this value indicates a successful transmission.
+	 */
+	IEEE802154_SUCCESS =3D 0x0,
+	/**< The disassociation reason code: coordinator kick off device from=
 pan */
+	IEEE802154_KICK_DEV =3D 0x1,
+	/**< The disassociation reason code: device wishes to leave the pan *=
/
+	IEEE802154_LEAVE_DEV =3D 0x2,
+	/**< The beacon was lost following a synchronization request. */
+	IEEE802154_BEACON_LOSS =3D 0xe0,
+	/**
+	 * A transmission could not take place due to activity on the
+	 * channel, i.e., the CSMA-CA mechanism has failed.
+	 */
+	IEEE802154_CHNL_ACCESS_FAIL =3D 0xe1,
+	/**< The GTS request has been denied by the PAN coordinator. */
+	IEEE802154_DENINED =3D 0xe2,
+	/**< The attempt to disable the transceiver has failed. */
+	IEEE802154_DISABLE_TRX_FAIL =3D 0xe3,
+	/**
+	 * The received frame induces a failed security check according to
+	 * the security suite.
+	 */
+	IEEE802154_FAILED_SECURITY_CHECK =3D 0xe4,
+	/**
+	 * The frame resulting from secure processing has a length that is
+	 * greater than aMACMaxFrameSize.
+	 */
+	IEEE802154_FRAME_TOO_LONG =3D 0xe5,
+	/**
+	 * The requested GTS transmission failed because the specified GTS
+	 * either did not have a transmit GTS direction or was not defined.
+	 */
+	IEEE802154_INVALID_GTS =3D 0xe6,
+	/**
+	 * A request to purge an MSDU from the transaction queue was made usi=
ng
+	 * an MSDU handle that was not found in the transaction table.
+	 */
+	IEEE802154_INVALID_HANDLE =3D 0xe7,
+	/**< A parameter in the primitive is out of the valid range.*/
+	IEEE802154_INVALID_PARAMETER =3D 0xe8,
+	/**< No acknowledgment was received after aMaxFrameRetries. */
+	IEEE802154_NO_ACK =3D 0xe9,
+	/**< A scan operation failed to find any network beacons.*/
+	IEEE802154_NO_BEACON =3D 0xea,
+	/**< No response data were available following a request. */
+	IEEE802154_NO_DATA =3D 0xeb,
+	/**< The operation failed because a short address was not allocated. =
*/
+	IEEE802154_NO_SHORT_ADDRESS =3D 0xec,
+	/**
+	 * A receiver enable request was unsuccessful because it could not be
+	 * completed within the CAP.
+	 */
+	IEEE802154_OUT_OF_CAP =3D 0xed,
+	/**
+	 * A PAN identifier conflict has been detected and communicated to th=
e
+	 * PAN coordinator.
+	 */
+	IEEE802154_PANID_CONFLICT =3D 0xee,
+	/**< A coordinator realignment command has been received. */
+	IEEE802154_REALIGMENT =3D 0xef,
+	/**< The transaction has expired and its information discarded. */
+	IEEE802154_TRANSACTION_EXPIRED =3D 0xf0,
+	/**< There is no capacity to store the transaction. */
+	IEEE802154_TRANSACTION_OVERFLOW =3D 0xf1,
+	/**
+	 * The transceiver was in the transmitter enabled state when the
+	 * receiver was requested to be enabled.
+	 */
+	IEEE802154_TX_ACTIVE =3D 0xf2,
+	/**< The appropriate key is not available in the ACL. */
+	IEEE802154_UNAVAILABLE_KEY =3D 0xf3,
+	/**
+	 * A SET/GET request was issued with the identifier of a PIB attribut=
e
+	 * that is not supported.
+	 */
+	IEEE802154_UNSUPPORTED_ATTR =3D 0xf4,
+	/*
+	 * A request to perform a scan operation failed because the MLME was
+	 * in the process of performing a previously initiated scan operation=
=2E
+	 */
+	IEEE802154_SCAN_IN_PROGRESS =3D 0xfc,
+};
+
+/**
+ * other errors
+ */
+#define IEEE802154_ERROR	0xff
+
+#define ZB_ED_MAX	0xff
+#define ZB_ED_MIN	0x0
+/* #define ZB_ED_EDGE	0x7f */
+/* I've got 0xBE on idle channel; let threshold be a little higher */
+#define ZB_ED_EDGE	0xc8
+
+/* In an ideal world this should be 1 */
+#define IEEE802154_SLOW_SERIAL_FIXUP	75
+
+#endif /* IEEE802154_CONST_H */
diff --git a/include/net/ieee802154/crc.h b/include/net/ieee802154/crc.=
h
new file mode 100644
index 0000000..5b37218
--- /dev/null
+++ b/include/net/ieee802154/crc.h
@@ -0,0 +1,38 @@
+/*
+ * based on crc-itu-t.c.
+ * Basically it's CRC-ITU-T but with inverted bit numbering
+ *
+ * Copyright 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long
+ * with this program; if not, write to the Free Software Foundation, I=
nc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * 	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ */
+
+extern const u16 ieee802154_crc_table[256];
+
+static inline u16 ieee802154_crc_byte(u16 crc, const u8 data)
+{
+	return (crc >> 8) ^ ieee802154_crc_table[(crc ^ data) & 0xff];
+}
+
+static inline u16 ieee802154_crc(u16 crc, const u8 *buffer, size_t len=
)
+{
+	while (len--)
+		crc =3D ieee802154_crc_byte(crc, *buffer++);
+	return crc;
+}
+
+
diff --git a/include/net/ieee802154/dev.h b/include/net/ieee802154/dev.=
h
new file mode 100644
index 0000000..1d28187
--- /dev/null
+++ b/include/net/ieee802154/dev.h
@@ -0,0 +1,107 @@
+/*
+ * IEEE802.15.4-2003 specification
+ *
+ * Copyright (C) 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long
+ * with this program; if not, write to the Free Software Foundation, I=
nc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ */
+#ifndef IEEE802154_DEV_H
+#define IEEE802154_DEV_H
+
+#include <linux/skbuff.h>
+#include <net/ieee802154/phy.h>
+#include <net/ieee802154/const.h>
+
+struct ieee802154_pib {
+	int type;
+	u32 val;
+};
+
+#define IEEE802154_PIB_CURCHAN	0 /* Current channel, u8 6.1.2 */
+#define IEEE802154_PIB_CHANSUPP	1 /* Channel mask, u32 6.1.2 */
+#define IEEE802154_PIB_TRPWR	2 /* Transmit power, u8 6.4.2  */
+#define IEEE802154_PIB_CCAMODE	3 /* CCA mode, u8 6.7.9 */
+
+struct ieee802154_dev {
+	const char *name;
+	int	extra_tx_headroom; /* headroom to reserve for tx skb */
+	void	*priv;		/* driver-specific data */
+	u32	channel_mask;
+	u8	current_channel;
+	u32 flags; /* Flags for device to set */
+	struct device *parent;
+};
+
+/* Checksum is in hardware and is omitted from packet */
+#define IEEE802154_OPS_OMIT_CKSUM	(1 << 0)
+
+
+struct ieee802154_ops {
+	struct module	*owner;
+	phy_status_t (*tx)(struct ieee802154_dev *dev, struct sk_buff *skb);
+	phy_status_t (*cca)(struct ieee802154_dev *dev);
+	phy_status_t (*ed)(struct ieee802154_dev *dev, u8 *level);
+	phy_status_t (*set_trx_state)(struct ieee802154_dev *dev, phy_status_=
t state);
+	phy_status_t (*set_channel)(struct ieee802154_dev *dev, int channel);
+	/* FIXME: PIB get/set ??? */
+};
+
+#ifdef __KERNEL__
+#define IEEE802154_MAC_CMD_SCAN		0
+
+struct ieee802154_priv {
+	struct ieee802154_dev	hw;
+	struct ieee802154_ops	*ops;
+	struct net_device	*master;
+	struct list_head	slaves;
+	spinlock_t		slaves_lock;
+	/* This one is used for scanning and other
+	 * jobs not to be interfered with serial driver */
+	struct workqueue_struct	*dev_workqueue;
+	/* MAC BSN field */
+	u8 bsn;
+	/* MAC BSN field */
+	u8 dsn;
+};
+
+#define ieee802154_to_priv(_hw)	container_of(_hw, struct ieee802154_pr=
iv, hw)
+
+#endif
+
+struct ieee802154_dev *ieee802154_alloc_device(void);
+int ieee802154_register_device(struct ieee802154_dev *dev, struct ieee=
802154_ops *ops);
+void ieee802154_unregister_device(struct ieee802154_dev *dev);
+void ieee802154_free_device(struct ieee802154_dev *dev);
+
+int ieee802154_add_slave(struct ieee802154_dev *hw, const u8 *addr);
+/* void ieee802154_del_slave(struct ieee802154_dev *hw, struct net_dev=
ice *slave); */
+void ieee802154_drop_slaves(struct ieee802154_dev *hw);
+
+void ieee802154_rx(struct ieee802154_dev *dev, struct sk_buff *skb, u8=
 lqi);
+void ieee802154_rx_irqsafe(struct ieee802154_dev *dev, struct sk_buff =
*skb, u8 lqi);
+
+int ieee802154_pib_set(struct ieee802154_dev *hw, struct ieee802154_pi=
b *pib);
+int ieee802154_pib_get(struct ieee802154_dev *hw, struct ieee802154_pi=
b *pib);
+
+int ieee802154_slave_register_notifier(struct net_device *dev, struct =
notifier_block *nb);
+int ieee802154_slave_unregister_notifier(struct net_device *dev, struc=
t notifier_block *nb);
+int ieee802154_slave_event(struct net_device *dev, int event, void *da=
ta);
+
+#define IEEE802154_NOTIFIER_BEACON		0x0
+
+void ieee802154_set_pan_id(struct net_device *dev, u16 panid);
+#endif
+
diff --git a/include/net/ieee802154/mac_def.h b/include/net/ieee802154/=
mac_def.h
new file mode 100644
index 0000000..42597f7
--- /dev/null
+++ b/include/net/ieee802154/mac_def.h
@@ -0,0 +1,96 @@
+/*
+ * IEEE802.15.4-2003 specification
+ *
+ * Copyright (C) 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long
+ * with this program; if not, write to the Free Software Foundation, I=
nc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Pavel Smolenskiy <pavel.smolenskiy@gmail.com>
+ * Maxim Gorbachyov <maxim.gorbachev@siemens.com>
+ * Maxim Osipov <maxim.osipov@siemens.com>
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ */
+
+#ifndef IEEE802154_MAC_DEF_H
+#define IEEE802154_MAC_DEF_H
+
+#define IEEE802154_PANID_BROADCAST	0xffff
+#define IEEE802154_ADDR_BROADCAST	0xffff
+#define IEEE802154_ADDR_UNDEF		0xfffe
+
+#define IEEE802154_FC_TYPE_BEACON	0x0	/* Frame is beacon */
+#define	IEEE802154_FC_TYPE_DATA		0x1	/* Frame is data */
+#define IEEE802154_FC_TYPE_ACK		0x2	/* Frame is acknowledgment */
+#define IEEE802154_FC_TYPE_MAC_CMD	0x3	/* Frame is MAC command */
+
+#define IEEE802154_FC_TYPE_SHIFT		0
+#define IEEE802154_FC_TYPE_MASK		((1 << 3) - 1)
+#define IEEE802154_FC_TYPE(x)		((x & IEEE802154_FC_TYPE_MASK) >> IEEE8=
02154_FC_TYPE_SHIFT)
+#define IEEE802154_FC_SET_TYPE(v, x)	do {v =3D (((v) & ~IEEE802154_FC_=
TYPE_MASK) | \
+						(((x) << IEEE802154_FC_TYPE_SHIFT) \
+						& IEEE802154_FC_TYPE_MASK)); } while (0)
+
+#define IEEE802154_FC_SECEN		(1 << 3)
+#define IEEE802154_FC_FRPEND		(1 << 4)
+#define IEEE802154_FC_ACK_REQ		(1 << 5)
+#define IEEE802154_FC_INTRA_PAN		(1 << 6)
+
+#define IEEE802154_FC_SAMODE_SHIFT	14
+#define IEEE802154_FC_SAMODE_MASK	(3 << IEEE802154_FC_SAMODE_SHIFT)
+#define IEEE802154_FC_DAMODE_SHIFT	10
+#define IEEE802154_FC_DAMODE_MASK	(3 << IEEE802154_FC_DAMODE_SHIFT)
+
+#define IEEE802154_FC_SAMODE(x)		\
+		(((x) & IEEE802154_FC_SAMODE_MASK) >> IEEE802154_FC_SAMODE_SHIFT)
+
+#define IEEE802154_FC_DAMODE(x)		\
+		(((x) & IEEE802154_FC_DAMODE_MASK) >> IEEE802154_FC_DAMODE_SHIFT)
+
+
+/* MAC's Command Frames Identifiers */
+#define IEEE802154_CMD_ASSOCIATION_REQ		0x01
+#define IEEE802154_CMD_ASSOCIATION_RESP		0x02
+#define IEEE802154_CMD_DISASSOCIATION_NOTIFY	0x03
+#define IEEE802154_CMD_DATA_REQ			0x04
+#define IEEE802154_CMD_PANID_CONFLICT_NOTIFY	0x05
+#define IEEE802154_CMD_ORPHAN_NOTIFY		0x06
+#define IEEE802154_CMD_BEACON_REQ		0x07
+#define IEEE802154_CMD_COORD_REALIGN_NOTIFY	0x08
+#define IEEE802154_CMD_GTS_REQ			0x09
+
+#ifdef __KERNEL__
+int ieee802154_process_cmd(struct net_device *dev, struct sk_buff *skb=
);
+
+int ieee802154_send_cmd(struct net_device *dev,
+		struct ieee802154_addr *addr, struct ieee802154_addr *saddr,
+		const u8 *buf, int len);
+
+int ieee802154_send_beacon_req(struct net_device *dev);
+int ieee802154_mlme_scan_req(struct net_device *dev, u8 type, u32 chan=
nels, u8 duration);
+
+int ieee802154_mlme_start_req(struct net_device *dev, u16 panid, u8 ch=
annel,
+			     u8 bcn_ord, u8 sf_ord, u8 pan_coord, u8 blx,
+			     u8 coord_realign, u8 sec);
+
+#define IEEE802154_MAC_SCAN_ED		0
+#define IEEE802154_MAC_SCAN_ACTIVE	1
+#define IEEE802154_MAC_SCAN_PASSIVE	2
+#define IEEE802154_MAC_SCAN_ORPHAN	3
+
+#endif
+
+#endif
+
+
diff --git a/include/net/ieee802154/netdev.h b/include/net/ieee802154/n=
etdev.h
new file mode 100644
index 0000000..80a22bd
--- /dev/null
+++ b/include/net/ieee802154/netdev.h
@@ -0,0 +1,74 @@
+/*
+ * IEEE802154.4 net device
+ *
+ * Copyright 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long
+ * with this program; if not, write to the Free Software Foundation, I=
nc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ */
+
+#ifndef IEEE802154_NETDEV_H
+#define IEEE802154_NETDEV_H
+#include <linux/netdevice.h>
+#include <net/ieee802154/dev.h>
+#include <net/ieee802154/phy.h>
+#include <net/ieee802154/af_ieee802154.h>
+
+int ieee802154_register_netdev_master(struct ieee802154_priv *hw);
+void ieee802154_unregister_netdev_master(struct ieee802154_priv *hw);
+
+/* FIXME: this header should be probably separated, as it contains bot=
h driver-specific and stack specific things */
+void ieee802154_subif_rx(struct ieee802154_dev *hw, struct sk_buff *sk=
b);
+struct ieee802154_priv *ieee802154_slave_get_hw(struct net_device *dev=
);
+
+struct ieee802154_addr;
+struct net_device *ieee802154_get_dev(struct net *net, struct ieee8021=
54_addr *sa);
+
+/* FIXME: should be dropped in favour of MIB getting */
+u16 ieee802154_dev_get_pan_id(struct net_device *dev);
+u16 ieee802154_dev_get_short_addr(struct net_device *dev);
+void ieee802154_dev_set_pan_id(struct net_device *dev, u16 val);
+void ieee802154_dev_set_short_addr(struct net_device *dev, u16 val);
+void ieee802154_dev_set_channel(struct net_device *dev, u8 chan);
+
+struct ieee802154_phy_cb {
+	u8 lqi;
+	u8 chan;
+};
+
+#define PHY_CB(skb)	((struct ieee802154_phy_cb *)(skb)->cb)
+
+
+struct ieee802154_mac_cb {
+	struct ieee802154_phy_cb phy;
+	struct ieee802154_addr sa;
+	struct ieee802154_addr da;
+	u8 flags;
+	u8 seq;
+};
+#define MAC_CB(skb)	((struct ieee802154_mac_cb *)(skb)->cb)
+
+#define MAC_CB_FLAG_TYPEMASK		((1 << 3) - 1)
+
+#define MAC_CB_FLAG_ACKREQ		(1 << 3)
+#define MAC_CB_FLAG_SECEN		(1 << 4)
+#define MAC_CB_FLAG_INTRAPAN		(1 << 5)
+
+#define MAC_CB_IS_ACKREQ(skb)		(MAC_CB(skb)->flags & MAC_CB_FLAG_ACKRE=
Q)
+#define MAC_CB_IS_SECEN(skb)		(MAC_CB(skb)->flags & MAC_CB_FLAG_SECEN)
+#define MAC_CB_IS_INTRAPAN(skb)		(MAC_CB(skb)->flags & MAC_CB_FLAG_INT=
RAPAN)
+#define MAC_CB_TYPE(skb)		(MAC_CB(skb)->flags & MAC_CB_FLAG_TYPEMASK)
+
+#endif
+
diff --git a/include/net/ieee802154/nl.h b/include/net/ieee802154/nl.h
new file mode 100644
index 0000000..311a1da
--- /dev/null
+++ b/include/net/ieee802154/nl.h
@@ -0,0 +1,166 @@
+/*
+ * ieee802154_nl.h
+ *
+ * Copyright (C) 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long
+ * with this program; if not, write to the Free Software Foundation, I=
nc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ */
+
+#ifndef IEEE802154_NL_H
+#define IEEE802154_NL_H
+
+#define IEEE802154_NL_NAME "802.15.4 MAC"
+#define IEEE802154_MCAST_COORD_NAME "coordinator"
+#define IEEE802154_MCAST_BEACON_NAME "beacon"
+
+enum {
+	__IEEE802154_ATTR_INVALID,
+
+	IEEE802154_ATTR_DEV_NAME,
+	IEEE802154_ATTR_DEV_INDEX,
+
+	IEEE802154_ATTR_STATUS,
+
+	IEEE802154_ATTR_SHORT_ADDR,
+	IEEE802154_ATTR_HW_ADDR,
+	IEEE802154_ATTR_PAN_ID,
+
+	IEEE802154_ATTR_CHANNEL,
+
+	IEEE802154_ATTR_COORD_SHORT_ADDR,
+	IEEE802154_ATTR_COORD_HW_ADDR,
+	IEEE802154_ATTR_COORD_PAN_ID,
+
+	IEEE802154_ATTR_SRC_SHORT_ADDR,
+	IEEE802154_ATTR_SRC_HW_ADDR,
+	IEEE802154_ATTR_SRC_PAN_ID,
+
+	IEEE802154_ATTR_DEST_SHORT_ADDR,
+	IEEE802154_ATTR_DEST_HW_ADDR,
+	IEEE802154_ATTR_DEST_PAN_ID,
+
+	IEEE802154_ATTR_CAPABILITY, /* FIXME: this is association */
+	IEEE802154_ATTR_REASON,
+	IEEE802154_ATTR_SCAN_TYPE,
+	IEEE802154_ATTR_CHANNELS,
+	IEEE802154_ATTR_DURATION,
+	IEEE802154_ATTR_ED_LIST,
+	IEEE802154_ATTR_BCN_ORD,
+	IEEE802154_ATTR_SF_ORD,
+	IEEE802154_ATTR_PAN_COORD,
+	IEEE802154_ATTR_BAT_EXT,
+	IEEE802154_ATTR_COORD_REALIGN,
+	IEEE802154_ATTR_SEC,
+
+	__IEEE802154_ATTR_MAX,
+};
+
+#define IEEE802154_ATTR_MAX (__IEEE802154_ATTR_MAX - 1)
+#define NLA_HW_ADDR	NLA_U64
+#define NLA_GET_HW_ADDR(attr, addr) do { u64 _temp =3D nla_get_u64(att=
r); memcpy(addr, &_temp, 8); } while (0)
+#define NLA_PUT_HW_ADDR(msg, attr, addr) do { u64 _temp; memcpy(&_temp=
, addr, 8); NLA_PUT_U64(msg, attr, _temp); } while (0)
+
+#ifdef IEEE802154_NL_WANT_POLICY
+static struct nla_policy ieee802154_policy[IEEE802154_ATTR_MAX + 1] =3D=
 {
+	[IEEE802154_ATTR_DEV_NAME] =3D { .type =3D NLA_STRING, },
+	[IEEE802154_ATTR_DEV_INDEX] =3D { .type =3D NLA_U32, },
+
+	[IEEE802154_ATTR_STATUS] =3D { .type =3D NLA_U8, },
+	[IEEE802154_ATTR_SHORT_ADDR] =3D { .type =3D NLA_U16, },
+	[IEEE802154_ATTR_HW_ADDR] =3D { .type =3D NLA_HW_ADDR, },
+	[IEEE802154_ATTR_PAN_ID] =3D { .type =3D NLA_U16, },
+	[IEEE802154_ATTR_CHANNEL] =3D { .type =3D NLA_U8, },
+	[IEEE802154_ATTR_COORD_SHORT_ADDR] =3D { .type =3D NLA_U16, },
+	[IEEE802154_ATTR_COORD_HW_ADDR] =3D { .type =3D NLA_HW_ADDR, },
+	[IEEE802154_ATTR_COORD_PAN_ID] =3D { .type =3D NLA_U16, },
+	[IEEE802154_ATTR_SRC_SHORT_ADDR] =3D { .type =3D NLA_U16, },
+	[IEEE802154_ATTR_SRC_HW_ADDR] =3D { .type =3D NLA_HW_ADDR, },
+	[IEEE802154_ATTR_SRC_PAN_ID] =3D { .type =3D NLA_U16, },
+	[IEEE802154_ATTR_DEST_SHORT_ADDR] =3D { .type =3D NLA_U16, },
+	[IEEE802154_ATTR_DEST_HW_ADDR] =3D { .type =3D NLA_HW_ADDR, },
+	[IEEE802154_ATTR_DEST_PAN_ID] =3D { .type =3D NLA_U16, },
+
+	[IEEE802154_ATTR_CAPABILITY] =3D { .type =3D NLA_U8, },
+	[IEEE802154_ATTR_REASON] =3D { .type =3D NLA_U8, },
+	[IEEE802154_ATTR_SCAN_TYPE] =3D { .type =3D NLA_U8, },
+	[IEEE802154_ATTR_CHANNELS] =3D { .type =3D NLA_U32, },
+	[IEEE802154_ATTR_DURATION] =3D { .type =3D NLA_U8, },
+#ifdef __KERNEL__
+	[IEEE802154_ATTR_ED_LIST] =3D { .len =3D 27 },
+#else
+	[IEEE802154_ATTR_ED_LIST] =3D { .minlen =3D 27, .maxlen =3D 27 },
+#endif
+};
+#endif
+
+/* commands */
+/* REQ should be responded with CONF
+ * and INDIC with RESP
+ */
+enum {
+	__IEEE802154_COMMAND_INVALID,
+
+	IEEE802154_ASSOCIATE_REQ,
+	IEEE802154_ASSOCIATE_CONF,
+	IEEE802154_DISASSOCIATE_REQ,
+	IEEE802154_DISASSOCIATE_CONF,
+	IEEE802154_GET_REQ,
+	IEEE802154_GET_CONF,
+/* 	IEEE802154_GTS_REQ, */
+/* 	IEEE802154_GTS_CONF, */
+	IEEE802154_RESET_REQ,
+	IEEE802154_RESET_CONF,
+/* 	IEEE802154_RX_ENABLE_REQ, */
+/* 	IEEE802154_RX_ENABLE_CONF, */
+	IEEE802154_SCAN_REQ,
+	IEEE802154_SCAN_CONF,
+	IEEE802154_SET_REQ,
+	IEEE802154_SET_CONF,
+	IEEE802154_START_REQ,
+	IEEE802154_START_CONF,
+	IEEE802154_SYNC_REQ,
+	IEEE802154_POLL_REQ,
+	IEEE802154_POLL_CONF,
+
+	IEEE802154_ASSOCIATE_INDIC,
+	IEEE802154_ASSOCIATE_RESP,
+	IEEE802154_DISASSOCIATE_INDIC,
+	IEEE802154_BEACON_NOTIFY_INDIC,
+/* 	IEEE802154_GTS_INDIC, */
+	IEEE802154_ORPHAN_INDIC,
+	IEEE802154_ORPHAN_RESP,
+	IEEE802154_COMM_STATUS_INDIC,
+	IEEE802154_SYNC_LOSS_INDIC,
+
+	__IEEE802154_CMD_MAX,
+};
+
+#define IEEE802154_CMD_MAX (__IEEE802154_CMD_MAX - 1)
+
+
+#ifdef __KERNEL__
+int ieee802154_nl_init(void);
+void ieee802154_nl_exit(void);
+
+int ieee802154_nl_assoc_indic(struct net_device *dev, struct ieee80215=
4_addr *addr, u8 cap);
+int ieee802154_nl_assoc_confirm(struct net_device *dev, u16 short_addr=
, u8 status);
+int ieee802154_nl_disassoc_indic(struct net_device *dev, struct ieee80=
2154_addr *addr, u8 reason);
+int ieee802154_nl_disassoc_confirm(struct net_device *dev, u8 status);
+int ieee802154_nl_scan_confirm(struct net_device *dev, u8 status, u8 s=
can_type, u32 unscanned,
+		u8 *edl/*, struct list_head *pan_desc_list */);
+int ieee802154_nl_beacon_indic(struct net_device *dev, u16 panid, u16 =
coord_addr); /* TODO */
+#endif
+
+#endif
diff --git a/include/net/ieee802154/phy.h b/include/net/ieee802154/phy.=
h
new file mode 100644
index 0000000..ca154fa
--- /dev/null
+++ b/include/net/ieee802154/phy.h
@@ -0,0 +1,117 @@
+/*
+ * IEEE802.15.4-2003 specification
+ * Physical interface.
+ *
+ * Copyright (C) 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long
+ * with this program; if not, write to the Free Software Foundation, I=
nc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Pavel Smolenskiy <pavel.smolenskiy@gmail.com>
+ * Maxim Gorbachyov <maxim.gorbachev@siemens.com>
+ * Maxim Osipov <maxim.osipov@siemens.com>
+ */
+
+#ifndef IEEE802154_PHY_H
+#define IEEE802154_PHY_H
+
+/*********************************************************************=
*********/
+/* PHY constants */
+/*********************************************************************=
*********/
+/** The maximum PSDU size (in octets) the PHY shall be able to receive=
,
+ * 127 octets
+ */
+#define IEEE802154_MAX_PHY_PACKET_SIZE	127
+
+/** RX-to-TX or TX-to-RX maximum turnaround time in symbol periods */
+#define IEEE802154_TURNAROUND_TIME 	12
+
+/*********************************************************************=
*********/
+/* PAN Information Base (PIB), PHY attribute identifiers */
+/* See IEEE802.15.4-2003 draft, Table 19 */
+/*********************************************************************=
*********/
+/**
+ * The RF channel to use for all following transmissions and reception=
s
+ * (Integer, 0-26)
+ */
+#define IEEE802154_PHY_CURRENT_CHANNEL		0x00
+
+/**
+ * The 5 most significant bits (MSBs) (b27,... ,b31) of phyChannelsSup=
ported
+ * shall be reserved and set to 0, and the 27 LSBs (b0,b1, ... b26) sh=
all
+ * indicate the status (1=3Davailable, 0=3Dunavailable) for each of th=
e 27 valid
+ * channels (bk shall indicate the status of channel k) (Bitmap)
+ */
+#define IEEE802154_PHY_CHANNELS_SUPPORTED	0x01
+
+/**
+ * The 2 MSBs represent the tolerance on the transmit power:
+ *
+ * 00 =3D +- 1 dB
+ * 01 =3D +- 3 dB
+ * 02 =3D +- 6 dB
+ *
+ * The 6 LSBs represent a signed integer in twos-complement format,
+ * corresponding to the nominal transmit power of the device in decibe=
ls
+ * relative to 1 mW. The lowest value of phyTransmitPower shall be int=
erpreted
+ * as less than or equal -32 dBm (Bitmap, 0x00-0xBF)
+ */
+#define IEEE802154_PHY_TRANSMIT_POWER	0x02
+
+/** The CCA mode (Integer, 1-3) */
+#define IEEE802154_PHY_CCA_MODE		0x03
+
+#define IEEE802154_CCA_ED		0x1
+#define IEEE802154_CCA_CS		0x2
+#define IEEE802154_CCA_CSED		0x3
+
+/*********************************************************************=
*********/
+/* PAN Information Base (PIB), attribute ranges */
+/* See IEEE802.15.4-2003 draft, Table 19 */
+/*********************************************************************=
*********/
+#define IEEE802154_PHY_CURRENT_CHANNEL_MIN	0x0
+#define IEEE802154_PHY_CURRENT_CHANNEL_MAX	0x1a
+
+#define IEEE802154_PHY_CHANNELS_SUPPORTED_MIN	0x0
+#define IEEE802154_PHY_CHANNELS_SUPPORTED_MAX	0x7FFFFFF
+
+#define IEEE802154_PHY_TRANSMIT_POWER_MIN	0x0
+#define IEEE802154_PHY_TRANSMIT_POWER_MAX	0xbf
+
+#define IEEE802154_PHY_CCA_MODE_MIN		0x1
+#define IEEE802154_PHY_CCA_MODE_MAX		0x3
+
+#ifdef __KERNEL__
+
+typedef enum {
+	PHY_BUSY =3D 0, /* cca */
+	PHY_BUSY_RX, /* state */
+	PHY_BUSY_TX, /* state */
+	PHY_FORCE_TRX_OFF,
+	PHY_IDLE, /* cca */
+	PHY_INVALID_PARAMETER, /* pib get/set */
+	PHY_RX_ON, /* state */
+	PHY_SUCCESS, /* ed */
+	PHY_TRX_OFF, /* cca, ed, state */
+	PHY_TX_ON, /* cca, ed, state */
+	PHY_UNSUPPORTED_ATTRIBUTE, /* pib get/set */
+	PHY_READ_ONLY, /* pib get/set */
+
+	PHY_INVAL =3D -1, /* all */
+	PHY_ERROR =3D -2, /* all */
+} phy_status_t;
+
+#endif /* __KERNEL__ */
+
+#endif
diff --git a/net/Kconfig b/net/Kconfig
index c19f549..7051b97 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -179,6 +179,7 @@ source "net/lapb/Kconfig"
 source "net/econet/Kconfig"
 source "net/wanrouter/Kconfig"
 source "net/phonet/Kconfig"
+source "net/ieee802154/Kconfig"
 source "net/sched/Kconfig"
 source "net/dcb/Kconfig"
=20
diff --git a/net/Makefile b/net/Makefile
index 9e00a55..ba324ae 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -60,6 +60,7 @@ obj-$(CONFIG_NET_9P)		+=3D 9p/
 ifneq ($(CONFIG_DCB),)
 obj-y				+=3D dcb/
 endif
+obj-y				+=3D ieee802154/
=20
 ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_SYSCTL)		+=3D sysctl_net.o
diff --git a/net/ieee802154/Kconfig b/net/ieee802154/Kconfig
new file mode 100644
index 0000000..f540cd1
--- /dev/null
+++ b/net/ieee802154/Kconfig
@@ -0,0 +1,12 @@
+config IEEE802154
+	tristate "IEEE Std 802.15.4 Low-Rate Wireless Personal Area Networks =
support (EXPERIMENTAL)"
+	depends on EXPERIMENTAL
+	---help---
+	  IEEE Std 802.15.4 defines a low data rate, low power and low comple=
xity
+	  short range wireless personal area networks. It was designed to
+	  organise networks of sensors, switches, etc automation devices. Max=
imum
+	  allowed data rate is 250 kb/s and typical personal operating space
+	  around 10m.
+
+	  Say Y here to compile LR-WPAN support into the kernel or say M to
+	  compile it as modules.
diff --git a/net/ieee802154/Makefile b/net/ieee802154/Makefile
new file mode 100644
index 0000000..d964365
--- /dev/null
+++ b/net/ieee802154/Makefile
@@ -0,0 +1,5 @@
+obj-$(CONFIG_IEEE802154) +=3D	ieee802154.o
+ieee802154-objs		:=3D main.o mdev.o dev.o netlink.o mac_cmd.o scan.o \
+			crc.o beacon.o beacon_hash.o start.o
+
+EXTRA_CFLAGS +=3D -Wall -DDEBUG
diff --git a/net/ieee802154/beacon.c b/net/ieee802154/beacon.c
new file mode 100644
index 0000000..72a5ac3
--- /dev/null
+++ b/net/ieee802154/beacon.c
@@ -0,0 +1,251 @@
+/*
+ * MAC beacon interface
+ *
+ * Copyright 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long
+ * with this program; if not, write to the Free Software Foundation, I=
nc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Sergey Lapin <sergey.lapin@siemens.com>
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ */
+
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+#include <linux/if_ether.h>
+#include <linux/list.h>
+
+#include <net/ieee802154/af_ieee802154.h>
+#include <net/ieee802154/mac_def.h>
+#include <net/ieee802154/netdev.h>
+#include <net/ieee802154/beacon.h>
+#include <net/ieee802154/nl.h>
+
+/* Beacon frame format per specification is the followinf:
+ * Standard MAC frame header:
+ * FC (2) SEQ (1)
+ * Addressing (4-20)
+ * Beacon fields:
+ * <Superframe specification> (2)
+ * <GTS> (?)
+ * <Pending address> (?)
+ * <Beacon payload> (?)
+ * FCS (2)
+ *
+ * Superframe specification:
+ * bit   Value
+ * 15    Association permit
+ * 14    PAN coordinator
+ * 13    Reserved
+ * 12    Battery life extension
+ * 8-11  Final CAP slot
+ * 4-7   Superframe order
+ * 0-3   Beacon order
+ *
+ * GTS:
+ * <GTS specification> (1)
+ * <GTS directions> (0-1)
+ * <GTS list> (?)
+ *
+ * Pending address:
+ * <Pending address specification> (1)
+ * <Pending address list (?)
+ *
+ * GTS specification:
+ * bit   Value
+ * 7     GTS permit
+ * 3-6   Reserved
+ * 0-2   GTS descriptor count
+ *
+ * Pending address specification:
+ * bit   Value
+ * 7     Reserved
+ * 4-6   Number of extended addresses pendinf
+ * 3     Reserved
+ * 0-2   Number of short addresses pending
+ * */
+
+#define IEEE802154_BEACON_SF_BO_BEACONLESS	(15 << 0)
+#define IEEE802154_BEACON_SF_SO(x)		((x & 0xf) << 4)
+#define IEEE802154_BEACON_SF_SO_INACTIVE		IEEE802154_BEACON_SF_SO(15)
+#define IEEE802154_BEACON_SF_PANCOORD		(1 << 14)
+#define IEEE802154_BEACON_SF_CANASSOC		(1 << 15)
+#define IEEE802154_BEACON_GTS_COUNT(x)		(x << 0)
+#define IEEE802154_BEACON_GTS_PERMIT		(1 << 7)
+#define IEEE802154_BEACON_PA_SHORT(x)		((x & 7) << 0)
+#define IEEE802154_BEACON_PA_LONG(x)		((x & 7) << 4)
+
+/* Flags parameter */
+#define IEEE802154_BEACON_FLAG_PANCOORD		(1 << 0)
+#define IEEE802154_BEACON_FLAG_CANASSOC		(1 << 1)
+#define IEEE802154_BEACON_FLAG_GTSPERMIT		(1 << 2)
+
+struct ieee802154_address_list {
+	struct list_head list;
+	struct ieee802154_addr addr;
+};
+/*
+ * @dev device
+ * @addr destination address
+ * @saddr source address
+ * @buf beacon payload
+ * @len beacon payload size
+ * @pan_coord - if we're PAN coordinator while sending this frame
+ * @gts_permit - wheather we allow GTS requests
+ * @al address list to be provided in beacon
+ *
+ * TODO:
+ * For a beacon frame, the sequence number field shall specify a BSN.
+ * Each coordinator shall store its current
+ * BSN value in the MAC PIB attribute macBSN and initialize it to a ra=
ndom value.
+ * The algorithm for choosing a random number is out of the scope
+ * of this standard. The coordinator shall copy the value of the macBS=
N
+ * attribute into the sequence number field of a beacon frame,
+ * each time one is generated, and shall then increment macBSN by one.
+ *
+*/
+
+
+int ieee802154_send_beacon(struct net_device *dev, struct ieee802154_a=
ddr *saddr,
+		u16 pan_id, const u8 *buf, int len,
+		int flags, struct list_head *al)
+{
+	struct sk_buff *skb;
+	int err;
+	u16 sf;
+	u8 gts;
+	u8 pa_spec;
+	int addr16_cnt;
+	int addr64_cnt;
+	struct ieee802154_addr addr;
+	struct ieee802154_priv *hw =3D ieee802154_slave_get_hw(dev);
+
+	BUG_ON(dev->type !=3D ARPHRD_IEEE802154);
+
+	skb =3D alloc_skb(LL_ALLOCATED_SPACE(dev) + len, GFP_ATOMIC);
+	if (!skb)
+		return -ENOMEM;
+
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+
+	skb_reset_network_header(skb);
+
+	MAC_CB(skb)->flags =3D IEEE802154_FC_TYPE_BEACON;
+	MAC_CB(skb)->seq =3D hw->bsn;
+
+	addr.addr_type =3D IEEE802154_ADDR_NONE;
+	err =3D dev_hard_header(skb, dev, ETH_P_IEEE802154, &addr, saddr, len=
);
+	if (err < 0) {
+		kfree_skb(skb);
+		return err;
+	}
+	skb_reset_mac_header(skb);
+
+	/* Superframe */
+	sf =3D IEEE802154_BEACON_SF_BO_BEACONLESS;
+	sf |=3D IEEE802154_BEACON_SF_SO_INACTIVE;
+	if (flags & IEEE802154_BEACON_FLAG_PANCOORD)
+		sf |=3D IEEE802154_BEACON_SF_PANCOORD;
+
+	if (flags & IEEE802154_BEACON_FLAG_CANASSOC)
+		sf |=3D IEEE802154_BEACON_SF_CANASSOC;
+	memcpy(skb_put(skb,  sizeof(sf)), &sf, sizeof(sf));
+
+	/* TODO GTS */
+	gts =3D 0;
+
+	if (flags & IEEE802154_BEACON_FLAG_GTSPERMIT)
+		gts |=3D IEEE802154_BEACON_GTS_PERMIT;
+	memcpy(skb_put(skb, sizeof(gts)), &gts, sizeof(gts));
+
+	/* FIXME pending address */
+	addr16_cnt =3D 0;
+	addr64_cnt =3D 0;
+#if 0
+	/* need more thinking about this */
+	list_for_each_entry(l, al->list, list) {
+		struct ieee802154_addr *s =3D container_of(l, struct list_head, list=
);
+		if (s->addr_type =3D=3D IEEE802154_ADDR_LONG)
+			addr16_cnt++;
+
+		if (s->addr_type =3D=3D IEEE802154_ADDR_SHORT)
+			addr64_cnt++;
+	}
+#endif
+	pa_spec =3D IEEE802154_BEACON_PA_LONG(addr64_cnt) | IEEE802154_BEACON=
_PA_SHORT(addr16_cnt);
+	memcpy(skb_put(skb, sizeof(pa_spec)), &pa_spec, sizeof(pa_spec));
+
+	memcpy(skb_put(skb, len), buf, len);
+
+	skb->dev =3D dev;
+	skb->protocol =3D htons(ETH_P_IEEE802154);
+	hw->bsn++; /* FIXME locking */
+
+	return dev_queue_xmit(skb);
+}
+
+/* at entry to this function we need skb->data to point to start
+ * of beacon field and MAC frame already parsed into MAC_CB */
+
+int parse_beacon_frame(struct sk_buff *skb, u8 *buf,
+		int *flags, struct list_head *al)
+{
+	int offt =3D 0;
+	u8 gts_spec;
+	u8 pa_spec;
+	struct ieee802154_priv *hw =3D ieee802154_slave_get_hw(skb->dev);
+	struct ieee802154_pandsc *pd;
+	u16 sf =3D skb->data[0] + (skb->data[1] << 8);
+
+	pd =3D kzalloc(sizeof(struct ieee802154_pandsc), GFP_KERNEL);
+
+	/* Filling-up pre-parsed values */
+	pd->lqi =3D MAC_CB(skb)->phy.lqi;
+	pd->sf =3D sf;
+	memcpy(&pd->addr, &MAC_CB(skb)->da, sizeof(struct ieee802154_addr));
+
+	/* Supplying our nitifiers with data */
+	ieee802154_slave_event(skb->dev, IEEE802154_NOTIFIER_BEACON, pd);
+	ieee802154_nl_beacon_indic(skb->dev, 0xeba1, 1); /* FIXME */
+	kfree(pd);
+
+	offt +=3D 2;
+	gts_spec =3D skb->data[offt++];
+	/* FIXME !!! */
+	if ((gts_spec & 7) !=3D 0) {
+		pr_debug("We still don't parse GTS part properly");
+		return -ENOTSUPP;
+	}
+	pa_spec =3D skb->data[offt++];
+	/* FIXME !!! */
+	if (pa_spec !=3D 0) {
+		pr_debug("We still don't parse PA part properly");
+		return -ENOTSUPP;
+	}
+
+	*flags =3D 0;
+
+	if (sf & IEEE802154_BEACON_SF_PANCOORD)
+		*flags |=3D IEEE802154_BEACON_FLAG_PANCOORD;
+
+	if (sf & IEEE802154_BEACON_SF_CANASSOC)
+		*flags |=3D IEEE802154_BEACON_FLAG_CANASSOC;
+	BUG_ON(skb->len - offt < 0);
+	/* FIXME */
+	if (buf && (skb->len - offt > 0))
+		memcpy(buf, skb->data + offt, skb->len - offt);
+	return 0;
+}
+
diff --git a/net/ieee802154/beacon_hash.c b/net/ieee802154/beacon_hash.=
c
new file mode 100644
index 0000000..f5049c1
--- /dev/null
+++ b/net/ieee802154/beacon_hash.c
@@ -0,0 +1,105 @@
+/*
+ * MAC beacon hash storage
+ *
+ * Copyright 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long
+ * with this program; if not, write to the Free Software Foundation, I=
nc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Sergey Lapin <sergey.lapin@siemens.com>
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ */
+
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <net/sock.h>
+
+#include <net/ieee802154/af_ieee802154.h>
+#include <net/ieee802154/beacon_hash.h>
+
+static struct hlist_head beacon_hash[IEEE802154_BEACON_HTABLE_SIZE];
+static DEFINE_RWLOCK(beacon_hash_lock);
+
+static int beacon_hashfn(struct ieee802154_addr *coord_addr, u16 pan_a=
ddr)
+{
+	return pan_addr % IEEE802154_BEACON_HTABLE_SIZE;
+}
+
+static void __beacon_add_node(struct ieee802154_addr *coord_addr, u16 =
pan_addr)
+{
+	struct beacon_node *node =3D kzalloc(sizeof(struct beacon_node), GFP_=
KERNEL);
+	struct hlist_head *list =3D &beacon_hash[beacon_hashfn(coord_addr, pa=
n_addr)];
+	memcpy(&node->coord_addr, coord_addr, sizeof(struct ieee802154_addr))=
;
+	node->pan_addr =3D pan_addr;
+	INIT_HLIST_NODE(&node->list);
+	hlist_add_head(&node->list, list);
+}
+
+struct beacon_node *ieee802154_beacon_find_pan(struct ieee802154_addr =
*coord_addr,
+						u16 pan_addr)
+{
+	struct hlist_head *list;
+	struct hlist_node *tmp;
+	list =3D &beacon_hash[beacon_hashfn(coord_addr, pan_addr)];
+	if (hlist_empty(list))
+		return NULL;
+	hlist_for_each(tmp, list) {
+		struct beacon_node *entry =3D hlist_entry(tmp, struct beacon_node, l=
ist);
+		if (entry->pan_addr =3D=3D pan_addr)
+			return entry;
+	}
+	return NULL;
+}
+EXPORT_SYMBOL(ieee802154_beacon_find_pan);
+
+void ieee802154_beacon_hash_add(struct ieee802154_addr *coord_addr)
+{
+	if (!ieee802154_beacon_find_pan(coord_addr, coord_addr->pan_id)) {
+		write_lock(&beacon_hash_lock);
+		__beacon_add_node(coord_addr, coord_addr->pan_id);
+		write_unlock(&beacon_hash_lock);
+	}
+}
+EXPORT_SYMBOL(ieee802154_beacon_hash_add);
+
+void ieee802154_beacon_hash_del(struct ieee802154_addr *coord_addr)
+{
+	struct beacon_node *entry =3D ieee802154_beacon_find_pan(coord_addr,
+								coord_addr->pan_id);
+	if (!entry)
+		return;
+	write_lock(&beacon_hash_lock);
+	hlist_del(&entry->list);
+	write_unlock(&beacon_hash_lock);
+	kfree(entry);
+}
+EXPORT_SYMBOL(ieee802154_beacon_hash_del);
+
+void ieee802154_beacon_hash_dump(void)
+{
+	int i;
+	struct hlist_node *tmp;
+	pr_debug("beacon hash dump begin\n");
+	read_lock(&beacon_hash_lock);
+	for (i =3D 0; i < IEEE802154_BEACON_HTABLE_SIZE; i++) {
+		struct beacon_node *entry;
+		hlist_for_each(tmp, &beacon_hash[i]) {
+			entry =3D hlist_entry(tmp, struct beacon_node, list);
+			pr_debug("PAN: %d\n", entry->pan_addr);
+		}
+	}
+	read_unlock(&beacon_hash_lock);
+	pr_debug("beacon hash dump end\n");
+}
+
diff --git a/net/ieee802154/crc.c b/net/ieee802154/crc.c
new file mode 100644
index 0000000..8e7c0d5
--- /dev/null
+++ b/net/ieee802154/crc.c
@@ -0,0 +1,73 @@
+/*
+ * based on crc-itu-t.c
+ *
+ * Copyright 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long
+ * with this program; if not, write to the Free Software Foundation, I=
nc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * 	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ */
+
+#include <linux/types.h>
+#include <net/ieee802154/crc.h>
+
+const u16 ieee802154_crc_table[256] =3D {
+	0x0000, 0x1189, 0x2312, 0x329b, 0x4624, 0x57ad, 0x6536, 0x74bf,
+	0x8c48, 0x9dc1, 0xaf5a, 0xbed3, 0xca6c, 0xdbe5, 0xe97e, 0xf8f7,
+	0x1081, 0x0108, 0x3393, 0x221a, 0x56a5, 0x472c, 0x75b7, 0x643e,
+	0x9cc9, 0x8d40, 0xbfdb, 0xae52, 0xdaed, 0xcb64, 0xf9ff, 0xe876,
+	0x2102, 0x308b, 0x0210, 0x1399, 0x6726, 0x76af, 0x4434, 0x55bd,
+	0xad4a, 0xbcc3, 0x8e58, 0x9fd1, 0xeb6e, 0xfae7, 0xc87c, 0xd9f5,
+	0x3183, 0x200a, 0x1291, 0x0318, 0x77a7, 0x662e, 0x54b5, 0x453c,
+	0xbdcb, 0xac42, 0x9ed9, 0x8f50, 0xfbef, 0xea66, 0xd8fd, 0xc974,
+	0x4204, 0x538d, 0x6116, 0x709f, 0x0420, 0x15a9, 0x2732, 0x36bb,
+	0xce4c, 0xdfc5, 0xed5e, 0xfcd7, 0x8868, 0x99e1, 0xab7a, 0xbaf3,
+	0x5285, 0x430c, 0x7197, 0x601e, 0x14a1, 0x0528, 0x37b3, 0x263a,
+	0xdecd, 0xcf44, 0xfddf, 0xec56, 0x98e9, 0x8960, 0xbbfb, 0xaa72,
+	0x6306, 0x728f, 0x4014, 0x519d, 0x2522, 0x34ab, 0x0630, 0x17b9,
+	0xef4e, 0xfec7, 0xcc5c, 0xddd5, 0xa96a, 0xb8e3, 0x8a78, 0x9bf1,
+	0x7387, 0x620e, 0x5095, 0x411c, 0x35a3, 0x242a, 0x16b1, 0x0738,
+	0xffcf, 0xee46, 0xdcdd, 0xcd54, 0xb9eb, 0xa862, 0x9af9, 0x8b70,
+	0x8408, 0x9581, 0xa71a, 0xb693, 0xc22c, 0xd3a5, 0xe13e, 0xf0b7,
+	0x0840, 0x19c9, 0x2b52, 0x3adb, 0x4e64, 0x5fed, 0x6d76, 0x7cff,
+	0x9489, 0x8500, 0xb79b, 0xa612, 0xd2ad, 0xc324, 0xf1bf, 0xe036,
+	0x18c1, 0x0948, 0x3bd3, 0x2a5a, 0x5ee5, 0x4f6c, 0x7df7, 0x6c7e,
+	0xa50a, 0xb483, 0x8618, 0x9791, 0xe32e, 0xf2a7, 0xc03c, 0xd1b5,
+	0x2942, 0x38cb, 0x0a50, 0x1bd9, 0x6f66, 0x7eef, 0x4c74, 0x5dfd,
+	0xb58b, 0xa402, 0x9699, 0x8710, 0xf3af, 0xe226, 0xd0bd, 0xc134,
+	0x39c3, 0x284a, 0x1ad1, 0x0b58, 0x7fe7, 0x6e6e, 0x5cf5, 0x4d7c,
+	0xc60c, 0xd785, 0xe51e, 0xf497, 0x8028, 0x91a1, 0xa33a, 0xb2b3,
+	0x4a44, 0x5bcd, 0x6956, 0x78df, 0x0c60, 0x1de9, 0x2f72, 0x3efb,
+	0xd68d, 0xc704, 0xf59f, 0xe416, 0x90a9, 0x8120, 0xb3bb, 0xa232,
+	0x5ac5, 0x4b4c, 0x79d7, 0x685e, 0x1ce1, 0x0d68, 0x3ff3, 0x2e7a,
+	0xe70e, 0xf687, 0xc41c, 0xd595, 0xa12a, 0xb0a3, 0x8238, 0x93b1,
+	0x6b46, 0x7acf, 0x4854, 0x59dd, 0x2d62, 0x3ceb, 0x0e70, 0x1ff9,
+	0xf78f, 0xe606, 0xd49d, 0xc514, 0xb1ab, 0xa022, 0x92b9, 0x8330,
+	0x7bc7, 0x6a4e, 0x58d5, 0x495c, 0x3de3, 0x2c6a, 0x1ef1, 0x0f78,
+};
+
+#if 0
+void generate()
+{
+	int i, j;
+	uint16_t crc =3D 1;
+
+	for (i =3D 0x80; i ; i >>=3D 1) {
+		crc =3D (crc >> 1) ^ ((crc & 1) ? 0x8408 : 0);
+		for (j =3D 0; j < 256; j +=3D 2 * i)
+			ieee802154_crc_table[i + j] =3D crc ^ ieee802154_crc_table[j];
+	}
+}
+#endif
diff --git a/net/ieee802154/dev.c b/net/ieee802154/dev.c
new file mode 100644
index 0000000..ecf5c98
--- /dev/null
+++ b/net/ieee802154/dev.c
@@ -0,0 +1,935 @@
+/*
+ * ZigBee socket interface
+ *
+ * Copyright 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long
+ * with this program; if not, write to the Free Software Foundation, I=
nc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Sergey Lapin <sergey.lapin@siemens.com>
+ * Maxim Gorbachyov <maxim.gorbachev@siemens.com>
+ */
+
+#include <linux/net.h>
+#include <linux/capability.h>
+#include <linux/module.h>
+#include <linux/if_arp.h>
+#include <linux/termios.h>	/* For TIOCOUTQ/INQ */
+#include <linux/notifier.h>
+#include <linux/random.h>
+#include <net/datalink.h>
+#include <net/psnap.h>
+#include <net/sock.h>
+#include <net/tcp_states.h>
+#include <net/route.h>
+#include <net/ieee802154/dev.h>
+#include <net/ieee802154/netdev.h>
+#include <net/ieee802154/crc.h>
+#include <net/ieee802154/af_ieee802154.h>
+#include <net/ieee802154/mac_def.h>
+#include <net/ieee802154/beacon.h>
+#include <net/ieee802154/beacon_hash.h>
+
+struct ieee802154_netdev_priv {
+	struct list_head list;
+	struct ieee802154_priv *hw;
+	struct net_device *dev;
+
+	__le16 pan_id;
+	__le16 short_addr;
+
+	u8 chan;
+
+	/* This one is used to provide notifications */
+	struct blocking_notifier_head events;
+};
+
+static int ieee802154_net_xmit(struct sk_buff *skb, struct net_device =
*dev)
+{
+	struct ieee802154_netdev_priv *priv;
+	priv =3D netdev_priv(dev);
+
+	if (!(priv->hw->hw.flags & IEEE802154_OPS_OMIT_CKSUM)) {
+		u16 crc =3D ieee802154_crc(0, skb->data, skb->len);
+		u8 *data =3D skb_put(skb, 2);
+		data[0] =3D crc & 0xff;
+		data[1] =3D crc >> 8;
+	}
+
+	PHY_CB(skb)->chan =3D priv->chan;
+
+	skb->iif =3D dev->ifindex;
+	skb->dev =3D priv->hw->master;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes +=3D skb->len;
+
+	dev->trans_start =3D jiffies;
+	dev_queue_xmit(skb);
+
+	return 0;
+}
+
+static int ieee802154_slave_open(struct net_device *dev)
+{
+	struct ieee802154_netdev_priv *priv;
+	priv =3D netdev_priv(dev);
+	netif_start_queue(dev);
+	return 0;
+}
+
+static int ieee802154_slave_close(struct net_device *dev)
+{
+	struct ieee802154_netdev_priv *priv;
+	netif_stop_queue(dev);
+	priv =3D netdev_priv(dev);
+	netif_stop_queue(dev);
+	return 0;
+}
+
+
+static int ieee802154_slave_ioctl(struct net_device *dev, struct ifreq=
 *ifr, int cmd)
+{
+	struct ieee802154_netdev_priv *priv =3D netdev_priv(dev);
+	struct sockaddr_ieee802154 *sa =3D (struct sockaddr_ieee802154 *)&ifr=
->ifr_addr;
+	switch (cmd) {
+	case SIOCGIFADDR:
+		if (priv->pan_id =3D=3D IEEE802154_PANID_BROADCAST || priv->short_ad=
dr =3D=3D IEEE802154_ADDR_BROADCAST)
+			return -EADDRNOTAVAIL;
+
+		sa->family =3D AF_IEEE802154;
+		sa->addr.addr_type =3D IEEE802154_ADDR_SHORT;
+		sa->addr.pan_id =3D priv->pan_id;
+		sa->addr.short_addr =3D priv->short_addr;
+		return 0;
+	case SIOCSIFADDR:
+		dev_warn(&dev->dev, "Using DEBUGing ioctl SIOCSIFADDR isn't recommen=
ed!\n");
+		if (sa->family !=3D AF_IEEE802154 || sa->addr.addr_type !=3D IEEE802=
154_ADDR_SHORT ||
+			sa->addr.pan_id =3D=3D IEEE802154_PANID_BROADCAST || sa->addr.short=
_addr =3D=3D IEEE802154_ADDR_BROADCAST || sa->addr.short_addr =3D=3D IE=
EE802154_ADDR_UNDEF)
+			return -EINVAL;
+
+		priv->pan_id =3D sa->addr.pan_id;
+		priv->short_addr =3D sa->addr.short_addr;
+		return 0;
+	}
+	return -ENOIOCTLCMD;
+}
+
+static int ieee802154_slave_mac_addr(struct net_device *dev, void *p)
+{
+	struct sockaddr *addr =3D p;
+
+	if (netif_running(dev))
+		return -EBUSY;
+	/* FIXME: validate addr */
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	return 0;
+}
+
+static int ieee802154_header_create(struct sk_buff *skb, struct net_de=
vice *dev,
+			   unsigned short type, const void *_daddr,
+			   const void *_saddr, unsigned len)
+{
+	u8 head[24] =3D {};
+	int pos =3D 0;
+
+	u16 fc;
+	const struct ieee802154_addr *saddr =3D _saddr;
+	const struct ieee802154_addr *daddr =3D _daddr;
+	struct ieee802154_addr dev_addr;
+	struct ieee802154_netdev_priv *priv =3D netdev_priv(dev);
+
+	fc =3D MAC_CB_TYPE(skb);
+	if (MAC_CB_IS_ACKREQ(skb))
+		fc |=3D IEEE802154_FC_ACK_REQ;
+
+	pos =3D 2;
+
+	head[pos++] =3D MAC_CB(skb)->seq; /* DSN/BSN */
+
+	if (!daddr)
+		return -EINVAL;
+
+	if (!saddr) {
+		if (priv->short_addr =3D=3D IEEE802154_ADDR_BROADCAST || priv->short=
_addr =3D=3D IEEE802154_ADDR_UNDEF || priv->pan_id =3D=3D IEEE802154_PA=
NID_BROADCAST) {
+			dev_addr.addr_type =3D IEEE802154_ADDR_LONG;
+			memcpy(dev_addr.hwaddr, dev->dev_addr, IEEE802154_ADDR_LEN);
+		} else {
+			dev_addr.addr_type =3D IEEE802154_ADDR_SHORT;
+			dev_addr.short_addr =3D priv->short_addr;
+		}
+
+		dev_addr.pan_id =3D priv->pan_id;
+		saddr =3D &dev_addr;
+	}
+
+	if (daddr->addr_type !=3D IEEE802154_ADDR_NONE) {
+		fc |=3D (daddr->addr_type << IEEE802154_FC_DAMODE_SHIFT);
+
+		head[pos++] =3D daddr->pan_id & 0xff;
+		head[pos++] =3D daddr->pan_id >> 8;
+
+		if (daddr->addr_type =3D=3D IEEE802154_ADDR_SHORT) {
+			head[pos++] =3D daddr->short_addr & 0xff;
+			head[pos++] =3D daddr->short_addr >> 8;
+		} else {
+			memcpy(head + pos, daddr->hwaddr, IEEE802154_ADDR_LEN);
+			pos +=3D IEEE802154_ADDR_LEN;
+		}
+	}
+
+	if (saddr->addr_type !=3D IEEE802154_ADDR_NONE) {
+		fc |=3D (saddr->addr_type << IEEE802154_FC_SAMODE_SHIFT);
+
+		if ((saddr->pan_id =3D=3D daddr->pan_id) && (saddr->pan_id !=3D IEEE=
802154_PANID_BROADCAST))
+			fc |=3D IEEE802154_FC_INTRA_PAN; /* PANID compression/ intra PAN */
+		else {
+			head[pos++] =3D saddr->pan_id & 0xff;
+			head[pos++] =3D saddr->pan_id >> 8;
+		}
+
+		if (saddr->addr_type =3D=3D IEEE802154_ADDR_SHORT) {
+			head[pos++] =3D saddr->short_addr & 0xff;
+			head[pos++] =3D saddr->short_addr >> 8;
+		} else {
+			memcpy(head + pos, saddr->hwaddr, IEEE802154_ADDR_LEN);
+			pos +=3D IEEE802154_ADDR_LEN;
+		}
+	}
+
+	head[0] =3D fc;
+	head[1] =3D fc >> 8;
+
+	memcpy(skb_push(skb, pos), head, pos);
+
+	return pos;
+}
+
+static int ieee802154_header_parse(const struct sk_buff *skb, unsigned=
 char *haddr)
+{
+	const u8 *hdr =3D skb_mac_header(skb), *tail =3D skb_tail_pointer(skb=
);
+	struct ieee802154_addr *addr =3D (struct ieee802154_addr *)haddr;
+	u16 fc;
+	int da_type;
+
+	if (hdr + 3 > tail)
+		goto malformed;
+
+	fc =3D hdr[0] | (hdr[1] << 8);
+
+	hdr +=3D 3;
+
+	da_type =3D IEEE802154_FC_DAMODE(fc);
+	addr->addr_type =3D IEEE802154_FC_SAMODE(fc);
+
+	switch (da_type) {
+	case IEEE802154_ADDR_NONE:
+		if (fc & IEEE802154_FC_INTRA_PAN)
+			goto malformed;
+		break;
+
+	case IEEE802154_ADDR_LONG:
+		if (hdr + 2 > tail)
+			goto malformed;
+		if (fc & IEEE802154_FC_INTRA_PAN) {
+			addr->pan_id =3D hdr[0] | (hdr[1] << 8);
+			hdr +=3D 2;
+		}
+
+		if (hdr + IEEE802154_ADDR_LEN > tail)
+			goto malformed;
+		hdr +=3D IEEE802154_ADDR_LEN;
+		break;
+
+	case IEEE802154_ADDR_SHORT:
+		if (hdr + 2 > tail)
+			goto malformed;
+		if (fc & IEEE802154_FC_INTRA_PAN) {
+			addr->pan_id =3D hdr[0] | (hdr[1] << 8);
+			hdr +=3D 2;
+		}
+
+		if (hdr + 2 > tail)
+			goto malformed;
+		hdr +=3D 2;
+		break;
+
+	default:
+		goto malformed;
+
+	}
+
+	switch (addr->addr_type) {
+	case IEEE802154_ADDR_NONE:
+		break;
+
+	case IEEE802154_ADDR_LONG:
+		if (hdr + 2 > tail)
+			goto malformed;
+		if (!(fc & IEEE802154_FC_INTRA_PAN)) {
+			addr->pan_id =3D hdr[0] | (hdr[1] << 8);
+			hdr +=3D 2;
+		}
+
+		if (hdr + IEEE802154_ADDR_LEN > tail)
+			goto malformed;
+		memcpy(addr->hwaddr, hdr, IEEE802154_ADDR_LEN);
+		hdr +=3D IEEE802154_ADDR_LEN;
+		break;
+
+	case IEEE802154_ADDR_SHORT:
+		if (hdr + 2 > tail)
+			goto malformed;
+		if (!(fc & IEEE802154_FC_INTRA_PAN)) {
+			addr->pan_id =3D hdr[0] | (hdr[1] << 8);
+			hdr +=3D 2;
+		}
+
+		if (hdr + 2 > tail)
+			goto malformed;
+		addr->short_addr =3D hdr[0] | (hdr[1] << 8);
+		hdr +=3D 2;
+		break;
+
+	default:
+		goto malformed;
+
+	}
+
+	return sizeof(struct ieee802154_addr);
+
+malformed:
+	pr_debug("malformed packet\n");
+	return 0;
+}
+
+static struct header_ops ieee802154_header_ops =3D {
+	.create		=3D ieee802154_header_create,
+	.parse		=3D ieee802154_header_parse,
+};
+
+static void ieee802154_netdev_setup(struct net_device *dev)
+{
+	dev->addr_len		=3D IEEE802154_ADDR_LEN;
+	memset(dev->broadcast, 0xff, IEEE802154_ADDR_LEN);
+	dev->features		=3D NETIF_F_NO_CSUM;
+	dev->hard_header_len	=3D 2 + 1 + 20 + 14;
+	dev->header_ops		=3D &ieee802154_header_ops;
+	dev->needed_tailroom	=3D 2; /* FCS */
+	dev->mtu		=3D 127;
+	dev->tx_queue_len	=3D 10;
+	dev->type		=3D ARPHRD_IEEE802154;
+	dev->flags		=3D IFF_NOARP | IFF_BROADCAST;
+	dev->watchdog_timeo	=3D 0;
+}
+
+static void ieee802154_init_seq(struct ieee802154_priv *priv)
+{
+	get_random_bytes(&priv->bsn, 1);
+	get_random_bytes(&priv->dsn, 1);
+}
+
+static const struct net_device_ops ieee802154_slave_ops =3D {
+	.ndo_open		=3D ieee802154_slave_open,
+	.ndo_stop		=3D ieee802154_slave_close,
+	.ndo_start_xmit		=3D ieee802154_net_xmit,
+	.ndo_do_ioctl		=3D ieee802154_slave_ioctl,
+	.ndo_set_mac_address	=3D ieee802154_slave_mac_addr,
+};
+
+int ieee802154_add_slave(struct ieee802154_dev *hw, const u8 *addr)
+{
+	struct net_device *dev;
+	struct ieee802154_netdev_priv *priv;
+	struct ieee802154_priv *ipriv =3D ieee802154_to_priv(hw);
+	int err;
+
+	ASSERT_RTNL();
+
+	dev =3D alloc_netdev(sizeof(struct ieee802154_netdev_priv),
+			"wpan%d", ieee802154_netdev_setup);
+	if (!dev) {
+		printk(KERN_ERR "Failure to initialize IEEE802154 device\n");
+		return -ENOMEM;
+	}
+	priv =3D netdev_priv(dev);
+	priv->dev =3D dev;
+	priv->hw =3D ieee802154_to_priv(hw);
+	ieee802154_init_seq(priv->hw);
+	BLOCKING_INIT_NOTIFIER_HEAD(&priv->events);
+	memcpy(dev->dev_addr, addr, dev->addr_len);
+	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
+	dev->priv_flags =3D IFF_SLAVE_INACTIVE;
+	dev->netdev_ops =3D &ieee802154_slave_ops;
+
+	priv->pan_id =3D IEEE802154_PANID_DEF;
+	priv->short_addr =3D IEEE802154_SHORT_ADDRESS_DEF;
+
+	dev_hold(priv->hw->master);
+
+	dev->needed_headroom =3D priv->hw->master->needed_headroom;
+
+	spin_lock(&ieee802154_to_priv(hw)->slaves_lock);
+	list_add_tail(&priv->list, &ieee802154_to_priv(hw)->slaves);
+	spin_unlock(&ieee802154_to_priv(hw)->slaves_lock);
+	/*
+	 * If the name is a format string the caller wants us to do a
+	 * name allocation.
+	 */
+	if (strchr(dev->name, '%')) {
+		err =3D dev_alloc_name(dev, dev->name);
+		if (err < 0)
+			goto out;
+	}
+
+	SET_NETDEV_DEV(dev, &ipriv->master->dev);
+
+	err =3D register_netdevice(dev);
+	if (err < 0)
+		goto out;
+
+	return dev->ifindex;
+out:
+	return err;
+}
+EXPORT_SYMBOL(ieee802154_add_slave);
+
+static void __ieee802154_del_slave(struct ieee802154_netdev_priv *ndp)
+{
+	struct net_device *dev =3D ndp->dev;
+	dev_put(ndp->hw->master);
+	unregister_netdev(ndp->dev);
+
+	spin_lock(&ndp->hw->slaves_lock);
+	list_del(&ndp->list);
+	spin_unlock(&ndp->hw->slaves_lock);
+
+	free_netdev(dev);
+}
+
+void ieee802154_drop_slaves(struct ieee802154_dev *hw)
+{
+	struct ieee802154_priv *priv =3D ieee802154_to_priv(hw);
+	struct ieee802154_netdev_priv *ndp, *next;
+
+	spin_lock(&priv->slaves_lock);
+	list_for_each_entry_safe(ndp, next, &priv->slaves, list) {
+		spin_unlock(&priv->slaves_lock);
+		__ieee802154_del_slave(ndp);
+		spin_lock(&priv->slaves_lock);
+	}
+	spin_unlock(&priv->slaves_lock);
+}
+EXPORT_SYMBOL(ieee802154_drop_slaves);
+
+static int ieee802154_send_ack(struct sk_buff *skb)
+{
+	u16 fc =3D IEEE802154_FC_TYPE_ACK;
+	u8 *data;
+	struct sk_buff *ackskb;
+
+	BUG_ON(!skb || !skb->dev);
+	BUG_ON(!MAC_CB_IS_ACKREQ(skb));
+
+	ackskb =3D alloc_skb(LL_ALLOCATED_SPACE(skb->dev) + IEEE802154_ACK_LE=
N, GFP_ATOMIC);
+
+	skb_reserve(ackskb, LL_RESERVED_SPACE(skb->dev));
+
+	skb_reset_network_header(ackskb);
+
+	data =3D skb_push(ackskb, IEEE802154_ACK_LEN);
+	data[0] =3D fc & 0xff;
+	data[1] =3D (fc >> 8) & 0xff;
+	data[2] =3D MAC_CB(skb)->seq;
+
+	skb_reset_mac_header(ackskb);
+
+	ackskb->dev =3D skb->dev;
+	pr_debug("ACK frame to %s device\n", skb->dev->name);
+	ackskb->protocol =3D htons(ETH_P_IEEE802154);
+	/* FIXME */
+
+	return dev_queue_xmit(ackskb);
+}
+
+static int ieee802154_process_beacon(struct net_device *dev, struct sk=
_buff *skb)
+{
+	int flags;
+	int ret;
+	ret =3D parse_beacon_frame(skb, NULL, &flags, NULL);
+
+	/* Here we have cb->sa =3D coordinator address, and PAN address */
+
+	if (ret < 0) {
+		ret =3D NET_RX_DROP;
+		goto fail;
+	}
+	dev_dbg(&dev->dev, "got beacon from pan %d\n", MAC_CB(skb)->sa.pan_id=
);
+	ieee802154_beacon_hash_add(&MAC_CB(skb)->sa);
+	ieee802154_beacon_hash_dump();
+	ret =3D NET_RX_SUCCESS;
+fail:
+	kfree_skb(skb);
+	return ret;
+}
+
+static int ieee802154_process_ack(struct net_device *dev, struct sk_bu=
ff *skb)
+{
+	pr_debug("got ACK for SEQ=3D%d\n", MAC_CB(skb)->seq);
+
+	kfree_skb(skb);
+	return NET_RX_SUCCESS;
+}
+
+static int ieee802154_process_data(struct net_device *dev, struct sk_b=
uff *skb)
+{
+	return netif_rx(skb);
+}
+
+static int ieee802154_subif_frame(struct ieee802154_netdev_priv *ndp, =
struct sk_buff *skb)
+{
+	pr_debug("%s Getting packet via slave interface %s\n",
+				__func__, ndp->dev->name);
+
+	switch (MAC_CB(skb)->da.addr_type) {
+	case IEEE802154_ADDR_NONE:
+		if (MAC_CB(skb)->sa.addr_type !=3D IEEE802154_ADDR_NONE)
+			/* FIXME: check if we are PAN coordinator :) */
+			skb->pkt_type =3D PACKET_OTHERHOST;
+		else
+			/* ACK comes with both addresses empty */
+			skb->pkt_type =3D PACKET_HOST;
+		break;
+	case IEEE802154_ADDR_LONG:
+		if (MAC_CB(skb)->da.pan_id !=3D ndp->pan_id && MAC_CB(skb)->da.pan_i=
d !=3D IEEE802154_PANID_BROADCAST)
+			skb->pkt_type =3D PACKET_OTHERHOST;
+		else if (!memcmp(MAC_CB(skb)->da.hwaddr, ndp->dev->dev_addr, IEEE802=
154_ADDR_LEN))
+			skb->pkt_type =3D PACKET_HOST;
+		else if (!memcmp(MAC_CB(skb)->da.hwaddr, ndp->dev->broadcast, IEEE80=
2154_ADDR_LEN))
+			/* FIXME: is this correct? */
+			skb->pkt_type =3D PACKET_BROADCAST;
+		else
+			skb->pkt_type =3D PACKET_OTHERHOST;
+		break;
+	case IEEE802154_ADDR_SHORT:
+		if (MAC_CB(skb)->da.pan_id !=3D ndp->pan_id && MAC_CB(skb)->da.pan_i=
d !=3D IEEE802154_PANID_BROADCAST)
+			skb->pkt_type =3D PACKET_OTHERHOST;
+		else if (MAC_CB(skb)->da.short_addr =3D=3D ndp->short_addr)
+			skb->pkt_type =3D PACKET_HOST;
+		else if (MAC_CB(skb)->da.short_addr =3D=3D IEEE802154_ADDR_BROADCAST=
)
+			skb->pkt_type =3D PACKET_BROADCAST;
+		else
+			skb->pkt_type =3D PACKET_OTHERHOST;
+		break;
+	}
+
+	skb->dev =3D ndp->dev;
+
+	if (MAC_CB_IS_ACKREQ(skb))
+		ieee802154_send_ack(skb);
+
+	switch (MAC_CB_TYPE(skb)) {
+	case IEEE802154_FC_TYPE_BEACON:
+		return ieee802154_process_beacon(ndp->dev, skb);
+	case IEEE802154_FC_TYPE_ACK:
+		return ieee802154_process_ack(ndp->dev, skb);
+	case IEEE802154_FC_TYPE_MAC_CMD:
+		return ieee802154_process_cmd(ndp->dev, skb);
+	case IEEE802154_FC_TYPE_DATA:
+		return ieee802154_process_data(ndp->dev, skb);
+	default:
+		pr_warning("ieee802154: Bad frame received (type =3D %d)\n", MAC_CB_=
TYPE(skb));
+		kfree_skb(skb);
+		return NET_RX_DROP;
+	}
+}
+
+static u8 fetch_skb_u8(struct sk_buff *skb)
+{
+	u8 ret;
+
+	BUG_ON(skb->len < 1);
+
+	ret =3D skb->data[0];
+	skb_pull(skb, 1);
+
+	return ret;
+}
+
+static u16 fetch_skb_u16(struct sk_buff *skb)
+{
+	u16 ret;
+
+	BUG_ON(skb->len < 2);
+
+	ret =3D skb->data[0] + (skb->data[1] * 256);
+	skb_pull(skb, 2);
+	return ret;
+}
+
+static void fetch_skb_u64(struct sk_buff *skb, void *data)
+{
+	BUG_ON(skb->len < IEEE802154_ADDR_LEN);
+
+	memcpy(data, skb->data, IEEE802154_ADDR_LEN);
+	skb_pull(skb, IEEE802154_ADDR_LEN);
+}
+
+#define IEEE802154_FETCH_U8(skb, var)		\
+	do {					\
+		if (skb->len < 1)		\
+			goto exit_error;	\
+		var =3D fetch_skb_u8(skb);	\
+	} while (0)
+
+#define IEEE802154_FETCH_U16(skb, var)		\
+	do {					\
+		if (skb->len < 2)		\
+			goto exit_error;	\
+		var =3D fetch_skb_u16(skb);	\
+	} while (0)
+
+#define IEEE802154_FETCH_U64(skb, var)			\
+	do {						\
+		if (skb->len < IEEE802154_ADDR_LEN)	\
+			goto exit_error;		\
+		fetch_skb_u64(skb, &var);		\
+	} while (0)
+
+static int parse_frame_start(struct sk_buff *skb)
+{
+	u8 *head =3D skb->data;
+	u16 fc;
+
+	if (skb->len < 3) {
+		pr_debug("frame size %d bytes is too short\n", skb->len);
+		return -EINVAL;
+	}
+
+	IEEE802154_FETCH_U16(skb, fc);
+	IEEE802154_FETCH_U8(skb, MAC_CB(skb)->seq);
+
+	pr_debug("%s: %04x dsn%02x\n", __func__, fc, head[2]);
+
+	MAC_CB(skb)->flags =3D IEEE802154_FC_TYPE(fc);
+
+	if (fc & IEEE802154_FC_ACK_REQ) {
+		pr_debug("%s(): ACKNOWLEDGE required\n", __func__);
+		MAC_CB(skb)->flags |=3D MAC_CB_FLAG_ACKREQ;
+	}
+
+	if (fc & IEEE802154_FC_SECEN)
+		MAC_CB(skb)->flags |=3D MAC_CB_FLAG_SECEN;
+
+	if (fc & IEEE802154_FC_INTRA_PAN)
+		MAC_CB(skb)->flags |=3D MAC_CB_FLAG_INTRAPAN;
+
+	/* TODO */
+	if (MAC_CB_IS_SECEN(skb)) {
+		pr_info("security support is not implemented\n");
+		return -EINVAL;
+	}
+
+	MAC_CB(skb)->sa.addr_type =3D IEEE802154_FC_SAMODE(fc);
+	if (MAC_CB(skb)->sa.addr_type =3D=3D IEEE802154_ADDR_NONE)
+		pr_debug("%s(): src addr_type is NONE\n", __func__);
+
+	MAC_CB(skb)->da.addr_type =3D IEEE802154_FC_DAMODE(fc);
+	if (MAC_CB(skb)->da.addr_type =3D=3D IEEE802154_ADDR_NONE)
+		pr_debug("%s(): dst addr_type is NONE\n", __func__);
+
+	if (IEEE802154_FC_TYPE(fc) =3D=3D IEEE802154_FC_TYPE_ACK) {
+		/* ACK can only have NONE-type addresses */
+		if (MAC_CB(skb)->sa.addr_type !=3D IEEE802154_ADDR_NONE ||
+		    MAC_CB(skb)->da.addr_type !=3D IEEE802154_ADDR_NONE)
+			return -EINVAL;
+	}
+
+	if (MAC_CB(skb)->da.addr_type !=3D IEEE802154_ADDR_NONE) {
+		IEEE802154_FETCH_U16(skb, MAC_CB(skb)->da.pan_id);
+
+		if (MAC_CB_IS_INTRAPAN(skb)) { /* ! panid compress */
+			pr_debug("%s(): src IEEE802154_FC_INTRA_PAN\n", __func__);
+			MAC_CB(skb)->sa.pan_id =3D MAC_CB(skb)->da.pan_id;
+			pr_debug("%s(): src PAN address %04x\n",
+					__func__, MAC_CB(skb)->sa.pan_id);
+		}
+
+		pr_debug("%s(): dst PAN address %04x\n",
+				__func__, MAC_CB(skb)->da.pan_id);
+
+		if (MAC_CB(skb)->da.addr_type =3D=3D IEEE802154_ADDR_SHORT) {
+			IEEE802154_FETCH_U16(skb, MAC_CB(skb)->da.short_addr);
+			pr_debug("%s(): dst SHORT address %04x\n",
+					__func__, MAC_CB(skb)->da.short_addr);
+
+		} else {
+			IEEE802154_FETCH_U64(skb, MAC_CB(skb)->da.hwaddr);
+			pr_debug("%s(): dst hardware addr\n", __func__);
+		}
+	}
+
+	if (MAC_CB(skb)->sa.addr_type !=3D IEEE802154_ADDR_NONE) {
+		pr_debug("%s(): got src non-NONE address\n", __func__);
+		if (!(MAC_CB_IS_INTRAPAN(skb))) { /* ! panid compress */
+			IEEE802154_FETCH_U16(skb, MAC_CB(skb)->sa.pan_id);
+			pr_debug("%s(): src IEEE802154_FC_INTRA_PAN\n", __func__);
+		}
+
+		if (MAC_CB(skb)->sa.addr_type =3D=3D IEEE802154_ADDR_SHORT) {
+			IEEE802154_FETCH_U16(skb, MAC_CB(skb)->sa.short_addr);
+			pr_debug("%s(): src IEEE802154_ADDR_SHORT\n", __func__);
+		} else {
+			IEEE802154_FETCH_U64(skb, MAC_CB(skb)->sa.hwaddr);
+			pr_debug("%s(): src hardware addr\n", __func__);
+		}
+	}
+
+	return 0;
+
+exit_error:
+	return -EINVAL;
+}
+
+void ieee802154_subif_rx(struct ieee802154_dev *hw, struct sk_buff *sk=
b)
+{
+	struct ieee802154_priv *priv =3D ieee802154_to_priv(hw);
+	struct ieee802154_netdev_priv *ndp, *prev =3D NULL;
+	int ret;
+
+	BUILD_BUG_ON(sizeof(struct ieee802154_mac_cb) > sizeof(skb->cb));
+	pr_debug("%s()\n", __func__);
+
+	ret =3D parse_frame_start(skb); /* 3 bytes pulled after this */
+	if (ret) {
+		pr_debug("%s(): Got invalid frame\n", __func__);
+		goto out;
+	}
+
+	if (!(priv->hw.flags & IEEE802154_OPS_OMIT_CKSUM)) {
+		if (skb->len < 2) {
+			pr_debug("%s(): Got invalid frame\n", __func__);
+			goto out;
+		}
+		/* FIXME: check CRC if necessary */
+		skb_trim(skb, skb->len - 2); /* CRC */
+	}
+
+	pr_debug("%s() frame %d\n", __func__, MAC_CB_TYPE(skb));
+
+	rcu_read_lock();
+
+	list_for_each_entry_rcu(ndp, &priv->slaves, list)
+	{
+		if (prev) {
+			struct sk_buff *skb2 =3D skb_clone(skb, GFP_ATOMIC);
+			if (skb2)
+				ieee802154_subif_frame(prev, skb2);
+		}
+
+		prev =3D ndp;
+	}
+
+	if (prev)
+		ieee802154_subif_frame(prev, skb);
+	else
+		kfree_skb(skb);
+
+	rcu_read_unlock();
+	return;
+
+out:
+	kfree_skb(skb);
+	return;
+}
+
+struct net_device *ieee802154_get_dev(struct net *net, struct ieee8021=
54_addr *addr)
+{
+	struct net_device *dev =3D NULL;
+
+	switch (addr->addr_type) {
+	case IEEE802154_ADDR_LONG:
+		rtnl_lock();
+		dev =3D dev_getbyhwaddr(net, ARPHRD_IEEE802154, addr->hwaddr);
+		if (dev)
+			dev_hold(dev);
+		rtnl_unlock();
+		break;
+	case IEEE802154_ADDR_SHORT:
+		if (addr->pan_id !=3D 0xffff && addr->short_addr !=3D IEEE802154_ADD=
R_UNDEF && addr->short_addr !=3D 0xffff) {
+			struct net_device *tmp;
+
+			rtnl_lock();
+
+			for_each_netdev(net, tmp) {
+				if (tmp->type =3D=3D ARPHRD_IEEE802154) {
+					struct ieee802154_netdev_priv *priv =3D netdev_priv(tmp);
+					if (priv->pan_id =3D=3D addr->pan_id && priv->short_addr =3D=3D a=
ddr->short_addr) {
+						dev =3D tmp;
+						dev_hold(dev);
+						break;
+					}
+				}
+			}
+
+			rtnl_unlock();
+		}
+		break;
+	default:
+		pr_warning("Unsupported ieee802154 address type: %d\n", addr->addr_t=
ype);
+		break;
+	}
+
+	return dev;
+}
+EXPORT_SYMBOL(ieee802154_get_dev);
+
+u16 ieee802154_dev_get_pan_id(struct net_device *dev)
+{
+	struct ieee802154_netdev_priv *priv =3D netdev_priv(dev);
+
+	BUG_ON(dev->type !=3D ARPHRD_IEEE802154);
+
+	return priv->pan_id;
+}
+EXPORT_SYMBOL(ieee802154_dev_get_pan_id);
+
+u16 ieee802154_dev_get_short_addr(struct net_device *dev)
+{
+	struct ieee802154_netdev_priv *priv =3D netdev_priv(dev);
+
+	BUG_ON(dev->type !=3D ARPHRD_IEEE802154);
+
+	return priv->short_addr;
+}
+EXPORT_SYMBOL(ieee802154_dev_get_short_addr);
+
+void ieee802154_dev_set_pan_id(struct net_device *dev, u16 val)
+{
+	struct ieee802154_netdev_priv *priv =3D netdev_priv(dev);
+
+	BUG_ON(dev->type !=3D ARPHRD_IEEE802154);
+
+	priv->pan_id =3D val;
+}
+void ieee802154_dev_set_short_addr(struct net_device *dev, u16 val)
+{
+	struct ieee802154_netdev_priv *priv =3D netdev_priv(dev);
+
+	BUG_ON(dev->type !=3D ARPHRD_IEEE802154);
+
+	priv->short_addr =3D val;
+}
+void ieee802154_dev_set_channel(struct net_device *dev, u8 val)
+{
+	struct ieee802154_netdev_priv *priv =3D netdev_priv(dev);
+
+	BUG_ON(dev->type !=3D ARPHRD_IEEE802154);
+
+	priv->chan =3D val;
+}
+
+/* FIXME: come with better solution */
+struct ieee802154_priv *ieee802154_slave_get_hw(struct net_device *dev=
)
+{
+	struct ieee802154_netdev_priv *priv;
+	priv =3D netdev_priv(dev);
+	return priv->hw;
+}
+EXPORT_SYMBOL(ieee802154_slave_get_hw);
+
+int ieee802154_pib_set(struct ieee802154_dev *hw, struct ieee802154_pi=
b *pib)
+{
+	int ret;
+	struct ieee802154_priv *priv =3D ieee802154_to_priv(hw);
+	BUG_ON(!hw);
+	BUG_ON(!pib);
+	switch (pib->type) {
+	case IEEE802154_PIB_CURCHAN:
+		/* Our internal mask is inverted
+		 * 0 =3D channel is available
+		 * 1 =3D channel is unavailable
+		 * this saves initialization */
+		if (hw->channel_mask & (1 << (pib->val - 1)))
+			return -EINVAL;
+		ret =3D priv->ops->set_channel(hw, pib->val);
+		if (ret =3D=3D PHY_ERROR)
+			return -EINVAL; /* FIXME */
+		hw->current_channel =3D  pib->val;
+		break;
+	case IEEE802154_PIB_CHANSUPP:
+		hw->channel_mask =3D ~(pib->val);
+		break;
+	case IEEE802154_PIB_TRPWR:
+		/* TODO */
+		break;
+	case IEEE802154_PIB_CCAMODE:
+		/* TODO */
+		break;
+	default:
+		pr_debug("Unknown PIB type value\n");
+		return -ENOTSUPP;
+	}
+	return 0;
+}
+
+int ieee802154_pib_get(struct ieee802154_dev *hw, struct ieee802154_pi=
b *pib)
+{
+	BUG_ON(!hw);
+	BUG_ON(!pib);
+	switch (pib->type) {
+	case IEEE802154_PIB_CURCHAN:
+		pib->val =3D hw->current_channel;
+		break;
+	case IEEE802154_PIB_CHANSUPP:
+		pib->val =3D ~(hw->channel_mask);
+		break;
+	case IEEE802154_PIB_TRPWR:
+		pib->val =3D 0;
+		break;
+	case IEEE802154_PIB_CCAMODE:
+		pib->val =3D 0;
+		break;
+	default:
+		pr_debug("Unknown PIB type value\n");
+		return -ENOTSUPP;
+	}
+	return 0;
+}
+
+int ieee802154_slave_register_notifier(struct net_device *dev, struct =
notifier_block *nb)
+{
+	struct ieee802154_netdev_priv *priv =3D netdev_priv(dev);
+	return blocking_notifier_chain_register(&priv->events, nb);
+}
+EXPORT_SYMBOL(ieee802154_slave_register_notifier);
+int ieee802154_slave_unregister_notifier(struct net_device *dev, struc=
t notifier_block *nb)
+{
+	struct ieee802154_netdev_priv *priv =3D netdev_priv(dev);
+	return blocking_notifier_chain_unregister(&priv->events, nb);
+}
+EXPORT_SYMBOL(ieee802154_slave_unregister_notifier);
+int ieee802154_slave_event(struct net_device *dev, int event, void *da=
ta)
+{
+	struct ieee802154_netdev_priv *priv =3D netdev_priv(dev);
+	return blocking_notifier_call_chain(&priv->events, event, data);
+}
+EXPORT_SYMBOL(ieee802154_slave_event);
+
+/* device should be locked before running */
+void ieee802154_set_pan_id(struct net_device *dev, u16 panid)
+{
+	struct ieee802154_netdev_priv *priv =3D netdev_priv(dev);
+	priv->pan_id =3D panid;
+}
+
diff --git a/net/ieee802154/mac_cmd.c b/net/ieee802154/mac_cmd.c
new file mode 100644
index 0000000..88dc196
--- /dev/null
+++ b/net/ieee802154/mac_cmd.c
@@ -0,0 +1,226 @@
+/*
+ * MAC commands interface
+ *
+ * Copyright 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long
+ * with this program; if not, write to the Free Software Foundation, I=
nc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Sergey Lapin <sergey.lapin@siemens.com>
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ */
+
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+#include <linux/if_ether.h>
+#include <net/ieee802154/af_ieee802154.h>
+#include <net/ieee802154/mac_def.h>
+#include <net/ieee802154/netdev.h>
+#include <net/ieee802154/nl.h>
+#include <net/ieee802154/beacon.h>
+
+static int ieee802154_cmd_beacon_req(struct sk_buff *skb)
+{
+	struct ieee802154_addr saddr; /* jeez */
+	int flags =3D 0;
+	if (skb->len !=3D 1)
+		return -EINVAL;
+
+	if (skb->pkt_type !=3D PACKET_HOST)
+		return 0;
+
+	/* Checking if we're really PAN coordinator
+	 * before sending beacons */
+	if (!(skb->dev->priv_flags & IFF_IEEE802154_COORD))
+		return 0;
+
+	if (MAC_CB(skb)->sa.addr_type !=3D IEEE802154_ADDR_NONE ||
+	    MAC_CB(skb)->da.addr_type !=3D IEEE802154_ADDR_SHORT ||
+	    MAC_CB(skb)->da.pan_id !=3D IEEE802154_PANID_BROADCAST ||
+	    MAC_CB(skb)->da.short_addr !=3D IEEE802154_ADDR_BROADCAST)
+		return -EINVAL;
+
+
+	/* 7 bytes of MHR and 1 byte of command frame identifier
+	 * We have no information in this command to proceed with.
+	 * we need to submit beacon as answer to this. */
+
+	return ieee802154_send_beacon(skb->dev, &saddr, ieee802154_dev_get_pa=
n_id(skb->dev),
+			NULL, 0, flags, NULL);
+}
+
+static int ieee802154_cmd_assoc_req(struct sk_buff *skb)
+{
+	u8 cap;
+
+	if (skb->len !=3D 2)
+		return -EINVAL;
+
+	if (skb->pkt_type !=3D PACKET_HOST)
+		return 0;
+
+	if (MAC_CB(skb)->sa.addr_type !=3D IEEE802154_ADDR_LONG ||
+	    MAC_CB(skb)->sa.pan_id !=3D IEEE802154_PANID_BROADCAST)
+		return -EINVAL;
+
+	/* FIXME: check that we allow incoming ASSOC requests by consulting M=
IB */
+
+	cap =3D skb->data[1];
+
+	return ieee802154_nl_assoc_indic(skb->dev, &MAC_CB(skb)->sa, cap);
+}
+
+static int ieee802154_cmd_assoc_resp(struct sk_buff *skb)
+{
+	u8 status;
+	u16 short_addr;
+
+	if (skb->len !=3D 4)
+		return -EINVAL;
+
+	if (skb->pkt_type !=3D PACKET_HOST)
+		return 0;
+
+	if (MAC_CB(skb)->sa.addr_type !=3D IEEE802154_ADDR_LONG ||
+	    MAC_CB(skb)->sa.addr_type !=3D IEEE802154_ADDR_LONG ||
+	    !(MAC_CB(skb)->flags & MAC_CB_FLAG_INTRAPAN))
+		return -EINVAL;
+
+	/* FIXME: check that we requested association ? */
+
+	status =3D skb->data[3];
+	short_addr =3D skb->data[1] | (skb->data[2] << 8);
+	pr_info("Received ASSOC-RESP status %x, addr %hx\n", status, short_ad=
dr);
+	if (status) {
+		ieee802154_dev_set_short_addr(skb->dev, IEEE802154_ADDR_BROADCAST);
+		ieee802154_dev_set_pan_id(skb->dev, IEEE802154_PANID_BROADCAST);
+	} else
+		ieee802154_dev_set_short_addr(skb->dev, short_addr);
+
+	return ieee802154_nl_assoc_confirm(skb->dev, short_addr, status);
+}
+
+static int ieee802154_cmd_disassoc_notify(struct sk_buff *skb)
+{
+	u8 reason;
+
+	if (skb->len !=3D 2)
+		return -EINVAL;
+
+	if (skb->pkt_type !=3D PACKET_HOST)
+		return 0;
+
+	if (MAC_CB(skb)->sa.addr_type !=3D IEEE802154_ADDR_LONG ||
+	    (MAC_CB(skb)->da.addr_type !=3D IEEE802154_ADDR_LONG &&
+	     MAC_CB(skb)->da.addr_type !=3D IEEE802154_ADDR_SHORT) ||
+	    MAC_CB(skb)->sa.pan_id !=3D MAC_CB(skb)->da.pan_id)
+		return -EINVAL;
+
+	reason =3D skb->data[1];
+
+	/* FIXME: checks if this was our coordinator and the disassoc us */
+	/* FIXME: if we device, one should receive ->da and not ->sa */
+	/* FIXME: the status should also help */
+
+	return ieee802154_nl_disassoc_indic(skb->dev, &MAC_CB(skb)->sa, reaso=
n);
+}
+
+int ieee802154_process_cmd(struct net_device *dev, struct sk_buff *skb=
)
+{
+	u8 cmd;
+
+	if (skb->len < 1) {
+		pr_warning("Uncomplete command frame!\n");
+		goto drop;
+	}
+
+	cmd =3D *(skb->data);
+	pr_debug("Command %02x on device %s\n", cmd, dev->name);
+
+	switch (cmd) {
+	case IEEE802154_CMD_ASSOCIATION_REQ:
+		ieee802154_cmd_assoc_req(skb);
+		break;
+	case IEEE802154_CMD_ASSOCIATION_RESP:
+		ieee802154_cmd_assoc_resp(skb);
+		break;
+	case IEEE802154_CMD_DISASSOCIATION_NOTIFY:
+		ieee802154_cmd_disassoc_notify(skb);
+		break;
+	case IEEE802154_CMD_BEACON_REQ:
+		ieee802154_cmd_beacon_req(skb);
+		break;
+	default:
+		pr_debug("Frame type is not supported yet\n");
+		goto drop;
+	}
+
+
+	kfree_skb(skb);
+	return NET_RX_SUCCESS;
+
+drop:
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee802154_send_beacon_req(struct net_device *dev)
+{
+	struct ieee802154_addr addr;
+	struct ieee802154_addr saddr;
+	u8 cmd =3D IEEE802154_CMD_BEACON_REQ;
+	addr.addr_type =3D IEEE802154_ADDR_SHORT;
+	addr.short_addr =3D IEEE802154_ADDR_BROADCAST;
+	addr.pan_id =3D IEEE802154_PANID_BROADCAST;
+	saddr.addr_type =3D IEEE802154_ADDR_NONE;
+	return ieee802154_send_cmd(dev, &addr, &saddr, &cmd, 1);
+}
+
+int ieee802154_send_cmd(struct net_device *dev,
+		struct ieee802154_addr *addr, struct ieee802154_addr *saddr,
+		const u8 *buf, int len)
+{
+	struct sk_buff *skb;
+	int err;
+	struct ieee802154_priv *hw =3D ieee802154_slave_get_hw(dev);
+
+	BUG_ON(dev->type !=3D ARPHRD_IEEE802154);
+
+	skb =3D alloc_skb(LL_ALLOCATED_SPACE(dev) + len, GFP_KERNEL);
+	if (!skb)
+		return -ENOMEM;
+
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+
+	skb_reset_network_header(skb);
+
+	MAC_CB(skb)->flags =3D IEEE802154_FC_TYPE_MAC_CMD | MAC_CB_FLAG_ACKRE=
Q;
+	MAC_CB(skb)->seq =3D hw->dsn;
+	err =3D dev_hard_header(skb, dev, ETH_P_IEEE802154, addr, saddr, len)=
;
+	if (err < 0) {
+		kfree_skb(skb);
+		return err;
+	}
+
+	skb_reset_mac_header(skb);
+	memcpy(skb_put(skb, len), buf, len);
+
+	skb->dev =3D dev;
+	skb->protocol =3D htons(ETH_P_IEEE802154);
+	hw->dsn++;
+
+	return dev_queue_xmit(skb);
+}
+
diff --git a/net/ieee802154/main.c b/net/ieee802154/main.c
new file mode 100644
index 0000000..743c1ea
--- /dev/null
+++ b/net/ieee802154/main.c
@@ -0,0 +1,175 @@
+/*
+ * ieee802154_phy.c
+ *
+ * Description: IEEE 802.15.4 PHY layer
+ *
+ * Copyright (C) 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long
+ * with this program; if not, write to the Free Software Foundation, I=
nc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Pavel Smolenskiy <pavel.smolenskiy@gmail.com>
+ * Maxim Gorbachyov <maxim.gorbachev@siemens.com>
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/workqueue.h>
+
+#include <net/ieee802154/dev.h>
+#include <net/ieee802154/netdev.h>
+#include <net/ieee802154/nl.h>
+
+struct ieee802154_dev *ieee802154_alloc_device(void)
+{
+	struct ieee802154_priv *priv =3D kzalloc(sizeof(struct ieee802154_pri=
v), GFP_KERNEL);
+	INIT_LIST_HEAD(&priv->slaves);
+	spin_lock_init(&priv->slaves_lock);
+	return &priv->hw;
+}
+EXPORT_SYMBOL(ieee802154_alloc_device);
+
+void ieee802154_free_device(struct ieee802154_dev *hw)
+{
+	struct ieee802154_priv *priv =3D ieee802154_to_priv(hw);
+
+	BUG_ON(!list_empty(&priv->slaves));
+	BUG_ON(priv->master);
+
+	kfree(priv);
+}
+EXPORT_SYMBOL(ieee802154_free_device);
+
+int ieee802154_register_device(struct ieee802154_dev *dev, struct ieee=
802154_ops *ops)
+{
+	struct ieee802154_priv *priv =3D ieee802154_to_priv(dev);
+	int rc;
+
+	if (!try_module_get(ops->owner))
+		return -EFAULT;
+
+	BUG_ON(!dev || !dev->name);
+	BUG_ON(!ops || !ops->tx || !ops->cca || !ops->ed || !ops->set_trx_sta=
te);
+
+	priv->ops =3D ops;
+	rc =3D ieee802154_register_netdev_master(priv);
+	if (rc < 0)
+		goto out;
+	priv->dev_workqueue =3D create_singlethread_workqueue(priv->master->n=
ame);
+	if (!priv->dev_workqueue)
+		goto out_wq;
+
+	return 0;
+
+out_wq:
+	ieee802154_unregister_netdev_master(priv);
+out:
+	return rc;
+}
+EXPORT_SYMBOL(ieee802154_register_device);
+
+void ieee802154_unregister_device(struct ieee802154_dev *dev)
+{
+	struct ieee802154_priv *priv =3D ieee802154_to_priv(dev);
+
+	ieee802154_drop_slaves(dev);
+	ieee802154_unregister_netdev_master(priv);
+	flush_workqueue(priv->dev_workqueue);
+	destroy_workqueue(priv->dev_workqueue);
+	module_put(priv->ops->owner);
+}
+EXPORT_SYMBOL(ieee802154_unregister_device);
+
+static void __ieee802154_rx_prepare(struct ieee802154_dev *dev, struct=
 sk_buff *skb, u8 lqi)
+{
+	struct ieee802154_priv *priv =3D ieee802154_to_priv(dev);
+
+	BUG_ON(!skb);
+
+	PHY_CB(skb)->lqi =3D lqi;
+
+	skb->dev =3D priv->master;
+
+	skb->iif =3D skb->dev->ifindex;
+
+	skb->protocol =3D htons(ETH_P_IEEE802154);
+
+	skb_reset_mac_header(skb);
+}
+
+void ieee802154_rx(struct ieee802154_dev *dev, struct sk_buff *skb, u8=
 lqi)
+{
+	struct sk_buff *skb2;
+
+	__ieee802154_rx_prepare(dev, skb, lqi);
+
+	skb2 =3D skb_clone(skb, GFP_KERNEL);
+	netif_rx(skb2);
+
+	ieee802154_subif_rx(dev, skb);
+}
+EXPORT_SYMBOL(ieee802154_rx);
+
+struct rx_work {
+	struct sk_buff *skb;
+	struct work_struct work;
+	struct ieee802154_dev *dev;
+};
+
+static void ieee802154_rx_worker(struct work_struct *work)
+{
+	struct rx_work *rw =3D container_of(work, struct rx_work, work);
+	struct sk_buff *skb =3D rw->skb;
+
+	struct sk_buff *skb2 =3D skb_clone(skb, GFP_KERNEL);
+	netif_rx(skb2);
+
+	ieee802154_subif_rx(rw->dev, skb);
+	kfree(rw);
+}
+
+void ieee802154_rx_irqsafe(struct ieee802154_dev *dev, struct sk_buff =
*skb, u8 lqi)
+{
+	struct ieee802154_priv *priv =3D ieee802154_to_priv(dev);
+	struct rx_work *work =3D kzalloc(sizeof(struct rx_work), GFP_ATOMIC);
+
+	if (!work)
+		return;
+
+	__ieee802154_rx_prepare(dev, skb, lqi);
+
+	INIT_WORK(&work->work, ieee802154_rx_worker);
+	work->skb =3D skb;
+	work->dev =3D dev;
+
+	queue_work(priv->dev_workqueue, &work->work);
+}
+EXPORT_SYMBOL(ieee802154_rx_irqsafe);
+
+static int __init ieee802154_init(void)
+{
+	return ieee802154_nl_init();
+}
+module_init(ieee802154_init);
+
+static void __exit ieee802154_exit(void)
+{
+	ieee802154_nl_exit();
+}
+module_exit(ieee802154_exit);
+
+MODULE_DESCRIPTION("IEEE 802.15.4 implementation");
+MODULE_LICENSE("GPL v2");
+
diff --git a/net/ieee802154/mdev.c b/net/ieee802154/mdev.c
new file mode 100644
index 0000000..c5cab08
--- /dev/null
+++ b/net/ieee802154/mdev.c
@@ -0,0 +1,189 @@
+/*
+ * Interface from IEEE802154.4 MAC layer to the userspace, net_device =
part.
+ *
+ * Copyright (C) 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long
+ * with this program; if not, write to the Free Software Foundation, I=
nc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ */
+
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+#include <linux/etherdevice.h>
+
+#include <net/ieee802154/phy.h>
+#include <net/ieee802154/netdev.h>
+#include <net/ieee802154/af_ieee802154.h>
+
+struct ieee802154_mnetdev_priv {
+	struct ieee802154_priv *hw;
+	struct net_device *dev;
+};
+
+struct xmit_work {
+	struct sk_buff *skb;
+	struct work_struct work;
+	struct ieee802154_mnetdev_priv *priv;
+};
+
+static void ieee802154_xmit_worker(struct work_struct *work)
+{
+	struct xmit_work *xw =3D container_of(work, struct xmit_work, work);
+	phy_status_t res;
+
+	if (xw->priv->hw->hw.current_channel !=3D PHY_CB(xw->skb)->chan) {
+		res =3D xw->priv->hw->ops->set_channel(&xw->priv->hw->hw, PHY_CB(xw-=
>skb)->chan);
+		if (res !=3D PHY_SUCCESS) {
+			pr_debug("set_channel failed\n");
+			goto out;
+		}
+	}
+
+	res =3D xw->priv->hw->ops->cca(&xw->priv->hw->hw);
+	if (res !=3D PHY_IDLE) {
+		pr_debug("CCA failed\n");
+		goto out;
+	}
+
+	res =3D xw->priv->hw->ops->set_trx_state(&xw->priv->hw->hw, PHY_TX_ON=
);
+	if (res !=3D PHY_SUCCESS && res !=3D PHY_TX_ON) {
+		pr_debug("set_trx_state returned %d\n", res);
+		goto out;
+	}
+
+	res =3D xw->priv->hw->ops->tx(&xw->priv->hw->hw, xw->skb);
+
+out:
+	/* FIXME: result processing and/or requeue!!! */
+	dev_kfree_skb(xw->skb);
+
+	xw->priv->hw->ops->set_trx_state(&xw->priv->hw->hw, PHY_RX_ON);
+	kfree(xw);
+}
+
+static int ieee802154_master_hard_start_xmit(struct sk_buff *skb, stru=
ct net_device *dev)
+{
+	struct ieee802154_mnetdev_priv *priv =3D netdev_priv(dev);
+	struct xmit_work *work;
+
+	if (skb_cow_head(skb, priv->hw->hw.extra_tx_headroom)) {
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+
+	work =3D kzalloc(sizeof(struct xmit_work), GFP_ATOMIC);
+	if (!work)
+		return NETDEV_TX_BUSY;
+
+	INIT_WORK(&work->work, ieee802154_xmit_worker);
+	work->skb =3D skb;
+	work->priv =3D priv;
+
+	queue_work(priv->hw->dev_workqueue, &work->work);
+
+	return NETDEV_TX_OK;
+}
+
+static int ieee802154_master_open(struct net_device *dev)
+{
+	struct ieee802154_mnetdev_priv *priv;
+	phy_status_t status;
+	priv =3D netdev_priv(dev);
+	if (!priv) {
+		pr_debug("%s:%s: unable to get master private data\n",
+				__FILE__, __func__);
+		return -ENODEV;
+	}
+	status =3D priv->hw->ops->set_trx_state(&priv->hw->hw, PHY_RX_ON);
+	if (status !=3D PHY_SUCCESS) {
+		pr_debug("set_trx_state returned %d\n", status);
+		return -EBUSY;
+	}
+
+	netif_start_queue(dev);
+	return 0;
+}
+
+static int ieee802154_master_close(struct net_device *dev)
+{
+	struct ieee802154_mnetdev_priv *priv;
+	netif_stop_queue(dev);
+	priv =3D netdev_priv(dev);
+
+	priv->hw->ops->set_trx_state(&priv->hw->hw, PHY_FORCE_TRX_OFF);
+	return 0;
+}
+static int ieee802154_master_ioctl(struct net_device *dev, struct ifre=
q *ifr, int cmd)
+{
+	struct ieee802154_mnetdev_priv *priv =3D netdev_priv(dev);
+	switch (cmd) {
+	case IEEE802154_SIOC_ADD_SLAVE:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		return ieee802154_add_slave(&priv->hw->hw, (u8 *) &ifr->ifr_hwaddr.s=
a_data);
+	}
+	return -ENOIOCTLCMD;
+}
+
+static void ieee802154_netdev_setup_master(struct net_device *dev)
+{
+	dev->addr_len		=3D 0;
+	memset(dev->broadcast, 0xff, dev->addr_len);
+	dev->features		=3D NETIF_F_NO_CSUM;
+	dev->hard_header_len	=3D 0;
+	dev->mtu		=3D 127;
+	dev->tx_queue_len	=3D 0;
+	dev->type		=3D ARPHRD_IEEE802154_PHY;
+	dev->flags		=3D IFF_NOARP | IFF_BROADCAST;
+	dev->watchdog_timeo	=3D 0;
+}
+
+static const struct net_device_ops ieee802154_master_ops =3D {
+	.ndo_open		=3D ieee802154_master_open,
+	.ndo_stop		=3D ieee802154_master_close,
+	.ndo_start_xmit		=3D ieee802154_master_hard_start_xmit,
+	.ndo_do_ioctl		=3D ieee802154_master_ioctl,
+};
+
+int ieee802154_register_netdev_master(struct ieee802154_priv *hw)
+{
+	struct net_device *dev;
+	struct ieee802154_mnetdev_priv *priv;
+
+	dev =3D alloc_netdev(sizeof(struct ieee802154_mnetdev_priv),
+			"mwpan%d", ieee802154_netdev_setup_master);
+	if (!dev) {
+		printk(KERN_ERR "Failure to initialize master IEEE802154 device\n");
+		return -ENOMEM;
+	}
+	priv =3D netdev_priv(dev);
+	priv->dev =3D dev;
+	priv->hw =3D hw;
+	hw->master =3D dev;
+	dev->netdev_ops =3D &ieee802154_master_ops;
+	dev->needed_headroom =3D hw->hw.extra_tx_headroom;
+	SET_NETDEV_DEV(dev, hw->hw.parent);
+	register_netdev(dev);
+	return 0;
+}
+
+void ieee802154_unregister_netdev_master(struct ieee802154_priv *hw)
+{
+	struct net_device *dev =3D hw->master;
+	BUG_ON(!hw->master);
+
+	unregister_netdev(hw->master);
+	hw->master =3D NULL;
+	free_netdev(dev);
+}
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
new file mode 100644
index 0000000..2acf0f1
--- /dev/null
+++ b/net/ieee802154/netlink.c
@@ -0,0 +1,637 @@
+/*
+ * Netlink intefcace for IEEE 802.15.4 stack
+ *
+ * Copyright 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long
+ * with this program; if not, write to the Free Software Foundation, I=
nc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Sergey Lapin <sergey.lapin@siemens.com>
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ */
+
+#include <linux/kernel.h>
+#include <linux/if_arp.h>
+#include <net/netlink.h>
+#include <net/genetlink.h>
+#include <linux/netdevice.h>
+#include <net/ieee802154/af_ieee802154.h>
+#define IEEE802154_NL_WANT_POLICY
+#include <net/ieee802154/nl.h>
+#include <net/ieee802154/mac_def.h>
+#include <net/ieee802154/netdev.h>
+
+static unsigned int ieee802154_seq_num;
+
+static struct genl_family ieee802154_coordinator_family =3D {
+	.id		=3D GENL_ID_GENERATE,
+	.hdrsize	=3D 0,
+	.name		=3D IEEE802154_NL_NAME,
+	.version	=3D 1,
+	.maxattr	=3D IEEE802154_ATTR_MAX,
+};
+
+static struct genl_multicast_group ieee802154_coord_mcgrp =3D {
+	.name		=3D IEEE802154_MCAST_COORD_NAME,
+};
+
+static struct genl_multicast_group ieee802154_beacon_mcgrp =3D {
+	.name		=3D IEEE802154_MCAST_BEACON_NAME,
+};
+
+/* Requests to userspace */
+
+int ieee802154_nl_assoc_indic(struct net_device *dev, struct ieee80215=
4_addr *addr, u8 cap)
+{
+	struct sk_buff *msg;
+	void *hdr;
+
+	pr_debug("%s\n", __func__);
+
+	msg =3D nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
+	if (!msg)
+		goto out_msg;
+
+	hdr =3D genlmsg_put(msg, 0, ieee802154_seq_num++, &ieee802154_coordin=
ator_family, /* flags*/ 0, IEEE802154_ASSOCIATE_INDIC);
+	if (!hdr)
+		goto out_free;
+
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
+	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
+	NLA_PUT_HW_ADDR(msg, IEEE802154_ATTR_HW_ADDR, dev->dev_addr);
+
+	/* FIXME: check that we really received hw address */
+	NLA_PUT_HW_ADDR(msg, IEEE802154_ATTR_SRC_HW_ADDR, addr->hwaddr);
+
+	NLA_PUT_U8(msg, IEEE802154_ATTR_CAPABILITY, cap);
+
+	if (!genlmsg_end(msg, hdr))
+		goto out_free;
+
+	return genlmsg_multicast(msg, 0, ieee802154_coord_mcgrp.id, GFP_ATOMI=
C);
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+out_free:
+	nlmsg_free(msg);
+out_msg:
+	return -ENOBUFS;
+}
+
+int ieee802154_nl_beacon_indic(struct net_device *dev, u16 panid, u16 =
coord_addr) /* TODO */
+{
+	struct sk_buff *msg;
+	void *hdr;
+	msg =3D nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
+	if (!msg)
+		goto out_msg;
+	hdr =3D genlmsg_put(msg, 0, ieee802154_seq_num++, &ieee802154_coordin=
ator_family, /* flags*/ 0, IEEE802154_ASSOCIATE_CONF);
+	if (!hdr)
+		goto out_free;
+
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
+	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
+	NLA_PUT_HW_ADDR(msg, IEEE802154_ATTR_HW_ADDR, dev->dev_addr);
+	NLA_PUT_U16(msg, IEEE802154_ATTR_COORD_SHORT_ADDR, coord_addr);
+	NLA_PUT_U16(msg, IEEE802154_ATTR_COORD_PAN_ID, panid);
+
+	if (!genlmsg_end(msg, hdr))
+		goto out_free;
+
+	/* FIXME different multicast group needed */
+	return genlmsg_multicast(msg, 0, ieee802154_beacon_mcgrp.id, GFP_ATOM=
IC);
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+out_free:
+	nlmsg_free(msg);
+out_msg:
+	return -ENOBUFS;
+}
+
+int ieee802154_nl_assoc_confirm(struct net_device *dev, u16 short_addr=
, u8 status)
+{
+	struct sk_buff *msg;
+	void *hdr;
+
+	pr_debug("%s\n", __func__);
+
+	msg =3D nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
+	if (!msg)
+		goto out_msg;
+
+	hdr =3D genlmsg_put(msg, 0, ieee802154_seq_num++, &ieee802154_coordin=
ator_family, /* flags*/ 0, IEEE802154_ASSOCIATE_CONF);
+	if (!hdr)
+		goto out_free;
+
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
+	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
+	NLA_PUT_HW_ADDR(msg, IEEE802154_ATTR_HW_ADDR, dev->dev_addr);
+
+	NLA_PUT_U16(msg, IEEE802154_ATTR_SHORT_ADDR, short_addr);
+	NLA_PUT_U8(msg, IEEE802154_ATTR_STATUS, status);
+
+	if (!genlmsg_end(msg, hdr))
+		goto out_free;
+
+	return genlmsg_multicast(msg, 0, ieee802154_coord_mcgrp.id, GFP_ATOMI=
C);
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+out_free:
+	nlmsg_free(msg);
+out_msg:
+	return -ENOBUFS;
+}
+
+int ieee802154_nl_disassoc_indic(struct net_device *dev, struct ieee80=
2154_addr *addr, u8 reason)
+{
+	struct sk_buff *msg;
+	void *hdr;
+
+	pr_debug("%s\n", __func__);
+
+	msg =3D nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
+	if (!msg)
+		goto out_msg;
+
+	hdr =3D genlmsg_put(msg, 0, ieee802154_seq_num++, &ieee802154_coordin=
ator_family, /* flags*/ 0, IEEE802154_DISASSOCIATE_INDIC);
+	if (!hdr)
+		goto out_free;
+
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
+	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
+	NLA_PUT_HW_ADDR(msg, IEEE802154_ATTR_HW_ADDR, dev->dev_addr);
+
+	if (addr->addr_type =3D=3D IEEE802154_ADDR_LONG)
+		NLA_PUT_HW_ADDR(msg, IEEE802154_ATTR_SRC_HW_ADDR, addr->hwaddr);
+	else
+		NLA_PUT_U16(msg, IEEE802154_ATTR_SRC_SHORT_ADDR, addr->short_addr);
+
+	NLA_PUT_U8(msg, IEEE802154_ATTR_REASON, reason);
+
+	if (!genlmsg_end(msg, hdr))
+		goto out_free;
+
+	return genlmsg_multicast(msg, 0, ieee802154_coord_mcgrp.id, GFP_ATOMI=
C);
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+out_free:
+	nlmsg_free(msg);
+out_msg:
+	return -ENOBUFS;
+}
+
+int ieee802154_nl_disassoc_confirm(struct net_device *dev, u8 status)
+{
+	struct sk_buff *msg;
+	void *hdr;
+
+	pr_debug("%s\n", __func__);
+
+	msg =3D nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
+	if (!msg)
+		goto out_msg;
+
+	hdr =3D genlmsg_put(msg, 0, ieee802154_seq_num++, &ieee802154_coordin=
ator_family, /* flags*/ 0, IEEE802154_DISASSOCIATE_CONF);
+	if (!hdr)
+		goto out_free;
+
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
+	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
+	NLA_PUT_HW_ADDR(msg, IEEE802154_ATTR_HW_ADDR, dev->dev_addr);
+
+	NLA_PUT_U8(msg, IEEE802154_ATTR_STATUS, status);
+
+	if (!genlmsg_end(msg, hdr))
+		goto out_free;
+
+	return genlmsg_multicast(msg, 0, ieee802154_coord_mcgrp.id, GFP_ATOMI=
C);
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+out_free:
+	nlmsg_free(msg);
+out_msg:
+	return -ENOBUFS;
+}
+
+int ieee802154_nl_scan_confirm(struct net_device *dev, u8 status, u8 s=
can_type, u32 unscanned,
+		u8 *edl/* , struct list_head *pan_desc_list */)
+{
+	struct sk_buff *msg;
+	void *hdr;
+
+	pr_debug("%s\n", __func__);
+
+	msg =3D nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
+	if (!msg)
+		goto out_msg;
+
+	hdr =3D genlmsg_put(msg, 0, ieee802154_seq_num++, &ieee802154_coordin=
ator_family, /* flags*/ 0, IEEE802154_SCAN_CONF);
+	if (!hdr)
+		goto out_free;
+
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
+	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
+	NLA_PUT_HW_ADDR(msg, IEEE802154_ATTR_HW_ADDR, dev->dev_addr);
+
+	NLA_PUT_U8(msg, IEEE802154_ATTR_STATUS, status);
+	NLA_PUT_U8(msg, IEEE802154_ATTR_SCAN_TYPE, scan_type);
+	NLA_PUT_U32(msg, IEEE802154_ATTR_CHANNELS, unscanned);
+
+	if (edl)
+		NLA_PUT(msg, IEEE802154_ATTR_ED_LIST, 27, edl);
+
+	if (!genlmsg_end(msg, hdr))
+		goto out_free;
+
+	return genlmsg_multicast(msg, 0, ieee802154_coord_mcgrp.id, GFP_ATOMI=
C);
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+out_free:
+	nlmsg_free(msg);
+out_msg:
+	return -ENOBUFS;
+}
+
+/* Requests from userspace */
+
+static int ieee802154_associate_req(struct sk_buff *skb, struct genl_i=
nfo *info)
+{
+	struct net_device *dev;
+	struct ieee802154_addr addr, saddr;
+	u8 buf[2];
+	int pos =3D 0;
+	int ret =3D -EINVAL;
+
+	if (!info->attrs[IEEE802154_ATTR_CHANNEL]
+	 || !info->attrs[IEEE802154_ATTR_COORD_PAN_ID]
+	 || (!info->attrs[IEEE802154_ATTR_COORD_HW_ADDR] && !info->attrs[IEEE=
802154_ATTR_COORD_SHORT_ADDR])
+	 || !info->attrs[IEEE802154_ATTR_CAPABILITY])
+		return -EINVAL;
+
+	if (info->attrs[IEEE802154_ATTR_DEV_NAME]) {
+		char name[IFNAMSIZ + 1];
+		nla_strlcpy(name, info->attrs[IEEE802154_ATTR_DEV_NAME], sizeof(name=
));
+		dev =3D dev_get_by_name(&init_net, name);
+	} else if (info->attrs[IEEE802154_ATTR_DEV_INDEX]) {
+		dev =3D dev_get_by_index(&init_net, nla_get_u32(info->attrs[IEEE8021=
54_ATTR_DEV_INDEX]));
+	} else
+		return -ENODEV;
+
+	if (!dev)
+		return -ENODEV;
+	if (dev->type !=3D ARPHRD_IEEE802154) {
+		dev_put(dev);
+		return -EINVAL;
+	}
+
+	if (info->attrs[IEEE802154_ATTR_COORD_HW_ADDR]) {
+		addr.addr_type =3D IEEE802154_ADDR_LONG;
+		NLA_GET_HW_ADDR(info->attrs[IEEE802154_ATTR_COORD_HW_ADDR], addr.hwa=
ddr);
+	} else {
+		addr.addr_type =3D IEEE802154_ADDR_SHORT;
+		addr.short_addr =3D nla_get_u16(info->attrs[IEEE802154_ATTR_COORD_SH=
ORT_ADDR]);
+	}
+	addr.pan_id =3D nla_get_u16(info->attrs[IEEE802154_ATTR_COORD_PAN_ID]=
);
+
+	saddr.addr_type =3D IEEE802154_ADDR_LONG;
+	saddr.pan_id =3D IEEE802154_PANID_BROADCAST;
+	memcpy(saddr.hwaddr, dev->dev_addr, IEEE802154_ADDR_LEN);
+
+	/* FIXME: set PIB/MIB info */
+	ieee802154_dev_set_pan_id(dev, addr.pan_id);
+	ieee802154_dev_set_channel(dev, nla_get_u8(info->attrs[IEEE802154_ATT=
R_CHANNEL]));
+
+	buf[pos++] =3D IEEE802154_CMD_ASSOCIATION_REQ;
+	buf[pos++] =3D nla_get_u8(info->attrs[IEEE802154_ATTR_CAPABILITY]);
+	ret =3D ieee802154_send_cmd(dev, &addr, &saddr, buf, pos);
+
+	dev_put(dev);
+	return ret;
+}
+
+static int ieee802154_associate_resp(struct sk_buff *skb, struct genl_=
info *info)
+{
+	struct net_device *dev;
+	struct ieee802154_addr addr, saddr;
+	u8 buf[4];
+	int pos =3D 0;
+	u16 short_addr;
+	int ret =3D -EINVAL;
+
+	if (!info->attrs[IEEE802154_ATTR_STATUS]
+	 || !info->attrs[IEEE802154_ATTR_DEST_HW_ADDR]
+	 || !info->attrs[IEEE802154_ATTR_DEST_SHORT_ADDR])
+		return -EINVAL;
+
+	if (info->attrs[IEEE802154_ATTR_DEV_NAME]) {
+		char name[IFNAMSIZ + 1];
+		nla_strlcpy(name, info->attrs[IEEE802154_ATTR_DEV_NAME], sizeof(name=
));
+		dev =3D dev_get_by_name(&init_net, name);
+	} else if (info->attrs[IEEE802154_ATTR_DEV_INDEX]) {
+		dev =3D dev_get_by_index(&init_net, nla_get_u32(info->attrs[IEEE8021=
54_ATTR_DEV_INDEX]));
+	} else
+		return -ENODEV;
+
+	if (!dev)
+		return -ENODEV;
+	if (dev->type !=3D ARPHRD_IEEE802154) {
+		dev_put(dev);
+		return -EINVAL;
+	}
+
+	addr.addr_type =3D IEEE802154_ADDR_LONG;
+	NLA_GET_HW_ADDR(info->attrs[IEEE802154_ATTR_DEST_HW_ADDR], addr.hwadd=
r);
+	addr.pan_id =3D ieee802154_dev_get_pan_id(dev);
+
+	saddr.addr_type =3D IEEE802154_ADDR_LONG;
+	saddr.pan_id =3D addr.pan_id;
+	memcpy(saddr.hwaddr, dev->dev_addr, IEEE802154_ADDR_LEN);
+
+	short_addr =3D nla_get_u16(info->attrs[IEEE802154_ATTR_DEST_SHORT_ADD=
R]);
+
+	buf[pos++] =3D IEEE802154_CMD_ASSOCIATION_RESP;
+	buf[pos++] =3D short_addr;
+	buf[pos++] =3D short_addr >> 8;
+	buf[pos++] =3D nla_get_u8(info->attrs[IEEE802154_ATTR_STATUS]);
+
+	ret =3D ieee802154_send_cmd(dev, &addr, &saddr, buf, pos);
+
+	dev_put(dev);
+	return ret;
+}
+
+static int ieee802154_disassociate_req(struct sk_buff *skb, struct gen=
l_info *info)
+{
+	struct net_device *dev;
+	struct ieee802154_addr addr, saddr;
+	u8 buf[2];
+	int pos =3D 0;
+	int ret =3D -EINVAL;
+
+	if ((!info->attrs[IEEE802154_ATTR_DEST_HW_ADDR] && !info->attrs[IEEE8=
02154_ATTR_DEST_SHORT_ADDR])
+	 || !info->attrs[IEEE802154_ATTR_REASON])
+		return -EINVAL;
+
+	if (info->attrs[IEEE802154_ATTR_DEV_NAME]) {
+		char name[IFNAMSIZ + 1];
+		nla_strlcpy(name, info->attrs[IEEE802154_ATTR_DEV_NAME], sizeof(name=
));
+		dev =3D dev_get_by_name(&init_net, name);
+	} else if (info->attrs[IEEE802154_ATTR_DEV_INDEX]) {
+		dev =3D dev_get_by_index(&init_net, nla_get_u32(info->attrs[IEEE8021=
54_ATTR_DEV_INDEX]));
+	} else
+		return -ENODEV;
+
+	if (!dev)
+		return -ENODEV;
+	if (dev->type !=3D ARPHRD_IEEE802154) {
+		dev_put(dev);
+		return -EINVAL;
+	}
+
+	if (info->attrs[IEEE802154_ATTR_DEST_HW_ADDR]) {
+		addr.addr_type =3D IEEE802154_ADDR_LONG;
+		NLA_GET_HW_ADDR(info->attrs[IEEE802154_ATTR_DEST_HW_ADDR], addr.hwad=
dr);
+	} else {
+		addr.addr_type =3D IEEE802154_ADDR_SHORT;
+		addr.short_addr =3D nla_get_u16(info->attrs[IEEE802154_ATTR_DEST_SHO=
RT_ADDR]);
+	}
+	addr.pan_id =3D ieee802154_dev_get_pan_id(dev);
+
+	saddr.addr_type =3D IEEE802154_ADDR_LONG;
+	saddr.pan_id =3D ieee802154_dev_get_pan_id(dev);
+	memcpy(saddr.hwaddr, dev->dev_addr, IEEE802154_ADDR_LEN);
+
+	buf[pos++] =3D IEEE802154_CMD_DISASSOCIATION_NOTIFY;
+	buf[pos++] =3D nla_get_u8(info->attrs[IEEE802154_ATTR_REASON]);
+	ret =3D ieee802154_send_cmd(dev, &addr, &saddr, buf, pos);
+
+	/* FIXME: this should be after the ack receved */
+	ieee802154_dev_set_pan_id(dev, 0xffff);
+	ieee802154_dev_set_short_addr(dev, 0xffff);
+	ieee802154_nl_disassoc_confirm(dev, 0x00);
+
+	dev_put(dev);
+	return ret;
+}
+
+/*
+ * PANid, channel, beacon_order =3D 15, superframe_order =3D 15,
+ * PAN_coordinator, battery_life_extension =3D 0,
+ * coord_realignment =3D 0, security_enable =3D 0
+*/
+static int ieee802154_start_req(struct sk_buff *skb, struct genl_info =
*info)
+{
+	struct net_device *dev;
+	u16 panid;
+	u8 channel =3D 0, bcn_ord =3D 15, sf_ord =3D 15;
+	int pan_coord, blx =3D 0, coord_realign =3D 0, sec =3D 0;
+	u16 short_addr;
+	int ret;
+
+	if (!info->attrs[IEEE802154_ATTR_COORD_PAN_ID]
+	 || !info->attrs[IEEE802154_ATTR_COORD_SHORT_ADDR]
+/*
+	 || !info->attrs[IEEE802154_ATTR_CHANNEL]
+	 || !info->attrs[IEEE802154_ATTR_BCN_ORD]
+	 || !info->attrs[IEEE802154_ATTR_SF_ORD]
+*/
+	 || !info->attrs[IEEE802154_ATTR_PAN_COORD]
+/*
+	 || !info->attrs[IEEE802154_ATTR_BAT_EXT]
+	 || !info->attrs[IEEE802154_ATTR_COORD_REALIGN]
+	 || !info->attrs[IEEE802154_ATTR_SEC] */)
+		return -EINVAL;
+	if (info->attrs[IEEE802154_ATTR_DEV_NAME]) {
+		char name[IFNAMSIZ + 1];
+		nla_strlcpy(name, info->attrs[IEEE802154_ATTR_DEV_NAME], sizeof(name=
));
+		dev =3D dev_get_by_name(&init_net, name);
+	} else if (info->attrs[IEEE802154_ATTR_DEV_INDEX]) {
+		dev =3D dev_get_by_index(&init_net, nla_get_u32(info->attrs[IEEE8021=
54_ATTR_DEV_INDEX]));
+	} else
+		return -ENODEV;
+
+	if (!dev)
+		return -ENODEV;
+
+
+	if (dev->type !=3D ARPHRD_IEEE802154) {
+		dev_put(dev);
+		return -EINVAL;
+	}
+	panid =3D nla_get_u16(info->attrs[IEEE802154_ATTR_COORD_PAN_ID]);
+#if 0
+	channel =3D nla_get_u8(info->attrs[IEEE802154_ATTR_CHANNEL]);
+	bcn_ord =3D nla_get_u8(info->attrs[IEEE802154_ATTR_BCN_ORD]);
+	sf_ord =3D nla_get_u8(info->attrs[IEEE802154_ATTR_SF_ORD]);
+#endif
+	pan_coord =3D nla_get_u8(info->attrs[IEEE802154_ATTR_PAN_COORD]);
+#if 0
+	blx =3D nla_get_u8(info->attrs[IEEE802154_ATTR_BAT_EXT]);
+	coord_realign =3D nla_get_u8(info->attrs[IEEE802154_ATTR_COORD_REALIG=
N]);
+	sec =3D nla_get_u8(info->attrs[IEEE802154_ATTR_COORD_SEC]);
+#endif
+	short_addr =3D nla_get_u16(info->attrs[IEEE802154_ATTR_COORD_SHORT_AD=
DR]);
+	ret =3D ieee802154_mlme_start_req(dev, panid, channel, bcn_ord, sf_or=
d,
+		pan_coord, blx, coord_realign, sec);
+	if (ret < 0)
+		goto out;
+	ieee802154_dev_set_short_addr(dev, short_addr);
+out:
+	dev_put(dev);
+	return ret;
+}
+
+static int ieee802154_scan_req(struct sk_buff *skb, struct genl_info *=
info)
+{
+	struct net_device *dev;
+	int ret;
+	u8 type;
+	u32 channels;
+	u8 duration;
+
+	if (!info->attrs[IEEE802154_ATTR_SCAN_TYPE]
+	 || !info->attrs[IEEE802154_ATTR_CHANNELS]
+	 || !info->attrs[IEEE802154_ATTR_DURATION])
+		return -EINVAL;
+
+	if (info->attrs[IEEE802154_ATTR_DEV_NAME]) {
+		char name[IFNAMSIZ + 1];
+		nla_strlcpy(name, info->attrs[IEEE802154_ATTR_DEV_NAME], sizeof(name=
));
+		dev =3D dev_get_by_name(&init_net, name);
+	} else if (info->attrs[IEEE802154_ATTR_DEV_INDEX]) {
+		dev =3D dev_get_by_index(&init_net, nla_get_u32(info->attrs[IEEE8021=
54_ATTR_DEV_INDEX]));
+	} else
+		return -ENODEV;
+
+	if (!dev)
+		return -ENODEV;
+	if (dev->type !=3D ARPHRD_IEEE802154) {
+		dev_put(dev);
+		return -EINVAL;
+	}
+
+	type =3D nla_get_u8(info->attrs[IEEE802154_ATTR_SCAN_TYPE]);
+	channels =3D nla_get_u32(info->attrs[IEEE802154_ATTR_CHANNELS]);
+	duration =3D nla_get_u8(info->attrs[IEEE802154_ATTR_DURATION]);
+
+	ret =3D ieee802154_mlme_scan_req(dev, type, channels, duration);
+
+	dev_put(dev);
+	return ret;
+}
+
+#define IEEE802154_OP(_cmd, _func)			\
+	{						\
+		.cmd	=3D _cmd,				\
+		.policy	=3D ieee802154_policy,		\
+		.doit	=3D _func,			\
+		.dumpit	=3D NULL,				\
+		.flags	=3D GENL_ADMIN_PERM,		\
+	}
+
+static struct genl_ops ieee802154_coordinator_ops[] =3D {
+	IEEE802154_OP(IEEE802154_ASSOCIATE_REQ, ieee802154_associate_req),
+	IEEE802154_OP(IEEE802154_ASSOCIATE_RESP, ieee802154_associate_resp),
+	IEEE802154_OP(IEEE802154_DISASSOCIATE_REQ, ieee802154_disassociate_re=
q),
+	IEEE802154_OP(IEEE802154_SCAN_REQ, ieee802154_scan_req),
+	IEEE802154_OP(IEEE802154_START_REQ, ieee802154_start_req),
+};
+
+#if 0
+static int ieee802154_coordinator_rcv(struct sk_buff *skb, struct genl=
_info *info)
+{
+	struct sk_buff *msg;
+	void *hdr;
+	char name[IFNAMSIZ + 1];
+	struct net_device *dev;
+
+
+	pr_debug("%s\n", __func__);
+
+	if (!info->attrs[IEEE802154_ATTR_DEV_NAME])
+		return -EINVAL;
+
+	nla_strlcpy(name, info->attrs[IEEE802154_ATTR_DEV_NAME], sizeof(name)=
);
+
+	dev =3D dev_get_by_name(&init_net, name);
+	if (!dev)
+		goto out_dev;
+
+	msg =3D nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
+	if (!msg)
+		goto out_msg;
+
+	hdr =3D genlmsg_put(msg, info->snd_pid, info->snd_seq, &ieee802154_co=
ordinator_family, /* flags*/ 0, /* cmd */ 1);
+	if (!hdr)
+		goto out_free;
+
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, name);
+	NLA_PUT_U64(msg, IEEE802154_ATTR_HW_ADDR, *(u64 *)&dev->dev_addr);
+
+	if (!genlmsg_end(msg, hdr))
+		goto out_free;
+
+	return genlmsg_unicast(msg, info->snd_pid);
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+out_free:
+	nlmsg_free(msg);
+out_msg:
+	dev_put(dev);
+out_dev:
+	return -ENOBUFS;
+}
+#endif
+
+int __init ieee802154_nl_init(void)
+{
+	int rc;
+	int i;
+
+	rc =3D genl_register_family(&ieee802154_coordinator_family);
+	if (rc)
+		goto fail;
+
+	rc =3D genl_register_mc_group(&ieee802154_coordinator_family, &ieee80=
2154_coord_mcgrp);
+	if (rc)
+		goto fail;
+
+	rc =3D genl_register_mc_group(&ieee802154_coordinator_family, &ieee80=
2154_beacon_mcgrp);
+	if (rc)
+		goto fail;
+
+
+	for (i =3D 0; i < ARRAY_SIZE(ieee802154_coordinator_ops); i++) {
+		rc =3D genl_register_ops(&ieee802154_coordinator_family, &ieee802154=
_coordinator_ops[i]);
+		if (rc)
+			goto fail;
+	}
+
+	return 0;
+
+fail:
+	genl_unregister_family(&ieee802154_coordinator_family);
+	return rc;
+}
+
+void __exit ieee802154_nl_exit(void)
+{
+	genl_unregister_family(&ieee802154_coordinator_family);
+}
diff --git a/net/ieee802154/scan.c b/net/ieee802154/scan.c
new file mode 100644
index 0000000..a9c319f
--- /dev/null
+++ b/net/ieee802154/scan.c
@@ -0,0 +1,211 @@
+/*
+ * scan.c
+ *
+ * Description: MAC scan helper functions.
+ *
+ * Copyright (C) 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long
+ * with this program; if not, write to the Free Software Foundation, I=
nc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Pavel Smolenskiy <pavel.smolenskiy@gmail.com>
+ * Maxim Gorbachyov <maxim.gorbachev@siemens.com>
+ */
+#include <linux/net.h>
+#include <linux/module.h>
+
+#include <net/ieee802154/beacon.h>
+#include <net/ieee802154/dev.h>
+#include <net/ieee802154/netdev.h>
+#include <net/ieee802154/mac_def.h>
+#include <net/ieee802154/nl.h>
+/*
+ * ED scan is periodic issuing of ed device function
+ * on evry permitted channel, so it is virtually PHY-only scan */
+
+struct scan_work {
+	struct work_struct work;
+
+	int (*scan_ch)(struct scan_work *work, int channel, u8 duration);
+	struct net_device *dev;
+
+	u8 edl[27];
+
+	u8 type;
+	u32 channels;
+	u8 duration;
+};
+
+static int scan_ed(struct scan_work *work, int channel, u8 duration)
+{
+	int ret;
+	struct ieee802154_priv *hw =3D ieee802154_slave_get_hw(work->dev);
+	pr_debug("ed scan channel %d duration %d\n", channel, duration);
+	ret =3D hw->ops->ed(&hw->hw, &work->edl[channel]);
+	pr_debug("ed scan channel %d value %d\n", channel, work->edl[channel]=
);
+	return ret;
+}
+
+struct scan_data {
+	struct notifier_block nb;
+	struct list_head scan_head;
+};
+
+static int beacon_notifier(struct notifier_block *p,
+		unsigned long event, void *data)
+{
+	struct ieee802154_pandsc *pd =3D data;
+	struct scan_data *sd =3D container_of(p, struct scan_data, nb);
+	switch (event) {
+	case IEEE802154_NOTIFIER_BEACON:
+		/* TODO: add item to list here */
+		pr_debug("got a beacon frame addr_type %d pan_id %d\n",
+				pd->addr.addr_type, pd->addr.pan_id);
+		break;
+	}
+	return 0;
+}
+
+
+static int scan_passive(struct scan_work *work, int channel, u8 durati=
on)
+{
+	unsigned long j;
+	struct scan_data *data =3D kzalloc(sizeof(struct scan_data), GFP_KERN=
EL);
+	pr_debug("passive scan channel %d duration %d\n", channel, duration);
+	data->nb.notifier_call =3D beacon_notifier;
+	ieee802154_slave_register_notifier(work->dev, &data->nb);
+	/* Hope 2 msecs will be enough for scan */
+	j =3D msecs_to_jiffies(2);
+	while (j > 0)
+		j =3D schedule_timeout(j);
+
+	ieee802154_slave_unregister_notifier(work->dev, &data->nb);
+	kfree(data);
+	return PHY_SUCCESS;
+}
+/* Active scan is periodic submission of beacon request
+ * and waiting for beacons which is useful for collecting LWPAN inform=
ation */
+static int scan_active(struct scan_work *work, int channel, u8 duratio=
n)
+{
+	int ret;
+	pr_debug("active scan channel %d duration %d\n", channel, duration);
+	ret =3D ieee802154_send_beacon_req(work->dev);
+	if (ret < 0)
+		return PHY_ERROR;
+	return scan_passive(work, channel, duration);
+}
+static int scan_orphan(struct scan_work *work, int channel, u8 duratio=
n)
+{
+	pr_debug("orphan scan channel %d duration %d\n", channel, duration);
+	return 0;
+}
+
+static void scanner(struct work_struct *work)
+{
+	struct scan_work *sw =3D container_of(work, struct scan_work, work);
+	struct ieee802154_priv *hw =3D ieee802154_slave_get_hw(sw->dev);
+	int i;
+	phy_status_t ret;
+
+	for (i =3D 0; i < 27; i++) {
+		if (!(sw->channels & (1 << i)))
+			continue;
+
+		ret =3D hw->ops->set_channel(&hw->hw,  i);
+		if (ret !=3D PHY_SUCCESS)
+			goto exit_error;
+
+		ret =3D sw->scan_ch(sw, i, sw->duration);
+		if (ret !=3D PHY_SUCCESS)
+			goto exit_error;
+
+		sw->channels &=3D ~(1 << i);
+	}
+
+	ieee802154_nl_scan_confirm(sw->dev, IEEE802154_SUCCESS, sw->type, sw-=
>channels,
+			sw->edl/*, NULL */);
+
+	kfree(sw);
+
+	return;
+
+exit_error:
+	ieee802154_nl_scan_confirm(sw->dev, IEEE802154_INVALID_PARAMETER, sw-=
>type, sw->channels,
+			NULL/*, NULL */);
+	kfree(sw);
+	return;
+}
+
+/**
+ * @brief MLME-SAP.Scan request
+ *
+ * Alloc ed_detect list for ED scan.
+ *
+ * @param mac current mac pointer
+ * @param type type of the scan to be performed
+ * @param channels 32-bit mask of requested to scan channels
+ * @param duration scan duration, see ieee802.15.4-2003.pdf, page 145.
+ * @return 0 if request is ok, errno otherwise.
+ */
+int ieee802154_mlme_scan_req(struct net_device *dev, u8 type, u32 chan=
nels, u8 duration)
+{
+	struct ieee802154_priv *hw =3D ieee802154_slave_get_hw(dev);
+	struct scan_work *work;
+
+	pr_debug("%s()\n", __func__);
+
+	if (duration > 14)
+		goto inval;
+	if (channels & hw->hw.channel_mask)
+		goto inval;
+
+	work =3D kzalloc(sizeof(struct scan_work), GFP_KERNEL);
+	if (!work)
+		goto inval;
+
+	work->dev =3D dev;
+	work->channels =3D channels;
+	work->duration =3D duration;
+	work->type =3D type;
+
+	switch (type) {
+	case IEEE802154_MAC_SCAN_ED:
+		work->scan_ch =3D scan_ed;
+		break;
+	case IEEE802154_MAC_SCAN_ACTIVE:
+		work->scan_ch =3D scan_active;
+		break;
+	case IEEE802154_MAC_SCAN_PASSIVE:
+		work->scan_ch =3D scan_passive;
+		break;
+	case IEEE802154_MAC_SCAN_ORPHAN:
+		work->scan_ch =3D scan_orphan;
+		break;
+	default:
+		pr_debug("%s(): invalid type %d\n", __func__, type);
+		goto inval;
+	}
+
+	INIT_WORK(&work->work, scanner);
+	queue_work(hw->dev_workqueue, &work->work);
+
+	return 0;
+
+inval:
+	ieee802154_nl_scan_confirm(dev, IEEE802154_INVALID_PARAMETER, type, c=
hannels,
+			NULL/*, NULL */);
+	return -EINVAL;
+}
+EXPORT_SYMBOL(ieee802154_mlme_scan_req);
+
diff --git a/net/ieee802154/start.c b/net/ieee802154/start.c
new file mode 100644
index 0000000..f628cd8
--- /dev/null
+++ b/net/ieee802154/start.c
@@ -0,0 +1,46 @@
+/*
+ * MLME START
+ *
+ * Copyright 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long
+ * with this program; if not, write to the Free Software Foundation, I=
nc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Sergey Lapin <sergey.lapin@siemens.com>
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ */
+
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/if.h>
+#include <linux/if_arp.h>
+#include <linux/if_ether.h>
+#include <net/ieee802154/af_ieee802154.h>
+#include <net/ieee802154/mac_def.h>
+#include <net/ieee802154/netdev.h>
+#include <net/ieee802154/nl.h>
+
+int ieee802154_mlme_start_req(struct net_device *dev, u16 panid, u8 ch=
annel,
+			     u8 bcn_ord, u8 sf_ord, u8 pan_coord, u8 blx,
+			     u8 coord_realign, u8 sec)
+{
+	ieee802154_set_pan_id(dev, panid);
+	if (pan_coord)
+		dev->priv_flags |=3D IFF_IEEE802154_COORD;
+	else
+		dev->priv_flags &=3D ~IFF_IEEE802154_COORD;
+
+	return 0;
+}
+
--=20
1.6.2.4

