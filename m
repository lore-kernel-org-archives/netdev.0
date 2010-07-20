From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] drivers/acpi/acpica/utmisc.c: Use printk
 extension %pV
Date: Tue, 20 Jul 2010 11:16:20 -0700
Message-ID: <1279649780.22947.38.camel@Joe-Laptop.home>
References: <1279602367.19374.20.camel@Joe-Laptop.home>
	 <201007201008.04496.bjorn.helgaas@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Len Brown <lenb@kernel.org>, linux-acpi@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <201007201008.04496.bjorn.helgaas@hp.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-07-20 at 10:08 -0600, Bjorn Helgaas wrote:
> On Monday, July 19, 2010 11:06:07 pm Joe Perches wrote:
> > Consolidates the printk messages to a single
> > call so the messages can not be interleaved.
> > 
> > Reduces text a bit.
> > 
> > $ size drivers/acpi/acpica/utmisc.o.*
> >    text	   data	    bss	    dec	    hex	filename
> >    7822	     56	   1832	   9710	   25ee	drivers/acpi/acpica/utmisc.o.old
> >    7748	     56	   1736	   9540	   2544	drivers/acpi/acpica/utmisc.o.new
> > 
> > Depends on net-next commit 7db6f5fb65a82af03229eef104dc9899c5eecf33
> > (vsprintf: Recursive vsnprintf: Add "%pV", struct va_format)
> 
> drivers/acpi/acpica/utmisc.c is part of the ACPI CA and is used in
> several different OSes, but %pV sounds like a Linux-specific feature,
> so I don't see how this patch can work.

Well, maybe something like this then.
It still reduces overall size a little bit, but less.

$ size drivers/acpi/acpica/utmisc.o
   text	   data	    bss	    dec	    hex	filename
   7816	     56	   1784	   9656	   25b8	drivers/acpi/acpica/utmisc.o

I'm not sure that utmisc.c is the right place for an #ifdef though.
---
 drivers/acpi/acpica/utmisc.c |   76 +++++++++++++++++++++++++++---------------
 1 files changed, 49 insertions(+), 27 deletions(-)

diff --git a/drivers/acpi/acpica/utmisc.c b/drivers/acpi/acpica/utmisc.c
index e8d0724..874e4d2 100644
--- a/drivers/acpi/acpica/utmisc.c
+++ b/drivers/acpi/acpica/utmisc.c
@@ -51,10 +51,45 @@
 ACPI_MODULE_NAME("utmisc")
 
 /*
- * Common suffix for messages
+ * Single line messages, adds a newline after message
  */
-#define ACPI_COMMON_MSG_SUFFIX \
-	acpi_os_printf(" (%8.8X/%s-%u)\n", ACPI_CA_VERSION, module_name, line_number)
+
+static void ACPI_PRINTF_LIKE(5)
+acpi_put_message(const char *module_name, u32 line_number,
+		 const char *fmt, va_list *args, const char *message, ...)
+{
+#ifdef __KERNEL__
+	va_list message_args;
+	struct va_format vaf1;
+	struct va_format vaf2;
+
+	va_start(message_args, message);
+	vaf1.fmt = message;
+	vaf1.va = &message_args;
+	vaf2.fmt = fmt;
+	vaf2.va = args;
+	if (module_name)
+		acpi_os_printf("%pV%pV (%8.8X/%s-%u)\n",
+			       &vaf1, &vaf2,
+			       ACPI_CA_VERSION, module_name, line_number);
+	else
+		acpi_os_printf("%pV%pV\n", &vaf1, &vaf2);
+	va_end(message_args);
+#else
+	va_list message_args;
+
+	va_start(message_args, message);
+	acpi_os_vprintf(message, message_args);
+	acpi_os_vprintf(fmt, *args);
+	if (module_name)
+		acpi_os_printf(" (%8.8X/%s-%u)\n",
+			       ACPI_CA_VERSION, module_name, line_number);
+	else
+		acpi_os_printf("\n");
+	va_end(message_args);
+#endif
+}
+
 /*******************************************************************************
  *
  * FUNCTION:    acpi_ut_validate_exception
@@ -1064,11 +1099,9 @@ acpi_error(const char *module_name, u32 line_number, const char *format, ...)
 {
 	va_list args;
 
-	acpi_os_printf("ACPI Error: ");
-
 	va_start(args, format);
-	acpi_os_vprintf(format, args);
-	ACPI_COMMON_MSG_SUFFIX;
+	acpi_put_message(module_name, line_number, format, &args,
+			 "ACPI Error: ");
 	va_end(args);
 }
 
@@ -1078,11 +1111,9 @@ acpi_exception(const char *module_name,
 {
 	va_list args;
 
-	acpi_os_printf("ACPI Exception: %s, ", acpi_format_exception(status));
-
 	va_start(args, format);
-	acpi_os_vprintf(format, args);
-	ACPI_COMMON_MSG_SUFFIX;
+	acpi_put_message(module_name, line_number, format, &args,
+			 "ACPI Exception: %s, ", acpi_format_exception(status));
 	va_end(args);
 }
 
@@ -1091,11 +1122,9 @@ acpi_warning(const char *module_name, u32 line_number, const char *format, ...)
 {
 	va_list args;
 
-	acpi_os_printf("ACPI Warning: ");
-
 	va_start(args, format);
-	acpi_os_vprintf(format, args);
-	ACPI_COMMON_MSG_SUFFIX;
+	acpi_put_message(module_name, line_number, format, &args,
+			 "ACPI Warning: ");
 	va_end(args);
 }
 
@@ -1104,11 +1133,8 @@ acpi_info(const char *module_name, u32 line_number, const char *format, ...)
 {
 	va_list args;
 
-	acpi_os_printf("ACPI: ");
-
 	va_start(args, format);
-	acpi_os_vprintf(format, args);
-	acpi_os_printf("\n");
+	acpi_put_message(NULL, 0, format, &args, "ACPI: ");
 	va_end(args);
 }
 
@@ -1152,11 +1178,9 @@ acpi_ut_predefined_warning(const char *module_name,
 		return;
 	}
 
-	acpi_os_printf("ACPI Warning for %s: ", pathname);
-
 	va_start(args, format);
-	acpi_os_vprintf(format, args);
-	ACPI_COMMON_MSG_SUFFIX;
+	acpi_put_message(module_name, line_number, format, &args,
+			 "ACPI Warning for %s: ", pathname);
 	va_end(args);
 }
 
@@ -1194,10 +1218,8 @@ acpi_ut_predefined_info(const char *module_name,
 		return;
 	}
 
-	acpi_os_printf("ACPI Info for %s: ", pathname);
-
 	va_start(args, format);
-	acpi_os_vprintf(format, args);
-	ACPI_COMMON_MSG_SUFFIX;
+	acpi_put_message(module_name, line_number, format, &args,
+			 "ACPI Info for %s: ", pathname);
 	va_end(args);
 }


