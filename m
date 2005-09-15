From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH 3/3] NETFILTER: New PPTP helper
Date: Thu, 15 Sep 2005 16:54:06 +0200
Message-ID: <20050915145406.GC17121@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YD3LsXFS42OYHhNZ"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--YD3LsXFS42OYHhNZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave, please push this to mainline.  Thanks!


NETFILTER: Add new PPTP conntrack and NAT helper

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
diff --git a/include/linux/netfilter_ipv4/ip_conntrack.h b/include/linux/ne=
tfilter_ipv4/ip_conntrack.h
--- a/include/linux/netfilter_ipv4/ip_conntrack.h
+++ b/include/linux/netfilter_ipv4/ip_conntrack.h
@@ -133,11 +133,13 @@ enum ip_conntrack_expect_events {
=20
 #include <linux/netfilter_ipv4/ip_conntrack_tcp.h>
 #include <linux/netfilter_ipv4/ip_conntrack_icmp.h>
+#include <linux/netfilter_ipv4/ip_conntrack_proto_gre.h>
 #include <linux/netfilter_ipv4/ip_conntrack_sctp.h>
=20
 /* per conntrack: protocol private data */
 union ip_conntrack_proto {
 	/* insert conntrack proto private data here */
+	struct ip_ct_gre gre;
 	struct ip_ct_sctp sctp;
 	struct ip_ct_tcp tcp;
 	struct ip_ct_icmp icmp;
@@ -148,6 +150,7 @@ union ip_conntrack_expect_proto {
 };
=20
 /* Add protocol helper include file here */
+#include <linux/netfilter_ipv4/ip_conntrack_pptp.h>
 #include <linux/netfilter_ipv4/ip_conntrack_amanda.h>
 #include <linux/netfilter_ipv4/ip_conntrack_ftp.h>
 #include <linux/netfilter_ipv4/ip_conntrack_irc.h>
@@ -155,12 +158,20 @@ union ip_conntrack_expect_proto {
 /* per conntrack: application helper private data */
 union ip_conntrack_help {
 	/* insert conntrack helper private data (master) here */
+	struct ip_ct_pptp_master ct_pptp_info;
 	struct ip_ct_ftp_master ct_ftp_info;
 	struct ip_ct_irc_master ct_irc_info;
 };
=20
 #ifdef CONFIG_IP_NF_NAT_NEEDED
 #include <linux/netfilter_ipv4/ip_nat.h>
+#include <linux/netfilter_ipv4/ip_nat_pptp.h>
+
+/* per conntrack: nat application helper private data */
+union ip_conntrack_nat_help {
+	/* insert nat helper private data here */
+	struct ip_nat_pptp nat_pptp_info;
+};
 #endif
=20
 #include <linux/types.h>
@@ -223,6 +234,7 @@ struct ip_conntrack
 #ifdef CONFIG_IP_NF_NAT_NEEDED
 	struct {
 		struct ip_nat_info info;
+		union ip_conntrack_nat_help help;
 #if defined(CONFIG_IP_NF_TARGET_MASQUERADE) || \
 	defined(CONFIG_IP_NF_TARGET_MASQUERADE_MODULE)
 		int masq_index;
diff --git a/include/linux/netfilter_ipv4/ip_conntrack_pptp.h b/include/lin=
ux/netfilter_ipv4/ip_conntrack_pptp.h
new file mode 100644
--- /dev/null
+++ b/include/linux/netfilter_ipv4/ip_conntrack_pptp.h
@@ -0,0 +1,332 @@
+/* PPTP constants and structs */
+#ifndef _CONNTRACK_PPTP_H
+#define _CONNTRACK_PPTP_H
+
+/* state of the control session */
+enum pptp_ctrlsess_state {
+	PPTP_SESSION_NONE,			/* no session present */
+	PPTP_SESSION_ERROR,			/* some session error */
+	PPTP_SESSION_STOPREQ,			/* stop_sess request seen */
+	PPTP_SESSION_REQUESTED,			/* start_sess request seen */
+	PPTP_SESSION_CONFIRMED,			/* session established */
+};
+
+/* state of the call inside the control session */
+enum pptp_ctrlcall_state {
+	PPTP_CALL_NONE,
+	PPTP_CALL_ERROR,
+	PPTP_CALL_OUT_REQ,
+	PPTP_CALL_OUT_CONF,
+	PPTP_CALL_IN_REQ,
+	PPTP_CALL_IN_REP,
+	PPTP_CALL_IN_CONF,
+	PPTP_CALL_CLEAR_REQ,
+};
+
+
+/* conntrack private data */
+struct ip_ct_pptp_master {
+	enum pptp_ctrlsess_state sstate;	/* session state */
+
+	/* everything below is going to be per-expectation in newnat,
+	 * since there could be more than one call within one session */
+	enum pptp_ctrlcall_state cstate;	/* call state */
+	u_int16_t pac_call_id;			/* call id of PAC, host byte order */
+	u_int16_t pns_call_id;			/* call id of PNS, host byte order */
+
+	/* in pre-2.6.11 this used to be per-expect. Now it is per-conntrack
+	 * and therefore imposes a fixed limit on the number of maps */
+	struct ip_ct_gre_keymap *keymap_orig, *keymap_reply;
+};
+
+/* conntrack_expect private member */
+struct ip_ct_pptp_expect {
+	enum pptp_ctrlcall_state cstate; 	/* call state */
+	u_int16_t pac_call_id;			/* call id of PAC */
+	u_int16_t pns_call_id;			/* call id of PNS */
+};
+
+
+#ifdef __KERNEL__
+
+#define IP_CONNTR_PPTP		PPTP_CONTROL_PORT
+
+#define PPTP_CONTROL_PORT	1723
+
+#define PPTP_PACKET_CONTROL	1
+#define PPTP_PACKET_MGMT	2
+
+#define PPTP_MAGIC_COOKIE	0x1a2b3c4d
+
+struct pptp_pkt_hdr {
+	__u16	packetLength;
+	__u16	packetType;
+	__u32	magicCookie;
+};
+
+/* PptpControlMessageType values */
+#define PPTP_START_SESSION_REQUEST	1
+#define PPTP_START_SESSION_REPLY	2
+#define PPTP_STOP_SESSION_REQUEST	3
+#define PPTP_STOP_SESSION_REPLY		4
+#define PPTP_ECHO_REQUEST		5
+#define PPTP_ECHO_REPLY			6
+#define PPTP_OUT_CALL_REQUEST		7
+#define PPTP_OUT_CALL_REPLY		8
+#define PPTP_IN_CALL_REQUEST		9
+#define PPTP_IN_CALL_REPLY		10
+#define PPTP_IN_CALL_CONNECT		11
+#define PPTP_CALL_CLEAR_REQUEST		12
+#define PPTP_CALL_DISCONNECT_NOTIFY	13
+#define PPTP_WAN_ERROR_NOTIFY		14
+#define PPTP_SET_LINK_INFO		15
+
+#define PPTP_MSG_MAX			15
+
+/* PptpGeneralError values */
+#define PPTP_ERROR_CODE_NONE		0
+#define PPTP_NOT_CONNECTED		1
+#define PPTP_BAD_FORMAT			2
+#define PPTP_BAD_VALUE			3
+#define PPTP_NO_RESOURCE		4
+#define PPTP_BAD_CALLID			5
+#define PPTP_REMOVE_DEVICE_ERROR	6
+
+struct PptpControlHeader {
+	__u16	messageType;
+	__u16	reserved;
+};
+
+/* FramingCapability Bitmap Values */
+#define PPTP_FRAME_CAP_ASYNC		0x1
+#define PPTP_FRAME_CAP_SYNC		0x2
+
+/* BearerCapability Bitmap Values */
+#define PPTP_BEARER_CAP_ANALOG		0x1
+#define PPTP_BEARER_CAP_DIGITAL		0x2
+
+struct PptpStartSessionRequest {
+	__u16	protocolVersion;
+	__u8	reserved1;
+	__u8	reserved2;
+	__u32	framingCapability;
+	__u32	bearerCapability;
+	__u16	maxChannels;
+	__u16	firmwareRevision;
+	__u8	hostName[64];
+	__u8	vendorString[64];
+};
+
+/* PptpStartSessionResultCode Values */
+#define PPTP_START_OK			1
+#define PPTP_START_GENERAL_ERROR	2
+#define PPTP_START_ALREADY_CONNECTED	3
+#define PPTP_START_NOT_AUTHORIZED	4
+#define PPTP_START_UNKNOWN_PROTOCOL	5
+
+struct PptpStartSessionReply {
+	__u16	protocolVersion;
+	__u8	resultCode;
+	__u8	generalErrorCode;
+	__u32	framingCapability;
+	__u32	bearerCapability;
+	__u16	maxChannels;
+	__u16	firmwareRevision;
+	__u8	hostName[64];
+	__u8	vendorString[64];
+};
+
+/* PptpStopReasons */
+#define PPTP_STOP_NONE			1
+#define PPTP_STOP_PROTOCOL		2
+#define PPTP_STOP_LOCAL_SHUTDOWN	3
+
+struct PptpStopSessionRequest {
+	__u8	reason;
+};
+
+/* PptpStopSessionResultCode */
+#define PPTP_STOP_OK			1
+#define PPTP_STOP_GENERAL_ERROR		2
+
+struct PptpStopSessionReply {
+	__u8	resultCode;
+	__u8	generalErrorCode;
+};
+
+struct PptpEchoRequest {
+	__u32 identNumber;
+};
+
+/* PptpEchoReplyResultCode */
+#define PPTP_ECHO_OK			1
+#define PPTP_ECHO_GENERAL_ERROR		2
+
+struct PptpEchoReply {
+	__u32	identNumber;
+	__u8	resultCode;
+	__u8	generalErrorCode;
+	__u16	reserved;
+};
+
+/* PptpFramingType */
+#define PPTP_ASYNC_FRAMING		1
+#define PPTP_SYNC_FRAMING		2
+#define PPTP_DONT_CARE_FRAMING		3
+
+/* PptpCallBearerType */
+#define PPTP_ANALOG_TYPE		1
+#define PPTP_DIGITAL_TYPE		2
+#define PPTP_DONT_CARE_BEARER_TYPE	3
+
+struct PptpOutCallRequest {
+	__u16	callID;
+	__u16	callSerialNumber;
+	__u32	minBPS;
+	__u32	maxBPS;
+	__u32	bearerType;
+	__u32	framingType;
+	__u16	packetWindow;
+	__u16	packetProcDelay;
+	__u16	reserved1;
+	__u16	phoneNumberLength;
+	__u16	reserved2;
+	__u8	phoneNumber[64];
+	__u8	subAddress[64];
+};
+
+/* PptpCallResultCode */
+#define PPTP_OUTCALL_CONNECT		1
+#define PPTP_OUTCALL_GENERAL_ERROR	2
+#define PPTP_OUTCALL_NO_CARRIER		3
+#define PPTP_OUTCALL_BUSY		4
+#define PPTP_OUTCALL_NO_DIAL_TONE	5
+#define PPTP_OUTCALL_TIMEOUT		6
+#define PPTP_OUTCALL_DONT_ACCEPT	7
+
+struct PptpOutCallReply {
+	__u16	callID;
+	__u16	peersCallID;
+	__u8	resultCode;
+	__u8	generalErrorCode;
+	__u16	causeCode;
+	__u32	connectSpeed;
+	__u16	packetWindow;
+	__u16	packetProcDelay;
+	__u32	physChannelID;
+};
+
+struct PptpInCallRequest {
+	__u16	callID;
+	__u16	callSerialNumber;
+	__u32	callBearerType;
+	__u32	physChannelID;
+	__u16	dialedNumberLength;
+	__u16	dialingNumberLength;
+	__u8	dialedNumber[64];
+	__u8	dialingNumber[64];
+	__u8	subAddress[64];
+};
+
+/* PptpInCallResultCode */
+#define PPTP_INCALL_ACCEPT		1
+#define PPTP_INCALL_GENERAL_ERROR	2
+#define PPTP_INCALL_DONT_ACCEPT		3
+
+struct PptpInCallReply {
+	__u16	callID;
+	__u16	peersCallID;
+	__u8	resultCode;
+	__u8	generalErrorCode;
+	__u16	packetWindow;
+	__u16	packetProcDelay;
+	__u16	reserved;
+};
+
+struct PptpInCallConnected {
+	__u16	peersCallID;
+	__u16	reserved;
+	__u32	connectSpeed;
+	__u16	packetWindow;
+	__u16	packetProcDelay;
+	__u32	callFramingType;
+};
+
+struct PptpClearCallRequest {
+	__u16	callID;
+	__u16	reserved;
+};
+
+struct PptpCallDisconnectNotify {
+	__u16	callID;
+	__u8	resultCode;
+	__u8	generalErrorCode;
+	__u16	causeCode;
+	__u16	reserved;
+	__u8	callStatistics[128];
+};
+
+struct PptpWanErrorNotify {
+	__u16	peersCallID;
+	__u16	reserved;
+	__u32	crcErrors;
+	__u32	framingErrors;
+	__u32	hardwareOverRuns;
+	__u32	bufferOverRuns;
+	__u32	timeoutErrors;
+	__u32	alignmentErrors;
+};
+
+struct PptpSetLinkInfo {
+	__u16	peersCallID;
+	__u16	reserved;
+	__u32	sendAccm;
+	__u32	recvAccm;
+};
+
+
+struct pptp_priv_data {
+	__u16	call_id;
+	__u16	mcall_id;
+	__u16	pcall_id;
+};
+
+union pptp_ctrl_union {
+		struct PptpStartSessionRequest	sreq;
+		struct PptpStartSessionReply	srep;
+		struct PptpStopSessionRequest	streq;
+		struct PptpStopSessionReply	strep;
+                struct PptpOutCallRequest       ocreq;
+                struct PptpOutCallReply         ocack;
+                struct PptpInCallRequest        icreq;
+                struct PptpInCallReply          icack;
+                struct PptpInCallConnected      iccon;
+		struct PptpClearCallRequest	clrreq;
+                struct PptpCallDisconnectNotify disc;
+                struct PptpWanErrorNotify       wanerr;
+                struct PptpSetLinkInfo          setlink;
+};
+
+extern int
+(*ip_nat_pptp_hook_outbound)(struct sk_buff **pskb,
+			  struct ip_conntrack *ct,
+			  enum ip_conntrack_info ctinfo,
+			  struct PptpControlHeader *ctlh,
+			  union pptp_ctrl_union *pptpReq);
+
+extern int
+(*ip_nat_pptp_hook_inbound)(struct sk_buff **pskb,
+			  struct ip_conntrack *ct,
+			  enum ip_conntrack_info ctinfo,
+			  struct PptpControlHeader *ctlh,
+			  union pptp_ctrl_union *pptpReq);
+
+extern int
+(*ip_nat_pptp_hook_exp_gre)(struct ip_conntrack_expect *exp_orig,
+			    struct ip_conntrack_expect *exp_reply);
+
+extern void
+(*ip_nat_pptp_hook_expectfn)(struct ip_conntrack *ct,
+			     struct ip_conntrack_expect *exp);
+#endif /* __KERNEL__ */
+#endif /* _CONNTRACK_PPTP_H */
diff --git a/include/linux/netfilter_ipv4/ip_conntrack_proto_gre.h b/includ=
e/linux/netfilter_ipv4/ip_conntrack_proto_gre.h
new file mode 100644
--- /dev/null
+++ b/include/linux/netfilter_ipv4/ip_conntrack_proto_gre.h
@@ -0,0 +1,114 @@
+#ifndef _CONNTRACK_PROTO_GRE_H
+#define _CONNTRACK_PROTO_GRE_H
+#include <asm/byteorder.h>
+
+/* GRE PROTOCOL HEADER */
+
+/* GRE Version field */
+#define GRE_VERSION_1701	0x0
+#define GRE_VERSION_PPTP	0x1
+
+/* GRE Protocol field */
+#define GRE_PROTOCOL_PPTP	0x880B
+
+/* GRE Flags */
+#define GRE_FLAG_C		0x80
+#define GRE_FLAG_R		0x40
+#define GRE_FLAG_K		0x20
+#define GRE_FLAG_S		0x10
+#define GRE_FLAG_A		0x80
+
+#define GRE_IS_C(f)	((f)&GRE_FLAG_C)
+#define GRE_IS_R(f)	((f)&GRE_FLAG_R)
+#define GRE_IS_K(f)	((f)&GRE_FLAG_K)
+#define GRE_IS_S(f)	((f)&GRE_FLAG_S)
+#define GRE_IS_A(f)	((f)&GRE_FLAG_A)
+
+/* GRE is a mess: Four different standards */
+struct gre_hdr {
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+	__u16	rec:3,
+		srr:1,
+		seq:1,
+		key:1,
+		routing:1,
+		csum:1,
+		version:3,
+		reserved:4,
+		ack:1;
+#elif defined(__BIG_ENDIAN_BITFIELD)
+	__u16	csum:1,
+		routing:1,
+		key:1,
+		seq:1,
+		srr:1,
+		rec:3,
+		ack:1,
+		reserved:4,
+		version:3;
+#else
+#error "Adjust your <asm/byteorder.h> defines"
+#endif
+	__u16	protocol;
+};
+
+/* modified GRE header for PPTP */
+struct gre_hdr_pptp {
+	__u8  flags;		/* bitfield */
+	__u8  version;		/* should be GRE_VERSION_PPTP */
+	__u16 protocol;		/* should be GRE_PROTOCOL_PPTP */
+	__u16 payload_len;	/* size of ppp payload, not inc. gre header */
+	__u16 call_id;		/* peer's call_id for this session */
+	__u32 seq;		/* sequence number.  Present if S=3D=3D1 */
+	__u32 ack;		/* seq number of highest packet recieved by */
+				/*  sender in this session */
+};
+
+
+/* this is part of ip_conntrack */
+struct ip_ct_gre {
+	unsigned int stream_timeout;
+	unsigned int timeout;
+};
+
+#ifdef __KERNEL__
+struct ip_conntrack_expect;
+struct ip_conntrack;
+
+/* structure for original <-> reply keymap */
+struct ip_ct_gre_keymap {
+	struct list_head list;
+
+	struct ip_conntrack_tuple tuple;
+};
+
+/* add new tuple->key_reply pair to keymap */
+int ip_ct_gre_keymap_add(struct ip_conntrack *ct,
+			 struct ip_conntrack_tuple *t,
+			 int reply);
+
+/* delete keymap entries */
+void ip_ct_gre_keymap_destroy(struct ip_conntrack *ct);
+
+
+/* get pointer to gre key, if present */
+static inline u_int32_t *gre_key(struct gre_hdr *greh)
+{
+	if (!greh->key)
+		return NULL;
+	if (greh->csum || greh->routing)
+		return (u_int32_t *) (greh+sizeof(*greh)+4);
+	return (u_int32_t *) (greh+sizeof(*greh));
+}
+
+/* get pointer ot gre csum, if present */
+static inline u_int16_t *gre_csum(struct gre_hdr *greh)
+{
+	if (!greh->csum)
+		return NULL;
+	return (u_int16_t *) (greh+sizeof(*greh));
+}
+
+#endif /* __KERNEL__ */
+
+#endif /* _CONNTRACK_PROTO_GRE_H */
diff --git a/include/linux/netfilter_ipv4/ip_conntrack_tuple.h b/include/li=
nux/netfilter_ipv4/ip_conntrack_tuple.h
--- a/include/linux/netfilter_ipv4/ip_conntrack_tuple.h
+++ b/include/linux/netfilter_ipv4/ip_conntrack_tuple.h
@@ -28,6 +28,9 @@ union ip_conntrack_manip_proto
 	struct {
 		u_int16_t port;
 	} sctp;
+	struct {
+		u_int16_t key;	/* key is 32bit, pptp only uses 16 */
+	} gre;
 };
=20
 /* The manipulable part of the tuple. */
@@ -61,6 +64,10 @@ struct ip_conntrack_tuple
 			struct {
 				u_int16_t port;
 			} sctp;
+			struct {
+				u_int16_t key;	/* key is 32bit,=20
+						 * pptp only uses 16 */
+			} gre;
 		} u;
=20
 		/* The protocol. */
diff --git a/include/linux/netfilter_ipv4/ip_nat_pptp.h b/include/linux/net=
filter_ipv4/ip_nat_pptp.h
new file mode 100644
--- /dev/null
+++ b/include/linux/netfilter_ipv4/ip_nat_pptp.h
@@ -0,0 +1,11 @@
+/* PPTP constants and structs */
+#ifndef _NAT_PPTP_H
+#define _NAT_PPTP_H
+
+/* conntrack private data */
+struct ip_nat_pptp {
+	u_int16_t pns_call_id;		/* NAT'ed PNS call id */
+	u_int16_t pac_call_id;		/* NAT'ed PAC call id */
+};
+
+#endif /* _NAT_PPTP_H */
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -129,6 +129,22 @@ config IP_NF_AMANDA
=20
 	  To compile it as a module, choose M here.  If unsure, say Y.
=20
+config IP_NF_PPTP
+	tristate  'PPTP protocol support'
+	help
+	  This module adds support for PPTP (Point to Point Tunnelling
+	  Protocol, RFC2637) conncection tracking and NAT.=20
+=09
+	  If you are running PPTP sessions over a stateful firewall or NAT
+	  box, you may want to enable this feature. =20
+=09
+	  Please note that not all PPTP modes of operation are supported yet.
+	  For more info, read top of the file
+	  net/ipv4/netfilter/ip_conntrack_pptp.c
+=09
+	  If you want to compile it as a module, say M here and read
+	  Documentation/modules.txt.  If unsure, say `N'.
+
 config IP_NF_QUEUE
 	tristate "IP Userspace queueing via NETLINK (OBSOLETE)"
 	help
@@ -613,6 +629,12 @@ config IP_NF_NAT_AMANDA
 	default IP_NF_NAT if IP_NF_AMANDA=3Dy
 	default m if IP_NF_AMANDA=3Dm
=20
+config IP_NF_NAT_PPTP
+	tristate
+	depends on IP_NF_NAT!=3Dn && IP_NF_PPTP!=3Dn
+	default IP_NF_NAT if IP_NF_PPTP=3Dy
+	default m if IP_NF_PPTP=3Dm
+
 # mangle + specific targets
 config IP_NF_MANGLE
 	tristate "Packet mangling"
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -6,6 +6,9 @@
 ip_conntrack-objs	:=3D ip_conntrack_standalone.o ip_conntrack_core.o ip_co=
nntrack_proto_generic.o ip_conntrack_proto_tcp.o ip_conntrack_proto_udp.o i=
p_conntrack_proto_icmp.o
 iptable_nat-objs	:=3D ip_nat_standalone.o ip_nat_rule.o ip_nat_core.o ip_n=
at_helper.o ip_nat_proto_unknown.o ip_nat_proto_tcp.o ip_nat_proto_udp.o ip=
_nat_proto_icmp.o
=20
+ip_conntrack_pptp-objs	:=3D ip_conntrack_helper_pptp.o ip_conntrack_proto_=
gre.o
+ip_nat_pptp-objs	:=3D ip_nat_helper_pptp.o ip_nat_proto_gre.o
+
 # connection tracking
 obj-$(CONFIG_IP_NF_CONNTRACK) +=3D ip_conntrack.o
=20
@@ -17,6 +20,7 @@ obj-$(CONFIG_IP_NF_CONNTRACK_NETLINK) +=3D
 obj-$(CONFIG_IP_NF_CT_PROTO_SCTP) +=3D ip_conntrack_proto_sctp.o
=20
 # connection tracking helpers
+obj-$(CONFIG_IP_NF_PPTP) +=3D ip_conntrack_pptp.o
 obj-$(CONFIG_IP_NF_AMANDA) +=3D ip_conntrack_amanda.o
 obj-$(CONFIG_IP_NF_TFTP) +=3D ip_conntrack_tftp.o
 obj-$(CONFIG_IP_NF_FTP) +=3D ip_conntrack_ftp.o
@@ -24,6 +28,7 @@ obj-$(CONFIG_IP_NF_IRC) +=3D ip_conntrack_
 obj-$(CONFIG_IP_NF_NETBIOS_NS) +=3D ip_conntrack_netbios_ns.o
=20
 # NAT helpers=20
+obj-$(CONFIG_IP_NF_NAT_PPTP) +=3D ip_nat_pptp.o
 obj-$(CONFIG_IP_NF_NAT_AMANDA) +=3D ip_nat_amanda.o
 obj-$(CONFIG_IP_NF_NAT_TFTP) +=3D ip_nat_tftp.o
 obj-$(CONFIG_IP_NF_NAT_FTP) +=3D ip_nat_ftp.o
diff --git a/net/ipv4/netfilter/ip_conntrack_helper_pptp.c b/net/ipv4/netfi=
lter/ip_conntrack_helper_pptp.c
new file mode 100644
--- /dev/null
+++ b/net/ipv4/netfilter/ip_conntrack_helper_pptp.c
@@ -0,0 +1,801 @@
+/*
+ * ip_conntrack_pptp.c	- Version 3.0
+ *
+ * Connection tracking support for PPTP (Point to Point Tunneling Protocol=
).
+ * PPTP is a a protocol for creating virtual private networks.
+ * It is a specification defined by Microsoft and some vendors
+ * working with Microsoft.  PPTP is built on top of a modified
+ * version of the Internet Generic Routing Encapsulation Protocol.
+ * GRE is defined in RFC 1701 and RFC 1702.  Documentation of
+ * PPTP can be found in RFC 2637
+ *
+ * (C) 2000-2005 by Harald Welte <laforge@gnumonks.org>
+ *
+ * Development of this code funded by Astaro AG (http://www.astaro.com/)
+ *
+ * Limitations:
+ * 	 - We blindly assume that control connections are always
+ * 	   established in PNS->PAC direction.  This is a violation
+ * 	   of RFFC2673
+ * 	 - We can only support one single call within each session
+ *
+ * TODO:
+ *	 - testing of incoming PPTP calls=20
+ *
+ * Changes:=20
+ * 	2002-02-05 - Version 1.3
+ * 	  - Call ip_conntrack_unexpect_related() from=20
+ * 	    pptp_timeout_related() to destroy expectations in case
+ * 	    CALL_DISCONNECT_NOTIFY or tcp fin packet was seen
+ * 	    (Philip Craig <philipc@snapgear.com>)
+ * 	  - Add Version information at module loadtime
+ * 	2002-02-10 - Version 1.6
+ * 	  - move to C99 style initializers
+ * 	  - remove second expectation if first arrives
+ * 	2004-10-22 - Version 2.0
+ * 	  - merge Mandrake's 2.6.x port with recent 2.6.x API changes
+ * 	  - fix lots of linear skb assumptions from Mandrake's port
+ * 	2005-06-10 - Version 2.1
+ * 	  - use ip_conntrack_expect_free() instead of kfree() on the
+ * 	    expect's (which are from the slab for quite some time)
+ * 	2005-06-10 - Version 3.0
+ * 	  - port helper to post-2.6.11 API changes,
+ * 	    funded by Oxcoda NetBox Blue (http://www.netboxblue.com/)
+ * 	2005-07-30 - Version 3.1
+ * 	  - port helper to 2.6.13 API changes
+ *
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/netfilter.h>
+#include <linux/ip.h>
+#include <net/checksum.h>
+#include <net/tcp.h>
+
+#include <linux/netfilter_ipv4/ip_conntrack.h>
+#include <linux/netfilter_ipv4/ip_conntrack_core.h>
+#include <linux/netfilter_ipv4/ip_conntrack_helper.h>
+#include <linux/netfilter_ipv4/ip_conntrack_proto_gre.h>
+#include <linux/netfilter_ipv4/ip_conntrack_pptp.h>
+
+#define IP_CT_PPTP_VERSION "3.1"
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Harald Welte <laforge@gnumonks.org>");
+MODULE_DESCRIPTION("Netfilter connection tracking helper module for PPTP");
+
+static DEFINE_SPINLOCK(ip_pptp_lock);
+
+int
+(*ip_nat_pptp_hook_outbound)(struct sk_buff **pskb,
+			  struct ip_conntrack *ct,
+			  enum ip_conntrack_info ctinfo,
+			  struct PptpControlHeader *ctlh,
+			  union pptp_ctrl_union *pptpReq);
+
+int
+(*ip_nat_pptp_hook_inbound)(struct sk_buff **pskb,
+			  struct ip_conntrack *ct,
+			  enum ip_conntrack_info ctinfo,
+			  struct PptpControlHeader *ctlh,
+			  union pptp_ctrl_union *pptpReq);
+
+int
+(*ip_nat_pptp_hook_exp_gre)(struct ip_conntrack_expect *expect_orig,
+			    struct ip_conntrack_expect *expect_reply);
+
+void
+(*ip_nat_pptp_hook_expectfn)(struct ip_conntrack *ct,
+			     struct ip_conntrack_expect *exp);
+
+#if 0
+#include "ip_conntrack_pptp_priv.h"
+#define DEBUGP(format, args...)	printk(KERN_DEBUG "%s:%s: " format, __FILE=
__, __FUNCTION__, ## args)
+#else
+#define DEBUGP(format, args...)
+#endif
+
+#define SECS *HZ
+#define MINS * 60 SECS
+#define HOURS * 60 MINS
+
+#define PPTP_GRE_TIMEOUT 		(10 MINS)
+#define PPTP_GRE_STREAM_TIMEOUT 	(5 HOURS)
+
+static void pptp_expectfn(struct ip_conntrack *ct,
+			 struct ip_conntrack_expect *exp)
+{
+	DEBUGP("increasing timeouts\n");
+
+	/* increase timeout of GRE data channel conntrack entry */
+	ct->proto.gre.timeout =3D PPTP_GRE_TIMEOUT;
+	ct->proto.gre.stream_timeout =3D PPTP_GRE_STREAM_TIMEOUT;
+
+	/* Can you see how rusty this code is, compared with the pre-2.6.11
+	 * one? That's what happened to my shiny newnat of 2002 ;( -HW */
+
+	if (!ip_nat_pptp_hook_expectfn) {
+		struct ip_conntrack_tuple inv_t;
+		struct ip_conntrack_expect *exp_other;
+
+		/* obviously this tuple inversion only works until you do NAT */
+		invert_tuplepr(&inv_t, &exp->tuple);
+		DEBUGP("trying to unexpect other dir: ");
+		DUMP_TUPLE(&inv_t);
+=09
+		exp_other =3D __ip_conntrack_expect_find(&inv_t);
+		if (exp_other) {
+			/* delete other expectation.  */
+			DEBUGP("found\n");
+			ip_conntrack_unexpect_related(exp_other);
+		} else {
+			DEBUGP("not found\n");
+		}
+	} else {
+		/* we need more than simple inversion */
+		ip_nat_pptp_hook_expectfn(ct, exp);
+	}
+}
+
+static int timeout_ct_or_exp(const struct ip_conntrack_tuple *t)
+{
+	struct ip_conntrack_tuple_hash *h;
+	struct ip_conntrack_expect *exp;
+
+	DEBUGP("trying to timeout ct or exp for tuple ");
+	DUMP_TUPLE(t);
+
+	h =3D __ip_conntrack_find(t, NULL);
+	if (h)  {
+		struct ip_conntrack *sibling =3D tuplehash_to_ctrack(h);
+		DEBUGP("setting timeout of conntrack %p to 0\n", sibling);
+		sibling->proto.gre.timeout =3D 0;
+		sibling->proto.gre.stream_timeout =3D 0;
+		/* refresh_acct will not modify counters if skb =3D=3D NULL */
+		ip_ct_refresh_acct(sibling, 0, NULL, 0);
+		return 1;
+	} else {
+		exp =3D __ip_conntrack_expect_find(t);
+		if (exp) {
+			DEBUGP("unexpect_related of expect %p\n", exp);
+			ip_conntrack_unexpect_related(exp);
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
+
+/* timeout GRE data connections */
+static int pptp_timeout_related(struct ip_conntrack *ct)
+{
+	struct ip_conntrack_tuple t;
+	int ret;
+
+	/* Since ct->sibling_list has literally rusted away in 2.6.11,=20
+	 * we now need another way to find out about our sibling
+	 * contrack and expects... -HW */
+
+	/* try original (pns->pac) tuple */
+	memcpy(&t, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple, sizeof(t));
+	t.dst.protonum =3D IPPROTO_GRE;
+	t.src.u.gre.key =3D htons(ct->help.ct_pptp_info.pns_call_id);
+	t.dst.u.gre.key =3D htons(ct->help.ct_pptp_info.pac_call_id);
+
+	ret =3D timeout_ct_or_exp(&t);
+
+	/* try reply (pac->pns) tuple */
+	memcpy(&t, &ct->tuplehash[IP_CT_DIR_REPLY].tuple, sizeof(t));
+	t.dst.protonum =3D IPPROTO_GRE;
+	t.src.u.gre.key =3D htons(ct->help.ct_pptp_info.pac_call_id);
+	t.dst.u.gre.key =3D htons(ct->help.ct_pptp_info.pns_call_id);
+
+	ret +=3D timeout_ct_or_exp(&t);
+
+	return ret;
+}
+
+/* expect GRE connections (PNS->PAC and PAC->PNS direction) */
+static inline int
+exp_gre(struct ip_conntrack *master,
+	u_int32_t seq,
+	u_int16_t callid,
+	u_int16_t peer_callid)
+{
+	struct ip_conntrack_tuple inv_tuple;
+	struct ip_conntrack_tuple exp_tuples[] =3D {
+		/* tuple in original direction, PNS->PAC */
+		{ .src =3D { .ip =3D master->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.ip,
+			   .u =3D { .gre =3D { .key =3D peer_callid } }
+			 },
+		  .dst =3D { .ip =3D master->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.ip,
+			   .u =3D { .gre =3D { .key =3D callid } },
+			   .protonum =3D IPPROTO_GRE
+			 },
+		 },
+		/* tuple in reply direction, PAC->PNS */
+		{ .src =3D { .ip =3D master->tuplehash[IP_CT_DIR_REPLY].tuple.src.ip,
+			   .u =3D { .gre =3D { .key =3D callid } }
+			 },
+		  .dst =3D { .ip =3D master->tuplehash[IP_CT_DIR_REPLY].tuple.dst.ip,
+			   .u =3D { .gre =3D { .key =3D peer_callid } },
+			   .protonum =3D IPPROTO_GRE
+			 },
+		 }
+	};
+
+	struct ip_conntrack_expect *exp_orig, *exp_reply;
+
+	exp_orig =3D ip_conntrack_expect_alloc(master);
+	if (exp_orig =3D=3D NULL)
+		return 1;
+
+	exp_reply =3D ip_conntrack_expect_alloc(master);
+	if (exp_reply =3D=3D NULL) {
+		ip_conntrack_expect_put(exp_orig);
+		return 1;
+	}
+
+	memcpy(&exp_orig->tuple, &exp_tuples[0], sizeof(exp_orig->tuple));
+
+	exp_orig->mask.src.ip =3D 0xffffffff;
+	exp_orig->mask.src.u.all =3D 0;
+	exp_orig->mask.dst.u.all =3D 0;
+	exp_orig->mask.dst.u.gre.key =3D 0xffff;
+	exp_orig->mask.dst.ip =3D 0xffffffff;
+	exp_orig->mask.dst.protonum =3D 0xff;
+	=09
+	exp_orig->master =3D master;
+	exp_orig->expectfn =3D pptp_expectfn;
+
+	exp_orig->dir =3D IP_CT_DIR_ORIGINAL;
+
+	/* both expectations are identical apart from tuple */
+	memcpy(exp_reply, exp_orig, sizeof(*exp_reply));
+	memcpy(&exp_reply->tuple, &exp_tuples[1], sizeof(exp_reply->tuple));
+
+	exp_reply->dir =3D !exp_orig->dir;
+
+	if (ip_nat_pptp_hook_exp_gre)
+		return ip_nat_pptp_hook_exp_gre(exp_orig, exp_reply);
+	else {
+
+		DEBUGP("calling expect_related PNS->PAC");
+		DUMP_TUPLE(&exp_orig->tuple);
+
+		if (ip_conntrack_expect_related(exp_orig) !=3D 0) {
+			ip_conntrack_expect_put(exp_orig);
+			ip_conntrack_expect_put(exp_reply);
+			DEBUGP("cannot expect_related()\n");
+			return 1;
+		}
+
+		DEBUGP("calling expect_related PAC->PNS");
+		DUMP_TUPLE(&exp_reply->tuple);
+
+		if (ip_conntrack_expect_related(exp_reply) !=3D 0) {
+			ip_conntrack_unexpect_related(exp_orig);
+			ip_conntrack_expect_put(exp_reply);
+			DEBUGP("cannot expect_related()\n");
+			return 1;
+		}
+
+		/* Add GRE keymap entries */
+		if (ip_ct_gre_keymap_add(master, &exp_reply->tuple, 0) !=3D 0) {
+			ip_conntrack_unexpect_related(exp_orig);
+			ip_conntrack_unexpect_related(exp_reply);
+			DEBUGP("cannot keymap_add() exp\n");
+			return 1;
+		}
+
+		invert_tuplepr(&inv_tuple, &exp_reply->tuple);
+		if (ip_ct_gre_keymap_add(master, &inv_tuple, 1) !=3D 0) {
+			ip_conntrack_unexpect_related(exp_orig);
+			ip_conntrack_unexpect_related(exp_reply);
+			ip_ct_gre_keymap_destroy(master);
+			DEBUGP("cannot keymap_add() exp_inv\n");
+			return 1;
+		}
+=09
+	}
+
+	ip_conntrack_expect_put(exp_orig);
+	ip_conntrack_expect_put(exp_reply);
+	return 0;
+}
+
+static inline int=20
+pptp_inbound_pkt(struct sk_buff **pskb,
+		 struct tcphdr *tcph,
+		 unsigned int ctlhoff,
+		 size_t datalen,
+		 struct ip_conntrack *ct,
+		 enum ip_conntrack_info ctinfo)
+{
+	struct PptpControlHeader _ctlh, *ctlh;
+	unsigned int reqlen;
+	union pptp_ctrl_union _pptpReq, *pptpReq;
+	struct ip_ct_pptp_master *info =3D &ct->help.ct_pptp_info;
+	u_int16_t msg, *cid, *pcid;
+	u_int32_t seq;=09
+
+	ctlh =3D skb_header_pointer(*pskb, ctlhoff, sizeof(_ctlh), &_ctlh);
+	if (unlikely(!ctlh)) {
+		DEBUGP("error during skb_header_pointer\n");
+		return NF_ACCEPT;
+	}
+
+	reqlen =3D datalen - sizeof(struct pptp_pkt_hdr) - sizeof(_ctlh);
+	pptpReq =3D skb_header_pointer(*pskb, ctlhoff+sizeof(_ctlh),
+				     reqlen, &_pptpReq);
+	if (unlikely(!pptpReq)) {
+		DEBUGP("error during skb_header_pointer\n");
+		return NF_ACCEPT;
+	}
+
+	msg =3D ntohs(ctlh->messageType);
+	DEBUGP("inbound control message %s\n", strMName[msg]);
+
+	switch (msg) {
+	case PPTP_START_SESSION_REPLY:
+		if (reqlen < sizeof(_pptpReq.srep)) {
+			DEBUGP("%s: short packet\n", strMName[msg]);
+			break;
+		}
+
+		/* server confirms new control session */
+		if (info->sstate < PPTP_SESSION_REQUESTED) {
+			DEBUGP("%s without START_SESS_REQUEST\n",
+				strMName[msg]);
+			break;
+		}
+		if (pptpReq->srep.resultCode =3D=3D PPTP_START_OK)
+			info->sstate =3D PPTP_SESSION_CONFIRMED;
+		else=20
+			info->sstate =3D PPTP_SESSION_ERROR;
+		break;
+
+	case PPTP_STOP_SESSION_REPLY:
+		if (reqlen < sizeof(_pptpReq.strep)) {
+			DEBUGP("%s: short packet\n", strMName[msg]);
+			break;
+		}
+
+		/* server confirms end of control session */
+		if (info->sstate > PPTP_SESSION_STOPREQ) {
+			DEBUGP("%s without STOP_SESS_REQUEST\n",
+				strMName[msg]);
+			break;
+		}
+		if (pptpReq->strep.resultCode =3D=3D PPTP_STOP_OK)
+			info->sstate =3D PPTP_SESSION_NONE;
+		else
+			info->sstate =3D PPTP_SESSION_ERROR;
+		break;
+
+	case PPTP_OUT_CALL_REPLY:
+		if (reqlen < sizeof(_pptpReq.ocack)) {
+			DEBUGP("%s: short packet\n", strMName[msg]);
+			break;
+		}
+
+		/* server accepted call, we now expect GRE frames */
+		if (info->sstate !=3D PPTP_SESSION_CONFIRMED) {
+			DEBUGP("%s but no session\n", strMName[msg]);
+			break;
+		}
+		if (info->cstate !=3D PPTP_CALL_OUT_REQ &&
+		    info->cstate !=3D PPTP_CALL_OUT_CONF) {
+			DEBUGP("%s without OUTCALL_REQ\n", strMName[msg]);
+			break;
+		}
+		if (pptpReq->ocack.resultCode !=3D PPTP_OUTCALL_CONNECT) {
+			info->cstate =3D PPTP_CALL_NONE;
+			break;
+		}
+
+		cid =3D &pptpReq->ocack.callID;
+		pcid =3D &pptpReq->ocack.peersCallID;
+
+		info->pac_call_id =3D ntohs(*cid);
+	=09
+		if (htons(info->pns_call_id) !=3D *pcid) {
+			DEBUGP("%s for unknown callid %u\n",
+				strMName[msg], ntohs(*pcid));
+			break;
+		}
+
+		DEBUGP("%s, CID=3D%X, PCID=3D%X\n", strMName[msg],=20
+			ntohs(*cid), ntohs(*pcid));
+	=09
+		info->cstate =3D PPTP_CALL_OUT_CONF;
+
+		seq =3D ntohl(tcph->seq) + sizeof(struct pptp_pkt_hdr)
+				       + sizeof(struct PptpControlHeader)
+				       + ((void *)pcid - (void *)pptpReq);
+		=09
+		if (exp_gre(ct, seq, *cid, *pcid) !=3D 0)
+			printk("ip_conntrack_pptp: error during exp_gre\n");
+		break;
+
+	case PPTP_IN_CALL_REQUEST:
+		if (reqlen < sizeof(_pptpReq.icack)) {
+			DEBUGP("%s: short packet\n", strMName[msg]);
+			break;
+		}
+
+		/* server tells us about incoming call request */
+		if (info->sstate !=3D PPTP_SESSION_CONFIRMED) {
+			DEBUGP("%s but no session\n", strMName[msg]);
+			break;
+		}
+		pcid =3D &pptpReq->icack.peersCallID;
+		DEBUGP("%s, PCID=3D%X\n", strMName[msg], ntohs(*pcid));
+		info->cstate =3D PPTP_CALL_IN_REQ;
+		info->pac_call_id =3D ntohs(*pcid);
+		break;
+
+	case PPTP_IN_CALL_CONNECT:
+		if (reqlen < sizeof(_pptpReq.iccon)) {
+			DEBUGP("%s: short packet\n", strMName[msg]);
+			break;
+		}
+
+		/* server tells us about incoming call established */
+		if (info->sstate !=3D PPTP_SESSION_CONFIRMED) {
+			DEBUGP("%s but no session\n", strMName[msg]);
+			break;
+		}
+		if (info->sstate !=3D PPTP_CALL_IN_REP
+		    && info->sstate !=3D PPTP_CALL_IN_CONF) {
+			DEBUGP("%s but never sent IN_CALL_REPLY\n",
+				strMName[msg]);
+			break;
+		}
+
+		pcid =3D &pptpReq->iccon.peersCallID;
+		cid =3D &info->pac_call_id;
+
+		if (info->pns_call_id !=3D ntohs(*pcid)) {
+			DEBUGP("%s for unknown CallID %u\n",=20
+				strMName[msg], ntohs(*cid));
+			break;
+		}
+
+		DEBUGP("%s, PCID=3D%X\n", strMName[msg], ntohs(*pcid));
+		info->cstate =3D PPTP_CALL_IN_CONF;
+
+		/* we expect a GRE connection from PAC to PNS */
+		seq =3D ntohl(tcph->seq) + sizeof(struct pptp_pkt_hdr)
+				       + sizeof(struct PptpControlHeader)
+				       + ((void *)pcid - (void *)pptpReq);
+		=09
+		if (exp_gre(ct, seq, *cid, *pcid) !=3D 0)
+			printk("ip_conntrack_pptp: error during exp_gre\n");
+
+		break;
+
+	case PPTP_CALL_DISCONNECT_NOTIFY:
+		if (reqlen < sizeof(_pptpReq.disc)) {
+			DEBUGP("%s: short packet\n", strMName[msg]);
+			break;
+		}
+
+		/* server confirms disconnect */
+		cid =3D &pptpReq->disc.callID;
+		DEBUGP("%s, CID=3D%X\n", strMName[msg], ntohs(*cid));
+		info->cstate =3D PPTP_CALL_NONE;
+
+		/* untrack this call id, unexpect GRE packets */
+		pptp_timeout_related(ct);
+		break;
+
+	case PPTP_WAN_ERROR_NOTIFY:
+		break;
+
+	case PPTP_ECHO_REQUEST:
+	case PPTP_ECHO_REPLY:
+		/* I don't have to explain these ;) */
+		break;
+	default:
+		DEBUGP("invalid %s (TY=3D%d)\n", (msg <=3D PPTP_MSG_MAX)
+			? strMName[msg]:strMName[0], msg);
+		break;
+	}
+
+
+	if (ip_nat_pptp_hook_inbound)
+		return ip_nat_pptp_hook_inbound(pskb, ct, ctinfo, ctlh,
+						pptpReq);
+
+	return NF_ACCEPT;
+
+}
+
+static inline int
+pptp_outbound_pkt(struct sk_buff **pskb,
+		  struct tcphdr *tcph,
+		  unsigned int ctlhoff,
+		  size_t datalen,
+		  struct ip_conntrack *ct,
+		  enum ip_conntrack_info ctinfo)
+{
+	struct PptpControlHeader _ctlh, *ctlh;
+	unsigned int reqlen;
+	union pptp_ctrl_union _pptpReq, *pptpReq;
+	struct ip_ct_pptp_master *info =3D &ct->help.ct_pptp_info;
+	u_int16_t msg, *cid, *pcid;
+
+	ctlh =3D skb_header_pointer(*pskb, ctlhoff, sizeof(_ctlh), &_ctlh);
+	if (!ctlh)
+		return NF_ACCEPT;
+=09
+	reqlen =3D datalen - sizeof(struct pptp_pkt_hdr) - sizeof(_ctlh);
+	pptpReq =3D skb_header_pointer(*pskb, ctlhoff+sizeof(_ctlh), reqlen,=20
+				     &_pptpReq);
+	if (!pptpReq)
+		return NF_ACCEPT;
+
+	msg =3D ntohs(ctlh->messageType);
+	DEBUGP("outbound control message %s\n", strMName[msg]);
+
+	switch (msg) {
+	case PPTP_START_SESSION_REQUEST:
+		/* client requests for new control session */
+		if (info->sstate !=3D PPTP_SESSION_NONE) {
+			DEBUGP("%s but we already have one",
+				strMName[msg]);
+		}
+		info->sstate =3D PPTP_SESSION_REQUESTED;
+		break;
+	case PPTP_STOP_SESSION_REQUEST:
+		/* client requests end of control session */
+		info->sstate =3D PPTP_SESSION_STOPREQ;
+		break;
+
+	case PPTP_OUT_CALL_REQUEST:
+		if (reqlen < sizeof(_pptpReq.ocreq)) {
+			DEBUGP("%s: short packet\n", strMName[msg]);
+			/* FIXME: break; */
+		}
+
+		/* client initiating connection to server */
+		if (info->sstate !=3D PPTP_SESSION_CONFIRMED) {
+			DEBUGP("%s but no session\n",
+				strMName[msg]);
+			break;
+		}
+		info->cstate =3D PPTP_CALL_OUT_REQ;
+		/* track PNS call id */
+		cid =3D &pptpReq->ocreq.callID;
+		DEBUGP("%s, CID=3D%X\n", strMName[msg], ntohs(*cid));
+		info->pns_call_id =3D ntohs(*cid);
+		break;
+	case PPTP_IN_CALL_REPLY:
+		if (reqlen < sizeof(_pptpReq.icack)) {
+			DEBUGP("%s: short packet\n", strMName[msg]);
+			break;
+		}
+
+		/* client answers incoming call */
+		if (info->cstate !=3D PPTP_CALL_IN_REQ
+		    && info->cstate !=3D PPTP_CALL_IN_REP) {
+			DEBUGP("%s without incall_req\n",=20
+				strMName[msg]);
+			break;
+		}
+		if (pptpReq->icack.resultCode !=3D PPTP_INCALL_ACCEPT) {
+			info->cstate =3D PPTP_CALL_NONE;
+			break;
+		}
+		pcid =3D &pptpReq->icack.peersCallID;
+		if (info->pac_call_id !=3D ntohs(*pcid)) {
+			DEBUGP("%s for unknown call %u\n",=20
+				strMName[msg], ntohs(*pcid));
+			break;
+		}
+		DEBUGP("%s, CID=3D%X\n", strMName[msg], ntohs(*pcid));
+		/* part two of the three-way handshake */
+		info->cstate =3D PPTP_CALL_IN_REP;
+		info->pns_call_id =3D ntohs(pptpReq->icack.callID);
+		break;
+
+	case PPTP_CALL_CLEAR_REQUEST:
+		/* client requests hangup of call */
+		if (info->sstate !=3D PPTP_SESSION_CONFIRMED) {
+			DEBUGP("CLEAR_CALL but no session\n");
+			break;
+		}
+		/* FUTURE: iterate over all calls and check if
+		 * call ID is valid.  We don't do this without newnat,
+		 * because we only know about last call */
+		info->cstate =3D PPTP_CALL_CLEAR_REQ;
+		break;
+	case PPTP_SET_LINK_INFO:
+		break;
+	case PPTP_ECHO_REQUEST:
+	case PPTP_ECHO_REPLY:
+		/* I don't have to explain these ;) */
+		break;
+	default:
+		DEBUGP("invalid %s (TY=3D%d)\n", (msg <=3D PPTP_MSG_MAX)?=20
+			strMName[msg]:strMName[0], msg);
+		/* unknown: no need to create GRE masq table entry */
+		break;
+	}
+=09
+	if (ip_nat_pptp_hook_outbound)
+		return ip_nat_pptp_hook_outbound(pskb, ct, ctinfo, ctlh,
+						 pptpReq);
+
+	return NF_ACCEPT;
+}
+
+
+/* track caller id inside control connection, call expect_related */
+static int=20
+conntrack_pptp_help(struct sk_buff **pskb,
+		    struct ip_conntrack *ct, enum ip_conntrack_info ctinfo)
+
+{
+	struct pptp_pkt_hdr _pptph, *pptph;
+=09
+	struct tcphdr _tcph, *tcph;
+	u_int32_t tcplen =3D (*pskb)->len - (*pskb)->nh.iph->ihl * 4;
+	u_int32_t datalen;
+	void *datalimit;
+	int dir =3D CTINFO2DIR(ctinfo);
+	struct ip_ct_pptp_master *info =3D &ct->help.ct_pptp_info;
+	unsigned int nexthdr_off;
+
+	int oldsstate, oldcstate;
+	int ret;
+
+	/* don't do any tracking before tcp handshake complete */
+	if (ctinfo !=3D IP_CT_ESTABLISHED=20
+	    && ctinfo !=3D IP_CT_ESTABLISHED+IP_CT_IS_REPLY) {
+		DEBUGP("ctinfo =3D %u, skipping\n", ctinfo);
+		return NF_ACCEPT;
+	}
+=09
+	nexthdr_off =3D (*pskb)->nh.iph->ihl*4;
+	tcph =3D skb_header_pointer(*pskb, (*pskb)->nh.iph->ihl*4, sizeof(_tcph),
+				  &_tcph);
+	if (!tcph)
+		return NF_ACCEPT;
+
+	/* not a complete TCP header? */
+	if (tcplen < sizeof(struct tcphdr) || tcplen < tcph->doff * 4) {
+		DEBUGP("tcplen =3D %u\n", tcplen);
+		return NF_ACCEPT;
+	}
+
+
+ 	datalen =3D tcplen - tcph->doff * 4;
+
+	/* checksum invalid? */
+	if (tcp_v4_check(tcph, tcplen, (*pskb)->nh.iph->saddr,
+			 (*pskb)->nh.iph->daddr,
+			 csum_partial((char *) tcph, tcplen, 0))) {
+		DEBUGP(" bad csum\n");
+		/* W2K PPTP server sends TCP packets with wrong checksum :(( */
+		/* return NF_ACCEPT */
+	}
+
+	if (tcph->fin || tcph->rst) {
+		DEBUGP("RST/FIN received, timeouting GRE\n");
+		/* can't do this after real newnat */
+		info->cstate =3D PPTP_CALL_NONE;
+
+		/* untrack this call id, unexpect GRE packets */
+		pptp_timeout_related(ct);
+	}
+
+	nexthdr_off +=3D tcph->doff*4;
+	pptph =3D skb_header_pointer(*pskb, (*pskb)->nh.iph->ihl*4 + tcph->doff*4,
+				   sizeof(_pptph), &_pptph);
+	if (!pptph) {
+		DEBUGP("no full PPTP header, can't track\n");
+		return NF_ACCEPT;
+	}
+
+	datalimit =3D (void *) pptph + datalen;
+
+	/* if it's not a control message we can't do anything with it */
+	if (ntohs(pptph->packetType) !=3D PPTP_PACKET_CONTROL ||
+	    ntohl(pptph->magicCookie) !=3D PPTP_MAGIC_COOKIE) {
+		DEBUGP("not a control packet\n");
+		return NF_ACCEPT;
+	}
+
+	oldsstate =3D info->sstate;
+	oldcstate =3D info->cstate;
+
+	spin_lock_bh(&ip_pptp_lock);
+
+	nexthdr_off +=3D sizeof(_pptph);
+	/* FIXME: We just blindly assume that the control connection is always
+	 * established from PNS->PAC.  However, RFC makes no guarantee */
+	if (dir =3D=3D IP_CT_DIR_ORIGINAL)
+		/* client -> server (PNS -> PAC) */
+		ret =3D pptp_outbound_pkt(pskb, tcph, nexthdr_off, datalen, ct,
+					ctinfo);
+	else
+		/* server -> client (PAC -> PNS) */
+		ret =3D pptp_inbound_pkt(pskb, tcph, nexthdr_off, datalen, ct,
+				       ctinfo);
+	DEBUGP("sstate: %d->%d, cstate: %d->%d\n",
+		oldsstate, info->sstate, oldcstate, info->cstate);
+	spin_unlock_bh(&ip_pptp_lock);
+
+	return ret;
+}
+
+/* control protocol helper */
+static struct ip_conntrack_helper pptp =3D {=20
+	.list =3D { NULL, NULL },
+	.name =3D "pptp",=20
+	.me =3D THIS_MODULE,
+	.max_expected =3D 2,
+	.timeout =3D 5 * 60,
+	.tuple =3D { .src =3D { .ip =3D 0,=20
+		 	    .u =3D { .tcp =3D { .port =3D =20
+				    __constant_htons(PPTP_CONTROL_PORT) } }=20
+			  },=20
+		   .dst =3D { .ip =3D 0,=20
+			    .u =3D { .all =3D 0 },
+			    .protonum =3D IPPROTO_TCP
+			  }=20
+		 },
+	.mask =3D { .src =3D { .ip =3D 0,=20
+			   .u =3D { .tcp =3D { .port =3D 0xffff } }=20
+			 },=20
+		  .dst =3D { .ip =3D 0,=20
+			   .u =3D { .all =3D 0 },
+			   .protonum =3D 0xff=20
+		 	 }=20
+		},
+	.help =3D conntrack_pptp_help
+};
+
+extern void __exit ip_ct_proto_gre_fini(void);
+extern int __init ip_ct_proto_gre_init(void);
+
+/* ip_conntrack_pptp initialization */
+static int __init init(void)
+{
+	int retcode;
+=20
+	retcode =3D ip_ct_proto_gre_init();
+	if (retcode < 0)
+		return retcode;
+
+	DEBUGP(" registering helper\n");
+	if ((retcode =3D ip_conntrack_helper_register(&pptp))) {
+		printk(KERN_ERR "Unable to register conntrack application "
+				"helper for pptp: %d\n", retcode);
+		ip_ct_proto_gre_fini();
+		return -EIO;
+	}
+
+	printk("ip_conntrack_pptp version %s loaded\n", IP_CT_PPTP_VERSION);
+	return 0;
+}
+
+static void __exit fini(void)
+{
+	ip_conntrack_helper_unregister(&pptp);
+	ip_ct_proto_gre_fini();
+	printk("ip_conntrack_pptp version %s unloaded\n", IP_CT_PPTP_VERSION);
+}
+
+module_init(init);
+module_exit(fini);
+
+EXPORT_SYMBOL(ip_pptp_lock);
+EXPORT_SYMBOL(ip_nat_pptp_hook_outbound);
+EXPORT_SYMBOL(ip_nat_pptp_hook_inbound);
+EXPORT_SYMBOL(ip_nat_pptp_hook_exp_gre);
+EXPORT_SYMBOL(ip_nat_pptp_hook_expectfn);
diff --git a/net/ipv4/netfilter/ip_conntrack_pptp_priv.h b/net/ipv4/netfilt=
er/ip_conntrack_pptp_priv.h
new file mode 100644
--- /dev/null
+++ b/net/ipv4/netfilter/ip_conntrack_pptp_priv.h
@@ -0,0 +1,24 @@
+#ifndef _IP_CT_PPTP_PRIV_H
+#define _IP_CT_PPTP_PRIV_H
+
+/* PptpControlMessageType names */
+static const char *strMName[] =3D {
+	"UNKNOWN_MESSAGE",
+	"START_SESSION_REQUEST",
+	"START_SESSION_REPLY",
+	"STOP_SESSION_REQUEST",
+	"STOP_SESSION_REPLY",
+	"ECHO_REQUEST",
+	"ECHO_REPLY",
+	"OUT_CALL_REQUEST",
+	"OUT_CALL_REPLY",
+	"IN_CALL_REQUEST",
+	"IN_CALL_REPLY",
+	"IN_CALL_CONNECT",
+	"CALL_CLEAR_REQUEST",
+	"CALL_DISCONNECT_NOTIFY",
+	"WAN_ERROR_NOTIFY",
+	"SET_LINK_INFO"
+};
+
+#endif
diff --git a/net/ipv4/netfilter/ip_conntrack_proto_gre.c b/net/ipv4/netfilt=
er/ip_conntrack_proto_gre.c
new file mode 100644
--- /dev/null
+++ b/net/ipv4/netfilter/ip_conntrack_proto_gre.c
@@ -0,0 +1,354 @@
+/*
+ * ip_conntrack_proto_gre.c - Version 3.0=20
+ *
+ * Connection tracking protocol helper module for GRE.
+ *
+ * GRE is a generic encapsulation protocol, which is generally not very
+ * suited for NAT, as it has no protocol-specific part as port numbers.
+ *
+ * It has an optional key field, which may help us distinguishing two=20
+ * connections between the same two hosts.
+ *
+ * GRE is defined in RFC 1701 and RFC 1702, as well as RFC 2784=20
+ *
+ * PPTP is built on top of a modified version of GRE, and has a mandatory
+ * field called "CallID", which serves us for the same purpose as the key
+ * field in plain GRE.
+ *
+ * Documentation about PPTP can be found in RFC 2637
+ *
+ * (C) 2000-2005 by Harald Welte <laforge@gnumonks.org>
+ *
+ * Development of this code funded by Astaro AG (http://www.astaro.com/)
+ *
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/timer.h>
+#include <linux/netfilter.h>
+#include <linux/ip.h>
+#include <linux/in.h>
+#include <linux/list.h>
+
+static DEFINE_RWLOCK(ip_ct_gre_lock);
+#define ASSERT_READ_LOCK(x)
+#define ASSERT_WRITE_LOCK(x)
+
+#include <linux/netfilter_ipv4/listhelp.h>
+#include <linux/netfilter_ipv4/ip_conntrack_protocol.h>
+#include <linux/netfilter_ipv4/ip_conntrack_helper.h>
+#include <linux/netfilter_ipv4/ip_conntrack_core.h>
+
+#include <linux/netfilter_ipv4/ip_conntrack_proto_gre.h>
+#include <linux/netfilter_ipv4/ip_conntrack_pptp.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Harald Welte <laforge@gnumonks.org>");
+MODULE_DESCRIPTION("netfilter connection tracking protocol helper for GRE"=
);
+
+/* shamelessly stolen from ip_conntrack_proto_udp.c */
+#define GRE_TIMEOUT		(30*HZ)
+#define GRE_STREAM_TIMEOUT	(180*HZ)
+
+#if 0
+#define DEBUGP(format, args...)	printk(KERN_DEBUG "%s:%s: " format, __FILE=
__, __FUNCTION__, ## args)
+#define DUMP_TUPLE_GRE(x) printk("%u.%u.%u.%u:0x%x -> %u.%u.%u.%u:0x%x\n",=
 \
+			NIPQUAD((x)->src.ip), ntohs((x)->src.u.gre.key), \
+			NIPQUAD((x)->dst.ip), ntohs((x)->dst.u.gre.key))
+#else
+#define DEBUGP(x, args...)
+#define DUMP_TUPLE_GRE(x)
+#endif
+			=09
+/* GRE KEYMAP HANDLING FUNCTIONS */
+static LIST_HEAD(gre_keymap_list);
+
+static inline int gre_key_cmpfn(const struct ip_ct_gre_keymap *km,
+				const struct ip_conntrack_tuple *t)
+{
+	return ((km->tuple.src.ip =3D=3D t->src.ip) &&
+		(km->tuple.dst.ip =3D=3D t->dst.ip) &&
+		(km->tuple.dst.protonum =3D=3D t->dst.protonum) &&
+		(km->tuple.dst.u.all =3D=3D t->dst.u.all));
+}
+
+/* look up the source key for a given tuple */
+static u_int32_t gre_keymap_lookup(struct ip_conntrack_tuple *t)
+{
+	struct ip_ct_gre_keymap *km;
+	u_int32_t key =3D 0;
+
+	read_lock_bh(&ip_ct_gre_lock);
+	km =3D LIST_FIND(&gre_keymap_list, gre_key_cmpfn,
+			struct ip_ct_gre_keymap *, t);
+	if (km)
+		key =3D km->tuple.src.u.gre.key;
+	read_unlock_bh(&ip_ct_gre_lock);
+=09
+	DEBUGP("lookup src key 0x%x up key for ", key);
+	DUMP_TUPLE_GRE(t);
+
+	return key;
+}
+
+/* add a single keymap entry, associate with specified master ct */
+int
+ip_ct_gre_keymap_add(struct ip_conntrack *ct,
+		     struct ip_conntrack_tuple *t, int reply)
+{
+	struct ip_ct_gre_keymap *km, *old;
+
+	if (!ct->helper || strcmp(ct->helper->name, "pptp")) {
+		DEBUGP("refusing to add GRE keymap to non-pptp session\n");
+		return -1;
+	}
+
+	km =3D kmalloc(sizeof(*km), GFP_ATOMIC);
+	if (!km)
+		return -1;
+
+	/* initializing list head should be sufficient */
+	memset(km, 0, sizeof(*km));
+
+	memcpy(&km->tuple, t, sizeof(*t));
+
+	if (!reply) {
+		if (ct->help.ct_pptp_info.keymap_orig) {
+			kfree(km);
+
+			/* check whether it's a retransmission */
+			old =3D LIST_FIND(&gre_keymap_list, gre_key_cmpfn,
+					struct ip_ct_gre_keymap *, t);
+			if (old =3D=3D ct->help.ct_pptp_info.keymap_orig) {
+				DEBUGP("retransmission\n");
+				return 0;
+			}
+
+			DEBUGP("trying to override keymap_orig for ct %p\n",
+				ct);
+			return -2;
+		}
+		ct->help.ct_pptp_info.keymap_orig =3D km;
+	} else {
+		if (ct->help.ct_pptp_info.keymap_reply) {
+			kfree(km);
+
+			/* check whether it's a retransmission */
+			old =3D LIST_FIND(&gre_keymap_list, gre_key_cmpfn,
+					struct ip_ct_gre_keymap *, t);
+			if (old =3D=3D ct->help.ct_pptp_info.keymap_reply) {
+				DEBUGP("retransmission\n");
+				return 0;
+			}
+
+			DEBUGP("trying to override keymap_reply for ct %p\n",
+				ct);
+			return -2;
+		}
+		ct->help.ct_pptp_info.keymap_reply =3D km;
+	}
+
+	DEBUGP("adding new entry %p: ", km);
+	DUMP_TUPLE_GRE(&km->tuple);
+
+	write_lock_bh(&ip_ct_gre_lock);
+	list_append(&gre_keymap_list, km);
+	write_unlock_bh(&ip_ct_gre_lock);
+
+	return 0;
+}
+
+/* destroy the keymap entries associated with specified master ct */
+void ip_ct_gre_keymap_destroy(struct ip_conntrack *ct)
+{
+	DEBUGP("entering for ct %p\n", ct);
+
+	if (!ct->helper || strcmp(ct->helper->name, "pptp")) {
+		DEBUGP("refusing to destroy GRE keymap to non-pptp session\n");
+		return;
+	}
+
+	write_lock_bh(&ip_ct_gre_lock);
+	if (ct->help.ct_pptp_info.keymap_orig) {
+		DEBUGP("removing %p from list\n",=20
+			ct->help.ct_pptp_info.keymap_orig);
+		list_del(&ct->help.ct_pptp_info.keymap_orig->list);
+		kfree(ct->help.ct_pptp_info.keymap_orig);
+		ct->help.ct_pptp_info.keymap_orig =3D NULL;
+	}
+	if (ct->help.ct_pptp_info.keymap_reply) {
+		DEBUGP("removing %p from list\n",
+			ct->help.ct_pptp_info.keymap_reply);
+		list_del(&ct->help.ct_pptp_info.keymap_reply->list);
+		kfree(ct->help.ct_pptp_info.keymap_reply);
+		ct->help.ct_pptp_info.keymap_reply =3D NULL;
+	}
+	write_unlock_bh(&ip_ct_gre_lock);
+}
+
+
+/* PUBLIC CONNTRACK PROTO HELPER FUNCTIONS */
+
+/* invert gre part of tuple */
+static int gre_invert_tuple(struct ip_conntrack_tuple *tuple,
+			    const struct ip_conntrack_tuple *orig)
+{
+	tuple->dst.u.gre.key =3D orig->src.u.gre.key;
+	tuple->src.u.gre.key =3D orig->dst.u.gre.key;
+
+	return 1;
+}
+
+/* gre hdr info to tuple */
+static int gre_pkt_to_tuple(const struct sk_buff *skb,
+			   unsigned int dataoff,
+			   struct ip_conntrack_tuple *tuple)
+{
+	struct gre_hdr_pptp _pgrehdr, *pgrehdr;
+	u_int32_t srckey;
+	struct gre_hdr _grehdr, *grehdr;
+
+	/* first only delinearize old RFC1701 GRE header */
+	grehdr =3D skb_header_pointer(skb, dataoff, sizeof(_grehdr), &_grehdr);
+	if (!grehdr || grehdr->version !=3D GRE_VERSION_PPTP) {
+		/* try to behave like "ip_conntrack_proto_generic" */
+		tuple->src.u.all =3D 0;
+		tuple->dst.u.all =3D 0;
+		return 1;
+	}
+
+	/* PPTP header is variable length, only need up to the call_id field */
+	pgrehdr =3D skb_header_pointer(skb, dataoff, 8, &_pgrehdr);
+	if (!pgrehdr)
+		return 1;
+
+	if (ntohs(grehdr->protocol) !=3D GRE_PROTOCOL_PPTP) {
+		DEBUGP("GRE_VERSION_PPTP but unknown proto\n");
+		return 0;
+	}
+
+	tuple->dst.u.gre.key =3D pgrehdr->call_id;
+	srckey =3D gre_keymap_lookup(tuple);
+	tuple->src.u.gre.key =3D srckey;
+
+	return 1;
+}
+
+/* print gre part of tuple */
+static int gre_print_tuple(struct seq_file *s,
+			   const struct ip_conntrack_tuple *tuple)
+{
+	return seq_printf(s, "srckey=3D0x%x dstkey=3D0x%x ",=20
+			  ntohs(tuple->src.u.gre.key),
+			  ntohs(tuple->dst.u.gre.key));
+}
+
+/* print private data for conntrack */
+static int gre_print_conntrack(struct seq_file *s,
+			       const struct ip_conntrack *ct)
+{
+	return seq_printf(s, "timeout=3D%u, stream_timeout=3D%u ",
+			  (ct->proto.gre.timeout / HZ),
+			  (ct->proto.gre.stream_timeout / HZ));
+}
+
+/* Returns verdict for packet, and may modify conntrack */
+static int gre_packet(struct ip_conntrack *ct,
+		      const struct sk_buff *skb,
+		      enum ip_conntrack_info conntrackinfo)
+{
+	/* If we've seen traffic both ways, this is a GRE connection.
+	 * Extend timeout. */
+	if (ct->status & IPS_SEEN_REPLY) {
+		ip_ct_refresh_acct(ct, conntrackinfo, skb,
+				   ct->proto.gre.stream_timeout);
+		/* Also, more likely to be important, and not a probe. */
+		set_bit(IPS_ASSURED_BIT, &ct->status);
+	} else
+		ip_ct_refresh_acct(ct, conntrackinfo, skb,
+				   ct->proto.gre.timeout);
+=09
+	return NF_ACCEPT;
+}
+
+/* Called when a new connection for this protocol found. */
+static int gre_new(struct ip_conntrack *ct,
+		   const struct sk_buff *skb)
+{=20
+	DEBUGP(": ");
+	DUMP_TUPLE_GRE(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
+
+	/* initialize to sane value.  Ideally a conntrack helper
+	 * (e.g. in case of pptp) is increasing them */
+	ct->proto.gre.stream_timeout =3D GRE_STREAM_TIMEOUT;
+	ct->proto.gre.timeout =3D GRE_TIMEOUT;
+
+	return 1;
+}
+
+/* Called when a conntrack entry has already been removed from the hashes
+ * and is about to be deleted from memory */
+static void gre_destroy(struct ip_conntrack *ct)
+{
+	struct ip_conntrack *master =3D ct->master;
+	DEBUGP(" entering\n");
+
+	if (!master)
+		DEBUGP("no master !?!\n");
+	else
+		ip_ct_gre_keymap_destroy(master);
+}
+
+/* protocol helper struct */
+static struct ip_conntrack_protocol gre =3D {=20
+	.proto		 =3D IPPROTO_GRE,
+	.name		 =3D "gre",=20
+	.pkt_to_tuple	 =3D gre_pkt_to_tuple,
+	.invert_tuple	 =3D gre_invert_tuple,
+	.print_tuple	 =3D gre_print_tuple,
+	.print_conntrack =3D gre_print_conntrack,
+	.packet		 =3D gre_packet,
+	.new		 =3D gre_new,
+	.destroy	 =3D gre_destroy,
+	.me 		 =3D THIS_MODULE,
+#if defined(CONFIG_IP_NF_CONNTRACK_NETLINK) || \
+    defined(CONFIG_IP_NF_CONNTRACK_NETLINK_MODULE)
+	.tuple_to_nfattr =3D ip_ct_port_tuple_to_nfattr,
+	.nfattr_to_tuple =3D ip_ct_port_nfattr_to_tuple,
+#endif
+};
+
+/* ip_conntrack_proto_gre initialization */
+int __init ip_ct_proto_gre_init(void)
+{
+	int retcode;
+
+	if ((retcode =3D ip_conntrack_protocol_register(&gre))) {
+		printk(KERN_ERR "Unable to register conntrack protocol "
+		       "helper for gre: %d\n", retcode);
+		return -EIO;
+	}
+
+	return 0;
+}
+
+void __exit ip_ct_proto_gre_fini(void)
+{
+	struct list_head *pos, *n;
+
+	/* delete all keymap entries */
+	write_lock_bh(&ip_ct_gre_lock);
+	list_for_each_safe(pos, n, &gre_keymap_list) {
+		DEBUGP("deleting keymap %p at module unload time\n", pos);
+		list_del(pos);
+		kfree(pos);
+	}
+	write_unlock_bh(&ip_ct_gre_lock);
+
+	ip_conntrack_protocol_unregister(&gre);=20
+}
+
+EXPORT_SYMBOL(ip_ct_gre_keymap_add);
+EXPORT_SYMBOL(ip_ct_gre_keymap_destroy);
diff --git a/net/ipv4/netfilter/ip_nat_helper_pptp.c b/net/ipv4/netfilter/i=
p_nat_helper_pptp.c
new file mode 100644
--- /dev/null
+++ b/net/ipv4/netfilter/ip_nat_helper_pptp.c
@@ -0,0 +1,401 @@
+/*
+ * ip_nat_pptp.c	- Version 3.0
+ *
+ * NAT support for PPTP (Point to Point Tunneling Protocol).
+ * PPTP is a a protocol for creating virtual private networks.
+ * It is a specification defined by Microsoft and some vendors
+ * working with Microsoft.  PPTP is built on top of a modified
+ * version of the Internet Generic Routing Encapsulation Protocol.
+ * GRE is defined in RFC 1701 and RFC 1702.  Documentation of
+ * PPTP can be found in RFC 2637
+ *
+ * (C) 2000-2005 by Harald Welte <laforge@gnumonks.org>
+ *
+ * Development of this code funded by Astaro AG (http://www.astaro.com/)
+ *
+ * TODO: - NAT to a unique tuple, not to TCP source port
+ * 	   (needs netfilter tuple reservation)
+ *
+ * Changes:
+ *     2002-02-10 - Version 1.3
+ *       - Use ip_nat_mangle_tcp_packet() because of cloned skb's
+ *	   in local connections (Philip Craig <philipc@snapgear.com>)
+ *       - add checks for magicCookie and pptp version
+ *       - make argument list of pptp_{out,in}bound_packet() shorter
+ *       - move to C99 style initializers
+ *       - print version number at module loadtime
+ *     2003-09-22 - Version 1.5
+ *       - use SNATed tcp sourceport as callid, since we get called before
+ *	   TCP header is mangled (Philip Craig <philipc@snapgear.com>)
+ *     2004-10-22 - Version 2.0
+ *       - kernel 2.6.x version
+ *     2005-06-10 - Version 3.0
+ *       - kernel >=3D 2.6.11 version,
+ *	   funded by Oxcoda NetBox Blue (http://www.netboxblue.com/)
+ *=20
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <net/tcp.h>
+
+#include <linux/netfilter_ipv4/ip_nat.h>
+#include <linux/netfilter_ipv4/ip_nat_rule.h>
+#include <linux/netfilter_ipv4/ip_nat_helper.h>
+#include <linux/netfilter_ipv4/ip_nat_pptp.h>
+#include <linux/netfilter_ipv4/ip_conntrack_core.h>
+#include <linux/netfilter_ipv4/ip_conntrack_helper.h>
+#include <linux/netfilter_ipv4/ip_conntrack_proto_gre.h>
+#include <linux/netfilter_ipv4/ip_conntrack_pptp.h>
+
+#define IP_NAT_PPTP_VERSION "3.0"
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Harald Welte <laforge@gnumonks.org>");
+MODULE_DESCRIPTION("Netfilter NAT helper module for PPTP");
+
+
+#if 0
+#include "ip_conntrack_pptp_priv.h"
+#define DEBUGP(format, args...) printk(KERN_DEBUG "%s:%s: " format, __FILE=
__, \
+				       __FUNCTION__, ## args)
+#else
+#define DEBUGP(format, args...)
+#endif
+
+static void pptp_nat_expected(struct ip_conntrack *ct,
+			      struct ip_conntrack_expect *exp)
+{
+	struct ip_conntrack *master =3D ct->master;
+	struct ip_conntrack_expect *other_exp;
+	struct ip_conntrack_tuple t;
+	struct ip_ct_pptp_master *ct_pptp_info;
+	struct ip_nat_pptp *nat_pptp_info;
+
+	ct_pptp_info =3D &master->help.ct_pptp_info;
+	nat_pptp_info =3D &master->nat.help.nat_pptp_info;
+
+	/* And here goes the grand finale of corrosion... */
+
+	if (exp->dir =3D=3D IP_CT_DIR_ORIGINAL) {
+		DEBUGP("we are PNS->PAC\n");
+		/* therefore, build tuple for PAC->PNS */
+		t.src.ip =3D master->tuplehash[IP_CT_DIR_REPLY].tuple.src.ip;
+		t.src.u.gre.key =3D htons(master->help.ct_pptp_info.pac_call_id);
+		t.dst.ip =3D master->tuplehash[IP_CT_DIR_REPLY].tuple.dst.ip;
+		t.dst.u.gre.key =3D htons(master->help.ct_pptp_info.pns_call_id);
+		t.dst.protonum =3D IPPROTO_GRE;
+	} else {
+		DEBUGP("we are PAC->PNS\n");
+		/* build tuple for PNS->PAC */
+		t.src.ip =3D master->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.ip;
+		t.src.u.gre.key =3D=20
+			htons(master->nat.help.nat_pptp_info.pns_call_id);
+		t.dst.ip =3D master->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.ip;
+		t.dst.u.gre.key =3D=20
+			htons(master->nat.help.nat_pptp_info.pac_call_id);
+		t.dst.protonum =3D IPPROTO_GRE;
+	}
+
+	DEBUGP("trying to unexpect other dir: ");
+	DUMP_TUPLE(&t);
+	other_exp =3D __ip_conntrack_expect_find(&t);
+	if (other_exp) {
+		ip_conntrack_unexpect_related(other_exp);
+		DEBUGP("success\n");
+	} else {
+		DEBUGP("not found!\n");
+	}
+
+	ip_nat_follow_master(ct, exp);
+}
+
+/* outbound packets =3D=3D from PNS to PAC */
+static int
+pptp_outbound_pkt(struct sk_buff **pskb,
+		  struct ip_conntrack *ct,
+		  enum ip_conntrack_info ctinfo,
+		  struct PptpControlHeader *ctlh,
+		  union pptp_ctrl_union *pptpReq)
+
+{
+	struct ip_ct_pptp_master *ct_pptp_info =3D &ct->help.ct_pptp_info;
+	struct ip_nat_pptp *nat_pptp_info =3D &ct->nat.help.nat_pptp_info;
+
+	u_int16_t msg, *cid =3D NULL, new_callid;
+
+	new_callid =3D htons(ct_pptp_info->pns_call_id);
+=09
+	switch (msg =3D ntohs(ctlh->messageType)) {
+		case PPTP_OUT_CALL_REQUEST:
+			cid =3D &pptpReq->ocreq.callID;
+			/* FIXME: ideally we would want to reserve a call ID
+			 * here.  current netfilter NAT core is not able to do
+			 * this :( For now we use TCP source port. This breaks
+			 * multiple calls within one control session */
+
+			/* save original call ID in nat_info */
+			nat_pptp_info->pns_call_id =3D ct_pptp_info->pns_call_id;
+
+			/* don't use tcph->source since we are at a DSTmanip
+			 * hook (e.g. PREROUTING) and pkt is not mangled yet */
+			new_callid =3D ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.u.tcp.port;
+
+			/* save new call ID in ct info */
+			ct_pptp_info->pns_call_id =3D ntohs(new_callid);
+			break;
+		case PPTP_IN_CALL_REPLY:
+			cid =3D &pptpReq->icreq.callID;
+			break;
+		case PPTP_CALL_CLEAR_REQUEST:
+			cid =3D &pptpReq->clrreq.callID;
+			break;
+		default:
+			DEBUGP("unknown outbound packet 0x%04x:%s\n", msg,
+			      (msg <=3D PPTP_MSG_MAX)? strMName[msg]:strMName[0]);
+			/* fall through */
+
+		case PPTP_SET_LINK_INFO:
+			/* only need to NAT in case PAC is behind NAT box */
+		case PPTP_START_SESSION_REQUEST:
+		case PPTP_START_SESSION_REPLY:
+		case PPTP_STOP_SESSION_REQUEST:
+		case PPTP_STOP_SESSION_REPLY:
+		case PPTP_ECHO_REQUEST:
+		case PPTP_ECHO_REPLY:
+			/* no need to alter packet */
+			return NF_ACCEPT;
+	}
+
+	/* only OUT_CALL_REQUEST, IN_CALL_REPLY, CALL_CLEAR_REQUEST pass
+	 * down to here */
+
+	IP_NF_ASSERT(cid);
+
+	DEBUGP("altering call id from 0x%04x to 0x%04x\n",
+		ntohs(*cid), ntohs(new_callid));
+
+	/* mangle packet */
+	if (ip_nat_mangle_tcp_packet(pskb, ct, ctinfo,
+		(void *)cid - ((void *)ctlh - sizeof(struct pptp_pkt_hdr)),
+				 	sizeof(new_callid),=20
+					(char *)&new_callid,
+				 	sizeof(new_callid)) =3D=3D 0)
+		return NF_DROP;
+
+	return NF_ACCEPT;
+}
+
+static int
+pptp_exp_gre(struct ip_conntrack_expect *expect_orig,
+	     struct ip_conntrack_expect *expect_reply)
+{
+	struct ip_ct_pptp_master *ct_pptp_info =3D=20
+				&expect_orig->master->help.ct_pptp_info;
+	struct ip_nat_pptp *nat_pptp_info =3D=20
+				&expect_orig->master->nat.help.nat_pptp_info;
+
+	struct ip_conntrack *ct =3D expect_orig->master;
+
+	struct ip_conntrack_tuple inv_t;
+	struct ip_conntrack_tuple *orig_t, *reply_t;
+
+	/* save original PAC call ID in nat_info */
+	nat_pptp_info->pac_call_id =3D ct_pptp_info->pac_call_id;
+
+	/* alter expectation */
+	orig_t =3D &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
+	reply_t =3D &ct->tuplehash[IP_CT_DIR_REPLY].tuple;
+
+	/* alter expectation for PNS->PAC direction */
+	invert_tuplepr(&inv_t, &expect_orig->tuple);
+	expect_orig->saved_proto.gre.key =3D htons(nat_pptp_info->pac_call_id);
+	expect_orig->tuple.src.u.gre.key =3D htons(nat_pptp_info->pns_call_id);
+	expect_orig->tuple.dst.u.gre.key =3D htons(ct_pptp_info->pac_call_id);
+	inv_t.src.ip =3D reply_t->src.ip;
+	inv_t.dst.ip =3D reply_t->dst.ip;
+	inv_t.src.u.gre.key =3D htons(nat_pptp_info->pac_call_id);
+	inv_t.dst.u.gre.key =3D htons(ct_pptp_info->pns_call_id);
+
+	if (!ip_conntrack_expect_related(expect_orig)) {
+		DEBUGP("successfully registered expect\n");
+	} else {
+		DEBUGP("can't expect_related(expect_orig)\n");
+		ip_conntrack_expect_put(expect_orig);
+		return 1;
+	}
+
+	/* alter expectation for PAC->PNS direction */
+	invert_tuplepr(&inv_t, &expect_reply->tuple);
+	expect_reply->saved_proto.gre.key =3D htons(nat_pptp_info->pns_call_id);
+	expect_reply->tuple.src.u.gre.key =3D htons(nat_pptp_info->pac_call_id);
+	expect_reply->tuple.dst.u.gre.key =3D htons(ct_pptp_info->pns_call_id);
+	inv_t.src.ip =3D orig_t->src.ip;
+	inv_t.dst.ip =3D orig_t->dst.ip;
+	inv_t.src.u.gre.key =3D htons(nat_pptp_info->pns_call_id);
+	inv_t.dst.u.gre.key =3D htons(ct_pptp_info->pac_call_id);
+
+	if (!ip_conntrack_expect_related(expect_reply)) {
+		DEBUGP("successfully registered expect\n");
+	} else {
+		DEBUGP("can't expect_related(expect_reply)\n");
+		ip_conntrack_unexpect_related(expect_orig);
+		ip_conntrack_expect_put(expect_reply);
+		return 1;
+	}
+
+	if (ip_ct_gre_keymap_add(ct, &expect_reply->tuple, 0) < 0) {
+		DEBUGP("can't register original keymap\n");
+		ip_conntrack_unexpect_related(expect_orig);
+		ip_conntrack_unexpect_related(expect_reply);
+		return 1;
+	}
+
+	if (ip_ct_gre_keymap_add(ct, &inv_t, 1) < 0) {
+		DEBUGP("can't register reply keymap\n");
+		ip_conntrack_unexpect_related(expect_orig);
+		ip_conntrack_unexpect_related(expect_reply);
+		ip_ct_gre_keymap_destroy(ct);
+		return 1;
+	}
+
+	return 0;
+}
+
+/* inbound packets =3D=3D from PAC to PNS */
+static int
+pptp_inbound_pkt(struct sk_buff **pskb,
+		 struct ip_conntrack *ct,
+		 enum ip_conntrack_info ctinfo,
+		 struct PptpControlHeader *ctlh,
+		 union pptp_ctrl_union *pptpReq)
+{
+	struct ip_nat_pptp *nat_pptp_info =3D &ct->nat.help.nat_pptp_info;
+	u_int16_t msg, new_cid =3D 0, new_pcid, *pcid =3D NULL, *cid =3D NULL;
+
+	int ret =3D NF_ACCEPT, rv;
+
+	new_pcid =3D htons(nat_pptp_info->pns_call_id);
+
+	switch (msg =3D ntohs(ctlh->messageType)) {
+	case PPTP_OUT_CALL_REPLY:
+		pcid =3D &pptpReq->ocack.peersCallID;=09
+		cid =3D &pptpReq->ocack.callID;
+		break;
+	case PPTP_IN_CALL_CONNECT:
+		pcid =3D &pptpReq->iccon.peersCallID;
+		break;
+	case PPTP_IN_CALL_REQUEST:
+		/* only need to nat in case PAC is behind NAT box */
+		break;
+	case PPTP_WAN_ERROR_NOTIFY:
+		pcid =3D &pptpReq->wanerr.peersCallID;
+		break;
+	case PPTP_CALL_DISCONNECT_NOTIFY:
+		pcid =3D &pptpReq->disc.callID;
+		break;
+	case PPTP_SET_LINK_INFO:
+		pcid =3D &pptpReq->setlink.peersCallID;
+		break;
+
+	default:
+		DEBUGP("unknown inbound packet %s\n",
+			(msg <=3D PPTP_MSG_MAX)? strMName[msg]:strMName[0]);
+		/* fall through */
+
+	case PPTP_START_SESSION_REQUEST:
+	case PPTP_START_SESSION_REPLY:
+	case PPTP_STOP_SESSION_REQUEST:
+	case PPTP_STOP_SESSION_REPLY:
+	case PPTP_ECHO_REQUEST:
+	case PPTP_ECHO_REPLY:
+		/* no need to alter packet */
+		return NF_ACCEPT;
+	}
+
+	/* only OUT_CALL_REPLY, IN_CALL_CONNECT, IN_CALL_REQUEST,
+	 * WAN_ERROR_NOTIFY, CALL_DISCONNECT_NOTIFY pass down here */
+
+	/* mangle packet */
+	IP_NF_ASSERT(pcid);
+	DEBUGP("altering peer call id from 0x%04x to 0x%04x\n",
+		ntohs(*pcid), ntohs(new_pcid));
+=09
+	rv =3D ip_nat_mangle_tcp_packet(pskb, ct, ctinfo,=20
+				      (void *)pcid - ((void *)ctlh - sizeof(struct pptp_pkt_hdr)),
+				      sizeof(new_pcid), (char *)&new_pcid,=20
+				      sizeof(new_pcid));
+	if (rv !=3D NF_ACCEPT)=20
+		return rv;
+
+	if (new_cid) {
+		IP_NF_ASSERT(cid);
+		DEBUGP("altering call id from 0x%04x to 0x%04x\n",
+			ntohs(*cid), ntohs(new_cid));
+		rv =3D ip_nat_mangle_tcp_packet(pskb, ct, ctinfo,=20
+					      (void *)cid - ((void *)ctlh - sizeof(struct pptp_pkt_hdr)),=20
+					      sizeof(new_cid),
+					      (char *)&new_cid,=20
+					      sizeof(new_cid));
+		if (rv !=3D NF_ACCEPT)
+			return rv;
+	}
+
+	/* check for earlier return value of 'switch' above */
+	if (ret !=3D NF_ACCEPT)
+		return ret;
+
+	/* great, at least we don't need to resize packets */
+	return NF_ACCEPT;
+}
+
+
+extern int __init ip_nat_proto_gre_init(void);
+extern void __exit ip_nat_proto_gre_fini(void);
+
+static int __init init(void)
+{
+	int ret;
+
+	DEBUGP("%s: registering NAT helper\n", __FILE__);
+
+	ret =3D ip_nat_proto_gre_init();
+	if (ret < 0)
+		return ret;
+
+	BUG_ON(ip_nat_pptp_hook_outbound);
+	ip_nat_pptp_hook_outbound =3D &pptp_outbound_pkt;
+
+	BUG_ON(ip_nat_pptp_hook_inbound);
+	ip_nat_pptp_hook_inbound =3D &pptp_inbound_pkt;
+
+	BUG_ON(ip_nat_pptp_hook_exp_gre);
+	ip_nat_pptp_hook_exp_gre =3D &pptp_exp_gre;
+
+	BUG_ON(ip_nat_pptp_hook_expectfn);
+	ip_nat_pptp_hook_expectfn =3D &pptp_nat_expected;
+
+	printk("ip_nat_pptp version %s loaded\n", IP_NAT_PPTP_VERSION);
+	return 0;
+}
+
+static void __exit fini(void)
+{
+	DEBUGP("cleanup_module\n" );
+
+	ip_nat_pptp_hook_expectfn =3D NULL;
+	ip_nat_pptp_hook_exp_gre =3D NULL;
+	ip_nat_pptp_hook_inbound =3D NULL;
+	ip_nat_pptp_hook_outbound =3D NULL;
+
+	ip_nat_proto_gre_fini();
+	/* Make sure noone calls it, meanwhile */
+	synchronize_net();
+
+	printk("ip_nat_pptp version %s unloaded\n", IP_NAT_PPTP_VERSION);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/ipv4/netfilter/ip_nat_proto_gre.c b/net/ipv4/netfilter/ip_=
nat_proto_gre.c
new file mode 100644
--- /dev/null
+++ b/net/ipv4/netfilter/ip_nat_proto_gre.c
@@ -0,0 +1,216 @@
+/*
+ * ip_nat_proto_gre.c - Version 2.0
+ *
+ * NAT protocol helper module for GRE.
+ *
+ * GRE is a generic encapsulation protocol, which is generally not very
+ * suited for NAT, as it has no protocol-specific part as port numbers.
+ *
+ * It has an optional key field, which may help us distinguishing two=20
+ * connections between the same two hosts.
+ *
+ * GRE is defined in RFC 1701 and RFC 1702, as well as RFC 2784=20
+ *
+ * PPTP is built on top of a modified version of GRE, and has a mandatory
+ * field called "CallID", which serves us for the same purpose as the key
+ * field in plain GRE.
+ *
+ * Documentation about PPTP can be found in RFC 2637
+ *
+ * (C) 2000-2005 by Harald Welte <laforge@gnumonks.org>
+ *
+ * Development of this code funded by Astaro AG (http://www.astaro.com/)
+ *
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/ip.h>
+#include <linux/netfilter_ipv4/ip_nat.h>
+#include <linux/netfilter_ipv4/ip_nat_rule.h>
+#include <linux/netfilter_ipv4/ip_nat_protocol.h>
+#include <linux/netfilter_ipv4/ip_conntrack_proto_gre.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Harald Welte <laforge@gnumonks.org>");
+MODULE_DESCRIPTION("Netfilter NAT protocol helper module for GRE");
+
+#if 0
+#define DEBUGP(format, args...) printk(KERN_DEBUG "%s:%s: " format, __FILE=
__, \
+				       __FUNCTION__, ## args)
+#else
+#define DEBUGP(x, args...)
+#endif
+
+/* is key in given range between min and max */
+static int
+gre_in_range(const struct ip_conntrack_tuple *tuple,
+	     enum ip_nat_manip_type maniptype,
+	     const union ip_conntrack_manip_proto *min,
+	     const union ip_conntrack_manip_proto *max)
+{
+	u_int32_t key;
+
+	if (maniptype =3D=3D IP_NAT_MANIP_SRC)
+		key =3D tuple->src.u.gre.key;
+	else
+		key =3D tuple->dst.u.gre.key;
+
+	return ntohl(key) >=3D ntohl(min->gre.key)
+		&& ntohl(key) <=3D ntohl(max->gre.key);
+}
+
+/* generate unique tuple ... */
+static int=20
+gre_unique_tuple(struct ip_conntrack_tuple *tuple,
+		 const struct ip_nat_range *range,
+		 enum ip_nat_manip_type maniptype,
+		 const struct ip_conntrack *conntrack)
+{
+	u_int32_t min, i, range_size;
+	u_int16_t key =3D 0, *keyptr;
+
+	if (maniptype =3D=3D IP_NAT_MANIP_SRC)
+		keyptr =3D &tuple->src.u.gre.key;
+	else
+		keyptr =3D &tuple->dst.u.gre.key;
+
+	if (!(range->flags & IP_NAT_RANGE_PROTO_SPECIFIED)) {
+		DEBUGP("%p: NATing GRE PPTP\n", conntrack);
+		min =3D 1;
+		range_size =3D 0xffff;
+	} else {
+		min =3D ntohl(range->min.gre.key);
+		range_size =3D ntohl(range->max.gre.key) - min + 1;
+	}
+
+	DEBUGP("min =3D %u, range_size =3D %u\n", min, range_size);=20
+
+	for (i =3D 0; i < range_size; i++, key++) {
+		*keyptr =3D htonl(min + key % range_size);
+		if (!ip_nat_used_tuple(tuple, conntrack))
+			return 1;
+	}
+
+	DEBUGP("%p: no NAT mapping\n", conntrack);
+
+	return 0;
+}
+
+/* manipulate a GRE packet according to maniptype */
+static int
+gre_manip_pkt(struct sk_buff **pskb,
+	      unsigned int iphdroff,
+	      const struct ip_conntrack_tuple *tuple,
+	      enum ip_nat_manip_type maniptype)
+{
+	struct gre_hdr *greh;
+	struct gre_hdr_pptp *pgreh;
+	struct iphdr *iph =3D (struct iphdr *)((*pskb)->data + iphdroff);
+	unsigned int hdroff =3D iphdroff + iph->ihl*4;
+
+	/* pgreh includes two optional 32bit fields which are not required
+	 * to be there.  That's where the magic '8' comes from */
+	if (!skb_make_writable(pskb, hdroff + sizeof(*pgreh)-8))
+		return 0;
+
+	greh =3D (void *)(*pskb)->data + hdroff;
+	pgreh =3D (struct gre_hdr_pptp *) greh;
+
+	/* we only have destination manip of a packet, since 'source key'=20
+	 * is not present in the packet itself */
+	if (maniptype =3D=3D IP_NAT_MANIP_DST) {
+		/* key manipulation is always dest */
+		switch (greh->version) {
+		case 0:
+			if (!greh->key) {
+				DEBUGP("can't nat GRE w/o key\n");
+				break;
+			}
+			if (greh->csum) {
+				/* FIXME: Never tested this code... */
+				*(gre_csum(greh)) =3D=20
+					ip_nat_cheat_check(~*(gre_key(greh)),
+							tuple->dst.u.gre.key,
+							*(gre_csum(greh)));
+			}
+			*(gre_key(greh)) =3D tuple->dst.u.gre.key;
+			break;
+		case GRE_VERSION_PPTP:
+			DEBUGP("call_id -> 0x%04x\n",=20
+				ntohl(tuple->dst.u.gre.key));
+			pgreh->call_id =3D htons(ntohl(tuple->dst.u.gre.key));
+			break;
+		default:
+			DEBUGP("can't nat unknown GRE version\n");
+			return 0;
+			break;
+		}
+	}
+	return 1;
+}
+
+/* print out a nat tuple */
+static unsigned int=20
+gre_print(char *buffer,=20
+	  const struct ip_conntrack_tuple *match,
+	  const struct ip_conntrack_tuple *mask)
+{
+	unsigned int len =3D 0;
+
+	if (mask->src.u.gre.key)
+		len +=3D sprintf(buffer + len, "srckey=3D0x%x ",=20
+				ntohl(match->src.u.gre.key));
+
+	if (mask->dst.u.gre.key)
+		len +=3D sprintf(buffer + len, "dstkey=3D0x%x ",
+				ntohl(match->src.u.gre.key));
+
+	return len;
+}
+
+/* print a range of keys */
+static unsigned int=20
+gre_print_range(char *buffer, const struct ip_nat_range *range)
+{
+	if (range->min.gre.key !=3D 0=20
+	    || range->max.gre.key !=3D 0xFFFF) {
+		if (range->min.gre.key =3D=3D range->max.gre.key)
+			return sprintf(buffer, "key 0x%x ",
+					ntohl(range->min.gre.key));
+		else
+			return sprintf(buffer, "keys 0x%u-0x%u ",
+					ntohl(range->min.gre.key),
+					ntohl(range->max.gre.key));
+	} else
+		return 0;
+}
+
+/* nat helper struct */
+static struct ip_nat_protocol gre =3D {=20
+	.name		=3D "GRE",=20
+	.protonum	=3D IPPROTO_GRE,
+	.manip_pkt	=3D gre_manip_pkt,
+	.in_range	=3D gre_in_range,
+	.unique_tuple	=3D gre_unique_tuple,
+	.print		=3D gre_print,
+	.print_range	=3D gre_print_range,
+#if defined(CONFIG_IP_NF_CONNTRACK_NETLINK) || \
+    defined(CONFIG_IP_NF_CONNTRACK_NETLINK_MODULE)
+	.range_to_nfattr	=3D ip_nat_port_range_to_nfattr,
+	.nfattr_to_range	=3D ip_nat_port_nfattr_to_range,
+#endif
+};
+				 =20
+int __init ip_nat_proto_gre_init(void)
+{
+	if (ip_nat_protocol_register(&gre))
+		return -EIO;
+
+	return 0;
+}
+
+void __exit ip_nat_proto_gre_fini(void)
+{
+	ip_nat_protocol_unregister(&gre);
+}
diff --git a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip=
_nat_standalone.c
--- a/net/ipv4/netfilter/ip_nat_standalone.c
+++ b/net/ipv4/netfilter/ip_nat_standalone.c
@@ -405,4 +405,6 @@ EXPORT_SYMBOL(ip_nat_mangle_tcp_packet);
 EXPORT_SYMBOL(ip_nat_mangle_udp_packet);
 EXPORT_SYMBOL(ip_nat_used_tuple);
 EXPORT_SYMBOL(ip_nat_follow_master);
+EXPORT_SYMBOL_GPL(ip_nat_port_nfattr_to_range);
+EXPORT_SYMBOL_GPL(ip_nat_port_range_to_nfattr);
 MODULE_LICENSE("GPL");
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--YD3LsXFS42OYHhNZ
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDKYsOXaXGVTD0i/8RAjnYAJ42bIJ43D77AZ4zbAi6WiNXlUEk4ACglKlA
EhziouzLhjwod0lzylJ2YjY=
=ipHR
-----END PGP SIGNATURE-----

--YD3LsXFS42OYHhNZ--
