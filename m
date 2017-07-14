From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 15/22] hwmon: applesmc: fix format string overflow
Date: Fri, 14 Jul 2017 14:07:07 +0200
Message-ID: <20170714120720.906842-16-arnd@arndb.de>
References: <20170714120720.906842-1-arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        akpm@linux-foundation.org, netdev@vger.kernel.org,
        "David S . Miller" <davem@davemloft.net>,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        linux-scsi@vger.kernel.org, x86@kernel.org,
        Arnd Bergmann <arnd@arndb.de>, linux-hwmon@vger.kernel.org
To: linux-kernel@vger.kernel.org, Henrik Rydberg <rydberg@bitmath.org>,
        Jean Delvare <jdelvare@suse.com>,
        Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc-7 warns that the key might exceed five bytes for lage index
values:

drivers/hwmon/applesmc.c: In function 'applesmc_show_fan_position':
drivers/hwmon/applesmc.c:906:18: error: '%d' directive writing between 1 and 5 bytes into a region of size 4 [-Werror=format-overflow=]
sprintf(newkey, FAN_ID_FMT, to_index(attr));
                ^~~~~~~
drivers/hwmon/applesmc.c:906:18: note: directive argument in the range [0, 65535]
drivers/hwmon/applesmc.c:906:2: note: 'sprintf' output between 5 and 9 bytes into a destination of size 5

As the key is required to be four characters plus trailing zero,
we know that the index has to be small here. I'm using snprintf()
to avoid the warning. This would truncate the string instead of
overflowing.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/hwmon/applesmc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/hwmon/applesmc.c b/drivers/hwmon/applesmc.c
index 0af7fd311979..515163b9a89f 100644
--- a/drivers/hwmon/applesmc.c
+++ b/drivers/hwmon/applesmc.c
@@ -903,7 +903,7 @@ static ssize_t applesmc_show_fan_position(struct device *dev,
 	char newkey[5];
 	u8 buffer[17];
 
-	sprintf(newkey, FAN_ID_FMT, to_index(attr));
+	snprintf(newkey, sizeof(newkey), FAN_ID_FMT, to_index(attr));
 
 	ret = applesmc_read_key(newkey, buffer, 16);
 	buffer[16] = 0;
-- 
2.9.0
