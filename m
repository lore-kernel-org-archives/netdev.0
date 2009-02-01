From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: hardware time stamping with optional structs in data area
Date: Sun, 01 Feb 2009 00:14:15 -0800 (PST)
Message-ID: <20090201.001415.201448053.davem@davemloft.net>
References: <1233069837.24438.54.camel@pohly-MOBL>
	<20090128090821.GA15770@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090128090821.GA15770-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Date: Wed, 28 Jan 2009 20:08:21 +1100

> Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:
> >
> > True - at this time. But what if this extension mechanism turns out to
> > be useful and we end up with more optional structures? I was hoping that
> > this might be the case and thus tried to make it easy to add more
> > structures.
> 
> You're putting the extension in the skb->end area, right?
> 
> How big are the time stamps? If they're not that big, why don't
> we put it into the shinfo structure itself? For the common case,
> we have plenty of space due to kmalloc padding anyway.

I did some thinking about this, and for the time being
I think we should stick all of these new pieces of
timestamp information in the skb shared info structure
and unconditionally.

Use unions where possible, but besides that don't try to
be clever at all.  We'll try to optimize this later.

So you can therefore get rid of all of this conditional sizing and
other complexity, which is distracting from what the patch is actually
doing.  As a result I expect patch #2 to shrink to basically nothing :)
Patch #4 should also become unnecessary, etc. etc.

Other than that, I went over the patches again, and here is some other
feedback:

1) Please kill the SO_TIMESTAMPING/SCM_TIMESTAMPING/SIOCHWTSTAMP
   fallback definition in linux/net_tstamp.h

   We don't do things like that.  The SIOCHWTSTAMP one was using
   __kernel__ (lowercase) instead of __KERNEL__ so it wouldn't
   work anyways :-)

2) Please fix up some coding style issues.  For example, when you have
   a multiline conditional as you do in sock_recv_timestamp(), format
   it like this:

	if (a ||
	    b ||
	    c)

   instead of the two tab thing you're doing on the lines after the
   first one in the conditional.  There are many cases of this, so
   please go over all of your patches and review for this.

   The sock_tx_timestamp() declaration has similar issues.  Make the
   arguments on the subsequent lines start right after the openning
   parenthesis on the first line.

   Please don't use braces for a basic block composed of only one
   line, it's just wasted space, for example:

	if (sock_flag(sk, SOCK_TIMESTAMPING_TX_HARDWARE)) {
		shtx->hardware = 1;
	}

   should be just:

	if (sock_flag(sk, SOCK_TIMESTAMPING_TX_HARDWARE))
		shtx->hardware = 1;

   I could go on and on, but that's pointless, just read
   Documentation/CodingStyle and use checkpatch.pl output as a
   further guide.

3) In the debug check added by patch #6 please use a construct such as
   WARN_ON() or WARN_ON_ONCE(), it can even be embedded in a
   conditional.

4) Please get patches #9 and #11 on a fresh review on linux-kernel
   with the timer maintainers CC:'d.  Once they ACK, get a figure on
   how we can arrange the merge of these changes.

   Just like you I think we have to merge this in via the net tree
   since the only user we have is this hwtstamp networking stuff.  So
   please express that and try to get the timer folk's blessing on
   that.

5) Finally, try to put the driver patches at the end so that they
   finish the patch series and the driver maintainer ACK'ing can
   be handled seperately and won't hold up the infrastructure patches.

Otherwise this stuff looks good, please keep working on this stuff!
--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
