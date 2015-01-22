From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [next-next PATCH 1/7] fib_trie: Use index & (~0ul << n->bits)
 instead of index >> n->bits
Date: Thu, 22 Jan 2015 15:51:08 -0800
Message-ID: <20150122235108.5779.95865.stgit@ahduyck-vm-fedora20>
References: <20150122234652.5779.44251.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37231 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751934AbbAVXvL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 18:51:11 -0500
In-Reply-To: <20150122234652.5779.44251.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In doing performance testing and analysis of the changes I recently found
that by shifting the index I had created an unnecessary dependency.

I have updated the code so that we instead shift a mask by bits and then
just test against that as that should save us about 2 CPU cycles since we
can generate the mask while the key and pos are being processed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 281e5e0..dea2f80 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -961,12 +961,12 @@ static struct tnode *fib_find_node(struct trie *t, u32 key)
 		 * prefix plus zeros for the bits in the cindex. The index
 		 * is the difference between the key and this value.  From
 		 * this we can actually derive several pieces of data.
-		 *   if !(index >> bits)
-		 *     we know the value is cindex
-		 *   else
+		 *   if (index & (~0ul << bits))
 		 *     we have a mismatch in skip bits and failed
+		 *   else
+		 *     we know the value is cindex
 		 */
-		if (index >> n->bits)
+		if (index & (~0ul << n->bits))
 			return NULL;
 
 		/* we have found a leaf. Prefixes have already been compared */
@@ -1301,12 +1301,12 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		 * prefix plus zeros for the "bits" in the prefix. The index
 		 * is the difference between the key and this value.  From
 		 * this we can actually derive several pieces of data.
-		 *   if !(index >> bits)
-		 *     we know the value is child index
-		 *   else
+		 *   if (index & (~0ul << bits))
 		 *     we have a mismatch in skip bits and failed
+		 *   else
+		 *     we know the value is cindex
 		 */
-		if (index >> n->bits)
+		if (index & (~0ul << n->bits))
 			break;
 
 		/* we have found a leaf. Prefixes have already been compared */
