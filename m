From: Matt Domsch <Matt_Domsch-8PEkshWhKlo@public.gmane.org>
Subject: Re: [Fwd: [patch 02/15] ppp_mppe: add PPP MPPE encryption module]
Date: Sun, 14 Aug 2005 09:07:24 -0500
Message-ID: <20050814140724.GA20944@lists.us.dell.com>
References: <42B747C9.7060901@pobox.com> <17102.26269.264419.345257@cargo.ozlabs.ibm.com> <17102.30763.326707.473425@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, akpm-3NddpPZAyC0@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Brice.Goglin-vYW+cPY1g1pg9hUCZPvPmw@public.gmane.org, james.cameron-VXdhtT5mjnY@public.gmane.org,
	pptpclient-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <pptpclient-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <17102.30763.326707.473425-UYQwCShxghk5kJ7NmlRacFaTQe2KTcn/@public.gmane.org>
Sender: pptpclient-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: pptpclient-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/pptpclient-devel>,
	<mailto:pptpclient-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:pptpclient-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:pptpclient-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/pptpclient-devel>,
	<mailto:pptpclient-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=pptpclient-devel>
List-Id: netdev.vger.kernel.org

On Fri, Jul 08, 2005 at 09:42:21PM +1000, Paul Mackerras wrote:
> Some comments on the MPPE kernel patch (sorry it's taken me so long):

Likewise, my apologies for the delay in implementing your
suggestions.  I do really appreciate your feedback.

 
> > +static inline struct sk_buff *
> > +pad_compress_skb(struct ppp *ppp, struct sk_buff *skb)
> > +{
> > +	struct sk_buff *new_skb;
> > +	int len;
> > +	int new_skb_size = ppp->dev->mtu + ppp->xcomp->comp_skb_extra_space + ppp->dev->hard_header_len;
> > +	int compressor_skb_size = ppp->dev->mtu + ppp->xcomp->comp_skb_extra_space + PPP_HDRLEN;
> 
> This would be nicer if you broke these lines each into two lines.  It
> would help if you chose shorter names for comp_skb_extra_space and
> decomp_skb_extra_space (just comp_extra, for instance).  And why do we
> need decomp_skb_extra_space anyway?  We expect the decompressor to
> expand things; if they shrink (as they will with MPPE) we don't have
> to do anything special.

Done.
 
> > +	} else {
> > +		/*
> > +		 * (len < 0)
> > +		 * MPPE requires that we do not send unencrypted
> > +		 * frames.  The compressor will return -1 if we
> > +		 * should drop the frame.  We cannot simply test
> > +		 * the compress_proto because MPPE and MPPC share
> > +		 * the same number.
> > +		 */
> > +		if (net_ratelimit())
> > +			printk(KERN_ERR "ppp: compressor dropped pkt\n");
> > +		kfree_skb(new_skb);
> > +		new_skb = NULL;
> 
> I think we just leaked the original skb in this case.

Good catch, fixed.

 
> > @@ -1683,7 +1716,7 @@ ppp_decompress_frame(struct ppp *ppp, st
> >  		goto err;
> >  
> >  	if (proto == PPP_COMP) {
> > -		ns = dev_alloc_skb(ppp->mru + PPP_HDRLEN);
> > +		ns = dev_alloc_skb(ppp->mru + ppp->rcomp->decomp_skb_extra_space + PPP_HDRLEN);
> >  		if (ns == 0) {
> >  			printk(KERN_ERR "ppp_decompress_frame: no memory\n");
> >  			goto err;
> 
> I don't see where you make sure that you drop any unencrypted received
> frames.

Fixed.

On Fri, Jul 08, 2005 at 10:57:15PM +1000, Paul Mackerras wrote:
> To follow up on my comments on the mppe patch, it still misses the
> most important thing, which is to make sure you don't send unencrypted
> data if CCP should go down.  A received CCP TermReq or TermAck will
> clear the SC_DECOMP_RUN flag and the code will then ignore the
> xcomp->must_compress flag.
> 
> I really think there should be another flag bit set by pppd to say
> "must compress" rather than relying on the compressor telling you
> that.

I've added a new flag SC_MUST_COMPRESS, which pppd sets on CCP UP with
MPPE enabled, and never clears it.  The new kernel code checks for
this flag at both compression and decompression time, and drops the
packets if compression or decompression fails.

pppd also drops LCP (thus the connection) if CCP goes down or gets
renegotiated, as tested with kill -USR2 $pid-of-pppd.  So a user can't
force renegotiation without losing their connection.

Kernel and pppd patches will follow in separate messages.  Lightly
tested, additional review much appreciated.

Thanks,
Matt

-- 
Matt Domsch
Software Architect
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
