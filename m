From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH 1/2] e1000: Do not overestimate descriptor counts in Tx
 pre-check
Date: Wed, 02 Mar 2016 16:16:01 -0500
Message-ID: <20160302211601.2124.64160.stgit@localhost.localdomain>
References: <20160302205129.2124.67042.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, jogreene@redhat.com,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	sassmann@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33944 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755105AbcCBW0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 17:26:46 -0500
Received: by mail-pf0-f175.google.com with SMTP id 4so1881121pfd.1
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 14:26:46 -0800 (PST)
In-Reply-To: <20160302205129.2124.67042.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code path is capable of grossly overestimating the number of
descriptors needed to transmit a new frame.  This specifically occurs if
the skb contains a number of 4K pages.  The issue is that the logic for
determining the descriptors needed is ((S) >> (X)) + 1.  When X is 12 it
means that we were indicating that we required 2 descriptors for each 4K
page when we only needed one.

This change corrects this by instead adding (1 << (X)) - 1 to the S value
instead of adding 1 after the fact.  This way we get an accurate descriptor
needed count as we are essentially doing a DIV_ROUNDUP().

Reported-by: Ivan Suzdal <isuzdal@mirantis.com>
Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 3fc7bde..d213fb4 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -3106,7 +3106,7 @@ static int e1000_maybe_stop_tx(struct net_device *netdev,
 	return __e1000_maybe_stop_tx(netdev, size);
 }
 
-#define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1)
+#define TXD_USE_COUNT(S, X) (((S) + ((1 << (X)) - 1)) >> (X))
 static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 				    struct net_device *netdev)
 {
