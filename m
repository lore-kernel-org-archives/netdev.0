From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [net-next v4 1/7] i40e: main driver core
Date: Thu, 5 Sep 2013 09:26:33 -0700
Message-ID: <20130905092633.253896e3@nehalam.linuxnetplumber.net>
References: <1378336629-24224-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1378336629-24224-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:43361 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397Ab3IEQ0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 12:26:37 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro12so2007263pbb.27
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 09:26:37 -0700 (PDT)
In-Reply-To: <1378336629-24224-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More review comments, these are non-blocking, and can be fixed later.

Minor
-----
* style
    not a fan of doing own error codes and handling (ie. I40E_SUCCESS)
    which probably is side effect of OS abstraction.

* extra parens aren't needed on return
     return (budget > 0);

* i40e_config_netdev
    etherdev_size = (sizeof(struct i40e_netdev_priv));
	 Extra paren, only used once, unsigned vs signed, just
	 use sizeof()
    strlcpy(netdev->name, "eth%d", IFNAMSIZ-1);
        That is already done by alloc_etherdev
    memcpy(netdev->dev_addr, mac_addr, netdev->addr_len);
       netdev->addr_len is ETH_ALEN, mac_addr is ETH_ALEN
       just use constant size copy.
* i40e_init_module
    ret = pci_register_driver(&i40e_driver);
    return ret;
       assignment is unneeded, just do return pci_register_driver

* service timer
     since it is 1 HZ, you should use round_jiffies to align
     on clock boundary to save power.

* Why is Kbuild file used instead of Makefile like other drivers?

* Ethtool
  Need to use ethtool_cmd_speed_set othewise only lower bit set.

* Extension I40E_DEBUG_USER is non-standard

* What is is point of using snprintf() in i40e_get_drvinfo
	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
		 "%s", i40e_fw_version_str(&pf->hw));
  Already using strlcpy() for other fields.

* Ethtool ops can be const

* isn't vsi->netdev = NULL needed here.
s32 i40e_vsi_release(struct i40e_vsi *vsi)
	if (vsi->netdev_registered) {
			vsi->netdev_registered = false;
			if (vsi->netdev) {
				/* results in a call to i40e_close() */
				unregister_netdev(vsi->netdev);
				free_netdev(vsi->netdev);
			>>>>	vsi->netdev = NULL;


Enhancement
-----------
* Support Byte Queue Limits
  - might be tougher with VBE
