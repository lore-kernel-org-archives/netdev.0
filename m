From: "Michael Chan" <mchan@broadcom.com>
Subject: RE: [PATCH v2 net 2/2] tg3: Fix data corruption on 5725 with
 TSO
Date: Tue, 14 May 2013 09:19:05 -0700
Message-ID: <1368548345.12268.76.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1368479056-11780-1-git-send-email-nsujir@broadcom.com>
 <1368479056-11780-3-git-send-email-nsujir@broadcom.com>
 <1368479644.13473.121.camel@edumazet-glaptop>
 <51915C7D.2000407@broadcom.com>
 <1368481224.13473.124.camel@edumazet-glaptop>
 <51915F77.5000405@broadcom.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7236@saturn3.aculab.com>
 <1368543869.12268.49.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7237@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: "David Laight" <David.Laight@ACULAB.COM>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7237@saturn3.aculab.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-05-14 at 16:20 +0100, David Laight wrote: 
> > On Tue, 2013-05-14 at 09:40 +0100, David Laight wrote:
> > > > >>>> +        if (tg3_asic_rev(tp) == ASIC_REV_5762 && mss) {
> > > > >>>> +                u32 base = (u32) mapping & 0xffffffff;
> > > > >>>> +
> > > > >>>> +                return ((base + len + (mss & 0x3fff)) < base);
> > > ...
> > > > For the bug to occur, the fragment does not have to span a 4G boundary. If it is
> > > > within MSS bytes (9.6k) of a 4G boundary, it triggers the failure.
> > >
> > > Would it be worth simplifying the test to assume that 'len'
> > > is 64k and 'mss' 9.6k?
> > > (commenting on the actual condition.)
> > > The number of false positives would be small, but the test
> > > a lot quicker.
> > > The '(u32)mapping + (0x10000 + 9600) < (u32)mapping' test might
> > > even be faster than the ' tg3_asic_rev(tp) == ASIC_REV_5762' one.
> > 
> > I think that if we do this and detect a false positive, it may be very
> > far from the 4G boundary.
> 
> It can't be very far away, approx 1 in 65k checks would fail.
> You could do the finer test afterwards.

If we do a 2nd level test, it will be ok.  But I'm not sure if it is
worth the complexity.

> 
> > The new skb that we allocate to workaround the condition may be
> > even closer to 4G and may hit the real bug condition.
> 
> If the 'fix' is to relocate the skb you are doomed to lose regardless
> of the check - unless you are willing to reallocate a lot of times,
> and without freeing the old skb.
> I'd assumed the 'fix' was to disable the relevant offload.

We relocate once and then drop the packet if we encounter additional
errors, including OOM, DMA mapping error, 4G boundary, etc.  The new
linear skb should not hit the 4G boundary again.  The room between the
end of this current buffer and 4G isn't big enough for the new linear
skb.

> 
> > The mss and len values are accessed many times in this immediate code
> > path just before setting the TX BD, gcc should be able to optimize this
> > quite nicely.
> 
> I was looking at the number of branches in the hot path, not whether
> the values were already in registers.
> 

Isn't the number of branches the same whether we use actual values in
registers or fixed values?
