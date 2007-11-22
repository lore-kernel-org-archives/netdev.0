From: Andi Kleen <ak@suse.de>
Subject: [PATCH RFC] [2/9] Fix duplicate symbol check to also check future gpl and unused symbols
Date: Thu, 22 Nov 2007 03:43:07 +0100 (CET)
Message-ID: <20071122024307.8C4A314D68@wotan.suse.de>
References: <20071122343.446909000@suse.de>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:58869 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751261AbXKVCnI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 21:43:08 -0500
In-Reply-To: <20071122343.446909000@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This seems to have been forgotten earlier. Right now it was possible
for a normal symbol to override a future gpl symbol and similar.
I restructured the code a bit to avoid too much duplicated code.

---
 kernel/module.c |   45 ++++++++++++++++++++++++---------------------
 1 file changed, 24 insertions(+), 21 deletions(-)

Index: linux/kernel/module.c
===================================================================
--- linux.orig/kernel/module.c
+++ linux/kernel/module.c
@@ -1430,33 +1430,36 @@ EXPORT_SYMBOL_GPL(do_symbol_get);
  * Ensure that an exported symbol [global namespace] does not already exist
  * in the kernel or in some other module's exported symbol table.
  */
-static int verify_export_symbols(struct module *mod)
+
+static int check_duplicate(const struct kernel_symbol *syms, int num, struct module *owner)
 {
-	const char *name = NULL;
-	unsigned long i, ret = 0;
-	struct module *owner;
+	int i;
 	const unsigned long *crc;
 
-	for (i = 0; i < mod->num_syms; i++)
-	        if (find_symbol(mod->syms[i].name, &owner, &crc, 1, mod)) {
-			name = mod->syms[i].name;
-			ret = -ENOEXEC;
-			goto dup;
-		}
-
-	for (i = 0; i < mod->num_gpl_syms; i++)
-	        if (find_symbol(mod->gpl_syms[i].name, &owner, &crc, 1, mod)) {
-			name = mod->gpl_syms[i].name;
-			ret = -ENOEXEC;
-			goto dup;
+	for (i = 0; i < num; i++)
+	        if (find_symbol(syms[i].name, &owner, &crc, 1, owner)) {
+			printk(KERN_ERR "%s: exports duplicate symbol %s (owned by %s)\n",
+				owner->name, syms[i].name, module_name(owner));
+			return -ENOEXEC;
 		}
+	return 0;
+}
 
-dup:
+static int verify_export_symbols(struct module *mod)
+{
+	int ret = check_duplicate(mod->syms, mod->num_syms, mod);
 	if (ret)
-		printk(KERN_ERR "%s: exports duplicate symbol %s (owned by %s)\n",
-			mod->name, name, module_name(owner));
-
-	return ret;
+		return ret;
+	ret = check_duplicate(mod->gpl_syms, mod->num_gpl_syms, mod);
+	if (ret)
+		return ret;
+	ret = check_duplicate(mod->unused_syms, mod->num_unused_syms, mod);
+	if (ret)
+		return ret;
+	ret = check_duplicate(mod->unused_gpl_syms, mod->num_unused_gpl_syms, mod);
+	if (ret)
+		return ret;
+	return check_duplicate(mod->gpl_future_syms, mod->num_gpl_future_syms, mod);
 }
 
 /* Change all symbols so that sh_value encodes the pointer directly. */
