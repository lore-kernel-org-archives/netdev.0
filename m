From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Tue, 22 Aug 2017 20:55:56 +0300
Message-ID: <20170822204015-mutt-send-email-mst@kernel.org>
References: <20170819063854.27010-1-den@klaipeden.com>
 <5352c98a-fa48-fcf9-c062-9986a317a1b0@redhat.com>
 <CAF=yD-LZ4=WAYfUtY7xRWi50FRSkrcOa+b7uc46xRnC4sbDCzQ@mail.gmail.com>
 <64d451ae-9944-e978-5a05-54bb1a62aaad@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Koichiro Den <den@klaipeden.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54070 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751915AbdHVRz6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Aug 2017 13:55:58 -0400
Content-Disposition: inline
In-Reply-To: <64d451ae-9944-e978-5a05-54bb1a62aaad@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 22, 2017 at 10:50:41AM +0800, Jason Wang wrote:
> > Perhaps the descriptor pool should also be
> > revised to allow out of order completions. Then there is no need to
> > copy zerocopy packets whenever they may experience delay.
> 
> Yes, but as replied in the referenced thread, windows driver may treat out
> of order completion as a bug.

That would be a windows driver bug then, but I don't think it makes this
assumption. What the referenced thread
(https://patchwork.kernel.org/patch/3787671/) is saying is that host
must use any buffers made available on a tx vq within a reasonable
timeframe otherwise windows guests panic.

Ideally we would detect that a packet is actually experiencing delay and
trigger the copy at that point e.g. by calling skb_linearize. But it
isn't easy to track these packets though and even harder to do a data
copy without races.

Which reminds me that skb_linearize in net core seems to be
fundamentally racy - I suspect that if skb is cloned, and someone is
trying to use the shared frags while another thread calls skb_linearize,
we get some use after free bugs which likely mostly go undetected
because the corrupted packets mostly go on wire and get dropped
by checksum code.

-- 
MST
