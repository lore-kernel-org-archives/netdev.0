From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [PATCH] net: bluetooth: fix locking problem
Date: Mon, 17 Jan 2011 13:08:37 +0300
Message-ID: <1295258917-31092-1-git-send-email-segoon@openwall.com>
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If alloc_skb() failed we still hold hci_dev_list_lock.  The code should
unlock it before exit.

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
---
 Compile tested only.

 net/bluetooth/mgmt.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index f827fd9..ace8726 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -111,8 +111,10 @@ static int read_index_list(struct sock *sk)
 
 	body_len = sizeof(*ev) + sizeof(*rp) + (2 * count);
 	skb = alloc_skb(sizeof(*hdr) + body_len, GFP_ATOMIC);
-	if (!skb)
+	if (!skb) {
+		read_unlock(&hci_dev_list_lock);
 		return -ENOMEM;
+	}
 
 	hdr = (void *) skb_put(skb, sizeof(*hdr));
 	hdr->opcode = cpu_to_le16(MGMT_EV_CMD_COMPLETE);
-- 
1.7.0.4
