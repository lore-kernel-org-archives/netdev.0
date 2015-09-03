From: Julien Grall <julien.grall@citrix.com>
Subject: [PATCH] device property: Don't overwrite addr when failing in device_get_mac_address
Date: Thu, 3 Sep 2015 23:59:50 +0100
Message-ID: <1441321190-25631-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Julien Grall <julien.grall@citrix.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	<netdev@vger.kernel.org>
To: <jeremy.linton@arm.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function device_get_mac_address is trying different property names
in order to get the mac address. To check the return value, the variable
addr (which contain the buffer pass by the caller) will be re-used. This
means that if the previous property is not found, the next property will
be read using a NULL buffer.

Therefore it's only possible to retrieve the mac if node contains a
property "mac-address". Fix it by using a temporary buffer for the
return value.

This has been introduced by commit 4c96b7dc0d393f12c17e0d81db15aa4a820a6ab3
"Add a matching set of device_ functions for determining mac/phy"

Signed-off-by: Julien Grall <julien.grall@citrix.com>
Cc: Jeremy Linton <jeremy.linton@arm.com>
Cc: David S. Miller <davem@davemloft.net>

---
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: netdev@vger.kernel.org
---
 drivers/base/property.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/base/property.c b/drivers/base/property.c
index ff03f23..2d75366 100644
--- a/drivers/base/property.c
+++ b/drivers/base/property.c
@@ -611,13 +611,15 @@ static void *device_get_mac_addr(struct device *dev,
 */
 void *device_get_mac_address(struct device *dev, char *addr, int alen)
 {
-	addr = device_get_mac_addr(dev, "mac-address", addr, alen);
-	if (addr)
-		return addr;
+	char *res;
 
-	addr = device_get_mac_addr(dev, "local-mac-address", addr, alen);
-	if (addr)
-		return addr;
+	res = device_get_mac_addr(dev, "mac-address", addr, alen);
+	if (res)
+		return res;
+
+	res = device_get_mac_addr(dev, "local-mac-address", addr, alen);
+	if (res)
+		return res;
 
 	return device_get_mac_addr(dev, "address", addr, alen);
 }
-- 
2.1.4
