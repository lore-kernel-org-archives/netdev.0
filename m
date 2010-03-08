From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFC][ PATCH 2/3] vhost-net: handle vnet_hdr processing for	MRG_RX_BUF
Date: Sun, 7 Mar 2010 17:28:02 -0800
Message-ID: <OF8A4807F2.DE42C086-ON882576E0.00033A96-882576E0.00080FCA@us.ibm.com>
References: <20100307161229.GB24997@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.osdl.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100307161229.GB24997@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> wrote on 03/07/2010 08:12:29 AM:

> On Tue, Mar 02, 2010 at 05:20:26PM -0700, David Stevens wrote:
> > This patch adds vnet_hdr processing for mergeable buffer
> > support to vhost-net.
> > 
> > Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
> > 
> > diff -ruN net-next-p1/drivers/vhost/net.c 
net-next-p2/drivers/vhost/net.c
> 
> Could you please add -p to diff flags so that it's easier
> to figure out which function is changes?

Sure.


> > @@ -148,25 +146,45 @@
> >                                "out %d, int %d\n", out, in);
> >                         break;
> >                 }
> > +               if (vq->guest_hlen > vq->sock_hlen) {
> > +                       if (msg.msg_iov[0].iov_len == vq->guest_hlen)
> > +                               msg.msg_iov[0].iov_len = 
vq->sock_hlen;
> > +                       else if (out == ARRAY_SIZE(vq->iov))
> > +                               vq_err(vq, "handle_tx iov overflow!");
> > +                       else {
> > +                               int i;
> > +
> > +                               /* give header its own iov */
> > +                               for (i=out; i>0; ++i)
> > +                                       msg.msg_iov[i+1] = 
msg.msg_iov[i];
> > +                               msg.msg_iov[0].iov_len = 
vq->sock_hlen;
> > +                               msg.msg_iov[1].iov_base += 
vq->guest_hlen;
> > +                               msg.msg_iov[1].iov_len -= 
vq->guest_hlen;
> > +                               out++;
> 
> We seem to spend a fair bit of code here and elsewhere trying to cover
> the diff between header size in guest and host.  In hindsight, it was
> not a good idea to put new padding between data and the header:
> virtio-net should have added it *before*. But it is what it is.
> 
> Wouldn't it be easier to just add an ioctl to tap so that
> vnet header size is made bigger by 4 bytes?

        I'd be ok with that, but if we support raw sockets, we have
some of the issues (easier, since it's 0). "num_buffers" is only
16 bits, so just add 2 bytes, but yeah-- pushing it to tap would
be easier for vhost.


> >                 /* TODO: Check specific error and bomb out unless 
ENOBUFS? 
> > */
> >                 err = sock->ops->sendmsg(NULL, sock, &msg, len);
> >                 if (unlikely(err < 0)) {
> > -                       vhost_discard(vq, 1);
> > -                       tx_poll_start(net, sock);
> > +                       if (err == -EAGAIN) {
> 
> The comment mentions ENOBUFS. Are you sure it's EAGAIN?

        The comment's from the original -- the code changes should do
the "TODO", so probably should remove the comment.
> 
> > +                               tx_poll_start(net, sock);
> 
> Don't we need to call discard to move the last avail header back?

        Yes, I think you're right. We might consider dropping the packet
in the EAGAIN case here instead, though. It's not clear retrying the
same packet with a delay here is better than getting new ones when the
socket buffer is full (esp. with queues on both sides already). Maybe
we should fold EAGAIN into the other error cases? Otherwise, you're
right, it looks like it should have a discard here.

> 
> > +                       } else {
> > +                               vq_err(vq, "sendmsg: errno %d\n", 
-err);
> > +                               /* drop packet; do not discard/resend 
*/
> > + vhost_add_used_and_signal(&net->dev,vq,&head,1);
> > +                       }
> >                         break;
> > -               }
> > -               if (err != len)
> > +               } else if (err != len)
> 
> 
> Previous if ends with break so no need for else here.

        Yes.


> > @@ -232,25 +243,18 @@
> >                 headcount = vhost_get_heads(vq, datalen, &in, vq_log, 
> > &log);
> >                 /* OK, now we need to know about added descriptors. */
> >                 if (!headcount) {
> > -                       if (unlikely(vhost_enable_notify(vq))) {
> > -                               /* They have slipped one in as we were
> > -                                * doing that: check again. */
> > -                               vhost_disable_notify(vq);
> > -                               continue;
> > -                       }
> > -                       /* Nothing new?  Wait for eventfd to tell us
> > -                        * they refilled. */
> > +                       vhost_enable_notify(vq);
> 
> 
> You don't think this race can happen?

        The notify case has to allow for multiple heads, not just the one,
so if he added just one head, it doesn't mean we're ok to continue-- the
packet may require multiple. Instead, the notifier now checks for enough
to handle a max-sized packet (whether or not NONOTIFY is set). I'll think
about this some more, but I concluded it wasn't needed at the time. :-)


> > @@ -519,6 +524,20 @@
> > 
> >         vhost_net_disable_vq(n, vq);
> >         rcu_assign_pointer(vq->private_data, sock);
> > +
> > +       if (sock && sock->sk) {
> > +               if (!vhost_sock_is_raw(sock) ||
> 
> I dislike this backend-specific code, it ties us with specifics of
> backend implementations, which change without notice.  Ideally all
> backend-specific stuff should live in userspace, userspace programs
> vhost device appropriately.

        We could do that; we need to know whether the socket has a
vnet header on it or not and the existing flags don't tell us. If
qemu sets a flag telling us the socket is has or doesn't have vnet,
that'd be equivalent.

> > +                   vhost_has_feature(&n->dev, 
> > VHOST_NET_F_VIRTIO_NET_HDR)) {
> > +                       vq->sock_hlen = sizeof(struct virtio_net_hdr);
> > +                       if (vhost_has_feature(&n->dev, 
> > VIRTIO_NET_F_MRG_RXBUF))
> > +                               vq->guest_hlen =
> > +                                       sizeof(struct 
> > virtio_net_hdr_mrg_rxbuf);
> > +                       else
> > +                               vq->guest_hlen = sizeof(struct 
> > virtio_net_hdr);
> > +               } else
> > +                       vq->guest_hlen = vq->sock_hlen = 0;
> > +       } else
> > +               vq_err(vq, "vhost_net_set_backend: sock->sk is NULL");
> 
> As proposed above, IMO it would be nicer to add an ioctl in tap
> that let us program header size.

        Do you know if Herbert or Dave have an opinion on that solution?
 
> > +static int
> > +vhost_get_hdr(struct vhost_virtqueue *vq, int *in, struct vhost_log 
*log,
> > +       int *log_num)
> > +{
> > +       struct iovec *heads = vq->heads;
> > +       struct iovec *iov = vq->iov;
> > +       int out;
> > +
> > +       *in = 0;
> > +       iov[0].iov_len = 0;
> > +
> > +       /* get buffer, starting from iov[1] */
> > +       heads[0].iov_base = (void *)vhost_get_vq_desc(vq->dev, vq,
> > +               vq->iov+1, ARRAY_SIZE(vq->iov)-1, &out, in, log, 
log_num);
> > +       if (out || *in <= 0) {
> > +               vq_err(vq, "unexpected descriptor format for RX: out 
%d, "
> > +                       "in %d\n", out, *in);
> > +               return 0;
> > +       }
> > +       if (heads[0].iov_base == (void *)vq->num)
> > +               return 0;
> > +
> > +       /* make iov[0] the header */
> > +       if (!vq->guest_hlen) {
> > +               if (vq->sock_hlen) {
> > +                       static struct virtio_net_hdr junk; /* bit 
bucket 
> > */
> > +
> > +                       iov[0].iov_base = &junk;
> > +                       iov[0].iov_len = sizeof(junk);
> > +               } else
> > +                       iov[0].iov_len = 0;
> > +       }
> > +       if (vq->sock_hlen < vq->guest_hlen) {
> > +               iov[0].iov_base = iov[1].iov_base;
> > +               iov[0].iov_len = vq->sock_hlen;
> > +
> > +               if (iov[1].iov_len < vq->sock_hlen) {
> > +                       vq_err(vq, "can't fit header in one buffer!");
> > +                       vhost_discard(vq, 1);
> > +                       return 0;
> > +               }
> > +               if (!vq->sock_hlen) {
> > +                       static const struct virtio_net_hdr_mrg_rxbuf 
hdr = 
> > {
> > +                               .hdr.flags = 0,
> > +                               .hdr.gso_type = 
VIRTIO_NET_HDR_GSO_NONE
> > +                       };
> > +                       memcpy(iov[0].iov_base, &hdr, vq->guest_hlen);
> > +               }
> > +               iov[1].iov_base += vq->guest_hlen;
> > +               iov[1].iov_len -= vq->guest_hlen;
> > +       }
> > +       return 1;
> 
> The above looks kind of scary, lots of special-casing.  I'll send a
> patch for tap to set vnet header size, let's see if it makes life easier
> for us.

        Yes, I try to handle all combinations of differing guest and 
socket
header lengths (including 0-lengths). If we don't support raw sockets 
and/or
we make the tap vnet header bigger in the MRXB case, it'll simplify this 
code.

> 
> > +}
> > +
> >  unsigned vhost_get_heads(struct vhost_virtqueue *vq, int datalen, int 

> > *iovcount,
> >         struct vhost_log *log, unsigned int *log_num)
> >  {
> >         struct iovec *heads = vq->heads;
> > -       int out, in;
> > +       int out, in = 0;
> > +       int seg = 0;
> >         int hc = 0;
> 
> I think it's better to stick to simple names like i
> for index variables, alternatively give it a meaningful
> name like "count".

        I'm not sure which one you're talking about. "in & out"
are inherited from the original, "seg" is an iovec segment index, and
"hc" is a head counter. "headcount" or "count" (if that's the
one you mean) instead of "hc" would probably cause some line wraps.
I think "i" is too generic here, but if you mean "hc", I could stick
a comment on the declaration:

        int hc = 0;     /* head count */

Does that address your concern, or do you mean something else?

> 
> > 
> > +       if (vq->guest_hlen != vq->sock_hlen) {
> 
> Sticking guest_hlen/sock_hlen in vhost is somewhat ugly.

        Do you mean in the struct? This essentially splits the
original "hdrsize" into the two (possibly different) header
sizes and allows removing the "hdr" iovec and reading the
(partial) header directly into the extended header mergeable
buffers needs. Unless we remove raw socket support and add the
ioctl to tap you suggested, I'm not sure it can be much cleaner.
For me, the ugliness comes from tap, raw and guest headers not
being the same.

                                                        +-DLS

