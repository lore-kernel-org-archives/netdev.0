From: Minho Ban <mhban@samsung.com>
Subject: [RFC/PATCH] Bluetooth: prevent double l2cap_chan_destroy
Date: Mon, 21 May 2012 09:56:40 +0900
Message-ID: <4FB992C8.8090105@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Gustavo Padovan <gustavo@padovan.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

l2cap_sock_kill can be called in l2cap_sock_release and l2cap_sock_close_cb
either. This lead l2cap_chan_destroy to be called twice for same channel.
To prevent double list_del and double chan_put, chan_destroy should be protected
with chan->refcnt and chan_list_lock so that reentrance could be forbidden.

Signed-off-by: Minho Ban <mhban@samsung.com>
---
 net/bluetooth/l2cap_core.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 24f144b..156ca14 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -400,10 +400,14 @@ struct l2cap_chan *l2cap_chan_create(void)
 void l2cap_chan_destroy(struct l2cap_chan *chan)
 {
 	write_lock(&chan_list_lock);
+	/* Check if channel is valid */
+	if (!atomic_read(&chan->refcnt)) {
+		write_unlock(&chan_list_lock);
+		return;
+	}
 	list_del(&chan->global_l);
-	write_unlock(&chan_list_lock);
-
 	l2cap_chan_put(chan);
+	write_unlock(&chan_list_lock);
 }
 
 void l2cap_chan_set_defaults(struct l2cap_chan *chan)
-- 
1.7.5.4
