From: Marin Mitov <mitov@issp.bas.bg>
Subject: [BUG] unsolicited IRQ disabling at the IO-APIC leading to eth0 freezes
Date: Tue, 25 Mar 2008 17:15:18 +0200
Message-ID: <200803251715.18694.mitov@issp.bas.bg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755357AbYCYPOh@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

WAS: net: tx timeouts with skge, 8139too, dmfe drivers/NICs

Hi all,

I am observing rare freezes(blocking) of eth0 with:

NETDEV WATCHDOG: eth0: transmit timed out

in dmesg output.

The problem has been already described in a previous message:

http://lkml.org/lkml/2008/2/25/312

with some additional observations, as described in:

http://lkml.org/lkml/2008/3/12/96

Recently I found that the IRQ# used by the driver/NIC has been
somehow disabled/masked  at the IO-APIC, blocking the interrupts to
the driver irq_handler, so the messages: NETDEV WATCHDOG....

Pitting:

disable_irq(_nosync)(irq#);
enable_irq(irq#);

in the dev->tx_timeout() method restores the working state of eth0,
(at least for skge), so the interface now works posting (sometimes)

NETDEV WATCHDOG: eth0: transmit timed out

messages in the log.

If I EXPORT_SYMBOL(irq_desc) (from kernel/irq/handle.c)
I am able to restore the working state of the eth0 interface with

(irq_desc + irq#)->chip->enable(irq#)

or

(irq_desc + irq#)->chip->unmask(irq#)

(properly locked),  instead of disable/enable_irq(irq#), 

Just for info the driver irq_handler always return IRQ_HANDLED and never 
(verified) IRQ_NONE, so the irq# is not disabled due to unhandled irqs - 
yes the driver declares IRQF_SHARED, but is the only one on this irq# 
(as viewed in /proc/interrupts).

The system is runing kernel-2.6.14.3-SMP (AMD64 X2) on Asus A7V Deluxe

Am I observing IRQ locking/rice condition OUT of net driver?

All suggestions for further investigation are wellcome.

Marin Mitov
