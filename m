From: Andi Kleen <ak@suse.de>
Subject: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Thu, 22 Nov 2007 03:43:06 +0100 (CET)
Message-ID: <20071122343.446909000@suse.de>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:58866 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751003AbXKVCnI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 21:43:08 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There seems to be rough consensus that the kernel currently has too many 
exported symbols. A lot of these exports are generally usable utility 
functions or important driver interfaces; but another large part are functions
intended by only one or two very specific modules for a very specific purpose.
One example is the TCP code. It has most of its internals exported, but 
only for use by tcp_ipv6.c (and now a few more by the TCP/IP congestion modules) 
But it doesn't make sense to include these exported for a specific module
functions into a broader "kernel interface".   External modules assume
they can use these functions, but they were never intended for that.

This patch allows to export symbols only for specific modules by 
introducing symbol name spaces. A module name space has a white
list of modules that are allowed to import symbols for it; all others
can't use the symbols.

It adds two new macros: 

MODULE_NAMESPACE_ALLOW(namespace, module);

Allow module to import symbols from namespace. module is the module name without
.ko as displayed by lsmod.  Must be in the same module as the export
(and be duplicated if there are multiple modules exporting symbols
to a namespace).  Multiple allows for the same name space are allowed.

EXPORT_SYMBOL_NS(namespace, symbol);

Export symbol into namespace.  Only modules allowed for the namespace
will be able to use them. EXPORT_SYMBOL_NS implies GPL only
because it is only for "internal" interfaces.

The name spaces only work for module loading. I didn't find
a nice way to make them work inside the main kernel binary. This means
the name space is not enforced for modules that are built in.

The biggest amount of work is of course still open: to go over all the existing
exports and figure for which ones it makes sense to define a namespace.
I did it for TCP and UDP so far, but the kernel right now has nearly 10k
exports (with some dups) that would need to be checked and turned into
name spaces. I would expect any symbol that is only used by one or two
other modules is a strong candidate for a namespace; in some cases even more
with modules that are tightly coupled.

I am optimistic that in the end we will have a much more manageable 
kernel interface.

Caveats: 

Exports need one long word more memory.

I had to add some alignment magic to the existing EXPORT_SYMBOLs
to get the sections right. Tested on i386/x86-64, but I hope it also
still works on architectures with stricter alignment requirements
like ARM. Any testers for that?

---
 arch/arm/kernel/armksyms.c        |    2 
 include/asm-generic/vmlinux.lds.h |    7 +
 include/linux/module.h            |   71 +++++++++++++++----
 kernel/module.c                   |  137 +++++++++++++++++++++++++++++++-------
 4 files changed, 177 insertions(+), 40 deletions(-)

Index: linux/include/linux/module.h
===================================================================
--- linux.orig/include/linux/module.h
+++ linux/include/linux/module.h
@@ -34,6 +34,7 @@ struct kernel_symbol
 {
 	unsigned long value;
 	const char *name;
+	const char *namespace;
 };
 
 struct modversion_info
@@ -167,49 +168,80 @@ struct notifier_block;
 #ifdef CONFIG_MODULES
 
 /* Get/put a kernel symbol (calls must be symmetric) */
-void *__symbol_get(const char *symbol);
-void *__symbol_get_gpl(const char *symbol);
+extern void *do_symbol_get(const char *symbol, struct module *caller);
+#define __symbol_get(sym) do_symbol_get(sym, THIS_MODULE)
 #define symbol_get(x) ((typeof(&x))(__symbol_get(MODULE_SYMBOL_PREFIX #x)))
 
+struct module_ns {
+	char *name;
+	char *allowed;
+};
+
+#define NS_SEPARATOR "."
+
+/*
+ * Allow module MODULE to reference namespace NS.
+ * MODULE is just the base module name with suffix or path.
+ * This must be declared in the module (or main kernel) as where the
+ * symbols are defined. When multiple modules export symbols from
+ * a single namespace all modules need to contain a full set
+ * of MODULE_NAMESPACE_ALLOWs.
+ */
+#define MODULE_NAMESPACE_ALLOW(ns, module) \
+	static const struct module_ns __knamespace_##module##_##_##ns \
+	asm("__knamespace_" #module NS_SEPARATOR #ns)		\
+	__attribute_used__					\
+	__attribute__((section("__knamespace"), unused))	\
+	= { #ns,  #module }
+
 #ifndef __GENKSYMS__
 #ifdef CONFIG_MODVERSIONS
 /* Mark the CRC weak since genksyms apparently decides not to
  * generate a checksums for some symbols */
-#define __CRC_SYMBOL(sym, sec)					\
+#define __CRC_SYMBOL(sym, sec, post, post2)			\
 	extern void *__crc_##sym __attribute__((weak));		\
-	static const unsigned long __kcrctab_##sym		\
+	static const unsigned long __kcrctab_##sym##post	\
+	asm("__kcrctab_" #sym post2)				\
 	__attribute_used__					\
 	__attribute__((section("__kcrctab" sec), unused))	\
 	= (unsigned long) &__crc_##sym;
 #else
-#define __CRC_SYMBOL(sym, sec)
+#define __CRC_SYMBOL(sym, sec, post, post2)
 #endif
 
 /* For every exported symbol, place a struct in the __ksymtab section */
-#define __EXPORT_SYMBOL(sym, sec)				\
+#define __EXPORT_SYMBOL(sym, sec, post, post2, ns)		\
 	extern typeof(sym) sym;					\
-	__CRC_SYMBOL(sym, sec)					\
-	static const char __kstrtab_##sym[]			\
+	__CRC_SYMBOL(sym, sec, post, post2)			\
+	static const char __kstrtab_##sym##post[]		\
+	asm("__kstrtab_" #sym post2)				\
 	__attribute__((section("__ksymtab_strings")))		\
 	= MODULE_SYMBOL_PREFIX #sym;                    	\
-	static const struct kernel_symbol __ksymtab_##sym	\
+	static const struct kernel_symbol __ksymtab_##sym##post	\
+	asm("__ksymtab_" #sym post2)				\
 	__attribute_used__					\
 	__attribute__((section("__ksymtab" sec), unused))	\
-	= { (unsigned long)&sym, __kstrtab_##sym }
+	__attribute__((aligned(sizeof(void *))))		\
+	= { (unsigned long)&sym, __kstrtab_##sym##post, ns }
 
 #define EXPORT_SYMBOL(sym)					\
-	__EXPORT_SYMBOL(sym, "")
+	__EXPORT_SYMBOL(sym, "",,, NULL)
 
 #define EXPORT_SYMBOL_GPL(sym)					\
-	__EXPORT_SYMBOL(sym, "_gpl")
+	__EXPORT_SYMBOL(sym, "_gpl",,, NULL)
 
 #define EXPORT_SYMBOL_GPL_FUTURE(sym)				\
-	__EXPORT_SYMBOL(sym, "_gpl_future")
+	__EXPORT_SYMBOL(sym, "_gpl_future",,, NULL)
 
+/* Export symbol into namespace ns
+ * No _GPL variants because namespaces imply GPL only
+ */
+#define EXPORT_SYMBOL_NS(ns, sym)				\
+	__EXPORT_SYMBOL(sym, "_gpl",__##ns, NS_SEPARATOR #ns, #ns)
 
 #ifdef CONFIG_UNUSED_SYMBOLS
-#define EXPORT_UNUSED_SYMBOL(sym) __EXPORT_SYMBOL(sym, "_unused")
-#define EXPORT_UNUSED_SYMBOL_GPL(sym) __EXPORT_SYMBOL(sym, "_unused_gpl")
+#define EXPORT_UNUSED_SYMBOL(sym) __EXPORT_SYMBOL(sym, "_unused",,,NULL)
+#define EXPORT_UNUSED_SYMBOL_GPL(sym) __EXPORT_SYMBOL(sym, "_unused_gpl",,,NULL)
 #else
 #define EXPORT_UNUSED_SYMBOL(sym)
 #define EXPORT_UNUSED_SYMBOL_GPL(sym)
@@ -288,6 +320,10 @@ struct module
 	unsigned int num_gpl_future_syms;
 	const unsigned long *gpl_future_crcs;
 
+	/* Namespaces */
+	struct module_ns *knamespace;
+	unsigned num_knamespaces;
+
 	/* Exception table */
 	unsigned int num_exentries;
 	const struct exception_table_entry *extable;
@@ -391,7 +427,8 @@ extern void __module_put_and_exit(struct
 
 #ifdef CONFIG_MODULE_UNLOAD
 unsigned int module_refcount(struct module *mod);
-void __symbol_put(const char *symbol);
+extern void do_symbol_put(const char *symbol, struct module *caller);
+#define __symbol_put(symbol) do_symbol_put(symbol, THIS_MODULE)
 #define symbol_put(x) __symbol_put(MODULE_SYMBOL_PREFIX #x)
 void symbol_put_addr(void *addr);
 
@@ -470,6 +507,8 @@ extern void module_update_markers(struct
 #define EXPORT_SYMBOL_GPL_FUTURE(sym)
 #define EXPORT_UNUSED_SYMBOL(sym)
 #define EXPORT_UNUSED_SYMBOL_GPL(sym)
+#define EXPORT_SYMBOL_NS(sym, ns)
+#define MODULE_NAMESPACE_ALLOW(ns, allow)
 
 /* Given an address, look for it in the exception tables. */
 static inline const struct exception_table_entry *
Index: linux/kernel/module.c
===================================================================
--- linux.orig/kernel/module.c
+++ linux/kernel/module.c
@@ -140,6 +140,8 @@ extern const unsigned long __start___kcr
 extern const unsigned long __start___kcrctab_gpl_future[];
 extern const unsigned long __start___kcrctab_unused[];
 extern const unsigned long __start___kcrctab_unused_gpl[];
+extern const struct module_ns __start___knamespace[];
+extern const struct module_ns __stop___knamespace[];
 
 #ifndef CONFIG_MODVERSIONS
 #define symversion(base, idx) NULL
@@ -171,7 +173,7 @@ static void printk_unused_warning(const 
 }
 
 /* Find a symbol, return value, crc and module which owns it */
-static unsigned long __find_symbol(const char *name,
+static const struct kernel_symbol *do_find_symbol(const char *name,
 				   struct module **owner,
 				   const unsigned long **crc,
 				   int gplok)
@@ -184,7 +186,7 @@ static unsigned long __find_symbol(const
 	ks = lookup_symbol(name, __start___ksymtab, __stop___ksymtab);
 	if (ks) {
 		*crc = symversion(__start___kcrctab, (ks - __start___ksymtab));
-		return ks->value;
+		return ks;
 	}
 	if (gplok) {
 		ks = lookup_symbol(name, __start___ksymtab_gpl,
@@ -192,7 +194,7 @@ static unsigned long __find_symbol(const
 		if (ks) {
 			*crc = symversion(__start___kcrctab_gpl,
 					  (ks - __start___ksymtab_gpl));
-			return ks->value;
+			return ks;
 		}
 	}
 	ks = lookup_symbol(name, __start___ksymtab_gpl_future,
@@ -209,7 +211,7 @@ static unsigned long __find_symbol(const
 		}
 		*crc = symversion(__start___kcrctab_gpl_future,
 				  (ks - __start___ksymtab_gpl_future));
-		return ks->value;
+		return ks;
 	}
 
 	ks = lookup_symbol(name, __start___ksymtab_unused,
@@ -218,7 +220,7 @@ static unsigned long __find_symbol(const
 		printk_unused_warning(name);
 		*crc = symversion(__start___kcrctab_unused,
 				  (ks - __start___ksymtab_unused));
-		return ks->value;
+		return ks;
 	}
 
 	if (gplok)
@@ -228,7 +230,7 @@ static unsigned long __find_symbol(const
 		printk_unused_warning(name);
 		*crc = symversion(__start___kcrctab_unused_gpl,
 				  (ks - __start___ksymtab_unused_gpl));
-		return ks->value;
+		return ks;
 	}
 
 	/* Now try modules. */
@@ -237,7 +239,7 @@ static unsigned long __find_symbol(const
 		ks = lookup_symbol(name, mod->syms, mod->syms + mod->num_syms);
 		if (ks) {
 			*crc = symversion(mod->crcs, (ks - mod->syms));
-			return ks->value;
+			return ks;
 		}
 
 		if (gplok) {
@@ -246,14 +248,14 @@ static unsigned long __find_symbol(const
 			if (ks) {
 				*crc = symversion(mod->gpl_crcs,
 						  (ks - mod->gpl_syms));
-				return ks->value;
+				return ks;
 			}
 		}
 		ks = lookup_symbol(name, mod->unused_syms, mod->unused_syms + mod->num_unused_syms);
 		if (ks) {
 			printk_unused_warning(name);
 			*crc = symversion(mod->unused_crcs, (ks - mod->unused_syms));
-			return ks->value;
+			return ks;
 		}
 
 		if (gplok) {
@@ -263,7 +265,7 @@ static unsigned long __find_symbol(const
 				printk_unused_warning(name);
 				*crc = symversion(mod->unused_gpl_crcs,
 						  (ks - mod->unused_gpl_syms));
-				return ks->value;
+				return ks;
 			}
 		}
 		ks = lookup_symbol(name, mod->gpl_future_syms,
@@ -281,11 +283,92 @@ static unsigned long __find_symbol(const
 			}
 			*crc = symversion(mod->gpl_future_crcs,
 					  (ks - mod->gpl_future_syms));
-			return ks->value;
+			return ks;
 		}
 	}
 	DEBUGP("Failed to find symbol %s\n", name);
-	return 0;
+ 	return NULL;
+}
+
+/* Find namespace in a single namespace table */
+static const struct module_ns *lookup_namespace(const struct module_ns *start,
+						const struct module_ns *stop,
+		 			  	const char *name,
+						const char *reqname, int *n)
+{
+	const struct module_ns *ns;
+	for (ns = start; ns < stop; ns++)
+		if (!strcmp(name, ns->name)) {
+			(*n)++;
+			if (!strcmp(reqname, ns->allowed))
+				return ns;
+		}
+	return NULL;
+}
+
+/* Search all namespace tables for a namespace */
+static const struct module_ns *find_namespace(const char *name,
+					      const char *reqname, int *n,
+					      const struct module **modp)
+{
+	const struct module_ns *ns;
+	struct module *mod;
+	*modp = NULL;
+	ns = lookup_namespace(__start___knamespace, __stop___knamespace,
+				name, reqname, n);
+	if (ns)
+		return ns;
+	list_for_each_entry(mod, &modules, list) {
+		ns = lookup_namespace(mod->knamespace,
+				      mod->knamespace + mod->num_knamespaces,
+				      name, reqname, n);
+		if (ns) {
+			*modp = mod;
+			return ns;
+		}
+	}
+	return NULL;
+}
+
+/* Look up a symbol and check namespace */
+static unsigned long find_symbol(const char *name,
+				   struct module **owner,
+				   const unsigned long **crc,
+				   int gplok,
+			           struct module *requester)
+{
+	const struct kernel_symbol *ks;
+	ks = do_find_symbol(name, owner, crc, gplok);
+	if (!ks)
+		return 0;
+	/* When the symbol has a name space check if the requesting module
+	   is white listed as allowed. */
+	if (ks->namespace) {
+		int n = 0;
+		const struct module_ns *ns;
+		const struct module *mod;
+		ns = find_namespace(ks->namespace, requester->name, &n, &mod);
+		if (!ns) {
+			if (n > 0)
+				printk("module %s not allowed to "
+				       "reference namespace `%s' for %s\n",
+					requester->name, ks->namespace, name);
+			else
+				printk("%s referencing undeclared "
+				       "namespace `%s' for %s\n",
+					requester->name, ks->namespace, name);
+			return 0;
+		}
+		/* Only allow name space declarations in the symbol's own
+		   module. */
+		if (mod != *owner) {
+			printk("namespace `%s' for symbol `%s' defined "
+			       "in wrong module `%s'\n",
+				name, name, mod->name);
+			return 0;
+		}
+	}
+	return ks->value;
 }
 
 /* Search for module by name: must hold module_mutex. */
@@ -750,18 +833,18 @@ static void print_unload_info(struct seq
 		seq_printf(m, "-");
 }
 
-void __symbol_put(const char *symbol)
+void do_symbol_put(const char *symbol, struct module *caller)
 {
 	struct module *owner;
 	const unsigned long *crc;
 
 	preempt_disable();
-	if (!__find_symbol(symbol, &owner, &crc, 1))
+	if (!find_symbol(symbol, &owner, &crc, 1, caller))
 		BUG();
 	module_put(owner);
 	preempt_enable();
 }
-EXPORT_SYMBOL(__symbol_put);
+EXPORT_SYMBOL(do_symbol_put);
 
 void symbol_put_addr(void *addr)
 {
@@ -902,7 +985,7 @@ static inline int check_modstruct_versio
 	const unsigned long *crc;
 	struct module *owner;
 
-	if (!__find_symbol("struct_module", &owner, &crc, 1))
+	if (!find_symbol("struct_module", &owner, &crc, 1, mod))
 		BUG();
 	return check_version(sechdrs, versindex, "struct_module", mod,
 			     crc);
@@ -949,8 +1032,8 @@ static unsigned long resolve_symbol(Elf_
 	unsigned long ret;
 	const unsigned long *crc;
 
-	ret = __find_symbol(name, &owner, &crc,
-			!(mod->taints & TAINT_PROPRIETARY_MODULE));
+	ret = find_symbol(name, &owner, &crc,
+			!(mod->taints & TAINT_PROPRIETARY_MODULE), mod);
 	if (ret) {
 		/* use_module can fail due to OOM, or module unloading */
 		if (!check_version(sechdrs, versindex, name, mod, crc) ||
@@ -1320,21 +1403,21 @@ static void free_module(struct module *m
 	module_free(mod, mod->module_core);
 }
 
-void *__symbol_get(const char *symbol)
+void *do_symbol_get(const char *symbol, struct module *caller)
 {
 	struct module *owner;
 	unsigned long value;
 	const unsigned long *crc;
 
 	preempt_disable();
-	value = __find_symbol(symbol, &owner, &crc, 1);
+	value = find_symbol(symbol, &owner, &crc, 1, caller);
 	if (value && !strong_try_module_get(owner))
 		value = 0;
 	preempt_enable();
 
 	return (void *)value;
 }
-EXPORT_SYMBOL_GPL(__symbol_get);
+EXPORT_SYMBOL_GPL(do_symbol_get);
 
 /*
  * Ensure that an exported symbol [global namespace] does not already exist
@@ -1348,14 +1431,14 @@ static int verify_export_symbols(struct 
 	const unsigned long *crc;
 
 	for (i = 0; i < mod->num_syms; i++)
-		if (__find_symbol(mod->syms[i].name, &owner, &crc, 1)) {
+	        if (find_symbol(mod->syms[i].name, &owner, &crc, 1, mod)) {
 			name = mod->syms[i].name;
 			ret = -ENOEXEC;
 			goto dup;
 		}
 
 	for (i = 0; i < mod->num_gpl_syms; i++)
-		if (__find_symbol(mod->gpl_syms[i].name, &owner, &crc, 1)) {
+	        if (find_symbol(mod->gpl_syms[i].name, &owner, &crc, 1, mod)) {
 			name = mod->gpl_syms[i].name;
 			ret = -ENOEXEC;
 			goto dup;
@@ -1675,6 +1758,7 @@ static struct module *load_module(void _
 	unsigned int unusedgplcrcindex;
 	unsigned int markersindex;
 	unsigned int markersstringsindex;
+	unsigned int namespaceindex;
 	struct module *mod;
 	long err = 0;
 	void *percpu = NULL, *ptr = NULL; /* Stops spurious gcc warning */
@@ -1771,6 +1855,7 @@ static struct module *load_module(void _
 #ifdef ARCH_UNWIND_SECTION_NAME
 	unwindex = find_sec(hdr, sechdrs, secstrings, ARCH_UNWIND_SECTION_NAME);
 #endif
+	namespaceindex = find_sec(hdr, sechdrs, secstrings, "__knamespace");
 
 	/* Don't keep modinfo section */
 	sechdrs[infoindex].sh_flags &= ~(unsigned long)SHF_ALLOC;
@@ -1930,6 +2015,12 @@ static struct module *load_module(void _
 	if (unusedgplcrcindex)
 		mod->unused_crcs = (void *)sechdrs[unusedgplcrcindex].sh_addr;
 
+	if (namespaceindex) {
+		mod->knamespace = (void *)sechdrs[namespaceindex].sh_addr;
+		mod->num_knamespaces = sechdrs[namespaceindex].sh_size /
+					sizeof(struct module_ns);
+	}
+
 #ifdef CONFIG_MODVERSIONS
 	if ((mod->num_syms && !crcindex) ||
 	    (mod->num_gpl_syms && !gplcrcindex) ||
Index: linux/include/asm-generic/vmlinux.lds.h
===================================================================
--- linux.orig/include/asm-generic/vmlinux.lds.h
+++ linux/include/asm-generic/vmlinux.lds.h
@@ -127,6 +127,13 @@
 		VMLINUX_SYMBOL(__stop___kcrctab_gpl_future) = .;	\
 	}								\
 									\
+	/* Kernel symbol table: namespaces */				\
+	__knamespace : AT(ADDR(__knamespace) - LOAD_OFFSET) { 		\
+		VMLINUX_SYMBOL(__start___knamespace) = .;		\
+		*(__knamespace)						\
+		VMLINUX_SYMBOL(__stop___knamespace) = .;		\
+	}								\
+									\
 	/* Kernel symbol table: strings */				\
         __ksymtab_strings : AT(ADDR(__ksymtab_strings) - LOAD_OFFSET) {	\
 		*(__ksymtab_strings)					\
Index: linux/arch/arm/kernel/armksyms.c
===================================================================
--- linux.orig/arch/arm/kernel/armksyms.c
+++ linux/arch/arm/kernel/armksyms.c
@@ -52,7 +52,7 @@ extern void fp_enter(void);
  * This has a special calling convention; it doesn't
  * modify any of the usual registers, except for LR.
  */
-#define EXPORT_CRC_ALIAS(sym) __CRC_SYMBOL(sym, "")
+#define EXPORT_CRC_ALIAS(sym) __CRC_SYMBOL(sym, "", "", "")
 
 #define EXPORT_SYMBOL_ALIAS(sym,orig)		\
  EXPORT_CRC_ALIAS(sym)				\
