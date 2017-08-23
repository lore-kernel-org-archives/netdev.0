From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Thu, 24 Aug 2017 01:57:06 +0300
Message-ID: <20170824014553-mutt-send-email-mst@kernel.org>
References: <20170819063854.27010-1-den@klaipeden.com>
 <5352c98a-fa48-fcf9-c062-9986a317a1b0@redhat.com>
 <CAF=yD-LZ4=WAYfUtY7xRWi50FRSkrcOa+b7uc46xRnC4sbDCzQ@mail.gmail.com>
 <64d451ae-9944-e978-5a05-54bb1a62aaad@redhat.com>
 <20170822204015-mutt-send-email-mst@kernel.org>
 <1503498504.8694.26.camel@klaipeden.com>
 <CAF=yD-+U_aWxSmPPY8v8t=JO0MRZ+N+DzVJTAMKYQ5F=pE1PfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Koichiro Den <den@klaipeden.com>, Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51072 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751026AbdHWW5I (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 18:57:08 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-+U_aWxSmPPY8v8t=JO0MRZ+N+DzVJTAMKYQ5F=pE1PfA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 23, 2017 at 11:20:45AM -0400, Willem de Bruijn wrote:
> > Please let me make sure if I understand it correctly:
> > * always do copy with skb_orphan_frags_rx as Willem mentioned in the earlier
> > post, before the xmit_skb as opposed to my original patch, is safe but too
> > costly so cannot be adopted.
> 
> One more point about msg_zerocopy in the guest. This does add new allocation
> limits on optmem and locked pages rlimit.
> 
> Hitting these should be extremely rare. The tcp small queues limit normally
> throttles well before this.
> 
> Virtio-net is an exception because it breaks the tsq signal by calling
> skb_orphan before transmission.
> 
> As a result hitting these limits is more likely here. But, in this edge case the
> sendmsg call will not block, either, but fail with -ENOBUFS. The caller can
> send without zerocopy to make forward progress and
> trigger free_old_xmit_skbs from start_xmit.
> 
> > * as a generic solution, if we were to somehow overcome the safety issue, track
> > the delay and do copy if some threshold is reached could be an answer, but it's
> > hard for now.> * so things like the current vhost-net implementation of deciding whether or not
> > to do zerocopy beforehand referring the zerocopy tx error ratio is a point of
> > practical compromise.
> 
> The fragility of this mechanism is another argument for switching to tx napi
> as default.
>
> Is there any more data about the windows guest issues when completions
> are not queued within a reasonable timeframe? What is this timescale and
> do we really need to work around this. 

I think it's pretty large, many milliseconds.

But I wonder what do you mean by "work around". Using buffers within
limited time frame sounds like a reasonable requirement to me. Neither
do I see why would using tx interrupts within guest be a work around -
AFAIK windows driver uses tx interrupts.

> That is the only thing keeping us from removing the HoL blocking in vhost-net zerocopy.

We don't enable network watchdog on virtio but we could and maybe
should.

-- 
MST
