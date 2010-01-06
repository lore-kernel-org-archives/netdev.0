From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCHv2 NEXT 1/2] qlcnic: Qlogic ethernet driver for CNA
 devices
Date: Wed, 6 Jan 2010 11:16:55 -0800
Message-ID: <20100106111655.207e7414@nehalam>
References: <1262777154-31982-1-git-send-email-amit.salecha@qlogic.com>
	<1262777154-31982-2-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	dhananjay.phadke@qlogic.com
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44277 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932089Ab0AFTRa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2010 14:17:30 -0500
In-Reply-To: <1262777154-31982-2-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Questions:
* Are rings really so big that they need to be allocated with vmalloc()
  rather than kmalloc()? vmalloc() space is restricted and use kmalloc()
  if possible.

* Is there some documentation on bridge mode?  controlling it via sysfs is
  okay, but is there a more logical place?
  
* Do you need overhead of tx_clean_lock if you only call it from NAPI
  context?

* crb_lock is setup as rwlock but you only use as writer;
  also isn't this already covered by mem_lock?

* mem_lock could/should be mutex
  can ioremap want to sleep?

Minor stuff:

* the following are only used in one file and should be static
    init_module
    cleanup_module
    qlcnic_get_stats
    qlcnic_set_mac

* Could qlcnic_process_cmd_ring be moved to qlcnic_main.c
  and made static so gcc can inline

* strings can be const
   qlcnic_driver_name, qlcnic_driver_string

* other things that can be const
   pci_device table
   diag_registers
   qlcnic_config_rss::key
   fw_name
   msi_tgt_status
   legacy_intr?

* why does diag_register[] use sentinel rather than ARRAY_SIZE()


* no need for static inline (let compiler decide)
    qlnic_update_cmd_consumer

* get_brd_name_by_type
    why is this an inline, it is not in fast path
    just move to qlcnic_main.c
    name can be const char *

* inconsistent use of extern
+int qlcnic_get_flash_mac_addr(struct qlcnic_adapter *adapter, __le64 *mac);
+int qlcnic_p3_get_mac_addr(struct qlcnic_adapter *adapter, __le64 *mac);
+extern void qlcnic_change_ringparam(struct qlcnic_adapter *adapter);
+extern int qlcnic_rom_fast_read(struct qlcnic_adapter *adapter, int addr,
+				int *valp);

* Polling should be aligned to safe power (see round_jiffies)





-- 
