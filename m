From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 2/6] llc2: Remove dead code for state machine
Date: Sun, 16 Sep 2012 04:11:18 +0100
Message-ID: <1347765078.13258.210.camel@deadeye.wl.decadent.org.uk>
References: <1347764982.13258.207.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-hEzVNgsdFpw45JZmGPhq"
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53018 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750740Ab2IPDLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2012 23:11:24 -0400
In-Reply-To: <1347764982.13258.207.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-hEzVNgsdFpw45JZmGPhq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The initial state is UP and there is no way to enter the other states
as the required event type is never generated.  Delete all states,
event types, and other dead code.  The only thing left is handling
of the XID and TEST commands.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 net/llc/llc_station.c |  404 ++-------------------------------------------=
----
 1 file changed, 9 insertions(+), 395 deletions(-)

diff --git a/net/llc/llc_station.c b/net/llc/llc_station.c
index e16c1b9..917d700 100644
--- a/net/llc/llc_station.c
+++ b/net/llc/llc_station.c
@@ -30,19 +30,12 @@
  *
  * SAP and connection resource manager, one per adapter.
  *
- * @state: state of station
- * @xid_r_count: XID response PDU counter
  * @mac_sa: MAC source address
  * @sap_list: list of related SAPs
  * @ev_q: events entering state mach.
  * @mac_pdu_q: PDUs ready to send to MAC
  */
 struct llc_station {
-	u8			    state;
-	u8			    xid_r_count;
-	struct timer_list	    ack_timer;
-	u8			    retry_count;
-	u8			    maximum_retry;
 	struct {
 		struct sk_buff_head list;
 		spinlock_t	    lock;
@@ -50,162 +43,38 @@ struct llc_station {
 	struct sk_buff_head	    mac_pdu_q;
 };
=20
-#define LLC_STATION_ACK_TIME (3 * HZ)
-
-int sysctl_llc_station_ack_timeout =3D LLC_STATION_ACK_TIME;
-
-/* Types of events (possible values in 'ev->type') */
-#define LLC_STATION_EV_TYPE_SIMPLE	1
-#define LLC_STATION_EV_TYPE_CONDITION	2
-#define LLC_STATION_EV_TYPE_PRIM	3
-#define LLC_STATION_EV_TYPE_PDU		4       /* command/response PDU */
-#define LLC_STATION_EV_TYPE_ACK_TMR	5
-#define LLC_STATION_EV_TYPE_RPT_STATUS	6
-
-/* Events */
-#define LLC_STATION_EV_ENABLE_WITH_DUP_ADDR_CHECK		1
-#define LLC_STATION_EV_ENABLE_WITHOUT_DUP_ADDR_CHECK		2
-#define LLC_STATION_EV_ACK_TMR_EXP_LT_RETRY_CNT_MAX_RETRY	3
-#define LLC_STATION_EV_ACK_TMR_EXP_EQ_RETRY_CNT_MAX_RETRY	4
-#define LLC_STATION_EV_RX_NULL_DSAP_XID_C			5
-#define LLC_STATION_EV_RX_NULL_DSAP_0_XID_R_XID_R_CNT_EQ	6
-#define LLC_STATION_EV_RX_NULL_DSAP_1_XID_R_XID_R_CNT_EQ	7
-#define LLC_STATION_EV_RX_NULL_DSAP_TEST_C			8
-#define LLC_STATION_EV_DISABLE_REQ				9
-
-struct llc_station_state_ev {
-	u8		 type;
-	u8		 prim;
-	u8		 prim_type;
-	u8		 reason;
-	struct list_head node; /* node in station->ev_q.list */
-};
-
-static __inline__ struct llc_station_state_ev *
-					llc_station_ev(struct sk_buff *skb)
-{
-	return (struct llc_station_state_ev *)skb->cb;
-}
-
 typedef int (*llc_station_ev_t)(struct sk_buff *skb);
=20
-#define LLC_STATION_STATE_DOWN		1	/* initial state */
-#define LLC_STATION_STATE_DUP_ADDR_CHK	2
-#define LLC_STATION_STATE_UP		3
-
-#define LLC_NBR_STATION_STATES		3	/* size of state table */
-
 typedef int (*llc_station_action_t)(struct sk_buff *skb);
=20
 /* Station component state table structure */
 struct llc_station_state_trans {
 	llc_station_ev_t ev;
-	u8 next_state;
 	llc_station_action_t *ev_actions;
 };
=20
-struct llc_station_state {
-	u8 curr_state;
-	struct llc_station_state_trans **transitions;
-};
-
 static struct llc_station llc_main_station;
=20
-static int llc_stat_ev_enable_with_dup_addr_check(struct sk_buff *skb)
-{
-	struct llc_station_state_ev *ev =3D llc_station_ev(skb);
-
-	return ev->type =3D=3D LLC_STATION_EV_TYPE_SIMPLE &&
-	       ev->prim_type =3D=3D
-			      LLC_STATION_EV_ENABLE_WITH_DUP_ADDR_CHECK ? 0 : 1;
-}
-
-static int llc_stat_ev_enable_without_dup_addr_check(struct sk_buff *skb)
-{
-	struct llc_station_state_ev *ev =3D llc_station_ev(skb);
-
-	return ev->type =3D=3D LLC_STATION_EV_TYPE_SIMPLE &&
-	       ev->prim_type =3D=3D
-			LLC_STATION_EV_ENABLE_WITHOUT_DUP_ADDR_CHECK ? 0 : 1;
-}
-
-static int llc_stat_ev_ack_tmr_exp_lt_retry_cnt_max_retry(struct sk_buff *=
skb)
-{
-	struct llc_station_state_ev *ev =3D llc_station_ev(skb);
-
-	return ev->type =3D=3D LLC_STATION_EV_TYPE_ACK_TMR &&
-		llc_main_station.retry_count <
-		llc_main_station.maximum_retry ? 0 : 1;
-}
-
-static int llc_stat_ev_ack_tmr_exp_eq_retry_cnt_max_retry(struct sk_buff *=
skb)
-{
-	struct llc_station_state_ev *ev =3D llc_station_ev(skb);
-
-	return ev->type =3D=3D LLC_STATION_EV_TYPE_ACK_TMR &&
-		llc_main_station.retry_count =3D=3D
-		llc_main_station.maximum_retry ? 0 : 1;
-}
-
 static int llc_stat_ev_rx_null_dsap_xid_c(struct sk_buff *skb)
 {
-	struct llc_station_state_ev *ev =3D llc_station_ev(skb);
 	struct llc_pdu_un *pdu =3D llc_pdu_un_hdr(skb);
=20
-	return ev->type =3D=3D LLC_STATION_EV_TYPE_PDU &&
-	       LLC_PDU_IS_CMD(pdu) &&			/* command PDU */
+	return LLC_PDU_IS_CMD(pdu) &&			/* command PDU */
 	       LLC_PDU_TYPE_IS_U(pdu) &&		/* U type PDU */
 	       LLC_U_PDU_CMD(pdu) =3D=3D LLC_1_PDU_CMD_XID &&
 	       !pdu->dsap ? 0 : 1;			/* NULL DSAP value */
 }
=20
-static int llc_stat_ev_rx_null_dsap_0_xid_r_xid_r_cnt_eq(struct sk_buff *s=
kb)
-{
-	struct llc_station_state_ev *ev =3D llc_station_ev(skb);
-	struct llc_pdu_un *pdu =3D llc_pdu_un_hdr(skb);
-
-	return ev->type =3D=3D LLC_STATION_EV_TYPE_PDU &&
-	       LLC_PDU_IS_RSP(pdu) &&			/* response PDU */
-	       LLC_PDU_TYPE_IS_U(pdu) &&		/* U type PDU */
-	       LLC_U_PDU_RSP(pdu) =3D=3D LLC_1_PDU_CMD_XID &&
-	       !pdu->dsap &&				/* NULL DSAP value */
-	       !llc_main_station.xid_r_count ? 0 : 1;
-}
-
-static int llc_stat_ev_rx_null_dsap_1_xid_r_xid_r_cnt_eq(struct sk_buff *s=
kb)
-{
-	struct llc_station_state_ev *ev =3D llc_station_ev(skb);
-	struct llc_pdu_un *pdu =3D llc_pdu_un_hdr(skb);
-
-	return ev->type =3D=3D LLC_STATION_EV_TYPE_PDU &&
-	       LLC_PDU_IS_RSP(pdu) &&			/* response PDU */
-	       LLC_PDU_TYPE_IS_U(pdu) &&		/* U type PDU */
-	       LLC_U_PDU_RSP(pdu) =3D=3D LLC_1_PDU_CMD_XID &&
-	       !pdu->dsap &&				/* NULL DSAP value */
-	       llc_main_station.xid_r_count =3D=3D 1 ? 0 : 1;
-}
-
 static int llc_stat_ev_rx_null_dsap_test_c(struct sk_buff *skb)
 {
-	struct llc_station_state_ev *ev =3D llc_station_ev(skb);
 	struct llc_pdu_un *pdu =3D llc_pdu_un_hdr(skb);
=20
-	return ev->type =3D=3D LLC_STATION_EV_TYPE_PDU &&
-	       LLC_PDU_IS_CMD(pdu) &&			/* command PDU */
+	return LLC_PDU_IS_CMD(pdu) &&			/* command PDU */
 	       LLC_PDU_TYPE_IS_U(pdu) &&		/* U type PDU */
 	       LLC_U_PDU_CMD(pdu) =3D=3D LLC_1_PDU_CMD_TEST &&
 	       !pdu->dsap ? 0 : 1;			/* NULL DSAP */
 }
=20
-static int llc_stat_ev_disable_req(struct sk_buff *skb)
-{
-	struct llc_station_state_ev *ev =3D llc_station_ev(skb);
-
-	return ev->type =3D=3D LLC_STATION_EV_TYPE_PRIM &&
-	       ev->prim =3D=3D LLC_DISABLE_PRIM &&
-	       ev->prim_type =3D=3D LLC_PRIM_TYPE_REQ ? 0 : 1;
-}
-
 /**
  *	llc_station_send_pdu - queues PDU to send
  *	@skb: Address of the PDU
@@ -220,58 +89,6 @@ static void llc_station_send_pdu(struct sk_buff *skb)
 			break;
 }
=20
-static int llc_station_ac_start_ack_timer(struct sk_buff *skb)
-{
-	mod_timer(&llc_main_station.ack_timer,
-		  jiffies + sysctl_llc_station_ack_timeout);
-	return 0;
-}
-
-static int llc_station_ac_set_retry_cnt_0(struct sk_buff *skb)
-{
-	llc_main_station.retry_count =3D 0;
-	return 0;
-}
-
-static int llc_station_ac_inc_retry_cnt_by_1(struct sk_buff *skb)
-{
-	llc_main_station.retry_count++;
-	return 0;
-}
-
-static int llc_station_ac_set_xid_r_cnt_0(struct sk_buff *skb)
-{
-	llc_main_station.xid_r_count =3D 0;
-	return 0;
-}
-
-static int llc_station_ac_inc_xid_r_cnt_by_1(struct sk_buff *skb)
-{
-	llc_main_station.xid_r_count++;
-	return 0;
-}
-
-static int llc_station_ac_send_null_dsap_xid_c(struct sk_buff *skb)
-{
-	int rc =3D 1;
-	struct sk_buff *nskb =3D llc_alloc_frame(NULL, skb->dev, LLC_PDU_TYPE_U,
-					       sizeof(struct llc_xid_info));
-
-	if (!nskb)
-		goto out;
-	llc_pdu_header_init(nskb, LLC_PDU_TYPE_U, 0, 0, LLC_PDU_CMD);
-	llc_pdu_init_as_xid_cmd(nskb, LLC_XID_NULL_CLASS_2, 127);
-	rc =3D llc_mac_hdr_init(nskb, skb->dev->dev_addr, skb->dev->dev_addr);
-	if (unlikely(rc))
-		goto free;
-	llc_station_send_pdu(nskb);
-out:
-	return rc;
-free:
-	kfree_skb(nskb);
-	goto out;
-}
-
 static int llc_station_ac_send_xid_r(struct sk_buff *skb)
 {
 	u8 mac_da[ETH_ALEN], dsap;
@@ -326,60 +143,6 @@ free:
 	goto out;
 }
=20
-static int llc_station_ac_report_status(struct sk_buff *skb)
-{
-	return 0;
-}
-
-/* DOWN STATE transitions */
-
-/* state transition for LLC_STATION_EV_ENABLE_WITH_DUP_ADDR_CHECK event */
-static llc_station_action_t llc_stat_down_state_actions_1[] =3D {
-	[0] =3D llc_station_ac_start_ack_timer,
-	[1] =3D llc_station_ac_set_retry_cnt_0,
-	[2] =3D llc_station_ac_set_xid_r_cnt_0,
-	[3] =3D llc_station_ac_send_null_dsap_xid_c,
-	[4] =3D NULL,
-};
-
-static struct llc_station_state_trans llc_stat_down_state_trans_1 =3D {
-	.ev	    =3D llc_stat_ev_enable_with_dup_addr_check,
-	.next_state =3D LLC_STATION_STATE_DUP_ADDR_CHK,
-	.ev_actions =3D llc_stat_down_state_actions_1,
-};
-
-/* state transition for LLC_STATION_EV_ENABLE_WITHOUT_DUP_ADDR_CHECK event=
 */
-static llc_station_action_t llc_stat_down_state_actions_2[] =3D {
-	[0] =3D llc_station_ac_report_status,	/* STATION UP */
-	[1] =3D NULL,
-};
-
-static struct llc_station_state_trans llc_stat_down_state_trans_2 =3D {
-	.ev	    =3D llc_stat_ev_enable_without_dup_addr_check,
-	.next_state =3D LLC_STATION_STATE_UP,
-	.ev_actions =3D llc_stat_down_state_actions_2,
-};
-
-/* array of pointers; one to each transition */
-static struct llc_station_state_trans *llc_stat_dwn_state_trans[] =3D {
-	[0] =3D &llc_stat_down_state_trans_1,
-	[1] =3D &llc_stat_down_state_trans_2,
-	[2] =3D NULL,
-};
-
-/* UP STATE transitions */
-/* state transition for LLC_STATION_EV_DISABLE_REQ event */
-static llc_station_action_t llc_stat_up_state_actions_1[] =3D {
-	[0] =3D llc_station_ac_report_status,	/* STATION DOWN */
-	[1] =3D NULL,
-};
-
-static struct llc_station_state_trans llc_stat_up_state_trans_1 =3D {
-	.ev	    =3D llc_stat_ev_disable_req,
-	.next_state =3D LLC_STATION_STATE_DOWN,
-	.ev_actions =3D llc_stat_up_state_actions_1,
-};
-
 /* state transition for LLC_STATION_EV_RX_NULL_DSAP_XID_C event */
 static llc_station_action_t llc_stat_up_state_actions_2[] =3D {
 	[0] =3D llc_station_ac_send_xid_r,
@@ -388,7 +151,6 @@ static llc_station_action_t llc_stat_up_state_actions_2=
[] =3D {
=20
 static struct llc_station_state_trans llc_stat_up_state_trans_2 =3D {
 	.ev	    =3D llc_stat_ev_rx_null_dsap_xid_c,
-	.next_state =3D LLC_STATION_STATE_UP,
 	.ev_actions =3D llc_stat_up_state_actions_2,
 };
=20
@@ -400,127 +162,14 @@ static llc_station_action_t llc_stat_up_state_action=
s_3[] =3D {
=20
 static struct llc_station_state_trans llc_stat_up_state_trans_3 =3D {
 	.ev	    =3D llc_stat_ev_rx_null_dsap_test_c,
-	.next_state =3D LLC_STATION_STATE_UP,
 	.ev_actions =3D llc_stat_up_state_actions_3,
 };
=20
 /* array of pointers; one to each transition */
 static struct llc_station_state_trans *llc_stat_up_state_trans [] =3D {
-	[0] =3D &llc_stat_up_state_trans_1,
-	[1] =3D &llc_stat_up_state_trans_2,
-	[2] =3D &llc_stat_up_state_trans_3,
-	[3] =3D NULL,
-};
-
-/* DUP ADDR CHK STATE transitions */
-/* state transition for LLC_STATION_EV_RX_NULL_DSAP_0_XID_R_XID_R_CNT_EQ
- * event
- */
-static llc_station_action_t llc_stat_dupaddr_state_actions_1[] =3D {
-	[0] =3D llc_station_ac_inc_xid_r_cnt_by_1,
-	[1] =3D NULL,
-};
-
-static struct llc_station_state_trans llc_stat_dupaddr_state_trans_1 =3D {
-	.ev	    =3D llc_stat_ev_rx_null_dsap_0_xid_r_xid_r_cnt_eq,
-	.next_state =3D LLC_STATION_STATE_DUP_ADDR_CHK,
-	.ev_actions =3D llc_stat_dupaddr_state_actions_1,
-};
-
-/* state transition for LLC_STATION_EV_RX_NULL_DSAP_1_XID_R_XID_R_CNT_EQ
- * event
- */
-static llc_station_action_t llc_stat_dupaddr_state_actions_2[] =3D {
-	[0] =3D llc_station_ac_report_status,	/* DUPLICATE ADDRESS FOUND */
-	[1] =3D NULL,
-};
-
-static struct llc_station_state_trans llc_stat_dupaddr_state_trans_2 =3D {
-	.ev	    =3D llc_stat_ev_rx_null_dsap_1_xid_r_xid_r_cnt_eq,
-	.next_state =3D LLC_STATION_STATE_DOWN,
-	.ev_actions =3D llc_stat_dupaddr_state_actions_2,
-};
-
-/* state transition for LLC_STATION_EV_RX_NULL_DSAP_XID_C event */
-static llc_station_action_t llc_stat_dupaddr_state_actions_3[] =3D {
-	[0] =3D llc_station_ac_send_xid_r,
-	[1] =3D NULL,
-};
-
-static struct llc_station_state_trans llc_stat_dupaddr_state_trans_3 =3D {
-	.ev	    =3D llc_stat_ev_rx_null_dsap_xid_c,
-	.next_state =3D LLC_STATION_STATE_DUP_ADDR_CHK,
-	.ev_actions =3D llc_stat_dupaddr_state_actions_3,
-};
-
-/* state transition for LLC_STATION_EV_ACK_TMR_EXP_LT_RETRY_CNT_MAX_RETRY
- * event
- */
-static llc_station_action_t llc_stat_dupaddr_state_actions_4[] =3D {
-	[0] =3D llc_station_ac_start_ack_timer,
-	[1] =3D llc_station_ac_inc_retry_cnt_by_1,
-	[2] =3D llc_station_ac_set_xid_r_cnt_0,
-	[3] =3D llc_station_ac_send_null_dsap_xid_c,
-	[4] =3D NULL,
-};
-
-static struct llc_station_state_trans llc_stat_dupaddr_state_trans_4 =3D {
-	.ev	    =3D llc_stat_ev_ack_tmr_exp_lt_retry_cnt_max_retry,
-	.next_state =3D LLC_STATION_STATE_DUP_ADDR_CHK,
-	.ev_actions =3D llc_stat_dupaddr_state_actions_4,
-};
-
-/* state transition for LLC_STATION_EV_ACK_TMR_EXP_EQ_RETRY_CNT_MAX_RETRY
- * event
- */
-static llc_station_action_t llc_stat_dupaddr_state_actions_5[] =3D {
-	[0] =3D llc_station_ac_report_status,	/* STATION UP */
-	[1] =3D NULL,
-};
-
-static struct llc_station_state_trans llc_stat_dupaddr_state_trans_5 =3D {
-	.ev	    =3D llc_stat_ev_ack_tmr_exp_eq_retry_cnt_max_retry,
-	.next_state =3D LLC_STATION_STATE_UP,
-	.ev_actions =3D llc_stat_dupaddr_state_actions_5,
-};
-
-/* state transition for LLC_STATION_EV_DISABLE_REQ event */
-static llc_station_action_t llc_stat_dupaddr_state_actions_6[] =3D {
-	[0] =3D llc_station_ac_report_status,	/* STATION DOWN */
-	[1] =3D NULL,
-};
-
-static struct llc_station_state_trans llc_stat_dupaddr_state_trans_6 =3D {
-	.ev	    =3D llc_stat_ev_disable_req,
-	.next_state =3D LLC_STATION_STATE_DOWN,
-	.ev_actions =3D llc_stat_dupaddr_state_actions_6,
-};
-
-/* array of pointers; one to each transition */
-static struct llc_station_state_trans *llc_stat_dupaddr_state_trans[] =3D =
{
-	[0] =3D &llc_stat_dupaddr_state_trans_6,	/* Request */
-	[1] =3D &llc_stat_dupaddr_state_trans_4,	/* Timer */
-	[2] =3D &llc_stat_dupaddr_state_trans_5,
-	[3] =3D &llc_stat_dupaddr_state_trans_1,	/* Receive frame */
-	[4] =3D &llc_stat_dupaddr_state_trans_2,
-	[5] =3D &llc_stat_dupaddr_state_trans_3,
-	[6] =3D NULL,
-};
-
-static struct llc_station_state
-			llc_station_state_table[LLC_NBR_STATION_STATES] =3D {
-	[LLC_STATION_STATE_DOWN - 1] =3D {
-		.curr_state  =3D LLC_STATION_STATE_DOWN,
-		.transitions =3D llc_stat_dwn_state_trans,
-	},
-	[LLC_STATION_STATE_DUP_ADDR_CHK - 1] =3D {
-		.curr_state  =3D LLC_STATION_STATE_DUP_ADDR_CHK,
-		.transitions =3D llc_stat_dupaddr_state_trans,
-	},
-	[LLC_STATION_STATE_UP - 1] =3D {
-		.curr_state  =3D LLC_STATION_STATE_UP,
-		.transitions =3D llc_stat_up_state_trans,
-	},
+	&llc_stat_up_state_trans_2,
+	&llc_stat_up_state_trans_3,
+	NULL,
 };
=20
 /**
@@ -557,10 +206,8 @@ static struct llc_station_state_trans *
 	int i =3D 0;
 	struct llc_station_state_trans *rc =3D NULL;
 	struct llc_station_state_trans **next_trans;
-	struct llc_station_state *curr_state =3D
-				&llc_station_state_table[llc_main_station.state - 1];
=20
-	for (next_trans =3D curr_state->transitions; next_trans[i]; i++)
+	for (next_trans =3D llc_stat_up_state_trans; next_trans[i]; i++)
 		if (!next_trans[i]->ev(skb)) {
 			rc =3D next_trans[i];
 			break;
@@ -576,10 +223,7 @@ static struct llc_station_state_trans *
  */
 static void llc_station_free_ev(struct sk_buff *skb)
 {
-	struct llc_station_state_ev *ev =3D llc_station_ev(skb);
-
-	if (ev->type =3D=3D LLC_STATION_EV_TYPE_PDU)
-		kfree_skb(skb);
+	kfree_skb(skb);
 }
=20
 /**
@@ -594,26 +238,18 @@ static u16 llc_station_next_state(struct sk_buff *skb=
)
 	u16 rc =3D 1;
 	struct llc_station_state_trans *trans;
=20
-	if (llc_main_station.state > LLC_NBR_STATION_STATES)
-		goto out;
 	trans =3D llc_find_station_trans(skb);
-	if (trans) {
+	if (trans)
 		/* got the state to which we next transition; perform the
 		 * actions associated with this transition before actually
 		 * transitioning to the next state
 		 */
 		rc =3D llc_exec_station_trans_actions(trans, skb);
-		if (!rc)
-			/* transition station to next state if all actions
-			 * execute successfully; done; wait for next event
-			 */
-			llc_main_station.state =3D trans->next_state;
-	} else
+	else
 		/* event not recognized in current state; re-queue it for
 		 * processing again at a later time; return failure
 		 */
 		rc =3D 0;
-out:
 	llc_station_free_ev(skb);
 	return rc;
 }
@@ -652,18 +288,6 @@ static void llc_station_state_process(struct sk_buff *=
skb)
 	spin_unlock_bh(&llc_main_station.ev_q.lock);
 }
=20
-static void llc_station_ack_tmr_cb(unsigned long timeout_data)
-{
-	struct sk_buff *skb =3D alloc_skb(0, GFP_ATOMIC);
-
-	if (skb) {
-		struct llc_station_state_ev *ev =3D llc_station_ev(skb);
-
-		ev->type =3D LLC_STATION_EV_TYPE_ACK_TMR;
-		llc_station_state_process(skb);
-	}
-}
-
 /**
  *	llc_station_rcv - send received pdu to the station state machine
  *	@skb: received frame.
@@ -672,10 +296,6 @@ static void llc_station_ack_tmr_cb(unsigned long timeo=
ut_data)
  */
 static void llc_station_rcv(struct sk_buff *skb)
 {
-	struct llc_station_state_ev *ev =3D llc_station_ev(skb);
-
-	ev->type   =3D LLC_STATION_EV_TYPE_PDU;
-	ev->reason =3D 0;
 	llc_station_state_process(skb);
 }
=20
@@ -684,12 +304,6 @@ void __init llc_station_init(void)
 	skb_queue_head_init(&llc_main_station.mac_pdu_q);
 	skb_queue_head_init(&llc_main_station.ev_q.list);
 	spin_lock_init(&llc_main_station.ev_q.lock);
-	setup_timer(&llc_main_station.ack_timer, llc_station_ack_tmr_cb,
-			(unsigned long)&llc_main_station);
-	llc_main_station.ack_timer.expires  =3D jiffies +
-						sysctl_llc_station_ack_timeout;
-	llc_main_station.maximum_retry	=3D 1;
-	llc_main_station.state		=3D LLC_STATION_STATE_UP;
 	llc_set_station_handler(llc_station_rcv);
 }
=20



--=-hEzVNgsdFpw45JZmGPhq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUFVDVue/yOyVhhEJAQqACg/+LN+dCzqhGndQQeAo0DNWlR3l6HPYP6R3
tzfnu8tXCeXKDxpI79qms0jddrfFypC2RfIaRiX25+kQhqS4j69OtdP9XRFMCCK/
syfXXMeWBPxUVe/NlJZTei8tY2i3G3a8c1zH5JGOw6e0wbeeSj+fgtdcm9GBwzkt
t/2+zWYKVrs6KKbOc7x/1CKZmONkMQ6EjLaVhU+Xf9k85dsWh/03URy2JJmIzrdW
jSmKLhrnB/GEzW16HuytZPQlyLYa7tE6zKygAwzGTbc7GMycTYg+IymXAR8+ECAd
ILQWLNH8lZpzPNVLzKmA+GsdVjYB0u336qCfb0l+AHxG1e7XzJVzGaKS6c1GQ0lm
uSFai6cfN+CBhMe1506b6n0OmBcawVC/WzUXJ47KtegKsssLIGg9FaCDWAT3t5Sl
dQ9GPp35cGL2WV565APwFZAiF5aSF2lDtGVJqqHJjYIkLDc7pz67EksIdNYSB1C8
46L2Zh71QVI6pLosziclfhkKAhiF5XyuSsEM4v0fABQ/hMbuNynDZy8VJktY+nak
xoUsv6Mbv6Cai8SGqgPA0nEXzssp0fc+TkHdVfdbuJstxQP8DmQuQsOjh+VJWZQ5
B/uLnGnRdeAxbAWm/dTvUKvvjDGPKvgCzWGneqgUcNB2osL6qCktjW4GI6S8TUGf
HIrut2ILFmk=
=Am0Y
-----END PGP SIGNATURE-----

--=-hEzVNgsdFpw45JZmGPhq--
