From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [REGRESSION] 2.6.24-rc7: e1000: Detected Tx Unit Hang
Date: Wed, 16 Jan 2008 18:07:38 +0100
Message-ID: <18318.14810.877279.41815@robur.slu.se>
References: <36D9DB17C6DE9E40B059440DB8D95F52042FA541@orsmsx418.amr.corp.intel.com>
	<20080115.210214.170759690.davem@davemloft.net>
	<200801160956.09053.elendil@planet.nl>
	<20080116.022953.184520911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: elendil@planet.nl, jesse.brandeburg@intel.com,
	slavon@bigtelecom.ru, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:52585 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751477AbYAPRHn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2008 12:07:43 -0500
In-Reply-To: <20080116.022953.184520911.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David Miller writes:
 > > On Wednesday 16 January 2008, David Miller wrote:
 > > > Ok, here is the patch I'll propose to fix this.  The goal is to make
 > > > it as simple as possible without regressing the thing we were trying
 > > > to fix.
 > > 
 > > Looks good to me. Tested with -rc8.
 > 
 > Thanks for testing.

 Yes that code looks nice. I'm using the patch but I've noticed another 
 phenomena with the current e1000 driver. There is a race when taking a 
 device down at high traffic loads. I've tracked and instrumented and it 
 seems like occasionly irq_sem can get bump up so interrupts can't be 
 enabled again.


eth0 e1000_irq_enable sem = 1    <- High netload
eth0 e1000_irq_enable sem = 1
eth0 e1000_irq_enable sem = 1
eth0 e1000_irq_enable sem = 1
eth0 e1000_irq_enable sem = 1
eth0 e1000_irq_enable sem = 1
eth0 e1000_irq_enable sem = 1    <- ifconfig eth0 down
eth0 e1000_irq_disable sem = 2

**e1000_open                     <- ifconfig eth0 up
eth0 e1000_irq_disable sem = 3      Dead. irq's can't be enabled
e1000_irq_enable miss
eth0 e1000_irq_enable sem = 2
e1000_irq_enable miss
eth0 e1000_irq_enable sem = 1
ADDRCONF(NETDEV_UP): eth0: link is not ready


Cheers
					--ro

static void
e1000_irq_disable(struct e1000_adapter *adapter)
{
        atomic_inc(&adapter->irq_sem);
        E1000_WRITE_REG(&adapter->hw, IMC, ~0);
        E1000_WRITE_FLUSH(&adapter->hw);
        synchronize_irq(adapter->pdev->irq);

        if(adapter->netdev->ifindex == 3)
        printk("%s e1000_irq_disable sem = %d\n",  adapter->netdev->name,
               atomic_read(&adapter->irq_sem));
}

static void
e1000_irq_enable(struct e1000_adapter *adapter)
{
        if (likely(atomic_dec_and_test(&adapter->irq_sem))) {
                E1000_WRITE_REG(&adapter->hw, IMS, IMS_ENABLE_MASK);
                E1000_WRITE_FLUSH(&adapter->hw);
                }
        else
                printk("e1000_irq_enable miss\n");

        if(adapter->netdev->ifindex == 3)
          printk("%s e1000_irq_enable sem = %d\n",  adapter->netdev->name,
                 atomic_read(&adapter->irq_sem));
}
