From: <Thomas_Chenault@Dell.com>
Subject: [PATCH] net: fix skb_seq_read returning wrong offset/length for page frag data
Date: Wed, 13 May 2009 20:33:11 -0500
Message-ID: <65FDECA153DE9A40B78CA281949AC88902A9FBF1@ausx3mps309.aus.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <Shyam_Iyer@Dell.com>, <michaelc@cs.wisc.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxippc101.us.dell.com ([143.166.85.207]:44963 "EHLO
	ausxippc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762441AbZENBmk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 21:42:40 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When called with a consumed value that is less than skb_headlen(skb)
bytes into a page frag, skb_seq_read() incorrectly returns an
offset/length relative to skb->data. Ensure that data which should come
from a page frag does.

Signed-off-by: Thomas Chenault <thomas_chenault@dell.com>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d152394..e505b53 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2288,7 +2288,7 @@ unsigned int skb_seq_read(unsigned int consumed,
const u8 **data,
 next_skb:
 	block_limit = skb_headlen(st->cur_skb) + st->stepped_offset;
 
-	if (abs_offset < block_limit) {
+	if (abs_offset < block_limit && !st->frag_data) {
 		*data = st->cur_skb->data + (abs_offset -
st->stepped_offset);
 		return block_limit - abs_offset;
 	}
