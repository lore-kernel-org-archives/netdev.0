From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 01/75] net: add APIs for manipulating skb page fragments.
Date: Fri, 19 Aug 2011 14:26:33 +0100
Message-ID: <1313760467-8598-1-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The primary aim is to add skb_frag_(ref|unref) in order to remove the u=
se of
bare get/put_page on SKB pages fragments and to isolate users from subs=
equent
changes to the skb_frag_t data structure.

Also included are helper APIs for passing a paged fragment to kmap and
dma_map_page since I was seeing the same pattern a lot. A helper for
pci_map_page is ommitted due to Micha=C5=82 Miros=C5=82aw's recommendat=
ion that users
should transition to pci_map_page instead.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Micha=C5=82 Miros=C5=82aw" <mirq-linux@rere.qmqm.pl>
Cc: netdev@vger.kernel.org
---
 include/linux/skbuff.h |  170 ++++++++++++++++++++++++++++++++++++++++=
+++++++-
 1 files changed, 168 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7b996ed..2562764 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -29,6 +29,7 @@
 #include <linux/rcupdate.h>
 #include <linux/dmaengine.h>
 #include <linux/hrtimer.h>
+#include <linux/dma-mapping.h>
=20
 /* Don't change this without changing skb_csum_unnecessary! */
 #define CHECKSUM_NONE 0
@@ -1126,14 +1127,47 @@ static inline int skb_pagelen(const struct sk_b=
uff *skb)
 	return len + skb_headlen(skb);
 }
=20
-static inline void skb_fill_page_desc(struct sk_buff *skb, int i,
-				      struct page *page, int off, int size)
+/**
+ * __skb_fill_page_desc - initialise a paged fragment in an skb
+ * @skb: buffer containing fragment to be initialised
+ * @i: paged fragment index to initialise
+ * @page: the page to use for this fragment
+ * @off: the offset to the data with @page
+ * @size: the length of the data
+ *
+ * Initialises the @i'th fragment of @skb to point to &size bytes at
+ * offset @off within @page.
+ *
+ * Does not take any additional reference on the fragment.
+ */
+static inline void __skb_fill_page_desc(struct sk_buff *skb, int i,
+					struct page *page, int off, int size)
 {
 	skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
 	frag->page		  =3D page;
 	frag->page_offset	  =3D off;
 	frag->size		  =3D size;
+}
+
+/**
+ * skb_fill_page_desc - initialise a paged fragment in an skb
+ * @skb: buffer containing fragment to be initialised
+ * @i: paged fragment index to initialise
+ * @page: the page to use for this fragment
+ * @off: the offset to the data with @page
+ * @size: the length of the data
+ *
+ * As per __skb_fill_page_desc() -- initialises the @i'th fragment of
+ * @skb to point to &size bytes at offset @off within @page. In
+ * addition updates @skb such that @i is the last fragment.
+ *
+ * Does not take any additional reference on the fragment.
+ */
+static inline void skb_fill_page_desc(struct sk_buff *skb, int i,
+				      struct page *page, int off, int size)
+{
+	__skb_fill_page_desc(skb, i, page, off, size);
 	skb_shinfo(skb)->nr_frags =3D i + 1;
 }
=20
@@ -1628,6 +1662,138 @@ static inline void netdev_free_page(struct net_=
device *dev, struct page *page)
 }
=20
 /**
+ * skb_frag_page - retrieve the page refered to by a paged fragment
+ * @frag: the paged fragment
+ *
+ * Returns the &struct page associated with @frag.
+ */
+static inline struct page *skb_frag_page(const skb_frag_t *frag)
+{
+	return frag->page;
+}
+
+/**
+ * __skb_frag_ref - take an addition reference on a paged fragment.
+ * @frag: the paged fragment
+ *
+ * Takes an additional reference on the paged fragment @frag.
+ */
+static inline void __skb_frag_ref(skb_frag_t *frag)
+{
+	get_page(skb_frag_page(frag));
+}
+
+/**
+ * skb_frag_ref - take an addition reference on a paged fragment of an=
 skb.
+ * @skb: the buffer
+ * @f: the fragment offset.
+ *
+ * Takes an additional reference on the @f'th paged fragment of @skb.
+ */
+static inline void skb_frag_ref(struct sk_buff *skb, int f)
+{
+	__skb_frag_ref(&skb_shinfo(skb)->frags[f]);
+}
+
+/**
+ * __skb_frag_unref - release a reference on a paged fragment.
+ * @frag: the paged fragment
+ *
+ * Releases a reference on the paged fragment @frag.
+ */
+static inline void __skb_frag_unref(skb_frag_t *frag)
+{
+	put_page(skb_frag_page(frag));
+}
+
+/**
+ * skb_frag_unref - release a reference on a paged fragment of an skb.
+ * @skb: the buffer
+ * @f: the fragment offset
+ *
+ * Releases a reference on the @f'th paged fragment of @skb.
+ */
+static inline void skb_frag_unref(struct sk_buff *skb, int f)
+{
+	__skb_frag_unref(&skb_shinfo(skb)->frags[f]);
+}
+
+/**
+ * skb_frag_address - gets the address of the data contained in a page=
d fragment
+ * @frag: the paged fragment buffer
+ *
+ * Returns the address of the data within @frag. The page must already
+ * be mapped.
+ */
+static inline void *skb_frag_address(const skb_frag_t *frag)
+{
+	return page_address(skb_frag_page(frag)) + frag->page_offset;
+}
+
+/**
+ * skb_frag_address_safe - gets the address of the data contained in a=
 paged fragment
+ * @frag: the paged fragment buffer
+ *
+ * Returns the address of the data within @frag. Checks that the page
+ * is mapped and returns %NULL otherwise.
+ */
+static inline void *skb_frag_address_safe(const skb_frag_t *frag)
+{
+	void *ptr =3D page_address(skb_frag_page(frag));
+	if (unlikely(!ptr))
+		return NULL;
+
+	return ptr + frag->page_offset;
+}
+
+/**
+ * __skb_frag_set_page - sets the page contained in a paged fragment
+ * @frag: the paged fragment
+ * @page: the page to set
+ *
+ * Sets the fragment @frag to contain @page.
+ */
+static inline void __skb_frag_set_page(skb_frag_t *frag, struct page *=
page)
+{
+	frag->page =3D page;
+	__skb_frag_ref(frag);
+}
+
+/**
+ * skb_frag_set_page - sets the page contained in a paged fragment of =
an skb
+ * @skb: the buffer
+ * @f: the fragment offset
+ * @page: the page to set
+ *
+ * Sets the @f'th fragment of @skb to contain @page.
+ */
+static inline void skb_frag_set_page(struct sk_buff *skb, int f,
+				     struct page *page)
+{
+	__skb_frag_set_page(&skb_shinfo(skb)->frags[f], page);
+}
+
+/**
+ * skb_frag_dma_map - maps a paged fragment via the DMA API
+ * @device: the device to map the fragment to
+ * @frag: the paged fragment to map
+ * @offset: the offset within the fragment (starting at the
+ *          fragment's own offset)
+ * @size: the number of bytes to map
+ * @direction: the direction of the mapping (%PCI_DMA_*)
+ *
+ * Maps the page associated with @frag to @device.
+ */
+static inline dma_addr_t skb_frag_dma_map(struct device *dev,
+					  const skb_frag_t *frag,
+					  size_t offset, size_t size,
+					  enum dma_data_direction dir)
+{
+	return dma_map_page(dev, skb_frag_page(frag),
+			    frag->page_offset + offset, size, dir);
+}
+
+/**
  *	skb_clone_writable - is the header of a clone writable
  *	@skb: buffer to check
  *	@len: length up to which to write
--=20
1.7.2.5
