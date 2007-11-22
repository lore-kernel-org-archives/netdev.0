From: Andi Kleen <ak@suse.de>
Subject: [PATCH RFC] [6/9] Implement namespace checking in modpost
Date: Thu, 22 Nov 2007 03:43:11 +0100 (CET)
Message-ID: <20071122024311.CC9E314D68@wotan.suse.de>
References: <20071122343.446909000@suse.de>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:58882 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751647AbXKVCnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 21:43:13 -0500
In-Reply-To: <20071122343.446909000@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This checks the namespaces at build time in modpost

---
 scripts/mod/modpost.c |  344 ++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 317 insertions(+), 27 deletions(-)

Index: linux/scripts/mod/modpost.c
===================================================================
--- linux.orig/scripts/mod/modpost.c
+++ linux/scripts/mod/modpost.c
@@ -1,8 +1,9 @@
-/* Postprocess module symbol versions
+/* Postprocess module symbol versions and do various other module checks.
  *
  * Copyright 2003       Kai Germaschewski
  * Copyright 2002-2004  Rusty Russell, IBM Corporation
  * Copyright 2006       Sam Ravnborg
+ * Copyright 2007	Andi Kleen, SUSE Labs (changes licensed GPLv2 only)
  * Based in part on module-init-tools/depmod.c,file2alias
  *
  * This software may be used and distributed according to the terms
@@ -12,9 +13,13 @@
  */
 
 #include <ctype.h>
+#include <assert.h>
 #include "modpost.h"
 #include "../../include/linux/license.h"
 
+#define NS_SEPARATOR '.'
+#define NS_SEPARATOR_STRING "."
+
 /* Are we using CONFIG_MODVERSIONS? */
 int modversions = 0;
 /* Warn about undefined symbols? (do so if we have vmlinux) */
@@ -27,6 +32,9 @@ static int external_module = 0;
 static int vmlinux_section_warnings = 1;
 /* Only warn about unresolved symbols */
 static int warn_unresolved = 0;
+/* Fixing those would cause too many ifdefs -- off by default. */
+static int warn_missing_modules = 0;
+
 /* How a symbol is exported */
 enum export {
 	export_plain,      export_unused,     export_gpl,
@@ -105,19 +113,43 @@ static struct module *find_module(char *
 	return mod;
 }
 
-static struct module *new_module(char *modname)
+static const char *basename(const char *s)
+{
+	char *p = strrchr(s, '/');
+	if (p)
+		return p + 1;
+	return s;
+}
+
+static struct module *find_module_base(char *modname)
 {
 	struct module *mod;
-	char *p, *s;
 
-	mod = NOFAIL(malloc(sizeof(*mod)));
-	memset(mod, 0, sizeof(*mod));
-	p = NOFAIL(strdup(modname));
+	for (mod = modules; mod; mod = mod->next) {
+		if (strcmp(basename(mod->name), modname) == 0)
+			break;
+	}
+	return mod;
+}
 
+static void strip_o(char *p)
+{
+	char *s;
 	/* strip trailing .o */
 	if ((s = strrchr(p, '.')) != NULL)
 		if (strcmp(s, ".o") == 0)
 			*s = '\0';
+}
+
+static struct module *new_module(char *modname)
+{
+	struct module *mod;
+	char *p;
+
+	mod = NOFAIL(malloc(sizeof(*mod)));
+	memset(mod, 0, sizeof(*mod));
+	p = NOFAIL(strdup(modname));
+	strip_o(p);
 
 	/* add to list */
 	mod->name = p;
@@ -132,10 +164,12 @@ static struct module *new_module(char *m
  * struct symbol is also used for lists of unresolved symbols */
 
 #define SYMBOL_HASH_SIZE 1024
+#define NSALLOW_HASH_SIZE 64
 
 struct symbol {
 	struct symbol *next;
 	struct module *module;
+	const char *namespace;
 	unsigned int crc;
 	int crc_valid;
 	unsigned int weak:1;
@@ -147,10 +181,19 @@ struct symbol {
 	char name[0];
 };
 
+struct nsallow {
+	struct nsallow *next;
+	struct module *mod;
+	struct module *orig;
+	int ref;
+	char name[0];
+};
+
 static struct symbol *symbolhash[SYMBOL_HASH_SIZE];
+static struct nsallow *nsallowhash[NSALLOW_HASH_SIZE];
 
 /* This is based on the hash agorithm from gdbm, via tdb */
-static inline unsigned int tdb_hash(const char *name)
+static unsigned int tdb_hash(const char *name)
 {
 	unsigned value;	/* Used to compute the hash value.  */
 	unsigned   i;	/* Used to cycle through random values. */
@@ -192,21 +235,67 @@ static struct symbol *new_symbol(const c
 	return new;
 }
 
-static struct symbol *find_symbol(const char *name)
+static struct symbol *find_symbol(const char *name, const char *ns)
 {
-	struct symbol *s;
+	struct symbol *s, *match;
 
 	/* For our purposes, .foo matches foo.  PPC64 needs this. */
 	if (name[0] == '.')
 		name++;
 
+	match = NULL;
 	for (s = symbolhash[tdb_hash(name) % SYMBOL_HASH_SIZE]; s; s=s->next) {
+		if (strcmp(s->name, name) == 0) {
+			match = s;
+			if (ns && s->namespace && strcmp(s->namespace, ns))
+				continue;
+			return s;
+		}
+	}
+	return ns ? NULL : match;
+}
+
+static struct nsallow *find_nsallow(const char *name, struct module *mod)
+{
+	struct nsallow *s;
+
+	for (s = nsallowhash[tdb_hash(name)%NSALLOW_HASH_SIZE]; s; s=s->next) {
+		if (strcmp(s->name, name) == 0 && s->mod == mod)
+			return s;
+	}
+	return NULL;
+}
+
+static struct nsallow *find_nsallow_name(const char *name)
+{
+	struct nsallow *s;
+
+	for (s = nsallowhash[tdb_hash(name)%NSALLOW_HASH_SIZE]; s; s=s->next) {
 		if (strcmp(s->name, name) == 0)
 			return s;
 	}
 	return NULL;
 }
 
+static struct nsallow *
+new_nsallow(const char *name, struct module *module, struct module *orig)
+{
+	unsigned int hash;
+	struct nsallow *new;
+	unsigned len;
+
+	len = sizeof(struct nsallow) + strlen(name) + 1;
+	new = NOFAIL(malloc(len));
+	new->mod = module;
+	new->orig = orig;
+	new->ref = 0;
+	strcpy(new->name, name);
+	hash = tdb_hash(name) % NSALLOW_HASH_SIZE;
+	new->next = nsallowhash[hash];
+	nsallowhash[hash] = new;
+	return new;
+}
+
 static struct {
 	const char *str;
 	enum export export;
@@ -253,27 +342,103 @@ static enum export export_from_sec(struc
 		return export_unknown;
 }
 
+/* Check if all the name space that allows referencing the symbol's
+   namespace is in the same module as the export. This makes sure a
+   module doesn't allow itself into a namespace (the kernel checks
+   this too) */
+static void check_export_namespace(struct symbol *s)
+{
+	const char *namespace = s->namespace;
+	struct nsallow *nsa = find_nsallow_name(namespace);
+	if (!nsa) {
+		warn("%s: namespace %s used for export `%s', but no module "
+		     "for it allowed\n", s->module->name, namespace, s->name);
+	}
+	for (; nsa; nsa = nsa->next) {
+		if (strcmp(nsa->name, namespace))
+			continue;
+		if (nsa->orig == s->module) {
+			nsa->ref++;
+			return;
+		}
+	}
+	merror("No module allowed for namespace %s in %s exporting %s\n",
+		namespace,
+		s->module->name,
+		s->name);
+}
+
+static void check_nsallow_referenced(void)
+{
+	int i;
+	struct nsallow *nsa;
+	for (i = 0; i < NSALLOW_HASH_SIZE; i++) {
+		for (nsa = nsallowhash[i]; nsa; nsa = nsa->next)
+			if (nsa->ref == 0 && !nsa->mod->skip) {
+				warn("%s: namespace %s allowed for module %s, "
+				     "but no exports using it\n",
+				     nsa->orig->name,
+				     nsa->name,
+				     nsa->mod->name);
+			}
+	}
+}
+
+static const char *sep_ns(const char **name)
+{
+	char *p;
+	const char *s = strchr(*name, NS_SEPARATOR);
+	if (!s)
+		return NULL;
+	*name = NOFAIL(strdup(*name));
+	p = strchr(*name, NS_SEPARATOR);
+	*p = '\0';
+	return p + 1;
+}
+
+static int deep_streq(const char *a, const char *b)
+{
+	if (a == b)
+		return 1;
+	if (!a || !b)
+		return 0;
+	return !strcmp(a, b);
+}
+
 /**
  * Add an exported symbol - it may have already been added without a
  * CRC, in this case just update the CRC
  **/
-static struct symbol *sym_add_exported(const char *name, struct module *mod,
+static struct symbol *sym_add_exported(const char *oname, struct module *mod,
 				       enum export export)
 {
-	struct symbol *s = find_symbol(name);
+	const char *name = oname;
+	const char *namespace = sep_ns(&name);
+	struct symbol *s = find_symbol(name, namespace);
 
 	if (!s) {
 		s = new_symbol(name, mod, export);
+		s->namespace = namespace;
 	} else {
 		if (!s->preloaded) {
 			warn("%s: '%s' exported twice. Previous export "
-			     "was in %s%s\n", mod->name, name,
+			     "was in %s%s\n", mod->name, oname,
 			     s->module->name,
 			     is_vmlinux(s->module->name) ?"":".ko");
+			if (!deep_streq(s->namespace, namespace)) {
+				warn("%s: New namespace '%s' of '%s' doesn't "
+				     "match existing namespace '%s'\n",
+				     s->module->name,
+				     namespace ?: "",
+				     s->name ?: "???",
+				     s->namespace ?: "");
+			}
 		} else {
 			/* In case Modules.symvers was out of date */
 			s->module = mod;
 		}
+		if (name != oname)
+			free((char *)name);
 	}
 	s->preloaded = 0;
 	s->vmlinux   = is_vmlinux(mod->name);
@@ -282,13 +447,58 @@ static struct symbol *sym_add_exported(c
 	return s;
 }
 
-static void sym_update_crc(const char *name, struct module *mod,
+static struct module *
+nsmodule(const char *name, int sep, const char *namespace, struct module *orig)
+{
+	struct module *mod;
+	char *modname = NOFAIL(malloc(sep + 1));
+
+	memcpy(modname, name, sep);
+	modname[sep] = 0;
+	mod = find_module_base(modname);
+	if (!mod) {
+		if (warn_missing_modules)
+			warn("%s: Namespace allow for %s references unknown"
+		    	 " module %.*s\n", orig->name, namespace, sep, name);
+		mod = new_module(modname);
+		mod->skip = 1;
+	} else {
+		free(modname);
+	}
+	return mod;
+}
+
+static void sym_add_nsallow(const char *name, struct module *orig)
+{
+	struct module *mod;
+	int sep;
+	const char *namespace;
+
+	sep = strcspn(name, NS_SEPARATOR_STRING);
+	if (name[sep] == 0 || sep == 0) {
+		warn("%s: Namespace allow '%s' incorrectly formatted\n",
+			orig->name, name);
+		return;
+	}
+	namespace = name + sep + 1;
+	mod = nsmodule(name, sep, namespace, orig);
+	if (!find_nsallow(namespace, mod))
+		new_nsallow(namespace, mod, orig);
+}
+
+static void sym_update_crc(const char *oname, struct module *mod,
 			   unsigned int crc, enum export export)
 {
-	struct symbol *s = find_symbol(name);
+	const char *name = oname;
+	const char *namespace = sep_ns(&name);
+	struct symbol *s = find_symbol(name, namespace);
 
-	if (!s)
+	if (!s) {
 		s = new_symbol(name, mod, export);
+	} else if (oname != name) {
+		assert(deep_streq(s->namespace, namespace));
+		free((char *)name);
+	}
 	s->crc = crc;
 	s->crc_valid = 1;
 }
@@ -456,6 +666,22 @@ static void parse_elf_finish(struct elf_
 
 #define CRC_PFX     MODULE_SYMBOL_PREFIX "__crc_"
 #define KSYMTAB_PFX MODULE_SYMBOL_PREFIX "__ksymtab_"
+#define NSALLOW_PFX MODULE_SYMBOL_PREFIX "__knamespace_"
+
+
+static void handle_nsallow(struct module *mod, struct elf_info *info,
+			       Elf_Sym *sym, const char *symname)
+{
+	switch (sym->st_shndx) {
+	case SHN_COMMON:
+	case SHN_ABS:
+	case SHN_UNDEF:
+		break;
+	default:
+		if (!strncmp(symname, NSALLOW_PFX, sizeof(NSALLOW_PFX)-1))
+			sym_add_nsallow(symname + sizeof(NSALLOW_PFX) - 1, mod);
+	}
+}
 
 static void handle_modversions(struct module *mod, struct elf_info *info,
 			       Elf_Sym *sym, const char *symname)
@@ -507,17 +733,25 @@ static void handle_modversions(struct mo
 #endif
 
 		if (memcmp(symname, MODULE_SYMBOL_PREFIX,
-			   strlen(MODULE_SYMBOL_PREFIX)) == 0)
-			mod->unres = alloc_symbol(symname +
-						  strlen(MODULE_SYMBOL_PREFIX),
+			   strlen(MODULE_SYMBOL_PREFIX)) == 0) {
+			const int plen = strlen(MODULE_SYMBOL_PREFIX);
+			const char *name = symname + plen;
+			const char *namespace = sep_ns(&name);
+
+			mod->unres = alloc_symbol(name,
 						  ELF_ST_BIND(sym->st_info) == STB_WEAK,
 						  mod->unres);
+			mod->unres->namespace = namespace;
+		}
 		break;
 	default:
 		/* All exported symbols */
 		if (memcmp(symname, KSYMTAB_PFX, strlen(KSYMTAB_PFX)) == 0) {
-			sym_add_exported(symname + strlen(KSYMTAB_PFX), mod,
-					export);
+			struct symbol *s;
+			s = sym_add_exported(symname + strlen(KSYMTAB_PFX), mod,
+					     export);
+			if (s->namespace)
+				check_export_namespace(s);
 		}
 		if (strcmp(symname, MODULE_SYMBOL_PREFIX "init_module") == 0)
 			mod->has_init = 1;
@@ -1261,11 +1495,16 @@ static void read_symbols(char *modname)
 	struct elf_info info = { };
 	Elf_Sym *sym;
 
+	char m[strlen(modname) + 1];
+	strcpy(m, modname);
+	strip_o(m);
+
+	mod = find_module(m);
+	assert(mod != NULL);
+
 	if (!parse_elf(&info, modname))
 		return;
 
-	mod = new_module(modname);
-
 	/* When there's no vmlinux, don't print warnings about
 	 * unresolved symbols (since there'll be too many ;) */
 	if (is_vmlinux(modname)) {
@@ -1285,6 +1524,12 @@ static void read_symbols(char *modname)
 					   "license", license);
 	}
 
+	/* First process all nsallows to check them against the symbols */
+	for (sym = info.symtab_start; sym < info.symtab_stop; sym++) {
+		symname = info.strtab + sym->st_name;
+		handle_nsallow(mod, &info, sym, symname);
+	}
+
 	for (sym = info.symtab_start; sym < info.symtab_stop; sym++) {
 		symname = info.strtab + sym->st_name;
 
@@ -1384,13 +1629,39 @@ static void check_for_unused(enum export
 	}
 }
 
+/* Check if symbol reference to S from module SYMMOD is allowed in namespace */
+static void check_symbol_ns(struct symbol *s, struct module *symmod,
+			    const char *symmodname)
+{
+	const char *namespace = s->namespace;
+	struct nsallow *nsa;
+	int sep;
+
+	if (is_vmlinux(symmodname))
+		return;
+	nsa = find_nsallow(namespace, symmod);
+	if (nsa)
+		return;
+	sep = strcspn(s->name, NS_SEPARATOR_STRING);
+	if (!find_nsallow_name(namespace)) {
+		warn("%s: Unknown namespace %s referenced from `%.*s'\n",
+		     symmodname, namespace, sep, s->name);
+	} else {
+		merror("%s: module not allowed to reference symbol "
+		       "'%.*s' in namespace %s\n",
+		       symmodname,
+		       sep, s->name,
+		       namespace);
+	}
+}
+
 static void check_exports(struct module *mod)
 {
 	struct symbol *s, *exp;
 
 	for (s = mod->unres; s; s = s->next) {
 		const char *basename;
-		exp = find_symbol(s->name);
+		exp = find_symbol(s->name, s->namespace);
 		if (!exp || exp->module == mod)
 			continue;
 		basename = strrchr(mod->name, '/');
@@ -1398,6 +1669,8 @@ static void check_exports(struct module 
 			basename++;
 		else
 			basename = mod->name;
+		if (s->namespace)
+			check_symbol_ns(s, mod, basename);
 		if (!mod->gpl_compatible)
 			check_for_gpl_usage(exp->export, basename, exp->name);
 		check_for_unused(exp->export, basename, exp->name);
@@ -1437,14 +1710,18 @@ static int add_versions(struct buffer *b
 	int err = 0;
 
 	for (s = mod->unres; s; s = s->next) {
-		exp = find_symbol(s->name);
+		exp = find_symbol(s->name, s->namespace);
 		if (!exp || exp->module == mod) {
 			if (have_vmlinux && !s->weak) {
 				if (warn_unresolved) {
-					warn("\"%s\" [%s.ko] undefined!\n",
+					warn("\"%s%s%s\" [%s.ko] undefined!\n",
+					 	s->namespace ?: "",
+						s->namespace ? ":" : "",
 					     s->name, mod->name);
 				} else {
-					merror("\"%s\" [%s.ko] undefined!\n",
+					merror("\"%s%s%s\" [%s.ko] undefined!\n",
+					 	s->namespace ?: "",
+						s->namespace ? ":" : "",
 					          s->name, mod->name);
 					err = 1;
 				}
@@ -1606,7 +1883,7 @@ static void read_dump(const char *fname,
 			if (is_vmlinux(modname)) {
 				have_vmlinux = 1;
 			}
-			mod = new_module(NOFAIL(strdup(modname)));
+			mod = new_module(modname);
 			mod->skip = 1;
 		}
 		s = sym_add_exported(symname, mod, export_no(export));
@@ -1660,6 +1937,7 @@ int main(int argc, char **argv)
 	char *dump_write = NULL;
 	int opt;
 	int err;
+	int c;
 
 	while ((opt = getopt(argc, argv, "i:I:mso:aw")) != -1) {
 		switch(opt) {
@@ -1685,6 +1963,9 @@ int main(int argc, char **argv)
 			case 'w':
 				warn_unresolved = 1;
 				break;
+			case 'M':
+				warn_missing_modules = 1;
+				break;
 			default:
 				exit(1);
 		}
@@ -1695,6 +1976,12 @@ int main(int argc, char **argv)
 	if (module_read)
 		read_dump(module_read, 0);
 
+	for (c = optind; c < argc; c++) {
+		char s[strlen(argv[c]) + 1];
+		strcpy(s, argv[c]);
+		new_module(s);
+	}
+
 	while (optind < argc) {
 		read_symbols(argv[optind++]);
 	}
@@ -1705,6 +1992,9 @@ int main(int argc, char **argv)
 		check_exports(mod);
 	}
 
+	if (warn_unresolved)
+		check_nsallow_referenced();
+
 	err = 0;
 
 	for (mod = modules; mod; mod = mod->next) {
