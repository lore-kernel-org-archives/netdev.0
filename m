From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH] r8169: use RxFIFO overflow workaround for 8168c chipset
Date: Tue, 01 Feb 2011 11:30:38 +0100
Message-ID: <1296556238.19128.27.camel@cera.brq.redhat.com>
References: <1296127451-12640-1-git-send-email-ivecera@redhat.com>
	 <20110127143219.GA7831@electric-eye.fr.zoreil.com>
	 <1296156217.8720.3.camel@ceranb.brq.redhat.com>
	 <20110128172537.GA11064@electric-eye.fr.zoreil.com>
	 <20110128172854.GA8151@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Hayes <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59047 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751603Ab1BAKaw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Feb 2011 05:30:52 -0500
In-Reply-To: <20110128172854.GA8151@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-01-28 at 18:28 +0100, Francois Romieu wrote:
> Ivan Vecera <ivecera@redhat.com> :
> [...]
> > The test case was: Migration of the several kvm guests at the same time
> > between two hosts.
> 
> :o(
> 
> Could you check if simply leaving the irq handler when status == RxFIFOOver
> works by any chance ?
It does not help, I tried two versions:
1) Simply leave the loop (only "break;") when status == RxFIFOOver
...
if (unlikely(status & RxFIFOOver)) {
	static int rxfifo_count = 0; 
        printk("r8169: Rx FIFO overflows detected: %d\n", 
        	++rxfifo_count);
	break;
}
...

2) the same but with interrupt confirmation before leave
...
if (unlikely(status & RxFIFOOver)) {
	static int rxfifo_count = 0; 
        printk("r8169: Rx FIFO overflows detected: %d\n", 
        	++rxfifo_count);
	RTL_W16(IntrStatus,
		(status & RxFIFOOver) ?
		 (status | RxOverflow) : status);
	break;
}
...

In both cases the NIC continues in generating Rx FIFO overflows.

Ivan

> 
> Faced with pktgen, RTL_GIGA_MAC_VER_26 spits RxFIFO overflow errors quite
> fast (10000 packets kill it, reliably). The same fix as your avoids the crash.
> 
> As is, RTL_GIGA_MAC_VER_12 seems to survive at 900kpps. It signals RXFIFO
> overflow, loses half the packets and sends pause control frames but it does
> not crash. I have made it leave the irq handler when status == RxFIFOOver.
> I'll see if it can stand a few hours like that.
> 


