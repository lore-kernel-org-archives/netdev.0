From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH][netlabel] Don't risk NULL ptr deref in netlbl_unlabel_staticlist_gen()
 if ifindex not found
Date: Wed, 16 Apr 2008 23:08:58 +0200 (CEST)
Message-ID: <alpine.LNX.1.00.0804162304220.9837@dragon.funnycrock.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jesper Juhl <jesper.juhl@gmail.com>
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:11856 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761910AbYDPVJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 17:09:02 -0400
Received: by fg-out-1718.google.com with SMTP id l27so2562625fgb.17
        for <netdev@vger.kernel.org>; Wed, 16 Apr 2008 14:09:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

dev_get_by_index() may return NULL if nothing is found. In 
net/netlabel/netlabel_unlabeled.c::netlbl_unlabel_staticlist_gen() the 
function is called, but the return value is never checked. If it returns 
NULL then we'll deref a NULL pointer on the very next line.
I checked the callers, and I don't think this can actually happen today, 
but code changes over time and in the future it might happen and it does 
no harm to be defensive and check for the failure, so that if/when it 
happens we'll fail gracefully instead of crashing.

Please consider the patch below for inclusion.


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

 netlabel_unlabeled.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 4478f2f..6af9457 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -1339,6 +1339,10 @@ static int netlbl_unlabel_staticlist_gen(u32 cmd,
 
 	if (iface->ifindex > 0) {
 		dev = dev_get_by_index(&init_net, iface->ifindex);
+		if (!dev) {
+			ret_val = -ENODEV;
+			goto list_cb_failure;
+		}
 		ret_val = nla_put_string(cb_arg->skb,
 					 NLBL_UNLABEL_A_IFACE, dev->name);
 		dev_put(dev);


