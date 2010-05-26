From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 9/17] net/iucv: Add missing spin_unlock
Date: Wed, 26 May 2010 17:56:48 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005261756330.23743@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Ursula Braun <ursula.braun@de.ibm.com>, linux390@de.ibm.com,
	"David S. , Miller" <davem@davemloft.net>,
	linux-s390@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.or
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Add a spin_unlock missing on the error path.  There seems like no reason
why the lock should continue to be held if the kzalloc fail.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression E1;
@@

* spin_lock(E1,...);
  <+... when != E1
  if (...) {
    ... when != E1
*   return ...;
  }
  ...+>
* spin_unlock(E1,...);
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 net/iucv/af_iucv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index c8b4599..9637e45 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1619,7 +1619,7 @@ static void iucv_callback_rx(struct iucv_path *path, struct iucv_message *msg)
 save_message:
 	save_msg = kzalloc(sizeof(struct sock_msg_q), GFP_ATOMIC | GFP_DMA);
 	if (!save_msg)
-		return;
+		goto out_unlock;
 	save_msg->path = path;
 	save_msg->msg = *msg;
 
