From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 1/5] net: fix rds_iovec page count overflow
Date: Thu, 28 Oct 2010 18:40:55 -0700
Message-ID: <1288316459-4679-2-git-send-email-andy.grover@oracle.com>
References: <1288316459-4679-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com,
	Linus Torvalds <torvalds@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:44289 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755651Ab0J2Bmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:42:35 -0400
In-Reply-To: <1288316459-4679-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>

As reported by Thomas Pollet, the rdma page counting can overflow.  We
get the rdma sizes in 64-bit unsigned entities, but then limit it to
UINT_MAX bytes and shift them down to pages (so with a possible "+1" for
an unaligned address).

So each individual page count fits comfortably in an 'unsigned int' (not
even close to overflowing into signed), but as they are added up, they
might end up resulting in a signed return value. Which would be wrong.

Catch the case of tot_pages turning negative, and return the appropriate
error code.

Reported-by: Thomas Pollet <thomas.pollet@gmail.com>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/rdma.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index 1a41deb..0df02c8 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -502,6 +502,13 @@ static int rds_rdma_pages(struct rds_rdma_args *args)
 			return -EINVAL;
 
 		tot_pages += nr_pages;
+
+		/*
+		 * nr_pages for one entry is limited to (UINT_MAX>>PAGE_SHIFT)+1,
+		 * so tot_pages cannot overflow without first going negative.
+		 */
+		if ((int)tot_pages < 0)
+			return -EINVAL;
 	}
 
 	return tot_pages;
-- 
1.7.1

