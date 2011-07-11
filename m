From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: introduce build_skb()
Date: Mon, 11 Jul 2011 07:46:46 +0200
Message-ID: <1310363206.2512.26.camel@edumazet-laptop>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
	 <ae7b531c89a01a21e4374907b69f4d997c9d5d1b.1310339688.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64703 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756495Ab1GKFqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 01:46:51 -0400
Received: by wwe5 with SMTP id 5so3573345wwe.1
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2011 22:46:50 -0700 (PDT)
In-Reply-To: <ae7b531c89a01a21e4374907b69f4d997c9d5d1b.1310339688.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 11 juillet 2011 =C3=A0 02:52 +0200, Micha=C5=82 Miros=C5=82aw =
a =C3=A9crit :
> Introduce __netdev_alloc_skb_aligned() to return skb with skb->data
> aligned at specified 2^n multiple.
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---

Hi Michal


Could we synchronize our work to not introduce things that might
disappear shortly ?

Here is the RFC patch about build_skb() :

[PATCH] net: introduce build_skb()

One of the thing we discussed during netdev 2011 conference was the ide=
a
to change network drivers to allocate/populate their skb at RX
completion time, right before feeding the skb to network stack.

Right now, we allocate skbs when populating the RX ring, and thats a
waste of CPU cache, since allocating skb means a full memset() to clear
the skb and its skb_shared_info portion. By the time NIC fills a frame
in data buffer and host can get it, cpu probably threw away the cache
lines from its caches, because of huge RX ring sizes.

So the deal would be to allocate only the data buffer for the NIC to
populate its RX ring buffer. And use build_skb() at RX completion to
attach a data buffer (now filled with an ethernet frame) to a new skb,
initialize the skb_shared_info portion, and give the hot skb to network
stack.

build_skb() is the function to allocate an skb, caller providing the
data buffer that should be attached to it. Drivers are expected to call=
=20
skb_reserve() right after build_skb() to let skb->data points to the
Ethernet frame (usually skipping NET_SKB_PAD and NET_IP_ALIGN)


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/skbuff.h |    1=20
 net/core/skbuff.c      |   48 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 49 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 32ada53..5e903e7 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -507,6 +507,7 @@ static inline struct rtable *skb_rtable(const struc=
t sk_buff *skb)
 extern void kfree_skb(struct sk_buff *skb);
 extern void consume_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
+extern struct sk_buff *build_skb(void *data, unsigned int size);
 extern struct sk_buff *__alloc_skb(unsigned int size,
 				   gfp_t priority, int fclone, int node);
 static inline struct sk_buff *alloc_skb(unsigned int size,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d220119..9193d7e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -234,6 +234,54 @@ nodata:
 EXPORT_SYMBOL(__alloc_skb);
=20
 /**
+ * build_skb - build a network buffer
+ * @data: data buffer provider by caller
+ * @size: size of data buffer, not including skb_shared_info
+ *
+ * Allocate a new &sk_buff. Caller provides space holding head and
+ * skb_shared_info. Mostly used in driver RX path.
+ * The return is the buffer. On a failure the return is %NULL.
+ * Notes :
+ *  Before IO, driver allocates only data buffer where NIC put incomin=
g frame
+ *  Driver SHOULD add room at head (NET_SKB_PAD) and
+ *  MUST add room tail (to hold skb_shared_info)
+ *  After IO, driver calls build_skb(), to get a hot skb instead of a =
cold one
+ *  before giving packet to stack. RX rings only contains data buffers=
, not
+ *  full skbs.
+ */
+struct sk_buff *build_skb(void *data, unsigned int size)
+{
+	struct skb_shared_info *shinfo;
+	struct sk_buff *skb;
+
+	skb =3D kmem_cache_alloc(skbuff_head_cache, GFP_ATOMIC);
+	if (!skb)
+		return NULL;
+
+	size =3D SKB_DATA_ALIGN(size);
+
+	memset(skb, 0, offsetof(struct sk_buff, tail));
+	skb->truesize =3D size + sizeof(struct sk_buff);
+	atomic_set(&skb->users, 1);
+	skb->head =3D data;
+	skb->data =3D data;
+	skb_reset_tail_pointer(skb);
+	skb->end =3D skb->tail + size;
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	skb->mac_header =3D ~0U;
+#endif
+
+	/* make sure we initialize shinfo sequentially */
+	shinfo =3D skb_shinfo(skb);
+	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
+	atomic_set(&shinfo->dataref, 1);
+	kmemcheck_annotate_variable(shinfo->destructor_arg);
+
+	return skb;
+}
+EXPORT_SYMBOL(build_skb);
+
+/**
  *	__netdev_alloc_skb - allocate an skbuff for rx on a specific device
  *	@dev: network device to receive on
  *	@length: length to allocate


