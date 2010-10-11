From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: RE: [PATCH net-next 2/5] bnx2x: save cycles in setting gso_size
Date: Mon, 11 Oct 2010 01:53:02 -0700
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AADDDEE4281D8@SJEXCHCCR02.corp.ad.broadcom.com>
References: <1286749675.4669.24.camel@lb-tlvb-dmitry>
 <20101010.205254.193716921.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3306 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753652Ab0JKIxO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 04:53:14 -0400
In-Reply-To: <20101010.205254.193716921.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, October 11, 2010 5:53 AM
> To: Dmitry Kravkov
> Cc: netdev@vger.kernel.org; Vladislav Zolotarov; Eilon Greenstein
> Subject: Re: [PATCH net-next 2/5] bnx2x: save cycles in setting
> gso_size
> 
> From: "Dmitry Kravkov" <dmitry@broadcom.com>
> Date: Mon, 11 Oct 2010 00:27:55 +0200
> 
> > diff --git a/drivers/net/bnx2x/bnx2x_cmn.c
> b/drivers/net/bnx2x/bnx2x_cmn.c
> > index cb2a3d6..ddf90e1 100644
> > --- a/drivers/net/bnx2x/bnx2x_cmn.c
> > +++ b/drivers/net/bnx2x/bnx2x_cmn.c
> > @@ -277,8 +277,7 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp,
> struct bnx2x_fastpath *fp,
> >
> >  	/* This is needed in order to enable forwarding support */
> >  	if (frag_size)
> > -		skb_shinfo(skb)->gso_size = min((u32)SGE_PAGE_SIZE,
> > -					       max(frag_size, (u32)len_on_bd));
> > +		skb_shinfo(skb)->gso_size = 1;
> >
> 
> I wonder why you need to set this here.
> 
> When you pass this packet into the stack, dev_gro_receive() is going
> to set ->gro_size() unconditionally if any GRO processing is going to
> occur at all.
> 
> Why do you need to set it at all?

Dave, it's a gSo_size, not a gRo_size and we are handling an LRO skb
here. It's quite confusing, I agree... ;) This is currently the way 
to mark an LRO skb in order to properly handle the LRO skbs that 
might still be forwarded to the stack short time after the LRO has 
been disabled due to enabling the IP forwarding (or if there is a 
bug in a driver).
See the skb_warn_if_lro() below:

static inline bool skb_warn_if_lro(const struct sk_buff *skb)
{
	/* LRO sets gso_size but not gso_type, whereas if GSO is really
	 * wanted then gso_type will be set. */
	struct skb_shared_info *shinfo = skb_shinfo(skb);
	if (skb_is_nonlinear(skb) && shinfo->gso_size != 0 &&
	    unlikely(shinfo->gso_type == 0)) {
		__skb_warn_lro_forwarding(skb);
		return true;
	}
	return false;
}

So, the convention is to set the gSo_size to a none-zero value leaving
the gSo_type zero for an LRO skbs. It's quite hacky but this is what
we have for quite a while and it quite worked so far. ;) To make it 
cleaner we might have done the following:

1) added a new member to the SKB_GSO_XXX family enum since we are riding
on the gso_type anyway. In that case there should have been the following
line in the LRO flow:

if (frag_size)
	skb_shinfo(skb)->gso_type = SKB_LSO_TYPE;


and skb_warn_if_lro() should have been reworked appropriately.
	
2) Change the name of the gso_type field to something like skb_type 
and this would make the LRO flow crystal clear then but would require 
changes in quite a few places.

So, the question is do we want to start all this? ;)

Regarding the current patch itself: we wanted to save the extra 
(not needed at all) calculations in the LRO bnx2x flow considering that 
current semantics requires the gso_size to be none zero for the LRO skb.

> 
> And if we do need it, doesn't every driver that builds fragmented SKBs?

I guess the answer is "yes".

> And if it's correct, why is setting a don't care value like "1" ok and
> will not cause problems to whoever cares about this value?

I disagree with your definition of "don't care" - it's quite "care"... ;)

I guess I've answered this question above but the bottom line would
be: because it's the current semantics to mark the LRO skb and it's
done exactly for reason that there is somebody out there who cares... ;)

Thanks,
vlad

> 
> I really want all of these questions answered, and at least lightly
> explained in the commit message before I apply this patch.
> 
> Thanks.


