From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: Wed, 5 Jan 2005 12:00:48 +0100
Message-ID: <20050105110048.GO26856@postel.suug.ch>
References: <20050103125635.GB26856@postel.suug.ch> <20050104223612.GN26856@postel.suug.ch> <1104894728.1117.56.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104894728.1117.56.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104894728.1117.56.camel@jzny.localdomain> 2005-01-04 22:12
> On Tue, 2005-01-04 at 17:36, Thomas Graf wrote:
> 
> >  * TCF_EM_SIMPLE flag which marks an ematch config as simple, meaning
> >    that the data consists of a u32 value.
> 
> This is 1 of 2 parts i think thats still an issue; otherwise looks very
> good. 
> Why do i need to signal something as simple? AND why does it have to be
> 32 bit type - what edge does that give you?

You don't have to, providing a 32bit data chunk without TCF_EM_SIMPLE
set will simply result in allocating & copy. It's an optimization,
nothing more.

> I should be able to specify a struct with two 32 bits and 
> encap it in a TLV and the classifier can treat it the same way - it
> knows the type and length - thats sufficient to create, destroy and
> dump.

Correct, maybe you're right and I should drop it again.

> The other issue is still on the ematch/match interleaving i.e i should
> be able to say something along the lines:
> 
> //simple slammer-worm or code-red ACL detector rule 
> //using u32 classifier and ematches
> (match ip protocol udp port 1434 AND
> ematch packetlen minsize 404 maxsize 404) OR
> (match ip protocol tcp http AND 
> ematch urlscanner "*.ida") 
> action ipt -j ULOG "Virus detected and dropped"
> action drop
> 
> Not a very good example - but you can see how powerfull this is when you
> can quickly use a string scanner such as the one you have as an ematch
> while maintaining u32 as is.

Basically you could do that already with the basic classifier but
I understand your concern and it would be neat to benefit from u32's
hashing. There are 2 options:
  1) We make u32 hold multiple ematch trees, a u32 key can be of 3
     kinds: u32/ematch/container. It's kind of a hack and not very
     fast due to a lot of stack movement.
  2) We make the existing u32 match be an ematch which I already did
     expect for the nexthdr bits. That is the select will simply be
     replaced by an ematch tree. I'll take a look into how we could
     have the classifier take influence on the ematches config data.
     One possibiliy is to have a struct transfered via map which
     contains useful data such as offset to next header (u32/rsvp).
     I have to think about this a little more though.

Personally I'm all for 2) because it's just cleaner and easier to
maintain. It's probably the best to not to use the u32 ematch I
wrote (which I renamed to cmp) but to write a new one behaving
exactly the same as the existing u32 match.

Attached cmp ematch (formerly u32), it was on diet for a while
and is quite smallish now.

diff -Nru linux-2.6.10-bk6.orig/include/linux/pkt_cls.h linux-2.6.10-bk6/include/linux/pkt_cls.h
--- linux-2.6.10-bk6.orig/include/linux/pkt_cls.h	2005-01-05 01:09:29.000000000 +0100
+++ linux-2.6.10-bk6/include/linux/pkt_cls.h	2005-01-05 01:46:34.000000000 +0100
@@ -349,6 +349,7 @@
 enum
 {
 	TCF_EM_CONTAINER,
+	TCF_EM_CMP,
 	__TCF_EM_MAX
 };
 
@@ -366,4 +367,28 @@
 #define TCF_EM_INVERT	(1<<3)
 #define TCF_EM_SIMPLE	(1<<4)
 
+struct tcf_em_cmp
+{
+	__u32		val;
+	__u32		mask;
+	__u16		off;
+	__u8		align;
+	__u8		layer:4;
+	__u8		opnd:4;
+};
+
+enum
+{
+	TCF_EM_ALIGN_U8  = 1,
+	TCF_EM_ALIGN_U16 = 2,
+	TCF_EM_ALIGN_U32 = 4
+};
+
+enum
+{
+	TCF_EM_OPND_EQ,
+	TCF_EM_OPND_GT,
+	TCF_EM_OPND_LT
+};
+
 #endif
diff -Nru linux-2.6.10-bk6.orig/include/net/pkt_cls.h linux-2.6.10-bk6/include/net/pkt_cls.h
--- linux-2.6.10-bk6.orig/include/net/pkt_cls.h	2005-01-05 01:09:29.000000000 +0100
+++ linux-2.6.10-bk6/include/net/pkt_cls.h	2005-01-05 01:26:03.000000000 +0100
@@ -270,6 +270,36 @@
 
 #endif /* CONFIG_NET_EMATCH */
 
+static inline u32 tcf_read_bucket(u8 *ptr, u8 align)
+{
+	switch (align) {
+		case TCF_EM_ALIGN_U8:
+			return *ptr;
+		case TCF_EM_ALIGN_U16:
+			return (*ptr << 8) | *(ptr+1);
+		case TCF_EM_ALIGN_U32:
+			return (*ptr << 24) | (*(ptr+1) << 16) |
+				(*(ptr+2) << 8) | *(ptr+3);
+	}
+	return 0;
+}
+
+static inline u8 * tcf_get_base_ptr(struct sk_buff *skb, u8 layer)
+{
+	switch (layer) {
+		case 0:
+			return skb->data;
+		case 1:
+			return skb->nh.raw;
+		case 2:
+			return skb->h.raw;
+	}
+	return NULL;
+}
+
+#define tcf_valid_offset(skb, ptr, off, len) \
+	((ptr + off + len) < skb->tail && (ptr + off) > skb->head)
+
 #ifdef CONFIG_NET_CLS_IND
 static inline int
 tcf_change_indev(struct tcf_proto *tp, char *indev, struct rtattr *indev_tlv)
diff -Nru linux-2.6.10-bk6.orig/net/sched/Kconfig linux-2.6.10-bk6/net/sched/Kconfig
--- linux-2.6.10-bk6.orig/net/sched/Kconfig	2005-01-05 01:09:29.000000000 +0100
+++ linux-2.6.10-bk6/net/sched/Kconfig	2005-01-05 01:34:38.000000000 +0100
@@ -388,6 +388,16 @@
 	  You must have a recent version of the iproute2 tools in order to use
 	  extended matches.
 
+config NET_EMATCH_CMP
+	tristate "Simple packet data comparison"
+	depends on NET_EMATCH
+	---help---
+	  Say Y here if you want to be able to classify packets based on
+	  simple packet data comparisons for 8, 16, and 32bit values.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called em_cmp.
+
 config NET_CLS_ACT
 	bool "Packet ACTION"
 	depends on EXPERIMENTAL && NET_CLS && NET_QOS
diff -Nru linux-2.6.10-bk6.orig/net/sched/Makefile linux-2.6.10-bk6/net/sched/Makefile
--- linux-2.6.10-bk6.orig/net/sched/Makefile	2005-01-05 01:09:29.000000000 +0100
+++ linux-2.6.10-bk6/net/sched/Makefile	2005-01-05 01:28:03.000000000 +0100
@@ -34,3 +34,4 @@
 obj-$(CONFIG_NET_CLS_TCINDEX)	+= cls_tcindex.o
 obj-$(CONFIG_NET_CLS_RSVP6)	+= cls_rsvp6.o
 obj-$(CONFIG_NET_EMATCH)	+= ematch.o
+obj-$(CONFIG_NET_EMATCH_CMP)	+= em_cmp.o
diff -Nru linux-2.6.10-bk6.orig/net/sched/em_cmp.c linux-2.6.10-bk6/net/sched/em_cmp.c
--- linux-2.6.10-bk6.orig/net/sched/em_cmp.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.10-bk6/net/sched/em_cmp.c	2005-01-05 01:47:00.000000000 +0100
@@ -0,0 +1,66 @@
+/*
+ * net/sched/em_cmp.c	Simple packet data comparison ematch
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Thomas Graf <tgraf@suug.ch>
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/skbuff.h>
+#include <net/pkt_cls.h>
+
+static int em_cmp_match(struct sk_buff *skb, struct tcf_ematch *m)
+{
+	struct tcf_em_cmp *u = (struct tcf_em_cmp *) m->data;
+	u8 *ptr = tcf_get_base_ptr(skb, u->layer);
+	u32 v;
+
+	if (unlikely(!tcf_valid_offset(skb, ptr, u->off, u->align)))
+		return 0;
+
+	v = tcf_read_bucket(ptr + u->off, u->align) & u->mask;
+
+	/* FIXME: byte order issues */
+
+	switch (u->opnd) {
+		case TCF_EM_OPND_EQ:
+			return v == u->val;
+		case TCF_EM_OPND_LT:
+			return v < u->val;
+		case TCF_EM_OPND_GT:
+			return v > u->val;
+	}
+	
+	return 0;
+}
+
+static struct tcf_ematch_ops em_cmp_ops = {
+	.kind	  = TCF_EM_CMP,
+	.datalen  = sizeof(struct tcf_em_cmp),
+	.match	  = em_cmp_match,
+	.owner	  = THIS_MODULE,
+	.link	  = LIST_HEAD_INIT(em_cmp_ops.link)
+};
+
+static int __init init_em_cmp(void)
+{
+	return tcf_em_register(&em_cmp_ops);
+}
+
+static void __exit exit_em_cmp(void) 
+{
+	tcf_em_unregister(&em_cmp_ops);
+}
+
+MODULE_LICENSE("GPL");
+
+module_init(init_em_cmp);
+module_exit(exit_em_cmp);
+
