From: Hillf Danton <dhillf@gmail.com>
Subject: Re: Ask For Comment: add routines for exchanging data between sock
 buffer and scatter list
Date: Sun, 3 Oct 2010 11:10:14 +0800
Message-ID: <AANLkTikF7uz8QHVQB=GMgeFNwsr+u7J0a06a5KAnxkTb@mail.gmail.com>
References: <AANLkTimF+zy-qTmbtchGu_0Td7fZUsrsd7PNgkAdM8fA@mail.gmail.com>
	<20101002.132056.226767861.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, axboe@kernel.dk,
	robert.w.love@intel.com, James.Bottomley@suse.de
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101002.132056.226767861.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There seems no routines provided for exchanging data
directly between sock buffer and scatter list in
both scatterlist.c and skbuff.c, so comes this work.

And it is hard to determine into which file these
routines should be added, then a header file is added.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

diff -Npur o/linux-2.6.36-rc4/include/skb_sg.h
m/linux-2.6.36-rc4/include/skb_sg.h
--- o/linux-2.6.36-rc4/include/skb_sg.h	1970-01-01 08:00:00.000000000 +0800
+++ m/linux-2.6.36-rc4/include/skb_sg.h	2010-10-03 10:03:54.000000000 +0800
@@ -0,0 +1,113 @@
+/*
+    Definition for exchanging data between sock buffer and scatter list
+
+    Copyright (C) Oct 2010 Hillf Danton <dhillf@gmail.com>
+
+    This program is free software; you can redistribute it and/or modify
+    it under the terms of the GNU General Public License as published by
+    the Free Software Foundation; either version 2 of the License, or
+    (at your option) any later version.
+
+    This program is distributed in the hope that it will be useful,
+    but WITHOUT ANY WARRANTY; without even the implied warranty of
+    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+    GNU General Public License for more details.
+
+    You should have received a copy of the GNU General Public License
+    along with this program; if not, write to the Free Software
+    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston,
+    MA 02110-1301  USA
+*/
+
+#ifndef __LINUX_SKB_SG_H
+#define __LINUX_SKB_SG_H
+
+#include <linux/scatterlist.h>
+#include <linux/skbuff.h>
+
+/*
+ * sg_fill_skb_page_desc - fill skb frags with info in sg list
+ * @index  the start index to fill
+ *
+ * return the number of filled frags
+ */
+
+static int sg_fill_skb_page_desc(struct sk_buff *skb, int index,
+                                 struct scatterlist *sg)
+{
+	int old = index;
+	struct page *page;
+	
+	for (; sg && index < MAX_SKB_FRAGS; index++) {
+		page = sg_page(sg);
+		get_page(page);
+		skb_add_rx_frag(skb, index, page, sg->offset, sg->length);
+		sg = sg_next(sg);
+	}
+	
+	return index - old;
+}
+
+/*
+ * skb_copy_bits_to_sg - copy data from skb to sg list
+ * @len	length of data to be copied
+ *
+ * return the number of copied bytes
+ */
+
+static int skb_copy_bits_to_sg(struct sk_buff *skb, int offset_in_skb,
+                               struct scatterlist *sg, int offset_in_sg,
+                               int len)
+{
+	int old = len;
+	struct sg_mapping_iter miter;
+
+	if (offset_in_skb >= skb->len)
+		return 0;
+	
+	if (len > skb->len - offset_in_skb)
+		old = len = skb->len - offset_in_skb;
+	
+	/* skip offset in sg */
+	while (sg && offset_in_sg >= sg->length) {
+		offset_in_sg -= sg->length;
+		sg = sg_next(sg);
+	}
+	if (! sg)
+		return 0;
+
+	/* and go thru sg list */
+	while (len > 0 && sg) {
+		int this_len;
+		int err;
+		
+		sg_miter_start(&miter, sg, 1, SG_MITER_ATOMIC|SG_MITER_TO_SG);
+
+		if (offset_in_sg) {
+			/* we have to count this residual */
+			miter.__offset = offset_in_sg;
+			offset_in_sg = 0;
+		}
+
+		if (! sg_miter_next(&miter))
+			break;
+		
+		this_len = min(miter.length, len);
+		
+		err = skb_copy_bits(skb, offset_in_skb, miter.addr, this_len);
+
+		sg_miter_stop(&miter);
+
+		if (err)
+			break;
+
+		offset_in_skb += this_len;
+		len -= this_len;
+
+		sg = sg_next(sg);
+	}
+
+	return old - len;	
+}
+
+#endif /* __LINUX_SKB_SG_H */
