From: Adam Borowski <kilobyte-b9QjgO8OEXPVItvQsEIGlw@public.gmane.org>
Subject: [PATCH v2] rtl8xxxu: Don't printk raw binary if serial number is not burned in.
Date: Fri,  8 Sep 2017 12:30:00 +0200
Message-ID: <20170908103000.6795-1-kilobyte@angband.pl>
References: <20170908032706.1fa59da9@elisabeth>
Cc: Adam Borowski <kilobyte-b9QjgO8OEXPVItvQsEIGlw@public.gmane.org>
To: Jes Sorensen <Jes.Sorensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Stefano Brivio <sbrivio-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170908032706.1fa59da9@elisabeth>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I assume that a blank efuse comes with all ones, thus I did not bother
recognizing other possible junk values.  This matches 100% of dongles
I've seen (a single Gembird 8192eu).

Signed-off-by: Adam Borowski <kilobyte-b9QjgO8OEXPVItvQsEIGlw@public.gmane.org>
---
v2: strncmp("goofy string") -> memchr_inv()

Stefano Brivio wrote:
> You might want to use memchr_inv():
>
>        if (memchr_inv(efuse->serial, 0xff, 11))
>                dev_info(&priv->udev->dev, "Serial: %.11s\n", efuse->serial);
>        ...
>
> Mostly cosmetic though.

This looks much better, thanks!


 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
index 80fee699f58a..38b2ba1ac6f8 100644
--- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
+++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
@@ -614,7 +614,10 @@ static int rtl8192eu_parse_efuse(struct rtl8xxxu_priv *priv)
 
 	dev_info(&priv->udev->dev, "Vendor: %.7s\n", efuse->vendor_name);
 	dev_info(&priv->udev->dev, "Product: %.11s\n", efuse->device_name);
-	dev_info(&priv->udev->dev, "Serial: %.11s\n", efuse->serial);
+	if (memchr_inv(efuse->serial, 0xff, 11))
+		dev_info(&priv->udev->dev, "Serial: %.11s\n", efuse->serial);
+	else
+		dev_info(&priv->udev->dev, "Serial not available.\n");
 
 	if (rtl8xxxu_debug & RTL8XXXU_DEBUG_EFUSE) {
 		unsigned char *raw = priv->efuse_wifi.raw;
-- 
2.14.1
