From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next 3/3] udp: try to avoid 2 cache miss on dequeue
Date: Thu, 01 Jun 2017 12:46:27 +0200
Message-ID: <1496313987.4872.16.camel@redhat.com>
References: <cover.1496070490.git.pabeni@redhat.com>
         <53a22c4f792ffd2efe76e233212185ecee868c1a.1496070490.git.pabeni@redhat.com>
         <1496250276.27480.9.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40248 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751369AbdFAKqa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 06:46:30 -0400
In-Reply-To: <1496250276.27480.9.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-05-31 at 10:04 -0700, Eric Dumazet wrote:
> On Mon, 2017-05-29 at 17:27 +0200, Paolo Abeni wrote:
> > when udp_recvmsg() is executed, on x86_64 and other archs, most skb
> > fields are on cold cachelines.
> > If the skb are linear and the kernel don't need to compute the udp
> > csum, only a handful of skb fields are required by udp_recvmsg().
> > Since we already use skb->dev_scratch to cache hot data, and
> > there are 32 bits unused on 64 bit archs, use such field to cache
> > as much data as we can, and try to prefetch on dequeue the relevant
> > fields that are left out.
> > 
> > This can save up to 2 cache miss per packet.
> 
> okay ;)
> 
> > 
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> > ---
> >  net/ipv4/udp.c | 114 +++++++++++++++++++++++++++++++++++++++++++++++++++------
> >  1 file changed, 103 insertions(+), 11 deletions(-)
> > 
> > diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> > index 53fa48d..616132e 100644
> > --- a/net/ipv4/udp.c
> > +++ b/net/ipv4/udp.c
> > @@ -1163,6 +1163,83 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
> >  	return ret;
> >  }
> >  
> > +/* Copy as much information as possible into skb->dev_scratch to avoid
> > + * possibly multiple cache miss on dequeue();
> > + */
> > +#if BITS_PER_LONG == 64
> > +
> > +/* we can store multiple info here: truesize, len and the bit needed to
> > + * compute skb_csum_unnecessary will be on cold cache lines at recvmsg
> > + * time.
> > + * skb->len can be stored on 16 bits since the udp header has been already
> > + * validated and pulled.
> > + */
> > +struct udp_dev_scratch {
> > +	__u32 truesize;
> > +	__u16 len;
> > +	__u16 is_linear:1;
> > +	__u16 csum_unnecessary:1;
> 
> What about 
> 	u32   truesize;
> 	u16   len;
> 	bool  is_linear;
> 	bool  csum_unnecessary;
> 
> I do not believe the __ prefix is necessary for a local structure (not
> uapi)
> 
> Also a plain bool or u8 is faster than a bit field (shorter
> instructions)

Thank you! I like the above! I'll go for 'bool' usage in v2,

Paolo

p.s. I used the bitfield because I initially had an additional, very
ugly, patch saving another cache miss and requiring one more bit there,
 but said patch hurted so much the sight that I had to drop it.
