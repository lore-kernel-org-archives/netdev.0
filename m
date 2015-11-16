From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/2] mISDN: One function call less in mISDN_sock_sendmsg()
 after error detection
Date: Mon, 16 Nov 2015 10:47:37 +0100
Message-ID: <5649A639.2040503@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net>
 <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
 <530A086E.8010901@users.sourceforge.net>
 <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
 <530A72AA.3000601@users.sourceforge.net>
 <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
 <530B5FB6.6010207@users.sourceforge.net>
 <alpine.DEB.2.10.1402241710370.2074@hadrien>
 <530C5E18.1020800@users.sourceforge.net>
 <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net> <5649A524.6030407@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5649A524.6030407@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 16 Nov 2015 10:30:29 +0100

The kfree_skb() function was called in one case by the
mISDN_sock_sendmsg() function during error handling even if a call of
the _l2_alloc_skb() function returned a null pointer.

This implementation detail could be improved by the introduction
of another jump label.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/isdn/mISDN/socket.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index edd16ef..430ac8c 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -200,7 +200,7 @@ mISDN_sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 
 	skb = _l2_alloc_skb(len, GFP_KERNEL);
 	if (!skb)
-		goto done;
+		goto release_socket;
 
 	if (memcpy_from_msg(skb_put(skb, len), msg, len)) {
 		err = -EFAULT;
@@ -237,6 +237,7 @@ mISDN_sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 
 done:
 	kfree_skb(skb);
+release_socket:
 	release_sock(sk);
 	return err;
 }
-- 
2.6.2
