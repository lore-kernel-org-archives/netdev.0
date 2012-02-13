From: Christian Brunner <chb@muc.de>
Subject: [PATCH] ixgbe: fix truesize calculation when merging active tail
 into lro skb
Date: Mon, 13 Feb 2012 14:52:48 +0100
Message-ID: <20120213135248.GA23457@sir.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59303 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756567Ab2BMNxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 08:53:33 -0500
Received: by bkcjm19 with SMTP id jm19so4551316bkc.19
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 05:53:32 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm seeing some page allocation failures with the ixgbe driver under heavy
load. While looking after it, I came accoss the truesize handling. I suspect,
that there is a small misstake in ixgbe_merge_active_tail(). (But I'm not
really sure).

Truesize allocation of the skb may be larger than skb->len, because
ixgbe is allocating PAGE_SIZE/2 for received fragments. Hence we 
should use the truesize of the tail when merging.

Signed-off-by: Christian Brunner <chb@muc.de>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a42b0b2..c4d25af 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1222,7 +1222,7 @@ static inline struct sk_buff *ixgbe_merge_active_tail(struct sk_buff *tail)
 
 	head->len += tail->len;
 	head->data_len += tail->len;
-	head->truesize += tail->len;
+	head->truesize += tail->truesize;
 
 	IXGBE_CB(tail)->head = NULL;
 
-- 
1.7.1
