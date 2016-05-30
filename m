From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] qed: fix qed_fill_link() error handling
Date: Mon, 30 May 2016 17:46:12 +0200
Message-ID: <1464623197-2084229-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	everest-linux-l2@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc warns about qed_fill_link possibly accessing uninitialized data:

drivers/net/ethernet/qlogic/qed/qed_main.c: In function 'qed_fill_link':
drivers/net/ethernet/qlogic/qed/qed_main.c:1170:35: error: 'link_caps' may be used uninitialized in this function [-Werror=maybe-uninitialized]

While this warning is only about the specific case of CONFIG_QED_SRIOV
being disabled but the function getting called for a VF (which should
never happen), another possibility is that qed_mcp_get_*() fails without
returning data.

This rearranges the code so we bail out in either of the two cases
and print a warning instead of accessing the uninitialized data.

The qed_link_output structure remains untouched in this case, but
all callers first call memset() on it, so at least we are not leaking
stack data then.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/qlogic/qed/qed_main.c | 45 ++++++++++++++++++++++++------
 1 file changed, 36 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 753064679bde..68f87a4f9316 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -1105,6 +1105,39 @@ static int qed_get_port_type(u32 media_type)
 	return port_type;
 }
 
+static int qed_get_link_data(struct qed_hwfn *hwfn,
+			     struct qed_mcp_link_params *params,
+			     struct qed_mcp_link_state *link,
+			     struct qed_mcp_link_capabilities *link_caps)
+{
+	void *p;
+
+	if (IS_ENABLED(CONFIG_QED_SRIOV) && !IS_PF(hwfn->cdev)) {
+		qed_vf_get_link_params(hwfn, params);
+		qed_vf_get_link_state(hwfn, link);
+		qed_vf_get_link_caps(hwfn, link_caps);
+
+		return 0;
+	}
+
+	p = qed_mcp_get_link_params(hwfn);
+	if (!p)
+		return -ENXIO;
+	memcpy(params, p, sizeof(*params));
+
+	p = qed_mcp_get_link_state(hwfn);
+	if (!p)
+		return -ENXIO;
+	memcpy(link, p, sizeof(*link));
+
+	p = qed_mcp_get_link_capabilities(hwfn);
+	if (!p)
+		return -ENXIO;
+	memcpy(link_caps, p, sizeof(*link_caps));
+
+	return 0;
+}
+
 static void qed_fill_link(struct qed_hwfn *hwfn,
 			  struct qed_link_output *if_link)
 {
@@ -1116,15 +1149,9 @@ static void qed_fill_link(struct qed_hwfn *hwfn,
 	memset(if_link, 0, sizeof(*if_link));
 
 	/* Prepare source inputs */
-	if (IS_PF(hwfn->cdev)) {
-		memcpy(&params, qed_mcp_get_link_params(hwfn), sizeof(params));
-		memcpy(&link, qed_mcp_get_link_state(hwfn), sizeof(link));
-		memcpy(&link_caps, qed_mcp_get_link_capabilities(hwfn),
-		       sizeof(link_caps));
-	} else {
-		qed_vf_get_link_params(hwfn, &params);
-		qed_vf_get_link_state(hwfn, &link);
-		qed_vf_get_link_caps(hwfn, &link_caps);
+	if (qed_get_link_data(hwfn, &params, &link, &link_caps)) {
+		dev_warn(&hwfn->cdev->pdev->dev, "no link data available\n");
+		return;
 	}
 
 	/* Set the link parameters to pass to protocol driver */
-- 
2.7.0
