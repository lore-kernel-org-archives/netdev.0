From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 07/14] batman-adv: use list_for_each_entry_safe
Date: Fri, 18 Dec 2015 23:33:31 +0800
Message-ID: <b01d3ee936833e94fffa53f7a82fc46e20d877c1.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Antonio Quartulli <a@unstable.cc>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use list_for_each_entry_safe() instead of list_for_each_safe() to
simplify the code.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 net/batman-adv/icmp_socket.c | 22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index bcabb5e..841239c 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -104,25 +104,21 @@ static int batadv_socket_open(struct inode *inode, struct file *file)
 
 static int batadv_socket_release(struct inode *inode, struct file *file)
 {
-	struct batadv_socket_client *socket_client = file->private_data;
-	struct batadv_socket_packet *socket_packet;
-	struct list_head *list_pos, *list_pos_tmp;
+	struct batadv_socket_client *client = file->private_data;
+	struct batadv_socket_packet *packet, *tmp;
 
-	spin_lock_bh(&socket_client->lock);
+	spin_lock_bh(&client->lock);
 
 	/* for all packets in the queue ... */
-	list_for_each_safe(list_pos, list_pos_tmp, &socket_client->queue_list) {
-		socket_packet = list_entry(list_pos,
-					   struct batadv_socket_packet, list);
-
-		list_del(list_pos);
-		kfree(socket_packet);
+	list_for_each_entry_safe(packet, tmp, &client->queue_list, list) {
+		list_del(&packet->list);
+		kfree(packet);
 	}
 
-	batadv_socket_client_hash[socket_client->index] = NULL;
-	spin_unlock_bh(&socket_client->lock);
+	batadv_socket_client_hash[client->index] = NULL;
+	spin_unlock_bh(&client->lock);
 
-	kfree(socket_client);
+	kfree(client);
 	module_put(THIS_MODULE);
 
 	return 0;
-- 
2.5.0
