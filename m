From: Koichiro Den <den@klaipeden.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Wed, 23 Aug 2017 23:47:22 +0900
Message-ID: <1503499642.8694.27.camel@klaipeden.com>
References: <20170819063854.27010-1-den@klaipeden.com>
         <5352c98a-fa48-fcf9-c062-9986a317a1b0@redhat.com>
         <CAF=yD-LZ4=WAYfUtY7xRWi50FRSkrcOa+b7uc46xRnC4sbDCzQ@mail.gmail.com>
         <64d451ae-9944-e978-5a05-54bb1a62aaad@redhat.com>
         <20170822204015-mutt-send-email-mst@kernel.org>
         <1503498504.8694.26.camel@klaipeden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-of-o52.zoho.com ([135.84.80.217]:21422 "EHLO
        sender-of-o52.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753985AbdHWOr3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 10:47:29 -0400
In-Reply-To: <1503498504.8694.26.camel@klaipeden.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-08-23 at 23:28 +0900, Koichiro Den wrote:
> On Tue, 2017-08-22 at 20:55 +0300, Michael S. Tsirkin wrote:
> > On Tue, Aug 22, 2017 at 10:50:41AM +0800, Jason Wang wrote:
> > > > Perhaps the descriptor pool should also be
> > > > revised to allow out of order completions. Then there is no need to
> > > > copy zerocopy packets whenever they may experience delay.
> > > 
> > > Yes, but as replied in the referenced thread, windows driver may treat out
> > > of order completion as a bug.
> > 
> > That would be a windows driver bug then, but I don't think it makes this
> > assumption. What the referenced thread
> > (https://patchwork.kernel.org/patch/3787671/) is saying is that host
> > must use any buffers made available on a tx vq within a reasonable
> > timeframe otherwise windows guests panic.
> > 
> > Ideally we would detect that a packet is actually experiencing delay and
> > trigger the copy at that point e.g. by calling skb_linearize. But it
> > isn't easy to track these packets though and even harder to do a data
> > copy without races.
> > 
> > Which reminds me that skb_linearize in net core seems to be
> > fundamentally racy - I suspect that if skb is cloned, and someone is
> > trying to use the shared frags while another thread calls skb_linearize,
> > we get some use after free bugs which likely mostly go undetected
> > because the corrupted packets mostly go on wire and get dropped
> > by checksum code.
> > 
> 
> Please let me make sure if I understand it correctly:
> * always do copy with skb_orphan_frags_rx as Willem mentioned in the earlier
> post, before the xmit_skb as opposed to my original patch, is safe but too
> costly so cannot be adopted.
> * as a generic solution, if we were to somehow overcome the safety issue,
> track
> the delay and do copy if some threshold is reached could be an answer, but
> it's
> hard for now.
> * so things like the current vhost-net implementation of deciding whether or
> not
> to do zerocopy beforehand referring the zerocopy tx error ratio is a point of
> practical compromise.
<- I forgot to mention the max pend checking part.
> 
> Thanks.
