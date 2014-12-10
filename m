From: Joe Perches <joe@perches.com>
Subject: [PATCH] irda: Convert function pointer arrays and uses to const
Date: Wed, 10 Dec 2014 10:28:58 -0800
Message-ID: <1418236138.18092.13.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Making things const is a good thing.

(x86-64 defconfig with all irda)
$ size net/irda/built-in.o*
   text	   data	    bss	    dec	    hex	filename
 109276	   1868	    244	 111388	  1b31c	net/irda/built-in.o.new
 108828	   2316	    244	 111388	  1b31c	net/irda/built-in.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/irda/parameters.h  | 6 +++---
 net/irda/ircomm/ircomm_param.c | 8 ++++----
 net/irda/irttp.c               | 6 ++++--
 net/irda/parameters.c          | 8 ++++----
 net/irda/qos.c                 | 6 +++---
 5 files changed, 18 insertions(+), 16 deletions(-)

diff --git a/include/net/irda/parameters.h b/include/net/irda/parameters.h
index 42713c9..2d9cd00 100644
--- a/include/net/irda/parameters.h
+++ b/include/net/irda/parameters.h
@@ -71,17 +71,17 @@ typedef int (*PV_HANDLER)(void *self, __u8 *buf, int len, __u8 pi,
 			  PV_TYPE type, PI_HANDLER func);
 
 typedef struct {
-	PI_HANDLER func;  /* Handler for this parameter identifier */
+	const PI_HANDLER func;  /* Handler for this parameter identifier */
 	PV_TYPE    type;  /* Data type for this parameter */
 } pi_minor_info_t;
 
 typedef struct {
-	pi_minor_info_t *pi_minor_call_table;
+	const pi_minor_info_t *pi_minor_call_table;
 	int len;
 } pi_major_info_t;
 
 typedef struct {
-	pi_major_info_t *tables;
+	const pi_major_info_t *tables;
 	int              len;
 	__u8             pi_mask;
 	int              pi_major_offset;
diff --git a/net/irda/ircomm/ircomm_param.c b/net/irda/ircomm/ircomm_param.c
index 27be782..3c4caa6 100644
--- a/net/irda/ircomm/ircomm_param.c
+++ b/net/irda/ircomm/ircomm_param.c
@@ -61,12 +61,12 @@ static int ircomm_param_dte(void *instance, irda_param_t *param, int get);
 static int ircomm_param_dce(void *instance, irda_param_t *param, int get);
 static int ircomm_param_poll(void *instance, irda_param_t *param, int get);
 
-static pi_minor_info_t pi_minor_call_table_common[] = {
+static const pi_minor_info_t pi_minor_call_table_common[] = {
 	{ ircomm_param_service_type, PV_INT_8_BITS },
 	{ ircomm_param_port_type,    PV_INT_8_BITS },
 	{ ircomm_param_port_name,    PV_STRING }
 };
-static pi_minor_info_t pi_minor_call_table_non_raw[] = {
+static const pi_minor_info_t pi_minor_call_table_non_raw[] = {
 	{ ircomm_param_data_rate,    PV_INT_32_BITS | PV_BIG_ENDIAN },
 	{ ircomm_param_data_format,  PV_INT_8_BITS },
 	{ ircomm_param_flow_control, PV_INT_8_BITS },
@@ -74,13 +74,13 @@ static pi_minor_info_t pi_minor_call_table_non_raw[] = {
 	{ ircomm_param_enq_ack,      PV_INT_16_BITS },
 	{ ircomm_param_line_status,  PV_INT_8_BITS }
 };
-static pi_minor_info_t pi_minor_call_table_9_wire[] = {
+static const pi_minor_info_t pi_minor_call_table_9_wire[] = {
 	{ ircomm_param_dte,          PV_INT_8_BITS },
 	{ ircomm_param_dce,          PV_INT_8_BITS },
 	{ ircomm_param_poll,         PV_NO_VALUE },
 };
 
-static pi_major_info_t pi_major_call_table[] = {
+static const pi_major_info_t pi_major_call_table[] = {
 	{ pi_minor_call_table_common,  3 },
 	{ pi_minor_call_table_non_raw, 6 },
 	{ pi_minor_call_table_9_wire,  3 }
diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index 3ef0b08..b6ab41d 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -71,11 +71,13 @@ static void irttp_status_indication(void *instance,
 				    LINK_STATUS link, LOCK_STATUS lock);
 
 /* Information for parsing parameters in IrTTP */
-static pi_minor_info_t pi_minor_call_table[] = {
+static const pi_minor_info_t pi_minor_call_table[] = {
 	{ NULL, 0 },                                             /* 0x00 */
 	{ irttp_param_max_sdu_size, PV_INTEGER | PV_BIG_ENDIAN } /* 0x01 */
 };
-static pi_major_info_t pi_major_call_table[] = { { pi_minor_call_table, 2 } };
+static const pi_major_info_t pi_major_call_table[] = {
+	{ pi_minor_call_table, 2 }
+};
 static pi_param_info_t param_info = { pi_major_call_table, 1, 0x0f, 4 };
 
 /************************ GLOBAL PROCEDURES ************************/
diff --git a/net/irda/parameters.c b/net/irda/parameters.c
index 006786b..16ce32f 100644
--- a/net/irda/parameters.c
+++ b/net/irda/parameters.c
@@ -52,7 +52,7 @@ static int irda_insert_no_value(void *self, __u8 *buf, int len, __u8 pi,
 static int irda_param_unpack(__u8 *buf, char *fmt, ...);
 
 /* Parameter value call table. Must match PV_TYPE */
-static PV_HANDLER pv_extract_table[] = {
+static const PV_HANDLER pv_extract_table[] = {
 	irda_extract_integer, /* Handler for any length integers */
 	irda_extract_integer, /* Handler for 8  bits integers */
 	irda_extract_integer, /* Handler for 16 bits integers */
@@ -62,7 +62,7 @@ static PV_HANDLER pv_extract_table[] = {
 	irda_extract_no_value /* Handler for no value parameters */
 };
 
-static PV_HANDLER pv_insert_table[] = {
+static const PV_HANDLER pv_insert_table[] = {
 	irda_insert_integer, /* Handler for any length integers */
 	irda_insert_integer, /* Handler for 8  bits integers */
 	irda_insert_integer, /* Handler for 16 bits integers */
@@ -449,7 +449,7 @@ static int irda_param_unpack(__u8 *buf, char *fmt, ...)
 int irda_param_insert(void *self, __u8 pi, __u8 *buf, int len,
 		      pi_param_info_t *info)
 {
-	pi_minor_info_t *pi_minor_info;
+	const pi_minor_info_t *pi_minor_info;
 	__u8 pi_minor;
 	__u8 pi_major;
 	int type;
@@ -504,7 +504,7 @@ EXPORT_SYMBOL(irda_param_insert);
 static int irda_param_extract(void *self, __u8 *buf, int len,
 			      pi_param_info_t *info)
 {
-	pi_minor_info_t *pi_minor_info;
+	const pi_minor_info_t *pi_minor_info;
 	__u8 pi_minor;
 	__u8 pi_major;
 	int type;
diff --git a/net/irda/qos.c b/net/irda/qos.c
index 5ed6c9a..25ba850 100644
--- a/net/irda/qos.c
+++ b/net/irda/qos.c
@@ -122,7 +122,7 @@ static __u32 max_line_capacities[10][4] = {
 	{ 800000, 400000, 160000, 80000 }, /* 16000000 bps */
 };
 
-static pi_minor_info_t pi_minor_call_table_type_0[] = {
+static const pi_minor_info_t pi_minor_call_table_type_0[] = {
 	{ NULL, 0 },
 /* 01 */{ irlap_param_baud_rate,       PV_INTEGER | PV_LITTLE_ENDIAN },
 	{ NULL, 0 },
@@ -134,7 +134,7 @@ static pi_minor_info_t pi_minor_call_table_type_0[] = {
 /* 08 */{ irlap_param_link_disconnect, PV_INT_8_BITS }
 };
 
-static pi_minor_info_t pi_minor_call_table_type_1[] = {
+static const pi_minor_info_t pi_minor_call_table_type_1[] = {
 	{ NULL, 0 },
 	{ NULL, 0 },
 /* 82 */{ irlap_param_max_turn_time,   PV_INT_8_BITS },
@@ -144,7 +144,7 @@ static pi_minor_info_t pi_minor_call_table_type_1[] = {
 /* 86 */{ irlap_param_min_turn_time,   PV_INT_8_BITS },
 };
 
-static pi_major_info_t pi_major_call_table[] = {
+static const pi_major_info_t pi_major_call_table[] = {
 	{ pi_minor_call_table_type_0, 9 },
 	{ pi_minor_call_table_type_1, 7 },
 };
