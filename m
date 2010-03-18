From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Add PGM protocol support to the IP stack
Date: Thu, 18 Mar 2010 16:58:31 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1003181657070.23010@router.home>
References: <alpine.DEB.2.00.1003181245050.23010@router.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi157.sbcis.sbc.com ([207.115.36.171]:35134 "EHLO
	nlpi157.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056Ab0CRV6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 17:58:38 -0400
In-Reply-To: <alpine.DEB.2.00.1003181245050.23010@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is what I have so far after a couple of hours.
Something hacked together from openpgm and udplite.

---
 Documentation/networking/pgm/TODO       |    8
 Documentation/networking/pgm/references |    2
 Documentation/networking/pgm/usage      |   91 ++++
 include/linux/in.h                      |    2
 include/linux/pgm.h                     |  720 ++++++++++++++++++++++++++++++++
 net/ipv4/Kconfig                        |   14
 net/ipv4/Makefile                       |    3
 net/ipv4/pgm.c                          |  143 ++++++
 8 files changed, 983 insertions(+)

Index: linux-2.6/include/linux/in.h
===================================================================
--- linux-2.6.orig/include/linux/in.h	2010-03-18 11:05:24.000000000 -0500
+++ linux-2.6/include/linux/in.h	2010-03-18 15:47:59.000000000 -0500
@@ -44,6 +44,7 @@ enum {
   IPPROTO_PIM    = 103,		/* Protocol Independent Multicast	*/

   IPPROTO_COMP   = 108,                /* Compression Header protocol */
+  IPPROTO_PGM	 = 113,		/* Pragmatic General Multicast		*/
   IPPROTO_SCTP   = 132,		/* Stream Control Transport Protocol	*/
   IPPROTO_UDPLITE = 136,	/* UDP-Lite (RFC 3828)			*/

@@ -51,6 +52,7 @@ enum {
   IPPROTO_MAX
 };

+#define IPPROTO_RM IPPROTO_PGM

 /* Internet address. */
 struct in_addr {
Index: linux-2.6/include/linux/pgm.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/include/linux/pgm.h	2010-03-18 16:56:19.000000000 -0500
@@ -0,0 +1,720 @@
+/*
+ * PGM packet formats, RFC 3208.
+ *
+ * Copyright (c) 2006 Miru Limited.
+ * Copyright (c) 2010 Christoph Lameter, The Linux Foundation.
+ *
+ * This library is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU Lesser General Public
+ * License as published by the Free Software Foundation; either
+ * version 2.1 of the License, or (at your option) any later version.
+ *
+ * This library is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * Lesser General Public License for more details.
+ *
+ * You should have received a copy of the GNU Lesser General Public
+ * License along with this library; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ * March 17, 2010 Christoph Lameter
+ *		Basic PGM definitions extracted from openpgm project.
+ * March 18, 2010
+ *		Socket API and document intended usage.
+ *		Basic protocol environment (from udplite.c)
+ */
+
+#ifndef _LINUX_PGM_H
+#define _LINUX_PGM_H
+
+#include <linux/types.h>
+
+/* PGM socket options */
+
+/* Transmitter */
+#define RM_LATEJOIN				1	/* X Not supported on receive so why have it? */
+#define RM_RATE_WINDOW_SIZE			2	/* See struct pgm_send_window */
+#define RM_SEND_WINDOW_ADV_RATE			3	/* X Increase of send window in percentage of window */
+#define RM_SENDER_STATISTICS			4	/* see struct pgm_sender_stats */
+#define RM_SENDER_WINDOW_ADVANCE_METHOD		5	/* X seems obsolete */
+#define RM_SET_MCAST_TTL			6	/* X Can be set via IP_MULTICAST_TTL */
+#define RM_SET_MESSAGE_BOUNDARY			7	/* Fix the size of the messages in bytes */
+#define RM_SET_SEND_IF				8	/* X use IP_MULTICAST_IF etc instead */
+#define RM_USE_FEC				9
+
+/* Receiver */
+#define RM_ADD_RECEIVE_IF			100	/* X ???? IP_MULTICAST_IF instead? */
+#define RM_DEL_RECEIVE_IF			101	/* X IP_MULTICAST_IF */
+#define RM_HIGH_SPEED_INTRANET_OPT		102	/* X PGM should adapt automatically to high speed networks */
+#define RM_RECEIVER_STATISTICS			103	/* See struct pgm_receiver_stats */
+
+/* Socket API structures (established by M$DN) */
+struct pgm_receiver_stats {
+	u64	NumODataPacketsReceived;	/* Number of ODATA (original) sequences */
+	u64	NumRDataPacketsReceived;	/* Number of RDATA (repair) sequences */
+	u64	NumDuplicateDataPackets;	/* Duplicate sequences */
+	u64	DataBytesReceived;
+	u64	TotalBytesReceived;
+	u64	RateKBitsPerSecOverall;		/* Receive rate since start of session X */
+	u64	RateKBitsPerSecLast;		/* Receive rate for last second X*/
+	u64	TrailingEdgeSeqId;		/* Oldest sequence in the receive window */
+	u64	LeadingEdgeSeqId;		/* Newest sequence in the receive window */
+	u64	AverageSequencesInWindow;	/* Average number of sequences in receive window X */
+	u64	MinSequencesInWindow;		/* The mininum number of sequences */
+	u64	MaxSequencesInWindow;		/* The maximum number of sequences */
+	u64	FirstNakSequenceNumber;		/* First outstanding nack sequence number */
+	u64	NumPendingNaks;			/* Number of sequences waiting for NCF */
+	u64	NumOutstandingNaks;		/* Number of sequences waiting for RDATA */
+	u64	NumDataPacketsBuffered;		/* Number of packets currently buffered */
+	u64	TotalSelectiveNaksSent;		/* Number of NAKs sent total */
+	u64	TotalParityNaksSent;		/* Number of parity NAKs sent */
+};
+
+struct pgm_sender_stats {
+	u64	DataBytesSent;
+	u64	TotalBytesSent;
+	u64	NaksReceived;
+	u64	NaksReceivedTooLate;		/* NAKs received after receive window advanced */
+	u64	NumOutstandingNaks;		/* Number of NAKs awaiting response */
+	u64	NumNaksAfterRData;		/* Number of NAKs after RDATA sequences were sent which were ignored */
+	u64	RepairPacketsSent;
+	u64	BufferSpaceAvailable;		/* Number of partial messages dropped */
+	u64	TrailingEdgeSeqId;		/* Oldest sequence id in window */
+	u64	LeadingEdgeSeqId;		/* Newest sequence id in window */
+	u64	RateKBitsPerSecOverall;		/* Rate since start of session X */
+	u64	RateKBitsPerSecLast;		/* Rate in last second X */
+	u64	TotalODataPacketsSent;		/* Total data packets transmitted */
+};
+
+/* Setup of sender RateKbitsPerSec = WindowSizeBytes / WindowSizeMSecs */
+struct pgm_send_window {
+  	u64	RateKbitsPerSec;		/* Allowed rate for the sender in kbits per second */
+	u64	WindowSizeInMSecs;		/* Send window size in time */
+	u64	WindowSizeInBytes;		/* Window size in bytes */
+};
+
+struct pgm_fec_info {
+  	u16	FECBlockSize;			/* Maximum number of packets for a group. Default and max = 255 */
+	u16	FECProActivePackets;		/* Number of proactive packets per group. */
+	u8	FECGroupSize;			/* Number of packets to be treated as a group. Power of two */
+  	int	fFECOnDemandParityEnabled;	/* Allow sender to sent parity repair packets */
+};
+
+/* address family indicator, rfc 1700 (ADDRESS FAMILY NUMBERS) */
+#ifndef AFI_IP
+#define AFI_IP	    1	    /* IP (IP version 4) */
+#define AFI_IP6	    2	    /* IP6 (IP version 6) */
+#endif
+
+/* UDP ports for UDP encapsulation, as per IBM WebSphere MQ */
+#define PGM_DEFAULT_UDP_ENCAP_UCAST_PORT	3055
+#define PGM_DEFAULT_UDP_ENCAP_MCAST_PORT	3056
+
+/* PGM default ports */
+#define PGM_DEFAULT_DATA_DESTINATION_PORT	7500
+#define PGM_DEFAULT_DATA_SOURCE_PORT	0	/* random */
+
+/* DoS limitation to protocol (MS08-036, KB950762) */
+#define PGM_MAX_APDU			UINT16_MAX
+
+/* Cisco default: 24 (max 8200), Juniper & H3C default: 16 */
+#define PGM_MAX_FRAGMENTS		16
+
+enum pgm_type {
+    PGM_SPM = 0x00,	/* 8.1: source path message */
+    PGM_POLL = 0x01,	/* 14.7.1: poll request */
+    PGM_POLR = 0x02,	/* 14.7.2: poll response */
+    PGM_ODATA = 0x04,	/* 8.2: original data */
+    PGM_RDATA = 0x05,	/* 8.2: repair data */
+    PGM_NAK = 0x08,	/* 8.3: NAK or negative acknowledgement */
+    PGM_NNAK = 0x09,	/* 8.3: N-NAK or null negative acknowledgement */
+    PGM_NCF = 0x0a,	/* 8.3: NCF or NAK confirmation */
+    PGM_SPMR = 0x0c,	/* 13.6: SPM request */
+    PGM_MAX = 0xff
+};
+
+#define PGM_OPT_LENGTH		    0x00	/* options length */
+#define PGM_OPT_FRAGMENT	    0x01	/* fragmentation */
+#define PGM_OPT_NAK_LIST	    0x02	/* list of nak entries */
+#define PGM_OPT_JOIN		    0x03	/* late joining */
+#define PGM_OPT_REDIRECT	    0x07	/* redirect */
+#define PGM_OPT_SYN		    0x0d	/* synchronisation */
+#define PGM_OPT_FIN		    0x0e	/* session end */
+#define PGM_OPT_RST		    0x0f	/* session reset */
+
+#define PGM_OPT_PARITY_PRM	    0x08	/* forward error correction parameters */
+#define PGM_OPT_PARITY_GRP	    0x09	/*   group number */
+#define PGM_OPT_CURR_TGSIZE	    0x0a	/*   group size */
+
+#define PGM_OPT_CR		    0x10	/* congestion report */
+#define PGM_OPT_CRQST		    0x11	/* congestion report request */
+
+#define PGM_OPT_NAK_BO_IVL	    0x04	/* nak back-off interval */
+#define PGM_OPT_NAK_BO_RNG	    0x05	/* nak back-off range */
+#define PGM_OPT_NBR_UNREACH	    0x0b	/* neighbour unreachable */
+#define PGM_OPT_PATH_NLA	    0x0c	/* path nla */
+
+#define PGM_OPT_INVALID		    0x7f	/* option invalidated */
+
+/* 8. PGM header */
+struct pgm_header {
+	u16		sport;			/* source port: tsi::sport or UDP port depending on direction */
+	u16		dport;			/* destination port */
+	u8		type;			/* version / packet type */
+	u8		options;		/* options */
+#define PGM_OPT_PARITY		0x80	/* parity packet */
+#define PGM_OPT_VAR_PKTLEN	0x40	/* + variable sized packets */
+#define PGM_OPT_NETWORK		0x02    /* network-significant: must be interpreted by network elements */
+#define PGM_OPT_PRESENT		0x01	/* option extension are present */
+	u16		checksum;		/* checksum */
+	u8		gsi[6];			/* global source id */
+	u16		tsdu_length;		/* tsdu length */
+				/* tpdu length = th length (header + options) + tsdu length */
+};
+
+/* 8.1.  Source Path Messages (SPM) */
+struct pgm_spm {
+	u32		sqn;			/* spm sequence number */
+	u32		trail;			/* trailing edge sequence number */
+	u32		lead;			/* leading edge sequence number */
+	u16		nla_afi;		/* nla afi */
+	u16		reserved;		/* reserved */
+	struct in_addr spm_nla;		/* path nla */
+	/* ... option extensions */
+};
+
+struct pgm_spm6 {
+	u32		sqn;			/* spm sequence number */
+	u32		trail;			/* trailing edge sequence number */
+	u32		lead;			/* leading edge sequence number */
+	u16		nla_afi;		/* nla afi */
+	u16		reserved;		/* reserved */
+	struct in6_addr spm6_nla;		/* path nla */
+	/* ... option extensions */
+};
+
+/* 8.2.  Data Packet */
+struct pgm_data {
+	u32		sqn;			/* data packet sequence number */
+	u32		trail;			/* trailing edge sequence number */
+	/* ... option extensions */
+	/* ... data */
+};
+
+/* 8.3.  Negative Acknowledgments and Confirmations (NAK, N-NAK, & NCF) */
+struct pgm_nak {
+	u32		sqn;			/* requested sequence number */
+	u16		src_nla_afi;		/* nla afi */
+	u16		reserved;		/* reserved */
+	struct in_addr src_nla;		/* source nla */
+	u16		grp_nla_afi;		/* nla afi */
+	u16		reserved2;		/* reserved */
+	struct in_addr grp_nla;		/* multicast group nla */
+	/* ... option extension */
+};
+
+struct pgm_nak6 {
+	u32		sqn;			/* requested sequence number */
+	u16		src_nla_afi;		/* nla afi */
+	u16		reserved;		/* reserved */
+	struct in6_addr src_nla;		/* source nla */
+	u16		grp_nla_afi;		/* nla afi */
+	u16		reserved2;		/* reserved */
+	struct in6_addr grp_nla;		/* multicast group nla */
+	/* ... option extension */
+};
+
+/* 9.  Option header (max 16 per packet) */
+struct pgm_opt_header {
+	u8		type;			/* option type */
+#define PGM_OPT_MASK	0x7f
+#define PGM_OPT_END	0x80		/* end of options flag */
+	u8		length;			/* option length */
+	u8		reserved;
+#define PGM_OP_ENCODED		0x8	/* F-bit */
+#define PGM_OPX_MASK		0x3
+#define PGM_OPX_IGNORE		0x0	/* extensibility bits */
+#define PGM_OPX_INVALIDATE	0x1
+#define PGM_OPX_DISCARD		0x2
+#define PGM_OP_ENCODED_NULL	0x80	/* U-bit */
+};
+
+/* 9.1.  Option extension length - OPT_LENGTH */
+struct pgm_opt_length {
+	u8		type;			/* include header as total length overwrites reserved/OPX bits */
+	u8		length;
+	u16		total_length;	    	/* total length of all options */
+};
+
+/* 9.2.  Option fragment - OPT_FRAGMENT */
+struct pgm_opt_fragment {
+	u8		reserved;		/* reserved */
+	u32		sqn;			/* first sequence number */
+	u32		frag_off;		/* offset */
+	u32		frag_len;		/* length */
+};
+
+/* 9.3.5.  Option NAK List - OPT_NAK_LIST */
+struct pgm_opt_nak_list {
+	u8		reserved;		/* reserved */
+	u32		sqn[];
+};
+
+/* 9.4.2.  Option Join - OPT_JOIN */
+struct pgm_opt_join {
+	u8		reserved;		    /* reserved */
+	u32		join_min;		    /* minimum sequence number */
+};
+
+/* 9.5.5.  Option Redirect - OPT_REDIRECT */
+struct pgm_opt_redirect {
+	u8		reserved;		/* reserved */
+	u16		nla_afi;		/* nla afi */
+	u16		reserved2;		/* reserved */
+	struct in_addr nla;		/* dlr nla */
+};
+
+struct pgm_opt6_redirect {
+	u8		reserved;		/* reserved */
+	u16		nla_afi;		/* nla afi */
+	u16		reserved2;		/* reserved */
+	struct in6_addr opt6_nla;		/* dlr nla */
+};
+
+/* 9.6.2.  Option Sources - OPT_SYN */
+struct pgm_opt_syn {
+	u8	    	reserved;		/* reserved */
+};
+
+/* 9.7.4.  Option End Session - OPT_FIN */
+struct pgm_opt_fin {
+	u8		reserved;		/* reserved */
+};
+
+/* 9.8.4.  Option Reset - OPT_RST */
+struct pgm_opt_rst {
+	u8		reserved;		/* reserved */
+};
+
+
+/*
+ * Forward Error Correction - FEC
+ */
+
+/* 11.8.1.  Option Parity - OPT_PARITY_PRM */
+struct pgm_opt_parity_prm {
+	u8	reserved;			/* reserved */
+#define PGM_PARITY_PRM_MASK 0x3
+#define PGM_PARITY_PRM_PRO  0x1		/* source provides pro-active parity packets */
+#define PGM_PARITY_PRM_OND  0x2		/*                 on-demand parity packets */
+	u32		tgs;			/* transmission group size */
+};
+
+/* 11.8.2.  Option Parity Group - OPT_PARITY_GRP */
+struct pgm_opt_parity_grp {
+	u8	reserved;			/* reserved */
+	u32	group;				/* parity group number */
+};
+
+/* 11.8.3.  Option Current Transmission Group Size - OPT_CURR_TGSIZE */
+struct pgm_opt_curr_tgsize {
+	u8	reserved;			/* reserved */
+	u32	atgsize;			/* actual transmission group size */
+};
+
+/*
+ * Congestion Control
+ */
+
+/* 12.7.1.  Option Congestion Report - OPT_CR */
+struct pgm_opt_cr {
+	u8		reserved;		/* reserved */
+	u32		cr_lead;		/* congestion report reference sqn */
+	u16		cr_ne_wl;		/* ne worst link */
+	u16		cr_ne_wp;		/* ne worst path */
+	u16		cr_rx_wp;		/* rcvr worst path */
+	u16		reserved2;		/* reserved */
+	u16		nla_afi;		/* nla afi */
+	u16		reserved3;		/* reserved */
+	u32		cr_rcvr;		/* worst receivers nla */
+};
+
+/* 12.7.2.  Option Congestion Report Request - OPT_CRQST */
+struct pgm_opt_crqst {
+	u8	reserved;			/* reserved */
+};
+
+
+/*
+ * SPM Requests
+ */
+
+/* 13.6.  SPM Requests */
+struct pgm_spmr {
+    /* ... option extensions */
+};
+
+
+/*
+ * Poll Mechanism
+ */
+
+/* 14.7.1.  Poll Request */
+struct pgm_poll {
+	u32		sqn;			/* poll sequence number */
+	u16		round;			/* poll round */
+	u16		type;			/* poll sub-type */
+#define PGM_POLL_GENERAL	0x0	/* general poll  */
+#define PGM_POLL_DLR		0x1	/* DLR poll */
+	u16		nla_afi;		/* nla afi */
+	u16		reserved;		/* reserved */
+	struct in_addr nla;			/* path nla */
+	u32		bo_ivl;			/* poll back-off interval */
+	char	rand[4];		/* random string */
+	u32		mask;			/* matching bit-mask */
+	/* ... option extensions */
+};
+
+struct pgm_poll6 {
+	u32		sqn;			/* poll sequence number */
+	u16		round;		    	/* poll round */
+	u16		s_type;			/* poll sub-type */
+	u16		nla_afi;		/* nla afi */
+	u16		reserved;		/* reserved */
+	struct in6_addr nla;		/* path nla */
+	u32		bo_ivl;			/* poll back-off interval */
+	char	rand[4];		/* random string */
+	u32		mask;			/* matching bit-mask */
+	/* ... option extensions */
+};
+
+/* 14.7.2.  Poll Response */
+struct pgm_polr {
+	u32		sqn;			/* polr sequence number */
+	u16		round;			/* polr round */
+	u16		reserved;		/* reserved */
+	/* ... option extensions */
+};
+
+
+/*
+ * Implosion Prevention
+ */
+
+/* 15.4.1.  Option NAK Back-Off Interval - OPT_NAK_BO_IVL */
+struct pgm_opt_nak_bo_ivl {
+	u8		opt_reserved;		/* reserved */
+	u32		opt_nak_bo_ivl;		/* nak back-off interval */
+	u32		opt_nak_bo_ivl_sqn;	/* nak back-off interval sqn */
+};
+
+/* 15.4.2.  Option NAK Back-Off Range - OPT_NAK_BO_RNG */
+struct pgm_opt_nak_bo_rng {
+	u8		opt_reserved;		/* reserved */
+	u32		opt_nak_max_bo_ivl;	/* maximum nak back-off interval */
+	u32		opt_nak_min_bo_ivl;	/* minimum nak back-off interval */
+};
+
+/* 15.4.3.  Option Neighbour Unreachable - OPT_NBR_UNREACH */
+struct pgm_opt_nbr_unreach {
+	u8		opt_reserved;		/* reserved */
+};
+
+/* 15.4.4.  Option Path - OPT_PATH_NLA */
+struct pgm_opt_path_nla {
+ 	u8		reserved;		/* reserved */
+	struct in_addr opt_path_nla;	/* path nla */
+};
+
+struct pgm_opt6_path_nla {
+	u8		reserved;		/* reserved */
+	struct in6_addr opt6_path_nla;	/* path nla */
+};
+
+#ifdef __KERNEL__
+
+#include <net/inet_sock.h>
+#include <linux/skbuff.h>
+#include <net/netns/hash.h>
+#include <linux/rslib.h>
+
+static inline int pgm_is_upstream(u8 type)
+{
+    return (type == PGM_NAK ||		/* unicast */
+	    type == PGM_NNAK ||		/* unicast */
+	    type == PGM_SPMR ||		/* multicast + unicast */
+	    type == PGM_POLR);		/* unicast */
+}
+
+static inline int pgm_is_peer(u8 type)
+{
+    return (type == PGM_SPMR);		/* multicast */
+}
+
+static inline int pgm_is_downstream (u8 type)
+{
+    return (type == PGM_SPM   ||	/* all multicast */
+	    type == PGM_ODATA ||
+	    type == PGM_RDATA ||
+	    type == PGM_POLL  ||
+	    type == PGM_NCF);
+}
+
+int pgm_verify_spm(struct sk_buff *);
+int pgm_verify_spmr(struct sk_buff *);
+int pgm_verify_nak(struct sk_buff *);
+int pgm_verify_nnak(struct sk_buff *);
+int pgm_verify_ncf(struct sk_buff *);
+int pgm_verify_poll(struct sk_buff *);
+int pgm_verify_polr(struct sk_buff *);
+
+/* Global sesssion ID */
+struct pgm_gsi {
+	char gsi[6];
+};
+
+struct pgm_tsi {
+	char	gsi[6];		/* global session identifier */
+	u16	sport;		/* source port: a random number to help detect session re-starts */
+}
+
+/* Receiver data structures */
+
+enum pgm_rxw_state {
+	PGM_PKT_ERROR_STATE,
+	PGM_PKT_BACK_OFF_STATE,	    /* PGM protocol recovery states */
+	PGM_PKT_WAIT_NCF_STATE,
+	PGM_PKT_WAIT_DATA_STATE,
+
+	PGM_PKT_HAVE_DATA_STATE,	    /* data received waiting to commit to application layer */
+
+	PGM_PKT_HAVE_PARITY_STATE,	    /* contains parity information not original data */
+	PGM_PKT_COMMIT_DATA_STATE,	    /* commited data waiting for purging */
+	PGM_PKT_LOST_DATA_STATE,	    /* if recovery fails, but packet has not yet been commited */
+};
+
+enum pgm_rxw_returns {
+	PGM_RXW_OK,
+	PGM_RXW_INSERTED,
+	PGM_RXW_APPENDED,
+	PGM_RXW_UPDATED,
+	PGM_RXW_MISSING,
+	PGM_RXW_DUPLICATE,
+	PGM_RXW_MALFORMED,
+	PGM_RXW_BOUNDS,
+	PGM_RXW_SLOW_CONSUMER,
+	PGM_RXW_UNKNOWN,
+};
+
+struct pgm_rxw_state {
+	unsigned long	nak_rb_expiry;
+	unsigned long	nak_rpt_expiry;
+	unsigned long	nak_rdata_expiry;
+
+        enum pgm_receiver_state state;
+
+	u8		nak_transmit_count;
+	u8		ncf_retry_count;
+	u8		data_retry_count;
+
+/* only valid on tg_sqn::pkt_sqn = 0 */
+	unsigned	is_contiguous:1;	/* transmission group */
+};
+
+struct pgm_rxw {
+	struct pgm_tsi *	tsi;
+
+        struct list_head backoff_queue;
+        struct list_head wait_ncf_queue;
+        struct list_head wait_data_queue;
+
+	/* window context counters */
+	u32		lost_count;		/* failed to repair */
+	u32		fragment_count;		/* incomplete apdu */
+	u32		parity_count;		/* parity for repairs */
+	u32		committed_count;	/* but still in window */
+
+        u16		max_tpdu;               /* maximum packet size */
+        u32		lead, trail;
+        u32		rxw_trail, rxw_trail_init;
+	u32		commit_lead;
+        unsigned        is_constrained:1;
+        unsigned        is_defined:1;
+	unsigned	has_event:1;		/* edge triggered */
+	unsigned	is_fec_available:1;
+	struct rs_t	rs;
+	u32		tg_size;		/* transmission group size for parity recovery */
+	unsigned	tg_sqn_shift;
+
+	u32		min_fill_time;		/* restricted from pgm_time_t */
+	u32		max_fill_time;
+	u32		min_nak_transmit_count;
+	u32		max_nak_transmit_count;
+	u32		cumulative_losses;
+	u32		bytes_delivered;		/* Fix this: Will overflow */
+	u32		msgs_delivered;
+
+	size_t		size;			/* in bytes */
+	unsigned	alloc;			/* in pkts */
+	struct sk_buff *pdata[];
+};
+
+struct pgm_rxw* pgm_rxw_create(pgm_tsi *, u16, u32, unsigned, unsigned);
+void pgm_rxw_destroy(struct pgm_rxw *);
+int pgm_rxw_add(struct pgm_rxw *, struct sk_buf *, u64, u64);
+void pgm_rxw_remove_commit(struct pgm_rxw *);
+size_t pgm_rxw_readv(struct pgm_rxw *, struct kiovec *, unsigned int);
+unsigned int pgm_rxw_remove_trail (struct pgm_rxw *);
+unsigned int pgm_rxw_update(struct pgm_rxw *, u32, u32, u64, u64);
+void pgm_rxw_update_fec(struct pgm_rxw *, unsigned int);
+int pgm_rxw_confirm(struct pgm_rxw *, u32, u64, u64, u64);
+void pgm_rxw_lost(struct  pgm_rxw *, u32);
+void pgm_rxw_state(struct pgm_rxw *, struct sk_buff *, enum pgm_pkt_state);
+struct sk_buff *pgm_rxw_peek(struct pgm_rxw *, u32);
+
+static inline int pgm_rxw_max_length(struct pgm_rxw *window)
+{
+	return window->alloc;
+}
+
+static inline u32 pgm_rxw_length(struct pgm_rxw *window)
+{
+	return ( 1 + window->lead ) - window->trail;
+}
+
+static inline size_t pgm_rxw_size(struct pgm_rxw *window)
+{
+	return window->size;
+}
+
+static inline int pgm_rxw_is_empty(struct pgm_rxw *window)
+{
+	return pgm_rxw_length (window) == 0;
+}
+
+static inline int pgm_rxw_is_full(struct pgm_rxw *window)
+{
+	return pgm_rxw_length (window) == pgm_rxw_max_length (window);
+}
+
+static inline u32 pgm_rxw_lead(struct pgm_rxw *window)
+{
+	return window->lead;
+}
+
+static inline u32 pgm_rxw_next_lead(struct pgm_rxw *window)
+{
+	return pgm_rxw_lead(window) + 1;
+}
+
+/* Transmitter data structures */
+
+struct pgm_txw_state {
+	u32		unfolded_checksum;	/* first 32-bit word must be checksum */
+
+	unsigned	waiting_retransmit:1;	/* in retransmit queue */
+	unsigned	retransmit_count:15;
+	unsigned	nak_elimination_count:16;
+
+        unsigned long	expiry;			/* Advance with time */
+        unsigned long	last_retransmit;	/* NAK elimination */
+};
+
+struct pgm_txw {
+	struct pgm_tsi*		tsi;
+
+/* option: lockless atomics */
+        u32			lead;
+        u32			trail;
+
+        struct list_head	retransmit_queue;
+
+	struct rs_t		rs;
+	unsigned int		tg_sqn_shift;
+	struct sk_buff *	parity_buffer;
+	unsigned		is_fec_enabled:1;
+
+	u32			size;			/* window content size in bytes */
+	u32			alloc;			/* length of pdata[] */
+	struct sk_buff*	pdata[];
+};
+
+struct pgm_txw *pgm_txw_create(pgm_tsi *, u16, u32, unsigned int,
+			unsigned int, int, unsigned int, unsigned int);
+void pgm_txw_shutdown (struct pgm_txw *);
+void pgm_txw_add(struct pgm_txw *, struct sk_buff *);
+struct sk_buff* pgm_txw_peek(struct pgm_txw* , u32);
+int pgm_txw_retransmit_push(struct pgm_txw *, u32, int, unsigned int);
+struct sk_buff* pgm_txw_retransmit_try_peek(struct pgm_txw *);
+void pgm_txw_retransmit_remove_head(struct pgm_txw *);
+
+static inline unsigned int pgm_txw_max_length(struct pgm_txw *window)
+{
+	return window->alloc;
+}
+
+static inline u32 pgm_txw_length(struct pgm_txw *window)
+{
+	return ( 1 + window->lead ) - window->trail;
+}
+
+static inline u32 pgm_txw_size(struct pgm_txw *window)
+{
+	return window->size;
+}
+
+static inline int pgm_txw_is_empty(struct pgm_txw *window)
+{
+	return pgm_txw_length(window) == 0;
+}
+
+static inline int pgm_txw_is_full(struct pgm_txw *window)
+{
+	return pgm_txw_length(window) == pgm_txw_max_length(window);
+}
+
+static inline u32 pgm_txw_lead(struct pgm_txw *window)
+{
+	return window->lead;
+}
+
+static inline u32 pgm_txw_next_lead(struct pgm_txw *window)
+{
+	return pgm_txw_lead (window) + 1;
+}
+
+static inline u32 pgm_txw_trail(struct pgm_txw *window)
+{
+	return window->trail;
+}
+
+static inline u32 pgm_txw_get_unfolded_checksum(struct sk_buff *skb)
+{
+	struct pgm_txw_state *state = (void *)&skb->cb;
+
+	return state->unfolded_checksum;
+}
+
+static inline void pgm_txw_set_unfolded_checksum(struct sk_buff* skb, u32 csum)
+{
+	struct pgm_txw_state *state = (void *)&skb->cb;
+
+	state->unfolded_checksum = csum;
+}
+
+static inline void pgm_txw_inc_retransmit_count(struct sk_buff * skb)
+{
+	struct pgm_txw_state *state = (void *)&skb->cb;
+
+	state->retransmit_count++;
+}
+
+static inline int pgm_txw_retransmit_is_empty(struct pgm_txw *window)
+{
+	return list_empty(&window->retransmit_queue);
+}
+
+#endif /* __KERNEL__ */
+
+#endif /* _LINUX_PGM_H */
Index: linux-2.6/Documentation/networking/pgm/TODO
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/Documentation/networking/pgm/TODO	2010-03-18 13:14:59.000000000 -0500
@@ -0,0 +1,8 @@
+- Define Socket API
+- Define /proc and sys api
+- Implement base logic
+- PGM over UDP
+- FEC Forward Error correction
+- Verify interaction with Cisco and other switches
+- Verify interaction with IBM Websphere, TIBCO, openpgm etc.
+
Index: linux-2.6/Documentation/networking/pgm/references
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/Documentation/networking/pgm/references	2010-03-18 13:14:59.000000000 -0500
@@ -0,0 +1,2 @@
+RFC3208
+
Index: linux-2.6/Documentation/networking/pgm/usage
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/Documentation/networking/pgm/usage	2010-03-18 15:55:17.000000000 -0500
@@ -0,0 +1,91 @@
+1. Opening a socket
+
+	A. Native PGM
+
+		fd = socket(AF_INET, SOCK_RDM, IPPROTO_PGM)
+
+	B. PGM over UDP
+
+		fd = socket(AF_INET, SOCK_RDM, IPPROTO_UDP)
+
+	C. PGM over SHM (?)
+
+		fd = socket(AF_UNIX, SOCK_RDM, 0)
+
+
+2. Binding to a multicast address
+
+	A. Sender
+
+		Connect the socket to a MC address and port using connect().
+
+		Note that the port is significant since multiple streams on different
+		ports can be run over the same MC addr.
+
+	B. Receiver
+
+		I. Bind the socket to the MC address and port of interest.
+
+		II. Listen to the socket.
+
+			Process will wait until a PGM packet destined to the port of interest
+			is received.
+
+		III. Accept a connection.
+
+			Establishes a session. Data can then be received.
+
+
+3. Sending and receiving
+
+	Use the usual socket read and write operations and the various flavors of waiting
+	for a packet via select, poll, epoll etc.
+
+	Packet sizes are determined by the number of  packets in a single sendmsg() unless
+	overridden by the RM_SET_MESSAGE_BOUNDARY socket option.
+
+	The sender will block when the send window is full unless a non blocking write is performed.
+
+	The receiver shows the usual wait semantics. If the stream is set to unreliable then
+	packets may arrive in random order. If the set is set to RM_LISTEN_ONLY then packets may
+	just be missing.
+
+4. 	Transmitter Socket Options
+
+
+	A. Setting the window size / rate.
+
+		struct pgm_send_window x;
+		x.RateKbitsPerSec = 56;
+		x.WindowSizeInMsecs = 60000;
+		x.WindowSizeinBytes = 10000000;
+
+		setsockopt(fd, SOCK_RDM, RM_RATE_WINDOW_SIZE, &x, sizeof(x));
+
+		Default is sending at 56Kbps with a buffer of 10 Megabytes and buffering for a minute.
+
+	B. FEC mode
+
+		struct pgm_fec_info x;
+
+		x.FECBlocksize = 255;
+		x.FECProActivePackets = 0;
+		x.FECGroupSize = 0;
+		x.fFECOnDemandParityEnabled = 1;
+
+		setsockopt(fd, SOCK_RDM, RM_FEC_MODE, &x, sizeof(x));
+
+
+5.	Receiver Socket Options
+
+	None?
+
+
+Possible Extensions
+
+	RM_UNORDERED	accept unordered packet avoiding delays when packets arrive out of sequence.
+			packet is still NAKed.
+
+	RM_RECEIVE_ONLY	Simply ignore missed packets. Do not send any replies.
+
+
Index: linux-2.6/net/ipv4/pgm.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/net/ipv4/pgm.c	2010-03-18 16:37:17.000000000 -0500
@@ -0,0 +1,143 @@
+/*
+ *  PGM		An implementation of the PGM (Pragmatic General Multicast)
+ *              protocol (RFC 3208).
+ *
+ *  Authors:    Christoph Lameter      <cl@linux-foundation.org>
+ *
+ *  Changes:
+ *  Fixes:
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ */
+#include "udp_impl.h"
+
+struct udp_table 	pgm_table __read_mostly;
+EXPORT_SYMBOL(pgm_table);
+
+static int pgm_rcv(struct sk_buff *skb)
+{
+	/* TBD */
+	return __udp4_lib_rcv(skb, &pgm_table, IPPROTO_UDPLITE);
+}
+
+static void pgm_err(struct sk_buff *skb, u32 info)
+{
+	__udp4_lib_err(skb, info, &pgm_table);
+}
+
+static const struct net_protocol pgm_protocol = {
+	.handler	= pgm_rcv,
+	.err_handler	= pgm_err,
+	.no_policy	= 1,
+	.netns_ok	= 1,
+};
+
+struct proto 	pgm_prot = {
+	.name		   = "PGM",
+	.owner		   = THIS_MODULE,
+	.close		   = udp_lib_close,
+	.connect	   = ip4_datagram_connect,
+	.disconnect	   = udp_disconnect,
+	.ioctl		   = udp_ioctl,
+	.init		   = pgm_sk_init,
+	.destroy	   = udp_destroy_sock,
+	.setsockopt	   = pgm_setsockopt,
+	.getsockopt	   = pgm_getsockopt,
+	.sendmsg	   = pgm_sendmsg,
+	.recvmsg	   = pgm_recvmsg,
+	.sendpage	   = pgm_sendpage,
+	.backlog_rcv	   = udp_queue_rcv_skb,
+	.hash		   = udp_lib_hash,
+	.unhash		   = udp_lib_unhash,
+	.get_port	   = udp_v4_get_port,
+	.obj_size	   = sizeof(struct udp_sock),
+	.slab_flags	   = SLAB_DESTROY_BY_RCU,
+	.h.udp_table	   = &pgm_table,
+#ifdef CONFIG_COMPAT
+	.compat_setsockopt = compat_pgm_setsockopt,
+	.compat_getsockopt = compat_pgm_getsockopt,
+#endif
+};
+
+static struct inet_protosw pgm_ip_protosw = {
+	.type		=  SOCK_RDM,
+	.protocol	=  IPPROTO_PGM,
+	.prot		=  &pgm_ip_prot,
+	.ops		=  &inet_pgm_ops,
+	.no_check	=  0,		/* must checksum (RFC 3828) */
+	.flags		=  INET_PROTOSW_PERMANENT,
+};
+
+static struct inet_protosw pgm_udp_protosw = {
+	.type		=  SOCK_RDM,
+	.protocol	=  IPPROTO_UDP,
+	.prot		=  &pgm_udp_prot,
+	.ops		=  &inet_pgm_ops,
+	.no_check	=  0,		/* must checksum (RFC 3828) */
+	.flags		=  INET_PROTOSW_PERMANENT,
+};
+
+#ifdef CONFIG_PROC_FS
+static struct udp_seq_afinfo pgm_seq_afinfo = {
+	.name		= "pgm",
+	.family		= AF_INET,
+	.udp_table 	= &pgm_table,
+	.seq_fops	= {
+		.owner	=	THIS_MODULE,
+	},
+	.seq_ops	= {
+		.show		= udp4_seq_show,
+	},
+};
+
+static int __net_init pgm_proc_init_net(struct net *net)
+{
+	return udp_proc_register(net, &pgm_seq_afinfo);
+}
+
+static void __net_exit pgm_proc_exit_net(struct net *net)
+{
+	udp_proc_unregister(net, &pgm_seq_afinfo);
+}
+
+static struct pernet_operations pgm4_net_ops = {
+	.init = pgm_proc_init_net,
+	.exit = pgm_proc_exit_net,
+};
+
+static __init int pgm_proc_init(void)
+{
+	return register_pernet_subsys(&pgm_net_ops);
+}
+#else
+static inline int pgm_proc_init(void)
+{
+	return 0;
+}
+#endif
+
+void __init pgm_register(void)
+{
+	udp_table_init(&pgm_table, "PGM");
+	if (proto_register(&pgm_prot, 1))
+		goto out_register_err;
+
+	if (inet_add_protocol(&pgm_protocol, IPPROTO_PGM) < 0)
+		goto out_unregister_proto;
+
+	inet_register_protosw(&pgm_ip_protosw);
+	inet_register_protosw(&pgm_udp_protosw);
+
+	if (pgm_proc_init())
+		printk(KERN_ERR "%s: Cannot register /proc!\n", __func__);
+	return;
+
+out_unregister_proto:
+	proto_unregister(&pgm_prot);
+out_register_err:
+	printk(KERN_CRIT "%s: Cannot add PGM protocol.\n", __func__);
+}
+
+EXPORT_SYMBOL(pgm_prot);
Index: linux-2.6/net/ipv4/Kconfig
===================================================================
--- linux-2.6.orig/net/ipv4/Kconfig	2010-03-18 16:16:34.000000000 -0500
+++ linux-2.6/net/ipv4/Kconfig	2010-03-18 16:39:36.000000000 -0500
@@ -14,6 +14,20 @@ config IP_MULTICAST
 	  <file:Documentation/networking/multicast.txt>. For most people, it's
 	  safe to say N.

+config IP_PGM
+	bool "IP: Pragmatic General Multicast (RFC3208) support"
+	depends on IP_MULTICAST && EXPERIMENTAL
+	help
+	   This is an implementation of reliable multicasting following
+	   RFC3208. PGM is used for publisher-subscriber based information
+	   services on private networks. The PGM protocol allows for recovery
+	   of lost packets through resent requests (NAKs) and through the
+	   recovery of missing packets via FEC. PGM is supported by router
+	   vendors through logic that allows correlation of NAKs to avoid
+	   flooding the network with NAK (aka NAK-storm). PGM is widely used
+	   in the financial industry and various commercial applications
+	   support this protocol.
+
 config IP_ADVANCED_ROUTER
 	bool "IP: advanced router"
 	---help---
Index: linux-2.6/net/ipv4/Makefile
===================================================================
--- linux-2.6.orig/net/ipv4/Makefile	2010-03-18 16:16:07.000000000 -0500
+++ linux-2.6/net/ipv4/Makefile	2010-03-18 16:24:04.000000000 -0500
@@ -52,3 +52,6 @@ obj-$(CONFIG_NETLABEL) += cipso_ipv4.o

 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o
+
+obj-$(CONFIG_IP_PGM)	+= pgm.o
+
