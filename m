From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/3] lib, traceevent: add PRINT_HEX_STR variant
Date: Wed, 25 Jan 2017 02:28:17 +0100
Message-ID: <001d3f29ee504ab386a6e0b65e885b39cf3d426f.1485306168.git.daniel@iogearbox.net>
References: <cover.1485306168.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>,
        Steven Rostedt <rostedt@goodmis.org>,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1485306168.git.daniel@iogearbox.net>
In-Reply-To: <cover.1485306168.git.daniel@iogearbox.net>
References: <cover.1485306168.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for the __print_hex_str() macro that was added for
tracing, so that user space tools such as perf can understand
it as well.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 tools/lib/traceevent/event-parse.c                 | 34 ++++++++++++++++++++--
 tools/lib/traceevent/event-parse.h                 |  1 +
 .../perf/util/scripting-engines/trace-event-perl.c |  1 +
 .../util/scripting-engines/trace-event-python.c    |  1 +
 4 files changed, 34 insertions(+), 3 deletions(-)

diff --git a/tools/lib/traceevent/event-parse.c b/tools/lib/traceevent/event-parse.c
index 14a4f62..f2ea780 100644
--- a/tools/lib/traceevent/event-parse.c
+++ b/tools/lib/traceevent/event-parse.c
@@ -831,6 +831,7 @@ static void free_arg(struct print_arg *arg)
 		free_flag_sym(arg->symbol.symbols);
 		break;
 	case PRINT_HEX:
+	case PRINT_HEX_STR:
 		free_arg(arg->hex.field);
 		free_arg(arg->hex.size);
 		break;
@@ -2629,10 +2630,11 @@ static char *arg_eval (struct print_arg *arg)
 }
 
 static enum event_type
-process_hex(struct event_format *event, struct print_arg *arg, char **tok)
+process_hex_common(struct event_format *event, struct print_arg *arg,
+		   char **tok, enum print_arg_type type)
 {
 	memset(arg, 0, sizeof(*arg));
-	arg->type = PRINT_HEX;
+	arg->type = type;
 
 	if (alloc_and_process_delim(event, ",", &arg->hex.field))
 		goto out;
@@ -2651,6 +2653,19 @@ static char *arg_eval (struct print_arg *arg)
 }
 
 static enum event_type
+process_hex(struct event_format *event, struct print_arg *arg, char **tok)
+{
+	return process_hex_common(event, arg, tok, PRINT_HEX);
+}
+
+static enum event_type
+process_hex_str(struct event_format *event, struct print_arg *arg,
+		char **tok)
+{
+	return process_hex_common(event, arg, tok, PRINT_HEX_STR);
+}
+
+static enum event_type
 process_int_array(struct event_format *event, struct print_arg *arg, char **tok)
 {
 	memset(arg, 0, sizeof(*arg));
@@ -3009,6 +3024,10 @@ static void remove_func_handler(struct pevent *pevent, char *func_name)
 		free_token(token);
 		return process_hex(event, arg, tok);
 	}
+	if (strcmp(token, "__print_hex_str") == 0) {
+		free_token(token);
+		return process_hex_str(event, arg, tok);
+	}
 	if (strcmp(token, "__print_array") == 0) {
 		free_token(token);
 		return process_int_array(event, arg, tok);
@@ -3547,6 +3566,7 @@ struct event_format *
 	case PRINT_SYMBOL:
 	case PRINT_INT_ARRAY:
 	case PRINT_HEX:
+	case PRINT_HEX_STR:
 		break;
 	case PRINT_TYPE:
 		val = eval_num_arg(data, size, event, arg->typecast.item);
@@ -3962,6 +3982,7 @@ static void print_str_arg(struct trace_seq *s, void *data, int size,
 		}
 		break;
 	case PRINT_HEX:
+	case PRINT_HEX_STR:
 		if (arg->hex.field->type == PRINT_DYNAMIC_ARRAY) {
 			unsigned long offset;
 			offset = pevent_read_number(pevent,
@@ -3981,7 +4002,7 @@ static void print_str_arg(struct trace_seq *s, void *data, int size,
 		}
 		len = eval_num_arg(data, size, event, arg->hex.size);
 		for (i = 0; i < len; i++) {
-			if (i)
+			if (i && arg->type == PRINT_HEX)
 				trace_seq_putc(s, ' ');
 			trace_seq_printf(s, "%02x", hex[i]);
 		}
@@ -5727,6 +5748,13 @@ static void print_args(struct print_arg *args)
 		print_args(args->hex.size);
 		printf(")");
 		break;
+	case PRINT_HEX_STR:
+		printf("__print_hex_str(");
+		print_args(args->hex.field);
+		printf(", ");
+		print_args(args->hex.size);
+		printf(")");
+		break;
 	case PRINT_INT_ARRAY:
 		printf("__print_array(");
 		print_args(args->int_array.field);
diff --git a/tools/lib/traceevent/event-parse.h b/tools/lib/traceevent/event-parse.h
index 7aae746..74cecba 100644
--- a/tools/lib/traceevent/event-parse.h
+++ b/tools/lib/traceevent/event-parse.h
@@ -292,6 +292,7 @@ enum print_arg_type {
 	PRINT_FUNC,
 	PRINT_BITMASK,
 	PRINT_DYNAMIC_ARRAY_LEN,
+	PRINT_HEX_STR,
 };
 
 struct print_arg {
diff --git a/tools/perf/util/scripting-engines/trace-event-perl.c b/tools/perf/util/scripting-engines/trace-event-perl.c
index e55a132..e74adfb 100644
--- a/tools/perf/util/scripting-engines/trace-event-perl.c
+++ b/tools/perf/util/scripting-engines/trace-event-perl.c
@@ -217,6 +217,7 @@ static void define_event_symbols(struct event_format *event,
 				       cur_field_name);
 		break;
 	case PRINT_HEX:
+	case PRINT_HEX_STR:
 		define_event_symbols(event, ev_name, args->hex.field);
 		define_event_symbols(event, ev_name, args->hex.size);
 		break;
diff --git a/tools/perf/util/scripting-engines/trace-event-python.c b/tools/perf/util/scripting-engines/trace-event-python.c
index 089438d..581e0ef 100644
--- a/tools/perf/util/scripting-engines/trace-event-python.c
+++ b/tools/perf/util/scripting-engines/trace-event-python.c
@@ -236,6 +236,7 @@ static void define_event_symbols(struct event_format *event,
 			      cur_field_name);
 		break;
 	case PRINT_HEX:
+	case PRINT_HEX_STR:
 		define_event_symbols(event, ev_name, args->hex.field);
 		define_event_symbols(event, ev_name, args->hex.size);
 		break;
-- 
1.9.3
