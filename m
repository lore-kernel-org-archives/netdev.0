From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] can-raw: Fix skb_orphan_try handling
Date: Fri, 30 Jul 2010 11:44:27 +0200
Message-ID: <4C529EFB.4090601@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Eric, hello Patrick,

Commit fc6055a5ba31e2c14e36e8939f9bf2b6d586a7f5 (net: Introduce
skb_orphan_try()) allows an early orphan of the skb and takes care on
tx timestamping, which needs the sk-reference in the skb on driver level.
So does the can-raw socket, which has not been taken into account here.

The patch below adds a 'prevent_sk_orphan' bit in the skb tx shared info,
which fixes the problem discovered by Matthias Fuchs here:

      http://marc.info/?t=128030411900003&r=1&w=2

Even if it's not a primary tx timestamp topic it fits well into some skb
shared tx context. Or should be find a different place for the information to
protect the sk reference until it reaches the driver level?

Regards,
Oliver

This patch applies on net-2.6 and would be a candidate for stable 2.6.34 also.

Signed-off-by: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>

---

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f89e7fd..eb674b7 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -169,6 +169,7 @@ struct skb_shared_hwtstamps {
  * @software:		generate software time stamp
  * @in_progress:	device driver is going to provide
  *			hardware time stamp
+ * @prevent_sk_orphan:	make sk reference available on driver level
  * @flags:		all shared_tx flags
  *
  * These flags are attached to packets as part of the
@@ -178,7 +179,8 @@ union skb_shared_tx {
 	struct {
 		__u8	hardware:1,
 			software:1,
-			in_progress:1;
+			in_progress:1,
+			prevent_sk_orphan:1;
 	};
 	__u8 flags;
 };
diff --git a/net/can/raw.c b/net/can/raw.c
index da99cf1..eedab37 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -655,6 +655,10 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 	err = sock_tx_timestamp(msg, sk, skb_tx(skb));
 	if (err < 0)
 		goto free_skb;
+
+	/* to be able to check the received tx sock reference in raw_rcv() */
+	(skb_tx(skb))->prevent_sk_orphan = 1;
+
 	skb->dev = dev;
 	skb->sk  = sk;
