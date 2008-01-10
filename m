From: linux@horizon.com
Subject: ipg.c bugs
Date: 10 Jan 2008 02:28:09 -0500
Message-ID: <20080110072809.1473.qmail@science.horizon.com>
References: <20080109233056.GA5673@electric-eye.fr.zoreil.com>
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: linux@horizon.com, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:15094 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753022AbYAJH3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 02:29:52 -0500
In-Reply-To: <20080109233056.GA5673@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm just about to test that second memory leak patch, but I gave the
original code a careful reading, and found a few problems:

* Huge monstrous glaring bug

  In ipg_interrupt_handler the code to habdle a shared interrupt
  not caused by this device:
	if (!(status & IPG_IS_RSVD_MASK))
		goto out_enable
  is *before* spin_lock(&sp->lock), but the code following
  out_enable does spin_unlock(&sp->lock).

  Thus, the sp->lock is all f*ed up.  The lack of any sort of
  locking between the interrupt handler and hard_start_xmit
  could cause all sort of issues.

  I'm not actually sure if it's even necessary; I'd think some
  suitable atomic access to sp->tx_current would suffice.

* Lesser bugs

  There's a general pattern of loops over the range from
  s->rx_current to sp->rx_dirty.  Some of them are call code
  that refers to s->rx_current, even though that hasn't been
  updated yet.

  One instance is in ipg_nic_check_frame_type.
  A second is in ipg_nic_check_error.

  In ipg_nic_set_multicast(), the code to enable the multicast flags
  is of the form "if (dev->flags & IFF_MULTICAST & (dev->mc_count > ...))".
  But IFF_MULTI CAST is not 1, so this will always be false.
  The seond & needs to be && (2x).


  In ipg_io_config(), there's
	/* Transmitter and receiver must be disabled before setting
	 * IFSSelect.
	 */
	ipg_w32((origmacctrl & (IPG_MC_RX_DISABLE | IPG_MC_TX_DISABLE)) &
		IPG_MC_RSVD_MASK, MAC_CTRL);
  I don't know what's going on there, but unless the IPG_MC_RX_DISABLE
  bit is already set in origmacctrl, that's going to write 0, which
  won't disable anything.

  Immediately following, there's some similarly buggy code doing something
  I don't understand with IPG_MC_IFS_96BIT.


  The setting of curr in ipg_nic_txfree, with that bizarre do_div, can't
  possibly be working right.


* Possible bugs

  I'm not very sanguine about the handling in init_rfdlist, of the
  code that handles a failed ipg_get_rxbuff.  In particular, it leaves
  rxfd->frag_info uninitialized in that case, but does set rxfd->rfs to
  "buffer ready to be received into", which could lead to receiving into
  random memory locations.

  In ipg_nic_hard_start_xmit(), the code
	if (sp->tx_current == (sp->tx_dirty + IPG_TFDLIST_LENGTH))
		netif_wake_queue(dev);
  shouldn't that *stop* the queue if the TFDLIST is full?

  I think that the places where the rxfd->rfs and txfd->tfc fields
  are filled in (containing the hardware-handoff flag) should
  have memory barriers.
  
* Stupid code

  In ipg_io_config, there are three writes to DEBUG_CTRL "Per silicon
  B3 eratta".  First, that's "errata".  But more significantly,
  can those writes be combined into one?  Is it necessary to read
  the DEBUG_CTRL register each time?

  The initialization of rxfd->rfs in init_rfdlist() and ipg_nix_rxrestore()
  should be moved into ipg_get_rxbuf().  And since the ready bit is there,
  it should be set AFTER the pointer fields AND there should be a barrier
  so the hardware doesn't read the fields out of order.

  In ipg_nic_txcleanup(), there's code to call netif_wake_queue every
  time through the loop in 10 MBit mode (to balance some bug-workaround
  call that stops the queue every packet in that case), which is
  quite unnecessary, as ipg_nic_txfree() will do it.

  The IPG_INSERT_MANUAL_VLAN_TAG code (fortunately disabled by default)
  is just plain bizarre.  What exactly is the use of assigning a tag of
  0xABC to every packet?

  The code in ipg_hw_init to set up dev->dev_addr reads each of the
  16-bit address reigsters twice, for no apparent reason.

  There's a lots of code in e.g. ipg_nic_rx() that does endless
  manipulation of rxfd->rfs with an le64_to_cpu() call around each
  instance, that should copy it to a CPU-ordered native value and be
  done with it.  (Some sparse annotations would help, too.)

  Likewise for messing with txfd->tfc in ipg_nic_hard_start_xmit().

  The Frame_WithEnd enum is a very strange value (decimal 10) to use as
  a bitmapped status flag.

  The four frame fragment functions
	nic_rx_with_start_and_end
	nic_rx_with_start
	nic_rx_with_end
	nic_rx_so_start_no_end
  could easily be unified into one.

* Performance left on the floor

  The hardware supports scallter/gather, hardware checksums, VLAN tagging,
  and 64-bit (well, 40-bit) DMA, but the driver sets no feature flags.

  The jumbo frame reception code could generate fragmented skbs rather
  that doing all those memcopies.

  Would it be worth splitting the 64-bit ->rfs and ->txc fields into
  two 32-bit fields?

  Would it be worth copying small incoming packets to small skbs and
  keeping the large skb in the receive queue?

* Questions

  In net_device_stats, are all those statistics registers cleared by
  a read?

  How do we determine the silicon revision numbers, so we can stop enabling
  bug workarounds on versions that don't need it?

  Where can I find docs about the scatter/gather features?  The bitfield
  definitions are a bit vague.
