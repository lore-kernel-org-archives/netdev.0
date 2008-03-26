From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 0/8] New driver "sfc" for Solarstorm SFC4000 controller (try #9)
Date: Wed, 26 Mar 2008 12:12:12 +0000
Message-ID: <20080326121210.GE24160@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net-drivers@solarflare.com, Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:59107 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751554AbYCZMM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 08:12:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a resubmission of a new driver for Solarflare network controllers.

The driver supports the 10Xpress PHY and XFP modules on our reference
designs SFE4001 and SFE4002 and the SMC models SMC10GPCIe-XFP and
SMC10GPCIe-10BT.

The previous patches began with:
  http://marc.info/?l=linux-netdev&m=120528862826282&w=2

Some explanation of the driver structure was posted in:
  http://marc.info/?l=linux-netdev&m=119999015817920&w=2

Since the last submission we have addressed the review comments:
- Remove local unused flags variables.
- Removed bogus uses of __attribute__ ((unused)).
- Removed conditional use of topology_core_siblings().
- Moved net-dev allocation and freeing from efx_{init,fini}_napi() to
  efx_pci_{probe,remove}() since we only have one port per PCI function.
  Moved net-dev initialisation and association from efx_init_napi() to
  appropriate functions.  Removed now-obsolete test that efx->net_dev
  is non-null.
- Simplified Makefile.

We have also made a number of bug fixes:
- Always reconfigure MAC in efx_start_port(); this avoids potential
  missed signalling of net carrier.
- Moved call to falcon_update_nic_stats() into efx_net_stats() since it
  now requires NIC stats as well.
- Remove useless call to efx_reconfigure_port() from efx_ioctl().
- When fini'ing the tx queue, don't complain about completing
  empty descriptors. Whilst here make skipping tx descriptors a proper
  error, and perform an invisible reset.
- Don't propagate link state changes whilst the port is down.
- Fixed failure path for efx_probe_all() to call efx_remove_nic() if
  necessary.
- Fixed efx_ethtool_set_pauseparam() to propagate result of
  efx_mac_operations::set_pause.

We also did some cleanup and simplification:
- Removed declaration of removed function falcon_debugfs_read_hardware_desc().
- Removed unused definitions of EFX_WORD, EFX_DWORD, EFX_OWORD.
  Removed definition of EFX_BYTE and replaced with literal 1 in sfe4001.c.
- Removed unused inline function efx_is_over_4gb().
- Changed return type of efx_probe_interrupts() and efx_select_used() to
  void, as they can never fail.  Simplified efx_probe_nic() accordingly.
- Renamed FALCON_BUF_ALIGN to FALCON_BUF_SIZE (it is both size and alignment).
  Replaced literal 4096 in falcon_alloc_special_buffer() with FALCON_BUF_SIZE.
  Made use of kernel ALIGN() macro in falcon_alloc_special_buffer().
- Corrected first comment in i2c-direct.c - we don't use I2C for EEPROM
  access on Falcon.
- Removed name format macros only used by ethtool self-tests and debugfs.
- Removed SPI-related members from efx_nic, only needed for MTD driver.
- Remove the net_dev_registered flag, replacing it with checks on
  the net_dev->flags field. netif_running() is implicitly false
  when NET_DEV_REGISTERED()==0, so remove some spurious checks.
- Since we always call efx_reconfigure_port() in efx_start_port(), then
  always drain the port in efx_stop_all(). This removes an unneeded
  abstraction.

We hope the driver is now ready to be merged.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
