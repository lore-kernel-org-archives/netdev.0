From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] bnx2x: don't reset chip on cleanup if PCI
 function is offline
Date: Thu, 01 Sep 2016 22:50:30 -0700 (PDT)
Message-ID: <20160901.225030.312704492938981672.davem@davemloft.net>
References: <1472656317-2323-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, ariel.elior@qlogic.com,
        netdev@vger.kernel.org
To: gpiccoli@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45010 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750979AbcIBFub (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 01:50:31 -0400
In-Reply-To: <1472656317-2323-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Date: Wed, 31 Aug 2016 12:11:57 -0300

> When PCI error is detected, in some architectures (like PowerPC) a slot
> reset is performed - the driver's error handlers are in charge of "disable"
> device before the reset, and re-enable it after a successful slot reset.
> 
> There are two cases though that another path is taken on the code: if the
> slot reset is not successful or if too many errors already happened in the
> specific adapter (meaning that possibly the device is experiencing a HW
> failure that slot reset is not able to solve), the core PCI error mechanism
> (called EEH in PowerPC) will remove the adapter from the system, since it
> will consider this as a permanent failure on device. In this case, a path
> is taken that leads to bnx2x_chip_cleanup() calling bnx2x_reset_hw(), which
> then tries to perform a HW reset on chip. This reset won't succeed since
> the HW is in a fault state, which can be seen by multiple messages on
> kernel log like below:
> 
> 	bnx2x: [bnx2x_issue_dmae_with_comp:552(eth1)]DMAE timeout!
> 	bnx2x: [bnx2x_write_dmae:600(eth1)]DMAE returned failure -1
> 
> After some time, the PCI error mechanism gives up on waiting the driver's
> correct removal procedure and forcibly remove the adapter from the system.
> We can see soft lockup while core PCI error mechanism is waiting for driver
> to accomplish the right removal process.
> 
> This patch adds a verification to avoid a chip reset whenever the function
> is in PCI error state - since this case is only reached when we have a
> device being removed because of a permanent failure, the HW chip reset is
> not expected to work fine neither is necessary.
> 
> Also, as a minor improvement in error path, we avoid the MCP information dump
> in case of non-recoverable PCI error (when adapter is about to be removed),
> since it will certainly fail.
> 
> Reported-by: Harsha Thyagaraja <hathyaga@in.ibm.com>
> Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
> ---
> v2: Removed the unlikely attribute on bnx2x_fw_dump_lvl() if block.

Applied, thanks.
