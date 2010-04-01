From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH v2] Add Mergeable RX buffer feature to vhost_net
Date: Thu, 1 Apr 2010 11:22:37 -0700
Message-ID: <OF9AF90021.62EF0EE4-ON882576F8.00618B3E-882576F8.0064F223@us.ibm.com>
References: <20100401105415.GA3323@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: kvm@vger.kernel.org, kvm-owner@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.osdl.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100401105415.GA3323@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kvm-owner@vger.kernel.org wrote on 04/01/2010 03:54:15 AM:

> On Wed, Mar 31, 2010 at 03:04:43PM -0700, David Stevens wrote:

> > 
> > > > +               head.iov_base = (void 
*)vhost_get_vq_desc(&net->dev, 
> > vq,
> > > > +                       vq->iov, ARRAY_SIZE(vq->iov), &out, &in, 
NULL, 
> > 
> > > > NULL);
> > > 
> > > I this casting confusing.
> > > Is it really expensive to add an array of heads so that
> > > we do not need to cast?
> > 
> >         It needs the heads and the lengths, which looks a lot
> > like an iovec. I was trying to resist adding a new
> > struct XXX { unsigned head; unsigned len; } just for this,
> > but I could make these parallel arrays, one with head index and
> > the other with length.

        Michael, on this one, if I add vq->heads as an argument to
vhost_get_heads (aka vhost_get_desc_n), I'd need the length too.
Would you rather this 1) remain an iovec (and a single arg added) but
cast still there, 2) 2 arrays (head and length) and 2 args added, or
3) a new struct type of {unsigned,int} to carry for the heads+len
instead of iovec?
        My preference would be 1). I agree the casts are ugly, but
it is essentially an iovec the way we use it; it's just that the
base isn't a pointer but a descriptor index instead.

> > 
> >         EAGAIN is not possible after the change, because we don't
> > even enter the loop unless we have an skb on the read queue; the
> > other cases bomb out, so I figured the comment for future work is
> > now done. :-)
> 
> Guest could be buggy so we'll get EFAULT.
> If skb is taken off the rx queue (as below), we might get EAGAIN.

        We break on any error. If we get EAGAIN because someone read
on the socket, this code would break the loop, but EAGAIN is a more
serious problem if it changed since we peeked (because it means
someone else is reading the socket).
        But I don't understand -- are you suggesting that the error
handling be different than that, or that the comment is still
relevant? My intention here is to do the "TODO" from the comment
so that it can be removed, by handling all error cases. I think
because of the peek, EAGAIN isn't something to be ignored anymore,
but the effect is the same whether we break out of the loop or
not, since we retry the packet next time around. Essentially, we
ignore every error since we will redo it with the same packet the
next time around. Maybe we should print something here, but since
we'll be retrying the packet that's still on the socket, a permanent
error would spew continuously. Maybe we should shut down entirely
if we get any negative return value here (including EAGAIN, since
that tells us someone messed with the socket when we don't want them
to).
        If you want the comment still there, ok, but I do think EAGAIN
isn't a special case per the comment anymore, and is handled as all
other errors are: by exiting the loop and retrying next time.

                                                                +-DLS

