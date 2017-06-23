From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: DNS (?) not working on G5 (64-bit powerpc) (was
 [net-next,v3,3/3] udp: try to avoid 2 cache miss on dequeue)
Date: Fri, 23 Jun 2017 13:59:41 +0200
Message-ID: <1498219181.2611.6.camel@redhat.com>
References: <87shisqihz.fsf@concordia.ellerman.id.au>
         <1498165026.2503.21.camel@redhat.com>
         <1498166297.111795.1018373424.5E414246@webmail.messagingengine.com>
         <87r2ybp4ud.fsf@concordia.ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org
To: Michael Ellerman <mpe@ellerman.id.au>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45046 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751189AbdFWL7p (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Jun 2017 07:59:45 -0400
In-Reply-To: <87r2ybp4ud.fsf@concordia.ellerman.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-06-23 at 16:59 +1000, Michael Ellerman wrote:
> Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
> 
> > On Thu, Jun 22, 2017, at 22:57, Paolo Abeni wrote:
> > > 
> > > Can you please check if the following patch fixes the issue? Only
> > > compiled tested here.
> > > 
> > > Thanks!!!
> > > ---
> > > diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> > > index 067a607..80d89fe 100644
> > > --- a/net/ipv4/udp.c
> > > +++ b/net/ipv4/udp.c
> > > @@ -1446,16 +1446,19 @@ static struct sk_buff
> > > *__first_packet_length(struct sock *sk,
> > >  {
> > >  	struct sk_buff *skb;
> > >  
> > > -       while ((skb = skb_peek(rcvq)) != NULL &&
> > > -              udp_lib_checksum_complete(skb)) {
> > > -               __UDP_INC_STATS(sock_net(sk), UDP_MIB_CSUMERRORS,
> > > -                               IS_UDPLITE(sk));
> > > -               __UDP_INC_STATS(sock_net(sk), UDP_MIB_INERRORS,
> > > -                               IS_UDPLITE(sk));
> > > -               atomic_inc(&sk->sk_drops);
> > > -               __skb_unlink(skb, rcvq);
> > > -               *total += skb->truesize;
> > > -               kfree_skb(skb);
> > > +       while ((skb = skb_peek(rcvq)) != NULL) {
> > > +               if (udp_lib_checksum_complete(skb)) {
> > > +                       __UDP_INC_STATS(sock_net(sk), UDP_MIB_CSUMERRORS,
> > > +                                       IS_UDPLITE(sk));
> > > +                       __UDP_INC_STATS(sock_net(sk), UDP_MIB_INERRORS,
> > > +                                       IS_UDPLITE(sk));
> > > +                       atomic_inc(&sk->sk_drops);
> > > +                       __skb_unlink(skb, rcvq);
> > > +                       *total += skb->truesize;
> > > +                       kfree_skb(skb);
> > > +               } else {
> > > +                       udp_set_dev_scratch(skb);
> > 
> > It needs a "break;" here.
> > 
> > > +               }
> > >  	}
> > >  	return skb;
> > >  }
> 
> That works!
> 
> $ wget google.com
> --2017-06-23 16:56:31--  http://google.com/
> Resolving proxy.pmdw.com (proxy.pmdw.com)... 10.1.2.3
> Connecting to proxy.pmdw.com (proxy.pmdw.com)|10.1.2.3|:3128... connected.
> Proxy request sent, awaiting response... 302 Found
> Location: http://www.google.com.au/?gfe_rd=cr&ei=n7tMWeb9JYPr8wfg4LXYAQ [following]
> --2017-06-23 16:56:31--  http://www.google.com.au/?gfe_rd=cr&ei=n7tMWeb9JYPr8wfg4LXYAQ
> Reusing existing connection to proxy.pmdw.com:3128.
> Proxy request sent, awaiting response... 200 OK
> Length: unspecified [text/html]
> Saving to: ‘index.html’
> 
> 
> The patch had whitespace issues or something and I had to apply it by
> hand, here's what I actually tested.

Thank you!

I'll submit formally the patch after some more testing.

I noticed this version has entered the ppc patchwork, but I think that
the formal submission should go towards the net-next tree.

Cheers,

Paolo
