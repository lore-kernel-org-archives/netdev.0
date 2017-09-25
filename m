From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH,v3,net-next 2/2] tun: enable napi_gro_frags() for TUN/TAP driver
Date: Mon, 25 Sep 2017 09:27:10 -0700
Message-ID: <CAF2d9jjQ16NycS8dRJqLm55K5rd1w6Zfni7JA29pPoZnvf_pUg@mail.gmail.com>
References: <20170922204915.7889-1-peterpenkov96@gmail.com> <20170922204915.7889-3-peterpenkov96@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Willem Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>,
        Petar Bozhidarov Penkov <ppenkov@stanford.edu>
To: Petar Penkov <peterpenkov96@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:56855 "EHLO
        mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752558AbdIYQ1b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 12:27:31 -0400
Received: by mail-yw0-f173.google.com with SMTP id w22so5101121ywa.13
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 09:27:31 -0700 (PDT)
In-Reply-To: <20170922204915.7889-3-peterpenkov96@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 22, 2017 at 1:49 PM, Petar Penkov <peterpenkov96@gmail.com> wrote:
> Add a TUN/TAP receive mode that exercises the napi_gro_frags()
> interface. This mode is available only in TAP mode, as the interface
> expects packets with Ethernet headers.
>
> Furthermore, packets follow the layout of the iovec_iter that was
> received. The first iovec is the linear data, and every one after the
> first is a fragment. If there are more fragments than the max number,
> drop the packet. Additionally, invoke eth_get_headlen() to exercise flow
> dissector code and to verify that the header resides in the linear data.
>
> The napi_gro_frags() mode requires setting the IFF_NAPI_FRAGS option.
> This is imposed because this mode is intended for testing via tools like
> syzkaller and packetdrill, and the increased flexibility it provides can
> introduce security vulnerabilities. This flag is accepted only if the
> device is in TAP mode and has the IFF_NAPI flag set as well. This is
> done because both of these are explicit requirements for correct
> operation in this mode.
>
> Signed-off-by: Petar Penkov <peterpenkov96@gmail.com>

Thank you Petar.

Acked-by: Mahesh Bandewar <maheshb@google,com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Mahesh Bandewar <maheshb@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> Cc: davem@davemloft.net
> Cc: ppenkov@stanford.edu
> ---
>  drivers/net/tun.c           | 134 ++++++++++++++++++++++++++++++++++++++++++--
>  include/uapi/linux/if_tun.h |   1 +
>  2 files changed, 129 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index f16407242b18..9880b3bc8fa5 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -75,6 +75,7 @@
>  #include <linux/skb_array.h>
>  #include <linux/bpf.h>
>  #include <linux/bpf_trace.h>
> +#include <linux/mutex.h>
>
>  #include <linux/uaccess.h>
>
> @@ -121,7 +122,8 @@ do {                                                                \
>  #define TUN_VNET_BE     0x40000000
>
>  #define TUN_FEATURES (IFF_NO_PI | IFF_ONE_QUEUE | IFF_VNET_HDR | \
> -                     IFF_MULTI_QUEUE | IFF_NAPI)
> +                     IFF_MULTI_QUEUE | IFF_NAPI | IFF_NAPI_FRAGS)
> +
>  #define GOODCOPY_LEN 128
>
>  #define FLT_EXACT_COUNT 8
> @@ -173,6 +175,7 @@ struct tun_file {
>                 unsigned int ifindex;
>         };
>         struct napi_struct napi;
> +       struct mutex napi_mutex;        /* Protects access to the above napi */
>         struct list_head next;
>         struct tun_struct *detached;
>         struct skb_array tx_array;
> @@ -277,6 +280,7 @@ static void tun_napi_init(struct tun_struct *tun, struct tun_file *tfile,
>                 netif_napi_add(tun->dev, &tfile->napi, tun_napi_poll,
>                                NAPI_POLL_WEIGHT);
>                 napi_enable(&tfile->napi);
> +               mutex_init(&tfile->napi_mutex);
>         }
>  }
>
> @@ -292,6 +296,11 @@ static void tun_napi_del(struct tun_struct *tun, struct tun_file *tfile)
>                 netif_napi_del(&tfile->napi);
>  }
>
> +static bool tun_napi_frags_enabled(const struct tun_struct *tun)
> +{
> +       return READ_ONCE(tun->flags) & IFF_NAPI_FRAGS;
> +}
> +
>  #ifdef CONFIG_TUN_VNET_CROSS_LE
>  static inline bool tun_legacy_is_little_endian(struct tun_struct *tun)
>  {
> @@ -1036,7 +1045,8 @@ static void tun_poll_controller(struct net_device *dev)
>          * supports polling, which enables bridge devices in virt setups to
>          * still use netconsole
>          * If NAPI is enabled, however, we need to schedule polling for all
> -        * queues.
> +        * queues unless we are using napi_gro_frags(), which we call in
> +        * process context and not in NAPI context.
>          */
>         struct tun_struct *tun = netdev_priv(dev);
>
> @@ -1044,6 +1054,9 @@ static void tun_poll_controller(struct net_device *dev)
>                 struct tun_file *tfile;
>                 int i;
>
> +               if (tun_napi_frags_enabled(tun))
> +                       return;
> +
>                 rcu_read_lock();
>                 for (i = 0; i < tun->numqueues; i++) {
>                         tfile = rcu_dereference(tun->tfiles[i]);
> @@ -1266,6 +1279,64 @@ static unsigned int tun_chr_poll(struct file *file, poll_table *wait)
>         return mask;
>  }
>
> +static struct sk_buff *tun_napi_alloc_frags(struct tun_file *tfile,
> +                                           size_t len,
> +                                           const struct iov_iter *it)
> +{
> +       struct sk_buff *skb;
> +       size_t linear;
> +       int err;
> +       int i;
> +
> +       if (it->nr_segs > MAX_SKB_FRAGS + 1)
> +               return ERR_PTR(-ENOMEM);
> +
> +       local_bh_disable();
> +       skb = napi_get_frags(&tfile->napi);
> +       local_bh_enable();
> +       if (!skb)
> +               return ERR_PTR(-ENOMEM);
> +
> +       linear = iov_iter_single_seg_count(it);
> +       err = __skb_grow(skb, linear);
> +       if (err)
> +               goto free;
> +
> +       skb->len = len;
> +       skb->data_len = len - linear;
> +       skb->truesize += skb->data_len;
> +
> +       for (i = 1; i < it->nr_segs; i++) {
> +               size_t fragsz = it->iov[i].iov_len;
> +               unsigned long offset;
> +               struct page *page;
> +               void *data;
> +
> +               if (fragsz == 0 || fragsz > PAGE_SIZE) {
> +                       err = -EINVAL;
> +                       goto free;
> +               }
> +
> +               local_bh_disable();
> +               data = napi_alloc_frag(fragsz);
> +               local_bh_enable();
> +               if (!data) {
> +                       err = -ENOMEM;
> +                       goto free;
> +               }
> +
> +               page = virt_to_head_page(data);
> +               offset = data - page_address(page);
> +               skb_fill_page_desc(skb, i - 1, page, offset, fragsz);
> +       }
> +
> +       return skb;
> +free:
> +       /* frees skb and all frags allocated with napi_alloc_frag() */
> +       napi_free_frags(&tfile->napi);
> +       return ERR_PTR(err);
> +}
> +
>  /* prepad is the amount to reserve at front.  len is length after that.
>   * linear is a hint as to how much to copy (usually headers). */
>  static struct sk_buff *tun_alloc_skb(struct tun_file *tfile,
> @@ -1478,6 +1549,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>         int err;
>         u32 rxhash;
>         int skb_xdp = 1;
> +       bool frags = tun_napi_frags_enabled(tun);
>
>         if (!(tun->dev->flags & IFF_UP))
>                 return -EIO;
> @@ -1535,7 +1607,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>                         zerocopy = true;
>         }
>
> -       if (tun_can_build_skb(tun, tfile, len, noblock, zerocopy)) {
> +       if (!frags && tun_can_build_skb(tun, tfile, len, noblock, zerocopy)) {
>                 /* For the packet that is not easy to be processed
>                  * (e.g gso or jumbo packet), we will do it at after
>                  * skb was created with generic XDP routine.
> @@ -1556,10 +1628,24 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>                                 linear = tun16_to_cpu(tun, gso.hdr_len);
>                 }
>
> -               skb = tun_alloc_skb(tfile, align, copylen, linear, noblock);
> +               if (frags) {
> +                       mutex_lock(&tfile->napi_mutex);
> +                       skb = tun_napi_alloc_frags(tfile, copylen, from);
> +                       /* tun_napi_alloc_frags() enforces a layout for the skb.
> +                        * If zerocopy is enabled, then this layout will be
> +                        * overwritten by zerocopy_sg_from_iter().
> +                        */
> +                       zerocopy = false;
> +               } else {
> +                       skb = tun_alloc_skb(tfile, align, copylen, linear,
> +                                           noblock);
> +               }
> +
>                 if (IS_ERR(skb)) {
>                         if (PTR_ERR(skb) != -EAGAIN)
>                                 this_cpu_inc(tun->pcpu_stats->rx_dropped);
> +                       if (frags)
> +                               mutex_unlock(&tfile->napi_mutex);
>                         return PTR_ERR(skb);
>                 }
>
> @@ -1571,6 +1657,11 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>                 if (err) {
>                         this_cpu_inc(tun->pcpu_stats->rx_dropped);
>                         kfree_skb(skb);
> +                       if (frags) {
> +                               tfile->napi.skb = NULL;
> +                               mutex_unlock(&tfile->napi_mutex);
> +                       }
> +
>                         return -EFAULT;
>                 }
>         }
> @@ -1578,6 +1669,11 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>         if (virtio_net_hdr_to_skb(skb, &gso, tun_is_little_endian(tun))) {
>                 this_cpu_inc(tun->pcpu_stats->rx_frame_errors);
>                 kfree_skb(skb);
> +               if (frags) {
> +                       tfile->napi.skb = NULL;
> +                       mutex_unlock(&tfile->napi_mutex);
> +               }
> +
>                 return -EINVAL;
>         }
>
> @@ -1603,7 +1699,8 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>                 skb->dev = tun->dev;
>                 break;
>         case IFF_TAP:
> -               skb->protocol = eth_type_trans(skb, tun->dev);
> +               if (!frags)
> +                       skb->protocol = eth_type_trans(skb, tun->dev);
>                 break;
>         }
>
> @@ -1638,7 +1735,23 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>
>         rxhash = __skb_get_hash_symmetric(skb);
>
> -       if (tun->flags & IFF_NAPI) {
> +       if (frags) {
> +               /* Exercise flow dissector code path. */
> +               u32 headlen = eth_get_headlen(skb->data, skb_headlen(skb));
> +
> +               if (headlen > skb_headlen(skb) || headlen < ETH_HLEN) {
> +                       this_cpu_inc(tun->pcpu_stats->rx_dropped);
> +                       napi_free_frags(&tfile->napi);
> +                       mutex_unlock(&tfile->napi_mutex);
> +                       WARN_ON(1);
> +                       return -ENOMEM;
> +               }
> +
> +               local_bh_disable();
> +               napi_gro_frags(&tfile->napi);
> +               local_bh_enable();
> +               mutex_unlock(&tfile->napi_mutex);
> +       } else if (tun->flags & IFF_NAPI) {
>                 struct sk_buff_head *queue = &tfile->sk.sk_write_queue;
>                 int queue_len;
>
> @@ -2061,6 +2174,15 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>         if (tfile->detached)
>                 return -EINVAL;
>
> +       if ((ifr->ifr_flags & IFF_NAPI_FRAGS)) {
> +               if (!capable(CAP_NET_ADMIN))
> +                       return -EPERM;
> +
> +               if (!(ifr->ifr_flags & IFF_NAPI) ||
> +                   (ifr->ifr_flags & TUN_TYPE_MASK) != IFF_TAP)
> +                       return -EINVAL;
> +       }
> +
>         dev = __dev_get_by_name(net, ifr->ifr_name);
>         if (dev) {
>                 if (ifr->ifr_flags & IFF_TUN_EXCL)
> diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
> index 30b6184884eb..365ade5685c9 100644
> --- a/include/uapi/linux/if_tun.h
> +++ b/include/uapi/linux/if_tun.h
> @@ -61,6 +61,7 @@
>  #define IFF_TUN                0x0001
>  #define IFF_TAP                0x0002
>  #define IFF_NAPI       0x0010
> +#define IFF_NAPI_FRAGS 0x0020
>  #define IFF_NO_PI      0x1000
>  /* This flag has no real effect */
>  #define IFF_ONE_QUEUE  0x2000
> --
> 2.11.0
>
