From: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Subject: Re: [PATCH] mac80211: rewrite fragmentation code
Date: Fri, 16 May 2008 20:32:48 +1000
Message-ID: <200805162032.48469.rusty@rustcorp.com.au>
References: <20080508032208.GA401@gondor.apana.org.au> <200805161201.48835.rusty@rustcorp.com.au> <20080515.215823.28841530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080515.215823.28841530.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 16 May 2008 14:58:23 David Miller wrote:
> From: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
> Date: Fri, 16 May 2008 12:01:48 +1000
>
> > Dave, please allow me to ask a heretical question.  Returning
> > TX_BUSY has some appeal for virtio_net: is it fundamentally a flawed
> > idea, or simply a matter of coding?
>
> Allowing TX_BUSY adds a special case to the caller which we'd
> like to remove at some point.
>
> > Currently we have no virtio interface to ask how many descriptors are
> > left; it's not clear that it's a fair question to ask, since for Xen it's
> > depends on the actual buffers we're trying to put in the descirptors.
>
> Two things:
>
> 1) You can always make sure that you have enough space for a
>    TSO frame, with arbitrary page boundaries and thus buffer
>    chopping.
>
>    It can even be estimated, and if violated by some corner case
>    you can punt and drop.

Yes, this is what we'd have to do.  Wasting room in the ring feels wrong 
though.

> 2) You can queue inside of the driver one packet when you hit
>    the limits unexpectedly, netif_stop_queue(), and return
>    success.  Spit this packet out right before waking the
>    queue again.

I put a patch in to do exactly that at Herbert's prompting, for 2.6.26, but 
it's buggy in (at least) two ways.  I have a fix for this, which adds a new 
tasklet to xmit the packet.  There's still some subtle race, however, since 
I'm still seeing a stuck packet.  I'll have to revert to TX_BUSY for 2.6.26 
if I can't find it (unlikely).

And I haven't measured what it does to performance (should be OK, but still).

> Really, there are no hard reasons to ever return TX_BUSY,
> it's always a bug.

But it's *simple*, and seems like a common thing to want.  Why not change 
everything to use TX_BUSY and rip out the guestimate/buffering hacks?

> In fact, I want to move things more and more towards the driver
> queueing TX packets internally instead of the networking mid-layer.
>
> That will ahve benefits for things like TX multiqueue, we won't
> need any locking at all, nor have any knowledge about multiple
> queues at all, if the driver takes care of providing the buffer
> between what the kernel gives it and what the device can handle
> at the moment.

That would be great: then I could shove the packet back on the queue myself 
and not have to ask you about it.  It's adding a *second* queue inside the 
driver which feels terribly ugly...

Cheers,
Rusty.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
