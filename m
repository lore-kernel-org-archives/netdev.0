From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net 3/5] ixgbe: fix race accessing page->_count
Date: Fri, 10 Oct 2014 04:48:16 -0700
Message-ID: <1412941698-17502-4-git-send-email-edumazet@google.com>
References: <1412941698-17502-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Andres Lagar-Cavilla <andreslc@google.com>,
	Greg Thelen <gthelen@google.com>,
	Hugh Dickins <hughd@google.com>,
	David Rientjes <rientjes@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f202.google.com ([209.85.213.202]:64903 "EHLO
	mail-ig0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456AbaJJLse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 07:48:34 -0400
Received: by mail-ig0-f202.google.com with SMTP id r10so365045igi.5
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 04:48:34 -0700 (PDT)
In-Reply-To: <1412941698-17502-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is illegal to use atomic_set(&page->_count, 2) even if we 'own'
the page. Other entities in the kernel need to use get_page_unless_zero()
to get a reference to the page before testing page properties, so we could
loose a refcount increment.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d677b5a23b58..fec5212d4337 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1865,12 +1865,10 @@ static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
 	/* flip page offset to other buffer */
 	rx_buffer->page_offset ^= truesize;
 
-	/*
-	 * since we are the only owner of the page and we need to
-	 * increment it, just set the value to 2 in order to avoid
-	 * an unecessary locked operation
+	/* Even if we own the page, we are not allowed to use atomic_set()
+	 * This would break get_page_unless_zero() users.
 	 */
-	atomic_set(&page->_count, 2);
+	atomic_inc(&page->_count);
 #else
 	/* move offset up to the next cache line */
 	rx_buffer->page_offset += truesize;
-- 
2.1.0.rc2.206.gedb03e5
