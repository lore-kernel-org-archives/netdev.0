From: Basil Gunn <basil@pacabunga.com>
Subject: PATCH 1/1]  AX.25: Close socket connection on session completion
Date: Thu, 16 Jun 2016 09:42:30 -0700
Message-ID: <20160616094230.1d023d0b@brox.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Joerg Reuter <jreuter@yaina.de>,
	Ralf Baechle <ralf@linux-mips.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A socket connection made in ax.25 is not closed when session is
completed.  The heartbeat timer is stopped prematurely and this is
where the socket gets closed. Allow heatbeat timer to run to close
socket. Symptom occurs in kernels >= 4.2.0

Originally sent 6/15/2016. Resend with distribution list matching
scripts/maintainer.pl output.

Signed-off-by: Basil Gunn <basil@pacabunga.com>
---
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index fbd0acf..2fdebab 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -976,7 +976,8 @@ static int ax25_release(struct socket *sock)
 			release_sock(sk);
 			ax25_disconnect(ax25, 0);
 			lock_sock(sk);
-			ax25_destroy_socket(ax25);
+			if (!sock_flag(ax25->sk, SOCK_DESTROY))
+				ax25_destroy_socket(ax25);
 			break;

 		case AX25_STATE_3:
diff --git a/net/ax25/ax25_ds_timer.c b/net/ax25/ax25_ds_timer.c
index 951cd57..5237dff 100644
--- a/net/ax25/ax25_ds_timer.c
+++ b/net/ax25/ax25_ds_timer.c
@@ -102,6 +102,7 @@ void ax25_ds_heartbeat_expiry(ax25_cb *ax25)
 	switch (ax25->state) {

 	case AX25_STATE_0:
+	case AX25_STATE_2:
 		/* Magic here: If we listen() and a new link dies before it
 		   is accepted() it isn't 'dead' so doesn't get removed. */
 		if (!sk || sock_flag(sk, SOCK_DESTROY) ||
@@ -111,6 +112,7 @@ void ax25_ds_heartbeat_expiry(ax25_cb *ax25)
 				sock_hold(sk);
 				ax25_destroy_socket(ax25);
 				bh_unlock_sock(sk);
+				/* Ungrab socket and destroy it */
 				sock_put(sk);
 			} else
 				ax25_destroy_socket(ax25);
@@ -213,7 +215,8 @@ void ax25_ds_t1_timeout(ax25_cb *ax25)
 	case AX25_STATE_2:
 		if (ax25->n2count == ax25->n2) {
 			ax25_send_control(ax25, AX25_DISC, AX25_POLLON, AX25_COMMAND);
-			ax25_disconnect(ax25, ETIMEDOUT);
+			if (!sock_flag(ax25->sk, SOCK_DESTROY))
+				ax25_disconnect(ax25, ETIMEDOUT);
 			return;
 		} else {
 			ax25->n2count++;
diff --git a/net/ax25/ax25_std_timer.c b/net/ax25/ax25_std_timer.c
index 004467c9..2c0d6ef 100644
--- a/net/ax25/ax25_std_timer.c
+++ b/net/ax25/ax25_std_timer.c
@@ -38,6 +38,7 @@ void ax25_std_heartbeat_expiry(ax25_cb *ax25)

 	switch (ax25->state) {
 	case AX25_STATE_0:
+	case AX25_STATE_2:
 		/* Magic here: If we listen() and a new link dies before it
 		   is accepted() it isn't 'dead' so doesn't get removed. */
 		if (!sk || sock_flag(sk, SOCK_DESTROY) ||
@@ -47,6 +48,7 @@ void ax25_std_heartbeat_expiry(ax25_cb *ax25)
 				sock_hold(sk);
 				ax25_destroy_socket(ax25);
 				bh_unlock_sock(sk);
+				/* Ungrab socket and destroy it */
 				sock_put(sk);
 			} else
 				ax25_destroy_socket(ax25);
@@ -144,7 +146,8 @@ void ax25_std_t1timer_expiry(ax25_cb *ax25)
 	case AX25_STATE_2:
 		if (ax25->n2count == ax25->n2) {
 			ax25_send_control(ax25, AX25_DISC, AX25_POLLON, AX25_COMMAND);
-			ax25_disconnect(ax25, ETIMEDOUT);
+			if (!sock_flag(ax25->sk, SOCK_DESTROY))
+				ax25_disconnect(ax25, ETIMEDOUT);
 			return;
 		} else {
 			ax25->n2count++;
diff --git a/net/ax25/ax25_subr.c b/net/ax25/ax25_subr.c
index 3b78e84..655a7d4 100644
--- a/net/ax25/ax25_subr.c
+++ b/net/ax25/ax25_subr.c
@@ -264,7 +264,8 @@ void ax25_disconnect(ax25_cb *ax25, int reason)
 {
 	ax25_clear_queues(ax25);

-	ax25_stop_heartbeat(ax25);
+	if (!sock_flag(ax25->sk, SOCK_DESTROY))
+		ax25_stop_heartbeat(ax25);
 	ax25_stop_t1timer(ax25);
 	ax25_stop_t2timer(ax25);
 	ax25_stop_t3timer(ax25);
