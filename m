From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 28/36] netfilter: x_tables: get rid of old and inconsistent debugging
Date: Mon,  9 May 2016 20:46:46 +0200
Message-ID: <1462819614-5402-29-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dprintf() and duprintf() functions are enabled at compile time,
these days we have better runtime debugging through pr_debug() and
static keys.

On top of this, this debugging is so old that I don't expect anyone
using this anymore, so let's get rid of this.

IP_NF_ASSERT() is still left in place, although this needs that
NETFILTER_DEBUG is enabled, I think these assertions provide useful
context information when reading the code.

Note that ARP_NF_ASSERT() has been removed as there is no user of
this.

Kill also DEBUG_ALLOW_ALL and a couple of pr_error() and pr_debug()
spots that are inconsistently placed in the code.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/arp_tables.c | 217 ++++++-----------------------------
 net/ipv4/netfilter/ip_tables.c  | 244 +++++++---------------------------------
 net/ipv6/netfilter/ip6_tables.c | 229 +++++++------------------------------
 3 files changed, 117 insertions(+), 573 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 3355ed7..2033f92 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -34,27 +34,6 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("David S. Miller <davem@redhat.com>");
 MODULE_DESCRIPTION("arptables core");
 
-/*#define DEBUG_ARP_TABLES*/
-/*#define DEBUG_ARP_TABLES_USER*/
-
-#ifdef DEBUG_ARP_TABLES
-#define dprintf(format, args...)  pr_debug(format, ## args)
-#else
-#define dprintf(format, args...)
-#endif
-
-#ifdef DEBUG_ARP_TABLES_USER
-#define duprintf(format, args...) pr_debug(format, ## args)
-#else
-#define duprintf(format, args...)
-#endif
-
-#ifdef CONFIG_NETFILTER_DEBUG
-#define ARP_NF_ASSERT(x)	WARN_ON(!(x))
-#else
-#define ARP_NF_ASSERT(x)
-#endif
-
 void *arpt_alloc_initial_table(const struct xt_table *info)
 {
 	return xt_alloc_initial_table(arpt, ARPT);
@@ -113,36 +92,20 @@ static inline int arp_packet_match(const struct arphdr *arphdr,
 #define FWINV(bool, invflg) ((bool) ^ !!(arpinfo->invflags & (invflg)))
 
 	if (FWINV((arphdr->ar_op & arpinfo->arpop_mask) != arpinfo->arpop,
-		  ARPT_INV_ARPOP)) {
-		dprintf("ARP operation field mismatch.\n");
-		dprintf("ar_op: %04x info->arpop: %04x info->arpop_mask: %04x\n",
-			arphdr->ar_op, arpinfo->arpop, arpinfo->arpop_mask);
+		  ARPT_INV_ARPOP))
 		return 0;
-	}
 
 	if (FWINV((arphdr->ar_hrd & arpinfo->arhrd_mask) != arpinfo->arhrd,
-		  ARPT_INV_ARPHRD)) {
-		dprintf("ARP hardware address format mismatch.\n");
-		dprintf("ar_hrd: %04x info->arhrd: %04x info->arhrd_mask: %04x\n",
-			arphdr->ar_hrd, arpinfo->arhrd, arpinfo->arhrd_mask);
+		  ARPT_INV_ARPHRD))
 		return 0;
-	}
 
 	if (FWINV((arphdr->ar_pro & arpinfo->arpro_mask) != arpinfo->arpro,
-		  ARPT_INV_ARPPRO)) {
-		dprintf("ARP protocol address format mismatch.\n");
-		dprintf("ar_pro: %04x info->arpro: %04x info->arpro_mask: %04x\n",
-			arphdr->ar_pro, arpinfo->arpro, arpinfo->arpro_mask);
+		  ARPT_INV_ARPPRO))
 		return 0;
-	}
 
 	if (FWINV((arphdr->ar_hln & arpinfo->arhln_mask) != arpinfo->arhln,
-		  ARPT_INV_ARPHLN)) {
-		dprintf("ARP hardware address length mismatch.\n");
-		dprintf("ar_hln: %02x info->arhln: %02x info->arhln_mask: %02x\n",
-			arphdr->ar_hln, arpinfo->arhln, arpinfo->arhln_mask);
+		  ARPT_INV_ARPHLN))
 		return 0;
-	}
 
 	src_devaddr = arpptr;
 	arpptr += dev->addr_len;
@@ -155,49 +118,25 @@ static inline int arp_packet_match(const struct arphdr *arphdr,
 	if (FWINV(arp_devaddr_compare(&arpinfo->src_devaddr, src_devaddr, dev->addr_len),
 		  ARPT_INV_SRCDEVADDR) ||
 	    FWINV(arp_devaddr_compare(&arpinfo->tgt_devaddr, tgt_devaddr, dev->addr_len),
-		  ARPT_INV_TGTDEVADDR)) {
-		dprintf("Source or target device address mismatch.\n");
-
+		  ARPT_INV_TGTDEVADDR))
 		return 0;
-	}
 
 	if (FWINV((src_ipaddr & arpinfo->smsk.s_addr) != arpinfo->src.s_addr,
 		  ARPT_INV_SRCIP) ||
 	    FWINV(((tgt_ipaddr & arpinfo->tmsk.s_addr) != arpinfo->tgt.s_addr),
-		  ARPT_INV_TGTIP)) {
-		dprintf("Source or target IP address mismatch.\n");
-
-		dprintf("SRC: %pI4. Mask: %pI4. Target: %pI4.%s\n",
-			&src_ipaddr,
-			&arpinfo->smsk.s_addr,
-			&arpinfo->src.s_addr,
-			arpinfo->invflags & ARPT_INV_SRCIP ? " (INV)" : "");
-		dprintf("TGT: %pI4 Mask: %pI4 Target: %pI4.%s\n",
-			&tgt_ipaddr,
-			&arpinfo->tmsk.s_addr,
-			&arpinfo->tgt.s_addr,
-			arpinfo->invflags & ARPT_INV_TGTIP ? " (INV)" : "");
+		  ARPT_INV_TGTIP))
 		return 0;
-	}
 
 	/* Look for ifname matches.  */
 	ret = ifname_compare(indev, arpinfo->iniface, arpinfo->iniface_mask);
 
-	if (FWINV(ret != 0, ARPT_INV_VIA_IN)) {
-		dprintf("VIA in mismatch (%s vs %s).%s\n",
-			indev, arpinfo->iniface,
-			arpinfo->invflags & ARPT_INV_VIA_IN ? " (INV)" : "");
+	if (FWINV(ret != 0, ARPT_INV_VIA_IN))
 		return 0;
-	}
 
 	ret = ifname_compare(outdev, arpinfo->outiface, arpinfo->outiface_mask);
 
-	if (FWINV(ret != 0, ARPT_INV_VIA_OUT)) {
-		dprintf("VIA out mismatch (%s vs %s).%s\n",
-			outdev, arpinfo->outiface,
-			arpinfo->invflags & ARPT_INV_VIA_OUT ? " (INV)" : "");
+	if (FWINV(ret != 0, ARPT_INV_VIA_OUT))
 		return 0;
-	}
 
 	return 1;
 #undef FWINV
@@ -205,16 +144,10 @@ static inline int arp_packet_match(const struct arphdr *arphdr,
 
 static inline int arp_checkentry(const struct arpt_arp *arp)
 {
-	if (arp->flags & ~ARPT_F_MASK) {
-		duprintf("Unknown flag bits set: %08X\n",
-			 arp->flags & ~ARPT_F_MASK);
+	if (arp->flags & ~ARPT_F_MASK)
 		return 0;
-	}
-	if (arp->invflags & ~ARPT_INV_MASK) {
-		duprintf("Unknown invflag bits set: %08X\n",
-			 arp->invflags & ~ARPT_INV_MASK);
+	if (arp->invflags & ~ARPT_INV_MASK)
 		return 0;
-	}
 
 	return 1;
 }
@@ -406,11 +339,9 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 				= (void *)arpt_get_target_c(e);
 			int visited = e->comefrom & (1 << hook);
 
-			if (e->comefrom & (1 << NF_ARP_NUMHOOKS)) {
-				pr_notice("arptables: loop hook %u pos %u %08X.\n",
-				       hook, pos, e->comefrom);
+			if (e->comefrom & (1 << NF_ARP_NUMHOOKS))
 				return 0;
-			}
+
 			e->comefrom
 				|= ((1 << hook) | (1 << NF_ARP_NUMHOOKS));
 
@@ -423,12 +354,8 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 
 				if ((strcmp(t->target.u.user.name,
 					    XT_STANDARD_TARGET) == 0) &&
-				    t->verdict < -NF_MAX_VERDICT - 1) {
-					duprintf("mark_source_chains: bad "
-						"negative verdict (%i)\n",
-								t->verdict);
+				    t->verdict < -NF_MAX_VERDICT - 1)
 					return 0;
-				}
 
 				/* Return: backtrack through the last
 				 * big jump.
@@ -462,8 +389,6 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 					   XT_STANDARD_TARGET) == 0 &&
 				    newpos >= 0) {
 					/* This a jump; chase it. */
-					duprintf("Jump rule %u -> %u\n",
-						 pos, newpos);
 					e = (struct arpt_entry *)
 						(entry0 + newpos);
 					if (!find_jump_target(newinfo, e))
@@ -480,8 +405,7 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 				pos = newpos;
 			}
 		}
-next:
-		duprintf("Finished chain %u\n", hook);
+next:		;
 	}
 	return 1;
 }
@@ -489,7 +413,6 @@ next:
 static inline int check_target(struct arpt_entry *e, const char *name)
 {
 	struct xt_entry_target *t = arpt_get_target(e);
-	int ret;
 	struct xt_tgchk_param par = {
 		.table     = name,
 		.entryinfo = e,
@@ -499,13 +422,7 @@ static inline int check_target(struct arpt_entry *e, const char *name)
 		.family    = NFPROTO_ARP,
 	};
 
-	ret = xt_check_target(&par, t->u.target_size - sizeof(*t), 0, false);
-	if (ret < 0) {
-		duprintf("arp_tables: check failed for `%s'.\n",
-			 t->u.kernel.target->name);
-		return ret;
-	}
-	return 0;
+	return xt_check_target(&par, t->u.target_size - sizeof(*t), 0, false);
 }
 
 static inline int
@@ -525,7 +442,6 @@ find_check_entry(struct arpt_entry *e, const char *name, unsigned int size)
 	target = xt_request_find_target(NFPROTO_ARP, t->u.user.name,
 					t->u.user.revision);
 	if (IS_ERR(target)) {
-		duprintf("find_check_entry: `%s' not found\n", t->u.user.name);
 		ret = PTR_ERR(target);
 		goto out;
 	}
@@ -571,17 +487,12 @@ static inline int check_entry_size_and_hooks(struct arpt_entry *e,
 
 	if ((unsigned long)e % __alignof__(struct arpt_entry) != 0 ||
 	    (unsigned char *)e + sizeof(struct arpt_entry) >= limit ||
-	    (unsigned char *)e + e->next_offset > limit) {
-		duprintf("Bad offset %p\n", e);
+	    (unsigned char *)e + e->next_offset > limit)
 		return -EINVAL;
-	}
 
 	if (e->next_offset
-	    < sizeof(struct arpt_entry) + sizeof(struct xt_entry_target)) {
-		duprintf("checking: element %p size %u\n",
-			 e, e->next_offset);
+	    < sizeof(struct arpt_entry) + sizeof(struct xt_entry_target))
 		return -EINVAL;
-	}
 
 	if (!arp_checkentry(&e->arp))
 		return -EINVAL;
@@ -598,12 +509,9 @@ static inline int check_entry_size_and_hooks(struct arpt_entry *e,
 		if ((unsigned char *)e - base == hook_entries[h])
 			newinfo->hook_entry[h] = hook_entries[h];
 		if ((unsigned char *)e - base == underflows[h]) {
-			if (!check_underflow(e)) {
-				pr_debug("Underflows must be unconditional and "
-					 "use the STANDARD target with "
-					 "ACCEPT/DROP\n");
+			if (!check_underflow(e))
 				return -EINVAL;
-			}
+
 			newinfo->underflow[h] = underflows[h];
 		}
 	}
@@ -648,7 +556,6 @@ static int translate_table(struct xt_table_info *newinfo, void *entry0,
 		newinfo->underflow[i] = 0xFFFFFFFF;
 	}
 
-	duprintf("translate_table: size %u\n", newinfo->size);
 	i = 0;
 
 	/* Walk through entries, checking offsets. */
@@ -665,31 +572,21 @@ static int translate_table(struct xt_table_info *newinfo, void *entry0,
 		    XT_ERROR_TARGET) == 0)
 			++newinfo->stacksize;
 	}
-	duprintf("translate_table: ARPT_ENTRY_ITERATE gives %d\n", ret);
 	if (ret != 0)
 		return ret;
 
-	if (i != repl->num_entries) {
-		duprintf("translate_table: %u not %u entries\n",
-			 i, repl->num_entries);
+	if (i != repl->num_entries)
 		return -EINVAL;
-	}
 
 	/* Check hooks all assigned */
 	for (i = 0; i < NF_ARP_NUMHOOKS; i++) {
 		/* Only hooks which are valid */
 		if (!(repl->valid_hooks & (1 << i)))
 			continue;
-		if (newinfo->hook_entry[i] == 0xFFFFFFFF) {
-			duprintf("Invalid hook entry %u %u\n",
-				 i, repl->hook_entry[i]);
+		if (newinfo->hook_entry[i] == 0xFFFFFFFF)
 			return -EINVAL;
-		}
-		if (newinfo->underflow[i] == 0xFFFFFFFF) {
-			duprintf("Invalid underflow %u %u\n",
-				 i, repl->underflow[i]);
+		if (newinfo->underflow[i] == 0xFFFFFFFF)
 			return -EINVAL;
-		}
 	}
 
 	if (!mark_source_chains(newinfo, repl->valid_hooks, entry0))
@@ -897,11 +794,8 @@ static int get_info(struct net *net, void __user *user,
 	struct xt_table *t;
 	int ret;
 
-	if (*len != sizeof(struct arpt_getinfo)) {
-		duprintf("length %u != %Zu\n", *len,
-			 sizeof(struct arpt_getinfo));
+	if (*len != sizeof(struct arpt_getinfo))
 		return -EINVAL;
-	}
 
 	if (copy_from_user(name, user, sizeof(name)) != 0)
 		return -EFAULT;
@@ -957,33 +851,25 @@ static int get_entries(struct net *net, struct arpt_get_entries __user *uptr,
 	struct arpt_get_entries get;
 	struct xt_table *t;
 
-	if (*len < sizeof(get)) {
-		duprintf("get_entries: %u < %Zu\n", *len, sizeof(get));
+	if (*len < sizeof(get))
 		return -EINVAL;
-	}
 	if (copy_from_user(&get, uptr, sizeof(get)) != 0)
 		return -EFAULT;
-	if (*len != sizeof(struct arpt_get_entries) + get.size) {
-		duprintf("get_entries: %u != %Zu\n", *len,
-			 sizeof(struct arpt_get_entries) + get.size);
+	if (*len != sizeof(struct arpt_get_entries) + get.size)
 		return -EINVAL;
-	}
+
 	get.name[sizeof(get.name) - 1] = '\0';
 
 	t = xt_find_table_lock(net, NFPROTO_ARP, get.name);
 	if (!IS_ERR_OR_NULL(t)) {
 		const struct xt_table_info *private = t->private;
 
-		duprintf("t->private->number = %u\n",
-			 private->number);
 		if (get.size == private->size)
 			ret = copy_entries_to_user(private->size,
 						   t, uptr->entrytable);
-		else {
-			duprintf("get_entries: I've got %u not %u!\n",
-				 private->size, get.size);
+		else
 			ret = -EAGAIN;
-		}
+
 		module_put(t->me);
 		xt_table_unlock(t);
 	} else
@@ -1021,8 +907,6 @@ static int __do_replace(struct net *net, const char *name,
 
 	/* You lied! */
 	if (valid_hooks != t->valid_hooks) {
-		duprintf("Valid hook crap: %08X vs %08X\n",
-			 valid_hooks, t->valid_hooks);
 		ret = -EINVAL;
 		goto put_module;
 	}
@@ -1032,8 +916,6 @@ static int __do_replace(struct net *net, const char *name,
 		goto put_module;
 
 	/* Update module usage count based on number of rules */
-	duprintf("do_replace: oldnum=%u, initnum=%u, newnum=%u\n",
-		oldinfo->number, oldinfo->initial_entries, newinfo->number);
 	if ((oldinfo->number > oldinfo->initial_entries) ||
 	    (newinfo->number <= oldinfo->initial_entries))
 		module_put(t->me);
@@ -1103,8 +985,6 @@ static int do_replace(struct net *net, const void __user *user,
 	if (ret != 0)
 		goto free_newinfo;
 
-	duprintf("arp_tables: Translated table\n");
-
 	ret = __do_replace(net, tmp.name, tmp.valid_hooks, newinfo,
 			   tmp.num_counters, tmp.counters);
 	if (ret)
@@ -1202,20 +1082,14 @@ check_compat_entry_size_and_hooks(struct compat_arpt_entry *e,
 	unsigned int entry_offset;
 	int ret, off;
 
-	duprintf("check_compat_entry_size_and_hooks %p\n", e);
 	if ((unsigned long)e % __alignof__(struct compat_arpt_entry) != 0 ||
 	    (unsigned char *)e + sizeof(struct compat_arpt_entry) >= limit ||
-	    (unsigned char *)e + e->next_offset > limit) {
-		duprintf("Bad offset %p, limit = %p\n", e, limit);
+	    (unsigned char *)e + e->next_offset > limit)
 		return -EINVAL;
-	}
 
 	if (e->next_offset < sizeof(struct compat_arpt_entry) +
-			     sizeof(struct compat_xt_entry_target)) {
-		duprintf("checking: element %p size %u\n",
-			 e, e->next_offset);
+			     sizeof(struct compat_xt_entry_target))
 		return -EINVAL;
-	}
 
 	if (!arp_checkentry(&e->arp))
 		return -EINVAL;
@@ -1232,8 +1106,6 @@ check_compat_entry_size_and_hooks(struct compat_arpt_entry *e,
 	target = xt_request_find_target(NFPROTO_ARP, t->u.user.name,
 					t->u.user.revision);
 	if (IS_ERR(target)) {
-		duprintf("check_compat_entry_size_and_hooks: `%s' not found\n",
-			 t->u.user.name);
 		ret = PTR_ERR(target);
 		goto out;
 	}
@@ -1303,7 +1175,6 @@ static int translate_compat_table(struct xt_table_info **pinfo,
 	size = compatr->size;
 	info->number = compatr->num_entries;
 
-	duprintf("translate_compat_table: size %u\n", info->size);
 	j = 0;
 	xt_compat_lock(NFPROTO_ARP);
 	xt_compat_init_offsets(NFPROTO_ARP, compatr->num_entries);
@@ -1318,11 +1189,8 @@ static int translate_compat_table(struct xt_table_info **pinfo,
 	}
 
 	ret = -EINVAL;
-	if (j != compatr->num_entries) {
-		duprintf("translate_compat_table: %u not %u entries\n",
-			 j, compatr->num_entries);
+	if (j != compatr->num_entries)
 		goto out_unlock;
-	}
 
 	ret = -ENOMEM;
 	newinfo = xt_alloc_table_info(size);
@@ -1413,8 +1281,6 @@ static int compat_do_replace(struct net *net, void __user *user,
 	if (ret != 0)
 		goto free_newinfo;
 
-	duprintf("compat_do_replace: Translated table\n");
-
 	ret = __do_replace(net, tmp.name, tmp.valid_hooks, newinfo,
 			   tmp.num_counters, compat_ptr(tmp.counters));
 	if (ret)
@@ -1447,7 +1313,6 @@ static int compat_do_arpt_set_ctl(struct sock *sk, int cmd, void __user *user,
 		break;
 
 	default:
-		duprintf("do_arpt_set_ctl:  unknown request %i\n", cmd);
 		ret = -EINVAL;
 	}
 
@@ -1530,17 +1395,13 @@ static int compat_get_entries(struct net *net,
 	struct compat_arpt_get_entries get;
 	struct xt_table *t;
 
-	if (*len < sizeof(get)) {
-		duprintf("compat_get_entries: %u < %zu\n", *len, sizeof(get));
+	if (*len < sizeof(get))
 		return -EINVAL;
-	}
 	if (copy_from_user(&get, uptr, sizeof(get)) != 0)
 		return -EFAULT;
-	if (*len != sizeof(struct compat_arpt_get_entries) + get.size) {
-		duprintf("compat_get_entries: %u != %zu\n",
-			 *len, sizeof(get) + get.size);
+	if (*len != sizeof(struct compat_arpt_get_entries) + get.size)
 		return -EINVAL;
-	}
+
 	get.name[sizeof(get.name) - 1] = '\0';
 
 	xt_compat_lock(NFPROTO_ARP);
@@ -1549,16 +1410,13 @@ static int compat_get_entries(struct net *net,
 		const struct xt_table_info *private = t->private;
 		struct xt_table_info info;
 
-		duprintf("t->private->number = %u\n", private->number);
 		ret = compat_table_info(private, &info);
 		if (!ret && get.size == info.size) {
 			ret = compat_copy_entries_to_user(private->size,
 							  t, uptr->entrytable);
-		} else if (!ret) {
-			duprintf("compat_get_entries: I've got %u not %u!\n",
-				 private->size, get.size);
+		} else if (!ret)
 			ret = -EAGAIN;
-		}
+
 		xt_compat_flush_offsets(NFPROTO_ARP);
 		module_put(t->me);
 		xt_table_unlock(t);
@@ -1610,7 +1468,6 @@ static int do_arpt_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned
 		break;
 
 	default:
-		duprintf("do_arpt_set_ctl:  unknown request %i\n", cmd);
 		ret = -EINVAL;
 	}
 
@@ -1653,7 +1510,6 @@ static int do_arpt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len
 	}
 
 	default:
-		duprintf("do_arpt_get_ctl: unknown request %i\n", cmd);
 		ret = -EINVAL;
 	}
 
@@ -1698,7 +1554,6 @@ int arpt_register_table(struct net *net,
 	memcpy(loc_cpu_entry, repl->entries, repl->size);
 
 	ret = translate_table(newinfo, loc_cpu_entry, repl);
-	duprintf("arpt_register_table: translate table gives %d\n", ret);
 	if (ret != 0)
 		goto out_free;
 
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 21ccc19..54906e0 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -35,34 +35,12 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
 MODULE_DESCRIPTION("IPv4 packet filter");
 
-/*#define DEBUG_IP_FIREWALL*/
-/*#define DEBUG_ALLOW_ALL*/ /* Useful for remote debugging */
-/*#define DEBUG_IP_FIREWALL_USER*/
-
-#ifdef DEBUG_IP_FIREWALL
-#define dprintf(format, args...) pr_info(format , ## args)
-#else
-#define dprintf(format, args...)
-#endif
-
-#ifdef DEBUG_IP_FIREWALL_USER
-#define duprintf(format, args...) pr_info(format , ## args)
-#else
-#define duprintf(format, args...)
-#endif
-
 #ifdef CONFIG_NETFILTER_DEBUG
 #define IP_NF_ASSERT(x)		WARN_ON(!(x))
 #else
 #define IP_NF_ASSERT(x)
 #endif
 
-#if 0
-/* All the better to debug you with... */
-#define static
-#define inline
-#endif
-
 void *ipt_alloc_initial_table(const struct xt_table *info)
 {
 	return xt_alloc_initial_table(ipt, IPT);
@@ -85,52 +63,28 @@ ip_packet_match(const struct iphdr *ip,
 	if (FWINV((ip->saddr&ipinfo->smsk.s_addr) != ipinfo->src.s_addr,
 		  IPT_INV_SRCIP) ||
 	    FWINV((ip->daddr&ipinfo->dmsk.s_addr) != ipinfo->dst.s_addr,
-		  IPT_INV_DSTIP)) {
-		dprintf("Source or dest mismatch.\n");
-
-		dprintf("SRC: %pI4. Mask: %pI4. Target: %pI4.%s\n",
-			&ip->saddr, &ipinfo->smsk.s_addr, &ipinfo->src.s_addr,
-			ipinfo->invflags & IPT_INV_SRCIP ? " (INV)" : "");
-		dprintf("DST: %pI4 Mask: %pI4 Target: %pI4.%s\n",
-			&ip->daddr, &ipinfo->dmsk.s_addr, &ipinfo->dst.s_addr,
-			ipinfo->invflags & IPT_INV_DSTIP ? " (INV)" : "");
+		  IPT_INV_DSTIP))
 		return false;
-	}
 
 	ret = ifname_compare_aligned(indev, ipinfo->iniface, ipinfo->iniface_mask);
 
-	if (FWINV(ret != 0, IPT_INV_VIA_IN)) {
-		dprintf("VIA in mismatch (%s vs %s).%s\n",
-			indev, ipinfo->iniface,
-			ipinfo->invflags & IPT_INV_VIA_IN ? " (INV)" : "");
+	if (FWINV(ret != 0, IPT_INV_VIA_IN))
 		return false;
-	}
 
 	ret = ifname_compare_aligned(outdev, ipinfo->outiface, ipinfo->outiface_mask);
 
-	if (FWINV(ret != 0, IPT_INV_VIA_OUT)) {
-		dprintf("VIA out mismatch (%s vs %s).%s\n",
-			outdev, ipinfo->outiface,
-			ipinfo->invflags & IPT_INV_VIA_OUT ? " (INV)" : "");
+	if (FWINV(ret != 0, IPT_INV_VIA_OUT))
 		return false;
-	}
 
 	/* Check specific protocol */
 	if (ipinfo->proto &&
-	    FWINV(ip->protocol != ipinfo->proto, IPT_INV_PROTO)) {
-		dprintf("Packet protocol %hi does not match %hi.%s\n",
-			ip->protocol, ipinfo->proto,
-			ipinfo->invflags & IPT_INV_PROTO ? " (INV)" : "");
+	    FWINV(ip->protocol != ipinfo->proto, IPT_INV_PROTO))
 		return false;
-	}
 
 	/* If we have a fragment rule but the packet is not a fragment
 	 * then we return zero */
-	if (FWINV((ipinfo->flags&IPT_F_FRAG) && !isfrag, IPT_INV_FRAG)) {
-		dprintf("Fragment rule but not fragment.%s\n",
-			ipinfo->invflags & IPT_INV_FRAG ? " (INV)" : "");
+	if (FWINV((ipinfo->flags&IPT_F_FRAG) && !isfrag, IPT_INV_FRAG))
 		return false;
-	}
 
 	return true;
 }
@@ -138,16 +92,10 @@ ip_packet_match(const struct iphdr *ip,
 static bool
 ip_checkentry(const struct ipt_ip *ip)
 {
-	if (ip->flags & ~IPT_F_MASK) {
-		duprintf("Unknown flag bits set: %08X\n",
-			 ip->flags & ~IPT_F_MASK);
+	if (ip->flags & ~IPT_F_MASK)
 		return false;
-	}
-	if (ip->invflags & ~IPT_INV_MASK) {
-		duprintf("Unknown invflag bits set: %08X\n",
-			 ip->invflags & ~IPT_INV_MASK);
+	if (ip->invflags & ~IPT_INV_MASK)
 		return false;
-	}
 	return true;
 }
 
@@ -346,10 +294,6 @@ ipt_do_table(struct sk_buff *skb,
 
 	e = get_entry(table_base, private->hook_entry[hook]);
 
-	pr_debug("Entering %s(hook %u), UF %p\n",
-		 table->name, hook,
-		 get_entry(table_base, private->underflow[hook]));
-
 	do {
 		const struct xt_entry_target *t;
 		const struct xt_entry_match *ematch;
@@ -396,22 +340,15 @@ ipt_do_table(struct sk_buff *skb,
 				if (stackidx == 0) {
 					e = get_entry(table_base,
 					    private->underflow[hook]);
-					pr_debug("Underflow (this is normal) "
-						 "to %p\n", e);
 				} else {
 					e = jumpstack[--stackidx];
-					pr_debug("Pulled %p out from pos %u\n",
-						 e, stackidx);
 					e = ipt_next_entry(e);
 				}
 				continue;
 			}
 			if (table_base + v != ipt_next_entry(e) &&
-			    !(e->ip.flags & IPT_F_GOTO)) {
+			    !(e->ip.flags & IPT_F_GOTO))
 				jumpstack[stackidx++] = e;
-				pr_debug("Pushed %p into pos %u\n",
-					 e, stackidx - 1);
-			}
 
 			e = get_entry(table_base, v);
 			continue;
@@ -429,18 +366,13 @@ ipt_do_table(struct sk_buff *skb,
 			/* Verdict */
 			break;
 	} while (!acpar.hotdrop);
-	pr_debug("Exiting %s; sp at %u\n", __func__, stackidx);
 
 	xt_write_recseq_end(addend);
 	local_bh_enable();
 
-#ifdef DEBUG_ALLOW_ALL
-	return NF_ACCEPT;
-#else
 	if (acpar.hotdrop)
 		return NF_DROP;
 	else return verdict;
-#endif
 }
 
 static bool find_jump_target(const struct xt_table_info *t,
@@ -480,11 +412,9 @@ mark_source_chains(const struct xt_table_info *newinfo,
 				= (void *)ipt_get_target_c(e);
 			int visited = e->comefrom & (1 << hook);
 
-			if (e->comefrom & (1 << NF_INET_NUMHOOKS)) {
-				pr_err("iptables: loop hook %u pos %u %08X.\n",
-				       hook, pos, e->comefrom);
+			if (e->comefrom & (1 << NF_INET_NUMHOOKS))
 				return 0;
-			}
+
 			e->comefrom |= ((1 << hook) | (1 << NF_INET_NUMHOOKS));
 
 			/* Unconditional return/END. */
@@ -496,26 +426,13 @@ mark_source_chains(const struct xt_table_info *newinfo,
 
 				if ((strcmp(t->target.u.user.name,
 					    XT_STANDARD_TARGET) == 0) &&
-				    t->verdict < -NF_MAX_VERDICT - 1) {
-					duprintf("mark_source_chains: bad "
-						"negative verdict (%i)\n",
-								t->verdict);
+				    t->verdict < -NF_MAX_VERDICT - 1)
 					return 0;
-				}
 
 				/* Return: backtrack through the last
 				   big jump. */
 				do {
 					e->comefrom ^= (1<<NF_INET_NUMHOOKS);
-#ifdef DEBUG_IP_FIREWALL_USER
-					if (e->comefrom
-					    & (1 << NF_INET_NUMHOOKS)) {
-						duprintf("Back unset "
-							 "on hook %u "
-							 "rule %u\n",
-							 hook, pos);
-					}
-#endif
 					oldpos = pos;
 					pos = e->counters.pcnt;
 					e->counters.pcnt = 0;
@@ -543,8 +460,6 @@ mark_source_chains(const struct xt_table_info *newinfo,
 					   XT_STANDARD_TARGET) == 0 &&
 				    newpos >= 0) {
 					/* This a jump; chase it. */
-					duprintf("Jump rule %u -> %u\n",
-						 pos, newpos);
 					e = (struct ipt_entry *)
 						(entry0 + newpos);
 					if (!find_jump_target(newinfo, e))
@@ -561,8 +476,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 				pos = newpos;
 			}
 		}
-next:
-		duprintf("Finished chain %u\n", hook);
+next:		;
 	}
 	return 1;
 }
@@ -584,18 +498,12 @@ static int
 check_match(struct xt_entry_match *m, struct xt_mtchk_param *par)
 {
 	const struct ipt_ip *ip = par->entryinfo;
-	int ret;
 
 	par->match     = m->u.kernel.match;
 	par->matchinfo = m->data;
 
-	ret = xt_check_match(par, m->u.match_size - sizeof(*m),
-	      ip->proto, ip->invflags & IPT_INV_PROTO);
-	if (ret < 0) {
-		duprintf("check failed for `%s'.\n", par->match->name);
-		return ret;
-	}
-	return 0;
+	return xt_check_match(par, m->u.match_size - sizeof(*m),
+			      ip->proto, ip->invflags & IPT_INV_PROTO);
 }
 
 static int
@@ -606,10 +514,8 @@ find_check_match(struct xt_entry_match *m, struct xt_mtchk_param *par)
 
 	match = xt_request_find_match(NFPROTO_IPV4, m->u.user.name,
 				      m->u.user.revision);
-	if (IS_ERR(match)) {
-		duprintf("find_check_match: `%s' not found\n", m->u.user.name);
+	if (IS_ERR(match))
 		return PTR_ERR(match);
-	}
 	m->u.kernel.match = match;
 
 	ret = check_match(m, par);
@@ -634,16 +540,9 @@ static int check_target(struct ipt_entry *e, struct net *net, const char *name)
 		.hook_mask = e->comefrom,
 		.family    = NFPROTO_IPV4,
 	};
-	int ret;
 
-	ret = xt_check_target(&par, t->u.target_size - sizeof(*t),
-	      e->ip.proto, e->ip.invflags & IPT_INV_PROTO);
-	if (ret < 0) {
-		duprintf("check failed for `%s'.\n",
-			 t->u.kernel.target->name);
-		return ret;
-	}
-	return 0;
+	return xt_check_target(&par, t->u.target_size - sizeof(*t),
+			       e->ip.proto, e->ip.invflags & IPT_INV_PROTO);
 }
 
 static int
@@ -680,7 +579,6 @@ find_check_entry(struct ipt_entry *e, struct net *net, const char *name,
 	target = xt_request_find_target(NFPROTO_IPV4, t->u.user.name,
 					t->u.user.revision);
 	if (IS_ERR(target)) {
-		duprintf("find_check_entry: `%s' not found\n", t->u.user.name);
 		ret = PTR_ERR(target);
 		goto cleanup_matches;
 	}
@@ -734,17 +632,12 @@ check_entry_size_and_hooks(struct ipt_entry *e,
 
 	if ((unsigned long)e % __alignof__(struct ipt_entry) != 0 ||
 	    (unsigned char *)e + sizeof(struct ipt_entry) >= limit ||
-	    (unsigned char *)e + e->next_offset > limit) {
-		duprintf("Bad offset %p\n", e);
+	    (unsigned char *)e + e->next_offset > limit)
 		return -EINVAL;
-	}
 
 	if (e->next_offset
-	    < sizeof(struct ipt_entry) + sizeof(struct xt_entry_target)) {
-		duprintf("checking: element %p size %u\n",
-			 e, e->next_offset);
+	    < sizeof(struct ipt_entry) + sizeof(struct xt_entry_target))
 		return -EINVAL;
-	}
 
 	if (!ip_checkentry(&e->ip))
 		return -EINVAL;
@@ -761,12 +654,9 @@ check_entry_size_and_hooks(struct ipt_entry *e,
 		if ((unsigned char *)e - base == hook_entries[h])
 			newinfo->hook_entry[h] = hook_entries[h];
 		if ((unsigned char *)e - base == underflows[h]) {
-			if (!check_underflow(e)) {
-				pr_debug("Underflows must be unconditional and "
-					 "use the STANDARD target with "
-					 "ACCEPT/DROP\n");
+			if (!check_underflow(e))
 				return -EINVAL;
-			}
+
 			newinfo->underflow[h] = underflows[h];
 		}
 	}
@@ -818,7 +708,6 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 		newinfo->underflow[i] = 0xFFFFFFFF;
 	}
 
-	duprintf("translate_table: size %u\n", newinfo->size);
 	i = 0;
 	/* Walk through entries, checking offsets. */
 	xt_entry_foreach(iter, entry0, newinfo->size) {
@@ -835,27 +724,18 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 			++newinfo->stacksize;
 	}
 
-	if (i != repl->num_entries) {
-		duprintf("translate_table: %u not %u entries\n",
-			 i, repl->num_entries);
+	if (i != repl->num_entries)
 		return -EINVAL;
-	}
 
 	/* Check hooks all assigned */
 	for (i = 0; i < NF_INET_NUMHOOKS; i++) {
 		/* Only hooks which are valid */
 		if (!(repl->valid_hooks & (1 << i)))
 			continue;
-		if (newinfo->hook_entry[i] == 0xFFFFFFFF) {
-			duprintf("Invalid hook entry %u %u\n",
-				 i, repl->hook_entry[i]);
+		if (newinfo->hook_entry[i] == 0xFFFFFFFF)
 			return -EINVAL;
-		}
-		if (newinfo->underflow[i] == 0xFFFFFFFF) {
-			duprintf("Invalid underflow %u %u\n",
-				 i, repl->underflow[i]);
+		if (newinfo->underflow[i] == 0xFFFFFFFF)
 			return -EINVAL;
-		}
 	}
 
 	if (!mark_source_chains(newinfo, repl->valid_hooks, entry0))
@@ -1083,11 +963,8 @@ static int get_info(struct net *net, void __user *user,
 	struct xt_table *t;
 	int ret;
 
-	if (*len != sizeof(struct ipt_getinfo)) {
-		duprintf("length %u != %zu\n", *len,
-			 sizeof(struct ipt_getinfo));
+	if (*len != sizeof(struct ipt_getinfo))
 		return -EINVAL;
-	}
 
 	if (copy_from_user(name, user, sizeof(name)) != 0)
 		return -EFAULT;
@@ -1145,31 +1022,23 @@ get_entries(struct net *net, struct ipt_get_entries __user *uptr,
 	struct ipt_get_entries get;
 	struct xt_table *t;
 
-	if (*len < sizeof(get)) {
-		duprintf("get_entries: %u < %zu\n", *len, sizeof(get));
+	if (*len < sizeof(get))
 		return -EINVAL;
-	}
 	if (copy_from_user(&get, uptr, sizeof(get)) != 0)
 		return -EFAULT;
-	if (*len != sizeof(struct ipt_get_entries) + get.size) {
-		duprintf("get_entries: %u != %zu\n",
-			 *len, sizeof(get) + get.size);
+	if (*len != sizeof(struct ipt_get_entries) + get.size)
 		return -EINVAL;
-	}
 	get.name[sizeof(get.name) - 1] = '\0';
 
 	t = xt_find_table_lock(net, AF_INET, get.name);
 	if (!IS_ERR_OR_NULL(t)) {
 		const struct xt_table_info *private = t->private;
-		duprintf("t->private->number = %u\n", private->number);
 		if (get.size == private->size)
 			ret = copy_entries_to_user(private->size,
 						   t, uptr->entrytable);
-		else {
-			duprintf("get_entries: I've got %u not %u!\n",
-				 private->size, get.size);
+		else
 			ret = -EAGAIN;
-		}
+
 		module_put(t->me);
 		xt_table_unlock(t);
 	} else
@@ -1205,8 +1074,6 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 
 	/* You lied! */
 	if (valid_hooks != t->valid_hooks) {
-		duprintf("Valid hook crap: %08X vs %08X\n",
-			 valid_hooks, t->valid_hooks);
 		ret = -EINVAL;
 		goto put_module;
 	}
@@ -1216,8 +1083,6 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 		goto put_module;
 
 	/* Update module usage count based on number of rules */
-	duprintf("do_replace: oldnum=%u, initnum=%u, newnum=%u\n",
-		oldinfo->number, oldinfo->initial_entries, newinfo->number);
 	if ((oldinfo->number > oldinfo->initial_entries) ||
 	    (newinfo->number <= oldinfo->initial_entries))
 		module_put(t->me);
@@ -1286,8 +1151,6 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
 	if (ret != 0)
 		goto free_newinfo;
 
-	duprintf("Translated table\n");
-
 	ret = __do_replace(net, tmp.name, tmp.valid_hooks, newinfo,
 			   tmp.num_counters, tmp.counters);
 	if (ret)
@@ -1413,11 +1276,9 @@ compat_find_calc_match(struct xt_entry_match *m,
 
 	match = xt_request_find_match(NFPROTO_IPV4, m->u.user.name,
 				      m->u.user.revision);
-	if (IS_ERR(match)) {
-		duprintf("compat_check_calc_match: `%s' not found\n",
-			 m->u.user.name);
+	if (IS_ERR(match))
 		return PTR_ERR(match);
-	}
+
 	m->u.kernel.match = match;
 	*size += xt_compat_match_offset(match);
 	return 0;
@@ -1449,20 +1310,14 @@ check_compat_entry_size_and_hooks(struct compat_ipt_entry *e,
 	unsigned int j;
 	int ret, off;
 
-	duprintf("check_compat_entry_size_and_hooks %p\n", e);
 	if ((unsigned long)e % __alignof__(struct compat_ipt_entry) != 0 ||
 	    (unsigned char *)e + sizeof(struct compat_ipt_entry) >= limit ||
-	    (unsigned char *)e + e->next_offset > limit) {
-		duprintf("Bad offset %p, limit = %p\n", e, limit);
+	    (unsigned char *)e + e->next_offset > limit)
 		return -EINVAL;
-	}
 
 	if (e->next_offset < sizeof(struct compat_ipt_entry) +
-			     sizeof(struct compat_xt_entry_target)) {
-		duprintf("checking: element %p size %u\n",
-			 e, e->next_offset);
+			     sizeof(struct compat_xt_entry_target))
 		return -EINVAL;
-	}
 
 	if (!ip_checkentry(&e->ip))
 		return -EINVAL;
@@ -1486,8 +1341,6 @@ check_compat_entry_size_and_hooks(struct compat_ipt_entry *e,
 	target = xt_request_find_target(NFPROTO_IPV4, t->u.user.name,
 					t->u.user.revision);
 	if (IS_ERR(target)) {
-		duprintf("check_compat_entry_size_and_hooks: `%s' not found\n",
-			 t->u.user.name);
 		ret = PTR_ERR(target);
 		goto release_matches;
 	}
@@ -1569,7 +1422,6 @@ translate_compat_table(struct net *net,
 	size = compatr->size;
 	info->number = compatr->num_entries;
 
-	duprintf("translate_compat_table: size %u\n", info->size);
 	j = 0;
 	xt_compat_lock(AF_INET);
 	xt_compat_init_offsets(AF_INET, compatr->num_entries);
@@ -1584,11 +1436,8 @@ translate_compat_table(struct net *net,
 	}
 
 	ret = -EINVAL;
-	if (j != compatr->num_entries) {
-		duprintf("translate_compat_table: %u not %u entries\n",
-			 j, compatr->num_entries);
+	if (j != compatr->num_entries)
 		goto out_unlock;
-	}
 
 	ret = -ENOMEM;
 	newinfo = xt_alloc_table_info(size);
@@ -1685,8 +1534,6 @@ compat_do_replace(struct net *net, void __user *user, unsigned int len)
 	if (ret != 0)
 		goto free_newinfo;
 
-	duprintf("compat_do_replace: Translated table\n");
-
 	ret = __do_replace(net, tmp.name, tmp.valid_hooks, newinfo,
 			   tmp.num_counters, compat_ptr(tmp.counters));
 	if (ret)
@@ -1720,7 +1567,6 @@ compat_do_ipt_set_ctl(struct sock *sk,	int cmd, void __user *user,
 		break;
 
 	default:
-		duprintf("do_ipt_set_ctl:  unknown request %i\n", cmd);
 		ret = -EINVAL;
 	}
 
@@ -1770,19 +1616,15 @@ compat_get_entries(struct net *net, struct compat_ipt_get_entries __user *uptr,
 	struct compat_ipt_get_entries get;
 	struct xt_table *t;
 
-	if (*len < sizeof(get)) {
-		duprintf("compat_get_entries: %u < %zu\n", *len, sizeof(get));
+	if (*len < sizeof(get))
 		return -EINVAL;
-	}
 
 	if (copy_from_user(&get, uptr, sizeof(get)) != 0)
 		return -EFAULT;
 
-	if (*len != sizeof(struct compat_ipt_get_entries) + get.size) {
-		duprintf("compat_get_entries: %u != %zu\n",
-			 *len, sizeof(get) + get.size);
+	if (*len != sizeof(struct compat_ipt_get_entries) + get.size)
 		return -EINVAL;
-	}
+
 	get.name[sizeof(get.name) - 1] = '\0';
 
 	xt_compat_lock(AF_INET);
@@ -1790,16 +1632,13 @@ compat_get_entries(struct net *net, struct compat_ipt_get_entries __user *uptr,
 	if (!IS_ERR_OR_NULL(t)) {
 		const struct xt_table_info *private = t->private;
 		struct xt_table_info info;
-		duprintf("t->private->number = %u\n", private->number);
 		ret = compat_table_info(private, &info);
-		if (!ret && get.size == info.size) {
+		if (!ret && get.size == info.size)
 			ret = compat_copy_entries_to_user(private->size,
 							  t, uptr->entrytable);
-		} else if (!ret) {
-			duprintf("compat_get_entries: I've got %u not %u!\n",
-				 private->size, get.size);
+		else if (!ret)
 			ret = -EAGAIN;
-		}
+
 		xt_compat_flush_offsets(AF_INET);
 		module_put(t->me);
 		xt_table_unlock(t);
@@ -1852,7 +1691,6 @@ do_ipt_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		break;
 
 	default:
-		duprintf("do_ipt_set_ctl:  unknown request %i\n", cmd);
 		ret = -EINVAL;
 	}
 
@@ -1904,7 +1742,6 @@ do_ipt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	}
 
 	default:
-		duprintf("do_ipt_get_ctl: unknown request %i\n", cmd);
 		ret = -EINVAL;
 	}
 
@@ -2006,7 +1843,6 @@ icmp_match(const struct sk_buff *skb, struct xt_action_param *par)
 		/* We've been asked to examine this packet, and we
 		 * can't.  Hence, no choice but to drop.
 		 */
-		duprintf("Dropping evil ICMP tinygram.\n");
 		par->hotdrop = true;
 		return false;
 	}
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 17874e8..63e06c3 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -39,34 +39,12 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
 MODULE_DESCRIPTION("IPv6 packet filter");
 
-/*#define DEBUG_IP_FIREWALL*/
-/*#define DEBUG_ALLOW_ALL*/ /* Useful for remote debugging */
-/*#define DEBUG_IP_FIREWALL_USER*/
-
-#ifdef DEBUG_IP_FIREWALL
-#define dprintf(format, args...) pr_info(format , ## args)
-#else
-#define dprintf(format, args...)
-#endif
-
-#ifdef DEBUG_IP_FIREWALL_USER
-#define duprintf(format, args...) pr_info(format , ## args)
-#else
-#define duprintf(format, args...)
-#endif
-
 #ifdef CONFIG_NETFILTER_DEBUG
 #define IP_NF_ASSERT(x)	WARN_ON(!(x))
 #else
 #define IP_NF_ASSERT(x)
 #endif
 
-#if 0
-/* All the better to debug you with... */
-#define static
-#define inline
-#endif
-
 void *ip6t_alloc_initial_table(const struct xt_table *info)
 {
 	return xt_alloc_initial_table(ip6t, IP6T);
@@ -100,35 +78,18 @@ ip6_packet_match(const struct sk_buff *skb,
 	if (FWINV(ipv6_masked_addr_cmp(&ipv6->saddr, &ip6info->smsk,
 				       &ip6info->src), IP6T_INV_SRCIP) ||
 	    FWINV(ipv6_masked_addr_cmp(&ipv6->daddr, &ip6info->dmsk,
-				       &ip6info->dst), IP6T_INV_DSTIP)) {
-		dprintf("Source or dest mismatch.\n");
-/*
-		dprintf("SRC: %u. Mask: %u. Target: %u.%s\n", ip->saddr,
-			ipinfo->smsk.s_addr, ipinfo->src.s_addr,
-			ipinfo->invflags & IP6T_INV_SRCIP ? " (INV)" : "");
-		dprintf("DST: %u. Mask: %u. Target: %u.%s\n", ip->daddr,
-			ipinfo->dmsk.s_addr, ipinfo->dst.s_addr,
-			ipinfo->invflags & IP6T_INV_DSTIP ? " (INV)" : "");*/
+				       &ip6info->dst), IP6T_INV_DSTIP))
 		return false;
-	}
 
 	ret = ifname_compare_aligned(indev, ip6info->iniface, ip6info->iniface_mask);
 
-	if (FWINV(ret != 0, IP6T_INV_VIA_IN)) {
-		dprintf("VIA in mismatch (%s vs %s).%s\n",
-			indev, ip6info->iniface,
-			ip6info->invflags & IP6T_INV_VIA_IN ? " (INV)" : "");
+	if (FWINV(ret != 0, IP6T_INV_VIA_IN))
 		return false;
-	}
 
 	ret = ifname_compare_aligned(outdev, ip6info->outiface, ip6info->outiface_mask);
 
-	if (FWINV(ret != 0, IP6T_INV_VIA_OUT)) {
-		dprintf("VIA out mismatch (%s vs %s).%s\n",
-			outdev, ip6info->outiface,
-			ip6info->invflags & IP6T_INV_VIA_OUT ? " (INV)" : "");
+	if (FWINV(ret != 0, IP6T_INV_VIA_OUT))
 		return false;
-	}
 
 /* ... might want to do something with class and flowlabel here ... */
 
@@ -145,11 +106,6 @@ ip6_packet_match(const struct sk_buff *skb,
 		}
 		*fragoff = _frag_off;
 
-		dprintf("Packet protocol %hi ?= %s%hi.\n",
-				protohdr,
-				ip6info->invflags & IP6T_INV_PROTO ? "!":"",
-				ip6info->proto);
-
 		if (ip6info->proto == protohdr) {
 			if (ip6info->invflags & IP6T_INV_PROTO)
 				return false;
@@ -169,16 +125,11 @@ ip6_packet_match(const struct sk_buff *skb,
 static bool
 ip6_checkentry(const struct ip6t_ip6 *ipv6)
 {
-	if (ipv6->flags & ~IP6T_F_MASK) {
-		duprintf("Unknown flag bits set: %08X\n",
-			 ipv6->flags & ~IP6T_F_MASK);
+	if (ipv6->flags & ~IP6T_F_MASK)
 		return false;
-	}
-	if (ipv6->invflags & ~IP6T_INV_MASK) {
-		duprintf("Unknown invflag bits set: %08X\n",
-			 ipv6->invflags & ~IP6T_INV_MASK);
+	if (ipv6->invflags & ~IP6T_INV_MASK)
 		return false;
-	}
+
 	return true;
 }
 
@@ -446,13 +397,9 @@ ip6t_do_table(struct sk_buff *skb,
 	xt_write_recseq_end(addend);
 	local_bh_enable();
 
-#ifdef DEBUG_ALLOW_ALL
-	return NF_ACCEPT;
-#else
 	if (acpar.hotdrop)
 		return NF_DROP;
 	else return verdict;
-#endif
 }
 
 static bool find_jump_target(const struct xt_table_info *t,
@@ -492,11 +439,9 @@ mark_source_chains(const struct xt_table_info *newinfo,
 				= (void *)ip6t_get_target_c(e);
 			int visited = e->comefrom & (1 << hook);
 
-			if (e->comefrom & (1 << NF_INET_NUMHOOKS)) {
-				pr_err("iptables: loop hook %u pos %u %08X.\n",
-				       hook, pos, e->comefrom);
+			if (e->comefrom & (1 << NF_INET_NUMHOOKS))
 				return 0;
-			}
+
 			e->comefrom |= ((1 << hook) | (1 << NF_INET_NUMHOOKS));
 
 			/* Unconditional return/END. */
@@ -508,26 +453,13 @@ mark_source_chains(const struct xt_table_info *newinfo,
 
 				if ((strcmp(t->target.u.user.name,
 					    XT_STANDARD_TARGET) == 0) &&
-				    t->verdict < -NF_MAX_VERDICT - 1) {
-					duprintf("mark_source_chains: bad "
-						"negative verdict (%i)\n",
-								t->verdict);
+				    t->verdict < -NF_MAX_VERDICT - 1)
 					return 0;
-				}
 
 				/* Return: backtrack through the last
 				   big jump. */
 				do {
 					e->comefrom ^= (1<<NF_INET_NUMHOOKS);
-#ifdef DEBUG_IP_FIREWALL_USER
-					if (e->comefrom
-					    & (1 << NF_INET_NUMHOOKS)) {
-						duprintf("Back unset "
-							 "on hook %u "
-							 "rule %u\n",
-							 hook, pos);
-					}
-#endif
 					oldpos = pos;
 					pos = e->counters.pcnt;
 					e->counters.pcnt = 0;
@@ -555,8 +487,6 @@ mark_source_chains(const struct xt_table_info *newinfo,
 					   XT_STANDARD_TARGET) == 0 &&
 				    newpos >= 0) {
 					/* This a jump; chase it. */
-					duprintf("Jump rule %u -> %u\n",
-						 pos, newpos);
 					e = (struct ip6t_entry *)
 						(entry0 + newpos);
 					if (!find_jump_target(newinfo, e))
@@ -573,8 +503,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 				pos = newpos;
 			}
 		}
-next:
-		duprintf("Finished chain %u\n", hook);
+next:		;
 	}
 	return 1;
 }
@@ -595,19 +524,12 @@ static void cleanup_match(struct xt_entry_match *m, struct net *net)
 static int check_match(struct xt_entry_match *m, struct xt_mtchk_param *par)
 {
 	const struct ip6t_ip6 *ipv6 = par->entryinfo;
-	int ret;
 
 	par->match     = m->u.kernel.match;
 	par->matchinfo = m->data;
 
-	ret = xt_check_match(par, m->u.match_size - sizeof(*m),
-			     ipv6->proto, ipv6->invflags & IP6T_INV_PROTO);
-	if (ret < 0) {
-		duprintf("ip_tables: check failed for `%s'.\n",
-			 par.match->name);
-		return ret;
-	}
-	return 0;
+	return xt_check_match(par, m->u.match_size - sizeof(*m),
+			      ipv6->proto, ipv6->invflags & IP6T_INV_PROTO);
 }
 
 static int
@@ -618,10 +540,9 @@ find_check_match(struct xt_entry_match *m, struct xt_mtchk_param *par)
 
 	match = xt_request_find_match(NFPROTO_IPV6, m->u.user.name,
 				      m->u.user.revision);
-	if (IS_ERR(match)) {
-		duprintf("find_check_match: `%s' not found\n", m->u.user.name);
+	if (IS_ERR(match))
 		return PTR_ERR(match);
-	}
+
 	m->u.kernel.match = match;
 
 	ret = check_match(m, par);
@@ -646,17 +567,11 @@ static int check_target(struct ip6t_entry *e, struct net *net, const char *name)
 		.hook_mask = e->comefrom,
 		.family    = NFPROTO_IPV6,
 	};
-	int ret;
 
 	t = ip6t_get_target(e);
-	ret = xt_check_target(&par, t->u.target_size - sizeof(*t),
-	      e->ipv6.proto, e->ipv6.invflags & IP6T_INV_PROTO);
-	if (ret < 0) {
-		duprintf("ip_tables: check failed for `%s'.\n",
-			 t->u.kernel.target->name);
-		return ret;
-	}
-	return 0;
+	return xt_check_target(&par, t->u.target_size - sizeof(*t),
+			       e->ipv6.proto,
+			       e->ipv6.invflags & IP6T_INV_PROTO);
 }
 
 static int
@@ -693,7 +608,6 @@ find_check_entry(struct ip6t_entry *e, struct net *net, const char *name,
 	target = xt_request_find_target(NFPROTO_IPV6, t->u.user.name,
 					t->u.user.revision);
 	if (IS_ERR(target)) {
-		duprintf("find_check_entry: `%s' not found\n", t->u.user.name);
 		ret = PTR_ERR(target);
 		goto cleanup_matches;
 	}
@@ -746,17 +660,12 @@ check_entry_size_and_hooks(struct ip6t_entry *e,
 
 	if ((unsigned long)e % __alignof__(struct ip6t_entry) != 0 ||
 	    (unsigned char *)e + sizeof(struct ip6t_entry) >= limit ||
-	    (unsigned char *)e + e->next_offset > limit) {
-		duprintf("Bad offset %p\n", e);
+	    (unsigned char *)e + e->next_offset > limit)
 		return -EINVAL;
-	}
 
 	if (e->next_offset
-	    < sizeof(struct ip6t_entry) + sizeof(struct xt_entry_target)) {
-		duprintf("checking: element %p size %u\n",
-			 e, e->next_offset);
+	    < sizeof(struct ip6t_entry) + sizeof(struct xt_entry_target))
 		return -EINVAL;
-	}
 
 	if (!ip6_checkentry(&e->ipv6))
 		return -EINVAL;
@@ -773,12 +682,9 @@ check_entry_size_and_hooks(struct ip6t_entry *e,
 		if ((unsigned char *)e - base == hook_entries[h])
 			newinfo->hook_entry[h] = hook_entries[h];
 		if ((unsigned char *)e - base == underflows[h]) {
-			if (!check_underflow(e)) {
-				pr_debug("Underflows must be unconditional and "
-					 "use the STANDARD target with "
-					 "ACCEPT/DROP\n");
+			if (!check_underflow(e))
 				return -EINVAL;
-			}
+
 			newinfo->underflow[h] = underflows[h];
 		}
 	}
@@ -830,7 +736,6 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 		newinfo->underflow[i] = 0xFFFFFFFF;
 	}
 
-	duprintf("translate_table: size %u\n", newinfo->size);
 	i = 0;
 	/* Walk through entries, checking offsets. */
 	xt_entry_foreach(iter, entry0, newinfo->size) {
@@ -847,27 +752,18 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 			++newinfo->stacksize;
 	}
 
-	if (i != repl->num_entries) {
-		duprintf("translate_table: %u not %u entries\n",
-			 i, repl->num_entries);
+	if (i != repl->num_entries)
 		return -EINVAL;
-	}
 
 	/* Check hooks all assigned */
 	for (i = 0; i < NF_INET_NUMHOOKS; i++) {
 		/* Only hooks which are valid */
 		if (!(repl->valid_hooks & (1 << i)))
 			continue;
-		if (newinfo->hook_entry[i] == 0xFFFFFFFF) {
-			duprintf("Invalid hook entry %u %u\n",
-				 i, repl->hook_entry[i]);
+		if (newinfo->hook_entry[i] == 0xFFFFFFFF)
 			return -EINVAL;
-		}
-		if (newinfo->underflow[i] == 0xFFFFFFFF) {
-			duprintf("Invalid underflow %u %u\n",
-				 i, repl->underflow[i]);
+		if (newinfo->underflow[i] == 0xFFFFFFFF)
 			return -EINVAL;
-		}
 	}
 
 	if (!mark_source_chains(newinfo, repl->valid_hooks, entry0))
@@ -1095,11 +991,8 @@ static int get_info(struct net *net, void __user *user,
 	struct xt_table *t;
 	int ret;
 
-	if (*len != sizeof(struct ip6t_getinfo)) {
-		duprintf("length %u != %zu\n", *len,
-			 sizeof(struct ip6t_getinfo));
+	if (*len != sizeof(struct ip6t_getinfo))
 		return -EINVAL;
-	}
 
 	if (copy_from_user(name, user, sizeof(name)) != 0)
 		return -EFAULT;
@@ -1157,31 +1050,24 @@ get_entries(struct net *net, struct ip6t_get_entries __user *uptr,
 	struct ip6t_get_entries get;
 	struct xt_table *t;
 
-	if (*len < sizeof(get)) {
-		duprintf("get_entries: %u < %zu\n", *len, sizeof(get));
+	if (*len < sizeof(get))
 		return -EINVAL;
-	}
 	if (copy_from_user(&get, uptr, sizeof(get)) != 0)
 		return -EFAULT;
-	if (*len != sizeof(struct ip6t_get_entries) + get.size) {
-		duprintf("get_entries: %u != %zu\n",
-			 *len, sizeof(get) + get.size);
+	if (*len != sizeof(struct ip6t_get_entries) + get.size)
 		return -EINVAL;
-	}
+
 	get.name[sizeof(get.name) - 1] = '\0';
 
 	t = xt_find_table_lock(net, AF_INET6, get.name);
 	if (!IS_ERR_OR_NULL(t)) {
 		struct xt_table_info *private = t->private;
-		duprintf("t->private->number = %u\n", private->number);
 		if (get.size == private->size)
 			ret = copy_entries_to_user(private->size,
 						   t, uptr->entrytable);
-		else {
-			duprintf("get_entries: I've got %u not %u!\n",
-				 private->size, get.size);
+		else
 			ret = -EAGAIN;
-		}
+
 		module_put(t->me);
 		xt_table_unlock(t);
 	} else
@@ -1217,8 +1103,6 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 
 	/* You lied! */
 	if (valid_hooks != t->valid_hooks) {
-		duprintf("Valid hook crap: %08X vs %08X\n",
-			 valid_hooks, t->valid_hooks);
 		ret = -EINVAL;
 		goto put_module;
 	}
@@ -1228,8 +1112,6 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 		goto put_module;
 
 	/* Update module usage count based on number of rules */
-	duprintf("do_replace: oldnum=%u, initnum=%u, newnum=%u\n",
-		oldinfo->number, oldinfo->initial_entries, newinfo->number);
 	if ((oldinfo->number > oldinfo->initial_entries) ||
 	    (newinfo->number <= oldinfo->initial_entries))
 		module_put(t->me);
@@ -1298,8 +1180,6 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
 	if (ret != 0)
 		goto free_newinfo;
 
-	duprintf("ip_tables: Translated table\n");
-
 	ret = __do_replace(net, tmp.name, tmp.valid_hooks, newinfo,
 			   tmp.num_counters, tmp.counters);
 	if (ret)
@@ -1424,11 +1304,9 @@ compat_find_calc_match(struct xt_entry_match *m,
 
 	match = xt_request_find_match(NFPROTO_IPV6, m->u.user.name,
 				      m->u.user.revision);
-	if (IS_ERR(match)) {
-		duprintf("compat_check_calc_match: `%s' not found\n",
-			 m->u.user.name);
+	if (IS_ERR(match))
 		return PTR_ERR(match);
-	}
+
 	m->u.kernel.match = match;
 	*size += xt_compat_match_offset(match);
 	return 0;
@@ -1460,20 +1338,14 @@ check_compat_entry_size_and_hooks(struct compat_ip6t_entry *e,
 	unsigned int j;
 	int ret, off;
 
-	duprintf("check_compat_entry_size_and_hooks %p\n", e);
 	if ((unsigned long)e % __alignof__(struct compat_ip6t_entry) != 0 ||
 	    (unsigned char *)e + sizeof(struct compat_ip6t_entry) >= limit ||
-	    (unsigned char *)e + e->next_offset > limit) {
-		duprintf("Bad offset %p, limit = %p\n", e, limit);
+	    (unsigned char *)e + e->next_offset > limit)
 		return -EINVAL;
-	}
 
 	if (e->next_offset < sizeof(struct compat_ip6t_entry) +
-			     sizeof(struct compat_xt_entry_target)) {
-		duprintf("checking: element %p size %u\n",
-			 e, e->next_offset);
+			     sizeof(struct compat_xt_entry_target))
 		return -EINVAL;
-	}
 
 	if (!ip6_checkentry(&e->ipv6))
 		return -EINVAL;
@@ -1497,8 +1369,6 @@ check_compat_entry_size_and_hooks(struct compat_ip6t_entry *e,
 	target = xt_request_find_target(NFPROTO_IPV6, t->u.user.name,
 					t->u.user.revision);
 	if (IS_ERR(target)) {
-		duprintf("check_compat_entry_size_and_hooks: `%s' not found\n",
-			 t->u.user.name);
 		ret = PTR_ERR(target);
 		goto release_matches;
 	}
@@ -1577,7 +1447,6 @@ translate_compat_table(struct net *net,
 	size = compatr->size;
 	info->number = compatr->num_entries;
 
-	duprintf("translate_compat_table: size %u\n", info->size);
 	j = 0;
 	xt_compat_lock(AF_INET6);
 	xt_compat_init_offsets(AF_INET6, compatr->num_entries);
@@ -1592,11 +1461,8 @@ translate_compat_table(struct net *net,
 	}
 
 	ret = -EINVAL;
-	if (j != compatr->num_entries) {
-		duprintf("translate_compat_table: %u not %u entries\n",
-			 j, compatr->num_entries);
+	if (j != compatr->num_entries)
 		goto out_unlock;
-	}
 
 	ret = -ENOMEM;
 	newinfo = xt_alloc_table_info(size);
@@ -1687,8 +1553,6 @@ compat_do_replace(struct net *net, void __user *user, unsigned int len)
 	if (ret != 0)
 		goto free_newinfo;
 
-	duprintf("compat_do_replace: Translated table\n");
-
 	ret = __do_replace(net, tmp.name, tmp.valid_hooks, newinfo,
 			   tmp.num_counters, compat_ptr(tmp.counters));
 	if (ret)
@@ -1722,7 +1586,6 @@ compat_do_ip6t_set_ctl(struct sock *sk, int cmd, void __user *user,
 		break;
 
 	default:
-		duprintf("do_ip6t_set_ctl:  unknown request %i\n", cmd);
 		ret = -EINVAL;
 	}
 
@@ -1772,19 +1635,15 @@ compat_get_entries(struct net *net, struct compat_ip6t_get_entries __user *uptr,
 	struct compat_ip6t_get_entries get;
 	struct xt_table *t;
 
-	if (*len < sizeof(get)) {
-		duprintf("compat_get_entries: %u < %zu\n", *len, sizeof(get));
+	if (*len < sizeof(get))
 		return -EINVAL;
-	}
 
 	if (copy_from_user(&get, uptr, sizeof(get)) != 0)
 		return -EFAULT;
 
-	if (*len != sizeof(struct compat_ip6t_get_entries) + get.size) {
-		duprintf("compat_get_entries: %u != %zu\n",
-			 *len, sizeof(get) + get.size);
+	if (*len != sizeof(struct compat_ip6t_get_entries) + get.size)
 		return -EINVAL;
-	}
+
 	get.name[sizeof(get.name) - 1] = '\0';
 
 	xt_compat_lock(AF_INET6);
@@ -1792,16 +1651,13 @@ compat_get_entries(struct net *net, struct compat_ip6t_get_entries __user *uptr,
 	if (!IS_ERR_OR_NULL(t)) {
 		const struct xt_table_info *private = t->private;
 		struct xt_table_info info;
-		duprintf("t->private->number = %u\n", private->number);
 		ret = compat_table_info(private, &info);
-		if (!ret && get.size == info.size) {
+		if (!ret && get.size == info.size)
 			ret = compat_copy_entries_to_user(private->size,
 							  t, uptr->entrytable);
-		} else if (!ret) {
-			duprintf("compat_get_entries: I've got %u not %u!\n",
-				 private->size, get.size);
+		else if (!ret)
 			ret = -EAGAIN;
-		}
+
 		xt_compat_flush_offsets(AF_INET6);
 		module_put(t->me);
 		xt_table_unlock(t);
@@ -1854,7 +1710,6 @@ do_ip6t_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		break;
 
 	default:
-		duprintf("do_ip6t_set_ctl:  unknown request %i\n", cmd);
 		ret = -EINVAL;
 	}
 
@@ -1906,7 +1761,6 @@ do_ip6t_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	}
 
 	default:
-		duprintf("do_ip6t_get_ctl: unknown request %i\n", cmd);
 		ret = -EINVAL;
 	}
 
@@ -2008,7 +1862,6 @@ icmp6_match(const struct sk_buff *skb, struct xt_action_param *par)
 		/* We've been asked to examine this packet, and we
 		 * can't.  Hence, no choice but to drop.
 		 */
-		duprintf("Dropping evil ICMP tinygram.\n");
 		par->hotdrop = true;
 		return false;
 	}
-- 
2.1.4

