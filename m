From: Harish Jenny K N <harish_kandiga@mentor.com>
Subject: [PATCH] Bluetooth: Fix use after free in l2cap_chan_timeout
Date: Thu, 19 Mar 2015 13:49:51 +0530
Message-ID: <1426753191-9468-1-git-send-email-harish_kandiga@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <gustavo@padovan.org>, <johan.hedberg@gmail.com>,
	<davem@davemloft.net>, <linux-bluetooth@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<harish_kandiga@mentor.com>
To: <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a potential use after free in bt_sock_poll when a
socket gets killed without getting unlinked from accept_q.
Hence added code to unlink from accpept_q by calling teardown
before freeing the socket for channel type L2CAP_CHAN_CONN_ORIENTED.

Signed-off-by: Harish Jenny K N <harish_kandiga@mentor.com>
---
 net/bluetooth/l2cap_core.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 6ba33f9..c6955fb 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -415,6 +415,11 @@ static void l2cap_chan_timeout(struct work_struct *work)
 
 	l2cap_chan_close(chan, reason);
 
+	if ((chan->state == BT_CONNECTED || chan->state == BT_CONFIG) &&
+	    chan->chan_type == L2CAP_CHAN_CONN_ORIENTED) {
+		chan->ops->teardown(chan, 0);
+	}
+
 	l2cap_chan_unlock(chan);
 
 	chan->ops->close(chan);
-- 
1.7.9.5
