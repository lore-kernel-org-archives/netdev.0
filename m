From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers/acpi/acpica/utmisc.c: Use printk
 extension %pV
Date: Mon, 19 Jul 2010 22:06:07 -0700
Message-ID: <1279602367.19374.20.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Len Brown <lenb@kernel.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Consolidates the printk messages to a single
call so the messages can not be interleaved.

Reduces text a bit.

$ size drivers/acpi/acpica/utmisc.o.*
   text	   data	    bss	    dec	    hex	filename
   7822	     56	   1832	   9710	   25ee	drivers/acpi/acpica/utmisc.o.old
   7748	     56	   1736	   9540	   2544	drivers/acpi/acpica/utmisc.o.new

Depends on net-next commit 7db6f5fb65a82af03229eef104dc9899c5eecf33
(vsprintf: Recursive vsnprintf: Add "%pV", struct va_format)

Compile tested only

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/acpi/acpica/utmisc.c |   78 ++++++++++++++++++++++++++++--------------
 1 files changed, 52 insertions(+), 26 deletions(-)

diff --git a/drivers/acpi/acpica/utmisc.c b/drivers/acpi/acpica/utmisc.c
index e8d0724..d9a4a64 100644
--- a/drivers/acpi/acpica/utmisc.c
+++ b/drivers/acpi/acpica/utmisc.c
@@ -53,8 +53,8 @@ ACPI_MODULE_NAME("utmisc")
 /*
  * Common suffix for messages
  */
-#define ACPI_COMMON_MSG_SUFFIX \
-	acpi_os_printf(" (%8.8X/%s-%u)\n", ACPI_CA_VERSION, module_name, line_number)
+#define ACPI_COMMON_MSG_SUFFIX_FMT  " (%8.8X/%s-%u)"
+#define ACPI_COMMON_MSG_SUFFIX_ARGS ACPI_CA_VERSION, module_name, line_number
 /*******************************************************************************
  *
  * FUNCTION:    acpi_ut_validate_exception
@@ -1063,12 +1063,16 @@ void ACPI_INTERNAL_VAR_XFACE
 acpi_error(const char *module_name, u32 line_number, const char *format, ...)
 {
 	va_list args;
-
-	acpi_os_printf("ACPI Error: ");
+	struct va_format vaf;
 
 	va_start(args, format);
-	acpi_os_vprintf(format, args);
-	ACPI_COMMON_MSG_SUFFIX;
+
+	vaf.fmt = format;
+	vaf.va = &args;
+
+	acpi_os_printf("ACPI Error: %pV" ACPI_COMMON_MSG_SUFFIX_FMT "\n",
+		       &vaf, ACPI_COMMON_MSG_SUFFIX_ARGS);
+
 	va_end(args);
 }
 
@@ -1077,12 +1081,18 @@ acpi_exception(const char *module_name,
 	       u32 line_number, acpi_status status, const char *format, ...)
 {
 	va_list args;
-
-	acpi_os_printf("ACPI Exception: %s, ", acpi_format_exception(status));
+	struct va_format vaf;
 
 	va_start(args, format);
-	acpi_os_vprintf(format, args);
-	ACPI_COMMON_MSG_SUFFIX;
+
+	vaf.fmt = format;
+	vaf.va = &args;
+
+	acpi_os_printf("ACPI Exception: %s, %pV"
+		       ACPI_COMMON_MSG_SUFFIX_FMT "\n",
+		       acpi_format_exception(status), &vaf,
+		       ACPI_COMMON_MSG_SUFFIX_ARGS);
+
 	va_end(args);
 }
 
@@ -1090,12 +1100,16 @@ void ACPI_INTERNAL_VAR_XFACE
 acpi_warning(const char *module_name, u32 line_number, const char *format, ...)
 {
 	va_list args;
-
-	acpi_os_printf("ACPI Warning: ");
+	struct va_format vaf;
 
 	va_start(args, format);
-	acpi_os_vprintf(format, args);
-	ACPI_COMMON_MSG_SUFFIX;
+
+	vaf.fmt = format;
+	vaf.va = &args;
+
+	acpi_os_printf("ACPI Warning: %pV" ACPI_COMMON_MSG_SUFFIX_FMT "\n",
+		       &vaf, ACPI_COMMON_MSG_SUFFIX_ARGS);
+
 	va_end(args);
 }
 
@@ -1103,12 +1117,15 @@ void ACPI_INTERNAL_VAR_XFACE
 acpi_info(const char *module_name, u32 line_number, const char *format, ...)
 {
 	va_list args;
-
-	acpi_os_printf("ACPI: ");
+	struct va_format vaf;
 
 	va_start(args, format);
-	acpi_os_vprintf(format, args);
-	acpi_os_printf("\n");
+
+	vaf.fmt = format;
+	vaf.va = &args;
+
+	acpi_os_printf("ACPI: %pV\n", &vaf);
+
 	va_end(args);
 }
 
@@ -1143,6 +1160,7 @@ acpi_ut_predefined_warning(const char *module_name,
 			   u8 node_flags, const char *format, ...)
 {
 	va_list args;
+	struct va_format vaf;
 
 	/*
 	 * Warning messages for this method/object will be disabled after the
@@ -1152,11 +1170,15 @@ acpi_ut_predefined_warning(const char *module_name,
 		return;
 	}
 
-	acpi_os_printf("ACPI Warning for %s: ", pathname);
-
 	va_start(args, format);
-	acpi_os_vprintf(format, args);
-	ACPI_COMMON_MSG_SUFFIX;
+
+	vaf.fmt = format;
+	vaf.va = &args;
+
+	acpi_os_printf("ACPI Warning for %s: %pV"
+		       ACPI_COMMON_MSG_SUFFIX_FMT "\n",
+		       pathname, &vaf, ACPI_COMMON_MSG_SUFFIX_ARGS);
+
 	va_end(args);
 }
 
@@ -1185,6 +1207,7 @@ acpi_ut_predefined_info(const char *module_name,
 			char *pathname, u8 node_flags, const char *format, ...)
 {
 	va_list args;
+	struct va_format vaf;
 
 	/*
 	 * Warning messages for this method/object will be disabled after the
@@ -1194,10 +1217,13 @@ acpi_ut_predefined_info(const char *module_name,
 		return;
 	}
 
-	acpi_os_printf("ACPI Info for %s: ", pathname);
-
 	va_start(args, format);
-	acpi_os_vprintf(format, args);
-	ACPI_COMMON_MSG_SUFFIX;
+
+	vaf.fmt = format;
+	vaf.va = &args;
+
+	acpi_os_printf("ACPI Info for %s: %pV" ACPI_COMMON_MSG_SUFFIX_FMT "\n",
+		       pathname, &vaf, ACPI_COMMON_MSG_SUFFIX_ARGS);
+
 	va_end(args);
 }


