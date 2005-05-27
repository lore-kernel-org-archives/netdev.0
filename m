From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/5] [PKT_SCHED] textsearch ematch
Date: Sat, 28 May 2005 00:49:18 +0200
Message-ID: <20050527224918.GL15391@postel.suug.ch>
References: <20050527224725.GG15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050527224725.GG15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Signed-off-by: Thomas Graf <tgraf@suug.ch>

---
commit 5d28d54b48451e7833295be68b7e4b6fcc2b5375
tree cc252d153b4b21f347aab71bbfe04c0bf2a3a8a2
parent 4fdcfba0bf99efed709bc8ebaeda0d5ed7e9cc67
author Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 23:45:15 +0200
committer Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 23:45:15 +0200

 include/linux/pkt_cls.h              |    1 
 include/linux/tc_ematch/tc_em_text.h |   19 ++++
 net/sched/Kconfig                    |   11 ++
 net/sched/Makefile                   |    1 
 net/sched/em_text.c                  |  142 +++++++++++++++++++++++++++++++++++
 5 files changed, 174 insertions(+)

Index: include/linux/pkt_cls.h
===================================================================
--- 13ce1cd98014267f2a353b96e813c1e70bbe9c3b/include/linux/pkt_cls.h  (mode:100644)
+++ cc252d153b4b21f347aab71bbfe04c0bf2a3a8a2/include/linux/pkt_cls.h  (mode:100644)
@@ -408,6 +408,7 @@
 	TCF_EM_NBYTE,
 	TCF_EM_U32,
 	TCF_EM_META,
+	TCF_EM_TEXT,
 	__TCF_EM_MAX
 };
 
Index: include/linux/tc_ematch/tc_em_text.h
===================================================================
--- /dev/null  (tree:13ce1cd98014267f2a353b96e813c1e70bbe9c3b)
+++ cc252d153b4b21f347aab71bbfe04c0bf2a3a8a2/include/linux/tc_ematch/tc_em_text.h  (mode:100644)
@@ -0,0 +1,19 @@
+#ifndef __LINUX_TC_EM_TEXT_H
+#define __LINUX_TC_EM_TEXT_H
+
+#include <linux/pkt_cls.h>
+
+#define TC_EM_TEXT_ALGOSIZ	16
+
+struct tcf_em_text
+{
+	char		algo[TC_EM_TEXT_ALGOSIZ];
+	__u16		from_offset;
+	__u16		to_offset;
+	__u16		pattern_len;
+	__u8		from_layer:4;
+	__u8		to_layer:4;
+	__u8		pad;
+};
+
+#endif
Index: net/sched/Kconfig
===================================================================
--- 13ce1cd98014267f2a353b96e813c1e70bbe9c3b/net/sched/Kconfig  (mode:100644)
+++ cc252d153b4b21f347aab71bbfe04c0bf2a3a8a2/net/sched/Kconfig  (mode:100644)
@@ -449,6 +449,17 @@
 	  To compile this code as a module, choose M here: the
 	  module will be called em_meta.
 
+config NET_EMATCH_TEXT
+	tristate "Textsearch"
+	depends on NET_EMATCH
+	---help---
+	  Say Y here if you want to be ablt to classify packets based on
+	  textsearch comparisons. Please select the appropriate textsearch
+	  algorithms in the Library section.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called em_text.
+
 config NET_CLS_ACT
 	bool "Packet ACTION"
 	depends on EXPERIMENTAL && NET_CLS && NET_QOS
Index: net/sched/Makefile
===================================================================
--- 13ce1cd98014267f2a353b96e813c1e70bbe9c3b/net/sched/Makefile  (mode:100644)
+++ cc252d153b4b21f347aab71bbfe04c0bf2a3a8a2/net/sched/Makefile  (mode:100644)
@@ -40,3 +40,4 @@
 obj-$(CONFIG_NET_EMATCH_NBYTE)	+= em_nbyte.o
 obj-$(CONFIG_NET_EMATCH_U32)	+= em_u32.o
 obj-$(CONFIG_NET_EMATCH_META)	+= em_meta.o
+obj-$(CONFIG_NET_EMATCH_TEXT)	+= em_text.o
Index: net/sched/em_text.c
===================================================================
--- /dev/null  (tree:13ce1cd98014267f2a353b96e813c1e70bbe9c3b)
+++ cc252d153b4b21f347aab71bbfe04c0bf2a3a8a2/net/sched/em_text.c  (mode:100644)
@@ -0,0 +1,142 @@
+/*
+ * net/sched/em_text.c	Textsearch ematch
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
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/skbuff.h>
+#include <linux/textsearch.h>
+#include <linux/tc_ematch/tc_em_text.h>
+#include <net/pkt_cls.h>
+
+struct text_match
+{
+	u16			from_offset;
+	u16			to_offset;
+	u8			from_layer;
+	u8			to_layer;
+	struct ts_config	*config;
+};
+
+static int em_text_match(struct sk_buff *skb, struct tcf_ematch *m,
+			 struct tcf_pkt_info *info)
+{
+	struct text_match *tm = (struct text_match *) m->data;
+	int from, to;
+	struct ts_state state;
+
+	from = tcf_get_base_ptr(skb, tm->from_layer) - skb->data;
+	from += tm->from_offset;
+	to = tcf_get_base_ptr(skb, tm->to_layer) - skb->data;
+	to += tm->to_offset;
+
+	if (skb_find_text(skb, from, to, tm->config, &state) < 0)
+		return 0;
+
+	return 1;
+}
+
+static int em_text_change(struct tcf_proto *tp, void *data, int len,
+			  struct tcf_ematch *m)
+{
+	struct text_match *tm;
+	struct tcf_em_text *conf = data;
+	struct ts_config *ts_conf;
+
+	if (len < sizeof(*conf) ||
+	    len < (sizeof(*conf) + conf->pattern_len))
+		return -EINVAL;
+
+	if (conf->from_layer > conf->to_layer)
+		return -EINVAL;
+
+	if (conf->from_layer == conf->to_layer &&
+	    conf->from_offset > conf->to_offset)
+		return -EINVAL;
+
+	ts_conf = textsearch_prepare(conf->algo, (char *) conf + sizeof(*conf),
+				     conf->pattern_len, GFP_KERNEL, 1);
+	if (IS_ERR(ts_conf))
+		return PTR_ERR(ts_conf);
+
+	tm = kmalloc(sizeof(*tm), GFP_KERNEL);
+	if (tm == NULL) {
+		textsearch_destroy(ts_conf);
+		return -ENOBUFS;
+	}
+
+	tm->from_offset = conf->from_offset;
+	tm->to_offset   = conf->to_offset;
+	tm->from_layer  = conf->from_layer;
+	tm->to_layer    = conf->to_layer;
+	tm->config      = ts_conf;
+
+	m->datalen = sizeof(*tm);
+	m->data = (unsigned long) tm;
+
+	return 0;
+}
+
+static void em_text_destroy(struct tcf_proto *tp, struct tcf_ematch *m)
+{
+	struct text_match *tm = (struct text_match *) m->data;
+	textsearch_destroy(tm->config);
+}
+
+static int em_text_dump(struct sk_buff *skb, struct tcf_ematch *m)
+{
+	struct text_match *tm = (struct text_match *) m->data;
+	struct tcf_em_text conf;
+
+	strncpy(conf.algo, tm->config->ops->name, sizeof(conf.algo) - 1);
+	conf.from_offset = tm->from_offset;
+	conf.to_offset = tm->to_offset;
+	conf.from_layer = tm->from_layer;
+	conf.to_layer = tm->to_layer;
+	conf.pattern_len = textsearch_get_pattern_len(tm->config);
+	conf.pad = 0;
+
+	RTA_PUT_NOHDR(skb, sizeof(conf), &conf);
+	RTA_PUT_NOHDR(skb, conf.pattern_len,
+		      textsearch_get_pattern(tm->config));
+	return 0;
+
+rtattr_failure:
+	return -1;
+}		
+
+static struct tcf_ematch_ops em_text_ops = {
+	.kind	  = TCF_EM_TEXT,
+	.change	  = em_text_change,
+	.match	  = em_text_match,
+	.destroy  = em_text_destroy,
+	.dump	  = em_text_dump,
+	.owner	  = THIS_MODULE,
+	.link	  = LIST_HEAD_INIT(em_text_ops.link)
+};
+
+static int __init init_em_text(void)
+{
+	return tcf_em_register(&em_text_ops);
+}
+
+static void __exit exit_em_text(void) 
+{
+	tcf_em_unregister(&em_text_ops);
+}
+
+MODULE_LICENSE("GPL");
+
+module_init(init_em_text);
+module_exit(exit_em_text);
