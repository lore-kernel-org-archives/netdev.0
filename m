From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH v2 2/5] kconfig: introduce the "suggest" keyword
Date: Tue, 25 Oct 2016 22:28:48 -0400
Message-ID: <1477448931-29051-3-git-send-email-nicolas.pitre@linaro.org>
References: <1477448931-29051-1-git-send-email-nicolas.pitre@linaro.org>
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: John Stultz <john.stultz@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        "Yann E. MORIN" <yann.morin.1998@free.fr>,
        Michal Marek <mmarek@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477448931-29051-1-git-send-email-nicolas.pitre@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Similar to "imply" but with no added restrictions on the target symbol's
value. Useful for providing a default value to another symbol.

Suggested by Edward Cree.

Signed-off-by: Nicolas Pitre <nico@linaro.org>
---
 Documentation/kbuild/kconfig-language.txt |  6 ++++++
 scripts/kconfig/expr.h                    |  2 ++
 scripts/kconfig/menu.c                    | 15 ++++++++++++++-
 scripts/kconfig/symbol.c                  | 20 +++++++++++++++++++-
 scripts/kconfig/zconf.gperf               |  1 +
 scripts/kconfig/zconf.y                   | 16 ++++++++++++++--
 6 files changed, 56 insertions(+), 4 deletions(-)

diff --git a/Documentation/kbuild/kconfig-language.txt b/Documentation/kbuild/kconfig-language.txt
index 5ee0dd3c85..b7f4f0ca1d 100644
--- a/Documentation/kbuild/kconfig-language.txt
+++ b/Documentation/kbuild/kconfig-language.txt
@@ -140,6 +140,12 @@ applicable everywhere (see syntax).
   ability to hook into a given subsystem while still being able to
   configure that subsystem out and keep those drivers selected.
 
+- even weaker reverse dependencies: "suggest" <symbol> ["if" <expr>]
+  This is similar to "imply" except that this doesn't add any restrictions
+  on the value the suggested symbol may use. In other words this only
+  provides a default for the specified symbol based on the value for the
+  config entry where this is used.
+
 - limiting menu display: "visible if" <expr>
   This attribute is only applicable to menu blocks, if the condition is
   false, the menu block is not displayed to the user (the symbols
diff --git a/scripts/kconfig/expr.h b/scripts/kconfig/expr.h
index a73f762c48..eea3aa3c7a 100644
--- a/scripts/kconfig/expr.h
+++ b/scripts/kconfig/expr.h
@@ -86,6 +86,7 @@ struct symbol {
 	struct expr_value dir_dep;
 	struct expr_value rev_dep;
 	struct expr_value implied;
+	struct expr_value suggested;
 };
 
 #define for_all_symbols(i, sym) for (i = 0; i < SYMBOL_HASHSIZE; i++) for (sym = symbol_hash[i]; sym; sym = sym->next) if (sym->type != S_OTHER)
@@ -138,6 +139,7 @@ enum prop_type {
 	P_CHOICE,   /* choice value */
 	P_SELECT,   /* select BAR */
 	P_IMPLY,    /* imply BAR */
+	P_SUGGEST,  /* suggest BAR */
 	P_RANGE,    /* range 7..100 (for a symbol) */
 	P_ENV,      /* value from environment variable */
 	P_SYMBOL,   /* where a symbol is defined */
diff --git a/scripts/kconfig/menu.c b/scripts/kconfig/menu.c
index e9357931b4..3abc5c85ac 100644
--- a/scripts/kconfig/menu.c
+++ b/scripts/kconfig/menu.c
@@ -255,7 +255,9 @@ static void sym_check_prop(struct symbol *sym)
 			break;
 		case P_SELECT:
 		case P_IMPLY:
-			use = prop->type == P_SELECT ? "select" : "imply";
+		case P_SUGGEST:
+			use = prop->type == P_SELECT ? "select" :
+			      prop->type == P_IMPLY ? "imply" : "suggest";
 			sym2 = prop_get_symbol(prop);
 			if (sym->type != S_BOOLEAN && sym->type != S_TRISTATE)
 				prop_warn(prop,
@@ -341,6 +343,10 @@ void menu_finalize(struct menu *parent)
 					struct symbol *es = prop_get_symbol(prop);
 					es->implied.expr = expr_alloc_or(es->implied.expr,
 							expr_alloc_and(expr_alloc_symbol(menu->sym), expr_copy(dep)));
+				} else if (prop->type == P_SUGGEST) {
+					struct symbol *es = prop_get_symbol(prop);
+					es->suggested.expr = expr_alloc_or(es->suggested.expr,
+							expr_alloc_and(expr_alloc_symbol(menu->sym), expr_copy(dep)));
 				}
 			}
 		}
@@ -687,6 +693,13 @@ static void get_symbol_str(struct gstr *r, struct symbol *sym,
 		str_append(r, "\n");
 	}
 
+	get_symbol_props_str(r, sym, P_SUGGEST, _("  Suggests: "));
+	if (sym->suggested.expr) {
+		str_append(r, _("  Suggested by: "));
+		expr_gstr_print(sym->suggested.expr, r);
+		str_append(r, "\n");
+	}
+
 	str_append(r, "\n\n");
 }
 
diff --git a/scripts/kconfig/symbol.c b/scripts/kconfig/symbol.c
index 20136ffefb..4a8094a63c 100644
--- a/scripts/kconfig/symbol.c
+++ b/scripts/kconfig/symbol.c
@@ -267,6 +267,16 @@ static void sym_calc_visibility(struct symbol *sym)
 		sym->implied.tri = tri;
 		sym_set_changed(sym);
 	}
+	tri = no;
+	if (sym->suggested.expr)
+		tri = expr_calc_value(sym->suggested.expr);
+	tri = EXPR_AND(tri, sym->visible);
+	if (tri == mod && sym_get_type(sym) == S_BOOLEAN)
+		tri = yes;
+	if (sym->suggested.tri != tri) {
+		sym->suggested.tri = tri;
+		sym_set_changed(sym);
+	}
 }
 
 /*
@@ -406,6 +416,10 @@ void sym_calc_value(struct symbol *sym)
 					newval.tri = EXPR_AND(expr_calc_value(prop->expr),
 							      prop->visible.tri);
 				}
+				if (sym->suggested.tri != no) {
+					sym->flags |= SYMBOL_WRITE;
+					newval.tri = EXPR_OR(newval.tri, sym->suggested.tri);
+				}
 				if (sym->implied.tri != no) {
 					sym->flags |= SYMBOL_WRITE;
 					newval.tri = EXPR_OR(newval.tri, sym->implied.tri);
@@ -766,7 +780,9 @@ const char *sym_get_string_default(struct symbol *sym)
 	if (sym->type == S_BOOLEAN && val == mod)
 		val = yes;
 
-	/* adjust the default value if this symbol is implied by another */
+	/* adjust the default value if this symbol is suggested/implied */
+	if (val < sym->suggested.tri)
+		val = sym->suggested.tri;
 	if (val < sym->implied.tri)
 		val = sym->implied.tri;
 
@@ -1374,6 +1390,8 @@ const char *prop_get_type_name(enum prop_type type)
 		return "select";
 	case P_IMPLY:
 		return "imply";
+	case P_SUGGEST:
+		return "suggest";
 	case P_RANGE:
 		return "range";
 	case P_SYMBOL:
diff --git a/scripts/kconfig/zconf.gperf b/scripts/kconfig/zconf.gperf
index ead02edec9..0c244a8e95 100644
--- a/scripts/kconfig/zconf.gperf
+++ b/scripts/kconfig/zconf.gperf
@@ -39,6 +39,7 @@ hex,		T_TYPE,		TF_COMMAND, S_HEX
 string,		T_TYPE,		TF_COMMAND, S_STRING
 select,		T_SELECT,	TF_COMMAND
 imply,		T_IMPLY,	TF_COMMAND
+suggest,	T_SUGGEST,	TF_COMMAND
 range,		T_RANGE,	TF_COMMAND
 visible,	T_VISIBLE,	TF_COMMAND
 option,		T_OPTION,	TF_COMMAND
diff --git a/scripts/kconfig/zconf.y b/scripts/kconfig/zconf.y
index 001305fa08..277415540a 100644
--- a/scripts/kconfig/zconf.y
+++ b/scripts/kconfig/zconf.y
@@ -31,7 +31,7 @@ struct symbol *symbol_hash[SYMBOL_HASHSIZE];
 static struct menu *current_menu, *current_entry;
 
 %}
-%expect 32
+%expect 34
 
 %union
 {
@@ -63,6 +63,7 @@ static struct menu *current_menu, *current_entry;
 %token <id>T_DEFAULT
 %token <id>T_SELECT
 %token <id>T_IMPLY
+%token <id>T_SUGGEST
 %token <id>T_RANGE
 %token <id>T_VISIBLE
 %token <id>T_OPTION
@@ -125,7 +126,7 @@ stmt_list:
 ;
 
 option_name:
-	T_DEPENDS | T_PROMPT | T_TYPE | T_SELECT | T_IMPLY | T_OPTIONAL | T_RANGE | T_DEFAULT | T_VISIBLE
+	T_DEPENDS | T_PROMPT | T_TYPE | T_SELECT | T_IMPLY | T_SUGGEST | T_OPTIONAL | T_RANGE | T_DEFAULT | T_VISIBLE
 ;
 
 common_stmt:
@@ -223,6 +224,12 @@ config_option: T_IMPLY T_WORD if_expr T_EOL
 	printd(DEBUG_PARSE, "%s:%d:imply\n", zconf_curname(), zconf_lineno());
 };
 
+config_option: T_SUGGEST T_WORD if_expr T_EOL
+{
+	menu_add_symbol(P_SUGGEST, sym_lookup($2, 0), $3);
+	printd(DEBUG_PARSE, "%s:%d:suggest\n", zconf_curname(), zconf_lineno());
+};
+
 config_option: T_RANGE symbol symbol if_expr T_EOL
 {
 	menu_add_expr(P_RANGE, expr_alloc_comp(E_RANGE,$2, $3), $4);
@@ -676,6 +683,11 @@ static void print_symbol(FILE *out, struct menu *menu)
 			expr_fprint(prop->expr, out);
 			fputc('\n', out);
 			break;
+		case P_SUGGEST:
+			fputs( "  suggest ", out);
+			expr_fprint(prop->expr, out);
+			fputc('\n', out);
+			break;
 		case P_RANGE:
 			fputs( "  range ", out);
 			expr_fprint(prop->expr, out);
-- 
2.7.4
