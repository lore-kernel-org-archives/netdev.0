From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/3] drivers/net/wireless/b43: Logging cleanups
Date: Sat, 19 Jun 2010 16:30:10 -0700
Message-ID: <d3ba55bcaadc8de1fee266a9c8811288d769c16a.1276988387.git.joe@perches.com>
References: <cover.1276988387.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stefano Brivio <stefano.brivio@polimi.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1196 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754369Ab0FSXaW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jun 2010 19:30:22 -0400
In-Reply-To: <cover.1276988387.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the logging macros and printks to a more standardized style.
Add underscores to b43 logging macros:
	b43info -> b43_info
	b43err  -> b43_err
	b43warn -> b43_warn
	b43dbg  -> b43_dbg
Use pr_<level> in a few places.
Add KERN_<level> in a few places.
Coalesced some format strings.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/b43/b43.h        |   17 +--
 drivers/net/wireless/b43/debugfs.c    |   14 +-
 drivers/net/wireless/b43/dma.c        |  115 ++++++++---------
 drivers/net/wireless/b43/leds.c       |    6 +-
 drivers/net/wireless/b43/lo.c         |   31 ++---
 drivers/net/wireless/b43/main.c       |  232 ++++++++++++++++----------------
 drivers/net/wireless/b43/pcmcia.c     |    3 +-
 drivers/net/wireless/b43/phy_a.c      |   11 +-
 drivers/net/wireless/b43/phy_common.c |    7 +-
 drivers/net/wireless/b43/phy_g.c      |   54 ++++----
 drivers/net/wireless/b43/phy_lp.c     |   17 ++-
 drivers/net/wireless/b43/phy_n.c      |   30 ++--
 drivers/net/wireless/b43/pio.c        |   12 +-
 drivers/net/wireless/b43/rfkill.c     |    4 +-
 drivers/net/wireless/b43/sysfs.c      |    3 +-
 drivers/net/wireless/b43/xmit.c       |   10 +-
 16 files changed, 278 insertions(+), 288 deletions(-)

diff --git a/drivers/net/wireless/b43/b43.h b/drivers/net/wireless/b43/b43.h
index 8674a99..28bf8f2 100644
--- a/drivers/net/wireless/b43/b43.h
+++ b/drivers/net/wireless/b43/b43.h
@@ -895,15 +895,14 @@ static inline bool b43_using_pio_transfers(struct b43_wldev *dev)
 #endif
 
 /* Message printing */
-void b43info(struct b43_wl *wl, const char *fmt, ...)
-    __attribute__ ((format(printf, 2, 3)));
-void b43err(struct b43_wl *wl, const char *fmt, ...)
-    __attribute__ ((format(printf, 2, 3)));
-void b43warn(struct b43_wl *wl, const char *fmt, ...)
-    __attribute__ ((format(printf, 2, 3)));
-void b43dbg(struct b43_wl *wl, const char *fmt, ...)
-    __attribute__ ((format(printf, 2, 3)));
-
+void b43_info(struct b43_wl *wl, const char *fmt, ...)
+	__attribute__ ((format(printf, 2, 3)));
+void b43_err(struct b43_wl *wl, const char *fmt, ...)
+	__attribute__ ((format(printf, 2, 3)));
+void b43_warn(struct b43_wl *wl, const char *fmt, ...)
+	__attribute__ ((format(printf, 2, 3)));
+void b43_dbg(struct b43_wl *wl, const char *fmt, ...)
+	__attribute__ ((format(printf, 2, 3)));
 
 /* A WARN_ON variant that vanishes when b43 debugging is disabled.
  * This _also_ evaluates the arg with debugging disabled. */
diff --git a/drivers/net/wireless/b43/debugfs.c b/drivers/net/wireless/b43/debugfs.c
index 80b19a4..307802c 100644
--- a/drivers/net/wireless/b43/debugfs.c
+++ b/drivers/net/wireless/b43/debugfs.c
@@ -68,7 +68,7 @@ struct b43_dfs_file *fops_to_dfs_file(struct b43_wldev *dev,
 					  bufsize - count,	\
 					  fmt , ##x);		\
 		else						\
-			printk(KERN_ERR "b43: fappend overflow\n"); \
+			pr_err("b43: fappend overflow\n");	\
 	} while (0)
 
 
@@ -703,7 +703,7 @@ void b43_debugfs_add_device(struct b43_wldev *dev)
 	B43_WARN_ON(!dev);
 	e = kzalloc(sizeof(*e), GFP_KERNEL);
 	if (!e) {
-		b43err(dev->wl, "debugfs: add device OOM\n");
+		b43_err(dev->wl, "debugfs: add device OOM\n");
 		return;
 	}
 	e->dev = dev;
@@ -711,7 +711,7 @@ void b43_debugfs_add_device(struct b43_wldev *dev)
 	log->log = kcalloc(B43_NR_LOGGED_TXSTATUS,
 			   sizeof(struct b43_txstatus), GFP_KERNEL);
 	if (!log->log) {
-		b43err(dev->wl, "debugfs: add device txstatus OOM\n");
+		b43_err(dev->wl, "debugfs: add device txstatus OOM\n");
 		kfree(e);
 		return;
 	}
@@ -723,11 +723,11 @@ void b43_debugfs_add_device(struct b43_wldev *dev)
 	e->subdir = debugfs_create_dir(devdir, rootdir);
 	if (!e->subdir || IS_ERR(e->subdir)) {
 		if (e->subdir == ERR_PTR(-ENODEV)) {
-			b43dbg(dev->wl, "DebugFS (CONFIG_DEBUG_FS) not "
-			       "enabled in kernel config\n");
+			b43_dbg(dev->wl,
+				"DebugFS (CONFIG_DEBUG_FS) not enabled in kernel config\n");
 		} else {
-			b43err(dev->wl, "debugfs: cannot create %s directory\n",
-			       devdir);
+			b43_err(dev->wl, "debugfs: cannot create %s directory\n",
+				devdir);
 		}
 		dev->dfsentry = NULL;
 		kfree(log->log);
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index 10d0aaf..a6d15c4 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -266,10 +266,10 @@ static void update_max_used_slots(struct b43_dmaring *ring,
 		return;
 	ring->max_used_slots = current_used_slots;
 	if (b43_debug(ring->dev, B43_DBG_DMAVERBOSE)) {
-		b43dbg(ring->dev->wl,
-		       "max_used_slots increased to %d on %s ring %d\n",
-		       ring->max_used_slots,
-		       ring->tx ? "TX" : "RX", ring->index);
+		b43_dbg(ring->dev->wl,
+			"max_used_slots increased to %d on %s ring %d\n",
+			ring->max_used_slots,
+			ring->tx ? "TX" : "RX", ring->index);
 	}
 }
 #else
@@ -405,7 +405,7 @@ static int alloc_ringmemory(struct b43_dmaring *ring)
 					    B43_DMA_RINGMEMSIZE,
 					    &(ring->dmabase), flags);
 	if (!ring->descbase) {
-		b43err(ring->dev->wl, "DMA ringmemory allocation failed\n");
+		b43_err(ring->dev->wl, "DMA ringmemory allocation failed\n");
 		return -ENOMEM;
 	}
 	memset(ring->descbase, 0, B43_DMA_RINGMEMSIZE);
@@ -456,7 +456,7 @@ static int b43_dmacontroller_rx_reset(struct b43_wldev *dev, u16 mmio_base,
 		msleep(1);
 	}
 	if (i != -1) {
-		b43err(dev->wl, "DMA RX reset timed out\n");
+		b43_err(dev->wl, "DMA RX reset timed out\n");
 		return -ENODEV;
 	}
 
@@ -514,7 +514,7 @@ static int b43_dmacontroller_tx_reset(struct b43_wldev *dev, u16 mmio_base,
 		msleep(1);
 	}
 	if (i != -1) {
-		b43err(dev->wl, "DMA TX reset timed out\n");
+		b43_err(dev->wl, "DMA TX reset timed out\n");
 		return -ENODEV;
 	}
 	/* ensure the reset is completed. */
@@ -605,7 +605,7 @@ static int setup_rx_descbuffer(struct b43_dmaring *ring,
 		dmaaddr = map_descbuffer(ring, skb->data,
 					 ring->rx_buffersize, 0);
 		if (b43_dma_mapping_error(ring, dmaaddr, ring->rx_buffersize, 0)) {
-			b43err(ring->dev->wl, "RX DMA buffer allocation failed\n");
+			b43_err(ring->dev->wl, "RX DMA buffer allocation failed\n");
 			dev_kfree_skb_any(skb);
 			return -EIO;
 		}
@@ -633,8 +633,8 @@ static int alloc_initial_descbuffers(struct b43_dmaring *ring)
 
 		err = setup_rx_descbuffer(ring, desc, meta, GFP_KERNEL);
 		if (err) {
-			b43err(ring->dev->wl,
-			       "Failed to allocate initial descbuffers\n");
+			b43_err(ring->dev->wl,
+				"Failed to allocate initial descbuffers\n");
 			goto err_unwind;
 		}
 	}
@@ -897,8 +897,8 @@ struct b43_dmaring *b43_setup_dmaring(struct b43_wldev *dev,
 			if (b43_dma_mapping_error(ring, dma_test,
 						  b43_txhdr_size(dev), 1)) {
 
-				b43err(dev->wl,
-				       "TXHDR DMA allocation failed\n");
+				b43_err(dev->wl,
+					"TXHDR DMA allocation failed\n");
 				goto err_kfree_txhdr_cache;
 			}
 		}
@@ -961,18 +961,18 @@ static void b43_destroy_dmaring(struct b43_dmaring *ring,
 		if (nr_packets)
 			average_tries = divide(ring->nr_total_packet_tries * 100, nr_packets);
 
-		b43dbg(ring->dev->wl, "DMA-%u %s: "
-		       "Used slots %d/%d, Failed frames %llu/%llu = %llu.%01llu%%, "
-		       "Average tries %llu.%02llu\n",
-		       (unsigned int)(ring->type), ringname,
-		       ring->max_used_slots,
-		       ring->nr_slots,
-		       (unsigned long long)failed_packets,
-		       (unsigned long long)nr_packets,
-		       (unsigned long long)divide(permille_failed, 10),
-		       (unsigned long long)modulo(permille_failed, 10),
-		       (unsigned long long)divide(average_tries, 100),
-		       (unsigned long long)modulo(average_tries, 100));
+		b43_dbg(ring->dev->wl, "DMA-%u %s: "
+			"Used slots %d/%d, Failed frames %llu/%llu = %llu.%01llu%%, "
+			"Average tries %llu.%02llu\n",
+			(unsigned int)(ring->type), ringname,
+			ring->max_used_slots,
+			ring->nr_slots,
+			(unsigned long long)failed_packets,
+			(unsigned long long)nr_packets,
+			(unsigned long long)divide(permille_failed, 10),
+			(unsigned long long)modulo(permille_failed, 10),
+			(unsigned long long)divide(average_tries, 100),
+			(unsigned long long)modulo(average_tries, 100));
 	}
 #endif /* DEBUG */
 
@@ -1034,15 +1034,14 @@ static int b43_dma_set_mask(struct b43_wldev *dev, u64 mask)
 			fallback = 1;
 			continue;
 		}
-		b43err(dev->wl, "The machine/kernel does not support "
-		       "the required %u-bit DMA mask\n",
-		       (unsigned int)dma_mask_to_engine_type(orig_mask));
+		b43_err(dev->wl, "The machine/kernel does not support the required %u-bit DMA mask\n",
+			(unsigned int)dma_mask_to_engine_type(orig_mask));
 		return -EOPNOTSUPP;
 	}
 	if (fallback) {
-		b43info(dev->wl, "DMA mask fallback from %u-bit to %u-bit\n",
-			(unsigned int)dma_mask_to_engine_type(orig_mask),
-			(unsigned int)dma_mask_to_engine_type(mask));
+		b43_info(dev->wl, "DMA mask fallback from %u-bit to %u-bit\n",
+			 (unsigned int)dma_mask_to_engine_type(orig_mask),
+			 (unsigned int)dma_mask_to_engine_type(mask));
 	}
 
 	return 0;
@@ -1091,8 +1090,7 @@ int b43_dma_init(struct b43_wldev *dev)
 	/* No support for the TX status DMA ring. */
 	B43_WARN_ON(dev->dev->id.revision < 5);
 
-	b43dbg(dev->wl, "%u-bit DMA initialized\n",
-	       (unsigned int)type);
+	b43_dbg(dev->wl, "%u-bit DMA initialized\n", (unsigned int)type);
 	err = 0;
 out:
 	return err;
@@ -1156,8 +1154,8 @@ struct b43_dmaring *parse_cookie(struct b43_wldev *dev, u16 cookie, int *slot)
 	}
 	*slot = (cookie & 0x0FFF);
 	if (unlikely(!ring || *slot < 0 || *slot >= ring->nr_slots)) {
-		b43dbg(dev->wl, "TX-status contains "
-		       "invalid cookie: 0x%04X\n", cookie);
+		b43_dbg(dev->wl, "TX-status contains invalid cookie: 0x%04X\n",
+			cookie);
 		return NULL;
 	}
 
@@ -1274,9 +1272,9 @@ static inline int should_inject_overflow(struct b43_dmaring *ring)
 		next_overflow = ring->last_injected_overflow + HZ;
 		if (time_after(jiffies, next_overflow)) {
 			ring->last_injected_overflow = jiffies;
-			b43dbg(ring->dev->wl,
-			       "Injecting TX ring overflow on "
-			       "DMA controller %d\n", ring->index);
+			b43_dbg(ring->dev->wl,
+				"Injecting TX ring overflow on DMA controller %d\n",
+				ring->index);
 			return 1;
 		}
 	}
@@ -1343,7 +1341,7 @@ int b43_dma_tx(struct b43_wldev *dev, struct sk_buff *skb)
 		 * the queue is stopped, thus we got called when we shouldn't.
 		 * For now, just refuse the transmit. */
 		if (b43_debug(dev, B43_DBG_DMAVERBOSE))
-			b43err(dev->wl, "Packet after queue stopped\n");
+			b43_err(dev->wl, "Packet after queue stopped\n");
 		err = -ENOSPC;
 		goto out;
 	}
@@ -1351,7 +1349,7 @@ int b43_dma_tx(struct b43_wldev *dev, struct sk_buff *skb)
 	if (unlikely(WARN_ON(free_slots(ring) < TX_SLOTS_PER_FRAME))) {
 		/* If we get here, we have a real error with the queue
 		 * full, but queues not stopped. */
-		b43err(dev->wl, "DMA queue overflow\n");
+		b43_err(dev->wl, "DMA queue overflow\n");
 		err = -ENOSPC;
 		goto out;
 	}
@@ -1370,7 +1368,7 @@ int b43_dma_tx(struct b43_wldev *dev, struct sk_buff *skb)
 		goto out;
 	}
 	if (unlikely(err)) {
-		b43err(dev->wl, "DMA tx mapping failure\n");
+		b43_err(dev->wl, "DMA tx mapping failure\n");
 		goto out;
 	}
 	if ((free_slots(ring) < TX_SLOTS_PER_FRAME) ||
@@ -1379,7 +1377,7 @@ int b43_dma_tx(struct b43_wldev *dev, struct sk_buff *skb)
 		ieee80211_stop_queue(dev->wl->hw, skb_get_queue_mapping(skb));
 		ring->stopped = 1;
 		if (b43_debug(dev, B43_DBG_DMAVERBOSE)) {
-			b43dbg(dev->wl, "Stopped TX ring %d\n", ring->index);
+			b43_dbg(dev->wl, "Stopped TX ring %d\n", ring->index);
 		}
 	}
 out:
@@ -1411,9 +1409,9 @@ void b43_dma_handle_txstatus(struct b43_wldev *dev,
 	if (unlikely(slot != firstused)) {
 		/* This possibly is a firmware bug and will result in
 		 * malfunction, memory leaks and/or stall of DMA functionality. */
-		b43dbg(dev->wl, "Out of order TX status report on DMA ring %d. "
-		       "Expected %d, but got %d\n",
-		       ring->index, firstused, slot);
+		b43_dbg(dev->wl, "Out of order TX status report on DMA ring %d. "
+			"Expected %d, but got %d\n",
+			ring->index, firstused, slot);
 		return;
 	}
 
@@ -1423,9 +1421,8 @@ void b43_dma_handle_txstatus(struct b43_wldev *dev,
 		desc = ops->idx2desc(ring, slot, &meta);
 
 		if (b43_dma_ptr_is_poisoned(meta->skb)) {
-			b43dbg(dev->wl, "Poisoned TX slot %d (first=%d) "
-			       "on ring %d\n",
-			       slot, firstused, ring->index);
+			b43_dbg(dev->wl, "Poisoned TX slot %d (first=%d) on ring %d\n",
+				slot, firstused, ring->index);
 			break;
 		}
 		if (meta->skb) {
@@ -1446,9 +1443,9 @@ void b43_dma_handle_txstatus(struct b43_wldev *dev,
 			if (unlikely(!meta->skb)) {
 				/* This is a scatter-gather fragment of a frame, so
 				 * the skb pointer must not be NULL. */
-				b43dbg(dev->wl, "TX status unexpected NULL skb "
-				       "at slot %d (first=%d) on ring %d\n",
-				       slot, firstused, ring->index);
+				b43_dbg(dev->wl,
+					"TX status unexpected NULL skb at slot %d (first=%d) on ring %d\n",
+					slot, firstused, ring->index);
 				break;
 			}
 
@@ -1476,9 +1473,9 @@ void b43_dma_handle_txstatus(struct b43_wldev *dev,
 			 * this is only the txhdr, which is not allocated.
 			 */
 			if (unlikely(meta->skb)) {
-				b43dbg(dev->wl, "TX status unexpected non-NULL skb "
-				       "at slot %d (first=%d) on ring %d\n",
-				       slot, firstused, ring->index);
+				b43_dbg(dev->wl,
+					"TX status unexpected non-NULL skb at slot %d (first=%d) on ring %d\n",
+					slot, firstused, ring->index);
 				break;
 			}
 		}
@@ -1498,7 +1495,7 @@ void b43_dma_handle_txstatus(struct b43_wldev *dev,
 		ieee80211_wake_queue(dev->wl->hw, ring->queue_prio);
 		ring->stopped = 0;
 		if (b43_debug(dev, B43_DBG_DMAVERBOSE)) {
-			b43dbg(dev->wl, "Woke up TX ring %d\n", ring->index);
+			b43_dbg(dev->wl, "Woke up TX ring %d\n", ring->index);
 		}
 	}
 }
@@ -1537,7 +1534,7 @@ static void dma_rx(struct b43_dmaring *ring, int *slot)
 	if (unlikely(b43_rx_buffer_is_poisoned(ring, skb))) {
 		/* Something went wrong with the DMA.
 		 * The device did not touch the buffer and did not overwrite the poison. */
-		b43dbg(ring->dev->wl, "DMA RX: Dropping poisoned buffer.\n");
+		b43_dbg(ring->dev->wl, "DMA RX: Dropping poisoned buffer\n");
 		dmaaddr = meta->dmaaddr;
 		goto drop_recycle_buffer;
 	}
@@ -1562,16 +1559,16 @@ static void dma_rx(struct b43_dmaring *ring, int *slot)
 			if (tmp <= 0)
 				break;
 		}
-		b43err(ring->dev->wl, "DMA RX buffer too small "
-		       "(len: %u, buffer: %u, nr-dropped: %d)\n",
-		       len, ring->rx_buffersize, cnt);
+		b43_err(ring->dev->wl, "DMA RX buffer too small "
+			"(len: %u, buffer: %u, nr-dropped: %d)\n",
+			len, ring->rx_buffersize, cnt);
 		goto drop;
 	}
 
 	dmaaddr = meta->dmaaddr;
 	err = setup_rx_descbuffer(ring, desc, meta, GFP_ATOMIC);
 	if (unlikely(err)) {
-		b43dbg(ring->dev->wl, "DMA RX: setup_rx_descbuffer() failed\n");
+		b43_dbg(ring->dev->wl, "DMA RX: setup_rx_descbuffer() failed\n");
 		goto drop_recycle_buffer;
 	}
 
diff --git a/drivers/net/wireless/b43/leds.c b/drivers/net/wireless/b43/leds.c
index c587115..4bf526e 100644
--- a/drivers/net/wireless/b43/leds.c
+++ b/drivers/net/wireless/b43/leds.c
@@ -140,7 +140,7 @@ static int b43_register_led(struct b43_wldev *dev, struct b43_led *led,
 
 	err = led_classdev_register(dev->dev->dev, &led->led_dev);
 	if (err) {
-		b43warn(dev->wl, "LEDs: Failed to register %s\n", name);
+		b43_warn(dev->wl, "LEDs: Failed to register %s\n", name);
 		led->wl = NULL;
 		return err;
 	}
@@ -204,8 +204,8 @@ static void b43_map_led(struct b43_wldev *dev,
 				 led_index, activelow);
 		break;
 	default:
-		b43warn(dev->wl, "LEDs: Unknown behaviour 0x%02X\n",
-			behaviour);
+		b43_warn(dev->wl, "LEDs: Unknown behaviour 0x%02X\n",
+			 behaviour);
 		break;
 	}
 }
diff --git a/drivers/net/wireless/b43/lo.c b/drivers/net/wireless/b43/lo.c
index 94e4f13..c16c35c 100644
--- a/drivers/net/wireless/b43/lo.c
+++ b/drivers/net/wireless/b43/lo.c
@@ -62,8 +62,8 @@ static void b43_lo_write(struct b43_wldev *dev, struct b43_loctl *control)
 
 	if (B43_DEBUG) {
 		if (unlikely(abs(control->i) > 16 || abs(control->q) > 16)) {
-			b43dbg(dev->wl, "Invalid LO control pair "
-			       "(I: %d, Q: %d)\n", control->i, control->q);
+			b43_dbg(dev->wl, "Invalid LO control pair "
+				"(I: %d, Q: %d)\n", control->i, control->q);
 			dump_stack();
 			return;
 		}
@@ -775,15 +775,15 @@ struct b43_lo_calib *b43_calibrate_lo_setting(struct b43_wldev *dev,
 	b43_mac_enable(dev);
 
 	if (b43_debug(dev, B43_DBG_LO)) {
-		b43dbg(dev->wl, "LO: Calibrated for BB(%u), RF(%u,%u) "
-		       "=> I=%d Q=%d\n",
-		       bbatt->att, rfatt->att, rfatt->with_padmix,
-		       loctl.i, loctl.q);
+		b43_dbg(dev->wl, "LO: Calibrated for BB(%u), RF(%u,%u) "
+			"=> I=%d Q=%d\n",
+			bbatt->att, rfatt->att, rfatt->with_padmix,
+			loctl.i, loctl.q);
 	}
 
 	cal = kmalloc(sizeof(*cal), GFP_KERNEL);
 	if (!cal) {
-		b43warn(dev->wl, "LO calib: out of memory\n");
+		b43_warn(dev->wl, "LO calib: out of memory\n");
 		return NULL;
 	}
 	memcpy(&cal->bbatt, bbatt, sizeof(*bbatt));
@@ -857,8 +857,7 @@ void b43_gphy_dc_lt_init(struct b43_wldev *dev, bool update_all)
 
 		cal = b43_calibrate_lo_setting(dev, bbatt, rfatt);
 		if (!cal) {
-			b43warn(dev->wl, "LO: Could not "
-				"calibrate DC table entry\n");
+			b43_warn(dev->wl, "LO: Could not calibrate DC table entry\n");
 			continue;
 		}
 		/*FIXME: Is Q really in the low nibble? */
@@ -973,11 +972,11 @@ void b43_lo_g_maintanance_work(struct b43_wldev *dev)
 			current_item_expired = 1;
 		}
 		if (b43_debug(dev, B43_DBG_LO)) {
-			b43dbg(dev->wl, "LO: Item BB(%u), RF(%u,%u), "
-			       "I=%d, Q=%d expired\n",
-			       cal->bbatt.att, cal->rfatt.att,
-			       cal->rfatt.with_padmix,
-			       cal->ctl.i, cal->ctl.q);
+			b43_dbg(dev->wl, "LO: Item BB(%u), RF(%u,%u), "
+				"I=%d, Q=%d expired\n",
+				cal->bbatt.att, cal->rfatt.att,
+				cal->rfatt.with_padmix,
+				cal->ctl.i, cal->ctl.q);
 		}
 		list_del(&cal->list);
 		kfree(cal);
@@ -985,13 +984,13 @@ void b43_lo_g_maintanance_work(struct b43_wldev *dev)
 	if (current_item_expired || unlikely(list_empty(&lo->calib_list))) {
 		/* Recalibrate currently used LO setting. */
 		if (b43_debug(dev, B43_DBG_LO))
-			b43dbg(dev->wl, "LO: Recalibrating current LO setting\n");
+			b43_dbg(dev->wl, "LO: Recalibrating current LO setting\n");
 		cal = b43_calibrate_lo_setting(dev, &gphy->bbatt, &gphy->rfatt);
 		if (cal) {
 			list_add(&cal->list, &lo->calib_list);
 			b43_lo_write(dev, &cal->ctl);
 		} else
-			b43warn(dev->wl, "Failed to recalibrate current LO setting\n");
+			b43_warn(dev->wl, "Failed to recalibrate current LO setting\n");
 	}
 }
 
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 8031f24..6343873 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -331,13 +331,13 @@ void b43info(struct b43_wl *wl, const char *fmt, ...)
 	if (!b43_ratelimit(wl))
 		return;
 	va_start(args, fmt);
-	printk(KERN_INFO "b43-%s: ",
-	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan");
+	pr_info("b43-%s: ",
+		(wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan");
 	vprintk(fmt, args);
 	va_end(args);
 }
 
-void b43err(struct b43_wl *wl, const char *fmt, ...)
+void b43_err(struct b43_wl *wl, const char *fmt, ...)
 {
 	va_list args;
 
@@ -346,13 +346,13 @@ void b43err(struct b43_wl *wl, const char *fmt, ...)
 	if (!b43_ratelimit(wl))
 		return;
 	va_start(args, fmt);
-	printk(KERN_ERR "b43-%s ERROR: ",
+	pr_err("b43-%s ERROR: ",
 	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan");
 	vprintk(fmt, args);
 	va_end(args);
 }
 
-void b43warn(struct b43_wl *wl, const char *fmt, ...)
+void b43_warn(struct b43_wl *wl, const char *fmt, ...)
 {
 	va_list args;
 
@@ -361,13 +361,13 @@ void b43warn(struct b43_wl *wl, const char *fmt, ...)
 	if (!b43_ratelimit(wl))
 		return;
 	va_start(args, fmt);
-	printk(KERN_WARNING "b43-%s warning: ",
-	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan");
+	pr_warning("b43-%s warning: ",
+		   (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan");
 	vprintk(fmt, args);
 	va_end(args);
 }
 
-void b43dbg(struct b43_wl *wl, const char *fmt, ...)
+void b43_dbg(struct b43_wl *wl, const char *fmt, ...)
 {
 	va_list args;
 
@@ -840,7 +840,7 @@ static void rx_tkip_phase1_write(struct b43_wldev *dev, u8 index, u32 iv32,
 	B43_WARN_ON(index >= B43_NR_PAIRWISE_KEYS);
 
 	if (b43_debug(dev, B43_DBG_KEYS)) {
-		b43dbg(dev->wl, "rx_tkip_phase1_write : idx 0x%x, iv32 0x%x\n",
+		b43_dbg(dev->wl, "rx_tkip_phase1_write : idx 0x%x, iv32 0x%x\n",
 				index, iv32);
 	}
 	/* Write the key to the  RX tkip shared mem */
@@ -959,7 +959,7 @@ static int b43_key_write(struct b43_wldev *dev,
 			}
 		}
 		if (index < 0) {
-			b43warn(dev->wl, "Out of hardware key memory\n");
+			b43_warn(dev->wl, "Out of hardware key memory\n");
 			return -ENOSPC;
 		}
 	} else
@@ -1018,7 +1018,7 @@ static void b43_dump_keymemory(struct b43_wldev *dev)
 		return;
 
 	hf = b43_hf_read(dev);
-	b43dbg(dev->wl, "Hardware key memory dump:  USEDEFKEYS=%u\n",
+	b43_dbg(dev->wl, "Hardware key memory dump:  USEDEFKEYS=%u\n",
 	       !!(hf & B43_HF_USEDEFKEYS));
 	if (b43_new_kidx_api(dev)) {
 		pairwise_keys_start = B43_NR_GROUP_KEYS;
@@ -1034,20 +1034,20 @@ static void b43_dump_keymemory(struct b43_wldev *dev)
 		offset = dev->ktp + (index * B43_SEC_KEYSIZE);
 		for (i = 0; i < B43_SEC_KEYSIZE; i += 2) {
 			u16 tmp = b43_shm_read16(dev, B43_SHM_SHARED, offset + i);
-			printk("%02X%02X", (tmp & 0xFF), ((tmp >> 8) & 0xFF));
+			pr_cont("%02X%02X", (tmp & 0xFF), ((tmp >> 8) & 0xFF));
 		}
 
 		algo = b43_shm_read16(dev, B43_SHM_SHARED,
 				      B43_SHM_SH_KEYIDXBLOCK + (index * 2));
-		printk("   Algo: %04X/%02X", algo, key->algorithm);
+		pr_cont("   Algo: %04X/%02X", algo, key->algorithm);
 
 		if (index >= pairwise_keys_start) {
 			if (key->algorithm == B43_SEC_ALGO_TKIP) {
-				printk("   TKIP: ");
+				pr_cont("   TKIP: ");
 				offset = B43_SHM_SH_TKIPTSCTTAK + (index - 4) * (10 + 4);
 				for (i = 0; i < 14; i += 2) {
 					u16 tmp = b43_shm_read16(dev, B43_SHM_SHARED, offset + i);
-					printk("%02X%02X", (tmp & 0xFF), ((tmp >> 8) & 0xFF));
+					pr_cont("%02X%02X", (tmp & 0xFF), ((tmp >> 8) & 0xFF));
 				}
 			}
 			rcmta0 = b43_shm_read32(dev, B43_SHM_RCMTA,
@@ -1056,10 +1056,9 @@ static void b43_dump_keymemory(struct b43_wldev *dev)
 						((index - pairwise_keys_start) * 2) + 1);
 			*((__le32 *)(&mac[0])) = cpu_to_le32(rcmta0);
 			*((__le16 *)(&mac[4])) = cpu_to_le16(rcmta1);
-			printk("   MAC: %pM", mac);
+			pr_cont("   MAC: %pM\n", mac);
 		} else
-			printk("   DEFAULT KEY");
-		printk("\n");
+			pr_cont("   DEFAULT KEY\n");
 	}
 }
 
@@ -1511,7 +1510,7 @@ static void b43_write_beacon_template(struct b43_wldev *dev,
 		b43_shm_write16(dev, B43_SHM_SHARED,
 				B43_SHM_SH_DTIMPER, 0);
 	}
-	b43dbg(dev->wl, "Updated beacon template at 0x%x\n", ram_offset);
+	b43_dbg(dev->wl, "Updated beacon template at 0x%x\n", ram_offset);
 }
 
 static void b43_upload_beacon0(struct b43_wldev *dev)
@@ -1666,7 +1665,7 @@ static void b43_set_beacon_int(struct b43_wldev *dev, u16 beacon_int)
 		b43_write16(dev, 0x610, beacon_int);
 	}
 	b43_time_unlock(dev);
-	b43dbg(dev->wl, "Set beacon interval to %u\n", beacon_int);
+	b43_dbg(dev->wl, "Set beacon interval to %u\n", beacon_int);
 }
 
 static void b43_handle_firmware_panic(struct b43_wldev *dev)
@@ -1675,11 +1674,11 @@ static void b43_handle_firmware_panic(struct b43_wldev *dev)
 
 	/* Read the register that contains the reason code for the panic. */
 	reason = b43_shm_read16(dev, B43_SHM_SCRATCH, B43_FWPANIC_REASON_REG);
-	b43err(dev->wl, "Whoopsy, firmware panic! Reason: %u\n", reason);
+	b43_err(dev->wl, "Whoopsy, firmware panic! Reason: %u\n", reason);
 
 	switch (reason) {
 	default:
-		b43dbg(dev->wl, "The panic reason is unknown.\n");
+		b43_dbg(dev->wl, "The panic reason is unknown\n");
 		/* fallthrough */
 	case B43_FWPANIC_DIE:
 		/* Do not restart the controller or firmware.
@@ -1715,14 +1714,14 @@ static void handle_irq_ucode_debug(struct b43_wldev *dev)
 			break; /* Only with driver debugging enabled. */
 		buf = kmalloc(4096, GFP_ATOMIC);
 		if (!buf) {
-			b43dbg(dev->wl, "SHM-dump: Failed to allocate memory\n");
+			b43_dbg(dev->wl, "SHM-dump: Failed to allocate memory\n");
 			goto out;
 		}
 		for (i = 0; i < 4096; i += 2) {
 			u16 tmp = b43_shm_read16(dev, B43_SHM_SHARED, i);
 			buf[i / 2] = cpu_to_le16(tmp);
 		}
-		b43info(dev->wl, "Shared memory dump:\n");
+		b43_info(dev->wl, "Shared memory dump:\n");
 		print_hex_dump(KERN_INFO, "", DUMP_PREFIX_OFFSET,
 			       16, 2, buf, 4096, 1);
 		kfree(buf);
@@ -1730,19 +1729,20 @@ static void handle_irq_ucode_debug(struct b43_wldev *dev)
 	case B43_DEBUGIRQ_DUMP_REGS:
 		if (!B43_DEBUG)
 			break; /* Only with driver debugging enabled. */
-		b43info(dev->wl, "Microcode register dump:\n");
+		b43_info(dev->wl, "Microcode register dump:\n");
 		for (i = 0, cnt = 0; i < 64; i++) {
 			u16 tmp = b43_shm_read16(dev, B43_SHM_SCRATCH, i);
-			if (cnt == 0)
-				printk(KERN_INFO);
-			printk("r%02u: 0x%04X  ", i, tmp);
+			printk("%sr%02u: 0x%04X  ",
+			       cnt == 0 ? KERN_INFO : KERN_CONT,
+			       i, tmp);
 			cnt++;
 			if (cnt == 6) {
-				printk("\n");
+				pr_cont("\n");
 				cnt = 0;
 			}
 		}
-		printk("\n");
+		if (cnt)
+			pr_cont("\n");
 		break;
 	case B43_DEBUGIRQ_MARKER:
 		if (!B43_DEBUG)
@@ -1751,12 +1751,12 @@ static void handle_irq_ucode_debug(struct b43_wldev *dev)
 					   B43_MARKER_ID_REG);
 		marker_line = b43_shm_read16(dev, B43_SHM_SCRATCH,
 					     B43_MARKER_LINE_REG);
-		b43info(dev->wl, "The firmware just executed the MARKER(%u) "
+		b43_info(dev->wl, "The firmware just executed the MARKER(%u) "
 			"at line number %u\n",
 			marker_id, marker_line);
 		break;
 	default:
-		b43dbg(dev->wl, "Debug-IRQ triggered for unknown reason: %u\n",
+		b43_dbg(dev->wl, "Debug-IRQ triggered for unknown reason: %u\n",
 		       reason);
 	}
 out:
@@ -1782,15 +1782,15 @@ static void b43_do_interrupt_thread(struct b43_wldev *dev)
 	}
 
 	if (unlikely(reason & B43_IRQ_MAC_TXERR))
-		b43err(dev->wl, "MAC transmission error\n");
+		b43_err(dev->wl, "MAC transmission error\n");
 
 	if (unlikely(reason & B43_IRQ_PHY_TXERR)) {
-		b43err(dev->wl, "PHY transmission error\n");
+		b43_err(dev->wl, "PHY transmission error\n");
 		rmb();
 		if (unlikely(atomic_dec_and_test(&dev->phy.txerr_cnt))) {
 			atomic_set(&dev->phy.txerr_cnt,
 				   B43_PHY_TX_BADNESS_LIMIT);
-			b43err(dev->wl, "Too many PHY TX errors, "
+			b43_err(dev->wl, "Too many PHY TX errors, "
 					"restarting the controller\n");
 			b43_controller_restart(dev, "PHY TX errors");
 		}
@@ -1799,13 +1799,13 @@ static void b43_do_interrupt_thread(struct b43_wldev *dev)
 	if (unlikely(merged_dma_reason & (B43_DMAIRQ_FATALMASK |
 					  B43_DMAIRQ_NONFATALMASK))) {
 		if (merged_dma_reason & B43_DMAIRQ_FATALMASK) {
-			b43err(dev->wl, "Fatal DMA error: "
+			b43_err(dev->wl, "Fatal DMA error: "
 			       "0x%08X, 0x%08X, 0x%08X, "
 			       "0x%08X, 0x%08X, 0x%08X\n",
 			       dma_reason[0], dma_reason[1],
 			       dma_reason[2], dma_reason[3],
 			       dma_reason[4], dma_reason[5]);
-			b43err(dev->wl, "This device does not support DMA "
+			b43_err(dev->wl, "This device does not support DMA "
 			       "on your system. Please use PIO instead.\n");
 			/* Fall back to PIO transfers if we get fatal DMA errors! */
 			dev->use_pio = 1;
@@ -1813,7 +1813,7 @@ static void b43_do_interrupt_thread(struct b43_wldev *dev)
 			return;
 		}
 		if (merged_dma_reason & B43_DMAIRQ_NONFATALMASK) {
-			b43err(dev->wl, "DMA error: "
+			b43_err(dev->wl, "DMA error: "
 			       "0x%08X, 0x%08X, 0x%08X, "
 			       "0x%08X, 0x%08X, 0x%08X\n",
 			       dma_reason[0], dma_reason[1],
@@ -1978,15 +1978,15 @@ static void b43_release_firmware(struct b43_wldev *dev)
 static void b43_print_fw_helptext(struct b43_wl *wl, bool error)
 {
 	const char text[] =
-		"You must go to " \
-		"http://wireless.kernel.org/en/users/Drivers/b43#devicefirmware " \
-		"and download the correct firmware for this driver version. " \
+		"You must go to "
+		"http://wireless.kernel.org/en/users/Drivers/b43#devicefirmware "
+		"and download the correct firmware for this driver version. "
 		"Please carefully read all instructions on this website.\n";
 
 	if (error)
-		b43err(wl, text);
+		b43_err(wl, text);
 	else
-		b43warn(wl, text);
+		b43_warn(wl, text);
 }
 
 int b43_do_request_fw(struct b43_request_fw_context *ctx,
@@ -2072,7 +2072,7 @@ int b43_do_request_fw(struct b43_request_fw_context *ctx,
 err_format:
 	snprintf(ctx->errors[ctx->req_type],
 		 sizeof(ctx->errors[ctx->req_type]),
-		 "Firmware file \"%s\" format error.\n", ctx->fwname);
+		 "Firmware file \"%s\" format error\n", ctx->fwname);
 	release_firmware(blob);
 
 	return -EPROTO;
@@ -2211,19 +2211,19 @@ static int b43_try_request_fw(struct b43_request_fw_context *ctx)
 
 err_no_ucode:
 	err = ctx->fatal_failure = -EOPNOTSUPP;
-	b43err(dev->wl, "The driver does not know which firmware (ucode) "
+	b43_err(dev->wl, "The driver does not know which firmware (ucode) "
 	       "is required for your device (wl-core rev %u)\n", rev);
 	goto error;
 
 err_no_pcm:
 	err = ctx->fatal_failure = -EOPNOTSUPP;
-	b43err(dev->wl, "The driver does not know which firmware (PCM) "
+	b43_err(dev->wl, "The driver does not know which firmware (PCM) "
 	       "is required for your device (wl-core rev %u)\n", rev);
 	goto error;
 
 err_no_initvals:
 	err = ctx->fatal_failure = -EOPNOTSUPP;
-	b43err(dev->wl, "The driver does not know which firmware (initvals) "
+	b43_err(dev->wl, "The driver does not know which firmware (initvals) "
 	       "is required for your device (wl-core rev %u)\n", rev);
 	goto error;
 
@@ -2270,7 +2270,7 @@ static int b43_request_firmware(struct b43_wldev *dev)
 	for (i = 0; i < B43_NR_FWTYPES; i++) {
 		errmsg = ctx->errors[i];
 		if (strlen(errmsg))
-			b43err(dev->wl, errmsg);
+			b43_err(dev->wl, errmsg);
 	}
 	b43_print_fw_helptext(dev->wl, 1);
 	err = -ENOENT;
@@ -2339,7 +2339,7 @@ static int b43_upload_microcode(struct b43_wldev *dev)
 			break;
 		i++;
 		if (i >= 20) {
-			b43err(dev->wl, "Microcode not responding\n");
+			b43_err(dev->wl, "Microcode not responding\n");
 			b43_print_fw_helptext(dev->wl, 1);
 			err = -ENODEV;
 			goto error;
@@ -2355,7 +2355,7 @@ static int b43_upload_microcode(struct b43_wldev *dev)
 	fwtime = b43_shm_read16(dev, B43_SHM_SHARED, B43_SHM_SH_UCODETIME);
 
 	if (fwrev <= 0x128) {
-		b43err(dev->wl, "YOUR FIRMWARE IS TOO OLD. Firmware from "
+		b43_err(dev->wl, "YOUR FIRMWARE IS TOO OLD. Firmware from "
 		       "binary drivers older than version 4.x is unsupported. "
 		       "You must upgrade your firmware files.\n");
 		b43_print_fw_helptext(dev->wl, 1);
@@ -2377,17 +2377,17 @@ static int b43_upload_microcode(struct b43_wldev *dev)
 
 		/* Patchlevel info is encoded in the "time" field. */
 		dev->fw.patch = fwtime;
-		b43info(dev->wl, "Loading OpenSource firmware version %u.%u\n",
+		b43_info(dev->wl, "Loading OpenSource firmware version %u.%u\n",
 			dev->fw.rev, dev->fw.patch);
 
 		fwcapa = b43_fwcapa_read(dev);
 		if (!(fwcapa & B43_FWCAPA_HWCRYPTO) || dev->fw.pcm_request_failed) {
-			b43info(dev->wl, "Hardware crypto acceleration not supported by firmware\n");
+			b43_info(dev->wl, "Hardware crypto acceleration not supported by firmware\n");
 			/* Disable hardware crypto and fall back to software crypto. */
 			dev->hwcrypto_enabled = 0;
 		}
 		if (!(fwcapa & B43_FWCAPA_QOS)) {
-			b43info(dev->wl, "QoS not supported by firmware\n");
+			b43_info(dev->wl, "QoS not supported by firmware\n");
 			/* Disable QoS. Tweak hw->queues to 1. It will be restored before
 			 * ieee80211_unregister to make sure the networking core can
 			 * properly free possible resources. */
@@ -2395,13 +2395,13 @@ static int b43_upload_microcode(struct b43_wldev *dev)
 			dev->qos_enabled = 0;
 		}
 	} else {
-		b43info(dev->wl, "Loading firmware version %u.%u "
+		b43_info(dev->wl, "Loading firmware version %u.%u "
 			"(20%.2i-%.2i-%.2i %.2i:%.2i:%.2i)\n",
 			fwrev, fwpatch,
 			(fwdate >> 12) & 0xF, (fwdate >> 8) & 0xF, fwdate & 0xFF,
 			(fwtime >> 11) & 0x1F, (fwtime >> 5) & 0x3F, fwtime & 0x1F);
 		if (dev->fw.pcm_request_failed) {
-			b43warn(dev->wl, "No \"pcm5.fw\" firmware file found. "
+			b43_warn(dev->wl, "No \"pcm5.fw\" firmware file found. "
 				"Hardware accelerated cryptography is disabled.\n");
 			b43_print_fw_helptext(dev->wl, 0);
 		}
@@ -2410,7 +2410,7 @@ static int b43_upload_microcode(struct b43_wldev *dev)
 	if (b43_is_old_txhdr_format(dev)) {
 		/* We're over the deadline, but we keep support for old fw
 		 * until it turns out to be in major conflict with something new. */
-		b43warn(dev->wl, "You are using an old firmware image. "
+		b43_warn(dev->wl, "You are using an old firmware image. "
 			"Support for old firmware will be removed soon "
 			"(official deadline was July 2008).\n");
 		b43_print_fw_helptext(dev->wl, 0);
@@ -2482,7 +2482,7 @@ static int b43_write_initvals(struct b43_wldev *dev,
 	return 0;
 
 err_format:
-	b43err(dev->wl, "Initial Values Firmware file-format error.\n");
+	b43_err(dev->wl, "Initial Values Firmware file-format error\n");
 	b43_print_fw_helptext(dev->wl, 1);
 
 	return -EPROTO;
@@ -2594,7 +2594,7 @@ void b43_mac_enable(struct b43_wldev *dev)
 					 B43_SHM_SH_UCODESTAT);
 		if ((fwstate != B43_SHM_SH_UCODESTAT_SUSP) &&
 		    (fwstate != B43_SHM_SH_UCODESTAT_SLEEP)) {
-			b43err(dev->wl, "b43_mac_enable(): The firmware "
+			b43_err(dev->wl, "b43_mac_enable(): The firmware "
 			       "should be suspended, but current state is %u\n",
 			       fwstate);
 		}
@@ -2644,7 +2644,7 @@ void b43_mac_suspend(struct b43_wldev *dev)
 				goto out;
 			msleep(1);
 		}
-		b43err(dev->wl, "MAC suspend failed\n");
+		b43_err(dev->wl, "MAC suspend failed\n");
 	}
 out:
 	dev->mac_suspended++;
@@ -2892,7 +2892,7 @@ static int b43_chip_init(struct b43_wldev *dev)
 		    dev->dev->bus->chipco.fast_pwrup_delay);
 
 	err = 0;
-	b43dbg(dev->wl, "Chip initialized\n");
+	b43_dbg(dev->wl, "Chip initialized\n");
 out:
 	return err;
 
@@ -2928,7 +2928,7 @@ static void b43_periodic_every15sec(struct b43_wldev *dev)
 		 * It will reset the watchdog counter to 0 in its idle loop. */
 		wdr = b43_shm_read16(dev, B43_SHM_SCRATCH, B43_WATCHDOG_REG);
 		if (unlikely(wdr)) {
-			b43err(dev->wl, "Firmware watchdog: The firmware died!\n");
+			b43_err(dev->wl, "Firmware watchdog: The firmware died!\n");
 			b43_controller_restart(dev, "Firmware watchdog");
 			return;
 		} else {
@@ -2947,7 +2947,7 @@ static void b43_periodic_every15sec(struct b43_wldev *dev)
 	if (b43_debug(dev, B43_DBG_VERBOSESTATS)) {
 		unsigned int i;
 
-		b43dbg(dev->wl, "Stats: %7u IRQs/sec, %7u TX/sec, %7u RX/sec\n",
+		b43_dbg(dev->wl, "Stats: %7u IRQs/sec, %7u TX/sec, %7u RX/sec\n",
 		       dev->irq_count / 15,
 		       dev->tx_count / 15,
 		       dev->rx_count / 15);
@@ -2956,7 +2956,7 @@ static void b43_periodic_every15sec(struct b43_wldev *dev)
 		dev->rx_count = 0;
 		for (i = 0; i < ARRAY_SIZE(dev->irq_bit_count); i++) {
 			if (dev->irq_bit_count[i]) {
-				b43dbg(dev->wl, "Stats: %7u IRQ-%02u/sec (0x%08X)\n",
+				b43_dbg(dev->wl, "Stats: %7u IRQ-%02u/sec (0x%08X)\n",
 				       dev->irq_bit_count[i] / 15, i, (1 << i));
 				dev->irq_bit_count[i] = 0;
 			}
@@ -3041,13 +3041,13 @@ static int b43_validate_chipaccess(struct b43_wldev *dev)
 	b43_shm_write16(dev, B43_SHM_SHARED, 4, 0x5566);
 	b43_shm_write16(dev, B43_SHM_SHARED, 6, 0x7788);
 	if (b43_shm_read32(dev, B43_SHM_SHARED, 2) != 0x55663344)
-		b43warn(dev->wl, "Unaligned 32bit SHM read access is broken\n");
+		b43_warn(dev->wl, "Unaligned 32bit SHM read access is broken\n");
 	b43_shm_write32(dev, B43_SHM_SHARED, 2, 0xAABBCCDD);
 	if (b43_shm_read16(dev, B43_SHM_SHARED, 0) != 0x1122 ||
 	    b43_shm_read16(dev, B43_SHM_SHARED, 2) != 0xCCDD ||
 	    b43_shm_read16(dev, B43_SHM_SHARED, 4) != 0xAABB ||
 	    b43_shm_read16(dev, B43_SHM_SHARED, 6) != 0x7788)
-		b43warn(dev->wl, "Unaligned 32bit SHM write access is broken\n");
+		b43_warn(dev->wl, "Unaligned 32bit SHM write access is broken\n");
 
 	b43_shm_write32(dev, B43_SHM_SHARED, 0, backup0);
 	b43_shm_write32(dev, B43_SHM_SHARED, 4, backup4);
@@ -3071,7 +3071,7 @@ static int b43_validate_chipaccess(struct b43_wldev *dev)
 
 	return 0;
 error:
-	b43err(dev->wl, "Failed to validate the chipaccess\n");
+	b43_err(dev->wl, "Failed to validate the chipaccess\n");
 	return -ENODEV;
 }
 
@@ -3129,7 +3129,7 @@ static int b43_rng_init(struct b43_wl *wl)
 	err = hwrng_register(&wl->rng);
 	if (err) {
 		wl->rng_initialized = 0;
-		b43err(wl, "Failed to register the random "
+		b43_err(wl, "Failed to register the random "
 		       "number generator (%d)\n", err);
 	}
 #endif /* CONFIG_B43_HWRNG */
@@ -3310,7 +3310,7 @@ static void b43_qos_init(struct b43_wldev *dev)
 		b43_write16(dev, B43_MMIO_IFSCTL,
 			    b43_read16(dev, B43_MMIO_IFSCTL)
 			    & ~B43_MMIO_IFSCTL_USE_EDCF);
-		b43dbg(dev->wl, "QoS disabled\n");
+		b43_dbg(dev->wl, "QoS disabled\n");
 		return;
 	}
 
@@ -3322,7 +3322,7 @@ static void b43_qos_init(struct b43_wldev *dev)
 	b43_write16(dev, B43_MMIO_IFSCTL,
 		    b43_read16(dev, B43_MMIO_IFSCTL)
 		    | B43_MMIO_IFSCTL_USE_EDCF);
-	b43dbg(dev->wl, "QoS enabled\n");
+	b43_dbg(dev->wl, "QoS enabled\n");
 }
 
 static int b43_op_conf_tx(struct ieee80211_hw *hw, u16 _queue,
@@ -3471,7 +3471,7 @@ static int b43_switch_band(struct b43_wl *wl, struct ieee80211_channel *chan)
 			break;
 	}
 	if (!up_dev) {
-		b43err(wl, "Could not find a device for %s-GHz band operation\n",
+		b43_err(wl, "Could not find a device for %s-GHz band operation\n",
 		       band_to_string(chan->band));
 		return -ENODEV;
 	}
@@ -3480,7 +3480,7 @@ static int b43_switch_band(struct b43_wl *wl, struct ieee80211_channel *chan)
 		/* This device is already running. */
 		return 0;
 	}
-	b43dbg(wl, "Switching to %s-GHz band\n",
+	b43_dbg(wl, "Switching to %s-GHz band\n",
 	       band_to_string(chan->band));
 	down_dev = wl->current_dev;
 
@@ -3502,18 +3502,18 @@ static int b43_switch_band(struct b43_wl *wl, struct ieee80211_channel *chan)
 	if (prev_status >= B43_STAT_INITIALIZED) {
 		err = b43_wireless_core_init(up_dev);
 		if (err) {
-			b43err(wl, "Fatal: Could not initialize device for "
-			       "selected %s-GHz band\n",
-			       band_to_string(chan->band));
+			b43_err(wl, "Fatal: Could not initialize device for "
+				"selected %s-GHz band\n",
+				band_to_string(chan->band));
 			goto init_failure;
 		}
 	}
 	if (prev_status >= B43_STAT_STARTED) {
 		err = b43_wireless_core_start(up_dev);
 		if (err) {
-			b43err(wl, "Fatal: Coult not start device for "
-			       "selected %s-GHz band\n",
-			       band_to_string(chan->band));
+			b43_err(wl, "Fatal: Coult not start device for "
+				"selected %s-GHz band\n",
+				band_to_string(chan->band));
 			b43_wireless_core_exit(up_dev);
 			goto init_failure;
 		}
@@ -3604,15 +3604,15 @@ static int b43_op_config(struct ieee80211_hw *hw, u32 changed)
 	if (wl->radio_enabled != phy->radio_on) {
 		if (wl->radio_enabled) {
 			b43_software_rfkill(dev, false);
-			b43info(dev->wl, "Radio turned on by software\n");
+			b43_info(dev->wl, "Radio turned on by software\n");
 			if (!dev->radio_hw_enable) {
-				b43info(dev->wl, "The hardware RF-kill button "
-					"still turns the radio physically off. "
-					"Press the button to turn it on.\n");
+				b43_info(dev->wl, "The hardware RF-kill button "
+					 "still turns the radio physically off. "
+					 "Press the button to turn it on.\n");
 			}
 		} else {
 			b43_software_rfkill(dev, true);
-			b43info(dev->wl, "Radio turned off by software\n");
+			b43_info(dev->wl, "Radio turned off by software\n");
 		}
 	}
 
@@ -3827,10 +3827,10 @@ static int b43_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 
 out_unlock:
 	if (!err) {
-		b43dbg(wl, "%s hardware based encryption for keyidx: %d, "
-		       "mac: %pM\n",
-		       cmd == SET_KEY ? "Using" : "Disabling", key->keyidx,
-		       sta ? sta->addr : bcast_addr);
+		b43_dbg(wl, "%s hardware based encryption for keyidx: %d, "
+			"mac: %pM\n",
+			cmd == SET_KEY ? "Using" : "Disabling", key->keyidx,
+			sta ? sta->addr : bcast_addr);
 		b43_dump_keymemory(dev);
 	}
 	mutex_unlock(&wl->mutex);
@@ -3940,7 +3940,7 @@ redo:
 
 	b43_mac_suspend(dev);
 	b43_leds_exit(dev);
-	b43dbg(wl, "Wireless interface stopped\n");
+	b43_dbg(wl, "Wireless interface stopped\n");
 
 	return dev;
 }
@@ -3956,7 +3956,7 @@ static int b43_wireless_core_start(struct b43_wldev *dev)
 	if (dev->dev->bus->bustype == SSB_BUSTYPE_SDIO) {
 		err = b43_sdio_request_irq(dev, b43_sdio_interrupt_handler);
 		if (err) {
-			b43err(dev->wl, "Cannot request SDIO IRQ\n");
+			b43_err(dev->wl, "Cannot request SDIO IRQ\n");
 			goto out;
 		}
 	} else {
@@ -3964,7 +3964,8 @@ static int b43_wireless_core_start(struct b43_wldev *dev)
 					   b43_interrupt_thread_handler,
 					   IRQF_SHARED, KBUILD_MODNAME, dev);
 		if (err) {
-			b43err(dev->wl, "Cannot request IRQ-%d\n", dev->dev->irq);
+			b43_err(dev->wl, "Cannot request IRQ-%d\n",
+				dev->dev->irq);
 			goto out;
 		}
 	}
@@ -3982,7 +3983,7 @@ static int b43_wireless_core_start(struct b43_wldev *dev)
 
 	b43_leds_init(dev);
 
-	b43dbg(dev->wl, "Wireless interface started\n");
+	b43_dbg(dev->wl, "Wireless interface started\n");
 out:
 	return err;
 }
@@ -4035,13 +4036,12 @@ static int b43_phy_versioning(struct b43_wldev *dev)
 		unsupported = 1;
 	};
 	if (unsupported) {
-		b43err(dev->wl, "FOUND UNSUPPORTED PHY "
-		       "(Analog %u, Type %u, Revision %u)\n",
-		       analog_type, phy_type, phy_rev);
+		b43_err(dev->wl, "FOUND UNSUPPORTED PHY (Analog %u, Type %u, Revision %u)\n",
+			analog_type, phy_type, phy_rev);
 		return -EOPNOTSUPP;
 	}
-	b43dbg(dev->wl, "Found PHY: Analog %u, Type %u, Revision %u\n",
-	       analog_type, phy_type, phy_rev);
+	b43_dbg(dev->wl, "Found PHY: Analog %u, Type %u, Revision %u\n",
+		analog_type, phy_type, phy_rev);
 
 	/* Get RADIO versioning */
 	if (dev->dev->bus->chip_id == 0x4317) {
@@ -4091,13 +4091,13 @@ static int b43_phy_versioning(struct b43_wldev *dev)
 		B43_WARN_ON(1);
 	}
 	if (unsupported) {
-		b43err(dev->wl, "FOUND UNSUPPORTED RADIO "
-		       "(Manuf 0x%X, Version 0x%X, Revision %u)\n",
-		       radio_manuf, radio_ver, radio_rev);
+		b43_err(dev->wl, "FOUND UNSUPPORTED RADIO "
+			"(Manuf 0x%X, Version 0x%X, Revision %u)\n",
+			radio_manuf, radio_ver, radio_rev);
 		return -EOPNOTSUPP;
 	}
-	b43dbg(dev->wl, "Found Radio: Manuf 0x%X, Version 0x%X, Revision %u\n",
-	       radio_manuf, radio_ver, radio_rev);
+	b43_dbg(dev->wl, "Found Radio: Manuf 0x%X, Version 0x%X, Revision %u\n",
+		radio_manuf, radio_ver, radio_rev);
 
 	phy->radio_manuf = radio_manuf;
 	phy->radio_ver = radio_ver;
@@ -4412,7 +4412,7 @@ static int b43_op_add_interface(struct ieee80211_hw *hw,
 	if (wl->operating)
 		goto out_mutex_unlock;
 
-	b43dbg(wl, "Adding Interface type %d\n", vif->type);
+	b43_dbg(wl, "Adding Interface type %d\n", vif->type);
 
 	dev = wl->current_dev;
 	wl->operating = 1;
@@ -4438,7 +4438,7 @@ static void b43_op_remove_interface(struct ieee80211_hw *hw,
 	struct b43_wl *wl = hw_to_b43_wl(hw);
 	struct b43_wldev *dev = wl->current_dev;
 
-	b43dbg(wl, "Removing Interface type %d\n", vif->type);
+	b43_dbg(wl, "Removing Interface type %d\n", vif->type);
 
 	mutex_lock(&wl->mutex);
 
@@ -4656,9 +4656,9 @@ out:
 		wl->current_dev = NULL; /* Failed to init the dev. */
 	mutex_unlock(&wl->mutex);
 	if (err)
-		b43err(wl, "Controller restart FAILED\n");
+		b43_err(wl, "Controller restart FAILED\n");
 	else
-		b43info(wl, "Controller restarted\n");
+		b43_info(wl, "Controller restarted\n");
 }
 
 static int b43_setup_bands(struct b43_wldev *dev,
@@ -4708,7 +4708,7 @@ static int b43_wireless_core_attach(struct b43_wldev *dev)
 
 	err = ssb_bus_powerup(bus, 0);
 	if (err) {
-		b43err(wl, "Bus powerup failed\n");
+		b43_err(wl, "Bus powerup failed\n");
 		goto out;
 	}
 	/* Get the PHY type. */
@@ -4754,7 +4754,7 @@ static int b43_wireless_core_attach(struct b43_wldev *dev)
 	}
 	if (dev->phy.type == B43_PHYTYPE_A) {
 		/* FIXME */
-		b43err(wl, "IEEE 802.11a devices are unsupported\n");
+		b43_err(wl, "IEEE 802.11a devices are unsupported\n");
 		err = -EOPNOTSUPP;
 		goto err_powerdown;
 	}
@@ -4836,7 +4836,7 @@ static int b43_one_core_attach(struct ssb_device *dev, struct b43_wl *wl)
 		if (!pdev ||
 		    ((pdev->device != 0x4321) &&
 		     (pdev->device != 0x4313) && (pdev->device != 0x431A))) {
-			b43dbg(wl, "Ignoring unconnected 802.11 core\n");
+			b43_dbg(wl, "Ignoring unconnected 802.11 core\n");
 			return -ENODEV;
 		}
 	}
@@ -4918,7 +4918,7 @@ static int b43_wireless_init(struct ssb_device *dev)
 
 	hw = ieee80211_alloc_hw(sizeof(*wl), &b43_hw_ops);
 	if (!hw) {
-		b43err(NULL, "Could not allocate ieee80211 device\n");
+		b43_err(NULL, "Could not allocate ieee80211 device\n");
 		goto out;
 	}
 	wl = hw_to_b43_wl(hw);
@@ -4954,8 +4954,8 @@ static int b43_wireless_init(struct ssb_device *dev)
 	skb_queue_head_init(&wl->tx_queue);
 
 	ssb_set_devtypedata(dev, wl);
-	b43info(wl, "Broadcom %04X WLAN found (core revision %u)\n",
-		dev->bus->chip_id, dev->id.revision);
+	b43_info(wl, "Broadcom %04X WLAN found (core revision %u)\n",
+		 dev->bus->chip_id, dev->id.revision);
 	err = 0;
 out:
 	return err;
@@ -5037,7 +5037,7 @@ void b43_controller_restart(struct b43_wldev *dev, const char *reason)
 	/* Must avoid requeueing, if we are in shutdown. */
 	if (b43_status(dev) < B43_STAT_INITIALIZED)
 		return;
-	b43info(dev->wl, "Controller RESET (%s) ...\n", reason);
+	b43_info(dev->wl, "Controller RESET (%s) ...\n", reason);
 	ieee80211_queue_work(dev->wl->hw, &dev->restart_work);
 }
 
@@ -5068,11 +5068,11 @@ static void b43_print_driverinfo(void)
 #ifdef CONFIG_B43_SDIO
 	feat_sdio = "S";
 #endif
-	printk(KERN_INFO "Broadcom 43xx driver loaded "
-	       "[ Features: %s%s%s%s%s, Firmware-ID: "
-	       B43_SUPPORTED_FIRMWARE_ID " ]\n",
-	       feat_pci, feat_pcmcia, feat_nphy,
-	       feat_leds, feat_sdio);
+	pr_info("Broadcom 43xx driver loaded "
+		"[ Features: %s%s%s%s%s, Firmware-ID: "
+		B43_SUPPORTED_FIRMWARE_ID " ]\n",
+		feat_pci, feat_pcmcia, feat_nphy,
+		feat_leds, feat_sdio);
 }
 
 static int __init b43_init(void)
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index 0e99b63..9dafa68 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -117,8 +117,7 @@ err_disable:
 err_kfree_ssb:
 	kfree(ssb);
 out_error:
-	printk(KERN_ERR "b43-pcmcia: Initialization failed (%d, %d)\n",
-	       res, err);
+	pr_err("b43-pcmcia: Initialization failed (%d, %d)\n", res, err);
 	return err;
 }
 
diff --git a/drivers/net/wireless/b43/phy_a.c b/drivers/net/wireless/b43/phy_a.c
index b6428ec..11062b7 100644
--- a/drivers/net/wireless/b43/phy_a.c
+++ b/drivers/net/wireless/b43/phy_a.c
@@ -344,8 +344,7 @@ static int b43_aphy_init_tssi2dbm_table(struct b43_wldev *dev)
 		/* pabX values not set in SPROM,
 		 * but APHY needs a generated table. */
 		aphy->tssi2dbm = NULL;
-		b43err(dev->wl, "Could not generate tssi2dBm "
-		       "table (wrong SPROM info)!\n");
+		b43_err(dev->wl, "Could not generate tssi2dBm table (wrong SPROM info)!\n");
 		return -ENODEV;
 	}
 
@@ -427,14 +426,14 @@ static inline u16 adjust_phyreg(struct b43_wldev *dev, u16 offset)
 #if B43_DEBUG
 	if ((offset & B43_PHYROUTE) == B43_PHYROUTE_EXT_GPHY) {
 		/* Ext-G registers are only available on G-PHYs */
-		b43err(dev->wl, "Invalid EXT-G PHY access at "
-		       "0x%04X on A-PHY\n", offset);
+		b43_err(dev->wl, "Invalid EXT-G PHY access at "
+			"0x%04X on A-PHY\n", offset);
 		dump_stack();
 	}
 	if ((offset & B43_PHYROUTE) == B43_PHYROUTE_N_BMODE) {
 		/* N-BMODE registers are only available on N-PHYs */
-		b43err(dev->wl, "Invalid N-BMODE PHY access at "
-		       "0x%04X on A-PHY\n", offset);
+		b43_err(dev->wl, "Invalid N-BMODE PHY access at "
+			"0x%04X on A-PHY\n", offset);
 		dump_stack();
 	}
 #endif /* B43_DEBUG */
diff --git a/drivers/net/wireless/b43/phy_common.c b/drivers/net/wireless/b43/phy_common.c
index 8f7d7ef..128ffff 100644
--- a/drivers/net/wireless/b43/phy_common.c
+++ b/drivers/net/wireless/b43/phy_common.c
@@ -87,14 +87,14 @@ int b43_phy_init(struct b43_wldev *dev)
 	ops->software_rfkill(dev, false);
 	err = ops->init(dev);
 	if (err) {
-		b43err(dev->wl, "PHY init failed\n");
+		b43_err(dev->wl, "PHY init failed\n");
 		goto err_block_rf;
 	}
 	/* Make sure to switch hardware and firmware (SHM) to
 	 * the default channel. */
 	err = b43_switch_channel(dev, ops->get_default_chan(dev));
 	if (err) {
-		b43err(dev->wl, "PHY init: Channel switch to default failed\n");
+		b43_err(dev->wl, "PHY init: Channel switch to default failed\n");
 		goto err_phy_exit;
 	}
 
@@ -192,8 +192,7 @@ static inline void assert_mac_suspended(struct b43_wldev *dev)
 		return;
 	if ((b43_status(dev) >= B43_STAT_INITIALIZED) &&
 	    (dev->mac_suspended <= 0)) {
-		b43dbg(dev->wl, "PHY/RADIO register access with "
-		       "enabled MAC.\n");
+		b43_dbg(dev->wl, "PHY/RADIO register access with enabled MAC\n");
 		dump_stack();
 	}
 }
diff --git a/drivers/net/wireless/b43/phy_g.c b/drivers/net/wireless/b43/phy_g.c
index 29bf34c..acadae6 100644
--- a/drivers/net/wireless/b43/phy_g.c
+++ b/drivers/net/wireless/b43/phy_g.c
@@ -237,10 +237,10 @@ static void b43_set_txpower_g(struct b43_wldev *dev,
 	memmove(&gphy->bbatt, bbatt, sizeof(*bbatt));
 
 	if (b43_debug(dev, B43_DBG_XMITPOWER)) {
-		b43dbg(dev->wl, "Tuning TX-power to bbatt(%u), "
-		       "rfatt(%u), tx_control(0x%02X), "
-		       "tx_bias(0x%02X), tx_magn(0x%02X)\n",
-		       bb, rf, tx_control, tx_bias, tx_magn);
+		b43_dbg(dev->wl, "Tuning TX-power to bbatt(%u), "
+			"rfatt(%u), tx_control(0x%02X), "
+			"tx_bias(0x%02X), tx_magn(0x%02X)\n",
+			bb, rf, tx_control, tx_bias, tx_magn);
 	}
 
 	b43_gphy_set_baseband_attenuation(dev, bb);
@@ -1970,11 +1970,12 @@ static void b43_phy_init_pctl(struct b43_wldev *dev)
 		if (B43_DEBUG) {
 			/* Current-Idle-TSSI sanity check. */
 			if (abs(gphy->cur_idle_tssi - gphy->tgt_idle_tssi) >= 20) {
-				b43dbg(dev->wl,
-				       "!WARNING! Idle-TSSI phy->cur_idle_tssi "
-				       "measuring failed. (cur=%d, tgt=%d). Disabling TX power "
-				       "adjustment.\n", gphy->cur_idle_tssi,
-				       gphy->tgt_idle_tssi);
+				b43_dbg(dev->wl,
+					"!WARNING! Idle-TSSI phy->cur_idle_tssi "
+					"measuring failed. (cur=%d, tgt=%d). "
+					"Disabling TX power adjustment.\n",
+					gphy->cur_idle_tssi,
+					gphy->tgt_idle_tssi);
 				gphy->cur_idle_tssi = 0;
 			}
 		}
@@ -2360,15 +2361,13 @@ u8 *b43_generate_dyn_tssi2dbm_tab(struct b43_wldev *dev,
 
 	tab = kmalloc(64, GFP_KERNEL);
 	if (!tab) {
-		b43err(dev->wl, "Could not allocate memory "
-		       "for tssi2dbm table\n");
+		b43_err(dev->wl, "Could not allocate memory for tssi2dbm table\n");
 		return NULL;
 	}
 	for (i = 0; i < 64; i++) {
 		err = b43_tssi2dbm_entry(tab, i, pab0, pab1, pab2);
 		if (err) {
-			b43err(dev->wl, "Could not generate "
-			       "tssi2dBm table\n");
+			b43_err(dev->wl, "Could not generate tssi2dBm table\n");
 			kfree(tab);
 			return NULL;
 		}
@@ -2864,7 +2863,7 @@ static void b43_gphy_op_adjust_txpower(struct b43_wldev *dev)
 	gphy->bbatt.att = bbatt;
 
 	if (b43_debug(dev, B43_DBG_XMITPOWER))
-		b43dbg(dev->wl, "Adjusting TX power\n");
+		b43_dbg(dev->wl, "Adjusting TX power\n");
 
 	/* Adjust the hardware */
 	b43_phy_lock(dev);
@@ -2918,8 +2917,7 @@ static enum b43_txpwr_result b43_gphy_op_recalc_txpower(struct b43_wldev *dev,
 	if (dev->dev->bus->sprom.boardflags_lo & B43_BFL_PACTRL)
 		max_pwr -= 3; /* minus 0.75 */
 	if (unlikely(max_pwr >= INT_TO_Q52(30/*dBm*/))) {
-		b43warn(dev->wl,
-			"Invalid max-TX-power value in SPROM.\n");
+		b43_warn(dev->wl, "Invalid max-TX-power value in SPROM\n");
 		max_pwr = INT_TO_Q52(20); /* fake it */
 		dev->dev->bus->sprom.maxpwr_bg = max_pwr;
 	}
@@ -2932,13 +2930,13 @@ static enum b43_txpwr_result b43_gphy_op_recalc_txpower(struct b43_wldev *dev,
 	/* And limit it. max_pwr already is Q5.2 */
 	desired_pwr = clamp_val(desired_pwr, 0, max_pwr);
 	if (b43_debug(dev, B43_DBG_XMITPOWER)) {
-		b43dbg(dev->wl,
-		       "[TX power]  current = " Q52_FMT
-		       " dBm,  desired = " Q52_FMT
-		       " dBm,  max = " Q52_FMT "\n",
-		       Q52_ARG(estimated_pwr),
-		       Q52_ARG(desired_pwr),
-		       Q52_ARG(max_pwr));
+		b43_dbg(dev->wl,
+			"[TX power]  current = " Q52_FMT
+			" dBm,  desired = " Q52_FMT
+			" dBm,  max = " Q52_FMT "\n",
+			Q52_ARG(estimated_pwr),
+			Q52_ARG(desired_pwr),
+			Q52_ARG(max_pwr));
 	}
 
 	/* Calculate the adjustment delta. */
@@ -2962,11 +2960,11 @@ static enum b43_txpwr_result b43_gphy_op_recalc_txpower(struct b43_wldev *dev,
 #if B43_DEBUG
 	if (b43_debug(dev, B43_DBG_XMITPOWER)) {
 		int dbm = pwr_adjust < 0 ? -pwr_adjust : pwr_adjust;
-		b43dbg(dev->wl,
-		       "[TX power deltas]  %s" Q52_FMT " dBm   =>   "
-		       "bbatt-delta = %d,  rfatt-delta = %d\n",
-		       (pwr_adjust < 0 ? "-" : ""), Q52_ARG(dbm),
-		       bbatt_delta, rfatt_delta);
+		b43_dbg(dev->wl,
+			"[TX power deltas]  %s" Q52_FMT " dBm   =>   "
+			"bbatt-delta = %d,  rfatt-delta = %d\n",
+			(pwr_adjust < 0 ? "-" : ""), Q52_ARG(dbm),
+			bbatt_delta, rfatt_delta);
 	}
 #endif /* DEBUG */
 
diff --git a/drivers/net/wireless/b43/phy_lp.c b/drivers/net/wireless/b43/phy_lp.c
index c6afe9d..2b706a8 100644
--- a/drivers/net/wireless/b43/phy_lp.c
+++ b/drivers/net/wireless/b43/phy_lp.c
@@ -594,8 +594,9 @@ static void lpphy_2062_init(struct b43_wldev *dev)
 	}
 	if (!fd)
 		fd = &freqdata_tab[ARRAY_SIZE(freqdata_tab) - 1];
-	b43dbg(dev->wl, "b2062: Using crystal tab entry %u kHz.\n",
-	       fd->freq); /* FIXME: Keep this printk until the code is fully debugged. */
+
+	/* FIXME: Keep this printk until the code is fully debugged. */
+	b43_dbg(dev->wl, "b2062: Using crystal tab entry %u kHz\n", fd->freq);
 
 	b43_radio_write(dev, B2062_S_RFPLL_CTL8,
 			((u16)(fd->data[1]) << 4) | fd->data[0]);
@@ -1210,9 +1211,9 @@ static void lpphy_rev0_1_rc_calib(struct b43_wldev *dev)
 
 	err = b43_lpphy_op_switch_channel(dev, 7);
 	if (err) {
-		b43dbg(dev->wl,
-		       "RC calib: Failed to switch to channel 7, error = %d\n",
-		       err);
+		b43_dbg(dev->wl,
+			"RC calib: Failed to switch to channel 7, error = %d\n",
+			err);
 	}
 	old_txg_ovr = !!(b43_phy_read(dev, B43_LPPHY_AFE_CTL_OVR) & 0x40);
 	old_bbmult = lpphy_get_bb_mult(dev);
@@ -1590,7 +1591,7 @@ static void lpphy_pr41573_workaround(struct b43_wldev *dev)
 
 	saved_tab = kcalloc(saved_tab_size, sizeof(saved_tab[0]), GFP_KERNEL);
 	if (!saved_tab) {
-		b43err(dev->wl, "PR41573 failed. Out of memory!\n");
+		b43_err(dev->wl, "PR41573 failed. Out of memory!\n");
 		return;
 	}
 
@@ -2676,8 +2677,8 @@ static int b43_lpphy_op_init(struct b43_wldev *dev)
 	lpphy_calibrate_rc(dev);
 	err = b43_lpphy_op_switch_channel(dev, 7);
 	if (err) {
-		b43dbg(dev->wl, "Switch to channel 7 failed, error = %d.\n",
-		       err);
+		b43_dbg(dev->wl, "Switch to channel 7 failed, error = %d\n",
+			err);
 	}
 	lpphy_tx_pctl_init(dev);
 	lpphy_calibration(dev);
diff --git a/drivers/net/wireless/b43/phy_n.c b/drivers/net/wireless/b43/phy_n.c
index 3d6b337..3da6b59 100644
--- a/drivers/net/wireless/b43/phy_n.c
+++ b/drivers/net/wireless/b43/phy_n.c
@@ -221,7 +221,7 @@ static void b43_radio_init2055_post(struct b43_wldev *dev)
 		udelay(10);
 	}
 	if (i)
-		b43err(dev->wl, "radio post init timeout\n");
+		b43_err(dev->wl, "radio post init timeout\n");
 	b43_radio_mask(dev, B2055_CAL_LPOCTL, 0xFF7F);
 	nphy_channel_switch(dev, dev->phy.channel);
 	b43_radio_write(dev, B2055_C1_RX_BB_LPF, 0x9);
@@ -1139,7 +1139,7 @@ static int b43_nphy_load_samples(struct b43_wldev *dev,
 
 	data = kzalloc(len * sizeof(u32), GFP_KERNEL);
 	if (!data) {
-		b43err(dev->wl, "allocation for samples loading failed\n");
+		b43_err(dev->wl, "allocation for samples loading failed\n");
 		return -ENOMEM;
 	}
 	if (nphy->hang_avoid)
@@ -1183,7 +1183,7 @@ static u16 b43_nphy_gen_load_samples(struct b43_wldev *dev, u32 freq, u16 max,
 
 	samples = kzalloc(len * sizeof(struct b43_c32), GFP_KERNEL);
 	if (!samples) {
-		b43err(dev->wl, "allocation for samples generation failed\n");
+		b43_err(dev->wl, "allocation for samples generation failed\n");
 		return 0;
 	}
 	rot = (((freq * 36) / bw) << 16) / 100;
@@ -1256,7 +1256,7 @@ static void b43_nphy_run_samples(struct b43_wldev *dev, u16 samps, u16 loops,
 		udelay(10);
 	}
 	if (i)
-		b43err(dev->wl, "run samples timeout\n");
+		b43_err(dev->wl, "run samples timeout\n");
 
 	b43_phy_write(dev, B43_NPHY_RFSEQMODE, seq_mode);
 }
@@ -1391,7 +1391,7 @@ static void b43_nphy_force_rf_sequence(struct b43_wldev *dev,
 			goto ok;
 		msleep(1);
 	}
-	b43err(dev->wl, "RF sequence status timeout\n");
+	b43_err(dev->wl, "RF sequence status timeout\n");
 ok:
 	b43_phy_write(dev, B43_NPHY_RFSEQMODE, seq_mode);
 }
@@ -1410,7 +1410,7 @@ static void b43_nphy_rf_control_override(struct b43_wldev *dev, u16 field,
 		const struct nphy_rf_control_override_rev3 *rf_ctrl;
 		for (i = 0; i < 2; i++) {
 			if (index == 0 || index == 16) {
-				b43err(dev->wl,
+				b43_err(dev->wl,
 					"Unsupported RF Ctrl Override call\n");
 				return;
 			}
@@ -1445,7 +1445,7 @@ static void b43_nphy_rf_control_override(struct b43_wldev *dev, u16 field,
 
 		for (i = 0; i < 2; i++) {
 			if (index <= 1 || index == 16) {
-				b43err(dev->wl,
+				b43_err(dev->wl,
 					"Unsupported RF Ctrl Override call\n");
 				return;
 			}
@@ -1511,7 +1511,7 @@ static void b43_nphy_rf_control_intc_override(struct b43_wldev *dev, u8 field,
 					udelay(10);
 				}
 				if (j)
-					b43err(dev->wl,
+					b43_err(dev->wl,
 						"intc override timeout\n");
 				b43_phy_mask(dev, B43_NPHY_TXF_40CO_B1S1,
 						0xFFFE);
@@ -1530,7 +1530,7 @@ static void b43_nphy_rf_control_intc_override(struct b43_wldev *dev, u8 field,
 					udelay(10);
 				}
 				if (j)
-					b43err(dev->wl,
+					b43_err(dev->wl,
 						"intc override timeout\n");
 				b43_phy_mask(dev, B43_NPHY_RFCTL_OVER,
 						0xFFFE);
@@ -3265,7 +3265,7 @@ int b43_phy_initn(struct b43_wldev *dev)
 	if (phy->rev >= 3)
 		b43_nphy_spur_workaround(dev);
 
-	b43err(dev->wl, "IEEE 802.11n devices are not supported, yet.\n");
+	b43_err(dev->wl, "IEEE 802.11n devices are not supported yet\n");
 	return 0;
 }
 
@@ -3437,14 +3437,14 @@ static inline void check_phyreg(struct b43_wldev *dev, u16 offset)
 #if B43_DEBUG
 	if ((offset & B43_PHYROUTE) == B43_PHYROUTE_OFDM_GPHY) {
 		/* OFDM registers are onnly available on A/G-PHYs */
-		b43err(dev->wl, "Invalid OFDM PHY access at "
-		       "0x%04X on N-PHY\n", offset);
+		b43_err(dev->wl, "Invalid OFDM PHY access at "
+			"0x%04X on N-PHY\n", offset);
 		dump_stack();
 	}
 	if ((offset & B43_PHYROUTE) == B43_PHYROUTE_EXT_GPHY) {
 		/* Ext-G registers are only available on G-PHYs */
-		b43err(dev->wl, "Invalid EXT-G PHY access at "
-		       "0x%04X on N-PHY\n", offset);
+		b43_err(dev->wl, "Invalid EXT-G PHY access at "
+			"0x%04X on N-PHY\n", offset);
 		dump_stack();
 	}
 #endif /* B43_DEBUG */
@@ -3491,7 +3491,7 @@ static void b43_nphy_op_software_rfkill(struct b43_wldev *dev,
 	struct b43_phy_n *nphy = dev->phy.n;
 
 	if (b43_read32(dev, B43_MMIO_MACCTL) & B43_MACCTL_ENABLED)
-		b43err(dev->wl, "MAC not suspended\n");
+		b43_err(dev->wl, "MAC not suspended\n");
 
 	if (blocked) {
 		b43_phy_mask(dev, B43_NPHY_RFCTL_CMD,
diff --git a/drivers/net/wireless/b43/pio.c b/drivers/net/wireless/b43/pio.c
index aa12273..3a7b487 100644
--- a/drivers/net/wireless/b43/pio.c
+++ b/drivers/net/wireless/b43/pio.c
@@ -278,7 +278,7 @@ int b43_pio_init(struct b43_wldev *dev)
 	if (!pio->rx_queue)
 		goto err_destroy_mcast;
 
-	b43dbg(dev->wl, "PIO initialized\n");
+	b43_dbg(dev->wl, "PIO initialized\n");
 	err = 0;
 out:
 	return err;
@@ -525,12 +525,12 @@ int b43_pio_tx(struct b43_wldev *dev, struct sk_buff *skb)
 
 	if (unlikely(total_len > q->buffer_size)) {
 		err = -ENOBUFS;
-		b43dbg(dev->wl, "PIO: TX packet longer than queue.\n");
+		b43_dbg(dev->wl, "PIO: TX packet longer than queue\n");
 		goto out;
 	}
 	if (unlikely(q->free_packet_slots == 0)) {
 		err = -ENOBUFS;
-		b43warn(dev->wl, "PIO: TX packet overflow.\n");
+		b43_warn(dev->wl, "PIO: TX packet overflow\n");
 		goto out;
 	}
 	B43_WARN_ON(q->buffer_used > q->buffer_size);
@@ -557,7 +557,7 @@ int b43_pio_tx(struct b43_wldev *dev, struct sk_buff *skb)
 		goto out;
 	}
 	if (unlikely(err)) {
-		b43err(dev->wl, "PIO transmission failure\n");
+		b43_err(dev->wl, "PIO transmission failure\n");
 		goto out;
 	}
 
@@ -651,7 +651,7 @@ static bool pio_rx_frame(struct b43_pio_rxqueue *q)
 			udelay(10);
 		}
 	}
-	b43dbg(q->dev->wl, "PIO RX timed out\n");
+	b43_dbg(q->dev->wl, "PIO RX timed out\n");
 	return 1;
 data_ready:
 
@@ -745,7 +745,7 @@ data_ready:
 
 rx_error:
 	if (err_msg)
-		b43dbg(q->dev->wl, "PIO RX error: %s\n", err_msg);
+		b43_dbg(q->dev->wl, "PIO RX error: %s\n", err_msg);
 	if (q->rev >= 8)
 		b43_piorx_write32(q, B43_PIO8_RXCTL, B43_PIO8_RXCTL_DATARDY);
 	else
diff --git a/drivers/net/wireless/b43/rfkill.c b/drivers/net/wireless/b43/rfkill.c
index 78016ae..2a532a3 100644
--- a/drivers/net/wireless/b43/rfkill.c
+++ b/drivers/net/wireless/b43/rfkill.c
@@ -70,8 +70,8 @@ void b43_rfkill_poll(struct ieee80211_hw *hw)
 
 	if (unlikely(enabled != dev->radio_hw_enable)) {
 		dev->radio_hw_enable = enabled;
-		b43info(wl, "Radio hardware status changed to %s\n",
-			enabled ? "ENABLED" : "DISABLED");
+		b43_info(wl, "Radio hardware status changed to %s\n",
+			 enabled ? "ENABLED" : "DISABLED");
 		wiphy_rfkill_set_hw_state(hw->wiphy, !enabled);
 		if (enabled != dev->phy.radio_on)
 			b43_software_rfkill(dev, !enabled);
diff --git a/drivers/net/wireless/b43/sysfs.c b/drivers/net/wireless/b43/sysfs.c
index f1ae4e0..b949e91 100644
--- a/drivers/net/wireless/b43/sysfs.c
+++ b/drivers/net/wireless/b43/sysfs.c
@@ -123,8 +123,7 @@ static ssize_t b43_attr_interfmode_store(struct device *dev,
 	if (wldev->phy.ops->interf_mitigation) {
 		err = wldev->phy.ops->interf_mitigation(wldev, mode);
 		if (err) {
-			b43err(wldev->wl, "Interference Mitigation not "
-			       "supported by device\n");
+			b43_err(wldev->wl, "Interference Mitigation not supported by device\n");
 		}
 	} else
 		err = -ENOSYS;
diff --git a/drivers/net/wireless/b43/xmit.c b/drivers/net/wireless/b43/xmit.c
index e6b0528..3e416f3 100644
--- a/drivers/net/wireless/b43/xmit.c
+++ b/drivers/net/wireless/b43/xmit.c
@@ -573,14 +573,14 @@ void b43_rx(struct b43_wldev *dev, struct sk_buff *skb, const void *_rxhdr)
 	/* Skip PLCP and padding */
 	padding = (macstat & B43_RX_MAC_PADDING) ? 2 : 0;
 	if (unlikely(skb->len < (sizeof(struct b43_plcp_hdr6) + padding))) {
-		b43dbg(dev->wl, "RX: Packet size underrun (1)\n");
+		b43_dbg(dev->wl, "RX: Packet size underrun (1)\n");
 		goto drop;
 	}
 	plcp = (struct b43_plcp_hdr6 *)(skb->data + padding);
 	skb_pull(skb, sizeof(struct b43_plcp_hdr6) + padding);
 	/* The skb contains the Wireless Header + payload data now */
 	if (unlikely(skb->len < (2 + 2 + 6 /*minimum hdr */  + FCS_LEN))) {
-		b43dbg(dev->wl, "RX: Packet size underrun (2)\n");
+		b43_dbg(dev->wl, "RX: Packet size underrun (2)\n");
 		goto drop;
 	}
 	wlhdr = (struct ieee80211_hdr *)(skb->data);
@@ -601,8 +601,8 @@ void b43_rx(struct b43_wldev *dev, struct sk_buff *skb, const void *_rxhdr)
 		if (dev->key[keyidx].algorithm != B43_SEC_ALGO_NONE) {
 			wlhdr_len = ieee80211_hdrlen(fctl);
 			if (unlikely(skb->len < (wlhdr_len + 3))) {
-				b43dbg(dev->wl,
-				       "RX: Packet size underrun (3)\n");
+				b43_dbg(dev->wl,
+					"RX: Packet size underrun (3)\n");
 				goto drop;
 			}
 			status.flag |= RX_FLAG_DECRYPTED;
@@ -695,7 +695,7 @@ void b43_rx(struct b43_wldev *dev, struct sk_buff *skb, const void *_rxhdr)
 #endif
 	return;
 drop:
-	b43dbg(dev->wl, "RX: Packet dropped\n");
+	b43_dbg(dev->wl, "RX: Packet dropped\n");
 	dev_kfree_skb_any(skb);
 }
 
-- 
1.7.1.337.g6068.dirty

