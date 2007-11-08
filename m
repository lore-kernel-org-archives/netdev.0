From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'fixes-davem' branch of wireless-2.6 (this time for
	real!)
Date: Wed, 7 Nov 2007 21:11:19 -0500
Message-ID: <20071108021119.GD11957@tuxdriver.com>
References: <20071107001314.GH4440@tuxdriver.com> <20071107185147.GA21097@tuxdriver.com> <20071107.163200.25509588.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20071107.163200.25509588.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 07, 2007 at 04:32:00PM -0800, David Miller wrote:
> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Wed, 7 Nov 2007 13:51:54 -0500
> 
> > Hold-off on this one for now if -- clearly Johannes and I need to
> > brush-up on our Kconfig skills... :-(
> > 
> > I'll post a new pull request soon.
> 
> Ok.

Dave,

These fixes are additive on top of the previous request archived here:

	http://marc.info/?l=linux-wireless&m=119439453721827&w=2

I've been sending ssb patches to you, but I'm not sure if that is the
right place to send them.  If you don't want them, can you suggest where
else I should send them?

Anyway, let me know if there are any problems!

Thanks,

John

---

The entire series (i.e. both from yesterday and today) is available
here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-davem

---

The following changes since commit d81bd04a737c102481c0ee7b46443796e14b6b5c:
  John W. Linville (1):
        mac80211: make "decrypt failed" messages conditional upon MAC80211_DEBUG

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-davem

Johannes Berg (1):
      mac80211: fix MAC80211_RCSIMPLE Kconfig

Michael Buesch (1):
      ssb: Fix PCMCIA-host lowlevel bus access

 drivers/ssb/main.c   |    1 +
 drivers/ssb/pcmcia.c |   56 +++++++++++++++++++++++++-------------------------
 net/mac80211/Kconfig |    4 +-
 3 files changed, 31 insertions(+), 30 deletions(-)

diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index fc1d589..85a2054 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -440,6 +440,7 @@ static int ssb_devices_register(struct ssb_bus *bus)
 			break;
 		case SSB_BUSTYPE_PCMCIA:
 #ifdef CONFIG_SSB_PCMCIAHOST
+			sdev->irq = bus->host_pcmcia->irq.AssignedIRQ;
 			dev->parent = &bus->host_pcmcia->dev;
 #endif
 			break;
diff --git a/drivers/ssb/pcmcia.c b/drivers/ssb/pcmcia.c
index b6abee8..bb44a76 100644
--- a/drivers/ssb/pcmcia.c
+++ b/drivers/ssb/pcmcia.c
@@ -63,17 +63,17 @@ int ssb_pcmcia_switch_coreidx(struct ssb_bus *bus,
 		err = pcmcia_access_configuration_register(pdev, &reg);
 		if (err != CS_SUCCESS)
 			goto error;
-		read_addr |= (reg.Value & 0xF) << 12;
+		read_addr |= ((u32)(reg.Value & 0x0F)) << 12;
 		reg.Offset = 0x30;
 		err = pcmcia_access_configuration_register(pdev, &reg);
 		if (err != CS_SUCCESS)
 			goto error;
-		read_addr |= reg.Value << 16;
+		read_addr |= ((u32)reg.Value) << 16;
 		reg.Offset = 0x32;
 		err = pcmcia_access_configuration_register(pdev, &reg);
 		if (err != CS_SUCCESS)
 			goto error;
-		read_addr |= reg.Value << 24;
+		read_addr |= ((u32)reg.Value) << 24;
 
 		cur_core = (read_addr - SSB_ENUM_BASE) / SSB_CORE_SIZE;
 		if (cur_core == coreidx)
@@ -152,28 +152,29 @@ error:
 	goto out_unlock;
 }
 
-/* These are the main device register access functions.
- * do_select_core is inline to have the likely hotpath inline.
- * All unlikely codepaths are out-of-line. */
-static inline int do_select_core(struct ssb_bus *bus,
-				 struct ssb_device *dev,
-				 u16 *offset)
+static int select_core_and_segment(struct ssb_device *dev,
+				   u16 *offset)
 {
+	struct ssb_bus *bus = dev->bus;
 	int err;
-	u8 need_seg = (*offset >= 0x800) ? 1 : 0;
+	u8 need_segment;
+
+	if (*offset >= 0x800) {
+		*offset -= 0x800;
+		need_segment = 1;
+	} else
+		need_segment = 0;
 
 	if (unlikely(dev != bus->mapped_device)) {
 		err = ssb_pcmcia_switch_core(bus, dev);
 		if (unlikely(err))
 			return err;
 	}
-	if (unlikely(need_seg != bus->mapped_pcmcia_seg)) {
-		err = ssb_pcmcia_switch_segment(bus, need_seg);
+	if (unlikely(need_segment != bus->mapped_pcmcia_seg)) {
+		err = ssb_pcmcia_switch_segment(bus, need_segment);
 		if (unlikely(err))
 			return err;
 	}
-	if (need_seg == 1)
-		*offset -= 0x800;
 
 	return 0;
 }
@@ -181,32 +182,31 @@ static inline int do_select_core(struct ssb_bus *bus,
 static u16 ssb_pcmcia_read16(struct ssb_device *dev, u16 offset)
 {
 	struct ssb_bus *bus = dev->bus;
-	u16 x;
 
-	if (unlikely(do_select_core(bus, dev, &offset)))
+	if (unlikely(select_core_and_segment(dev, &offset)))
 		return 0xFFFF;
-	x = readw(bus->mmio + offset);
 
-	return x;
+	return readw(bus->mmio + offset);
 }
 
 static u32 ssb_pcmcia_read32(struct ssb_device *dev, u16 offset)
 {
 	struct ssb_bus *bus = dev->bus;
-	u32 x;
+	u32 lo, hi;
 
-	if (unlikely(do_select_core(bus, dev, &offset)))
+	if (unlikely(select_core_and_segment(dev, &offset)))
 		return 0xFFFFFFFF;
-	x = readl(bus->mmio + offset);
+	lo = readw(bus->mmio + offset);
+	hi = readw(bus->mmio + offset + 2);
 
-	return x;
+	return (lo | (hi << 16));
 }
 
 static void ssb_pcmcia_write16(struct ssb_device *dev, u16 offset, u16 value)
 {
 	struct ssb_bus *bus = dev->bus;
 
-	if (unlikely(do_select_core(bus, dev, &offset)))
+	if (unlikely(select_core_and_segment(dev, &offset)))
 		return;
 	writew(value, bus->mmio + offset);
 }
@@ -215,12 +215,12 @@ static void ssb_pcmcia_write32(struct ssb_device *dev, u16 offset, u32 value)
 {
 	struct ssb_bus *bus = dev->bus;
 
-	if (unlikely(do_select_core(bus, dev, &offset)))
+	if (unlikely(select_core_and_segment(dev, &offset)))
 		return;
-	readw(bus->mmio + offset);
-	writew(value >> 16, bus->mmio + offset + 2);
-	readw(bus->mmio + offset);
-	writew(value, bus->mmio + offset);
+	writeb((value & 0xFF000000) >> 24, bus->mmio + offset + 3);
+	writeb((value & 0x00FF0000) >> 16, bus->mmio + offset + 2);
+	writeb((value & 0x0000FF00) >> 8, bus->mmio + offset + 1);
+	writeb((value & 0x000000FF) >> 0, bus->mmio + offset + 0);
 }
 
 /* Not "static", as it's used in main.c */
diff --git a/net/mac80211/Kconfig b/net/mac80211/Kconfig
index 32c8c08..ce176e6 100644
--- a/net/mac80211/Kconfig
+++ b/net/mac80211/Kconfig
@@ -14,9 +14,9 @@ config MAC80211
 	networking stack.
 
 config MAC80211_RCSIMPLE
-	bool "'simple' rate control algorithm"
+	bool "'simple' rate control algorithm" if EMBEDDED
 	default y
-	depends on MAC80211 && EMBEDDED
+	depends on MAC80211
 	help
 	  This option allows you to turn off the 'simple' rate
 	  control algorithm in mac80211. If you do turn it off,
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
