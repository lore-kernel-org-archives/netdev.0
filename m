From: Alan <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 0/4] atl1: Revised Attansic L1 ethernet driver
Date: Mon, 20 Nov 2006 01:15:34 +0000
Message-ID: <20061120011534.54b1e010@localhost.localdomain>
References: <20061119202817.GA29736@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, shemminger@osdl.org, romieu@fr.zoreil.com,
	csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:38824 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP id S933829AbWKTBK4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 20:10:56 -0500
To: Jay Cliburn <jacliburn@bellsouth.net>
In-Reply-To: <20061119202817.GA29736@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Would be nice if it used atl_ not at_ so its less likely to cause
namespace clashes.

You have various macros for swaps that are pretty ugly - we have
cpu_to and le/be_to_cpu functions for most swapping cases and these are
generally optimised assembler (eg bswap on x86)

AT_DESC_USED/UNUSED would be better as inline functions but thats not a
serious concern.

Be careful with :1 bitfields when working with hardware - the compiler
has more than one choice about how to pack them.

The irq enable/disable use for locking on vlan appears unsafe. PCI
interrupt delivery is asynchronous which means you can get this happen


	card sends PCI interrupt
	We call irq_disable
	We take lock
	We poke bits
	We drop lock

	PCI interrupt arrives


This really does happen, typically its nasty to debug as well because you
usually only get it on PIII boards on the one in n-zillion times a
message collides and is retransmitted on the APIC bus.

skb->len is unsigned so <= 0 can be == 0. More importantly the subtraction
before the test will wrap and is completely unsafe (see at_xmit_frame)


Alan
