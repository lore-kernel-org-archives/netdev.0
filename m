From: Joe Perches <joe@perches.com>
Subject: [PATCH] vsprintf.c: remove stack variable ksym from
Date: Sat, 13 Mar 2010 11:54:39 -0800
Message-ID: <1268510079.30289.69.camel@Joe-Laptop.home>
References: <cover.1267682641.git.joe@perches.com>
	 <20100304143837.af39845d.akpm@linux-foundation.org>
	 <alpine.LFD.2.00.1003041504080.3751@localhost.localdomain>
	 <1267911399.849.39.camel@Joe-Laptop.home>
	 <alpine.LFD.2.00.1003061356420.31447@localhost.localdomain>
	 <1267914654.849.81.camel@Joe-Laptop.home>
	 <alpine.LFD.2.00.1003061445490.31447@localhost.localdomain>
	 <alpine.LFD.2.00.1003061455590.31447@localhost.localdomain>
	 <1267918554.849.89.camel@Joe-Laptop.home>
	 <alpine.LFD.2.00.1003061540470.23804@localhost.localdomain>
	 <alpine.LFD.2.00.1003061547490.23804@localhost.localdomain>
	 <alpine.LFD.2.00.1003061556420.23804@localhost.localdomain>
	 <1267924214.1937.12.camel@Joe-Laptop.home>
	 <alpine.LFD.2.00.1003061755400.23804@localhost.localdomain>
	 <1267929215.1937.18.camel@Joe-Laptop.home>
	 <20100312162559.a8e51777.akpm@linux-foundation.org>
	 <alpine.LFD.2.00.1003130734420.3719@i5.linux-foundation.org>
	 <1268502295.30289.44.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Nick Andrew <nick@nick-andrew.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org,
	Bjorn Helgaas <bjorn.helgaas@hp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1268502295.30289.44.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2010-03-13 at 09:44 -0800, Joe Perches wrote:
> On Sat, 2010-03-13 at 07:35 -0800, Linus Torvalds wrote:
> > On Fri, 12 Mar 2010, Andrew Morton wrote:
> > > nice.
> > But the kallsyms_lookup()/sprint_symbol() functions don't take a 
> > length parameter, so we have to do the worst-case thing (which itself has 
> > tons of unnecessary padding).
> Perhaps a new snprint_symbol function with the
> other kallsyms... functions changed as necessary.

Perhaps something like this:

Functions added:

kallsyms_lookup_n	length limited kallsyms_lookup
snprint_symbol		length limited sprint_symbol
module_address_lookup_n	length limited module_address_lookup

Changes to vsprintf.c, function symbol_string:

remove stack variable ksym, just use output buffer
and length limited functions.

Compiled, untested

Signed-off-by: Joe Perches
---
 include/linux/kallsyms.h |    7 ++++
 include/linux/module.h   |   15 ++++++++
 kernel/kallsyms.c        |   91 ++++++++++++++++++++++++++++++++++++++++------
 kernel/module.c          |   33 +++++++++++++++++
 lib/vsprintf.c           |   14 ++++---
 5 files changed, 143 insertions(+), 17 deletions(-)

diff --git a/include/linux/kallsyms.h b/include/linux/kallsyms.h
index d8e9b3d..b1729b5 100644
--- a/include/linux/kallsyms.h
+++ b/include/linux/kallsyms.h
@@ -34,8 +34,15 @@ const char *kallsyms_lookup(unsigned long addr,
 			    unsigned long *offset,
 			    char **modname, char *namebuf);
 
+const char *kallsyms_lookup_n(unsigned long addr,
+			      unsigned long *symbolsize,
+			      unsigned long *offset,
+			      char **modname, char *namebuf, size_t size);
+
 /* Look up a kernel symbol and return it in a text buffer. */
 extern int sprint_symbol(char *buffer, unsigned long address);
+/* Look up a kernel symbol and return it in a text buffer. */
+extern int snprint_symbol(char *buffer, size_t size, unsigned long address);
 
 /* Look up a kernel symbol and print it to the kernel messages. */
 extern void __print_symbol(const char *fmt, unsigned long address);
diff --git a/include/linux/module.h b/include/linux/module.h
index 5e869ff..7a65fad 100644
--- a/include/linux/module.h
+++ b/include/linux/module.h
@@ -520,6 +520,11 @@ const char *module_address_lookup(unsigned long addr,
 			    unsigned long *offset,
 			    char **modname,
 			    char *namebuf);
+const char *module_address_lookup_n(unsigned long addr,
+				    unsigned long *symbolsize,
+				    unsigned long *offset,
+				    char **modname,
+				    char *namebuf, size_t size);
 int lookup_module_symbol_name(unsigned long addr, char *symname);
 int lookup_module_symbol_attrs(unsigned long addr, unsigned long *size, unsigned long *offset, char *modname, char *name);
 
@@ -598,6 +603,16 @@ static inline const char *module_address_lookup(unsigned long addr,
 	return NULL;
 }
 
+/* For kallsyms to ask for address resolution.  NULL means not found. */
+static inline const char *module_address_lookup_n(unsigned long addr,
+						  unsigned long *symbolsize,
+						  unsigned long *offset,
+						  char **modname,
+						  char *namebuf, size_t size)
+{
+	return NULL;
+}
+
 static inline int lookup_module_symbol_name(unsigned long addr, char *symname)
 {
 	return -ERANGE;
diff --git a/kernel/kallsyms.c b/kernel/kallsyms.c
index 8e5288a..0516d23 100644
--- a/kernel/kallsyms.c
+++ b/kernel/kallsyms.c
@@ -84,9 +84,11 @@ static int is_ksym_addr(unsigned long addr)
  * Expand a compressed symbol data into the resulting uncompressed string,
  * given the offset to where the symbol is in the compressed stream.
  */
-static unsigned int kallsyms_expand_symbol(unsigned int off, char *result)
+static unsigned int kallsyms_expand_symbol(unsigned int off,
+					   char *result, size_t size)
 {
-	int len, skipped_first = 0;
+	int len;
+	bool skipped_first = false;
 	const u8 *tptr, *data;
 
 	/* Get the compressed symbol length from the first symbol byte. */
@@ -110,16 +112,18 @@ static unsigned int kallsyms_expand_symbol(unsigned int off, char *result)
 		len--;
 
 		while (*tptr) {
-			if (skipped_first) {
+			if (skipped_first && size > 1) {
 				*result = *tptr;
 				result++;
+				size--;
 			} else
-				skipped_first = 1;
+				skipped_first = true;
 			tptr++;
 		}
 	}
 
-	*result = '\0';
+	if (size)
+		*result = '\0';
 
 	/* Return to offset to the next symbol. */
 	return off;
@@ -174,7 +178,7 @@ unsigned long kallsyms_lookup_name(const char *name)
 	unsigned int off;
 
 	for (i = 0, off = 0; i < kallsyms_num_syms; i++) {
-		off = kallsyms_expand_symbol(off, namebuf);
+		off = kallsyms_expand_symbol(off, namebuf, sizeof(namebuf));
 
 		if (strcmp(namebuf, name) == 0)
 			return kallsyms_addresses[i];
@@ -193,7 +197,7 @@ int kallsyms_on_each_symbol(int (*fn)(void *, const char *, struct module *,
 	int ret;
 
 	for (i = 0, off = 0; i < kallsyms_num_syms; i++) {
-		off = kallsyms_expand_symbol(off, namebuf);
+		off = kallsyms_expand_symbol(off, namebuf, sizeof(namebuf));
 		ret = fn(data, namebuf, NULL, kallsyms_addresses[i]);
 		if (ret != 0)
 			return ret;
@@ -292,7 +296,8 @@ const char *kallsyms_lookup(unsigned long addr,
 
 		pos = get_symbol_pos(addr, symbolsize, offset);
 		/* Grab name */
-		kallsyms_expand_symbol(get_symbol_offset(pos), namebuf);
+		kallsyms_expand_symbol(get_symbol_offset(pos),
+				       namebuf, KSYM_NAME_LEN);
 		if (modname)
 			*modname = NULL;
 		return namebuf;
@@ -303,6 +308,38 @@ const char *kallsyms_lookup(unsigned long addr,
 				     namebuf);
 }
 
+/*
+ * Lookup an address (length_limited)
+ * - modname is set to NULL if it's in the kernel.
+ * - We guarantee that the returned name is valid until we reschedule even if.
+ *   It resides in a module.
+ * - We also guarantee that modname will be valid until rescheduled.
+ */
+const char *kallsyms_lookup_n(unsigned long addr,
+			      unsigned long *symbolsize,
+			      unsigned long *offset,
+			      char **modname, char *namebuf, size_t size)
+{
+	if (size)
+		namebuf[size - 1] = 0;
+	namebuf[0] = 0;
+
+	if (is_ksym_addr(addr)) {
+		unsigned long pos;
+
+		pos = get_symbol_pos(addr, symbolsize, offset);
+		/* Grab name */
+		kallsyms_expand_symbol(get_symbol_offset(pos), namebuf, size);
+		if (modname)
+			*modname = NULL;
+		return namebuf;
+	}
+
+	/* See if it's in a module. */
+	return module_address_lookup_n(addr, symbolsize, offset, modname,
+				       namebuf, size);
+}
+
 int lookup_symbol_name(unsigned long addr, char *symname)
 {
 	symname[0] = '\0';
@@ -313,7 +350,8 @@ int lookup_symbol_name(unsigned long addr, char *symname)
 
 		pos = get_symbol_pos(addr, NULL, NULL);
 		/* Grab name */
-		kallsyms_expand_symbol(get_symbol_offset(pos), symname);
+		kallsyms_expand_symbol(get_symbol_offset(pos),
+				       symname, KSYM_NAME_LEN);
 		return 0;
 	}
 	/* See if it's in a module. */
@@ -331,7 +369,8 @@ int lookup_symbol_attrs(unsigned long addr, unsigned long *size,
 
 		pos = get_symbol_pos(addr, size, offset);
 		/* Grab name */
-		kallsyms_expand_symbol(get_symbol_offset(pos), name);
+		kallsyms_expand_symbol(get_symbol_offset(pos),
+				       name, KSYM_NAME_LEN);
 		modname[0] = '\0';
 		return 0;
 	}
@@ -340,6 +379,36 @@ int lookup_symbol_attrs(unsigned long addr, unsigned long *size,
 }
 
 /* Look up a kernel symbol and return it in a text buffer. */
+int snprint_symbol(char *buffer, size_t size, unsigned long address)
+{
+	char *modname;
+	const char *name;
+	unsigned long offset, ksize;
+	int len;
+
+	name = kallsyms_lookup_n(address, &ksize, &offset, &modname,
+				 buffer, size);
+	if (!name)
+		return snprintf(buffer, size, "0x%lx", address);
+
+	if (name != buffer)
+		strncpy(buffer, name, size);
+	len = strlen(buffer);
+	buffer += len;
+
+	if (modname)
+		len += snprintf(buffer, size - len,
+				"+%#lx/%#lx [%s]", offset, ksize, modname);
+	else
+		len += snprintf(buffer, size - len,
+				"+%#lx/%#lx", offset, ksize);
+
+	return len;
+}
+EXPORT_SYMBOL_GPL(snprint_symbol);
+
+
+/* Look up a kernel symbol and return it in a text buffer. */
 int sprint_symbol(char *buffer, unsigned long address)
 {
 	char *modname;
@@ -407,7 +476,7 @@ static unsigned long get_ksymbol_core(struct kallsym_iter *iter)
 
 	iter->type = kallsyms_get_symbol_type(off);
 
-	off = kallsyms_expand_symbol(off, iter->name);
+	off = kallsyms_expand_symbol(off, iter->name, sizeof(iter->name));
 
 	return off - iter->nameoff;
 }
diff --git a/kernel/module.c b/kernel/module.c
index c968d36..17a879a 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -2607,6 +2607,39 @@ const char *module_address_lookup(unsigned long addr,
 	return ret;
 }
 
+/* For kallsyms to ask for address resolution.  NULL means not found.  Careful
+ * not to lock to avoid deadlock on oopses, simply disable preemption. */
+const char *module_address_lookup_n(unsigned long addr,
+				    unsigned long *ksize,
+				    unsigned long *offset,
+				    char **modname,
+				    char *namebuf, size_t size)
+{
+	struct module *mod;
+	const char *ret = NULL;
+
+	preempt_disable();
+	list_for_each_entry_rcu(mod, &modules, list) {
+		if (within_module_init(addr, mod) ||
+		    within_module_core(addr, mod)) {
+			if (modname)
+				*modname = mod->name;
+			ret = get_ksymbol(mod, addr, ksize, offset);
+			break;
+		}
+	}
+	/* Make a copy in here where it's safe */
+	if (ret) {
+		if (size) {
+			strncpy(namebuf, ret, size - 1);
+			namebuf[size - 1] = 0;
+		}
+		ret = namebuf;
+	}
+	preempt_enable();
+	return ret;
+}
+
 int lookup_module_symbol_name(unsigned long addr, char *symname)
 {
 	struct module *mod;
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 0d461c7..dab6354 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -571,13 +571,15 @@ static char *symbol_string(char *buf, char *end, void *ptr,
 {
 	unsigned long value = (unsigned long) ptr;
 #ifdef CONFIG_KALLSYMS
-	char sym[KSYM_SYMBOL_LEN];
-	if (ext != 'f' && ext != 's')
-		sprint_symbol(sym, value);
-	else
-		kallsyms_lookup(value, NULL, NULL, NULL, sym);
+	/* Cap ending position to spec.field_width if specified */
+	if (spec.field_width > 0 && (end - buf) > spec.field_width)
+		end = buf + spec.field_width;
 
-	return string(buf, end, sym, spec);
+	if (ext != 'f' && ext != 's')
+		return buf + snprint_symbol(buf, end - buf, value);
+		
+	kallsyms_lookup_n(value, NULL, NULL, NULL, buf, end - buf);
+	return buf + strlen(buf);
 #else
 	spec.field_width = 2 * sizeof(void *);
 	spec.flags |= SPECIAL | SMALL | ZEROPAD;
