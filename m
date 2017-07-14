From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 18/22] gpio: acpi: fix string overflow for large pin numbers
Date: Fri, 14 Jul 2017 14:07:10 +0200
Message-ID: <20170714120720.906842-19-arnd@arndb.de>
References: <20170714120720.906842-1-arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org,
        netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        linux-scsi@vger.kernel.org, x86@kernel.org,
        Arnd Bergmann <arnd@arndb.de>,
        Hans de Goede <hdegoede@redhat.com>,
        "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Wei Yongjun <weiyongjun1@huawei.com>,
        linux-gpio@vger.kernel.org, linux-acpi@vger.kernel.org
To: linux-kernel@vger.kernel.org,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Linus Walleij <linus.walleij@linaro.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-1-arnd@arndb.de>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc-7 notices that the pin_table is an array of 16-bit numbers,
but we assume it can be printed as a two-character hexadecimal
string:

drivers/gpio/gpiolib-acpi.c: In function 'acpi_gpiochip_request_interrupt':
drivers/gpio/gpiolib-acpi.c:206:24: warning: '%02X' directive writing between 2 and 4 bytes into a region of size 3 [-Wformat-overflow=]
   sprintf(ev_name, "_%c%02X",
                        ^~~~
drivers/gpio/gpiolib-acpi.c:206:20: note: directive argument in the range [0, 65535]
   sprintf(ev_name, "_%c%02X",
                    ^~~~~~~~~
drivers/gpio/gpiolib-acpi.c:206:3: note: 'sprintf' output between 5 and 7 bytes into a destination of size 5
   sprintf(ev_name, "_%c%02X",
   ^~~~~~~~~~~~~~~~~~~~~~~~~~~
    agpio->triggering == ACPI_EDGE_SENSITIVE ? 'E' : 'L',
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    pin);
    ~~~~

This can't be right, so this changes it to truncate the number to
an 8-bit pin number.

Fixes: 0d1c28a449c6 ("gpiolib-acpi: Add ACPI5 event model support to gpio.")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/gpio/gpiolib-acpi.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/gpio/gpiolib-acpi.c b/drivers/gpio/gpiolib-acpi.c
index c9b42dd12dfa..c3faea724af8 100644
--- a/drivers/gpio/gpiolib-acpi.c
+++ b/drivers/gpio/gpiolib-acpi.c
@@ -205,7 +205,7 @@ static acpi_status acpi_gpiochip_request_interrupt(struct acpi_resource *ares,
 		char ev_name[5];
 		sprintf(ev_name, "_%c%02X",
 			agpio->triggering == ACPI_EDGE_SENSITIVE ? 'E' : 'L',
-			pin);
+			(u8)pin);
 		if (ACPI_SUCCESS(acpi_get_handle(handle, ev_name, &evt_handle)))
 			handler = acpi_gpio_irq_handler;
 	}
-- 
2.9.0

