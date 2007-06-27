From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 5/6] iw_cxgb3: Don't post TID_RELEASE message.
Date: Wed, 27 Jun 2007 10:51:45 -0500
Message-ID: <20070627155145.24944.64064.stgit@dell3.ogc.int>
References: <20070627155119.24944.44172.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, divy@chelsio.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070627155119.24944.44172.stgit@dell3.ogc.int>
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


iw_cxgb3: Don't post TID_RELEASE message.

The LLD does this for us in cxgb3_remove_tid().

Also fixed active open failure cases where we shouldn't
be releasing the TID as well.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_cm.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/h=
w/cxgb3/iwch_cm.c
index 4d7c277..228721f 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -254,8 +254,6 @@ static void release_ep_resources(struct=20
 	cxgb3_remove_tid(ep->com.tdev, (void *)ep, ep->hwtid);
 	dst_release(ep->dst);
 	l2t_release(L2DATA(ep->com.tdev), ep->l2t);
-	if (ep->com.tdev->type =3D=3D T3B)
-		release_tid(ep->com.tdev, ep->hwtid, NULL);
 	put_ep(&ep->com);
 }
=20
@@ -1103,6 +1101,15 @@ static int abort_rpl(struct t3cdev *tdev
 	return CPL_RET_BUF_DONE;
 }
=20
+/*
+ * Return whether a failed active open has allocated a TID
+ */
+static inline int act_open_has_tid(int status)
+{
+	return status !=3D CPL_ERR_TCAM_FULL && status !=3D CPL_ERR_CONN_EXIST =
&&
+	       status !=3D CPL_ERR_ARP_MISS;
+}
+
 static int act_open_rpl(struct t3cdev *tdev, struct sk_buff *skb, void *=
ctx)
 {
 	struct iwch_ep *ep =3D ctx;
@@ -1112,7 +1119,7 @@ static int act_open_rpl(struct t3cdev *t
 	     status2errno(rpl->status));
 	connect_reply_upcall(ep, status2errno(rpl->status));
 	state_set(&ep->com, DEAD);
-	if (ep->com.tdev->type =3D=3D T3B)
+	if (ep->com.tdev->type =3D=3D T3B && act_open_has_tid(rpl->status))
 		release_tid(ep->com.tdev, GET_TID(rpl), NULL);
 	cxgb3_free_atid(ep->com.tdev, ep->atid);
 	dst_release(ep->dst);
