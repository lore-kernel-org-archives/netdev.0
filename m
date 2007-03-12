From: tony@bakeyournoodle.com (Tony Breeds)
Subject: Re: 2.6.21-rc2-mm2: drivers/net/wireless/libertas/debugfs.c addr bogosity
Date: Mon, 12 Mar 2007 14:43:26 +1100
Message-ID: <20070312034326.GQ4575@bakeyournoodle.com>
References: <20070306004408.d3f6434d.akpm@linux-foundation.org> <20070307224116.GE3441@stusta.de> <20070307150057.4e6342dc.akpm@linux-foundation.org> <20070309021146.GL4575@bakeyournoodle.com> <20070309141906.GA3296@tuxdriver.com> <20070309091429.a84aee9b.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Adrian Bunk <bunk@stusta.de>, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pythia.bakeyournoodle.com ([203.82.209.197]:38760 "EHLO
	pythia.bakeyournoodle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964968AbXCLDn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2007 23:43:29 -0400
Content-Disposition: inline
In-Reply-To: <20070309091429.a84aee9b.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 09, 2007 at 09:14:29AM -0800, Randy Dunlap wrote:
 
> Good to use FIELD_SIZEOF(),

Thanks.

>                             but in general, we prefer to use it
> directly, not in yet another wrapper.

I left the item_{size,addr} in place as it seemed to make the item[]
more compact.

I'm not certain using the FIELD_SIZEOF() macro directly is a win.

From: Tony Breeds <tony@bakeyournoodle.com>

Cleanup drivers/net/wireless/libertas/debugfs.c to use standard kernel macros and functions.

Signed-off-by: Tony Breeds <tony@bakeyournoodle.com>

---
only compile tested on x86

 drivers/net/wireless/libertas/debugfs.c |   56 +++++++------------------------
 1 files changed, 12 insertions(+), 44 deletions(-)

diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
index 3ad1e03..8b0e3ec 100644
--- a/drivers/net/wireless/libertas/debugfs.c
+++ b/drivers/net/wireless/libertas/debugfs.c
@@ -1771,58 +1771,26 @@ void libertas_debugfs_remove_one(wlan_private *priv)
 }
 
 /* debug entry */
-
-#define item_size(n) (sizeof ((wlan_adapter *)0)->n)
-#define item_addr(n) ((u32) &((wlan_adapter *)0)->n)
-
 struct debug_data {
 	char name[32];
 	u32 size;
 	u32 addr;
 };
 
-/* To debug any member of wlan_adapter, simply add one line here.
- */
+/* To debug any member of wlan_adapter, simply add a record here. */
 static struct debug_data items[] = {
-	{"intcounter", item_size(intcounter), item_addr(intcounter)},
-	{"psmode", item_size(psmode), item_addr(psmode)},
-	{"psstate", item_size(psstate), item_addr(psstate)},
+	{ .name = "intcounter",
+	  .size = FIELD_SIZEOF(wlan_adapter, intcounter),
+	  .addr = offsetof(wlan_adapter, intcounter) },
+	{ .name = "psmode",
+	  .size = FIELD_SIZEOF(wlan_adapter, psmode),
+	  .addr = offsetof(wlan_adapter, psmode) },
+	{ .name = "psstate",
+	  .size = FIELD_SIZEOF(wlan_adapter, psstate),
+	  .addr = offsetof(wlan_adapter, psstate) },
 };
 
-static int num_of_items = sizeof(items) / sizeof(items[0]);
-
-/**
- *  @brief convert string to number
- *
- *  @param s   	   pointer to numbered string
- *  @return 	   converted number from string s
- */
-static int string_to_number(char *s)
-{
-	int r = 0;
-	int base = 0;
-
-	if ((strncmp(s, "0x", 2) == 0) || (strncmp(s, "0X", 2) == 0))
-		base = 16;
-	else
-		base = 10;
-
-	if (base == 16)
-		s += 2;
-
-	for (s = s; *s != 0; s++) {
-		if ((*s >= 48) && (*s <= 57))
-			r = (r * base) + (*s - 48);
-		else if ((*s >= 65) && (*s <= 70))
-			r = (r * base) + (*s - 55);
-		else if ((*s >= 97) && (*s <= 102))
-			r = (r * base) + (*s - 87);
-		else
-			break;
-	}
-
-	return r;
-}
+static int num_of_items = ARRAY_SIZE(items);
 
 /**
  *  @brief proc read function
@@ -1912,7 +1880,7 @@ static int wlan_debugfs_write(struct file *f, const char __user *buf,
 			if (!p2)
 				break;
 			p2++;
-			r = string_to_number(p2);
+			r = simple_strtoul(p2, NULL, 0);
 			if (d[i].size == 1)
 				*((u8 *) d[i].addr) = (u8) r;
 			else if (d[i].size == 2)


Yours Tony

  linux.conf.au        http://linux.conf.au/ || http://lca2008.linux.org.au/
  Jan 28 - Feb 02 2008 The Australian Linux Technical Conference!

