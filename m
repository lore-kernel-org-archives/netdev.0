From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/3] r8169: code clean-up
Date: Sat, 19 Feb 2005 23:30:12 +0100
Message-ID: <20050219223012.GA3601@electric-eye.fr.zoreil.com>
References: <200502161823.43562.jdmason@us.ibm.com> <200502181918.07859.jdmason@us.ibm.com> <20050219104640.GA31035@electric-eye.fr.zoreil.com> <200502191147.14845.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200502191147.14845.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> :
[...]
> I never said it was pretty, simply a working snapshot of my test driver.  I 
> figured that I had been promising you this update for so long, I better send 
> it out before you get upset with me.  ;-)

No, no, I meant mangled as in "kmail fcuked the tabs again".

[...]
> The change to opts1 seems cleaner to me.  As the only the that the adapter 
> needs to know is the RingEnd.  I can try removing it and see if it makes any 
> difference.

Until there is a stability or performance reason for it, I will not take
the change:
- it would add one extra parameter in any future problem report;
- neither me nor you can reproduce on it the testing done on the current form.

I would lazily label it as too much work with too low a priority.

> Opts2 is VERY necessary to zero.  Without this zero, the adapter will change 
> the partition point randomly of each packet (random because I have yet to 
> determine the rhyme or reason).  I didn't want to spend too much time trying 
> to determine the bahavior of this since I found out that zeroing it solved 
> the problem.  If you can think of a reason why this doesn't work, I can 
> always go back and try to figure it out.

Ok, this one really changes the behavior of the driver.

[...]
> See above for reason.  I can re-order the operations and a mb (rmd I would 
> think).  

So this one changes the behavior of the driver as well, right ?

The window may be narrow but I'll sleep more quietly if the ordering is
modified and the memory barrier added.

[...]
> > Why is rtl8169_rx_csum() moved around ?
> 
> Seemed to make more sense to me to have it after the 
> pci_dma_sync_single_for_cpu.  If you disagree, I can move it back.  

rtl8169_rx_csum() only uses the consistent DMA mapping so it does not
care.

[skb_put/memcpy duplication]
> 
> Me too, but I couldn't think of a better way.  Suggestions welcomed.

Nothing fancy. Something like:
	len  = (pkt_size > rx_copybreak) ? tp->desc_part : pkt_size;
	memcpy(skb->data, sk_buff[0]->tail, len);
	skb_put(skb, len);


> > 5 - rtl8169_return_to_asic() in rtl8169_rx_copy() seems suspect
> >     when FirstFrag is true and the skb allocation failed.
> 
> In this case the desc is only a portion of the whole packet.  I thought it 
> best to toss the whole packet if the driver couldn't alloc a skb, and return 
> the descriptor so that it can be used again.  

1 - the packet could be under rx_copybreak as well;
2 - the driver currently defers the loss of a packet until there is no memory
    pointed by the current descriptor used for Rx DMA from the adapter. If it
    is refilled soon enough, no one notices it.

> Actually, talking about this gave me an idea.  Since desc_part is the largest 
> skb we will ever need (aside from when they are combined), it would be more 
> efficient to use that instead of the full size.  I will create a patch for 
> this (and the mb changes) and resubmit it.  Let me know if you want me to 
> return other things to their original spot.

I am not sure I understand exactly what you mean. If you are saying that
the max size is known and can be allocated in advance so that only the
rx_copybreak calls for an instant allocation, we are saying the same thing
(actually this should have been point 3- above :o) ).

It will make my life easier if the patch only contains the minimal amount of
changes (easier reviewing, testing, confidence, blah blah, it's boring but
you got the idea).

> > 6 - skb_put() ends duplicated. It should be possible to avoid it.
> 
> Is it?  I was specifically trying to aviod that.  Where do you see that?

->
+   if (rtl8169_rx_copy(&skb, pkt_size, desc, tp)) {
     pci_action = pci_unmap_single;
     tp->Rx_skbuff[entry] = NULL;
+    skb_put(skb, pkt_size);
    }

-> rtl8169_rx_copy()
Lots of skb_put()

Don't bother too much about this one. I had expected to keep the
skb->dev = ...; skb_put(...); skb->proto = ... sequence as is to
minimize the changes but it is not necessarily doable/sane.

--
Ueimor
