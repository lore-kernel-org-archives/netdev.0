From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH v2 4/4] Defer skb allocation -- change allocation &
 receiving in recv path
Date: Tue, 15 Dec 2009 00:43:04 -0800
Message-ID: <1260866584.4387.16.camel@localhost.localdomain>
References: <1258697359.7416.14.camel@localhost.localdomain>
	 <200911231123.18898.rusty@rustcorp.com.au>
	 <20091208122134.GA17286@redhat.com>
	 <1260534506.30371.6.camel@localhost.localdomain>
	 <1260535793.30371.27.camel@localhost.localdomain>
	 <20091213110822.GA7074@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anthony Liguori <anthony@codemonkey.ws>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20091213110822.GA7074@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2009-12-13 at 13:08 +0200, Michael S. Tsirkin wrote:
> Do not cast away void*.
> This initialization above looks very strange: in
> fact only one of skb, page makes sense.
> So I think you should either get rid of both page and
> skb variables (routines such as give_pages get page *
> so they will accept void* just as happily) or
> move initialization or even use of these variables to
> where they are used.
Ok.


> So above you override skb that you initialized
> at the start of function. It would be better
> to do in the 3'd case:
>                 skb = buf;
> as well. And then it would be clear why
> " Only for mergeable and big" comment below
> is true.

Ok.

> > +     }
> >  
> > -             err = pskb_trim(skb, len);
> > -             if (err) {
> > -                     pr_debug("%s: pskb_trim failed %i %d\n",
> dev->name,
> > -                              len, err);
> > -                     dev->stats.rx_dropped++;
> > -                     goto drop;
> > -             }
> > +     if (unlikely(!skb)) {
> > +             dev->stats.rx_dropped++;
> > +             /* only for mergeable buf and big packets */
> > +             give_pages(vi, page);
> > +             return;
> 
> Did you remove drop: label? If no, is it unused now?

The label is used when checking buf len, but I will remove drop in the
update patch. 

> > +     void *buf = NULL;
> 
> Does this have to be initialized? If not (as it seems) better not do
> it.
I remembered there was a compile warning, I will double check.

> > +     freed = vi->rvq->vq_ops->destroy_bufs(vi->rvq,
> virtio_net_free_pages);
> 
> This looks like double free to me: should not you remove code that
> does
> __skb_dequeue on recv above?

Nope, this is not a double free, the queue recv skb is still there for
small packet size. But I will remove it in the update patch.

Thanks
Shirley

