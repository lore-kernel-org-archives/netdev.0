From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [RFC 2/2] ixgbe: netmap support
Date: Fri, 19 Apr 2013 12:09:35 -0700
Message-ID: <20130419120935.2ba12c24@nehalam.linuxnetplumber.net>
References: <20130419120651.4e646976@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:33675 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753406Ab3DSTKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 15:10:17 -0400
Received: by mail-da0-f45.google.com with SMTP id v40so2076571dad.32
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 12:10:16 -0700 (PDT)
In-Reply-To: <20130419120651.4e646976@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Integrate netmap support with Intel 10G driver.
Direct port of patch from original; still needs work to be up
to meet Linux coding standards.

Awkward to have staging stuff in a non-staging driver, no real way
to work around that problem.

Loads and runs, but not fully functional at this point.


Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c         |   47 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_netmap_linux.h |  548 ++++++++++++++++++
 2 files changed, 595 insertions(+)

--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c	2013-04-19 10:36:28.258060048 -0700
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c	2013-04-19 10:36:44.777846396 -0700
@@ -248,6 +248,22 @@ static const struct ixgbe_reg_info ixgbe
 	{}
 };
 
+#if defined(CONFIG_NETMAP) || defined(CONFIG_NETMAP_MODULE)
+/*
+ * The #ifdef DEV_NETMAP / #endif blocks in this file are meant to
+ * be a reference on how to implement netmap support in a driver.
+ * Additional comments are in ixgbe_netmap_linux.h .
+ *
+ * The code is originally developed on FreeBSD and in the interest
+ * of maintainability we try to limit differences between the two systems.
+ *
+ * <ixgbe_netmap_linux.h> contains functions for netmap support
+ * that extend the standard driver.
+ * It also defines DEV_NETMAP so further conditional sections use
+ * that instead of CONFIG_NETMAP
+ */
+#include "ixgbe_netmap_linux.h"
+#endif
 
 /*
  * ixgbe_regdump - register printout routine
@@ -872,6 +888,17 @@ static bool ixgbe_clean_tx_irq(struct ix
 	if (test_bit(__IXGBE_DOWN, &adapter->state))
 		return true;
 
+#ifdef DEV_NETMAP
+	/*
+	 * In netmap mode, all the work is done in the context
+	 * of the client thread. Interrupt handlers only wake up
+	 * clients, which may be sleeping on individual rings
+	 * or on a global resource for all rings.
+	 */
+	if (netmap_tx_irq(adapter->netdev, tx_ring->queue_index))
+		return 1; /* seems to be ignored */
+#endif /* DEV_NETMAP */
+
 	tx_buffer = &tx_ring->tx_buffer_info[i];
 	tx_desc = IXGBE_TX_DESC(tx_ring, i);
 	i -= tx_ring->count;
@@ -1906,6 +1933,15 @@ static bool ixgbe_clean_rx_irq(struct ix
 #endif /* IXGBE_FCOE */
 	u16 cleaned_count = ixgbe_desc_unused(rx_ring);
 
+#ifdef DEV_NETMAP
+	/*
+	 * 	 Same as the txeof routine: only wakeup clients on intr.
+	 */
+	int dummy;
+	if (netmap_rx_irq(rx_ring->netdev, rx_ring->queue_index, &dummy))
+		return true; /* no more interrupts */
+#endif /* DEV_NETMAP */
+
 	do {
 		union ixgbe_adv_rx_desc *rx_desc;
 		struct sk_buff *skb;
@@ -2892,6 +2928,9 @@ void ixgbe_configure_tx_ring(struct ixgb
 	} while (--wait_loop && !(txdctl & IXGBE_TXDCTL_ENABLE));
 	if (!wait_loop)
 		e_err(drv, "Could not enable Tx Queue %d\n", reg_idx);
+#ifdef DEV_NETMAP
+	ixgbe_netmap_configure_tx_ring(adapter, reg_idx);
+#endif /* DEV_NETMAP */
 }
 
 static void ixgbe_setup_mtqc(struct ixgbe_adapter *adapter)
@@ -3253,6 +3292,10 @@ void ixgbe_configure_rx_ring(struct ixgb
 	IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(reg_idx), rxdctl);
 
 	ixgbe_rx_desc_queue_enable(adapter, ring);
+#ifdef DEV_NETMAP
+	if (ixgbe_netmap_configure_rx_ring(adapter, reg_idx))
+		return;
+#endif /* DEV_NETMAP */
 	ixgbe_alloc_rx_buffers(ring, ixgbe_desc_unused(ring));
 }
 
@@ -5022,6 +5065,10 @@ static int ixgbe_open(struct net_device
 
 	ixgbe_up_complete(adapter);
 
+#ifdef DEV_NETMAP
+	ixgbe_netmap_attach(adapter);
+#endif /* DEV_NETMAP */
+
 	return 0;
 
 err_set_queues:
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_netmap_linux.h	2013-04-19 10:36:44.777846396 -0700
@@ -0,0 +1,549 @@
+/*
+ * Copyright (C) 2012 Matteo Landi, Luigi Rizzo. All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
+ * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
+ * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
+ * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
+ * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
+ * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
+ * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
+ * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
+ * SUCH DAMAGE.
+ */
+
+/*
+ * $FreeBSD: head/sys/dev/netmap/ixgbe_netmap.h 230572 2012-01-26 09:55:16Z luigi $
+ * $Id: ixgbe_netmap_linux.h 10670 2012-02-27 21:15:38Z luigi $
+ *
+ * netmap support for ixgbe (LINUX version)
+ *
+ * supports N TX and RX queues, separate locks, hw crc strip,
+ * address rewrite in txsync
+ *
+ * This file is meant to be a reference on how to implement
+ * netmap support for a network driver.
+ * This file contains code but only static or inline functions
+ * that are used by a single driver. To avoid replication of
+ * code we just #include it near the beginning of the
+ * standard driver.
+ */
+
+
+#include <netmap/bsd_glue.h>
+#include <netmap/netmap.h>
+#include <netmap/netmap_kern.h>
+
+/*
+ * Adaptation to various version of the driver.
+ * Recent drivers (3.4 and above) redefine some macros
+ */
+#ifndef	IXGBE_TX_DESC_ADV
+#define	IXGBE_TX_DESC_ADV	IXGBE_TX_DESC
+#define	IXGBE_RX_DESC_ADV	IXGBE_RX_DESC
+#endif
+
+/*
+ * Register/unregister. We are already under core lock.
+ * Only called on the first register or the last unregister.
+ */
+static int
+ixgbe_netmap_reg(struct ifnet *ifp, int onoff)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(ifp);
+	struct netmap_adapter *na = NA(ifp);
+	int error = 0;
+
+	if (na == NULL)
+		return EINVAL;	/* no netmap support here */
+
+	// XXX do a reinit_locked or something else ?
+	/* Tell the stack that the interface is no longer active */
+	while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
+		usleep_range(1000, 2000);
+
+	ixgbe_down(adapter);
+
+	if (onoff) { /* enable netmap mode */
+		ifp->if_capenable |= IFCAP_NETMAP;
+
+		/* save if_transmit and replace with our routine */
+		na->if_transmit = (void *)ifp->netdev_ops;
+		ifp->netdev_ops = &na->nm_ndo;
+
+		/*
+		 * reinitialize the adapter, now with netmap flag set,
+		 * so the rings will be set accordingly.
+		 */
+		ixgbe_up(adapter);
+		pr_info("ixgbe netmap enabled\n");
+
+	} else { /* reset normal mode (explicit request or netmap failed) */
+		/* restore if_transmit */
+		ifp->netdev_ops = (void *)na->if_transmit;
+		ifp->if_capenable &= ~IFCAP_NETMAP;
+		/* initialize the card, this time in standard mode */
+		ixgbe_up(adapter);	/* also enables intr */
+		pr_info("ixgbe netmap disabled\n");
+	}
+
+	clear_bit(__IXGBE_RESETTING, &adapter->state);
+	return (error);
+}
+
+
+/*
+ * Reconcile kernel and user view of the transmit ring.
+ * This routine might be called frequently so it must be efficient.
+ *
+ * Userspace has filled tx slots up to ring->cur (excluded).
+ * The last unused slot previously known to the kernel was kring->nkr_hwcur,
+ * and the last interrupt reported kring->nr_hwavail slots available.
+ *
+ * This function runs under lock (acquired from the caller or internally).
+ * It must first update ring->avail to what the kernel knows,
+ * subtract the newly used slots (ring->cur - kring->nkr_hwcur)
+ * from both avail and nr_hwavail, and set ring->nkr_hwcur = ring->cur
+ * issuing a dmamap_sync on all slots.
+ *
+ * Since ring comes from userspace, its content must be read only once,
+ * and validated before being used to update the kernel's structures.
+ * (this is also true for every use of ring in the kernel).
+ *
+ * ring->avail is never used, only checked for bogus values.
+ *
+ * do_lock is set iff the function is called from the ioctl handler.
+ * In this case, grab a lock around the body, and also reclaim transmitted
+ * buffers irrespective of interrupt mitigation.
+ */
+static int
+ixgbe_netmap_txsync(struct ifnet *ifp, u_int ring_nr, int do_lock)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(ifp);
+	struct ixgbe_ring *txr = adapter->tx_ring[ring_nr];
+	struct netmap_adapter *na = NA(ifp);
+	struct netmap_kring *kring = &na->tx_rings[ring_nr];
+	struct netmap_ring *ring = kring->ring;
+	u_int j, k = ring->cur, l, n, lim = kring->nkr_num_slots - 1;
+
+	/*
+	 * ixgbe can generate an interrupt on every tx packet, but it
+	 * seems very expensive, so we interrupt once every half ring,
+	 * or when requested with NS_REPORT
+	 */
+	int report_frequency = kring->nkr_num_slots >> 1;
+
+	/* if cur is invalid reinitialize the ring. */
+	if (k > lim)
+		return netmap_ring_reinit(kring);
+	if (do_lock)
+		mtx_lock(&kring->q_lock);
+
+	/*
+	 * Process new packets to send. j is the current index in the
+	 * netmap ring, l is the corresponding index in the NIC ring.
+	 * The two numbers differ because upon a *_init() we reset
+	 * the NIC ring but leave the netmap ring unchanged.
+	 * For the transmit ring, we have
+	 *
+	 *		j = kring->nr_hwcur
+	 *		l = IXGBE_TDT (not tracked in the driver)
+	 * and
+	 * 		j == (l + kring->nkr_hwofs) % ring_size
+	 *
+	 * In this driver kring->nkr_hwofs >= 0, but for other
+	 * drivers it might be negative as well.
+	 */
+	j = kring->nr_hwcur;
+	if (j != k) {	/* we have new packets to send */
+		l = netmap_idx_k2n(kring, j);
+		for (n = 0; j != k; n++) {
+			/*
+			 * Collect per-slot info.
+			 * Note that txbuf and curr are indexed by l.
+			 *
+			 * In this driver we collect the buffer address
+			 * (using the PNMB() macro) because we always
+			 * need to rewrite it into the NIC ring.
+			 * Many other drivers preserve the address, so
+			 * we only need to access it if NS_BUF_CHANGED
+			 * is set.
+			 */
+			struct netmap_slot *slot = &ring->slot[j];
+			union ixgbe_adv_tx_desc *curr = IXGBE_TX_DESC_ADV(txr, l);
+			uint64_t paddr;
+			void *addr = PNMB(slot, &paddr);
+			// XXX type for flags and len ?
+			int flags = ((slot->flags & NS_REPORT) ||
+				j == 0 || j == report_frequency) ?
+					IXGBE_TXD_CMD_RS : 0;
+			u_int len = slot->len;
+
+			/*
+			 * Quick check for valid addr and len.
+			 * NMB() returns netmap_buffer_base for invalid
+			 * buffer indexes (but the address is still a
+			 * valid one to be used in a ring). slot->len is
+			 * unsigned so no need to check for negative values.
+			 */
+			if (addr == netmap_buffer_base || len > NETMAP_BUF_SIZE) {
+ring_reset:
+				if (do_lock)
+					mtx_unlock(&kring->q_lock);
+				return netmap_ring_reinit(kring);
+			}
+
+			slot->flags &= ~NS_REPORT;
+			if (slot->flags & NS_BUF_CHANGED) {
+				/* buffer has changed, unload and reload map */
+				// netmap_reload_map(pdev, DMA_TO_DEVICE, old_addr, addr);
+				slot->flags &= ~NS_BUF_CHANGED;
+			}
+			/*
+			 * Fill the slot in the NIC ring.
+			 * In this driver we need to rewrite the buffer
+			 * address in the NIC ring. Other drivers do not
+			 * need this.
+			 */
+			curr->read.buffer_addr = htole64(paddr);
+			curr->read.olinfo_status = htole32(len << IXGBE_ADVTXD_PAYLEN_SHIFT);
+			curr->read.cmd_type_len =
+			    htole32( len |
+				(IXGBE_ADVTXD_DTYP_DATA |
+				    IXGBE_ADVTXD_DCMD_DEXT |
+				    IXGBE_ADVTXD_DCMD_IFCS |
+				    IXGBE_TXD_CMD_EOP | flags) );
+			j = (j == lim) ? 0 : j + 1;
+			l = (l == lim) ? 0 : l + 1;
+		}
+		kring->nr_hwcur = k; /* the saved ring->cur */
+		/* decrease avail by number of packets  sent */
+		kring->nr_hwavail -= n;
+
+		wmb();	/* synchronize writes to the NIC ring */
+		/* (re)start the transmitter up to slot l (excluded) */
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_TDT(txr->reg_idx), l);
+	}
+
+	/*
+	 * Reclaim buffers for completed transmissions.
+	 * Because this is expensive (we read a NIC register etc.)
+	 * we only do it in specific cases (see below).
+	 * In all cases kring->nr_kflags indicates which slot will be
+	 * checked upon a tx interrupt (nkr_num_slots means none).
+	 */
+	if (do_lock) {
+		j = 1; /* forced reclaim, ignore interrupts */
+		kring->nr_kflags = kring->nkr_num_slots;
+	} else if (kring->nr_hwavail > 0) {
+		j = 0; /* buffers still available: no reclaim, ignore intr. */
+		kring->nr_kflags = kring->nkr_num_slots;
+	} else {
+		/*
+		 * no buffers available, locate a slot for which we request
+		 * ReportStatus (approximately half ring after next_to_clean)
+		 * and record it in kring->nr_kflags.
+		 * If the slot has DD set, do the reclaim looking at TDH,
+		 * otherwise we go to sleep (in netmap_poll()) and will be
+		 * woken up when slot nr_kflags will be ready.
+		 */
+		union ixgbe_adv_tx_desc *txd = IXGBE_TX_DESC_ADV(txr, 0);
+
+		j = txr->next_to_clean + kring->nkr_num_slots/2;
+		if (j >= kring->nkr_num_slots)
+			j -= kring->nkr_num_slots;
+		// round to the closest with dd set
+		j= (j < kring->nkr_num_slots / 4 || j >= kring->nkr_num_slots*3/4) ?
+			0 : report_frequency;
+		kring->nr_kflags = j; /* the slot to check */
+		j = txd[j].wb.status & IXGBE_TXD_STAT_DD;	// XXX cpu_to_le32 ?
+	}
+	if (j) {
+		int delta;
+
+		/*
+		 * Record completed transmissions.
+		 * We (re)use the driver's txr->next_to_clean to keep
+		 * track of the most recently completed transmission.
+		 *
+		 * The datasheet discourages the use of TDH to find out the
+		 * number of sent packets. We should rather check the DD
+		 * status bit in a packet descriptor. However, we only set
+		 * the "report status" bit for some descriptors (a kind of
+		 * interrupt mitigation), so we can only check on those.
+		 * For the time being we use TDH, as we do it infrequently
+		 * enough not to pose performance problems.
+		 */
+		l = IXGBE_READ_REG(&adapter->hw, IXGBE_TDH(ring_nr));
+		if (l >= kring->nkr_num_slots) { /* XXX can happen */
+			D("TDH wrap %d", l);
+			l -= kring->nkr_num_slots;
+		}
+		delta = l - txr->next_to_clean;
+		if (delta) {
+			/* some tx completed, increment hwavail. */
+			if (delta < 0)
+				delta += kring->nkr_num_slots;
+			txr->next_to_clean = l;
+			kring->nr_hwavail += delta;
+			if (kring->nr_hwavail > lim)
+				goto ring_reset;
+		}
+	}
+	/* update avail to what the kernel knows */
+	ring->avail = kring->nr_hwavail;
+
+	if (do_lock)
+		mtx_unlock(&kring->q_lock);
+	return 0;
+}
+
+
+/*
+ * Reconcile kernel and user view of the receive ring.
+ * Same as for the txsync, this routine must be efficient and
+ * avoid races in accessing the shared regions.
+ *
+ * When called, userspace has read data from slots kring->nr_hwcur
+ * up to ring->cur (excluded).
+ *
+ * The last interrupt reported kring->nr_hwavail slots available
+ * after kring->nr_hwcur.
+ * We must subtract the newly consumed slots (cur - nr_hwcur)
+ * from nr_hwavail, make the descriptors available for the next reads,
+ * and set kring->nr_hwcur = ring->cur and ring->avail = kring->nr_hwavail.
+ *
+ * do_lock has a special meaning: please refer to txsync.
+ */
+static int
+ixgbe_netmap_rxsync(struct ifnet *ifp, u_int ring_nr, int do_lock)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(ifp);
+	struct ixgbe_ring *rxr = adapter->rx_ring[ring_nr];
+	struct netmap_adapter *na = NA(ifp);
+	struct netmap_kring *kring = &na->rx_rings[ring_nr];
+	struct netmap_ring *ring = kring->ring;
+	u_int j, l, n, lim = kring->nkr_num_slots - 1;
+	int force_update = do_lock || kring->nr_kflags & NKR_PENDINTR;
+	u_int k = ring->cur, resvd = ring->reserved;
+
+	if (k > lim) /* userspace is cheating */
+		return netmap_ring_reinit(kring);
+
+	if (do_lock)
+		mtx_lock(&kring->q_lock);
+	rmb();
+	/*
+	 * First part, import newly received packets into the netmap ring.
+	 *
+	 * j is the index of the next free slot in the netmap ring,
+	 * and l is the index of the next received packet in the NIC ring,
+	 * and they may differ in case if_init() has been called while
+	 * in netmap mode. For the receive ring we have
+	 *
+	 *	j = (kring->nr_hwcur + kring->nr_hwavail) % ring_size
+	 *	l = rxr->next_to_check;
+	 * and
+	 *	j == (l + kring->nkr_hwofs) % ring_size
+	 *
+	 * rxr->next_to_check is set to 0 on a ring reinit
+	 */
+	l = rxr->next_to_clean;
+	j = netmap_idx_n2k(kring, l);
+
+	if (netmap_no_pendintr || force_update) {
+		for (n = 0; ; n++) {
+			union ixgbe_adv_rx_desc *curr = IXGBE_RX_DESC_ADV(rxr, l);
+			uint32_t staterr = le32toh(curr->wb.upper.status_error);
+
+			if ((staterr & IXGBE_RXD_STAT_DD) == 0)
+				break;
+			ring->slot[j].len = le16toh(curr->wb.upper.length);
+			ring->slot[j].flags = NS_FORWARD;
+			j = (j == lim) ? 0 : j + 1;
+			l = (l == lim) ? 0 : l + 1;
+		}
+		if (n) { /* update the state variables */
+			rxr->next_to_clean = l;
+			kring->nr_hwavail += n;
+		}
+		kring->nr_kflags &= ~NKR_PENDINTR;
+	}
+
+	/*
+	 * Skip past packets that userspace has already released
+	 * (from kring->nr_hwcur to ring->cur-ring->reserved excluded),
+	 * and make the buffers available for reception.
+	 * As usual j is the index in the netmap ring, l is the index
+	 * in the NIC ring, and j == (l + kring->nkr_hwofs) % ring_size
+	 */
+	j = kring->nr_hwcur; /* netmap ring index */
+	if (resvd > 0) {
+		if (resvd + ring->avail >= lim + 1) {
+			D("XXX invalid reserve/avail %d %d", resvd, ring->avail);
+			ring->reserved = resvd = 0; // XXX panic...
+		}
+		k = (k >= resvd) ? k - resvd : k + lim + 1 - resvd;
+	}
+	if (j != k) { /* userspace has released some packets. */
+		l = netmap_idx_k2n(kring, j);
+		for (n = 0; j != k; n++) {
+			/* collect per-slot info, with similar validations
+			 * and flag handling as in the txsync code.
+			 *
+			 * NOTE curr and rxbuf are indexed by l.
+			 * Also, this driver needs to update the physical
+			 * address in the NIC ring, but other drivers
+			 * may not have this requirement.
+			 */
+			struct netmap_slot *slot = &ring->slot[j];
+			union ixgbe_adv_rx_desc *curr = IXGBE_RX_DESC_ADV(rxr, l);
+			uint64_t paddr;
+			void *addr = PNMB(slot, &paddr);
+
+			if (addr == netmap_buffer_base) /* bad buf */
+				goto ring_reset;
+
+			if (slot->flags & NS_BUF_CHANGED) {
+				// netmap_reload_map(pdev, DMA_TO_DEVICE, old_addr, addr);
+				slot->flags &= ~NS_BUF_CHANGED;
+			}
+			curr->wb.upper.status_error = 0;
+			curr->read.pkt_addr = htole64(paddr);
+			j = (j == lim) ? 0 : j + 1;
+			l = (l == lim) ? 0 : l + 1;
+		}
+		kring->nr_hwavail -= n;
+		kring->nr_hwcur = k;
+		rxr->next_to_use = l; // XXX not really used
+		wmb();
+		/* IMPORTANT: we must leave one free slot in the ring,
+		 * so move l back by one unit
+		 */
+		l = (l == 0) ? lim : l - 1;
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_RDT(rxr->reg_idx), l);
+	}
+	/* tell userspace that there are new packets */
+	ring->avail = kring->nr_hwavail - resvd;
+
+	if (do_lock)
+		mtx_unlock(&kring->q_lock);
+	return 0;
+
+ring_reset:
+	if (do_lock)
+		mtx_unlock(&kring->q_lock);
+	return netmap_ring_reinit(kring);
+}
+
+
+/*
+ * if in netmap mode, attach the netmap buffers to the ring and return true.
+ * Otherwise return false.
+ */
+static int
+ixgbe_netmap_configure_tx_ring(struct ixgbe_adapter *adapter, int ring_nr)
+{
+	struct netmap_adapter *na = NA(adapter->netdev);
+	struct netmap_slot *slot = netmap_reset(na, NR_TX, ring_nr, 0);
+	//int j;
+
+	if (!slot)
+		return 0;	// not in netmap;
+#if 0
+	/*
+	 * on a generic card we should set the address in the slot.
+	 * But on the ixgbe, the address needs to be rewritten
+	 * after a transmission so there is nothing do to except
+	 * loading the map.
+	 */
+	for (j = 0; j < na->num_tx_desc; j++) {
+		int sj = netmap_idx_n2k(&na->tx_rings[ring_nr], j);
+		uint64_t paddr;
+		void *addr = PNMB(slot + sj, &paddr);
+	}
+#endif
+	return 1;
+}
+
+
+static int
+ixgbe_netmap_configure_rx_ring(struct ixgbe_adapter *adapter, int ring_nr)
+{
+	/*
+	 * In netmap mode, we must preserve the buffers made
+	 * available to userspace before the if_init()
+	 * (this is true by default on the TX side, because
+	 * init makes all buffers available to userspace).
+	 *
+	 * netmap_reset() and the device specific routines
+	 * (e.g. ixgbe_setup_receive_rings()) map these
+	 * buffers at the end of the NIC ring, so here we
+	 * must set the RDT (tail) register to make sure
+	 * they are not overwritten.
+	 *
+	 * In this driver the NIC ring starts at RDH = 0,
+	 * RDT points to the last slot available for reception (?),
+	 * so RDT = num_rx_desc - 1 means the whole ring is available.
+	 */
+	struct netmap_adapter *na = NA(adapter->netdev);
+	struct netmap_slot *slot = netmap_reset(na, NR_RX, ring_nr, 0);
+	int lim, i;
+	struct ixgbe_ring *ring = adapter->rx_ring[ring_nr];
+        /* same as in ixgbe_setup_transmit_ring() */
+	if (!slot)
+		return 0;	// not in netmap;
+
+	lim = na->num_rx_desc - 1 - na->rx_rings[ring_nr].nr_hwavail;
+
+	for (i = 0; i < na->num_rx_desc; i++) {
+		/*
+		 * Fill the map and set the buffer address in the NIC ring,
+		 * considering the offset between the netmap and NIC rings
+		 * (see comment in ixgbe_setup_transmit_ring() ).
+		 */
+		int si = netmap_idx_n2k(&na->rx_rings[ring_nr], i);
+		uint64_t paddr;
+		PNMB(slot + si, &paddr);
+		// netmap_load_map(rxr->ptag, rxbuf->pmap, addr);
+		/* Update descriptor */
+		IXGBE_RX_DESC_ADV(ring, i)->read.pkt_addr = htole64(paddr);
+	}
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RDT(ring_nr), lim);
+	return 1;
+}
+
+
+/*
+ * The attach routine, called near the end of ixgbe_attach(),
+ * fills the parameters for netmap_attach() and calls it.
+ * It cannot fail, in the worst case (such as no memory)
+ * netmap mode will be disabled and the driver will only
+ * operate in standard mode.
+ */
+static void
+ixgbe_netmap_attach(struct ixgbe_adapter *adapter)
+{
+	struct netmap_adapter na = {
+		.ifp = adapter->netdev,
+		.separate_locks = 0,	/* this card has separate rx/tx locks */
+		.num_tx_desc = adapter->tx_ring[0]->count,
+		.num_rx_desc = adapter->rx_ring[0]->count,
+		.nm_txsync = ixgbe_netmap_txsync,
+		.nm_rxsync = ixgbe_netmap_rxsync,
+		.nm_register = ixgbe_netmap_reg,
+	};
+
+	netmap_attach(&na, adapter->num_tx_queues);
+}
