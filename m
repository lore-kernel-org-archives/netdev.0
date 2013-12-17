From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH v2 1/1] drivers: net : cpsw: pass proper device
 name while requesting irq
Date: Tue, 17 Dec 2013 14:39:19 -0500 (EST)
Message-ID: <20131217.143919.986923631175327534.davem@davemloft.net>
References: <1386925527-6706-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	george.cherian@ti.com
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48372 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129Ab3LQTjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 14:39:21 -0500
In-Reply-To: <1386925527-6706-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Fri, 13 Dec 2013 14:35:27 +0530

> During checking the interrupts with "cat /proc/interrupts", it is showing
> device name as (null), this change was done with commit id aa1a15e2d where
> request_irq is changed to devm_request_irq also changing the irq name from
> platform device name to net device name, but the net device is not
> registered at this point with the network frame work, so devm_request_irq
> is called with device name as NULL, by which it is showed as "(null)" in
> "cat /proc/interrupts". So this patch moved the devm_request_irq after
> the net device register so that the device name shows as eth*.

This change is buggy.

If the request irq fails, you have to unregister the network device,
branching to clean_ale_ret is insufficient.

And this shows the more fundamental problem with your change, you
cannot register the network device before you request the IRQs
if your ->open() method assumes that the IRQs are registered already.

Which this driver does.

The very moment you call request_irq(), the interface can be brought
up and then ->open() method invoked.

Therefore, register_netdevice() absolutely must be the very last
action during the probe function.

Why don't you just use the platform device name as the interrupt
name?  The other alternative is to only register the IRQs in the
->open() routine and free the IRQ in the ->close() method.

I can't apply this, sorry.
