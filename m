From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/5] [LIB] textsearch infrastructure
Date: Sat, 28 May 2005 00:47:59 +0200
Message-ID: <20050527224759.GH15391@postel.suug.ch>
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

Before a textsearch can be performed, a configuration must be created
by calling textsearch_prepare() specyfing the searching algorithm and
the pattern to match. The returned configuration may then be used for
an arbitary amount of times and even in parallel as long as you
provide a separate struct ts_state variable for every instance.

The actual search is performed by either calling textsearch_find_-
continuous() for linear text or by providing an own get_text()
implementation and calling textsearch_find(). Both functions will
returns the position of the first matching occurrence of the patern.
Subsequent matches may be retrived via textsearch_next() irrespective
of the linearity of the text.

Once you're done using a configuration you must give back the
allocted resources by calling textsearch_destroy().

Signed-off-by: Thomas Graf <tgraf@suug.ch>

---
commit bf7ae763f13d767bd039703b3ab4f5954561df39
tree ab065819ea6e966aa3db4f1c5935c421dd689d2e
parent fde09d4989b6c7b5183ffb3ec2076ff53dd6fa78
author Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 20:18:48 +0200
committer Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 20:18:48 +0200

 include/linux/textsearch.h |  196 ++++++++++++++++++++++++++++++++++++
 lib/Makefile               |    2 
 lib/textsearch.c           |  241 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 438 insertions(+), 1 deletion(-)

Index: include/linux/textsearch.h
===================================================================
--- /dev/null  (tree:b032d0d440d93aac252e656bd41df32ff5461e3a)
+++ ab065819ea6e966aa3db4f1c5935c421dd689d2e/include/linux/textsearch.h  (mode:100644)
@@ -0,0 +1,196 @@
+#ifndef __LINUX_TEXTSEARCH_H
+#define __LINUX_TEXTSEARCH_H
+
+#ifdef __KERNEL__
+
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/err.h>
+
+struct ts_config;
+
+/**
+ * struct ts_state - textsearch state
+ * @offset: offset for next match
+ * @args: for persistant variables of get_text()
+ */
+struct ts_state
+{
+	int			offset;
+	long			args[6];
+};
+
+/**
+ * struct ts_ops - textsearch operations
+ * @name: name of search algorithm
+ * @init: called upon initialization to prepare a search
+ * @find: does the actual matching on a prepared configuration
+ * @destroy: called upon destroyage of a configuration
+ * @owner: reference to algorithm module if existent
+ * @list: operations list we are on
+ */
+struct ts_ops
+{
+	const char		*name;
+	struct ts_config *	(*init)(const unsigned char *, size_t, int);
+	int			(*find)(struct ts_config *,
+					struct ts_state *);
+	void			(*destroy)(struct ts_config *);
+	unsigned char *		(*get_pattern)(struct ts_config *);
+	unsigned int		(*get_pattern_len)(struct ts_config *);
+	struct module		*owner;
+	struct list_head	list;
+};
+
+/**
+ * struct ts_config - textsearch configuration
+ * @ops: textsearch operations
+ * @get_text: callback to fetch text to search in
+ * @len: length of pattern
+ */
+struct ts_config
+{
+	struct ts_ops		*ops;
+
+	/**
+	 * get_text - return next chunk of text
+	 * @offset: Number of bytes consumed by the matcher
+	 * @dst: destination buffer
+	 * @conf: search configuration
+	 * @state: search state
+	 *
+	 * Gets called repeatedly until 0 is returned.Must assign a pointer
+	 * to the start of the next chunk of text to *dst and return the
+	 * length of the chunk or 0 if at the end. offset==0 indicates
+	 * a new search. May store/read persistant values in state->args[].
+	 */
+	int			(*get_text)(int offset, unsigned char **dst,
+					    struct ts_config *conf,
+					    struct ts_state *state);
+
+	/**
+	 * finish - called when the matching has been completed successful
+	 *          or not.
+	 * @conf: search configuration
+	 * @state: search state
+	 */
+	void			(*finish)(struct ts_config *conf,
+					  struct ts_state *state);
+};
+
+/**
+ * textsearch_next - continue search for a pattern in a text
+ * @conf: search configuration
+ * @state: search state
+ *
+ * Continues a search looking for more occurrences of the pattern.
+ * You must call textsearch_find() to search the first occurrence
+ * in order to reset the state.
+ *
+ * Returns the position of next occurance of the pattern or a
+ *         negative number if no match was found.
+ */ 
+static inline int textsearch_next(struct ts_config *conf,
+				  struct ts_state *state)
+{
+	int ret = conf->ops->find(conf, state);
+
+	if (conf->finish)
+		conf->finish(conf, state);
+
+	return ret;
+}
+
+/**
+ * textsearch_find - search for a pattern in a text
+ * @conf: search configuration
+ * @state: search state
+ *
+ * Peforms the actual search on the prepared configuration.
+ *
+ * Returns the position of first occurrence of the pattern or a
+ *         negative number if no match was found.
+ */ 
+static inline int textsearch_find(struct ts_config *conf,
+				  struct ts_state *state)
+{
+	state->offset = 0;
+	return textsearch_next(conf, state);
+}
+
+/**
+ * textsearch_destroy - destroy a textsearch configuration
+ * @conf: search configuration
+ *
+ * Releases all references of the configuration and frees
+ * up the memory.
+ */
+static inline void textsearch_destroy(struct ts_config *conf)
+{
+	if (conf->ops) {
+		if (conf->ops->destroy)
+			conf->ops->destroy(conf);
+		module_put(conf->ops->owner);
+	}
+
+	kfree(conf);
+}
+
+/**
+ * textsearch_get_pattern - return pattern of a textsearch configuration
+ * @conf: textsearch configuration
+ */
+static inline unsigned char *textsearch_get_pattern(struct ts_config *conf)
+{
+	return conf->ops->get_pattern(conf);
+}
+
+/**
+ * textsearch_get_pattern_len - return pattern length of a textsearch configuration
+ * @conf: textsearch configuration
+ */
+static inline unsigned int textsearch_get_pattern_len(struct ts_config *conf)
+{
+	return conf->ops->get_pattern_len(conf);
+}
+
+/**
+ * alloc_ts_config - allocate a textsearch configuration
+ * @payload: size of additional module specific data required
+ * @gfp_mask: allocation mask
+ *
+ * Returns a empty textsearch configuration or a ERR_PTR().
+ */
+static inline struct ts_config *alloc_ts_config(size_t payload, int gfp_mask)
+{
+	struct ts_config *conf;
+
+	conf = kmalloc(sizeof(*conf) + payload, gfp_mask);
+	if (conf == NULL)
+		return ERR_PTR(-ENOMEM);
+
+	memset(conf, 0, sizeof(*conf) + payload);
+	return conf;
+}
+
+/**
+ * ts_config_priv - returns private part of a textsearch configuration
+ * @conf: textsearch configuration
+ */
+static inline void *ts_config_priv(struct ts_config *conf)
+{
+	return ((unsigned char *) conf + sizeof(struct ts_config));
+}
+
+extern int textsearch_register(struct ts_ops *);
+extern int textsearch_unregister(struct ts_ops *);
+extern struct ts_config *textsearch_prepare(const char *, const unsigned char *,
+					    size_t, int, int);
+extern int textsearch_find_continuous(struct ts_config *, struct ts_state *,
+				      const unsigned char *, size_t);
+
+#endif /* __KERNEL__ */
+
+#endif
Index: lib/Makefile
===================================================================
--- b032d0d440d93aac252e656bd41df32ff5461e3a/lib/Makefile  (mode:100644)
+++ ab065819ea6e966aa3db4f1c5935c421dd689d2e/lib/Makefile  (mode:100644)
@@ -6,7 +6,7 @@
 	 bust_spinlocks.o rbtree.o radix-tree.o dump_stack.o \
 	 kobject.o kref.o idr.o div64.o int_sqrt.o \
 	 bitmap.o extable.o kobject_uevent.o prio_tree.o sha1.o \
-	 halfmd4.o
+	 halfmd4.o textsearch.o
 
 obj-y += sort.o parser.o
 
Index: lib/textsearch.c
===================================================================
--- /dev/null  (tree:b032d0d440d93aac252e656bd41df32ff5461e3a)
+++ ab065819ea6e966aa3db4f1c5935c421dd689d2e/lib/textsearch.c  (mode:100644)
@@ -0,0 +1,241 @@
+/*
+ * lib/textsearch.c	Generic text search interface
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Thomas Graf <tgraf@suug.ch>
+ *
+ * ==========================================================================
+ *
+ * The textsearch infrastructure provides text searching facitilies for both
+ * linear and non-linear data.
+ *
+ * Before a textsearch can be performed, a configuration must be created
+ * by calling textsearch_prepare() specyfing the searching algorithm and
+ * the pattern to match. The returned configuration may then be used for
+ * an arbitary amount of times and even in parallel as long as you
+ * provide a separate struct ts_state variable for every instance.
+ *
+ * The actual search is performed by either calling textsearch_find_-
+ * continuous() for linear text or by providing an own get_text()
+ * implementation and calling textsearch_find(). Both functions will
+ * returns the position of the first matching occurrence of the patern.
+ * Subsequent matches may be retrived via textsearch_next() irrespective
+ * of the linearity of the text.
+ *
+ * Once you're done using a configuration you must give back the
+ * allocted resources by calling textsearch_destroy().
+ *
+ * Example:
+ *   int pos;
+ *   struct ts_config *conf;
+ *   struct ts_state state;
+ *   conar char *pattern = "chicken";
+ *   const char *example = "We dance the funky chicken";
+ *
+ *   conf = textsearch_prepare("kmp", pattern, strlen(pattern), GFP_KERNEL, 1);
+ *   if (IS_ERR(conf)) {
+ *       err = PTR_ERR(conf);
+ *       goto errout;
+ *   }
+ *
+ *   pos = textsearch_find_continuous(conf, &state, example, strlen(example));
+ *   if (pos >= 0)
+ *       panic("Oh my god, dancing chickens at %d\n", pos);
+ *
+ *   textsearch_destroy(conf);
+ *
+ * ==========================================================================
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/string.h>
+#include <linux/err.h>
+#include <linux/textsearch.h>
+
+static LIST_HEAD(ts_ops);
+static DEFINE_RWLOCK(ts_mod_lock);
+
+static inline struct ts_ops *lookup_ts_algo(const char *name)
+{
+	struct ts_ops *o;
+
+	read_lock(&ts_mod_lock);
+	list_for_each_entry(o, &ts_ops, list) {
+		if (!strcmp(name, o->name)) {
+			if (!try_module_get(o->owner))
+				o = NULL;
+			read_unlock(&ts_mod_lock);
+			return o;
+		}
+	}
+	read_unlock(&ts_mod_lock);
+
+	return NULL;
+}
+
+/**
+ * textsearch_register - register a textsearch module
+ * @ops: operations lookup table
+ *
+ * This function must be called by textsearch modules to announce
+ * their presence. The given @ops must have %name set to a unique
+ * identifier and the callbacks find() and init() must be implemented.
+ *
+ * Returns -EEXISTS if another module has already registered with
+ *         same name.
+ */
+int textsearch_register(struct ts_ops *ops)
+{
+	int err = -EEXIST;
+	struct ts_ops *o;
+
+	if (ops->name == NULL || ops->find == NULL || ops->init == NULL ||
+	    ops->get_pattern == NULL || ops->get_pattern_len == NULL)
+		return -EINVAL;
+
+	write_lock(&ts_mod_lock);
+	list_for_each_entry(o, &ts_ops, list)
+		if (!strcmp(ops->name, o->name))
+			goto errout;
+
+	list_add_tail(&ops->list, &ts_ops);
+	err = 0;
+errout:
+	write_unlock(&ts_mod_lock);
+	return err;
+}
+
+/**
+ * textsearch_unregister - unregister a textsearch module
+ * @ops: operations lookup table
+ *
+ * This function must be called by textsearch modules to announce
+ * their disappearance for examples when the module gets unloaded.
+ * The @ops parameter must be the same as the one during the
+ * registration.
+ *
+ * Returns -ENOENT if no matching textsearch registration was found.
+ */
+int textsearch_unregister(struct ts_ops *ops)
+{
+	int err = 0;
+	struct ts_ops *o;
+
+	write_lock(&ts_mod_lock);
+	list_for_each_entry(o, &ts_ops, list) {
+		if (o == ops) {
+			list_del(&o->list);
+			goto out;
+		}
+	}
+
+	err = -ENOENT;
+out:
+	write_unlock(&ts_mod_lock);
+	return err;
+}
+
+static inline int get_linear_text(int offset, unsigned char **text,
+				  struct ts_config *conf,
+				  struct ts_state *state)
+{
+	unsigned char *string = (unsigned char *) state->args[0];
+	size_t len = state->args[1];
+
+	if (offset < len) {
+		*text = string + offset;
+		return len - offset;
+	} else
+		return 0;
+}
+
+/**
+ * textsearch_find_continuous - search a pattern in continuous/linear text
+ * @conf: search configuration
+ * @state: search state
+ * @text: text to search in
+ * @len: length of text
+ *
+ * A simplified version of textsearch_find() for continuous/linear text.
+ * Call textsearch_next() to retrieve subsequent matches.
+ *
+ * Returns the position of first occurrence of the pattern or a
+ *         negative number if no match was found.
+ */ 
+int textsearch_find_continuous(struct ts_config *conf, struct ts_state *state,
+			       const unsigned char *text, size_t len)
+{
+	conf->get_text = get_linear_text;
+	state->args[0] = (long) text;
+	state->args[1] = len;
+
+	return textsearch_find(conf, state);
+}
+
+/**
+ * textsearch_prepare - Prepare a text search
+ * @algo: name of search algorithm
+ * @pattern: pattern data
+ * @len: length of pattern
+ * @gfp_mask: allocation mask
+ * @autoload: bool indicating whether to autoload modules
+ *
+ * Looks up the search algorithm module and creates a new textsearch
+ * configuration for the specified pattern. Upon completion all
+ * necessary refcnts are held and the configuration must be put back
+ * using textsearch_put() after usage.
+ *
+ * Note: The format of the pattern may not be compatible between
+ *       the various search algorithms.
+ *
+ * Returns a new textsearch configuration according to the specified
+ *         parameters or a ERR_PTR().
+ */
+struct ts_config *textsearch_prepare(const char *algo,
+				     const unsigned char *pattern, size_t len,
+				     int gfp_mask, int autoload)
+{
+	int err = -ENOENT;
+	struct ts_config *conf;
+	struct ts_ops *ops;
+	
+	ops = lookup_ts_algo(algo);
+#ifdef CONFIG_KMOD
+	/* Why not always autoload you may ask. Some users may be
+	 * in a situation where requesting a module may deadlock,
+	 * especially when the module is located on a NFS mount. */
+	if (ops == NULL && autoload) {
+		request_module("ts_%s", algo);
+		ops = lookup_ts_algo(algo);
+	}
+#endif
+
+	if (ops == NULL)
+		goto errout;
+
+	conf = ops->init(pattern, len, gfp_mask);
+	if (IS_ERR(conf)) {
+		err = PTR_ERR(conf);
+		goto errout;
+	}
+
+	conf->ops = ops;
+	return conf;
+
+errout:
+	if (ops)
+		module_put(ops->owner);
+		
+	return ERR_PTR(err);
+}
+
+EXPORT_SYMBOL(textsearch_register);
+EXPORT_SYMBOL(textsearch_unregister);
+EXPORT_SYMBOL(textsearch_prepare);
+EXPORT_SYMBOL(textsearch_find_continuous);
