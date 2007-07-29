From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2.6.23 2/2] iw_cxgb3: Always call low level
	send function via cxgb3_ofld_send().
Date: Sun, 29 Jul 2007 15:12:29 -0500
Message-ID: <20070729201228.31659.26300.stgit@dell3.ogc.int>
References: <20070729201226.31659.85900.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070729201226.31659.85900.stgit@dell3.ogc.int>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


iw_cxgb3: Always call low level send function via cxgb3_ofld_send().

Avoids deadlocks.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_cm.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/h=
w/cxgb3/iwch_cm.c
index fa95dce..20ba372 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -139,7 +139,7 @@ static void release_tid(struct t3cdev *t
 	req->wr.wr_hi =3D htonl(V_WR_OP(FW_WROPCODE_FORWARD));
 	OPCODE_TID(req) =3D htonl(MK_OPCODE_TID(CPL_TID_RELEASE, hwtid));
 	skb->priority =3D CPL_PRIORITY_SETUP;
-	tdev->send(tdev, skb);
+	cxgb3_ofld_send(tdev, skb);
 	return;
 }
=20
@@ -161,7 +161,7 @@ int iwch_quiesce_tid(struct iwch_ep *ep)
 	req->val =3D cpu_to_be64(1 << S_TCB_RX_QUIESCE);
=20
 	skb->priority =3D CPL_PRIORITY_DATA;
-	ep->com.tdev->send(ep->com.tdev, skb);
+	cxgb3_ofld_send(ep->com.tdev, skb);
 	return 0;
 }
=20
@@ -183,7 +183,7 @@ int iwch_resume_tid(struct iwch_ep *ep)
 	req->val =3D 0;
=20
 	skb->priority =3D CPL_PRIORITY_DATA;
-	ep->com.tdev->send(ep->com.tdev, skb);
+	cxgb3_ofld_send(ep->com.tdev, skb);
 	return 0;
 }
=20
@@ -784,7 +784,7 @@ static int update_rx_credits(struct iwch
 	OPCODE_TID(req) =3D htonl(MK_OPCODE_TID(CPL_RX_DATA_ACK, ep->hwtid));
 	req->credit_dack =3D htonl(V_RX_CREDITS(credits) | V_RX_FORCE_ACK(1));
 	skb->priority =3D CPL_PRIORITY_ACK;
-	ep->com.tdev->send(ep->com.tdev, skb);
+	cxgb3_ofld_send(ep->com.tdev, skb);
 	return credits;
 }
=20
@@ -1152,7 +1152,7 @@ static int listen_start(struct iwch_list
 	req->opt1 =3D htonl(V_CONN_POLICY(CPL_CONN_POLICY_ASK));
=20
 	skb->priority =3D 1;
-	ep->com.tdev->send(ep->com.tdev, skb);
+	cxgb3_ofld_send(ep->com.tdev, skb);
 	return 0;
 }
=20
@@ -1186,7 +1186,7 @@ static int listen_stop(struct iwch_liste
 	req->cpu_idx =3D 0;
 	OPCODE_TID(req) =3D htonl(MK_OPCODE_TID(CPL_CLOSE_LISTSRV_REQ, ep->stid=
));
 	skb->priority =3D 1;
-	ep->com.tdev->send(ep->com.tdev, skb);
+	cxgb3_ofld_send(ep->com.tdev, skb);
 	return 0;
 }
=20
@@ -1264,7 +1264,7 @@ static void reject_cr(struct t3cdev *tde
 		rpl->opt0l_status =3D htonl(CPL_PASS_OPEN_REJECT);
 		rpl->opt2 =3D 0;
 		rpl->rsvd =3D rpl->opt2;
-		tdev->send(tdev, skb);
+		cxgb3_ofld_send(tdev, skb);
 	}
 }
=20
@@ -1557,7 +1557,7 @@ static int peer_abort(struct t3cdev *tde
 	rpl->wr.wr_lo =3D htonl(V_WR_TID(ep->hwtid));
 	OPCODE_TID(rpl) =3D htonl(MK_OPCODE_TID(CPL_ABORT_RPL, ep->hwtid));
 	rpl->cmd =3D CPL_ABORT_NO_RST;
-	ep->com.tdev->send(ep->com.tdev, rpl_skb);
+	cxgb3_ofld_send(ep->com.tdev, rpl_skb);
 	if (state !=3D ABORTING) {
 		state_set(&ep->com, DEAD);
 		release_ep_resources(ep);
