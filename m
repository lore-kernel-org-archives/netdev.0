From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: Netlink mmap tx security?
Date: Tue, 14 Oct 2014 12:33:43 -0700
Message-ID: <CALCETrUYBed_TBacxoDPMphM5y=iqxho2isrDruOQi=pmK2yoQ@mail.gmail.com>
References: <CALCETrWsCqy7KEKPTOeHjrO1c2JE1E_seO_J+yA=sYFhS11NXQ@mail.gmail.com>
 <CALCETrVuREGVKwrni61DEg=Tgjc7x41WYtrEiDMqMvwVFXfybw@mail.gmail.com>
 <CALCETrWfQe5H2Ht7cjCQLfUw+XUcRvga_H93esaWpAp37=noZg@mail.gmail.com> <20141014.151949.1967601568480255495.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>,
	Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:36389 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932547AbaJNTeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 15:34:05 -0400
Received: by mail-lb0-f176.google.com with SMTP id p9so8993754lbv.35
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 12:34:04 -0700 (PDT)
In-Reply-To: <20141014.151949.1967601568480255495.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 14, 2014 at 12:19 PM, David Miller <davem@davemloft.net> wrote:
> From: Andy Lutomirski <luto@amacapital.net>
> Date: Sat, 11 Oct 2014 15:29:17 -0700
>
>> On May 12, 2014 3:08 PM, "Andy Lutomirski" <luto@amacapital.net> wrote:
>>>
>>> [moving to netdev -- this is much lower impact than I thought, since
>>> you can't set up a netlink mmap ring without global CAP_NET_ADMIN]
>>
>> Did anything ever happen here?  Despite not being a privilege
>> escalation in the normal sense, it's still a bug, and it's still a
>> fairly easy bypass of module signatures.
>
> Andy, please review:
>
> ====================
> [PATCH] netlink: Remove TX mmap support.
>
> There is no reasonable manner in which to absolutely make sure that another
> thread of control cannot write to the pages in the mmap()'d area and thus
> make sure that netlink messages do not change underneath us after we've
> performed verifications.

For full honesty, there is now the machinery developed for memfd
sealing, but I can't imagine that this is ever faster than just
copying the buffer.

I think that the NETLINK_SKB_TX declaration in include/linux/netlink.h
should probably go, too.  And there's the last parameter to
netlink_set_ring, too, and possibly even the nlk->tx_ring struct
itself.

--Andy

>
> Reported-by: Andy Lutomirski <luto@amacapital.net>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/netlink/af_netlink.c | 135 ++---------------------------------------------
>  1 file changed, 5 insertions(+), 130 deletions(-)
>
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index c416725..771e6c0 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -289,11 +289,6 @@ static bool netlink_rx_is_mmaped(struct sock *sk)
>         return nlk_sk(sk)->rx_ring.pg_vec != NULL;
>  }
>
> -static bool netlink_tx_is_mmaped(struct sock *sk)
> -{
> -       return nlk_sk(sk)->tx_ring.pg_vec != NULL;
> -}
> -
>  static __pure struct page *pgvec_to_page(const void *addr)
>  {
>         if (is_vmalloc_addr(addr))
> @@ -662,13 +657,6 @@ static unsigned int netlink_poll(struct file *file, struct socket *sock,
>         }
>         spin_unlock_bh(&sk->sk_receive_queue.lock);
>
> -       spin_lock_bh(&sk->sk_write_queue.lock);
> -       if (nlk->tx_ring.pg_vec) {
> -               if (netlink_current_frame(&nlk->tx_ring, NL_MMAP_STATUS_UNUSED))
> -                       mask |= POLLOUT | POLLWRNORM;
> -       }
> -       spin_unlock_bh(&sk->sk_write_queue.lock);
> -
>         return mask;
>  }
>
> @@ -698,104 +686,6 @@ static void netlink_ring_setup_skb(struct sk_buff *skb, struct sock *sk,
>         NETLINK_CB(skb).sk = sk;
>  }
>
> -static int netlink_mmap_sendmsg(struct sock *sk, struct msghdr *msg,
> -                               u32 dst_portid, u32 dst_group,
> -                               struct sock_iocb *siocb)
> -{
> -       struct netlink_sock *nlk = nlk_sk(sk);
> -       struct netlink_ring *ring;
> -       struct nl_mmap_hdr *hdr;
> -       struct sk_buff *skb;
> -       unsigned int maxlen;
> -       bool excl = true;
> -       int err = 0, len = 0;
> -
> -       /* Netlink messages are validated by the receiver before processing.
> -        * In order to avoid userspace changing the contents of the message
> -        * after validation, the socket and the ring may only be used by a
> -        * single process, otherwise we fall back to copying.
> -        */
> -       if (atomic_long_read(&sk->sk_socket->file->f_count) > 2 ||
> -           atomic_read(&nlk->mapped) > 1)
> -               excl = false;
> -
> -       mutex_lock(&nlk->pg_vec_lock);
> -
> -       ring   = &nlk->tx_ring;
> -       maxlen = ring->frame_size - NL_MMAP_HDRLEN;
> -
> -       do {
> -               hdr = netlink_current_frame(ring, NL_MMAP_STATUS_VALID);
> -               if (hdr == NULL) {
> -                       if (!(msg->msg_flags & MSG_DONTWAIT) &&
> -                           atomic_read(&nlk->tx_ring.pending))
> -                               schedule();
> -                       continue;
> -               }
> -               if (hdr->nm_len > maxlen) {
> -                       err = -EINVAL;
> -                       goto out;
> -               }
> -
> -               netlink_frame_flush_dcache(hdr);
> -
> -               if (likely(dst_portid == 0 && dst_group == 0 && excl)) {
> -                       skb = alloc_skb_head(GFP_KERNEL);
> -                       if (skb == NULL) {
> -                               err = -ENOBUFS;
> -                               goto out;
> -                       }
> -                       sock_hold(sk);
> -                       netlink_ring_setup_skb(skb, sk, ring, hdr);
> -                       NETLINK_CB(skb).flags |= NETLINK_SKB_TX;
> -                       __skb_put(skb, hdr->nm_len);
> -                       netlink_set_status(hdr, NL_MMAP_STATUS_RESERVED);
> -                       atomic_inc(&ring->pending);
> -               } else {
> -                       skb = alloc_skb(hdr->nm_len, GFP_KERNEL);
> -                       if (skb == NULL) {
> -                               err = -ENOBUFS;
> -                               goto out;
> -                       }
> -                       __skb_put(skb, hdr->nm_len);
> -                       memcpy(skb->data, (void *)hdr + NL_MMAP_HDRLEN, hdr->nm_len);
> -                       netlink_set_status(hdr, NL_MMAP_STATUS_UNUSED);
> -               }
> -
> -               netlink_increment_head(ring);
> -
> -               NETLINK_CB(skb).portid    = nlk->portid;
> -               NETLINK_CB(skb).dst_group = dst_group;
> -               NETLINK_CB(skb).creds     = siocb->scm->creds;
> -
> -               err = security_netlink_send(sk, skb);
> -               if (err) {
> -                       kfree_skb(skb);
> -                       goto out;
> -               }
> -
> -               if (unlikely(dst_group)) {
> -                       atomic_inc(&skb->users);
> -                       netlink_broadcast(sk, skb, dst_portid, dst_group,
> -                                         GFP_KERNEL);
> -               }
> -               err = netlink_unicast(sk, skb, dst_portid,
> -                                     msg->msg_flags & MSG_DONTWAIT);
> -               if (err < 0)
> -                       goto out;
> -               len += err;
> -
> -       } while (hdr != NULL ||
> -                (!(msg->msg_flags & MSG_DONTWAIT) &&
> -                 atomic_read(&nlk->tx_ring.pending)));
> -
> -       if (len > 0)
> -               err = len;
> -out:
> -       mutex_unlock(&nlk->pg_vec_lock);
> -       return err;
> -}
> -
>  static void netlink_queue_mmaped_skb(struct sock *sk, struct sk_buff *skb)
>  {
>         struct nl_mmap_hdr *hdr;
> @@ -842,10 +732,8 @@ static void netlink_ring_set_copied(struct sock *sk, struct sk_buff *skb)
>  #else /* CONFIG_NETLINK_MMAP */
>  #define netlink_skb_is_mmaped(skb)     false
>  #define netlink_rx_is_mmaped(sk)       false
> -#define netlink_tx_is_mmaped(sk)       false
>  #define netlink_mmap                   sock_no_mmap
>  #define netlink_poll                   datagram_poll
> -#define netlink_mmap_sendmsg(sk, msg, dst_portid, dst_group, siocb)    0
>  #endif /* CONFIG_NETLINK_MMAP */
>
>  static void netlink_skb_destructor(struct sk_buff *skb)
> @@ -864,16 +752,11 @@ static void netlink_skb_destructor(struct sk_buff *skb)
>                 hdr = netlink_mmap_hdr(skb);
>                 sk = NETLINK_CB(skb).sk;
>
> -               if (NETLINK_CB(skb).flags & NETLINK_SKB_TX) {
> -                       netlink_set_status(hdr, NL_MMAP_STATUS_UNUSED);
> -                       ring = &nlk_sk(sk)->tx_ring;
> -               } else {
> -                       if (!(NETLINK_CB(skb).flags & NETLINK_SKB_DELIVERED)) {
> -                               hdr->nm_len = 0;
> -                               netlink_set_status(hdr, NL_MMAP_STATUS_VALID);
> -                       }
> -                       ring = &nlk_sk(sk)->rx_ring;
> +               if (!(NETLINK_CB(skb).flags & NETLINK_SKB_DELIVERED)) {
> +                       hdr->nm_len = 0;
> +                       netlink_set_status(hdr, NL_MMAP_STATUS_VALID);
>                 }
> +               ring = &nlk_sk(sk)->rx_ring;
>
>                 WARN_ON(atomic_read(&ring->pending) == 0);
>                 atomic_dec(&ring->pending);
> @@ -2165,8 +2048,7 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
>                 err = 0;
>                 break;
>  #ifdef CONFIG_NETLINK_MMAP
> -       case NETLINK_RX_RING:
> -       case NETLINK_TX_RING: {
> +       case NETLINK_RX_RING: {
>                 struct nl_mmap_req req;
>
>                 /* Rings might consume more memory than queue limits, require
> @@ -2295,13 +2177,6 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
>                         goto out;
>         }
>
> -       if (netlink_tx_is_mmaped(sk) &&
> -           msg->msg_iov->iov_base == NULL) {
> -               err = netlink_mmap_sendmsg(sk, msg, dst_portid, dst_group,
> -                                          siocb);
> -               goto out;
> -       }
> -
>         err = -EMSGSIZE;
>         if (len > sk->sk_sndbuf - 32)
>                 goto out;
> --
> 1.7.11.7
>



-- 
Andy Lutomirski
AMA Capital Management, LLC
