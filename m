From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH rfc] packet: zerocopy packet_snd
Date: Wed, 26 Nov 2014 18:05:16 -0500
Message-ID: <CA+FuTSf_qiO964ZK1gB9skd1iQMj3iodcccscCt=vo6j92MsuA@mail.gmail.com>
References: <1416602694-7540-1-git-send-email-willemb@google.com>
 <20141126182445.GA15744@redhat.com> <CA+FuTSdYB4rDMH3gAAMwaRdbqN58f_SxLz=C3fcCACw_KosGXw@mail.gmail.com>
 <20141126212038.GA12118@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:33277 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbaKZXFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 18:05:47 -0500
Received: by mail-qa0-f53.google.com with SMTP id bm13so2578181qab.26
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 15:05:46 -0800 (PST)
In-Reply-To: <20141126212038.GA12118@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 26, 2014 at 4:20 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Wed, Nov 26, 2014 at 02:59:34PM -0500, Willem de Bruijn wrote:
>> > The main problem with zero copy ATM is with queueing disciplines
>> > which might keep the socket around essentially forever.
>> > The case was described here:
>> > https://lkml.org/lkml/2014/1/17/105
>> > and of course this will make it more serious now that
>> > more applications will be able to do this, so
>> > chances that an administrator enables this
>> > are higher.
>>
>> The denial of service issue raised there, that a single queue can
>> block an entire virtio-net device, is less problematic in the case of
>> packet sockets. A socket can run out of sk_wmem_alloc, but a prudent
>> application can increase the limit or use separate sockets for
>> separate flows.
>
> Sounds like this interface is very hard to use correctly.

Actually, this socket alloc issue is the same for zerocopy and
non-zerocopy. Packets can be held in deep queues at which point
the packet socket is blocked. This is accepted behavior.

>From the above thread:

"It's ok for non-zerocopy packet to be blocked since VM1 thought the
packets has been sent instead of pending in the virtqueue. So VM1 can
still send packet to other destination."

This is very specific to virtio and vhost-net. I don't think that that
concern applies to a packet interface.

Another issue, though, is that the method currently really only helps
TSO because ll other paths cause a deep copy. There are more use
cases once it can send up to 64KB MTU over loopback or send out
GSO datagrams without triggering skb_copy_ubufs. I have not looked
into how (or if) that can be achieved yet.

>
>> > One possible solution is some kind of timer orphaning frags
>> > for skbs that have been around for too long.
>>
>> Perhaps this can be approximated without an explicit timer by calling
>> skb_copy_ubufs on enqueue whenever qlen exceeds a threshold value?
>
> Not sure.  I'll have to see that patch to judge.
>
>> >
>> >> ---
>> >>  include/linux/skbuff.h        |   1 +
>> >>  include/linux/socket.h        |   1 +
>> >>  include/uapi/linux/errqueue.h |   1 +
>> >>  net/packet/af_packet.c        | 110 ++++++++++++++++++++++++++++++++++++++----
>> >>  4 files changed, 103 insertions(+), 10 deletions(-)
>> >>
>> >> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> >> index 78c299f..8e661d2 100644
>> >> --- a/include/linux/skbuff.h
>> >> +++ b/include/linux/skbuff.h
>> >> @@ -295,6 +295,7 @@ struct ubuf_info {
>> >>       void (*callback)(struct ubuf_info *, bool zerocopy_success);
>> >>       void *ctx;
>> >>       unsigned long desc;
>> >> +     void *callback_priv;
>> >>  };
>> >>
>> >>  /* This data is invariant across clones and lives at
>> >> diff --git a/include/linux/socket.h b/include/linux/socket.h
>> >> index de52228..0a2e0ea 100644
>> >> --- a/include/linux/socket.h
>> >> +++ b/include/linux/socket.h
>> >> @@ -265,6 +265,7 @@ struct ucred {
>> >>  #define MSG_SENDPAGE_NOTLAST 0x20000 /* sendpage() internal : not the last page */
>> >>  #define MSG_EOF         MSG_FIN
>> >>
>> >> +#define MSG_ZEROCOPY 0x4000000       /* Pin user pages */
>> >>  #define MSG_FASTOPEN 0x20000000      /* Send data in TCP SYN */
>> >>  #define MSG_CMSG_CLOEXEC 0x40000000  /* Set close_on_exec for file
>> >>                                          descriptor received through
>> >> diff --git a/include/uapi/linux/errqueue.h b/include/uapi/linux/errqueue.h
>> >> index 07bdce1..61bf318 100644
>> >> --- a/include/uapi/linux/errqueue.h
>> >> +++ b/include/uapi/linux/errqueue.h
>> >> @@ -19,6 +19,7 @@ struct sock_extended_err {
>> >>  #define SO_EE_ORIGIN_ICMP6   3
>> >>  #define SO_EE_ORIGIN_TXSTATUS        4
>> >>  #define SO_EE_ORIGIN_TIMESTAMPING SO_EE_ORIGIN_TXSTATUS
>> >> +#define SO_EE_ORIGIN_UPAGE   5
>> >>
>> >>  #define SO_EE_OFFENDER(ee)   ((struct sockaddr*)((ee)+1))
>> >>
>> >> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> >> index 58af5802..367c23a 100644
>> >> --- a/net/packet/af_packet.c
>> >> +++ b/net/packet/af_packet.c
>> >> @@ -2370,28 +2370,112 @@ out:
>> >>
>> >>  static struct sk_buff *packet_alloc_skb(struct sock *sk, size_t prepad,
>> >>                                       size_t reserve, size_t len,
>> >> -                                     size_t linear, int noblock,
>> >> +                                     size_t linear, int flags,
>> >>                                       int *err)
>> >>  {
>> >>       struct sk_buff *skb;
>> >> +     size_t data_len;
>> >>
>> >> -     /* Under a page?  Don't bother with paged skb. */
>> >> -     if (prepad + len < PAGE_SIZE || !linear)
>> >> -             linear = len;
>> >> +     if (flags & MSG_ZEROCOPY) {
>> >> +             /* Minimize linear, but respect header lower bound */
>> >> +             linear = min(len, max_t(size_t, linear, MAX_HEADER));
>> >> +             data_len = 0;
>> >> +     } else {
>> >> +             /* Under a page? Don't bother with paged skb. */
>> >> +             if (prepad + len < PAGE_SIZE || !linear)
>> >> +                     linear = len;
>> >> +             data_len = len - linear;
>> >> +     }
>> >>
>> >> -     skb = sock_alloc_send_pskb(sk, prepad + linear, len - linear, noblock,
>> >> -                                err, 0);
>> >> +     skb = sock_alloc_send_pskb(sk, prepad + linear, data_len,
>> >> +                                flags & MSG_DONTWAIT, err, 0);
>> >>       if (!skb)
>> >>               return NULL;
>> >>
>> >>       skb_reserve(skb, reserve);
>> >>       skb_put(skb, linear);
>> >> -     skb->data_len = len - linear;
>> >> -     skb->len += len - linear;
>> >> +     skb->data_len = data_len;
>> >> +     skb->len += data_len;
>> >>
>> >>       return skb;
>> >>  }
>> >>
>> >> +/* release zerocopy resources and avoid destructor callback on kfree */
>> >> +static void packet_snd_zerocopy_free(struct sk_buff *skb)
>> >> +{
>> >> +     struct ubuf_info *uarg = skb_shinfo(skb)->destructor_arg;
>> >> +
>> >> +     if (uarg) {
>> >> +             kfree_skb(uarg->callback_priv);
>> >> +             sock_put((struct sock *) uarg->ctx);
>> >> +             kfree(uarg);
>> >> +
>> >> +             skb_shinfo(skb)->destructor_arg = NULL;
>> >> +             skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
>> >> +     }
>> >> +}
>> >> +
>> >> +static void packet_snd_zerocopy_callback(struct ubuf_info *uarg,
>> >> +                                      bool zerocopy_success)
>> >> +{
>> >> +     struct sk_buff *err_skb;
>> >> +     struct sock *err_sk;
>> >> +     struct sock_exterr_skb *serr;
>> >> +
>> >> +     err_sk = uarg->ctx;
>> >> +     err_skb = uarg->callback_priv;
>> >> +
>> >> +     serr = SKB_EXT_ERR(err_skb);
>> >> +     memset(serr, 0, sizeof(*serr));
>> >> +     serr->ee.ee_errno = ENOMSG;
>> >> +     serr->ee.ee_origin = SO_EE_ORIGIN_UPAGE;
>> >> +     serr->ee.ee_data = uarg->desc & 0xFFFFFFFF;
>> >> +     serr->ee.ee_info = ((u64) uarg->desc) >> 32;
>> >> +     if (sock_queue_err_skb(err_sk, err_skb))
>> >> +             kfree_skb(err_skb);
>> >> +
>> >> +     kfree(uarg);
>> >> +     sock_put(err_sk);
>> >> +}
>> >> +
>> >> +static int packet_zerocopy_sg_from_iovec(struct sk_buff *skb,
>> >> +                                      struct msghdr *msg)
>> >> +{
>> >> +     struct ubuf_info *uarg = NULL;
>> >> +     int ret;
>> >> +
>> >> +     if (iov_pages(msg->msg_iov, 0, msg->msg_iovlen) > MAX_SKB_FRAGS)
>> >> +             return -EMSGSIZE;
>> >> +
>> >> +     uarg = kzalloc(sizeof(*uarg), GFP_KERNEL);
>> >> +     if (!uarg)
>> >> +             return -ENOMEM;
>> >> +
>> >> +     uarg->callback_priv = alloc_skb(0, GFP_KERNEL);
>> >> +     if (!uarg->callback_priv) {
>> >> +             kfree(uarg);
>> >> +             return -ENOMEM;
>> >> +     }
>> >> +
>> >> +     ret = zerocopy_sg_from_iovec(skb, msg->msg_iov, 0, msg->msg_iovlen);
>> >> +     if (ret) {
>> >> +             kfree_skb(uarg->callback_priv);
>> >> +             kfree(uarg);
>> >> +             return -EIO;
>> >> +     }
>> >> +
>> >> +     sock_hold(skb->sk);
>> >> +     uarg->ctx = skb->sk;
>> >> +     uarg->callback = packet_snd_zerocopy_callback;
>> >> +     uarg->desc = (unsigned long) msg->msg_iov[0].iov_base;
>> >> +
>> >> +     skb_shinfo(skb)->destructor_arg = uarg;
>> >> +     skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
>> >> +     skb_shinfo(skb)->tx_flags |= SKBTX_SHARED_FRAG;
>> >> +
>> >> +     return 0;
>> >> +}
>> >> +
>> >>  static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
>> >>  {
>> >>       struct sock *sk = sock->sk;
>> >> @@ -2408,6 +2492,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
>> >>       unsigned short gso_type = 0;
>> >>       int hlen, tlen;
>> >>       int extra_len = 0;
>> >> +     bool zerocopy = msg->msg_flags & MSG_ZEROCOPY;
>> >>
>> >>       /*
>> >>        *      Get and verify the address.
>> >> @@ -2501,7 +2586,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
>> >>       hlen = LL_RESERVED_SPACE(dev);
>> >>       tlen = dev->needed_tailroom;
>> >>       skb = packet_alloc_skb(sk, hlen + tlen, hlen, len, vnet_hdr.hdr_len,
>> >> -                            msg->msg_flags & MSG_DONTWAIT, &err);
>> >> +                            msg->msg_flags, &err);
>> >>       if (skb == NULL)
>> >>               goto out_unlock;
>> >>
>> >> @@ -2518,7 +2603,11 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
>> >>       }
>> >>
>> >>       /* Returns -EFAULT on error */
>> >> -     err = skb_copy_datagram_from_iovec(skb, offset, msg->msg_iov, 0, len);
>> >> +     if (zerocopy)
>> >> +             err = packet_zerocopy_sg_from_iovec(skb, msg);
>> >> +     else
>> >> +             err = skb_copy_datagram_from_iovec(skb, offset, msg->msg_iov,
>> >> +                                                0, len);
>> >>       if (err)
>> >>               goto out_free;
>> >>
>> >> @@ -2578,6 +2667,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
>> >>       return len;
>> >>
>> >>  out_free:
>> >> +     packet_snd_zerocopy_free(skb);
>> >>       kfree_skb(skb);
>> >>  out_unlock:
>> >>       if (dev)
>> >> --
>> >> 2.1.0.rc2.206.gedb03e5
