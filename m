From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH 2/3] r8169: code clean-up
Date: Sun, 20 Feb 2005 12:04:23 -0600
Message-ID: <200502201204.23468.jdmason@us.ibm.com>
References: <200502161823.43562.jdmason@us.ibm.com> <200502191147.14845.jdmason@us.ibm.com> <20050219223012.GA3601@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050219223012.GA3601@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Saturday 19 February 2005 04:30 pm, Francois Romieu wrote:
> Jon Mason <jdmason@us.ibm.com> :
> [...]
>
> > I never said it was pretty, simply a working snapshot of my test driver. 
> > I figured that I had been promising you this update for so long, I better
> > send it out before you get upset with me.  ;-)
>
> No, no, I meant mangled as in "kmail fcuked the tabs again".

Not 100% sure it is a kmail problem (as it could be my IMAP server).  I'll 
trying a different mail clent, and see if that makes any difference.  Thanks 
for the heads-up.

> [...]
>
> > The change to opts1 seems cleaner to me.  As the only the that the
> > adapter needs to know is the RingEnd.  I can try removing it and see if
> > it makes any difference.
>
> Until there is a stability or performance reason for it, I will not take
> the change:
> - it would add one extra parameter in any future problem report;
> - neither me nor you can reproduce on it the testing done on the current
> form.
>
> I would lazily label it as too much work with too low a priority.

Actually, I removed it and it causes the partition point to move, similiar to 
opts2.  I realize this isn't really an acceptable answer, so I will try to 
determine what is causing this weird behavior.

> > Opts2 is VERY necessary to zero.  Without this zero, the adapter will
> > change the partition point randomly of each packet (random because I have
> > yet to determine the rhyme or reason).  I didn't want to spend too much
> > time trying to determine the bahavior of this since I found out that
> > zeroing it solved the problem.  If you can think of a reason why this
> > doesn't work, I can always go back and try to figure it out.
>
> Ok, this one really changes the behavior of the driver.
>
> [...]
>
> > See above for reason.  I can re-order the operations and a mb (rmd I
> > would think).
>
> So this one changes the behavior of the driver as well, right ?
>
> The window may be narrow but I'll sleep more quietly if the ordering is
> modified and the memory barrier added.

fixed.  

> [...]
>
> > > Why is rtl8169_rx_csum() moved around ?
> >
> > Seemed to make more sense to me to have it after the
> > pci_dma_sync_single_for_cpu.  If you disagree, I can move it back.
>
> rtl8169_rx_csum() only uses the consistent DMA mapping so it does not
> care.

returned to its original spot.

> [skb_put/memcpy duplication]
>
> > Me too, but I couldn't think of a better way.  Suggestions welcomed.
>
> Nothing fancy. Something like:
>  len  = (pkt_size > rx_copybreak) ? tp->desc_part : pkt_size;
>  memcpy(skb->data, sk_buff[0]->tail, len);
>  skb_put(skb, len);

fixed.

> > > 5 - rtl8169_return_to_asic() in rtl8169_rx_copy() seems suspect
> > >     when FirstFrag is true and the skb allocation failed.
> >
> > In this case the desc is only a portion of the whole packet.  I thought
> > it best to toss the whole packet if the driver couldn't alloc a skb, and
> > return the descriptor so that it can be used again.
>
> 1 - the packet could be under rx_copybreak as well;
> 2 - the driver currently defers the loss of a packet until there is no
> memory pointed by the current descriptor used for Rx DMA from the adapter.
> If it is refilled soon enough, no one notices it.

True, but this problem existed before I made the jumbo frames changes.  The 
only way I can think to fix this is to do the following:

static inline int rtl8169_rx_copy(struct sk_buff **sk_buff, int pkt_size,
                              struct RxDesc *desc, struct rtl8169_private *tp)
{
        u32 status = le32_to_cpu(desc->opts1);

        if ((pkt_size > rx_copybreak) &&
                        ((status & FirstFrag) && (status & LastFrag)))
                return -1;

        if (status & FirstFrag) {
                struct sk_buff *skb = dev_alloc_skb(pkt_size + NET_IP_ALIGN);
                u32 len = (pkt_size > rx_copybreak) ? tp->desc_part : 
pkt_size;

                if (skb) {
                        skb_reserve(skb, NET_IP_ALIGN);
                        memcpy(skb->data, sk_buff[0]->tail, len);
                        skb_put(skb, len);
                } else {
                        printk(KERN_INFO "no rx skb allocated\n");
   if (pkt_size <= rx_copybreak) 
    return -1;
                }

                tp->new_skb = skb;
        }

Is this acceptable?

> > Actually, talking about this gave me an idea.  Since desc_part is the
> > largest skb we will ever need (aside from when they are combined), it
> > would be more efficient to use that instead of the full size.  I will
> > create a patch for this (and the mb changes) and resubmit it.  Let me
> > know if you want me to return other things to their original spot.
>
> I am not sure I understand exactly what you mean. If you are saying that
> the max size is known and can be allocated in advance so that only the
> rx_copybreak calls for an instant allocation, we are saying the same thing
> (actually this should have been point 3- above :o) ).

No, I am saying that the max size is know for the skb rx ring and it is not 
rx_buf_sz, but desc_part.   I don't currently have this in the driver, but I 
can add it where driver allocs smaller skbs for jumbo frames enabled rx ring.  

If I am still not making sense, I can be more verbose.

> It will make my life easier if the patch only contains the minimal amount
> of changes (easier reviewing, testing, confidence, blah blah, it's boring
> but you got the idea).

Sorry, I guess I got a little over eager.  I will attempt to avoid this 
behavior in the future.  Forgiveness please.

> > > 6 - skb_put() ends duplicated. It should be possible to avoid it.
> >
> > Is it?  I was specifically trying to aviod that.  Where do you see that?
>
> ->
> +   if (rtl8169_rx_copy(&skb, pkt_size, desc, tp)) {
>      pci_action = pci_unmap_single;
>      tp->Rx_skbuff[entry] = NULL;
> +    skb_put(skb, pkt_size);
>     }
>
> -> rtl8169_rx_copy()
> Lots of skb_put()

Actually, I am using skb_put more frequently for a reason, and I probably need 
to explain why.  In rtl8169_rx_copy(), I am using it to keep track of the end 
of the skb, so that the driver knows the point to concatinate the next desc 
to the skb.  when it is all over, the tail points to the end of the skb and 
len is correct (which is the whole point of using skb_put), thereby removing 
the need to call it in the jumbo frames case.  

I realize this is being a little creative, but it is much cleaner code this 
way.  Otherwise the driver will need a global counter to use as a offset of 
the skb->tail and call skb_put after it is all over.  

> Don't bother too much about this one. I had expected to keep the
> skb->dev = ...; skb_put(...); skb->proto = ... sequence as is to
> minimize the changes but it is not necessarily doable/sane.
>
> --
> Ueimor

I will clean-up what I currently have with the changes you suggested and 
resend it.

Thanks,
Jon
