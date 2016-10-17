From: Zach Brown <zach.brown@ni.com>
Subject: [PATCH v5 3/4] net: phy: Create phy_supported_speeds function which
 lists speeds currently supported by a phydevice
Date: Mon, 17 Oct 2016 10:49:54 -0500
Message-ID: <1476719395-28273-4-git-send-email-zach.brown@ni.com>
References: <1476719395-28273-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, florian.c.schilhabel@googlemail.com,
 andrew@lunn.ch, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 rpurdie@rpsys.net, gregkh@linuxfoundation.org, Larry.Finger@lwfinger.net,
 j.anaszewski@samsung.com, linux-leds@vger.kernel.org, mlindner@marvell.com
To: <f.fainelli@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1476719395-28273-1-git-send-email-zach.brown@ni.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

phy_supported_speeds provides a means to get a list of all the speeds a
phy device currently supports.

Signed-off-by: Zach Brown <zach.brown@ni.com>
---
 drivers/net/phy/phy.c | 35 +++++++++++++++++++++++++++++++++++
 include/linux/phy.h   | 15 +++++++++++++++
 2 files changed, 50 insertions(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index f5721db..82ee233 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -261,6 +261,41 @@ static inline unsigned int phy_find_valid(unsigned int idx, u32 features)
 }
 
 /**
+ * phy_supported_speeds - return all speeds currently supported by a phy device
+ * @phy: The phy device to return supported speeds of.
+ * @speeds: buffer to store supported speeds in.
+ * @size:   size of speeds buffer.
+ *
+ * Description: Returns the number of supported speeds, and fills the speeds
+ * buffer with the supported speeds. If speeds buffer is too small to contain
+ * all currently supported speeds, will return as many speeds as can fit.
+ */
+unsigned int phy_supported_speeds(struct phy_device *phy,
+				  unsigned int *speeds,
+				  unsigned int size)
+{
+	unsigned int count = 0;
+	unsigned int idx = 0;
+
+	while (idx < MAX_NUM_SETTINGS && count < size) {
+		idx = phy_find_valid(idx, phy->supported);
+
+		if (!(settings[idx].setting & phy->supported))
+			break;
+
+		/* Assumes settings are grouped by speed */
+		if ((count == 0) ||
+		    (speeds[count - 1] != settings[idx].speed)) {
+			speeds[count] = settings[idx].speed;
+			count++;
+		}
+		idx++;
+	}
+
+	return count;
+}
+
+/**
  * phy_check_valid - check if there is a valid PHY setting which matches
  *		     speed, duplex, and feature mask
  * @speed: speed to match
diff --git a/include/linux/phy.h b/include/linux/phy.h
index e25f183..8761f30 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -85,6 +85,21 @@ typedef enum {
 } phy_interface_t;
 
 /**
+ * phy_supported_speeds - return all speeds currently supported by a phy device
+ * @phy: The phy device to return supported speeds of.
+ * @speeds: buffer to store supported speeds in.
+ * @size: size of speeds buffer.
+ *
+ * Description: Returns the number of supported speeds, and
+ * fills the speeds * buffer with the supported speeds. If speeds buffer is
+ * too small to contain * all currently supported speeds, will return as
+ * many speeds as can fit.
+ */
+unsigned int phy_supported_speeds(struct phy_device *phy,
+				      unsigned int *speeds,
+				      unsigned int size);
+
+/**
  * It maps 'enum phy_interface_t' found in include/linux/phy.h
  * into the device tree binding of 'phy-mode', so that Ethernet
  * device driver can get phy interface from device tree.
-- 
2.7.4
