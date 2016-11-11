From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/3] tuntap: rx batching
Date: Fri, 11 Nov 2016 05:31:22 +0200
Message-ID: <20161111053048-mutt-send-email-mst@kernel.org>
References: <1478677113-13126-1-git-send-email-jasowang@redhat.com>
 <20161109183259-mutt-send-email-mst@kernel.org>
 <c6cd619f-b9a6-784d-2c44-6106e64f5664@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <c6cd619f-b9a6-784d-2c44-6106e64f5664@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 11, 2016 at 10:07:44AM +0800, Jason Wang wrote:
> 
> 
> On 2016年11月10日 00:38, Michael S. Tsirkin wrote:
> > On Wed, Nov 09, 2016 at 03:38:31PM +0800, Jason Wang wrote:
> > > Backlog were used for tuntap rx, but it can only process 1 packet at
> > > one time since it was scheduled during sendmsg() synchronously in
> > > process context. This lead bad cache utilization so this patch tries
> > > to do some batching before call rx NAPI. This is done through:
> > > 
> > > - accept MSG_MORE as a hint from sendmsg() caller, if it was set,
> > >    batch the packet temporarily in a linked list and submit them all
> > >    once MSG_MORE were cleared.
> > > - implement a tuntap specific NAPI handler for processing this kind of
> > >    possible batching. (This could be done by extending backlog to
> > >    support skb like, but using a tun specific one looks cleaner and
> > >    easier for future extension).
> > > 
> > > Signed-off-by: Jason Wang <jasowang@redhat.com>
> > So why do we need an extra queue?
> 
> The idea was borrowed from backlog to allow some kind of bulking and avoid
> spinlock on each dequeuing.
> 
> >   This is not what hardware devices do.
> > How about adding the packet to queue unconditionally, deferring
> > signalling until we get sendmsg without MSG_MORE?
> 
> Then you need touch spinlock when dequeuing each packet.

It runs on the same CPU, right? Otherwise we should use skb_array...

> > 
> > 
> > > ---
> > >   drivers/net/tun.c | 71 ++++++++++++++++++++++++++++++++++++++++++++++++++-----
> > >   1 file changed, 65 insertions(+), 6 deletions(-)
> > > 
> 
> [...]
> 
> > >   	rxhash = skb_get_hash(skb);
> > > -	netif_rx_ni(skb);
> > > +	skb_queue_tail(&tfile->socket.sk->sk_write_queue, skb);
> > > +
> > > +	if (!more) {
> > > +		local_bh_disable();
> > > +		napi_schedule(&tfile->napi);
> > > +		local_bh_enable();
> > Why do we need to disable bh here? I thought napi_schedule can
> > be called from any context.
> 
> Yes, it's unnecessary. Will remove.
> 
> Thanks
