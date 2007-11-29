From: "Shannon Nelson" <shannon.lee.nelson@gmail.com>
Subject: Re: [PATCH -mm] [RFC] I/OAT: Handle incoming udp through ioatdma
Date: Thu, 29 Nov 2007 12:17:32 -0800
Message-ID: <3cce60f30711291217u7ba29cecl3bfd0ca75164039f@mail.gmail.com>
References: <BAE9DCEF64577A439B3A37F36F9B691C03853146@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.229]:63908 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760136AbXK2URe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 15:17:34 -0500
Received: by wr-out-0506.google.com with SMTP id c49so1730308wra
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2007 12:17:33 -0800 (PST)
In-Reply-To: <BAE9DCEF64577A439B3A37F36F9B691C03853146@orsmsx418.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Argh - mind the line breaks...
sln

On Nov 29, 2007 12:08 PM, Nelson, Shannon <shannon.nelson@intel.com> wrote:
> [RFC] I/OAT: Handle incoming udp through ioatdma
>
> From: Shannon Nelson <shannon.nelson@intel.com>
>
> If the incoming udp packet is larger than sysctl_udp_dma_copybreak, try
> pushing it through the ioatdma asynchronous memcpy.  This is very much
> the
> same as the tcp copy offload.  This is an RFC because we know there are
> stability problems under high traffic.
>
> This code was originally proposed by the Capstone students at Portland
> State University: Aaron Armstrong, Greg Nishikawa, Sean Gayner, Toai
> Nguyen,
> Stephen Bekefi, and Derek Chiles.
>
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> ---
>
>  include/net/udp.h   |    5 +++
>  net/core/user_dma.c |    1 +
>  net/ipv4/udp.c      |   79
> ++++++++++++++++++++++++++++++++++++++++++++++++---
>  3 files changed, 81 insertions(+), 4 deletions(-)
>
> diff --git a/include/net/udp.h b/include/net/udp.h
> index 98755eb..d5e05d8 100644
> --- a/include/net/udp.h
> +++ b/include/net/udp.h
> @@ -173,4 +173,9 @@ extern void udp_proc_unregister(struct
> udp_seq_afinfo *afinfo);
>  extern int  udp4_proc_init(void);
>  extern void udp4_proc_exit(void);
>  #endif
> +
> +#ifdef CONFIG_NET_DMA
> +extern int sysctl_udp_dma_copybreak;
> +#endif
> +
>  #endif /* _UDP_H */
> diff --git a/net/core/user_dma.c b/net/core/user_dma.c
> index 0ad1cd5..e876ca4 100644
> --- a/net/core/user_dma.c
> +++ b/net/core/user_dma.c
> @@ -34,6 +34,7 @@
>  #define NET_DMA_DEFAULT_COPYBREAK 4096
>
>  int sysctl_tcp_dma_copybreak = NET_DMA_DEFAULT_COPYBREAK;
> +int sysctl_udp_dma_copybreak = NET_DMA_DEFAULT_COPYBREAK;
>
>  /**
>   *     dma_skb_copy_datagram_iovec - Copy a datagram to an iovec.
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 69d4bd1..3b6d91c 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -102,6 +102,8 @@
>  #include <net/route.h>
>  #include <net/checksum.h>
>  #include <net/xfrm.h>
> +#include <net/netdma.h>
> +#include <linux/dmaengine.h>
>  #include "udp_impl.h"
>
>  /*
> @@ -819,6 +821,11 @@ int udp_recvmsg(struct kiocb *iocb, struct sock
> *sk, struct msghdr *msg,
>         unsigned int ulen, copied;
>         int err;
>         int is_udplite = IS_UDPLITE(sk);
> +#ifdef CONFIG_NET_DMA
> +       struct dma_chan         *dma_chan = NULL;
> +       struct dma_pinned_list  *pinned_list = NULL;
> +       dma_cookie_t            dma_cookie = 0;
> +#endif
>
>         /*
>          *      Check any passed addresses
> @@ -829,6 +836,18 @@ int udp_recvmsg(struct kiocb *iocb, struct sock
> *sk, struct msghdr *msg,
>         if (flags & MSG_ERRQUEUE)
>                 return ip_recv_error(sk, msg, len);
>
> +#ifdef CONFIG_NET_DMA
> +       preempt_disable();
> +       if ((len > sysctl_udp_dma_copybreak) &&
> +                       !(flags & MSG_PEEK) &&
> +                       __get_cpu_var(softnet_data).net_dma) {
> +
> +               preempt_enable_no_resched();
> +               pinned_list = dma_pin_iovec_pages(msg->msg_iov, len);
> +       } else
> +               preempt_enable_no_resched();
> +#endif
> +
>  try_again:
>         skb = skb_recv_datagram(sk, flags, noblock, &err);
>         if (!skb)
> @@ -852,10 +871,30 @@ try_again:
>                         goto csum_copy_err;
>         }
>
> -       if (skb_csum_unnecessary(skb))
> -               err = skb_copy_datagram_iovec(skb, sizeof(struct
> udphdr),
> -                                             msg->msg_iov, copied
> );
> -       else {
> +       if (skb_csum_unnecessary(skb)) {
> +#ifdef CONFIG_NET_DMA
> +               if (pinned_list && !dma_chan)
> +                       dma_chan = get_softnet_dma();
> +               if (dma_chan) {
> +                       dma_cookie = dma_skb_copy_datagram_iovec(
> +                                       dma_chan, skb, sizeof(struct
> udphdr),
> +                                       msg->msg_iov, copied,
> pinned_list);
> +                       if (dma_cookie < 0) {
> +                               printk(KERN_ALERT "dma_cookie < 0\n");
> +
> +                               /* Exception. Bailout! */
> +                               if (!copied)
> +                                       copied = -EFAULT;
> +                               goto out_free;
> +                       }
> +                       err = 0;
> +               }
> +               else
> +#endif
> +                       err = skb_copy_datagram_iovec(skb,
> +                                                     sizeof(struct
> udphdr),
> +                                                     msg->msg_iov,
> copied);
> +       } else {
>                 err = skb_copy_and_csum_datagram_iovec(skb,
> sizeof(struct udphdr), msg->msg_iov);
>
>                 if (err == -EINVAL)
> @@ -882,6 +921,35 @@ try_again:
>         if (flags & MSG_TRUNC)
>                 err = ulen;
>
> +#ifdef CONFIG_NET_DMA
> +       if (dma_chan) {
> +               struct sk_buff *skb;
> +               dma_cookie_t done, used;
> +
> +               dma_async_memcpy_issue_pending(dma_chan);
> +
> +               while (dma_async_memcpy_complete(dma_chan, dma_cookie,
> &done,
> +                                       &used) == DMA_IN_PROGRESS) {
> +                       /* do partial cleanup of sk_async_wait_queue */
> +                       while ((skb =
> skb_peek(&sk->sk_async_wait_queue)) &&
> +
> (dma_async_is_complete(skb->dma_cookie,
> +                                       done, used) == DMA_SUCCESS)) {
> +                               __skb_dequeue(&sk->sk_async_wait_queue);
> +                               kfree_skb(skb);
> +                       }
> +               }
> +
> +               /* Safe to free early-copied skbs now */
> +               __skb_queue_purge(&sk->sk_async_wait_queue);
> +               dma_chan_put(dma_chan);
> +               dma_chan = NULL;
> +       }
> +       if (pinned_list) {
> +               dma_unpin_iovec_pages(pinned_list);
> +               pinned_list = NULL;
> +       }
> +#endif
> +
>  out_free:
>         skb_free_datagram(sk, skb);
>  out:
> @@ -906,6 +974,9 @@ int udp_disconnect(struct sock *sk, int flags)
>          */
>
>         sk->sk_state = TCP_CLOSE;
> +#ifdef CONFIG_NET_DMA
> +       __skb_queue_purge(&sk->sk_async_wait_queue);
> +#endif
>         inet->daddr = 0;
>         inet->dport = 0;
>         sk->sk_bound_dev_if = 0;
>
>
> --
> ======================================================================
> Mr. Shannon Nelson                 LAN Access Division, Intel Corp.
> Shannon.Nelson@intel.com                I don't speak for Intel
> (503) 712-7659                    Parents can't afford to be squeamish.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



-- 
==============================================
Mr. Shannon Nelson         Parents can't afford to be squeamish.
