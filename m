From: Simon Arlott <simon@fire.lp0.eu>
Subject: [PATCH 2/2] ppp_generic: handle non-linear skbs when passing them
 to pppd
Date: Mon, 03 May 2010 17:51:18 +0100
Message-ID: <4BDEFF06.1070304@simon.arlott.org.uk>
References: <4BDB244D.40800@simon.arlott.org.uk>	<4BDB2469.6020105@simon.arlott.org.uk> <20100502.232711.256856995.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org, linux-ppp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([81.2.80.65]:53192 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932968Ab0ECQvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 May 2010 12:51:25 -0400
In-Reply-To: <20100502.232711.256856995.davem@davemloft.net>
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
On 03/05/10 07:27, David Miller wrote:
> From: Simon Arlott <simon@fire.lp0.eu>
> Date: Fri, 30 Apr 2010 19:41:45 +0100
> 
>> Frequently when using PPPoE with an interface MTU greater than 1500,
>> the skb is likely to be non-linear. If the skb needs to be passed to
>> pppd then the skb must be linearised first.
> 
> Don't propagate stupidity.
> 
> The real problem is that ppp_read() can't handle non-linear SKBs, so
> fix that instead.  The easiest way to do that is to put a "struct
> iovec iov;" on ppp_read()'s stack, fill it in with ther user buffer
> pointer and length, then use that to call
> skb_copy_datagram_const_iovec().

I've updated it to use skb_copy_datagram_iovec():

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
