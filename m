From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFC][ PATCH 1/3] vhost-net: support multiple buffer heads in	receiver
Date: Wed, 10 Mar 2010 14:17:19 -0800
Message-ID: <OFB507E769.AEAC2F51-ON882576E2.007806C8-882576E2.007A6F76@us.ibm.com>
References: <20100308074533.GA7482@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.osdl.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100308074533.GA7482@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> wrote on 03/07/2010 11:45:33 PM:

> > > > +static int skb_head_len(struct sk_buff_head *skq)
> > > > +{
> > > > +       struct sk_buff *head;
> > > > +
> > > > +       head = skb_peek(skq);
> > > > +       if (head)
> > > > +               return head->len;
> > > > +       return 0;
> > > > +}
> > > > +
> > > 
> > > This is done without locking, which I think can crash
> > > if skb is consumed after we peek it but before we read the
> > > length.
> > 
> >         This thread is the only legitimate consumer, right? But
> > qemu has the file descriptor and I guess we shouldn't trust
> > that it won't give it to someone else; it'd break vhost, but
> > a crash would be inappropriate, of course. I'd like to avoid
> > the lock, but I have another idea here, so will investigate.

        I looked at this some more and actually, I'm not sure I
see a crash here.
        First, without qemu, or something it calls, being broken
as root, nothing else should ever read from the socket, in which
case the length will be exactly right for the next packet we
read. No problem.
        But if by some error this skb is freed, we'll have valid
memory address that isn't the length field of the next packet
we'll read.
        If the length is negative or more than available in the
vring, we'll fail the buffer allocation, exit the loop, and
get the new head length of the receive queue the next time
around -- no problem.
        If the length field is 0, we'll exit the loop even
though we have data to read, but will get that packet the
next time we get in here, again, with the right length.
No problem.
        If the length field is big enough to allocate buffer
space for it, but smaller than the new head we have to read,
the recvmsg will fail with EMSGSIZE, drop the packet, exit
the loop and be back in business with the next packet. No
problem.
        Otherwise, the packet will fit and be delivered.

        I don't much like the notion of using skb->head when
it's garbage, but that can only happen if qemu has broken,
and I don't see a crash unless the skb is not only freed
but no longer a valid memory address for reading at all,
and all within the race window.
        Since the code handles other failure cases (not
enough ring buffers or packet not fitting in the allocated
buffers), the actual length value only matters in the
sense that it prevents us from using buffers unnecessarily--
something that isn't all that relevant if it's hosed enough
to have unauthorized readers on the socket.

        Is this case worth the performance penalty we'll no
doubt pay for either locking the socket or always allocating
for a max-sized packet? I'll experiment with a couple
solutions here, but unless I've missed something, we might
be better off just leaving it as-is.

                                                        +-DLS


