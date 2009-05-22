From: Karsten Keil <keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org>
Subject: [mISDN PATCH v2 12/19] Fix skb leak in error cases
Date: Fri, 22 May 2009 23:04:52 +0200
Message-ID: <234a21433b574ede7ef52c07369c2adbfe111877.1243024967.git.kkeil@pingi.linux-pingi.de>
References: <cover.1243024967.git.kkeil@pingi.linux-pingi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
In-Reply-To: <cover.1243024967.git.kkeil-Zw2aQviYsaUCyFmpLCWB8V3+hHH5wKcB@public.gmane.org>
List-Unsubscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.isdn4linux.de/pipermail/i4ldeveloper>
List-Post: <mailto:i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
List-Help: <mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=help>
List-Subscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=subscribe>
Sender: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
Errors-To: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
List-Id: netdev.vger.kernel.org

If the channel receive function returns an error the skb must be freed.

Signed-off-by: Karsten Keil <keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org>
---
 drivers/isdn/mISDN/socket.c |   22 ++++++++++++----------
 1 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index 530f689..2a2c30a 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -209,7 +209,7 @@ mISDN_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 	if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
 		err = -EFAULT;
-		goto drop;
+		goto done;
 	}
 
 	memcpy(mISDN_HEAD_P(skb), skb->data, MISDN_HEADER_LEN);
@@ -230,19 +230,21 @@ mISDN_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 		     __func__, mISDN_HEAD_ID(skb));
 
 	err = -ENODEV;
-	if (!_pms(sk)->ch.peer ||
-	    (err = _pms(sk)->ch.recv(_pms(sk)->ch.peer, skb)))
-		goto drop;
-
-	err = len;
+	if (!_pms(sk)->ch.peer)
+		goto done;
+	err = _pms(sk)->ch.recv(_pms(sk)->ch.peer, skb);
+	if (err)
+		goto done;
+	else {
+		skb = NULL;
+		err = len;
+	}
 
 done:
+	if (skb)
+		kfree_skb(skb);
 	release_sock(sk);
 	return err;
-
-drop:
-	kfree_skb(skb);
-	goto done;
 }
 
 static int
-- 
1.6.0.2
