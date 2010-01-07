From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCHv2 NEXT 1/2] qlcnic: Qlogic ethernet driver for CNA
 devices
Date: Thu, 7 Jan 2010 05:38:13 -0600
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80CFE943443@MNEXMB2.qlogic.org>
References: <1262777154-31982-1-git-send-email-amit.salecha@qlogic.com>
	<1262777154-31982-2-git-send-email-amit.salecha@qlogic.com>,<20100106111655.207e7414@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Dhananjay Phadke <dhananjay.phadke@qlogic.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:49503 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752380Ab0AGLoS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 06:44:18 -0500
In-Reply-To: <20100106111655.207e7414@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks a lot for your review.
I will send patch again with version v3, fixing some of your comments

Questions:
1) I have changed tx cmd buffer allocation to kmalloc, rcv buffer will use vmalloc only,
     because of its size.    
2) Will provide some documentation. Currently sysfs is only option.
3) We have multiple NAPI context, all of them can process single command ring.
4) Since registers and onboard memory has different window register, they require separate lock.
5) Changed it to mutex. Now mem_lock is mutex.

I have fixed some of the minor stuff, which were valid.

-Amit Salecha
________________________________________
From: Stephen Hemminger [shemminger@vyatta.com]
Sent: Thursday, January 07, 2010 12:46 AM
To: Amit Salecha
Cc: davem@davemloft.net; netdev@vger.kernel.org; Dhananjay Phadke
Subject: Re: [PATCHv2 NEXT 1/2] qlcnic: Qlogic ethernet driver for CNA devices

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
+                               int *valp);

* Polling should be aligned to safe power (see round_jiffies)





