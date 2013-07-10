From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: pull on receive skb may need
 to happen earlier
Date: Wed, 10 Jul 2013 11:04:16 +0100
Message-ID: <20130710100416.GL19798@zion.uk.xensource.com>
References: <51D57C1F.8070909@hunenet.nl>
 <20130704150137.GW7483@zion.uk.xensource.com>
 <51D6AED902000078000E2EA9@nat28.tlf.novell.com>
 <20130705145319.GB9050@zion.uk.xensource.com>
 <51DAA9B202000078000E3357@nat28.tlf.novell.com>
 <51DAE6CA02000078000E3566@nat28.tlf.novell.com>
 <20130708154814.GI8027@zion.uk.xensource.com>
 <51DBCF4F02000078000E3793@nat28.tlf.novell.com>
 <20130709165134.GG19798@zion.uk.xensource.com>
 <51DD221E02000078000E3BC6@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, <davem@davemloft.net>,
	Dion Kant <g.w.kant@hunenet.nl>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <stable@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51DD221E02000078000E3BC6@nat28.tlf.novell.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 10, 2013 at 07:58:06AM +0100, Jan Beulich wrote:
> >>> On 09.07.13 at 18:51, Wei Liu <wei.liu2@citrix.com> wrote:
> > On Tue, Jul 09, 2013 at 07:52:31AM +0100, Jan Beulich wrote:
> >> >>> On 08.07.13 at 17:48, Wei Liu <wei.liu2@citrix.com> wrote:
> >> > On Mon, Jul 08, 2013 at 03:20:26PM +0100, Jan Beulich wrote:
> >> >> @@ -1014,7 +1025,7 @@ err:
> >> >>  
> >> >>  		skb_shinfo(skb)->frags[0].page_offset = rx->offset;
> >> >>  		skb_frag_size_set(&skb_shinfo(skb)->frags[0], rx->status);
> >> >> -		skb->data_len = rx->status;
> >> >> +		skb->len = skb->data_len = rx->status;
> >> > 
> >> > This is not correct. You should not be needing this. Now you lose count
> >> > of SKB head len. Try to go without the above line and see if it makes a
> >> > difference?
> >> 
> >> I don't follow - at this point, there's 0 bytes of head (this only
> >> changes with the first call to __pskb_pull_tail()). Hence ->len ==
> >> ->data_len seems correct to me (and afaict pulling would do the
> >> wrong thing if I dropped that change).
> >> 
> > 
> > My bad, I suggested the wrong thing. :-(
> > 
> > But I would prefer skb->len += skb->data_len. In the case that skb->len
> > == 0 it's the same as your line while skb->len is not zero it would also
> > do the right thing.
> 
> I can do that, albeit I don't see how ->len could end up non-zero
> here.
> 
> > As for the warning in skb_try_coalesce, I don't see any direct call to
> > it in netfront, I will need to think about it. It looks like it's really
> > something very deep in the stack.
> 
> Yes, as the call stack provided by Dion proves. The question
> really is whether the patch somehow results in ->truesize to be
> incorrect, or whether - as Eric points out - this is "normal" for
> the sort of special SKBs here (having a rather small headlen). If
> what he says is applicable here, it may hint at the pulling we do
> still not being sufficient for the full TCP header to be in the linear

__netdev_alloc_skb in netfront is fed with RX_COPY_THRESHOLD+NET_IP_ALIGN.
RX_COPY_THRESHOLD is 256 while MAX_TCP_HEADER can be as larger as 256+48
depending on kernel configurations.

> part (which iirc is the main [if not the only purpose] of us doing
> the pull in the first place).
> 

Ian, any comment on this?

Jan, looking at the commit log, the overrun issue in
xennet_get_responses was not introduced by __pskb_pull_tail. The call to
xennet_fill_frags has always been in the same place.

Now I start to think about the purpose of "max = MAX_SKB_FRAGS +
(rx->status <= RX_COPY_THRESHOLD)" in xennet_get_responses which queues
up to MAX_SKB_FRAGS+1 responeses. I'm not clear about the rationale
of that line.


Wei.

> Jan
