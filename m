From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: Re: IPv6 and encapsulation headers
Date: Tue, 13 Jul 2004 10:42:41 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407131042.41346.kazunori@miyazawa.org>
References: <20040710033209.GA14316@gondor.apana.org.au> <200407121732.52542.kazunori@miyazawa.org> <20040712104710.GC965@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040712104710.GC965@gondor.apana.org.au>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

2004/07/12(月) 19:47、Herbert Xu  wrote:
> On Mon, Jul 12, 2004 at 05:32:52PM +0900, Kazunori Miyazawa wrote:
> > right, esp6 tunnel doesn't care about skb->h.raw. we need to fix it.
>
> The same needs to be done to the other tunnels as well.  But please
> consider the issue in the next paragraph first before doing this.
>
> > > So should it be changed to ip6_find_1stfragopt() as is the case with
> > > esp6 and ipcomp6?
> >
> > Do we need to skip esp or ipcomp payload?
> > I thinks those are similar with transport layer protocol in outer esp
> > process. Did I misunderstand your question?
>
> I don't know because I didn't understand your question :)
>
> Let me state a few things and please tell me whether you agree or
> disagree:
>
> 1. AH's position should be determined by the bundle.  So if the
> bundle says AH+ESP then AH goes on the outside, if the bundle says
> ESP+AH or just AH then AH goes on the inside.
>
agree. 

> 2. If AH is the inner-most xfrm then it should be applied before
> the second destination options header.
Yes.

>
> It seems to me that skb->h is not actually set to the spot pointed
> to ip6_find_1stfragopt() by anything apart from the xfrm output
> functions.
>
> Therefore if AH is the inner-most xfrm, then skb->h will also point
> to the wrong spot.  It would appear to be safest to call
> ip6_find_1stfragopt() in AH instead of relying on the value of skb->h.
>
I agree with you. It should uses ip6_find_1stfragopt.
However please consider zero_out_mutable_opts in ah6.c clears second 
destination options. We need to get the copy length by other way.
Because ip6_find_1stfragopt returns the insert point of IPsec.

> Regardless of whether we use skb->h or ip6_find_1stfragopt() though,
> ah6/esp6/ipcomp6 should all use the same logic to find their spot for
> encapsulation.  The reason is that the specification in 2402/2406/3173
> is identical so we shouldn't have special-case code in AH.
>
> > Because fragmentation takes place after IPsec processing,
> > do we need to make ip6_find_1stfragopt care fragment header?
> > I think there is no fragment header in skb at that point.
>
> Good point.
>
> Hmm, what about address spoofing? Is there code in IPv6 to prevent
> another machine from relaying a packet through us with our source
> address?
>
Does it concern with IPsec or fragmentation?
It might be netfiler stuff. 

Thank you,

--Kazunori Miyazawa
