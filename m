From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net 0/5] net: fix races accessing page->_count
Date: Fri, 10 Oct 2014 04:48:13 -0700
Message-ID: <1412941698-17502-1-git-send-email-edumazet@google.com>
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
Received: from mail-pd0-f202.google.com ([209.85.192.202]:37366 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268AbaJJLs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 07:48:26 -0400
Received: by mail-pd0-f202.google.com with SMTP id fp1so301357pdb.1
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 04:48:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is illegal to use atomic_set(&page->_count, ...) even if we 'own'
the page. Other entities in the kernel need to use get_page_unless_zero()
to get a reference to the page before testing page properties, so we could
loose a refcount increment.

The only case it is valid is when page->_count is 0, we can use this in
__netdev_alloc_frag()

Note that I never seen crashes caused by these races, the issue was reported
by Andres Lagar-Cavilla and Hugh Dickins.


Eric Dumazet (5):
  fm10k: fix race accessing page->_count
  igb: fix race accessing page->_count
  ixgbe: fix race accessing page->_count
  mlx4: fix race accessing page->_count
  net: fix races in page->_count manipulation

 drivers/net/ethernet/intel/fm10k/fm10k_main.c |  7 +++----
 drivers/net/ethernet/intel/igb/igb_main.c     |  7 +++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  8 +++-----
 drivers/net/ethernet/mellanox/mlx4/en_rx.c    |  6 +++---
 net/core/skbuff.c                             | 25 ++++++++++++++++++-------
 5 files changed, 30 insertions(+), 23 deletions(-)

-- 
2.1.0.rc2.206.gedb03e5
