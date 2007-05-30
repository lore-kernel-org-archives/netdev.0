From: Michael Buesch <mb@bu3sch.de>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Wed, 30 May 2007 12:45:16 +0200
Message-ID: <200705301245.16983.mb@bu3sch.de>
References: <20070525172431.60affaca@freepuppy> <465CABA3.10003@pobox.com> <1180474611.17711.26.camel@dhcp-10-12-136-115.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>,
	"Maximilian Engelhardt" <maxi@daemonizer.de>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-wireless" <linux-wireless@vger.kernel.org>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	"Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, "Andrew Morton" <akpm@linux-foundation.org>
To: "Gary Zambrano" <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:47988
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210AbXE3KqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 06:46:25 -0400
In-Reply-To: <1180474611.17711.26.camel@dhcp-10-12-136-115.broadcom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 29 May 2007 23:36:51 Gary Zambrano wrote:
> On Tue, 2007-05-29 at 18:39 -0400, Jeff Garzik wrote:
> 
> > We check for 0xffffffff because that is often how a fault is indicated, 
> > when the memory location is read during or immediately after hotplug (or 
> > if the PCI bus is truly faulty).  So for most hardware, you see
> > 
> > tmp = read(irq status)
> > if (!tmp)
> > 	return irq-none		/* no irq events raised */
> > if (tmp == 0xffffffff)
> > 	return irq-none		/* hot unplug or h/w fault */
> > 
> > and the method that determines no interrupt handling is needed.
> > 
> 
> I guess you are right, but then shouldn't the driver be checking for
> faults in other parts of the code too? What if a fault/hotplug occurs
> immediately after an interrupt, but before a tx?
> Thanks,

Well, in general it's not desired (or even possible) to check every
single MMIO access. General practice is to check on entering the IRQ handler
and on values from registers or DMA which could crash the driver.
For example on DMA we get some cookie back from the device in the TX
status report that says which packet this was associated to.
That value is used to look up a table.
In bcm43xx I initialize that to 0 in the driver, which is not a valid value.
Later I check for that. So if the device is unplugged before DMA was
on that value was complete it will recognize it and it won't crash.

In general we can only do our very best to prevent bad sideeffects from
a pull-in-full-operation. We can't do much here anyway. Best we can do
is to _try_ to prevent a crash. It might not always be 100% possible
to do so, though.

-- 
Greetings Michael.
