From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFC][ PATCH 1/3] vhost-net: support multiple buffer heads in	receiver
Date: Sun, 7 Mar 2010 16:34:32 -0800
Message-ID: <OFEEE8B4AB.0C708EB8-ON882576DF.00831519-882576E0.000329C4@us.ibm.com>
References: <20100307153130.GA24997@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.osdl.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100307153130.GA24997@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> wrote on 03/07/2010 07:31:30 AM:

> On Tue, Mar 02, 2010 at 05:20:15PM -0700, David Stevens wrote:
> > This patch generalizes buffer handling functions to
                                      NULL, NULL);
> > +               head.iov_base = (void *)vhost_get_vq_desc(&net->dev, 
vq,
> > +                       vq->iov, ARRAY_SIZE(vq->iov), &out, &in, NULL, 

> > NULL);
> 
> Should type for head be changed so that we do not need to cast?
> 
> I also prefer aligning descendants on the opening (.

        Yes, that's probably better; the indentation with the cast would
still wrap a lot, but I'll see what I can do here.


> >                 err = sock->ops->sendmsg(NULL, sock, &msg, len);
> >                 if (unlikely(err < 0)) {
> > -                       vhost_discard_vq_desc(vq);
> > +                       vhost_discard(vq, 1);
> 
> Isn't the original name a bit more descriptive?

        During development, I had both and I generally like
shorter names, but I can change it back.

> > +static int skb_head_len(struct sk_buff_head *skq)
> > +{
> > +       struct sk_buff *head;
> > +
> > +       head = skb_peek(skq);
> > +       if (head)
> > +               return head->len;
> > +       return 0;
> > +}
> > +
> 
> This is done without locking, which I think can crash
> if skb is consumed after we peek it but before we read the
> length.

        This thread is the only legitimate consumer, right? But
qemu has the file descriptor and I guess we shouldn't trust
that it won't give it to someone else; it'd break vhost, but
a crash would be inappropriate, of course. I'd like to avoid
the lock, but I have another idea here, so will investigate.

> 
> 
> >  /* Expects to be always run from workqueue - which acts as
> >   * read-size critical section for our kind of RCU. */
> >  static void handle_rx(struct vhost_net *net)
> >  {
> >         struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
> > -       unsigned head, out, in, log, s;
> > +       unsigned in, log, s;
> >         struct vhost_log *vq_log;
> >         struct msghdr msg = {
> >                 .msg_name = NULL,
> > @@ -204,10 +213,11 @@
> >         };
> > 
> >         size_t len, total_len = 0;
> > -       int err;
> > +       int err, headcount, datalen;
> >         size_t hdr_size;
> >         struct socket *sock = rcu_dereference(vq->private_data);
> > -       if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
> > +
> > +       if (!sock || !skb_head_len(&sock->sk->sk_receive_queue))
> >                 return;
> > 
> 
> Isn't this equivalent? Do you expect zero len skbs in socket?
> If yes, maybe we should discard these, not stop processing ...

        A zero return means "no skb's". They are equivalent; I
changed this call just to make it identical to the loop check,
but I don't have a strong attachment to this.


> >         vq_log = unlikely(vhost_has_feature(&net->dev, 
VHOST_F_LOG_ALL)) ?
> >                 vq->log : NULL;
> > 
> > -       for (;;) {
> > -               head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
> > -                                        ARRAY_SIZE(vq->iov),
> > -                                        &out, &in,
> > -                                        vq_log, &log);
> > +       while ((datalen = skb_head_len(&sock->sk->sk_receive_queue))) 
{
> 
> This peeks in the queue to figure out how much data we have.
> It's a neat trick, but it does introduce new failure modes
> where an skb is consumed after we did the peek:
> - new skb could be shorter, we should return the unconsumed part
> - new skb could be longer, this will drop a packet.
>   maybe this last is not an issue as the race should be rare in practice

        As before, this loop is the only legitimate consumer of skb's; if
anyone else is reading the socket, it's broken. But since the file
descriptor is available to qemu, it's probably trusting qemu too much.
I don't believe there is a race at all on a working system; the head
can't change until we read it after this test, but I'll see if I can
come up with something better here. Closing the fd for qemu so vhost
has exclusive access might do it, but otherwise we could just get a
max-sized packet worth of buffers and then return them after the read.
That'd force us to wait with small packets when the ring is nearly
full, where we don't have to now, but I expect locking to read the head
length will hurt performance in all cases. Will try these ideas out.k

> 
> > +               headcount = vhost_get_heads(vq, datalen, &in, vq_log, 
> > &log);
> >                 /* OK, now we need to know about added descriptors. */
> > -               if (head == vq->num) {
> > +               if (!headcount) {
> >                         if (unlikely(vhost_enable_notify(vq))) {
> >                                 /* They have slipped one in as we were
> >                                  * doing that: check again. */
> > @@ -235,13 +242,6 @@
> >                          * they refilled. */
> >                         break;
> >                 }
> > -               /* We don't need to be notified again. */
> 
> you find this comment unhelpful?

        This code is changed in the later patches; the comment was
removed with that, but I got it in the wrong patch on the split.
I guess the comment is ok to stay, anyway, but notification may
require multiple buffers to be available; I had fixed that here, but
the final patch pushes that into the notify code, so yes, this can
go back in.

> > -               if (out) {
> > -                       vq_err(vq, "Unexpected descriptor format for 
RX: "
> > -                              "out %d, int %d\n",
> > -                              out, in);
> > -                       break;
> > -               }
> 
> 
> we still need this check, don't we?

        It's done in vhost_get_heads(); "out" isn't visible in handle_rx()
anymore.
 
> > +unsigned vhost_get_heads(struct vhost_virtqueue *vq, int datalen, int 

> > *iovcount,
> > +       struct vhost_log *log, unsigned int *log_num)
> 
> Could you please document this function's parameters? It's not obvious
> what iovcount, log, log_num are.

Yes. To answer the question, they are the same as vhost_get_vq_desc(),
except "iovcount" replaces "in" (and "out" is not needed in the caller).

> > +{
> > +       struct iovec *heads = vq->heads;
> > +       int out, in;
> > +       int hc = 0;
> > +
> > +       while (datalen > 0) {
> > +               if (hc >= VHOST_NET_MAX_SG) {
> > +                       vhost_discard(vq, hc);
> > +                       return 0;
> > +               }
> > +               heads[hc].iov_base = (void 
*)vhost_get_vq_desc(vq->dev, 
> > vq,
> > +                       vq->iov, ARRAY_SIZE(vq->iov), &out, &in, log, 
> > log_num);
> > +               if (heads[hc].iov_base == (void *)vq->num) {
> > +                       vhost_discard(vq, hc);
> > +                       return 0;
> > +               }
> > +               if (out || in <= 0) {
> > +                       vq_err(vq, "unexpected descriptor format for 
RX: "
> > +                               "out %d, in %d\n", out, in);
> > +                       vhost_discard(vq, hc);
> > +                       return 0;
> > +               }
> > +               heads[hc].iov_len = iov_length(vq->iov, in);
> > +               hc++;
> > +               datalen -= heads[hc].iov_len;
> > +       }
> > +       *iovcount = in;
> 
> 
> Only the last value?

        In this part of the split, it only goes through once; this is
changed to the accumulated value "seg" in a later patch. So, split
artifact.

  {
> >         struct vring_used_elem *used;
> > +       int i;
> > 
> > -       /* The virtqueue contains a ring of used buffers.  Get a 
pointer 
> > to the
> > -        * next entry in that used ring. */
> > -       used = &vq->used->ring[vq->last_used_idx % vq->num];
> > -       if (put_user(head, &used->id)) {
> > -               vq_err(vq, "Failed to write used id");
> > -               return -EFAULT;
> > -       }
> > -       if (put_user(len, &used->len)) {
> > -               vq_err(vq, "Failed to write used len");
> > -               return -EFAULT;
> > +       for (i=0; i<count; i++, vq->last_used_idx++) {
> 
> whitespace damage: I prefer space around =, <.
> I also use ++i, etc in this driver, better be consistent?
> Also for clarity, I prefer to put vq->last_used_idx inside the loop.

        OK.
> 
> > +               used = &vq->used->ring[vq->last_used_idx % vq->num];
> > +               if (put_user((unsigned)heads[i].iov_base, &used->id)) 
{
> > +                       vq_err(vq, "Failed to write used id");
> > +                       return -EFAULT;
> > +               }
> > +               if (put_user(heads[i].iov_len, &used->len)) {
> > +                       vq_err(vq, "Failed to write used len");
> > +                       return -EFAULT;
> > +               }
> 
> If this fails, last_used_idx will still be incremented, which I think is 
wrong.

        True, but if these fail, aren't we dead? I don't think we can 
recover
from an EFAULT in any of these; I didn't test those paths from the 
original,
but I think we need to bail out entirely for these cases, right?

 +-DLS

