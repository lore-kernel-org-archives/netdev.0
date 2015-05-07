From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH 00/10] Refactor netdev page frags and move them into mm/
Date: Wed, 06 May 2015 21:11:34 -0700
Message-ID: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35922 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750725AbbEGELo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2015 00:11:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series addresses several things.

First I found an issue in the performance of the pfmemalloc check from
build_skb.  To work around it I have provided a cached copy of pfmemalloc
to be used in __netdev_alloc_skb and __napi_alloc_skb.

Second I moved the page fragment allocation logic into the mm tree and
added functionality for freeing page fragments.  I had to fix igb before I
could do this as it was using a reference to NETDEV_FRAG_PAGE_MAX_SIZE
incorrectly.

Finally I went through and replaced all of the duplicate code that was
calling put_page and replaced it with calls to skb_free_frag.

With these changes in place a simple receive and drop test increased from a
packet rate of 8.9Mpps to 9.8Mpps.  The gains breakdown as follows:

8.9Mpps	Before			9.8Mpps	After
------------------------	------------------------
7.8%	put_compound_page	9.1%	__free_page_frag
3.9%	skb_free_head
1.1%	put_page

4.9%	build_skb		3.8%	__napi_alloc_skb
2.5%	__alloc_rx_skb
1.9%	__napi_alloc_skb

---

Alexander Duyck (10):
      net: Use cached copy of pfmemalloc to avoid accessing page
      igb: Don't use NETDEV_FRAG_PAGE_MAX_SIZE in descriptor calculation
      net: Store virtual address instead of page in netdev_alloc_cache
      mm/net: Rename and move page fragment handling from net/ to mm/
      net: Add skb_free_frag to replace use of put_page in freeing skb->head
      netcp: Replace put_page(virt_to_head_page(ptr)) w/ skb_free_frag
      mvneta: Replace put_page(virt_to_head_page(ptr)) w/ skb_free_frag
      e1000: Replace e1000_free_frag with skb_free_frag
      hisilicon: Replace put_page(virt_to_head_page()) with skb_free_frag()
      bnx2x, tg3: Replace put_page(virt_to_head_page()) with skb_free_frag()


 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 
 drivers/net/ethernet/broadcom/tg3.c             |    2 
 drivers/net/ethernet/hisilicon/hip04_eth.c      |    2 
 drivers/net/ethernet/intel/e1000/e1000_main.c   |   19 +-
 drivers/net/ethernet/intel/igb/igb_main.c       |   11 -
 drivers/net/ethernet/marvell/mvneta.c           |    2 
 drivers/net/ethernet/ti/netcp_core.c            |    2 
 include/linux/gfp.h                             |    5 +
 include/linux/mm_types.h                        |   18 ++
 include/linux/skbuff.h                          |    9 +
 mm/page_alloc.c                                 |   98 ++++++++++
 net/core/skbuff.c                               |  224 ++++++++---------------
 12 files changed, 223 insertions(+), 171 deletions(-)

--
