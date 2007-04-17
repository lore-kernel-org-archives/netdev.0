From: "Aubrey Li" <aubreylee@gmail.com>
Subject: [PATCH] Fix UDP checksum issue in net poll mode.
Date: Tue, 17 Apr 2007 14:53:48 +0800
Message-ID: <6d6a94c50704162353p2b96b3e4kd05489a59aa9bba7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Linux Kernel" <linux-kernel@vger.kernel.org>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, kaber@coreworks.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:8727 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674AbXDQGxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 02:53:49 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1923732wxd
        for <netdev@vger.kernel.org>; Mon, 16 Apr 2007 23:53:49 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In net poll mode, the current checksum function doesn't consider the
kind of packet which is padded to reach a specific minimum length. I
believe that's the problem causing my test case failed. The following
patch fixed this issue.

Signed-off-by: Aubrey.Li <aubreylee@gmail.com>
---
 net/core/netpoll.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 823215d..522e441 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -471,6 +471,13 @@ int __netpoll_rx(struct sk_buff *skb)
 	if (skb->len < len || len < iph->ihl*4)
 		goto out;

+	/*
+	 * Our transport medium may have padded the buffer out.
+	 * Now We trim to the true length of the frame.
+	 */
+	if (pskb_trim_rcsum(skb, len))
+		goto out;
+
 	if (iph->protocol != IPPROTO_UDP)
 		goto out;

-- 
1.5.1
