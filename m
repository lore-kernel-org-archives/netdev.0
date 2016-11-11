From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH v4 1/6] kconfig: introduce the "imply" keyword
Date: Fri, 11 Nov 2016 00:10:05 -0500
Message-ID: <1478841010-28605-2-git-send-email-nicolas.pitre@linaro.org>
References: <1478841010-28605-1-git-send-email-nicolas.pitre@linaro.org>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Paul Bolle <pebolle@tiscali.nl>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: John Stultz <john.stultz@linaro.org>,
        Michal Marek <mmarek@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alt22.smtp-out.videotron.ca ([70.80.0.73]:2123 "EHLO
        alt22.smtp-out.videotron.ca" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751396AbcKKFKc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 00:10:32 -0500
In-Reply-To: <1478841010-28605-1-git-send-email-nicolas.pitre@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "imply" keyword is a weak version of "select" where the target
config symbol can still be turned off, avoiding those pitfalls that come
with the "select" keyword.

This is useful e.g. with multiple drivers that want to indicate their
ability to hook into a secondary subsystem while allowing the user to
configure that subsystem out without also having to unset these drivers.

Currently, the same effect can almost be achieved with:

config DRIVER_A
	tristate

config DRIVER_B
	tristate

config DRIVER_C
	tristate

config DRIVER_D
	tristate

[...]

config SUBSYSTEM_X
	tristate
	default DRIVER_A || DRIVER_B || DRIVER_C || DRIVER_D || [...]

This is unwieldy to maintain especially with a large number of drivers.
Furthermore, there is no easy way to restrict the choice for SUBSYSTEM_X
to y or n, excluding m, when some drivers are built-in. The "select"
keyword allows for excluding m, but it excludes n as well. Hence
this "imply" keyword.  The above becomes:

config DRIVER_A
	tristate
	imply SUBSYSTEM_X

config DRIVER_B
	tristate
	imply SUBSYSTEM_X

[...]

config SUBSYSTEM_X
	tristate

This is much cleaner, and way more flexible than "select". SUBSYSTEM_X
can still be configured out, and it can be set as a module when none of
the drivers are configured in or all of them are modular.

Signed-off-by: Nicolas Pitre <nico@linaro.org>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
Acked-by: Richard Cochran <richardcochran@gmail.com>
Acked-by: Thomas Gleixner <tglx@linutronix.de>
---
 Documentation/kbuild/kconfig-language.txt | 29 ++++++++++++++++
 scripts/kconfig/expr.h                    |  2 ++
 scripts/kconfig/menu.c                    | 55 ++++++++++++++++++++++---------
 scripts/kconfig/symbol.c                  | 24 +++++++++++++-
 scripts/kconfig/zconf.gperf               |  1 +
 scripts/kconfig/zconf.y                   | 16 +++++++--
 6 files changed, 108 insertions(+), 19 deletions(-)

diff --git a/Documentation/kbuild/kconfig-language.txt b/Documentation/kbuild/kconfig-language.txt
index 069fcb3eef..262722d886 100644
--- a/Documentation/kbuild/kconfig-language.txt
+++ b/Documentation/kbuild/kconfig-language.txt
@@ -113,6 +113,34 @@ applicable everywhere (see syntax).
 	That will limit the usefulness but on the other hand avoid
 	the illegal configurations all over.
 
+- weak reverse dependencies: "imply" <symbol> ["if" <expr>]
+  This is similar to "select" as it enforces a lower limit on another
+  symbol except that the "implied" symbol's value may still be set to n
+  from a direct dependency or with a visible prompt.
+
+  Given the following example:
+
+  config FOO
+	tristate
+	imply BAZ
+
+  config BAZ
+	tristate
+	depends on BAR
+
+  The following values are possible:
+
+	FOO		BAR		BAZ's default	choice for BAZ
+	---		---		-------------	--------------
+	n		y		n		N/m/y
+	m		y		m		M/y/n
+	y		y		y		Y/n
+	y		n		*		N
+
+  This is useful e.g. with multiple drivers that want to indicate their
+  ability to hook into a secondary subsystem while allowing the user to
+  configure that subsystem out without also having to unset these drivers.
+
 - limiting menu display: "visible if" <expr>
   This attribute is only applicable to menu blocks, if the condition is
   false, the menu block is not displayed to the user (the symbols
@@ -481,6 +509,7 @@ historical issues resolved through these different solutions.
   b) Match dependency semantics:
 	b1) Swap all "select FOO" to "depends on FOO" or,
 	b2) Swap all "depends on FOO" to "select FOO"
+  c) Consider the use of "imply" instead of "select"
 
 The resolution to a) can be tested with the sample Kconfig file
 Documentation/kbuild/Kconfig.recursion-issue-01 through the removal
diff --git a/scripts/kconfig/expr.h b/scripts/kconfig/expr.h
index 973b6f7333..a73f762c48 100644
--- a/scripts/kconfig/expr.h
+++ b/scripts/kconfig/expr.h
@@ -85,6 +85,7 @@ struct symbol {
 	struct property *prop;
 	struct expr_value dir_dep;
 	struct expr_value rev_dep;
+	struct expr_value implied;
 };
 
 #define for_all_symbols(i, sym) for (i = 0; i < SYMBOL_HASHSIZE; i++) for (sym = symbol_hash[i]; sym; sym = sym->next) if (sym->type != S_OTHER)
@@ -136,6 +137,7 @@ enum prop_type {
 	P_DEFAULT,  /* default y */
 	P_CHOICE,   /* choice value */
 	P_SELECT,   /* select BAR */
+	P_IMPLY,    /* imply BAR */
 	P_RANGE,    /* range 7..100 (for a symbol) */
 	P_ENV,      /* value from environment variable */
 	P_SYMBOL,   /* where a symbol is defined */
diff --git a/scripts/kconfig/menu.c b/scripts/kconfig/menu.c
index aed678e8a7..e9357931b4 100644
--- a/scripts/kconfig/menu.c
+++ b/scripts/kconfig/menu.c
@@ -233,6 +233,8 @@ static void sym_check_prop(struct symbol *sym)
 {
 	struct property *prop;
 	struct symbol *sym2;
+	char *use;
+
 	for (prop = sym->prop; prop; prop = prop->next) {
 		switch (prop->type) {
 		case P_DEFAULT:
@@ -252,18 +254,20 @@ static void sym_check_prop(struct symbol *sym)
 			}
 			break;
 		case P_SELECT:
+		case P_IMPLY:
+			use = prop->type == P_SELECT ? "select" : "imply";
 			sym2 = prop_get_symbol(prop);
 			if (sym->type != S_BOOLEAN && sym->type != S_TRISTATE)
 				prop_warn(prop,
-				    "config symbol '%s' uses select, but is "
-				    "not boolean or tristate", sym->name);
+				    "config symbol '%s' uses %s, but is "
+				    "not boolean or tristate", sym->name, use);
 			else if (sym2->type != S_UNKNOWN &&
 				 sym2->type != S_BOOLEAN &&
 				 sym2->type != S_TRISTATE)
 				prop_warn(prop,
-				    "'%s' has wrong type. 'select' only "
+				    "'%s' has wrong type. '%s' only "
 				    "accept arguments of boolean and "
-				    "tristate type", sym2->name);
+				    "tristate type", sym2->name, use);
 			break;
 		case P_RANGE:
 			if (sym->type != S_INT && sym->type != S_HEX)
@@ -333,6 +337,10 @@ void menu_finalize(struct menu *parent)
 					struct symbol *es = prop_get_symbol(prop);
 					es->rev_dep.expr = expr_alloc_or(es->rev_dep.expr,
 							expr_alloc_and(expr_alloc_symbol(menu->sym), expr_copy(dep)));
+				} else if (prop->type == P_IMPLY) {
+					struct symbol *es = prop_get_symbol(prop);
+					es->implied.expr = expr_alloc_or(es->implied.expr,
+							expr_alloc_and(expr_alloc_symbol(menu->sym), expr_copy(dep)));
 				}
 			}
 		}
@@ -612,13 +620,30 @@ static struct property *get_symbol_prop(struct symbol *sym)
 	return prop;
 }
 
+static void get_symbol_props_str(struct gstr *r, struct symbol *sym,
+				 enum prop_type tok, const char *prefix)
+{
+	bool hit = false;
+	struct property *prop;
+
+	for_all_properties(sym, prop, tok) {
+		if (!hit) {
+			str_append(r, prefix);
+			hit = true;
+		} else
+			str_printf(r, " && ");
+		expr_gstr_print(prop->expr, r);
+	}
+	if (hit)
+		str_append(r, "\n");
+}
+
 /*
  * head is optional and may be NULL
  */
 static void get_symbol_str(struct gstr *r, struct symbol *sym,
 		    struct list_head *head)
 {
-	bool hit;
 	struct property *prop;
 
 	if (sym && sym->name) {
@@ -648,22 +673,20 @@ static void get_symbol_str(struct gstr *r, struct symbol *sym,
 		}
 	}
 
-	hit = false;
-	for_all_properties(sym, prop, P_SELECT) {
-		if (!hit) {
-			str_append(r, "  Selects: ");
-			hit = true;
-		} else
-			str_printf(r, " && ");
-		expr_gstr_print(prop->expr, r);
-	}
-	if (hit)
-		str_append(r, "\n");
+	get_symbol_props_str(r, sym, P_SELECT, _("  Selects: "));
 	if (sym->rev_dep.expr) {
 		str_append(r, _("  Selected by: "));
 		expr_gstr_print(sym->rev_dep.expr, r);
 		str_append(r, "\n");
 	}
+
+	get_symbol_props_str(r, sym, P_IMPLY, _("  Implies: "));
+	if (sym->implied.expr) {
+		str_append(r, _("  Implied by: "));
+		expr_gstr_print(sym->implied.expr, r);
+		str_append(r, "\n");
+	}
+
 	str_append(r, "\n\n");
 }
 
diff --git a/scripts/kconfig/symbol.c b/scripts/kconfig/symbol.c
index 2432298487..20136ffefb 100644
--- a/scripts/kconfig/symbol.c
+++ b/scripts/kconfig/symbol.c
@@ -258,6 +258,15 @@ static void sym_calc_visibility(struct symbol *sym)
 		sym->rev_dep.tri = tri;
 		sym_set_changed(sym);
 	}
+	tri = no;
+	if (sym->implied.expr && sym->dir_dep.tri != no)
+		tri = expr_calc_value(sym->implied.expr);
+	if (tri == mod && sym_get_type(sym) == S_BOOLEAN)
+		tri = yes;
+	if (sym->implied.tri != tri) {
+		sym->implied.tri = tri;
+		sym_set_changed(sym);
+	}
 }
 
 /*
@@ -397,6 +406,10 @@ void sym_calc_value(struct symbol *sym)
 					newval.tri = EXPR_AND(expr_calc_value(prop->expr),
 							      prop->visible.tri);
 				}
+				if (sym->implied.tri != no) {
+					sym->flags |= SYMBOL_WRITE;
+					newval.tri = EXPR_OR(newval.tri, sym->implied.tri);
+				}
 			}
 		calc_newval:
 			if (sym->dir_dep.tri == no && sym->rev_dep.tri != no) {
@@ -413,7 +426,8 @@ void sym_calc_value(struct symbol *sym)
 			}
 			newval.tri = EXPR_OR(newval.tri, sym->rev_dep.tri);
 		}
-		if (newval.tri == mod && sym_get_type(sym) == S_BOOLEAN)
+		if (newval.tri == mod &&
+		    (sym_get_type(sym) == S_BOOLEAN || sym->implied.tri == yes))
 			newval.tri = yes;
 		break;
 	case S_STRING:
@@ -498,6 +512,8 @@ bool sym_tristate_within_range(struct symbol *sym, tristate val)
 		return false;
 	if (sym->visible <= sym->rev_dep.tri)
 		return false;
+	if (sym->implied.tri == yes && val == mod)
+		return false;
 	if (sym_is_choice_value(sym) && sym->visible == yes)
 		return val == yes;
 	return val >= sym->rev_dep.tri && val <= sym->visible;
@@ -750,6 +766,10 @@ const char *sym_get_string_default(struct symbol *sym)
 	if (sym->type == S_BOOLEAN && val == mod)
 		val = yes;
 
+	/* adjust the default value if this symbol is implied by another */
+	if (val < sym->implied.tri)
+		val = sym->implied.tri;
+
 	switch (sym->type) {
 	case S_BOOLEAN:
 	case S_TRISTATE:
@@ -1352,6 +1372,8 @@ const char *prop_get_type_name(enum prop_type type)
 		return "choice";
 	case P_SELECT:
 		return "select";
+	case P_IMPLY:
+		return "imply";
 	case P_RANGE:
 		return "range";
 	case P_SYMBOL:
diff --git a/scripts/kconfig/zconf.gperf b/scripts/kconfig/zconf.gperf
index ac498f01b4..ead02edec9 100644
--- a/scripts/kconfig/zconf.gperf
+++ b/scripts/kconfig/zconf.gperf
@@ -38,6 +38,7 @@ int,		T_TYPE,		TF_COMMAND, S_INT
 hex,		T_TYPE,		TF_COMMAND, S_HEX
 string,		T_TYPE,		TF_COMMAND, S_STRING
 select,		T_SELECT,	TF_COMMAND
+imply,		T_IMPLY,	TF_COMMAND
 range,		T_RANGE,	TF_COMMAND
 visible,	T_VISIBLE,	TF_COMMAND
 option,		T_OPTION,	TF_COMMAND
diff --git a/scripts/kconfig/zconf.y b/scripts/kconfig/zconf.y
index 71bf8bff69..001305fa08 100644
--- a/scripts/kconfig/zconf.y
+++ b/scripts/kconfig/zconf.y
@@ -31,7 +31,7 @@ struct symbol *symbol_hash[SYMBOL_HASHSIZE];
 static struct menu *current_menu, *current_entry;
 
 %}
-%expect 30
+%expect 32
 
 %union
 {
@@ -62,6 +62,7 @@ static struct menu *current_menu, *current_entry;
 %token <id>T_TYPE
 %token <id>T_DEFAULT
 %token <id>T_SELECT
+%token <id>T_IMPLY
 %token <id>T_RANGE
 %token <id>T_VISIBLE
 %token <id>T_OPTION
@@ -124,7 +125,7 @@ stmt_list:
 ;
 
 option_name:
-	T_DEPENDS | T_PROMPT | T_TYPE | T_SELECT | T_OPTIONAL | T_RANGE | T_DEFAULT | T_VISIBLE
+	T_DEPENDS | T_PROMPT | T_TYPE | T_SELECT | T_IMPLY | T_OPTIONAL | T_RANGE | T_DEFAULT | T_VISIBLE
 ;
 
 common_stmt:
@@ -216,6 +217,12 @@ config_option: T_SELECT T_WORD if_expr T_EOL
 	printd(DEBUG_PARSE, "%s:%d:select\n", zconf_curname(), zconf_lineno());
 };
 
+config_option: T_IMPLY T_WORD if_expr T_EOL
+{
+	menu_add_symbol(P_IMPLY, sym_lookup($2, 0), $3);
+	printd(DEBUG_PARSE, "%s:%d:imply\n", zconf_curname(), zconf_lineno());
+};
+
 config_option: T_RANGE symbol symbol if_expr T_EOL
 {
 	menu_add_expr(P_RANGE, expr_alloc_comp(E_RANGE,$2, $3), $4);
@@ -664,6 +671,11 @@ static void print_symbol(FILE *out, struct menu *menu)
 			expr_fprint(prop->expr, out);
 			fputc('\n', out);
 			break;
+		case P_IMPLY:
+			fputs( "  imply ", out);
+			expr_fprint(prop->expr, out);
+			fputc('\n', out);
+			break;
 		case P_RANGE:
 			fputs( "  range ", out);
 			expr_fprint(prop->expr, out);
-- 
2.7.4
