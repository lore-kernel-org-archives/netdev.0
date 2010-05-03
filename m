From: Simon Arlott <simon@fire.lp0.eu>
Subject: [PATCH v2 2/2] ppp_generic: handle non-linear skbs when passing them
 to pppd
Date: Mon, 03 May 2010 21:20:27 +0100
Message-ID: <4BDF300B.1040103@simon.arlott.org.uk>
References: <4BDF2FD5.2030509@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, paulus@samba.org,
	linux-ppp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([81.2.80.65]:54378 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756747Ab0ECUU3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 May 2010 16:20:29 -0400
In-Reply-To: <4BDF2FD5.2030509@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frequently when using PPPoE with an interface MTU greater than 1500,
the skb is likely to be non-linear. If the skb needs to be passed to
pppd then the skb data must be read correctly.

The previous commit fixes an issue with accidentally sending skbs
to pppd based on an invalid read of the protocol type. When that
error occurred pppd was reading invalid skb data too.

Signed-off-by: Simon Arlott <simon@fire.lp0.eu>
---
 drivers/net/ppp_generic.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 75e8903..8518a2e 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -405,6 +405,7 @@ static ssize_t ppp_read(struct file *file, char __user *buf,
 	DECLARE_WAITQUEUE(wait, current);
 	ssize_t ret;
 	struct sk_buff *skb = NULL;
+	struct iovec iov;
 
 	ret = count;
 
@@ -448,7 +449,9 @@ static ssize_t ppp_read(struct file *file, char __user *buf,
 	if (skb->len > count)
 		goto outf;
 	ret = -EFAULT;
-	if (copy_to_user(buf, skb->data, skb->len))
+	iov.iov_base = buf;
+	iov.iov_len = count;
+	if (skb_copy_datagram_iovec(skb, 0, &iov, skb->len))
 		goto outf;
 	ret = skb->len;
 
-- 
1.7.0.4

-- 
Simon Arlott
