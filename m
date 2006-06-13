From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [RFT 0/5] sky2: suspend/resume patchlets
Date: Tue, 13 Jun 2006 09:38:09 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0606130908370.5498@g5.osdl.org>
References: <20060613081726.695812000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:35999 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932186AbWFMQih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 12:38:37 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060613081726.695812000@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[ Davem - see the final conclusion: this might not be a driver bug as much 
  as a netconsole problem, where netconsole might perhaps continue sendign 
  on a device that really can't take it any more? ]

On Tue, 13 Jun 2006, Stephen Hemminger wrote:
>
> There were a several problems buried in suspend/resume. The real
> failure was caused by the idle timer not being stopped/restarted.
> But several other races, and cleanups were needed.
> 
> Since I don't have a machine that will suspend successfully with
> that hardware, I can't test it.

With this, I get a page-fault in sky2_tx_complete+0x91 (with traceback to 
sky2_poll, net_rx_action, do_softirq, do_IRQ, skb_release_data, kfree_skb, 
sky2_rx_clean, sky2_down, sky2_suspend, pci_device_suspend, all the way 
down to suspend_device()).

So an IRQ happened while the sky2 driver was doign sky2_rx_clean, which is 
just _after_ it did "sky2_tx_clean()", and then the TX side was unhappy 
for some reason.

Again, the driver has actually tried to disable its _own_ irq, but that 
doesn't much help. Also, with write posting, even its own irq might have 
gotten delayed (ie if you really want to synchronize irq's, you need to 
read from the device, and then also wait a bit to see that the irq isn't 
being posted int he _other_ direction), but in the presense of shared 
irq's, it just doesn't do anything at all.

I can't seem to get a bigger VGA console on the Mac mini, so I'm unable to 
see the exact register values.

Btw, this probably happens with my patch too, and is likely 
timing-related.

Oh, and to make matters worse, I also enabled netconsole (in order to see 
what goes wrong), which is probably what brought on the horrid timing 
issue (ie packets going out _just_ at the right time saying "shutting 
down sky2")

Btw, that "sky2_tx_complete+0x91" seems to be 

	loop:
		inc    %edx
		mov    0x9c(%ecx),%eax
	**	movzwl 0x4(%eax),%eax	**
		cmp    %eax,%edx
		jb loop

which in turn is:

                for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
                        struct tx_ring_info *fre;
                        fre = sky2->tx_ring + RING_NEXT(put + i, TX_RING_SIZE);
                        pci_unmap_page(pdev, pci_unmap_addr(fre, mapaddr),
                                       skb_shinfo(skb)->frags[i].size,
                                       PCI_DMA_TODEVICE);
                }

since pci_unmap_page() is a no-op here ;)

So it looks like it's the "skb_shinfo(skb)->nr_frags" access that oopses.

Which probably means that

	skb = re->skb;

just got garbage (rememebr: the pci_unmap_single() directly after it is 
_also_ a no-op, so it wouldn't oops there).

I dunno the details. I'd have _expected_ tx_cons to be equal to tx_prod 
here (since we just did a sky2_tx_clean() before), and the loop to not 
have been entered at all, but I wonder if maybe it's the netconsole that 
doesn't honor "netif_stop_queue()"?

Dunno.

			Linus
