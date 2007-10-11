From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Regression in net-2.6.24?
Date: Thu, 11 Oct 2007 16:55:48 -0700
Message-ID: <20071011165548.6545b207@freepuppy.rosehill>
References: <20071011.105526.17823985.takano@axe-inc.co.jp>
	<Pine.LNX.4.64.0710111300280.23026@kivilampi-30.cs.helsinki.fi>
	<20071011.225146.94718703.takano@axe-inc.co.jp>
	<20071011.164827.64988925.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: takano@axe-inc.co.jp, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, mchan@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42583 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753295AbXJKX4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 19:56:23 -0400
In-Reply-To: <20071011.164827.64988925.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 11 Oct 2007 16:48:27 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: TAKANO Ryousei <takano@axe-inc.co.jp>
> Date: Thu, 11 Oct 2007 22:51:46 +0900 (JST)
> 
> > Modules linked in: 8021q tcp_bic netconsole evdev joydev sg st sr_mod ohci_hcd i2c_amd756 i2c_amd8111 i2c_core ipv6 tg3 usbhid usbcore ff_memless dm_mod ext3 jbd sata_sil libata sd_mod scsi_mod
>  ...
> > RIP points at __list_del (net_rx_action -> list_move_tail -> __list_del).
> 
> There is a contract between the driver's ->poll() method and
> net_rx_action() in that it is assumed that if the entire quota has
> been used up, the driver will not perform a netif_rx_complete().
> 
> It seems that in a corner case the tg3 driver, which you appear to be
> using, will not abide by this rule.  That corner case is when the card
> has exactly "budget" receive packets pending.  In such a case
> tg3_has_work() will be false, and we will RX complete when work_done
> >= budget, which violates the above mentioned rule.
> 
> Can you see if the following test patch makes the crash go away?
> 
> Michael, I know you're not pleased with this patch and neither am
> I.  It might be better to just strictly RX complete when
> (work < budget) and if tg3_has_work(), trigger a HW interrupt.
> 
> Alternatively we could loop in tg3_poll() until either budget
> is exhausted or tg3_has_work() returns false.  Actually, this sounds
> like a cleaner scheme the more I think about it.
> 
> BNX2 likely has a similar issue.

sky2 as well.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
