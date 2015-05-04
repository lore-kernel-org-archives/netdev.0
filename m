From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 0/6] Add skb_free_frag to replace
 put_page(virt_to_head_page(ptr))
Date: Mon, 04 May 2015 16:14:42 -0700
Message-ID: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, davem@davemloft.net
To: linux-mm@kvack.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40777 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751277AbbEDXOs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 19:14:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set cleans up some of the handling of page frags used in the skb
allocation.  The issue was we were having to use a number of calls to
virt_to_head_page in a number of places and then following that up with
put_page.  Both calls end up being expensive, the first due to size, and
the second due to the fact that we end up having to call a number of other
functions before we finally see the page freed in the case of compound
pages.

The skb_free_frag function is meant to resolve that by providing a
centralized location for the virt_to_head_page call and by coalesing
several checks such as the check for PageHead into a single check so that
we can keep the instruction cound minimal when freeing the page frag.

With this change I am seeing an improvement of about 5% in a simple
receive/drop test.

---

Alexander Duyck (6):
      net: Add skb_free_frag to replace use of put_page in freeing skb->head
      netcp: Replace put_page(virt_to_head_page(ptr)) w/ skb_free_frag
      mvneta: Replace put_page(virt_to_head_page(ptr)) w/ skb_free_frag
      e1000: Replace e1000_free_frag with skb_free_frag
      hisilicon: Replace put_page(virt_to_head_page()) with skb_free_frag()
      bnx2x, tg3: Replace put_page(virt_to_head_page()) with skb_free_frag()


 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 +-
 drivers/net/ethernet/broadcom/tg3.c             |    2 +-
 drivers/net/ethernet/hisilicon/hip04_eth.c      |    2 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c   |   19 ++++++---------
 drivers/net/ethernet/marvell/mvneta.c           |    2 +-
 drivers/net/ethernet/ti/netcp_core.c            |    2 +-
 include/linux/gfp.h                             |    1 +
 include/linux/skbuff.h                          |    1 +
 mm/page_alloc.c                                 |    4 +--
 net/core/skbuff.c                               |   29 +++++++++++++++++++++--
 10 files changed, 41 insertions(+), 23 deletions(-)

--
