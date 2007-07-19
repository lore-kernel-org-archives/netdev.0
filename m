From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: [PATCH] net/, drivers/net/ , missing EXPERIMENTAL in menus
Date: Thu, 19 Jul 2007 23:05:57 +0100
Message-ID: <469FE045.3070403@simon.arlott.org.uk>
References: <469E75AA.7040109@pimpmylinux.org> <Pine.LNX.4.64.0707181620460.13912@localhost.localdomain> <20070718134012.cde2f956.randy.dunlap@oracle.com> <469E7BE1.6090401@garzik.org> <Pine.LNX.4.64.0707181648330.15343@localhost.localdomain> <20070718210903.GM3801@stusta.de> <Pine.LNX.4.64.0707181712340.16513@localhost.localdomain> <20070719054742.GN3801@stusta.de> <Pine.LNX.4.64.0707190331330.11902@localhost.localdomain> <469F240E.9040205@s5r6.in-berlin.de> <Pine.LNX.4.64.0707190523001.19216@localhost.localdomain> <20070719083109.13b2ab56.rdunlap@xenotime.net> <Pine.LNX.4.64.0707191213130.8844@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Robert P. J. Day" <rpjday@mindspring.com>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Adrian Bunk <bunk@stusta.de>, Jeff Garzik <jeff@garzik.org>,
	Gabriel C <crazy@pimpmylinux.org>, netdev@vger.kernel.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:58130 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763092AbXGSWGF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 18:06:05 -0400
In-Reply-To: <Pine.LNX.4.64.0707191213130.8844@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19/07/07 17:19, Robert P. J. Day wrote:
> On Thu, 19 Jul 2007, Randy Dunlap wrote:
>> I think that Stefan means a patch to the kconfig source code,
>> not the the Kconfig files.  Good luck.  I'd still like to see it.
> 
> yes, i understand what he wanted now.  as a first step (that
> theoretically shouldn't change any behaviour), i'd patch the Kconfig
> structure to add a new attribute ("maturity") which would be allowed
> to be set to *exactly one* of a pre-defined set of values (say,
> OBSOLETE, DEPRECATED, EXPERIMENTAL, and STILLBLEEDING).  and that's
> it, nothing more.
> 
> don't try to do anything with any of that just yet, just add the
> infrastructure to support the (optional) association of a maturity
> level with a config option.  that's step one.

What about something like this? I'm not sure if the addition to sym_init
is desirable... I also had to prefix _ to the name for now otherwise it
conflicts badly with the current symbols. It probably should stop
"depends on _BROKEN" etc. too.

---
diff --git a/init/Kconfig b/init/Kconfig
diff --git a/net/Kconfig b/net/Kconfig
index cdba08c..5e2f4db 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -6,6 +6,7 @@ menu "Networking"

 config NET
 	bool "Networking support"
+	maturity _BROKEN
 	---help---
 	  Unless you really know what you are doing, you should say Y here.
 	  The reason is that some programs need kernel networking support even
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
diff --git a/scripts/kconfig/Makefile b/scripts/kconfig/Makefile
index fb2bb30..1dea08e 100644
--- a/scripts/kconfig/Makefile
+++ b/scripts/kconfig/Makefile
@@ -256,7 +256,7 @@ $(obj)/lkc_defs.h: $(src)/lkc_proto.h
 # The following requires flex/bison/gperf
 # By default we use the _shipped versions, uncomment the following line if
 # you are modifying the flex/bison src.
-# LKC_GENPARSER := 1
+LKC_GENPARSER := 1

 ifdef LKC_GENPARSER

diff --git a/scripts/kconfig/conf.c b/scripts/kconfig/conf.c
index 1199baf..cc9be0e 100644
--- a/scripts/kconfig/conf.c
+++ b/scripts/kconfig/conf.c
@@ -211,6 +211,22 @@ static int conf_sym(struct menu *menu)

 	while (1) {
 		printf("%*s%s ", indent - 1, "", menu->prompt->text);
+		switch (sym->maturity) {
+		case M_EXPERIMENTAL:
+			printf("(EXPERIMENTAL) ");
+			break;
+		case M_DEPRECATED:
+			printf("(DEPRECATED) ");
+			break;
+		case M_OBSOLETE:
+			printf("(OBSOLETE) ");
+			break;
+		case M_BROKEN:
+			printf("(BROKEN) ");
+			break;
+		default:
+			break;
+		}
 		if (sym->name)
 			printf("(%s) ", sym->name);
 		type = sym_get_type(sym);
diff --git a/scripts/kconfig/expr.h b/scripts/kconfig/expr.h
index 6084525..a22b6c1 100644
--- a/scripts/kconfig/expr.h
+++ b/scripts/kconfig/expr.h
@@ -60,7 +60,11 @@ struct symbol_value {
 };

 enum symbol_type {
-	S_UNKNOWN, S_BOOLEAN, S_TRISTATE, S_INT, S_HEX, S_STRING, S_OTHER
+	S_UNKNOWN, S_BOOLEAN, S_TRISTATE, S_INT, S_HEX, S_STRING, S_MATURITY,
S_OTHER
+};
+
+enum maturity_level {
+	M_NONE, M_EXPERIMENTAL, M_DEPRECATED, M_OBSOLETE, M_BROKEN
 };

 enum {
@@ -72,6 +76,7 @@ struct symbol {
 	struct symbol *next;
 	char *name;
 	char *help;
+	enum maturity_level maturity;
 	enum symbol_type type;
 	struct symbol_value curr;
 	struct symbol_value def[4];
diff --git a/scripts/kconfig/lex.zconf.c_shipped
b/scripts/kconfig/lex.zconf.c_shipped
diff --git a/scripts/kconfig/lkc.h b/scripts/kconfig/lkc.h
index 8a07ee4..9add1cd 100644
--- a/scripts/kconfig/lkc.h
+++ b/scripts/kconfig/lkc.h
@@ -79,6 +79,7 @@ void menu_end_menu(void);
 void menu_add_entry(struct symbol *sym);
 void menu_end_entry(void);
 void menu_add_dep(struct expr *dep);
+void menu_set_maturity(struct symbol *sym);
 struct property *menu_add_prop(enum prop_type type, char *prompt,
struct expr *expr, struct expr *dep);
 struct property *menu_add_prompt(enum prop_type type, char *prompt,
struct expr *dep);
 void menu_add_expr(enum prop_type type, struct expr *expr, struct expr
*dep);
diff --git a/scripts/kconfig/mconf.c b/scripts/kconfig/mconf.c
index d0e4fa5..eaf199b 100644
--- a/scripts/kconfig/mconf.c
+++ b/scripts/kconfig/mconf.c
@@ -238,6 +238,7 @@ search_help[] = N_(
 	"Result:\n"
 	"-----------------------------------------------------------------\n"
 	"Symbol: FOO [=m]\n"
+	"Maturity: FOO\n"
 	"Prompt: Foo bus is used to drive the bar HW\n"
 	"Defined at drivers/pci/Kconfig:47\n"
 	"Depends on: X86_LOCAL_APIC && X86_IO_APIC || IA64\n"
@@ -359,6 +360,27 @@ static void get_symbol_str(struct gstr *r, struct
symbol *sym)

 	str_printf(r, "Symbol: %s [=%s]\n", sym->name,
 	                               sym_get_string_value(sym));
+
+	if (sym->maturity != M_NONE) {
+		str_append(r, "Maturity: ");
+		switch (sym->maturity) {
+		case M_EXPERIMENTAL:
+			str_append(r, "EXPERIMENTAL\n");
+			break;
+		case M_DEPRECATED:
+			str_append(r, "DEPRECATED\n");
+			break;
+		case M_OBSOLETE:
+			str_append(r, "OBSOLETE\n");
+			break;
+		case M_BROKEN:
+			str_append(r, "BROKEN\n");
+			break;
+		default:
+			break;
+		}
+	}
+
 	for_all_prompts(sym, prop)
 		get_prompt_str(r, prop);
 	hit = false;
diff --git a/scripts/kconfig/menu.c b/scripts/kconfig/menu.c
index f14aeac..3e37e5b 100644
--- a/scripts/kconfig/menu.c
+++ b/scripts/kconfig/menu.c
@@ -104,6 +104,15 @@ void menu_add_dep(struct expr *dep)
 	current_entry->dep = expr_alloc_and(current_entry->dep,
menu_check_dep(dep));
 }

+void menu_set_maturity(struct symbol *sym)
+{
+	if (sym->type != S_MATURITY) {
+		zconf_error("'%s' is an invalid maturity level", sym->name);
+	} else {
+		current_entry->sym->maturity = sym->maturity;
+	}
+}
+
 void menu_set_type(int type)
 {
 	struct symbol *sym = current_entry->sym;
diff --git a/scripts/kconfig/symbol.c b/scripts/kconfig/symbol.c
index c35dcc5..280ee8f 100644
--- a/scripts/kconfig/symbol.c
+++ b/scripts/kconfig/symbol.c
@@ -72,6 +72,22 @@ void sym_init(void)
 	sym->type = S_STRING;
 	sym->flags |= SYMBOL_AUTO;
 	sym_add_default(sym, uts.release);
+
+	sym = sym_lookup("_EXPERIMENTAL", 0);
+	sym->type = S_MATURITY;
+	sym->maturity = M_EXPERIMENTAL;
+
+	sym = sym_lookup("_DEPRECATED", 0);
+	sym->type = S_MATURITY;
+	sym->maturity = M_DEPRECATED;
+
+	sym = sym_lookup("_OBSOLETE", 0);
+	sym->type = S_MATURITY;
+	sym->maturity = M_OBSOLETE;
+
+	sym = sym_lookup("_BROKEN", 0);
+	sym->type = S_MATURITY;
+	sym->maturity = M_BROKEN;
 }

 enum symbol_type sym_get_type(struct symbol *sym)
@@ -100,6 +116,8 @@ const char *sym_type_name(enum symbol_type type)
 		return "hex";
 	case S_STRING:
 		return "string";
+	case S_MATURITY:
+		return "maturity";
 	case S_UNKNOWN:
 		return "unknown";
 	case S_OTHER:
@@ -679,6 +697,7 @@ struct symbol *sym_lookup(const char *name, int isconst)
 	memset(symbol, 0, sizeof(*symbol));
 	symbol->name = new_name;
 	symbol->type = S_UNKNOWN;
+	symbol->maturity = M_NONE;
 	if (isconst)
 		symbol->flags |= SYMBOL_CONST;

diff --git a/scripts/kconfig/zconf.gperf b/scripts/kconfig/zconf.gperf
index 9b44c80..756d559 100644
--- a/scripts/kconfig/zconf.gperf
+++ b/scripts/kconfig/zconf.gperf
@@ -25,6 +25,7 @@ endif,		T_ENDIF,	TF_COMMAND
 depends,	T_DEPENDS,	TF_COMMAND
 requires,	T_REQUIRES,	TF_COMMAND
 optional,	T_OPTIONAL,	TF_COMMAND
+maturity,	T_MATURITY,	TF_COMMAND
 default,	T_DEFAULT,	TF_COMMAND, S_UNKNOWN
 prompt,		T_PROMPT,	TF_COMMAND
 tristate,	T_TYPE,		TF_COMMAND, S_TRISTATE
diff --git a/scripts/kconfig/zconf.y b/scripts/kconfig/zconf.y
index 92eb02b..1b47966 100644
--- a/scripts/kconfig/zconf.y
+++ b/scripts/kconfig/zconf.y
@@ -66,6 +66,7 @@ static struct menu *current_menu, *current_entry;
 %token <id>T_DEPENDS
 %token <id>T_REQUIRES
 %token <id>T_OPTIONAL
+%token <id>T_MATURITY
 %token <id>T_PROMPT
 %token <id>T_TYPE
 %token <id>T_DEFAULT
@@ -120,7 +121,7 @@ stmt_list:
 ;

 option_name:
-	T_DEPENDS | T_PROMPT | T_TYPE | T_SELECT | T_OPTIONAL | T_RANGE |
T_DEFAULT
+	T_DEPENDS | T_MATURITY | T_PROMPT | T_TYPE | T_SELECT | T_OPTIONAL |
T_RANGE | T_DEFAULT
 ;

 common_stmt:
@@ -177,6 +178,7 @@ config_option_list:
 	| config_option_list config_option
 	| config_option_list symbol_option
 	| config_option_list depends
+	| config_option_list maturity
 	| config_option_list help
 	| config_option_list option_error
 	| config_option_list T_EOL
@@ -269,6 +271,7 @@ choice_option_list:
 	  /* empty */
 	| choice_option_list choice_option
 	| choice_option_list depends
+	| choice_option_list maturity
 	| choice_option_list help
 	| choice_option_list T_EOL
 	| choice_option_list option_error
@@ -349,7 +352,7 @@ menu: T_MENU prompt T_EOL
 	printd(DEBUG_PARSE, "%s:%d:menu\n", zconf_curname(), zconf_lineno());
 };

-menu_entry: menu depends_list
+menu_entry: menu maturity_set_opt depends_list
 {
 	$$ = menu_add_menu();
 };
@@ -430,6 +433,19 @@ depends: T_DEPENDS T_ON expr T_EOL
 	printd(DEBUG_PARSE, "%s:%d:requires\n", zconf_curname(), zconf_lineno());
 };

+/* maturity setting */
+
+maturity_set_opt:
+	  /* empty */
+	| maturity
+;
+
+maturity: T_MATURITY symbol T_EOL
+{
+	menu_set_maturity($2);
+	printd(DEBUG_PARSE, "%s:%d:maturity\n", zconf_curname(), zconf_lineno());
+};
+
 /* prompt statement */

 prompt_stmt_opt:
@@ -519,6 +535,7 @@ const char *zconf_tokenname(int token)
 	case T_IF:		return "if";
 	case T_ENDIF:		return "endif";
 	case T_DEPENDS:		return "depends";
+	case T_MATURITY:	return "maturity";
 	}
 	return "<token>";
 }
@@ -615,6 +632,9 @@ void print_symbol(FILE *out, struct menu *menu)
 	case S_HEX:
 		fputs("  hex\n", out);
 		break;
+	case S_MATURITY:
+		fputs("  maturity\n", out);
+		break;
 	default:
 		fputs("  ???\n", out);
 		break;


-- 
Simon Arlott
