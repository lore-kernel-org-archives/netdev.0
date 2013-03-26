From: Darren Hart <dvhart@linux.intel.com>
Subject: pch_gbe: Expanding PHY and Board support (MinnowBoard)
Date: Tue, 26 Mar 2013 16:25:48 -0700
Message-ID: <51522E7C.4040204@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Decotigny <decot@google.com>,
	Tomoya <tomoya-linux@dsn.okisemi.com>,
	Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>,
	Tomoya MORINAGA <tomoya.rohm@gmail.com>,
	Takahiro Shimizu <tshimizu818@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:35224 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755944Ab3CZXZu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 19:25:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm working on adding support for the MinnowBoard (minnowboard.org) as
we're working through the last of the hardware changes. There are a few
things about the pch_gbe driver that I'm having to update to support
this board. I'd appreciate your thoughts on how to best go about the
specializations.

1) It uses an Atheros AR8031 PHY instead of the more typical Realtek
   a) This PHY hibernates after 10s of no cable and can prevent
successful PHY
      init during PCI probe of the device. This can be addressed by
disabling
      hibernation in firmware and enabling later in the Kernel or by
adding support
      for the HW Reset of this PHY with the GPIO line tied to it on this
board.
   b) The board doesn't have a long trace to add the 2ns delay to TX
clock like
      other boards using this platform. This can be addressed by
instructing the
      PHY to introduce the delay.

2) Like another board which led to the following commit, this board does not
   have an EEPROM for the Ethernet address (MAC).

    commit 2b53d07891630dead46d65c8f896955fd3ae0302
    Author: Darren Hart <dvhart@linux.intel.com>
    Date:   Mon Jan 16 09:50:19 2012 +0000

        pch_gbe: Do not abort probe on bad MAC

   On this board, we plan to have the MAC provided by the firmware
(NVRAM, EFI
   VAR, something along those lines).

Looking at the driver and our options, using a PCI subsystem
vendor/device IDs
to identify the board seems like the best way to go. I have a start at
this but
would appreciate your thoughts on the following:

1) Is the PCI subsystem vendor/device IDs the right approach, e.g. in
probe():

	adapter = netdev_priv(netdev);

	/* Identify PCI subsystem ID tweaks */
	adapter->hw.mac_in_nvram = NULL
	adapter->hw.phy.hw_rst_gpio = -1;
	adapter->hw.phy.tx_clk_delay = false;
	switch (pdev->subsystem_vendor) {
	case PCI_VENDOR_ID_INTEL:
		switch (pdev->subsystem_device) {
		case PCI_SUBDEVICE_ID_MINNOWBOARD:
			pr_debug("MinnowBoard detected\n");
			adapter->hw.mac_in_nvram = MINNOW_NVRAM_MAC_ADDR;
			adapter->hw.phy.hw_reset_gpio = MINNOW_PHY_RST_GPIO;
			adapter->hw.phy.tx_clk_delay = true;
	}

   The mac_in_nvram, hw_rst_gpio, and tx_clk_delay vars were added to the
   existing structures in support of this.

2) The physical reset of the PHY is extremely board and PHY specifc as it
   requires knowledge of the GPIO line used and the specifics of the
reset and
   clock timings on the particular PHY. I believe I can avoid this by just
   disabling hibernation in firmware and enabling after the driver is
up. There
   are scenarios where this could fail though, such as loading the module,
   unloading the module, removing the cable, waiting 10+ seconds, and
trying to
   load the driver again. It should however load successfully after a
cable was
   reinserted.

3) It appears as though the pch_gbe was written with a very specific PHY in
   mind. I've switched on phy.id where needed:

	switch (hw->phy.id) {
	case PHY_AR803X_ID:
		pr_info("AR803x PHY: configuring tx clock delay.\n");
		...

   But I wonder if converting pch_gbe over to the PHY Abstraction Layer and
   fleshing out the two known PHYs for this platform would be "the right"
   approach. Sounds like a lot more work...

Anyway, I'm new to networking drivers and would appreciate any feedback
that would help me start with the preferred approach for this type of
specialization.

Thanks,

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Technical Lead - Linux Kernel
