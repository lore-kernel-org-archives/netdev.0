From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH v3 6/6] fix wrong get_user_pages usage in iovlock.c
Date: Tue, 14 Apr 2009 15:23:13 +0900 (JST)
Message-ID: <20090414152151.C659.A69D9226@jp.fujitsu.com>
References: <20090414151204.C647.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com, Linus Torvalds <torvalds@osdl.org>,
	Andrew Morton <akpm@osdl.org>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	Maciej Sosnowski <maciej.sosnowski@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Chris Leech <christopher.leech@intel.com>,
	netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:56159 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753626AbZDNGXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 02:23:16 -0400
In-Reply-To: <20090414151204.C647.A69D9226@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't have NET-DMA usable device. I hope to get expert review.

=========================
Subject: [Untested][RFC][PATCH] fix wrong get_user_pages usage in iovlock.c

	down_read(mmap_sem)
	get_user_pages()
	up_read(mmap_sem)

is fork unsafe.
fix it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Maciej Sosnowski <maciej.sosnowski@intel.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Chris Leech <christopher.leech@intel.com>
Cc: netdev@vger.kernel.org
---
 drivers/dma/iovlock.c |   18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

Index: b/drivers/dma/iovlock.c
===================================================================
--- a/drivers/dma/iovlock.c	2009-02-21 16:53:23.000000000 +0900
+++ b/drivers/dma/iovlock.c	2009-04-13 04:46:02.000000000 +0900
@@ -94,18 +94,10 @@ struct dma_pinned_list *dma_pin_iovec_pa
 		pages += page_list->nr_pages;
 
 		/* pin pages down */
-		down_read(&current->mm->mmap_sem);
-		ret = get_user_pages(
-			current,
-			current->mm,
-			(unsigned long) iov[i].iov_base,
-			page_list->nr_pages,
-			1,	/* write */
-			0,	/* force */
-			page_list->pages,
-			NULL);
-		up_read(&current->mm->mmap_sem);
-
+		down_read(&current->mm->mm_pinned_sem);
+		ret = get_user_pages_fast((unsigned long) iov[i].iov_base,
+					  page_list->nr_pages, 1,
+					  page_list->pages);
 		if (ret != page_list->nr_pages)
 			goto unpin;
 
@@ -127,6 +119,8 @@ void dma_unpin_iovec_pages(struct dma_pi
 	if (!pinned_list)
 		return;
 
+	up_read(&current->mm->mm_pinned_sem);
+
 	for (i = 0; i < pinned_list->nr_iovecs; i++) {
 		struct dma_page_list *page_list = &pinned_list->page_list[i];
 		for (j = 0; j < page_list->nr_pages; j++) {


