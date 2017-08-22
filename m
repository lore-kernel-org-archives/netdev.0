From: Koichiro Den <den@klaipeden.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Tue, 22 Aug 2017 23:04:28 +0900
Message-ID: <1503410668.8694.14.camel@klaipeden.com>
References: <20170819063854.27010-1-den@klaipeden.com>
         <CAF=yD-LYLsQNt_5yYZ+PUwv04ZwaJUXn-YakH=tuh0TV+BG7iA@mail.gmail.com>
         <CAF=yD-LO0rP1A_hrxqx_1HYEv6qyk=Sc=D7iH7cPh2YXDm=cYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-of-o52.zoho.com ([135.84.80.217]:21418 "EHLO
        sender-of-o52.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933018AbdHVOEg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 10:04:36 -0400
In-Reply-To: <CAF=yD-LO0rP1A_hrxqx_1HYEv6qyk=Sc=D7iH7cPh2YXDm=cYQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-22 at 08:11 -0400, Willem de Bruijn wrote:
> On Sun, Aug 20, 2017 at 4:49 PM, Willem de Bruijn
> <willemdebruijn.kernel@gmail.com> wrote:
> > On Sat, Aug 19, 2017 at 2:38 AM, Koichiro Den <den@klaipeden.com> wrote:
> > > Facing the possible unbounded delay relying on freeing on xmit path,
> > > we also better to invoke and clear the upper layer zerocopy callback
> > > beforehand to keep them from waiting for unbounded duration in vain.
> > 
> > Good point.
> > 
> > > For instance, this removes the possible deadlock in the case that the
> > > upper layer is a zerocopy-enabled vhost-net.
> > > This does not apply if napi_tx is enabled since it will be called in
> > > reasonale time.
> > 
> > Indeed. Btw, I am gathering data to eventually make napi the default
> > mode. But that is taking some time.
> > 
> > > 
> > > Signed-off-by: Koichiro Den <den@klaipeden.com>
> > > ---
> > >  drivers/net/virtio_net.c | 8 ++++++++
> > >  1 file changed, 8 insertions(+)
> > > 
> > > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > > index 4302f313d9a7..f7deaa5b7b50 100644
> > > --- a/drivers/net/virtio_net.c
> > > +++ b/drivers/net/virtio_net.c
> > > @@ -1290,6 +1290,14 @@ static netdev_tx_t start_xmit(struct sk_buff *skb,
> > > struct net_device *dev)
> > > 
> > >         /* Don't wait up for transmitted skbs to be freed. */
> > >         if (!use_napi) {
> > > +               if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
> > > +                       struct ubuf_info *uarg;
> > > +                       uarg = skb_shinfo(skb)->destructor_arg;
> > > +                       if (uarg->callback)
> > > +                           uarg->callback(uarg, true);
> > > +                       skb_shinfo(skb)->destructor_arg = NULL;
> > > +                       skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
> > > +               }
> > 
> > Instead of open coding, this can use skb_zcopy_clear.
> 
> It is not correct to only send the zerocopy completion here, as
> the skb will still be shared with the nic. The only safe approach
> to notifying early is to create a copy with skb_orphan_frags_rx.
> That will call skb_zcopy_clear(skb, false) internally. But the
> copy will be very expensive.
I noticed this email after my last post. I cannot not imagine how it could be
unsafe in virtio case. Sorry could you explain a bit more?
> 
> Is the deadlock you refer to the case where tx interrupts are
> disabled, so transmit completions are only handled in start_xmit
> and somehow the socket(s) are unable to send new data? The
> question is what is blocking them. If it is zerocopy, it may be a
> too low optmem_max or hitting the per-user locked pages limit.
> We may have to keep interrupts enabled when zerocopy skbs
> are in flight.
Even if we keep interrupts enabled, We miss the completion without start_xmit.
And it's also likely that the next start_xmit depends on the completion itself
as I described in my last post.
