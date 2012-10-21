From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 4/5] ath6kl/wmi.c: eliminate possible double free
Date: Sun, 21 Oct 2012 12:52:06 +0200
Message-ID: <1350816727-1381-5-git-send-email-Julia.Lawall@lip6.fr>
References: <1350816727-1381-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1350816727-1381-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

This makes two changes.  In ath6kl_wmi_cmd_send, a call to dev_kfree_skb on
the skb argument is added to the initial sanity check to more completely
establish the invariant that ath6kl_wmi_cmd_send owns its skb argument.
Then, in ath6kl_wmi_sync_point, on failure of the call to
ath6kl_wmi_cmd_send, the clearing of the local skb variable is moved up, so
that the error-handling code at the end of the function does not free it
again.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@r@
identifier f,free,a;
parameter list[n] ps;
type T;
expression e;
@@

f(ps,T a,...) {
  ... when any
      when != a = e
  if(...) { ... free(a); ... return ...; }
  ... when any
}

@@
identifier r.f,r.free;
expression x,a;
expression list[r.n] xs;
@@

* x = f(xs,a,...);
  if (...) { ... free(a); ... return ...; }
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
Not tested.

 drivers/net/wireless/ath/ath6kl/wmi.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/wmi.c b/drivers/net/wireless/ath/ath6kl/wmi.c
index c30ab4b..50f50e4 100644
--- a/drivers/net/wireless/ath/ath6kl/wmi.c
+++ b/drivers/net/wireless/ath/ath6kl/wmi.c
@@ -1677,8 +1677,10 @@ int ath6kl_wmi_cmd_send(struct wmi *wmi, u8 if_idx, struct sk_buff *skb,
 	int ret;
 	u16 info1;
 
-	if (WARN_ON(skb == NULL || (if_idx > (wmi->parent_dev->vif_max - 1))))
+	if (WARN_ON(skb == NULL || if_idx > (wmi->parent_dev->vif_max - 1))) {
+		dev_kfree_skb(skb);
 		return -EINVAL;
+	}
 
 	ath6kl_dbg(ATH6KL_DBG_WMI, "wmi tx id %d len %d flag %d\n",
 		   cmd_id, skb->len, sync_flag);
@@ -2348,12 +2350,12 @@ static int ath6kl_wmi_sync_point(struct wmi *wmi, u8 if_idx)
 	ret = ath6kl_wmi_cmd_send(wmi, if_idx, skb, WMI_SYNCHRONIZE_CMDID,
 				  NO_SYNC_WMIFLAG);
 
-	if (ret)
-		goto free_skb;
-
 	/* cmd buffer sent, we no longer own it */
 	skb = NULL;
 
+	if (ret)
+		goto free_skb;
+
 	for (index = 0; index < num_pri_streams; index++) {
 
 		if (WARN_ON(!data_sync_bufs[index].skb))
