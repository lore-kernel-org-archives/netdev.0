From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/18] netfilter: nf_ct_sctp: minimal multihoming support
Date: Tue,  4 Aug 2015 12:02:45 +0200
Message-ID: <1438682568-8346-16-git-send-email-pablo@netfilter.org>
References: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56084 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933154AbbHDJ5k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 05:57:40 -0400
In-Reply-To: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Michal Kube=C4=8Dek <mkubecek@suse.cz>

Currently nf_conntrack_proto_sctp module handles only packets between
primary addresses used to establish the connection. Any packets between
secondary addresses are classified as invalid so that usual firewall
configurations drop them. Allowing HEARTBEAT and HEARTBEAT-ACK chunks t=
o
establish a new conntrack would allow traffic between secondary
addresses to pass through. A more sophisticated solution based on the
addresses advertised in the initial handshake (and possibly also later
dynamic address addition and removal) would be much harder to implement=
=2E
Moreover, in general we cannot assume to always see the initial
handshake as it can be routed through a different path.

The patch adds two new conntrack states:

  SCTP_CONNTRACK_HEARTBEAT_SENT  - a HEARTBEAT chunk seen but not acked
  SCTP_CONNTRACK_HEARTBEAT_ACKED - a HEARTBEAT acked by HEARTBEAT-ACK

State transition rules:

- HEARTBEAT_SENT responds to usual chunks the same way as NONE (so that
  the behaviour changes as little as possible)
- HEARTBEAT_ACKED responds to usual chunks the same way as ESTABLISHED
  does, except the resulting state is HEARTBEAT_ACKED rather than
  ESTABLISHED
- previously existing states except NONE are preserved when HEARTBEAT o=
r
  HEARTBEAT-ACK is seen
- NONE (in the initial direction) changes to HEARTBEAT_SENT on HEARTBEA=
T
  and to CLOSED on HEARTBEAT-ACK
- HEARTBEAT_SENT changes to HEARTBEAT_ACKED on HEARTBEAT-ACK in the
  reply direction
- HEARTBEAT_SENT and HEARTBEAT_ACKED are preserved on HEARTBEAT and
  HEARTBEAT-ACK otherwise

Normally, vtag is set from the INIT chunk for the reply direction and
from the INIT-ACK chunk for the originating direction (i.e. each of
these defines vtag value for the opposite direction). For secondary
conntracks, we can't rely on seeing INIT/INIT-ACK and even if we have
seen them, we would need to connect two different conntracks. Therefore
simplified logic is applied: vtag of first packet in each direction
(HEARTBEAT in the originating and HEARTBEAT-ACK in reply direction) is
saved and all following packets in that direction are compared with thi=
s
saved value. While INIT and INIT-ACK define vtag for the opposite
direction, vtags extracted from HEARTBEAT and HEARTBEAT-ACK are always
for their direction.

Default timeout values for new states are

  HEARTBEAT_SENT: 30 seconds (default hb_interval)
  HEARTBEAT_ACKED: 210 seconds (hb_interval * path_max_retry + max_rto)

(We cannot expect to see the shutdown sequence so that, unlike
ESTABLISHED, the HEARTBEAT_ACKED timeout shouldn't be too long.)

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_conntrack_sctp.h   |    2 +
 include/uapi/linux/netfilter/nfnetlink_cttimeout.h |    2 +
 net/netfilter/nf_conntrack_proto_sctp.c            |  101 ++++++++++++=
+++-----
 3 files changed, 81 insertions(+), 24 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_conntrack_sctp.h b/include=
/uapi/linux/netfilter/nf_conntrack_sctp.h
index ceeefe6..ed4e776 100644
--- a/include/uapi/linux/netfilter/nf_conntrack_sctp.h
+++ b/include/uapi/linux/netfilter/nf_conntrack_sctp.h
@@ -13,6 +13,8 @@ enum sctp_conntrack {
 	SCTP_CONNTRACK_SHUTDOWN_SENT,
 	SCTP_CONNTRACK_SHUTDOWN_RECD,
 	SCTP_CONNTRACK_SHUTDOWN_ACK_SENT,
+	SCTP_CONNTRACK_HEARTBEAT_SENT,
+	SCTP_CONNTRACK_HEARTBEAT_ACKED,
 	SCTP_CONNTRACK_MAX
 };
=20
diff --git a/include/uapi/linux/netfilter/nfnetlink_cttimeout.h b/inclu=
de/uapi/linux/netfilter/nfnetlink_cttimeout.h
index 1ab0b97..f2c10dc 100644
--- a/include/uapi/linux/netfilter/nfnetlink_cttimeout.h
+++ b/include/uapi/linux/netfilter/nfnetlink_cttimeout.h
@@ -92,6 +92,8 @@ enum ctattr_timeout_sctp {
 	CTA_TIMEOUT_SCTP_SHUTDOWN_SENT,
 	CTA_TIMEOUT_SCTP_SHUTDOWN_RECD,
 	CTA_TIMEOUT_SCTP_SHUTDOWN_ACK_SENT,
+	CTA_TIMEOUT_SCTP_HEARTBEAT_SENT,
+	CTA_TIMEOUT_SCTP_HEARTBEAT_ACKED,
 	__CTA_TIMEOUT_SCTP_MAX
 };
 #define CTA_TIMEOUT_SCTP_MAX (__CTA_TIMEOUT_SCTP_MAX - 1)
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf=
_conntrack_proto_sctp.c
index b45da90..6719773 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -42,6 +42,8 @@ static const char *const sctp_conntrack_names[] =3D {
 	"SHUTDOWN_SENT",
 	"SHUTDOWN_RECD",
 	"SHUTDOWN_ACK_SENT",
+	"HEARTBEAT_SENT",
+	"HEARTBEAT_ACKED",
 };
=20
 #define SECS  * HZ
@@ -57,6 +59,8 @@ static unsigned int sctp_timeouts[SCTP_CONNTRACK_MAX]=
 __read_mostly =3D {
 	[SCTP_CONNTRACK_SHUTDOWN_SENT]		=3D 300 SECS / 1000,
 	[SCTP_CONNTRACK_SHUTDOWN_RECD]		=3D 300 SECS / 1000,
 	[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT]	=3D 3 SECS,
+	[SCTP_CONNTRACK_HEARTBEAT_SENT]		=3D 30 SECS,
+	[SCTP_CONNTRACK_HEARTBEAT_ACKED]	=3D 210 SECS,
 };
=20
 #define sNO SCTP_CONNTRACK_NONE
@@ -67,6 +71,8 @@ static unsigned int sctp_timeouts[SCTP_CONNTRACK_MAX]=
 __read_mostly =3D {
 #define	sSS SCTP_CONNTRACK_SHUTDOWN_SENT
 #define	sSR SCTP_CONNTRACK_SHUTDOWN_RECD
 #define	sSA SCTP_CONNTRACK_SHUTDOWN_ACK_SENT
+#define	sHS SCTP_CONNTRACK_HEARTBEAT_SENT
+#define	sHA SCTP_CONNTRACK_HEARTBEAT_ACKED
 #define	sIV SCTP_CONNTRACK_MAX
=20
 /*
@@ -88,6 +94,10 @@ SHUTDOWN_ACK_SENT - We have seen a SHUTDOWN_ACK chun=
k in the direction opposite
 		    to that of the SHUTDOWN chunk.
 CLOSED            - We have seen a SHUTDOWN_COMPLETE chunk in the dire=
ction of
 		    the SHUTDOWN chunk. Connection is closed.
+HEARTBEAT_SENT    - We have seen a HEARTBEAT in a new flow.
+HEARTBEAT_ACKED   - We have seen a HEARTBEAT-ACK in the direction oppo=
site to
+		    that of the HEARTBEAT chunk. Secondary connection is
+		    established.
 */
=20
 /* TODO
@@ -97,36 +107,40 @@ CLOSED            - We have seen a SHUTDOWN_COMPLE=
TE chunk in the direction of
  - Check the error type in the reply dir before transitioning from
 cookie echoed to closed.
  - Sec 5.2.4 of RFC 2960
- - Multi Homing support.
+ - Full Multi Homing support.
 */
=20
 /* SCTP conntrack state transitions */
-static const u8 sctp_conntracks[2][9][SCTP_CONNTRACK_MAX] =3D {
+static const u8 sctp_conntracks[2][11][SCTP_CONNTRACK_MAX] =3D {
 	{
 /*	ORIGINAL	*/
-/*                  sNO, sCL, sCW, sCE, sES, sSS, sSR, sSA */
-/* init         */ {sCW, sCW, sCW, sCE, sES, sSS, sSR, sSA},
-/* init_ack     */ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA},
-/* abort        */ {sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL},
-/* shutdown     */ {sCL, sCL, sCW, sCE, sSS, sSS, sSR, sSA},
-/* shutdown_ack */ {sSA, sCL, sCW, sCE, sES, sSA, sSA, sSA},
-/* error        */ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA},/* Can't h=
ave Stale cookie*/
-/* cookie_echo  */ {sCL, sCL, sCE, sCE, sES, sSS, sSR, sSA},/* 5.2.4 -=
 Big TODO */
-/* cookie_ack   */ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA},/* Can't c=
ome in orig dir */
-/* shutdown_comp*/ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sCL}
+/*                  sNO, sCL, sCW, sCE, sES, sSS, sSR, sSA, sHS, sHA *=
/
+/* init         */ {sCW, sCW, sCW, sCE, sES, sSS, sSR, sSA, sCW, sHA},
+/* init_ack     */ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA, sCL, sHA},
+/* abort        */ {sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL},
+/* shutdown     */ {sCL, sCL, sCW, sCE, sSS, sSS, sSR, sSA, sCL, sSS},
+/* shutdown_ack */ {sSA, sCL, sCW, sCE, sES, sSA, sSA, sSA, sSA, sHA},
+/* error        */ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA, sCL, sHA},=
/* Can't have Stale cookie*/
+/* cookie_echo  */ {sCL, sCL, sCE, sCE, sES, sSS, sSR, sSA, sCL, sHA},=
/* 5.2.4 - Big TODO */
+/* cookie_ack   */ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA, sCL, sHA},=
/* Can't come in orig dir */
+/* shutdown_comp*/ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sCL, sCL, sHA},
+/* heartbeat    */ {sHS, sCL, sCW, sCE, sES, sSS, sSR, sSA, sHS, sHA},
+/* heartbeat_ack*/ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA, sHS, sHA}
 	},
 	{
 /*	REPLY	*/
-/*                  sNO, sCL, sCW, sCE, sES, sSS, sSR, sSA */
-/* init         */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA},/* INIT in=
 sCL Big TODO */
-/* init_ack     */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA},
-/* abort        */ {sIV, sCL, sCL, sCL, sCL, sCL, sCL, sCL},
-/* shutdown     */ {sIV, sCL, sCW, sCE, sSR, sSS, sSR, sSA},
-/* shutdown_ack */ {sIV, sCL, sCW, sCE, sES, sSA, sSA, sSA},
-/* error        */ {sIV, sCL, sCW, sCL, sES, sSS, sSR, sSA},
-/* cookie_echo  */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA},/* Can't c=
ome in reply dir */
-/* cookie_ack   */ {sIV, sCL, sCW, sES, sES, sSS, sSR, sSA},
-/* shutdown_comp*/ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sCL}
+/*                  sNO, sCL, sCW, sCE, sES, sSS, sSR, sSA, sHS, sHA *=
/
+/* init         */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA, sIV, sHA},=
/* INIT in sCL Big TODO */
+/* init_ack     */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA, sIV, sHA},
+/* abort        */ {sIV, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sIV, sCL},
+/* shutdown     */ {sIV, sCL, sCW, sCE, sSR, sSS, sSR, sSA, sIV, sSR},
+/* shutdown_ack */ {sIV, sCL, sCW, sCE, sES, sSA, sSA, sSA, sIV, sHA},
+/* error        */ {sIV, sCL, sCW, sCL, sES, sSS, sSR, sSA, sIV, sHA},
+/* cookie_echo  */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA, sIV, sHA},=
/* Can't come in reply dir */
+/* cookie_ack   */ {sIV, sCL, sCW, sES, sES, sSS, sSR, sSA, sIV, sHA},
+/* shutdown_comp*/ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sCL, sIV, sHA},
+/* heartbeat    */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA, sHS, sHA},
+/* heartbeat_ack*/ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA, sHA, sHA}
 	}
 };
=20
@@ -278,9 +292,16 @@ static int sctp_new_state(enum ip_conntrack_dir di=
r,
 		pr_debug("SCTP_CID_SHUTDOWN_COMPLETE\n");
 		i =3D 8;
 		break;
+	case SCTP_CID_HEARTBEAT:
+		pr_debug("SCTP_CID_HEARTBEAT");
+		i =3D 9;
+		break;
+	case SCTP_CID_HEARTBEAT_ACK:
+		pr_debug("SCTP_CID_HEARTBEAT_ACK");
+		i =3D 10;
+		break;
 	default:
-		/* Other chunks like DATA, SACK, HEARTBEAT and
-		its ACK do not cause a change in state */
+		/* Other chunks like DATA or SACK do not change the state */
 		pr_debug("Unknown chunk type, Will stay in %s\n",
 			 sctp_conntrack_names[cur_state]);
 		return cur_state;
@@ -329,6 +350,8 @@ static int sctp_packet(struct nf_conn *ct,
 	    !test_bit(SCTP_CID_COOKIE_ECHO, map) &&
 	    !test_bit(SCTP_CID_ABORT, map) &&
 	    !test_bit(SCTP_CID_SHUTDOWN_ACK, map) &&
+	    !test_bit(SCTP_CID_HEARTBEAT, map) &&
+	    !test_bit(SCTP_CID_HEARTBEAT_ACK, map) &&
 	    sh->vtag !=3D ct->proto.sctp.vtag[dir]) {
 		pr_debug("Verification tag check failed\n");
 		goto out;
@@ -357,6 +380,16 @@ static int sctp_packet(struct nf_conn *ct,
 			/* Sec 8.5.1 (D) */
 			if (sh->vtag !=3D ct->proto.sctp.vtag[dir])
 				goto out_unlock;
+		} else if (sch->type =3D=3D SCTP_CID_HEARTBEAT ||
+			   sch->type =3D=3D SCTP_CID_HEARTBEAT_ACK) {
+			if (ct->proto.sctp.vtag[dir] =3D=3D 0) {
+				pr_debug("Setting vtag %x for dir %d\n",
+					 sh->vtag, dir);
+				ct->proto.sctp.vtag[dir] =3D sh->vtag;
+			} else if (sh->vtag !=3D ct->proto.sctp.vtag[dir]) {
+				pr_debug("Verification tag check failed\n");
+				goto out_unlock;
+			}
 		}
=20
 		old_state =3D ct->proto.sctp.state;
@@ -466,6 +499,10 @@ static bool sctp_new(struct nf_conn *ct, const str=
uct sk_buff *skb,
 				/* Sec 8.5.1 (A) */
 				return false;
 			}
+		} else if (sch->type =3D=3D SCTP_CID_HEARTBEAT) {
+			pr_debug("Setting vtag %x for secondary conntrack\n",
+				 sh->vtag);
+			ct->proto.sctp.vtag[IP_CT_DIR_ORIGINAL] =3D sh->vtag;
 		}
 		/* If it is a shutdown ack OOTB packet, we expect a return
 		   shutdown complete, otherwise an ABORT Sec 8.4 (5) and (8) */
@@ -610,6 +647,8 @@ sctp_timeout_nla_policy[CTA_TIMEOUT_SCTP_MAX+1] =3D=
 {
 	[CTA_TIMEOUT_SCTP_SHUTDOWN_SENT]	=3D { .type =3D NLA_U32 },
 	[CTA_TIMEOUT_SCTP_SHUTDOWN_RECD]	=3D { .type =3D NLA_U32 },
 	[CTA_TIMEOUT_SCTP_SHUTDOWN_ACK_SENT]	=3D { .type =3D NLA_U32 },
+	[CTA_TIMEOUT_SCTP_HEARTBEAT_SENT]	=3D { .type =3D NLA_U32 },
+	[CTA_TIMEOUT_SCTP_HEARTBEAT_ACKED]	=3D { .type =3D NLA_U32 },
 };
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
=20
@@ -658,6 +697,18 @@ static struct ctl_table sctp_sysctl_table[] =3D {
 		.mode		=3D 0644,
 		.proc_handler	=3D proc_dointvec_jiffies,
 	},
+	{
+		.procname	=3D "nf_conntrack_sctp_timeout_heartbeat_sent",
+		.maxlen		=3D sizeof(unsigned int),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec_jiffies,
+	},
+	{
+		.procname	=3D "nf_conntrack_sctp_timeout_heartbeat_acked",
+		.maxlen		=3D sizeof(unsigned int),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec_jiffies,
+	},
 	{ }
 };
=20
@@ -730,6 +781,8 @@ static int sctp_kmemdup_sysctl_table(struct nf_prot=
o_net *pn,
 	pn->ctl_table[4].data =3D &sn->timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT]=
;
 	pn->ctl_table[5].data =3D &sn->timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD]=
;
 	pn->ctl_table[6].data =3D &sn->timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_S=
ENT];
+	pn->ctl_table[7].data =3D &sn->timeouts[SCTP_CONNTRACK_HEARTBEAT_SENT=
];
+	pn->ctl_table[8].data =3D &sn->timeouts[SCTP_CONNTRACK_HEARTBEAT_ACKE=
D];
 #endif
 	return 0;
 }
--=20
1.7.10.4
