From: tony@bakeyournoodle.com (Tony Breeds)
Subject: Re: 2.6.21-rc2-mm2: drivers/net/wireless/libertas/debugfs.c addr bogosity
Date: Fri, 9 Mar 2007 13:11:46 +1100
Message-ID: <20070309021146.GL4575@bakeyournoodle.com>
References: <20070306004408.d3f6434d.akpm@linux-foundation.org> <20070307224116.GE3441@stusta.de> <20070307150057.4e6342dc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@stusta.de>, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S2992882AbXCICLu@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070307150057.4e6342dc.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 07, 2007 at 03:00:57PM -0800, Andrew Morton wrote:
> On Wed, 7 Mar 2007 23:41:16 +0100
> Adrian Bunk <bunk@stusta.de> wrote:
> 
> > On Tue, Mar 06, 2007 at 12:44:08AM -0800, Andrew Morton wrote:
> > >...
> > > Changes since 2.6.20-rc2-mm1:
> > >...
> > >  git-netdev-all.patch
> > >...
> > >  git trees
> > >...
> > 
> > drivers/net/wireless/libertas/debugfs.c contains:
> >   #define item_addr(n) ((u32) &((wlan_adapter *)0)->n)
> > 
> > This is wrong on 64bit architectures.
> 
> Is OK - it is simply yet another reimplementation of offsetof().  Hint.

Perhaps something like?

Against 2.6.21-rc3-mm2

From: Tony Breeds <tony@bakeyournoodle.com>

Cleanup drivers/net/wireless/libertas/debugfs.c to use standard kernel macros and functions.

Signed-off-by: Tony Breeds <tony@bakeyournoodle.com>

---
only compile tested on x86

 debugfs.c |   41 ++++-------------------------------------
 1 file changed, 4 insertions(+), 37 deletions(-)

diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
index 3ad1e03..51dfd20 100644
--- a/drivers/net/wireless/libertas/debugfs.c
+++ b/drivers/net/wireless/libertas/debugfs.c
@@ -1772,8 +1772,8 @@ void libertas_debugfs_remove_one(wlan_private *priv)
 
 /* debug entry */
 
-#define item_size(n) (sizeof ((wlan_adapter *)0)->n)
-#define item_addr(n) ((u32) &((wlan_adapter *)0)->n)
+#define item_size(n)	(FIELD_SIZEOF(wlan_adapter, n))
+#define item_addr(n)	(offsetof(wlan_adapter, n))
 
 struct debug_data {
 	char name[32];
@@ -1789,40 +1789,7 @@ static struct debug_data items[] = {
 	{"psstate", item_size(psstate), item_addr(psstate)},
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
@@ -1912,7 +1879,7 @@ static int wlan_debugfs_write(struct file *f, const char __user *buf,
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
