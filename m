From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] Bluetooth: Use hci_conn_hash_lookup_le
Date: Fri, 29 Apr 2016 21:22:39 +0200
Message-ID: <1461957760-753-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the function hci_conn_hash_lookup_le that integrates type testing for
looking up LE connections.  See the patch 1b51c7b6 that introduced this
function for more details.

The semantic patch that (sort of) fixes this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression hdev,addr;
symbol UNKNOWN;
@@

-       hci_conn_hash_lookup_ba(hdev, LE_LINK, addr)
+       hci_conn_hash_lookup_le(hdev, addr, UNKNOWN)
// </smpl>

UNKNOWN has to be replaced by the address type from the usage context.  In
the second case, a subsequent test on the address type is removed also.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---

This was done by analogy with f5ad4ff and from the explanation in
1b51c7b6.  It is not tested, and I don't really know if it is correct.

 net/bluetooth/mgmt.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index 9e4b931..5a61245 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -4773,7 +4773,8 @@ static int get_conn_info(struct sock *sk, struct hci_dev *hdev, void *data,
 		conn = hci_conn_hash_lookup_ba(hdev, ACL_LINK,
 					       &cp->addr.bdaddr);
 	else
-		conn = hci_conn_hash_lookup_ba(hdev, LE_LINK, &cp->addr.bdaddr);
+		conn = hci_conn_hash_lookup_le(hdev, &cp->addr.bdaddr,
+					       cp->addr.type);
 
 	if (!conn || conn->state != BT_CONNECTED) {
 		err = mgmt_cmd_complete(sk, hdev->id, MGMT_OP_GET_CONN_INFO,
@@ -5009,13 +5010,10 @@ static bool is_connected(struct hci_dev *hdev, bdaddr_t *addr, u8 type)
 {
 	struct hci_conn *conn;
 
-	conn = hci_conn_hash_lookup_ba(hdev, LE_LINK, addr);
+	conn = hci_conn_hash_lookup_le(hdev, addr, type);
 	if (!conn)
 		return false;
 
-	if (conn->dst_type != type)
-		return false;
-
 	if (conn->state != BT_CONNECTED)
 		return false;
 
