From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 04/09: ebtables: add CONFIG_COMPAT support
Date: Thu, 18 Feb 2010 19:21:08 +0100 (MET)
Message-ID: <20100218182108.21826.29615.sendpatchset@x2.localnet>
References: <20100218182103.21826.17908.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100218182103.21826.17908.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 81e675c227ec60a0bdcbb547dc530ebee23ff931
Author: Florian Westphal <fwestphal@astaro.com>
Date:   Tue Jan 5 16:09:46 2010 +0100

    netfilter: ebtables: add CONFIG_COMPAT support
    
    Main code for 32 bit userland ebtables binary with 64 bit kernels
    support.
    
    Tested on x86_64 kernel only, using 64bit ebtables binary
    for output comparision.
    
    At least ebt_mark, m_mark and ebt_limit need CONFIG_COMPAT hooks, too.
    
    remaining problem:
    
    The ebtables userland makefile has:
    ifeq ($(shell uname -m),sparc64)
    	CFLAGS+=-DEBT_MIN_ALIGN=8 -DKERNEL_64_USERSPACE_32
    endif
    
    struct ebt_replace, ebt_entry_match etc. then contain userland-side
    padding, i.e.  even if we are called from a 32 bit userland, the
    structures may already be in the right format.
    
    This problem is addressed in a follow-up patch.
    
    Signed-off-by: Florian Westphal <fwestphal@astaro.com>

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 76b99d3..fcaefdd 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -51,11 +51,37 @@
 
 static DEFINE_MUTEX(ebt_mutex);
 
+#ifdef CONFIG_COMPAT
+static void ebt_standard_compat_from_user(void *dst, const void *src)
+{
+	int v = *(compat_int_t *)src;
+
+	if (v >= 0)
+		v += xt_compat_calc_jump(NFPROTO_BRIDGE, v);
+	memcpy(dst, &v, sizeof(v));
+}
+
+static int ebt_standard_compat_to_user(void __user *dst, const void *src)
+{
+	compat_int_t cv = *(int *)src;
+
+	if (cv >= 0)
+		cv -= xt_compat_calc_jump(NFPROTO_BRIDGE, cv);
+	return copy_to_user(dst, &cv, sizeof(cv)) ? -EFAULT : 0;
+}
+#endif
+
+
 static struct xt_target ebt_standard_target = {
 	.name       = "standard",
 	.revision   = 0,
 	.family     = NFPROTO_BRIDGE,
 	.targetsize = sizeof(int),
+#ifdef CONFIG_COMPAT
+	.compatsize = sizeof(compat_int_t),
+	.compat_from_user = ebt_standard_compat_from_user,
+	.compat_to_user =  ebt_standard_compat_to_user,
+#endif
 };
 
 static inline int
@@ -1454,7 +1480,7 @@ static int do_ebt_set_ctl(struct sock *sk,
 		break;
 	default:
 		ret = -EINVAL;
-  }
+	}
 	return ret;
 }
 
@@ -1514,15 +1540,874 @@ static int do_ebt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	return ret;
 }
 
+#ifdef CONFIG_COMPAT
+/* 32 bit-userspace compatibility definitions. */
+struct compat_ebt_replace {
+	char name[EBT_TABLE_MAXNAMELEN];
+	compat_uint_t valid_hooks;
+	compat_uint_t nentries;
+	compat_uint_t entries_size;
+	/* start of the chains */
+	compat_uptr_t hook_entry[NF_BR_NUMHOOKS];
+	/* nr of counters userspace expects back */
+	compat_uint_t num_counters;
+	/* where the kernel will put the old counters. */
+	compat_uptr_t counters;
+	compat_uptr_t entries;
+};
+
+/* struct ebt_entry_match, _target and _watcher have same layout */
+struct compat_ebt_entry_mwt {
+	union {
+		char name[EBT_FUNCTION_MAXNAMELEN];
+		compat_uptr_t ptr;
+	} u;
+	compat_uint_t match_size;
+	compat_uint_t data[0];
+};
+
+/* account for possible padding between match_size and ->data */
+static int ebt_compat_entry_padsize(void)
+{
+	BUILD_BUG_ON(XT_ALIGN(sizeof(struct ebt_entry_match)) <
+			COMPAT_XT_ALIGN(sizeof(struct compat_ebt_entry_mwt)));
+	return (int) XT_ALIGN(sizeof(struct ebt_entry_match)) -
+			COMPAT_XT_ALIGN(sizeof(struct compat_ebt_entry_mwt));
+}
+
+static int ebt_compat_match_offset(const struct xt_match *match,
+				   unsigned int userlen)
+{
+	/*
+	 * ebt_among needs special handling. The kernel .matchsize is
+	 * set to -1 at registration time; at runtime an EBT_ALIGN()ed
+	 * value is expected.
+	 * Example: userspace sends 4500, ebt_among.c wants 4504.
+	 */
+	if (unlikely(match->matchsize == -1))
+		return XT_ALIGN(userlen) - COMPAT_XT_ALIGN(userlen);
+	return xt_compat_match_offset(match);
+}
+
+static int compat_match_to_user(struct ebt_entry_match *m, void __user **dstptr,
+				unsigned int *size)
+{
+	const struct xt_match *match = m->u.match;
+	struct compat_ebt_entry_mwt __user *cm = *dstptr;
+	int off = ebt_compat_match_offset(match, m->match_size);
+	compat_uint_t msize = m->match_size - off;
+
+	BUG_ON(off >= m->match_size);
+
+	if (copy_to_user(cm->u.name, match->name,
+	    strlen(match->name) + 1) || put_user(msize, &cm->match_size))
+		return -EFAULT;
+
+	if (match->compat_to_user) {
+		if (match->compat_to_user(cm->data, m->data))
+			return -EFAULT;
+	} else if (copy_to_user(cm->data, m->data, msize))
+			return -EFAULT;
+
+	*size -= ebt_compat_entry_padsize() + off;
+	*dstptr = cm->data;
+	*dstptr += msize;
+	return 0;
+}
+
+static int compat_target_to_user(struct ebt_entry_target *t,
+				 void __user **dstptr,
+				 unsigned int *size)
+{
+	const struct xt_target *target = t->u.target;
+	struct compat_ebt_entry_mwt __user *cm = *dstptr;
+	int off = xt_compat_target_offset(target);
+	compat_uint_t tsize = t->target_size - off;
+
+	BUG_ON(off >= t->target_size);
+
+	if (copy_to_user(cm->u.name, target->name,
+	    strlen(target->name) + 1) || put_user(tsize, &cm->match_size))
+		return -EFAULT;
+
+	if (target->compat_to_user) {
+		if (target->compat_to_user(cm->data, t->data))
+			return -EFAULT;
+	} else if (copy_to_user(cm->data, t->data, tsize))
+		return -EFAULT;
+
+	*size -= ebt_compat_entry_padsize() + off;
+	*dstptr = cm->data;
+	*dstptr += tsize;
+	return 0;
+}
+
+static int compat_watcher_to_user(struct ebt_entry_watcher *w,
+				  void __user **dstptr,
+				  unsigned int *size)
+{
+	return compat_target_to_user((struct ebt_entry_target *)w,
+							dstptr, size);
+}
+
+static int compat_copy_entry_to_user(struct ebt_entry *e, void __user **dstptr,
+				unsigned int *size)
+{
+	struct ebt_entry_target *t;
+	struct ebt_entry __user *ce;
+	u32 watchers_offset, target_offset, next_offset;
+	compat_uint_t origsize;
+	int ret;
+
+	if (e->bitmask == 0) {
+		if (*size < sizeof(struct ebt_entries))
+			return -EINVAL;
+		if (copy_to_user(*dstptr, e, sizeof(struct ebt_entries)))
+			return -EFAULT;
+
+		*dstptr += sizeof(struct ebt_entries);
+		*size -= sizeof(struct ebt_entries);
+		return 0;
+	}
+
+	if (*size < sizeof(*ce))
+		return -EINVAL;
+
+	ce = (struct ebt_entry __user *)*dstptr;
+	if (copy_to_user(ce, e, sizeof(*ce)))
+		return -EFAULT;
+
+	origsize = *size;
+	*dstptr += sizeof(*ce);
+
+	ret = EBT_MATCH_ITERATE(e, compat_match_to_user, dstptr, size);
+	if (ret)
+		return ret;
+	watchers_offset = e->watchers_offset - (origsize - *size);
+
+	ret = EBT_WATCHER_ITERATE(e, compat_watcher_to_user, dstptr, size);
+	if (ret)
+		return ret;
+	target_offset = e->target_offset - (origsize - *size);
+
+	t = (struct ebt_entry_target *) ((char *) e + e->target_offset);
+
+	ret = compat_target_to_user(t, dstptr, size);
+	if (ret)
+		return ret;
+	next_offset = e->next_offset - (origsize - *size);
+
+	if (put_user(watchers_offset, &ce->watchers_offset) ||
+	    put_user(target_offset, &ce->target_offset) ||
+	    put_user(next_offset, &ce->next_offset))
+		return -EFAULT;
+
+	*size -= sizeof(*ce);
+	return 0;
+}
+
+static int compat_calc_match(struct ebt_entry_match *m, int *off)
+{
+	*off += ebt_compat_match_offset(m->u.match, m->match_size);
+	*off += ebt_compat_entry_padsize();
+	return 0;
+}
+
+static int compat_calc_watcher(struct ebt_entry_watcher *w, int *off)
+{
+	*off += xt_compat_target_offset(w->u.watcher);
+	*off += ebt_compat_entry_padsize();
+	return 0;
+}
+
+static int compat_calc_entry(const struct ebt_entry *e,
+			     const struct ebt_table_info *info,
+			     const void *base,
+			     struct compat_ebt_replace *newinfo)
+{
+	const struct ebt_entry_target *t;
+	unsigned int entry_offset;
+	int off, ret, i;
+
+	if (e->bitmask == 0)
+		return 0;
+
+	off = 0;
+	entry_offset = (void *)e - base;
+
+	EBT_MATCH_ITERATE(e, compat_calc_match, &off);
+	EBT_WATCHER_ITERATE(e, compat_calc_watcher, &off);
+
+	t = (const struct ebt_entry_target *) ((char *) e + e->target_offset);
+
+	off += xt_compat_target_offset(t->u.target);
+	off += ebt_compat_entry_padsize();
+
+	newinfo->entries_size -= off;
+
+	ret = xt_compat_add_offset(NFPROTO_BRIDGE, entry_offset, off);
+	if (ret)
+		return ret;
+
+	for (i = 0; i < NF_BR_NUMHOOKS; i++) {
+		const void *hookptr = info->hook_entry[i];
+		if (info->hook_entry[i] &&
+		    (e < (struct ebt_entry *)(base - hookptr))) {
+			newinfo->hook_entry[i] -= off;
+			pr_debug("0x%08X -> 0x%08X\n",
+					newinfo->hook_entry[i] + off,
+					newinfo->hook_entry[i]);
+		}
+	}
+
+	return 0;
+}
+
+
+static int compat_table_info(const struct ebt_table_info *info,
+			     struct compat_ebt_replace *newinfo)
+{
+	unsigned int size = info->entries_size;
+	const void *entries = info->entries;
+
+	newinfo->entries_size = size;
+
+	return EBT_ENTRY_ITERATE(entries, size, compat_calc_entry, info,
+							entries, newinfo);
+}
+
+static int compat_copy_everything_to_user(struct ebt_table *t,
+					  void __user *user, int *len, int cmd)
+{
+	struct compat_ebt_replace repl, tmp;
+	struct ebt_counter *oldcounters;
+	struct ebt_table_info tinfo;
+	int ret;
+	void __user *pos;
+
+	memset(&tinfo, 0, sizeof(tinfo));
+
+	if (cmd == EBT_SO_GET_ENTRIES) {
+		tinfo.entries_size = t->private->entries_size;
+		tinfo.nentries = t->private->nentries;
+		tinfo.entries = t->private->entries;
+		oldcounters = t->private->counters;
+	} else {
+		tinfo.entries_size = t->table->entries_size;
+		tinfo.nentries = t->table->nentries;
+		tinfo.entries = t->table->entries;
+		oldcounters = t->table->counters;
+	}
+
+	if (copy_from_user(&tmp, user, sizeof(tmp)))
+		return -EFAULT;
+
+	if (tmp.nentries != tinfo.nentries ||
+	   (tmp.num_counters && tmp.num_counters != tinfo.nentries))
+		return -EINVAL;
+
+	memcpy(&repl, &tmp, sizeof(repl));
+	if (cmd == EBT_SO_GET_ENTRIES)
+		ret = compat_table_info(t->private, &repl);
+	else
+		ret = compat_table_info(&tinfo, &repl);
+	if (ret)
+		return ret;
+
+	if (*len != sizeof(tmp) + repl.entries_size +
+	   (tmp.num_counters? tinfo.nentries * sizeof(struct ebt_counter): 0)) {
+		pr_err("wrong size: *len %d, entries_size %u, replsz %d\n",
+				*len, tinfo.entries_size, repl.entries_size);
+		return -EINVAL;
+	}
+
+	/* userspace might not need the counters */
+	ret = copy_counters_to_user(t, oldcounters, compat_ptr(tmp.counters),
+					tmp.num_counters, tinfo.nentries);
+	if (ret)
+		return ret;
+
+	pos = compat_ptr(tmp.entries);
+	return EBT_ENTRY_ITERATE(tinfo.entries, tinfo.entries_size,
+			compat_copy_entry_to_user, &pos, &tmp.entries_size);
+}
+
+struct ebt_entries_buf_state {
+	char *buf_kern_start;	/* kernel buffer to copy (translated) data to */
+	u32 buf_kern_len;	/* total size of kernel buffer */
+	u32 buf_kern_offset;	/* amount of data copied so far */
+	u32 buf_user_offset;	/* read position in userspace buffer */
+};
+
+static int ebt_buf_count(struct ebt_entries_buf_state *state, unsigned int sz)
+{
+	state->buf_kern_offset += sz;
+	return state->buf_kern_offset >= sz ? 0 : -EINVAL;
+}
+
+static int ebt_buf_add(struct ebt_entries_buf_state *state,
+		       void *data, unsigned int sz)
+{
+	if (state->buf_kern_start == NULL)
+		goto count_only;
+
+	BUG_ON(state->buf_kern_offset + sz > state->buf_kern_len);
+
+	memcpy(state->buf_kern_start + state->buf_kern_offset, data, sz);
+
+ count_only:
+	state->buf_user_offset += sz;
+	return ebt_buf_count(state, sz);
+}
+
+static int ebt_buf_add_pad(struct ebt_entries_buf_state *state, unsigned int sz)
+{
+	char *b = state->buf_kern_start;
+
+	BUG_ON(b && state->buf_kern_offset > state->buf_kern_len);
+
+	if (b != NULL && sz > 0)
+		memset(b + state->buf_kern_offset, 0, sz);
+	/* do not adjust ->buf_user_offset here, we added kernel-side padding */
+	return ebt_buf_count(state, sz);
+}
+
+enum compat_mwt {
+	EBT_COMPAT_MATCH,
+	EBT_COMPAT_WATCHER,
+	EBT_COMPAT_TARGET,
+};
+
+static int compat_mtw_from_user(struct compat_ebt_entry_mwt *mwt,
+				enum compat_mwt compat_mwt,
+				struct ebt_entries_buf_state *state,
+				const unsigned char *base)
+{
+	char name[EBT_FUNCTION_MAXNAMELEN];
+	struct xt_match *match;
+	struct xt_target *wt;
+	void *dst = NULL;
+	int off, pad = 0, ret = 0;
+	unsigned int size_kern, entry_offset, match_size = mwt->match_size;
+
+	strlcpy(name, mwt->u.name, sizeof(name));
+
+	if (state->buf_kern_start)
+		dst = state->buf_kern_start + state->buf_kern_offset;
+
+	entry_offset = (unsigned char *) mwt - base;
+	switch (compat_mwt) {
+	case EBT_COMPAT_MATCH:
+		match = try_then_request_module(xt_find_match(NFPROTO_BRIDGE,
+						name, 0), "ebt_%s", name);
+		if (match == NULL)
+			return -ENOENT;
+		if (IS_ERR(match))
+			return PTR_ERR(match);
+
+		off = ebt_compat_match_offset(match, match_size);
+		if (dst) {
+			if (match->compat_from_user)
+				match->compat_from_user(dst, mwt->data);
+			else
+				memcpy(dst, mwt->data, match_size);
+		}
+
+		size_kern = match->matchsize;
+		if (unlikely(size_kern == -1))
+			size_kern = match_size;
+		module_put(match->me);
+		break;
+	case EBT_COMPAT_WATCHER: /* fallthrough */
+	case EBT_COMPAT_TARGET:
+		wt = try_then_request_module(xt_find_target(NFPROTO_BRIDGE,
+						name, 0), "ebt_%s", name);
+		if (wt == NULL)
+			return -ENOENT;
+		if (IS_ERR(wt))
+			return PTR_ERR(wt);
+		off = xt_compat_target_offset(wt);
+
+		if (dst) {
+			if (wt->compat_from_user)
+				wt->compat_from_user(dst, mwt->data);
+			else
+				memcpy(dst, mwt->data, match_size);
+		}
+
+		size_kern = wt->targetsize;
+		module_put(wt->me);
+		break;
+	}
+
+	if (!dst) {
+		ret = xt_compat_add_offset(NFPROTO_BRIDGE, entry_offset,
+					off + ebt_compat_entry_padsize());
+		if (ret < 0)
+			return ret;
+	}
+
+	state->buf_kern_offset += match_size + off;
+	state->buf_user_offset += match_size;
+	pad = XT_ALIGN(size_kern) - size_kern;
+
+	if (pad > 0 && dst) {
+		BUG_ON(state->buf_kern_len <= pad);
+		BUG_ON(state->buf_kern_offset - (match_size + off) + size_kern > state->buf_kern_len - pad);
+		memset(dst + size_kern, 0, pad);
+	}
+	return off + match_size;
+}
+
+/*
+ * return size of all matches, watchers or target, including necessary
+ * alignment and padding.
+ */
+static int ebt_size_mwt(struct compat_ebt_entry_mwt *match32,
+			unsigned int size_left, enum compat_mwt type,
+			struct ebt_entries_buf_state *state, const void *base)
+{
+	int growth = 0;
+	char *buf;
+
+	if (size_left == 0)
+		return 0;
+
+	buf = (char *) match32;
+
+	while (size_left >= sizeof(*match32)) {
+		struct ebt_entry_match *match_kern;
+		int ret;
+
+		match_kern = (struct ebt_entry_match *) state->buf_kern_start;
+		if (match_kern) {
+			char *tmp;
+			tmp = state->buf_kern_start + state->buf_kern_offset;
+			match_kern = (struct ebt_entry_match *) tmp;
+		}
+		ret = ebt_buf_add(state, buf, sizeof(*match32));
+		if (ret < 0)
+			return ret;
+		size_left -= sizeof(*match32);
+
+		/* add padding before match->data (if any) */
+		ret = ebt_buf_add_pad(state, ebt_compat_entry_padsize());
+		if (ret < 0)
+			return ret;
+
+		if (match32->match_size > size_left)
+			return -EINVAL;
+
+		size_left -= match32->match_size;
+
+		ret = compat_mtw_from_user(match32, type, state, base);
+		if (ret < 0)
+			return ret;
+
+		BUG_ON(ret < match32->match_size);
+		growth += ret - match32->match_size;
+		growth += ebt_compat_entry_padsize();
+
+		buf += sizeof(*match32);
+		buf += match32->match_size;
+
+		if (match_kern)
+			match_kern->match_size = ret;
+
+		WARN_ON(type == EBT_COMPAT_TARGET && size_left);
+		match32 = (struct compat_ebt_entry_mwt *) buf;
+	}
+
+	return growth;
+}
+
+#define EBT_COMPAT_WATCHER_ITERATE(e, fn, args...)          \
+({                                                          \
+	unsigned int __i;                                   \
+	int __ret = 0;                                      \
+	struct compat_ebt_entry_mwt *__watcher;             \
+	                                                    \
+	for (__i = e->watchers_offset;                      \
+	     __i < (e)->target_offset;                      \
+	     __i += __watcher->watcher_size +               \
+	     sizeof(struct compat_ebt_entry_mwt)) {         \
+		__watcher = (void *)(e) + __i;              \
+		__ret = fn(__watcher , ## args);            \
+		if (__ret != 0)                             \
+			break;                              \
+	}                                                   \
+	if (__ret == 0) {                                   \
+		if (__i != (e)->target_offset)              \
+			__ret = -EINVAL;                    \
+	}                                                   \
+	__ret;                                              \
+})
+
+#define EBT_COMPAT_MATCH_ITERATE(e, fn, args...)            \
+({                                                          \
+	unsigned int __i;                                   \
+	int __ret = 0;                                      \
+	struct compat_ebt_entry_mwt *__match;               \
+	                                                    \
+	for (__i = sizeof(struct ebt_entry);                \
+	     __i < (e)->watchers_offset;                    \
+	     __i += __match->match_size +                   \
+	     sizeof(struct compat_ebt_entry_mwt)) {         \
+		__match = (void *)(e) + __i;                \
+		__ret = fn(__match , ## args);              \
+		if (__ret != 0)                             \
+			break;                              \
+	}                                                   \
+	if (__ret == 0) {                                   \
+		if (__i != (e)->watchers_offset)            \
+			__ret = -EINVAL;                    \
+	}                                                   \
+	__ret;                                              \
+})
+
+/* called for all ebt_entry structures. */
+static int size_entry_mwt(struct ebt_entry *entry, const unsigned char *base,
+			  unsigned int *total,
+			  struct ebt_entries_buf_state *state)
+{
+	unsigned int i, j, startoff, new_offset = 0;
+	/* stores match/watchers/targets & offset of next struct ebt_entry: */
+	unsigned int offsets[4];
+	unsigned int *offsets_update = NULL;
+	int ret;
+	char *buf_start;
+
+	if (*total < sizeof(struct ebt_entries))
+		return -EINVAL;
+
+	if (!entry->bitmask) {
+		*total -= sizeof(struct ebt_entries);
+		return ebt_buf_add(state, entry, sizeof(struct ebt_entries));
+	}
+	if (*total < sizeof(*entry) || entry->next_offset < sizeof(*entry))
+		return -EINVAL;
+
+	startoff = state->buf_user_offset;
+	/* pull in most part of ebt_entry, it does not need to be changed. */
+	ret = ebt_buf_add(state, entry,
+			offsetof(struct ebt_entry, watchers_offset));
+	if (ret < 0)
+		return ret;
+
+	offsets[0] = sizeof(struct ebt_entry); /* matches come first */
+	memcpy(&offsets[1], &entry->watchers_offset,
+			sizeof(offsets) - sizeof(offsets[0]));
+
+	if (state->buf_kern_start) {
+		buf_start = state->buf_kern_start + state->buf_kern_offset;
+		offsets_update = (unsigned int *) buf_start;
+	}
+	ret = ebt_buf_add(state, &offsets[1],
+			sizeof(offsets) - sizeof(offsets[0]));
+	if (ret < 0)
+		return ret;
+	buf_start = (char *) entry;
+	/*
+	 * 0: matches offset, always follows ebt_entry.
+	 * 1: watchers offset, from ebt_entry structure
+	 * 2: target offset, from ebt_entry structure
+	 * 3: next ebt_entry offset, from ebt_entry structure
+	 *
+	 * offsets are relative to beginning of struct ebt_entry (i.e., 0).
+	 */
+	for (i = 0, j = 1 ; j < 4 ; j++, i++) {
+		struct compat_ebt_entry_mwt *match32;
+		unsigned int size;
+		char *buf = buf_start;
+
+		buf = buf_start + offsets[i];
+		if (offsets[i] > offsets[j])
+			return -EINVAL;
+
+		match32 = (struct compat_ebt_entry_mwt *) buf;
+		size = offsets[j] - offsets[i];
+		ret = ebt_size_mwt(match32, size, i, state, base);
+		if (ret < 0)
+			return ret;
+		new_offset += ret;
+		if (offsets_update && new_offset) {
+			pr_debug("ebtables: change offset %d to %d\n",
+				offsets_update[i], offsets[j] + new_offset);
+			offsets_update[i] = offsets[j] + new_offset;
+		}
+	}
+
+	startoff = state->buf_user_offset - startoff;
+
+	BUG_ON(*total < startoff);
+	*total -= startoff;
+	return 0;
+}
+
+/*
+ * repl->entries_size is the size of the ebt_entry blob in userspace.
+ * It might need more memory when copied to a 64 bit kernel in case
+ * userspace is 32-bit. So, first task: find out how much memory is needed.
+ *
+ * Called before validation is performed.
+ */
+static int compat_copy_entries(unsigned char *data, unsigned int size_user,
+				struct ebt_entries_buf_state *state)
+{
+	unsigned int size_remaining = size_user;
+	int ret;
+
+	ret = EBT_ENTRY_ITERATE(data, size_user, size_entry_mwt, data,
+					&size_remaining, state);
+	if (ret < 0)
+		return ret;
+
+	WARN_ON(size_remaining);
+	return state->buf_kern_offset;
+}
+
+
+static int compat_copy_ebt_replace_from_user(struct ebt_replace *repl,
+					    void __user *user, unsigned int len)
+{
+	struct compat_ebt_replace tmp;
+	int i;
+
+	if (len < sizeof(tmp))
+		return -EINVAL;
+
+	if (copy_from_user(&tmp, user, sizeof(tmp)))
+		return -EFAULT;
+
+	if (len != sizeof(tmp) + tmp.entries_size)
+		return -EINVAL;
+
+	if (tmp.entries_size == 0)
+		return -EINVAL;
+
+	if (tmp.nentries >= ((INT_MAX - sizeof(struct ebt_table_info)) /
+			NR_CPUS - SMP_CACHE_BYTES) / sizeof(struct ebt_counter))
+		return -ENOMEM;
+	if (tmp.num_counters >= INT_MAX / sizeof(struct ebt_counter))
+		return -ENOMEM;
+
+	memcpy(repl, &tmp, offsetof(struct ebt_replace, hook_entry));
+
+	/* starting with hook_entry, 32 vs. 64 bit structures are different */
+	for (i = 0; i < NF_BR_NUMHOOKS; i++)
+		repl->hook_entry[i] = compat_ptr(tmp.hook_entry[i]);
+
+	repl->num_counters = tmp.num_counters;
+	repl->counters = compat_ptr(tmp.counters);
+	repl->entries = compat_ptr(tmp.entries);
+	return 0;
+}
+
+static int compat_do_replace(struct net *net, void __user *user,
+			     unsigned int len)
+{
+	int ret, i, countersize, size64;
+	struct ebt_table_info *newinfo;
+	struct ebt_replace tmp;
+	struct ebt_entries_buf_state state;
+	void *entries_tmp;
+
+	ret = compat_copy_ebt_replace_from_user(&tmp, user, len);
+	if (ret)
+		return ret;
+
+	countersize = COUNTER_OFFSET(tmp.nentries) * nr_cpu_ids;
+	newinfo = vmalloc(sizeof(*newinfo) + countersize);
+	if (!newinfo)
+		return -ENOMEM;
+
+	if (countersize)
+		memset(newinfo->counters, 0, countersize);
+
+	memset(&state, 0, sizeof(state));
+
+	newinfo->entries = vmalloc(tmp.entries_size);
+	if (!newinfo->entries) {
+		ret = -ENOMEM;
+		goto free_newinfo;
+	}
+	if (copy_from_user(
+	   newinfo->entries, tmp.entries, tmp.entries_size) != 0) {
+		ret = -EFAULT;
+		goto free_entries;
+	}
+
+	entries_tmp = newinfo->entries;
+
+	xt_compat_lock(NFPROTO_BRIDGE);
+
+	ret = compat_copy_entries(entries_tmp, tmp.entries_size, &state);
+	if (ret < 0)
+		goto out_unlock;
+
+	pr_debug("tmp.entries_size %d, kern off %d, user off %d delta %d\n",
+		tmp.entries_size, state.buf_kern_offset, state.buf_user_offset,
+		xt_compat_calc_jump(NFPROTO_BRIDGE, tmp.entries_size));
+
+	size64 = ret;
+	newinfo->entries = vmalloc(size64);
+	if (!newinfo->entries) {
+		vfree(entries_tmp);
+		ret = -ENOMEM;
+		goto out_unlock;
+	}
+
+	memset(&state, 0, sizeof(state));
+	state.buf_kern_start = newinfo->entries;
+	state.buf_kern_len = size64;
+
+	ret = compat_copy_entries(entries_tmp, tmp.entries_size, &state);
+	BUG_ON(ret < 0);	/* parses same data again */
+
+	vfree(entries_tmp);
+	tmp.entries_size = size64;
+
+	for (i = 0; i < NF_BR_NUMHOOKS; i++) {
+		char __user *usrptr;
+		if (tmp.hook_entry[i]) {
+			unsigned int delta;
+			usrptr = (char __user *) tmp.hook_entry[i];
+			delta = usrptr - tmp.entries;
+			usrptr += xt_compat_calc_jump(NFPROTO_BRIDGE, delta);
+			tmp.hook_entry[i] = (struct ebt_entries __user *)usrptr;
+		}
+	}
+
+	xt_compat_flush_offsets(NFPROTO_BRIDGE);
+	xt_compat_unlock(NFPROTO_BRIDGE);
+
+	ret = do_replace_finish(net, &tmp, newinfo);
+	if (ret == 0)
+		return ret;
+free_entries:
+	vfree(newinfo->entries);
+free_newinfo:
+	vfree(newinfo);
+	return ret;
+out_unlock:
+	xt_compat_flush_offsets(NFPROTO_BRIDGE);
+	xt_compat_unlock(NFPROTO_BRIDGE);
+	goto free_entries;
+}
+
+static int compat_update_counters(struct net *net, void __user *user,
+				  unsigned int len)
+{
+	struct compat_ebt_replace hlp;
+
+	if (copy_from_user(&hlp, user, sizeof(hlp)))
+		return -EFAULT;
+
+	if (len != sizeof(hlp) + hlp.num_counters * sizeof(struct ebt_counter))
+		return -EINVAL;
+
+	return do_update_counters(net, hlp.name, compat_ptr(hlp.counters),
+					hlp.num_counters, user, len);
+}
+
+static int compat_do_ebt_set_ctl(struct sock *sk,
+		int cmd, void __user *user, unsigned int len)
+{
+	int ret;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	switch (cmd) {
+	case EBT_SO_SET_ENTRIES:
+		ret = compat_do_replace(sock_net(sk), user, len);
+		break;
+	case EBT_SO_SET_COUNTERS:
+		ret = compat_update_counters(sock_net(sk), user, len);
+		break;
+	default:
+		ret = -EINVAL;
+  }
+	return ret;
+}
+
+static int compat_do_ebt_get_ctl(struct sock *sk, int cmd,
+		void __user *user, int *len)
+{
+	int ret;
+	struct compat_ebt_replace tmp;
+	struct ebt_table *t;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if ((cmd == EBT_SO_GET_INFO ||
+	     cmd == EBT_SO_GET_INIT_INFO) && *len != sizeof(tmp))
+			return -EINVAL;
+
+	if (copy_from_user(&tmp, user, sizeof(tmp)))
+		return -EFAULT;
+
+	t = find_table_lock(sock_net(sk), tmp.name, &ret, &ebt_mutex);
+	if (!t)
+		return ret;
+
+	xt_compat_lock(NFPROTO_BRIDGE);
+	switch (cmd) {
+	case EBT_SO_GET_INFO:
+		tmp.nentries = t->private->nentries;
+		ret = compat_table_info(t->private, &tmp);
+		if (ret)
+			goto out;
+		tmp.valid_hooks = t->valid_hooks;
+
+		if (copy_to_user(user, &tmp, *len) != 0) {
+			ret = -EFAULT;
+			break;
+		}
+		ret = 0;
+		break;
+	case EBT_SO_GET_INIT_INFO:
+		tmp.nentries = t->table->nentries;
+		tmp.entries_size = t->table->entries_size;
+		tmp.valid_hooks = t->table->valid_hooks;
+
+		if (copy_to_user(user, &tmp, *len) != 0) {
+			ret = -EFAULT;
+			break;
+		}
+		ret = 0;
+		break;
+	case EBT_SO_GET_ENTRIES:
+	case EBT_SO_GET_INIT_ENTRIES:
+		ret = compat_copy_everything_to_user(t, user, len, cmd);
+		break;
+	default:
+		ret = -EINVAL;
+	}
+ out:
+	xt_compat_flush_offsets(NFPROTO_BRIDGE);
+	xt_compat_unlock(NFPROTO_BRIDGE);
+	mutex_unlock(&ebt_mutex);
+	return ret;
+}
+#endif
+
 static struct nf_sockopt_ops ebt_sockopts =
 {
 	.pf		= PF_INET,
 	.set_optmin	= EBT_BASE_CTL,
 	.set_optmax	= EBT_SO_SET_MAX + 1,
 	.set		= do_ebt_set_ctl,
+#ifdef CONFIG_COMPAT
+	.compat_set	= compat_do_ebt_set_ctl,
+#endif
 	.get_optmin	= EBT_BASE_CTL,
 	.get_optmax	= EBT_SO_GET_MAX + 1,
 	.get		= do_ebt_get_ctl,
+#ifdef CONFIG_COMPAT
+	.compat_get	= compat_do_ebt_get_ctl,
+#endif
 	.owner		= THIS_MODULE,
 };
 
