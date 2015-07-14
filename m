From: Michal Kubecek <mkubecek-AlSwsSmVLrQ@public.gmane.org>
Subject: [PATCH nf-next] netfilter: nf_ct_sctp: minimal multihoming support
Date: Tue, 14 Jul 2015 14:23:11 +0200 (CEST)
Message-ID: <20150714122311.8DA8EA0C9A@unicorn.suse.cz>
Cc: coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Jozsef Kadlecsik <kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Currently nf_conntrack_proto_sctp module handles only packets between
primary addresses used to establish the connection. Any packets between
secondary addresses are classified as invalid so that usual firewall
configurations drop them. Allowing HEARTBEAT and HEARTBEAT-ACK chunks to
establish a new conntrack would allow traffic between secondary
addresses to pass through. A more sophisticated solution based on the
addresses advertised in the initial handshake (and possibly also later
dynamic address addition and removal) would be much harder to implement.
Moreover, in general we cannot assume to always see the initial
handshake as it can be routed through a different path.

The patch adds two new conntrack states:

  SCTP_CONNTRACK_HB_SENT  - a HEARTBEAT chunk seen but not acked
  SCTP_CONNTRACK_HB_ACKED - a HEARTBEAT acked by HEARTBEAT-ACK

State transition rules:

- HB_SENT responds to usual chunks the same way as NONE (so that the
  behaviour changes as little as possible)
- HB_ACKED responds to usual chunks the same way as ESTABLISHED does,
  except the resulting state is HB_ACKED rather than ESTABLISHED
- previously existing states except NONE are preserved when HEARTBEAT or
  HEARTBEAT-ACK is seen
- NONE (in the initial direction) changes to HB_SENT on HEARTBEAT
  and to CLOSED on HEARTBEAT-ACK
- HB_SENT changes to HB_ACKED on HEARTBEAT-ACK in the reply direction
- HB_SENT and HB_ACKED are preserved on HEARTBEAT/HEARTBEAT-ACK
  otherwise

Default timeout values for new states are

  HB_SENT: 30 seconds (default hb_interval)
  HB_ACKED: 210 seconds (hb_interval * path_max_retry + max_rto)

(We cannot expect to see the shutdown sequence so that the HB_ACKED
timeout shouldn't be too long.)

Signed-off-by: Michal Kubecek <mkubecek-AlSwsSmVLrQ@public.gmane.org>
---
 include/uapi/linux/netfilter/nf_conntrack_sctp.h |   2 +
 net/netfilter/nf_conntrack_proto_sctp.c          | 110 ++++++++++++++++++-----
 2 files changed, 90 insertions(+), 22 deletions(-)

diff --git a/include/uapi/linux/netfilter/nf_conntrack_sctp.h b/include/uapi/linux/netfilter/nf_conntrack_sctp.h
index ceeefe6681b5..3ec7a6082457 100644
--- a/include/uapi/linux/netfilter/nf_conntrack_sctp.h
+++ b/include/uapi/linux/netfilter/nf_conntrack_sctp.h
@@ -13,6 +13,8 @@ enum sctp_conntrack {
 	SCTP_CONNTRACK_SHUTDOWN_SENT,
 	SCTP_CONNTRACK_SHUTDOWN_RECD,
 	SCTP_CONNTRACK_SHUTDOWN_ACK_SENT,
+	SCTP_CONNTRACK_HB_SENT,
+	SCTP_CONNTRACK_HB_ACKED,
 	SCTP_CONNTRACK_MAX
 };
 
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index b45da90fad32..efb6d5b16393 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -42,6 +42,8 @@ static const char *const sctp_conntrack_names[] = {
 	"SHUTDOWN_SENT",
 	"SHUTDOWN_RECD",
 	"SHUTDOWN_ACK_SENT",
+	"HEARTBEAT_SENT",
+	"HEARTBEAT_ACKED",
 };
 
 #define SECS  * HZ
@@ -57,6 +59,8 @@ static unsigned int sctp_timeouts[SCTP_CONNTRACK_MAX] __read_mostly = {
 	[SCTP_CONNTRACK_SHUTDOWN_SENT]		= 300 SECS / 1000,
 	[SCTP_CONNTRACK_SHUTDOWN_RECD]		= 300 SECS / 1000,
 	[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT]	= 3 SECS,
+	[SCTP_CONNTRACK_HB_SENT]		= 30 SECS,
+	[SCTP_CONNTRACK_HB_ACKED]		= 210 SECS,
 };
 
 #define sNO SCTP_CONNTRACK_NONE
@@ -67,6 +71,8 @@ static unsigned int sctp_timeouts[SCTP_CONNTRACK_MAX] __read_mostly = {
 #define	sSS SCTP_CONNTRACK_SHUTDOWN_SENT
 #define	sSR SCTP_CONNTRACK_SHUTDOWN_RECD
 #define	sSA SCTP_CONNTRACK_SHUTDOWN_ACK_SENT
+#define	sHS SCTP_CONNTRACK_HB_SENT
+#define	sHA SCTP_CONNTRACK_HB_ACKED
 #define	sIV SCTP_CONNTRACK_MAX
 
 /*
@@ -88,6 +94,10 @@ SHUTDOWN_ACK_SENT - We have seen a SHUTDOWN_ACK chunk in the direction opposite
 		    to that of the SHUTDOWN chunk.
 CLOSED            - We have seen a SHUTDOWN_COMPLETE chunk in the direction of
 		    the SHUTDOWN chunk. Connection is closed.
+HEARTBEAT_SENT    - We have seen a HEARTBEAT in a new flow.
+HEARTBEAT_ACKED   - We have seen a HEARTBEAT-ACK in the direction opposite to
+		    that of the HEARTBEAT chunk. Secondary connection is
+		    established.
 */
 
 /* TODO
@@ -97,36 +107,40 @@ CLOSED            - We have seen a SHUTDOWN_COMPLETE chunk in the direction of
  - Check the error type in the reply dir before transitioning from
 cookie echoed to closed.
  - Sec 5.2.4 of RFC 2960
- - Multi Homing support.
+ - Full Multi Homing support.
 */
 
 /* SCTP conntrack state transitions */
-static const u8 sctp_conntracks[2][9][SCTP_CONNTRACK_MAX] = {
+static const u8 sctp_conntracks[2][11][SCTP_CONNTRACK_MAX] = {
 	{
 /*	ORIGINAL	*/
-/*                  sNO, sCL, sCW, sCE, sES, sSS, sSR, sSA */
-/* init         */ {sCW, sCW, sCW, sCE, sES, sSS, sSR, sSA},
-/* init_ack     */ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA},
-/* abort        */ {sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL},
-/* shutdown     */ {sCL, sCL, sCW, sCE, sSS, sSS, sSR, sSA},
-/* shutdown_ack */ {sSA, sCL, sCW, sCE, sES, sSA, sSA, sSA},
-/* error        */ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA},/* Can't have Stale cookie*/
-/* cookie_echo  */ {sCL, sCL, sCE, sCE, sES, sSS, sSR, sSA},/* 5.2.4 - Big TODO */
-/* cookie_ack   */ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA},/* Can't come in orig dir */
-/* shutdown_comp*/ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sCL}
+/*                  sNO, sCL, sCW, sCE, sES, sSS, sSR, sSA, sHS, sHA */
+/* init         */ {sCW, sCW, sCW, sCE, sES, sSS, sSR, sSA, sCW, sHA},
+/* init_ack     */ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA, sCL, sHA},
+/* abort        */ {sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL},
+/* shutdown     */ {sCL, sCL, sCW, sCE, sSS, sSS, sSR, sSA, sCL, sSS},
+/* shutdown_ack */ {sSA, sCL, sCW, sCE, sES, sSA, sSA, sSA, sSA, sHA},
+/* error        */ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA, sCL, sHA},/* Can't have Stale cookie*/
+/* cookie_echo  */ {sCL, sCL, sCE, sCE, sES, sSS, sSR, sSA, sCL, sHA},/* 5.2.4 - Big TODO */
+/* cookie_ack   */ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA, sCL, sHA},/* Can't come in orig dir */
+/* shutdown_comp*/ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sCL, sCL, sHA},
+/* heartbeat    */ {sHS, sCL, sCW, sCE, sES, sSS, sSR, sSA, sHS, sHA},
+/* heartbeat_ack*/ {sCL, sCL, sCW, sCE, sES, sSS, sSR, sSA, sHS, sHA}
 	},
 	{
 /*	REPLY	*/
-/*                  sNO, sCL, sCW, sCE, sES, sSS, sSR, sSA */
-/* init         */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA},/* INIT in sCL Big TODO */
-/* init_ack     */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA},
-/* abort        */ {sIV, sCL, sCL, sCL, sCL, sCL, sCL, sCL},
-/* shutdown     */ {sIV, sCL, sCW, sCE, sSR, sSS, sSR, sSA},
-/* shutdown_ack */ {sIV, sCL, sCW, sCE, sES, sSA, sSA, sSA},
-/* error        */ {sIV, sCL, sCW, sCL, sES, sSS, sSR, sSA},
-/* cookie_echo  */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA},/* Can't come in reply dir */
-/* cookie_ack   */ {sIV, sCL, sCW, sES, sES, sSS, sSR, sSA},
-/* shutdown_comp*/ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sCL}
+/*                  sNO, sCL, sCW, sCE, sES, sSS, sSR, sSA, sHS, sHA */
+/* init         */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA, sIV, sHA},/* INIT in sCL Big TODO */
+/* init_ack     */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA, sIV, sHA},
+/* abort        */ {sIV, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sIV, sCL},
+/* shutdown     */ {sIV, sCL, sCW, sCE, sSR, sSS, sSR, sSA, sIV, sSR},
+/* shutdown_ack */ {sIV, sCL, sCW, sCE, sES, sSA, sSA, sSA, sIV, sHA},
+/* error        */ {sIV, sCL, sCW, sCL, sES, sSS, sSR, sSA, sIV, sHA},
+/* cookie_echo  */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA, sIV, sHA},/* Can't come in reply dir */
+/* cookie_ack   */ {sIV, sCL, sCW, sES, sES, sSS, sSR, sSA, sIV, sHA},
+/* shutdown_comp*/ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sCL, sIV, sHA},
+/* heartbeat    */ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA, sHS, sHA},
+/* heartbeat_ack*/ {sIV, sCL, sCW, sCE, sES, sSS, sSR, sSA, sHA, sHA}
 	}
 };
 
@@ -278,6 +292,14 @@ static int sctp_new_state(enum ip_conntrack_dir dir,
 		pr_debug("SCTP_CID_SHUTDOWN_COMPLETE\n");
 		i = 8;
 		break;
+	case SCTP_CID_HEARTBEAT:
+		pr_debug("SCTP_CID_HEARTBEAT");
+		i = 9;
+		break;
+	case SCTP_CID_HEARTBEAT_ACK:
+		pr_debug("SCTP_CID_HEARTBEAT_ACK");
+		i = 10;
+		break;
 	default:
 		/* Other chunks like DATA, SACK, HEARTBEAT and
 		its ACK do not cause a change in state */
@@ -329,6 +351,8 @@ static int sctp_packet(struct nf_conn *ct,
 	    !test_bit(SCTP_CID_COOKIE_ECHO, map) &&
 	    !test_bit(SCTP_CID_ABORT, map) &&
 	    !test_bit(SCTP_CID_SHUTDOWN_ACK, map) &&
+	    !test_bit(SCTP_CID_HEARTBEAT, map) &&
+	    !test_bit(SCTP_CID_HEARTBEAT_ACK, map) &&
 	    sh->vtag != ct->proto.sctp.vtag[dir]) {
 		pr_debug("Verification tag check failed\n");
 		goto out;
@@ -357,6 +381,16 @@ static int sctp_packet(struct nf_conn *ct,
 			/* Sec 8.5.1 (D) */
 			if (sh->vtag != ct->proto.sctp.vtag[dir])
 				goto out_unlock;
+		} else if (sch->type == SCTP_CID_HEARTBEAT ||
+			   sch->type == SCTP_CID_HEARTBEAT_ACK) {
+			if (ct->proto.sctp.vtag[dir] == 0) {
+				pr_debug("Setting vtag %x for dir %d\n",
+					 sh->vtag, dir);
+				ct->proto.sctp.vtag[dir] = sh->vtag;
+			} else if (sh->vtag != ct->proto.sctp.vtag[dir]) {
+				pr_debug("Verification tag check failed\n");
+				goto out_unlock;
+			}
 		}
 
 		old_state = ct->proto.sctp.state;
@@ -466,6 +500,10 @@ static bool sctp_new(struct nf_conn *ct, const struct sk_buff *skb,
 				/* Sec 8.5.1 (A) */
 				return false;
 			}
+		} else if (sch->type == SCTP_CID_HEARTBEAT) {
+			pr_debug("Setting vtag %x for secondary conntrack\n",
+				 sh->vtag);
+			ct->proto.sctp.vtag[IP_CT_DIR_ORIGINAL] = sh->vtag;
 		}
 		/* If it is a shutdown ack OOTB packet, we expect a return
 		   shutdown complete, otherwise an ABORT Sec 8.4 (5) and (8) */
@@ -658,6 +696,18 @@ static struct ctl_table sctp_sysctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
+	{
+		.procname	= "nf_conntrack_sctp_timeout_heartbeat_sent",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "nf_conntrack_sctp_timeout_heartbeat_acked",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
 	{ }
 };
 
@@ -705,6 +755,18 @@ static struct ctl_table sctp_compat_sysctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
+	{
+		.procname	= "ip_conntrack_sctp_timeout_heartbeat_sent",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "ip_conntrack_sctp_timeout_heartbeat_acked",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
 	{ }
 };
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
@@ -730,6 +792,8 @@ static int sctp_kmemdup_sysctl_table(struct nf_proto_net *pn,
 	pn->ctl_table[4].data = &sn->timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT];
 	pn->ctl_table[5].data = &sn->timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD];
 	pn->ctl_table[6].data = &sn->timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT];
+	pn->ctl_table[7].data = &sn->timeouts[SCTP_CONNTRACK_HB_SENT];
+	pn->ctl_table[8].data = &sn->timeouts[SCTP_CONNTRACK_HB_ACKED];
 #endif
 	return 0;
 }
@@ -752,6 +816,8 @@ static int sctp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn,
 	pn->ctl_compat_table[4].data = &sn->timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT];
 	pn->ctl_compat_table[5].data = &sn->timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD];
 	pn->ctl_compat_table[6].data = &sn->timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT];
+	pn->ctl_compat_table[7].data = &sn->timeouts[SCTP_CONNTRACK_HB_SENT];
+	pn->ctl_compat_table[8].data = &sn->timeouts[SCTP_CONNTRACK_HB_ACKED];
 #endif
 #endif
 	return 0;
-- 
2.4.5
