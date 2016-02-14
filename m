From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v1 6/8] xen-netback: add an implementation of
 toeplitz hashing...
Date: Sun, 14 Feb 2016 23:13:27 +0100
Message-ID: <CALx6S36vp=VKsS4V3_Voz2NGV80nBGADfVSwzXtk8rOdBZZo7Q@mail.gmail.com>
References: <1455272005-17144-1-git-send-email-paul.durrant@citrix.com>
	<1455272005-17144-7-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	xen-devel@lists.xenproject.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:35947 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452AbcBNWN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2016 17:13:28 -0500
Received: by mail-ig0-f177.google.com with SMTP id xg9so41042616igb.1
        for <netdev@vger.kernel.org>; Sun, 14 Feb 2016 14:13:28 -0800 (PST)
In-Reply-To: <1455272005-17144-7-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 12, 2016 at 11:13 AM, Paul Durrant <paul.durrant@citrix.com> wrote:
> ...for receive-side packets.
>
> My recent patch to include/xen/interface/io/netif.h defines a set of
> control messages that can be used by a VM frontend driver to configure
> toeplitz hashing of receive-side packets and consequent steering of those
> packets to particular queues.
>
> This patch introduces an implementation of toeplitz hashing and into
> xen-netback and allows it to be configured using the new control messages.
>
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/net/xen-netback/common.h    |  13 ++++
>  drivers/net/xen-netback/interface.c | 149 ++++++++++++++++++++++++++++++++++++
>  drivers/net/xen-netback/netback.c   | 128 ++++++++++++++++++++++++++++++-
>  3 files changed, 287 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> index 093a12a..6687702 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -220,6 +220,12 @@ struct xenvif_mcast_addr {
>
>  #define XEN_NETBK_MCAST_MAX 64
>
> +#define XEN_NETBK_MAX_TOEPLITZ_KEY_SIZE 40
> +
> +#define XEN_NETBK_MAX_TOEPLITZ_MAPPING_ORDER 7
> +#define XEN_NETBK_MAX_TOEPLITZ_MAPPING_SIZE \
> +       BIT(XEN_NETBK_MAX_TOEPLITZ_MAPPING_ORDER)
> +
>  struct xenvif {
>         /* Unique identifier for this interface. */
>         domid_t          domid;
> @@ -251,6 +257,13 @@ struct xenvif {
>         unsigned int num_queues; /* active queues, resource allocated */
>         unsigned int stalled_queues;
>
> +       struct {
> +               u32 flags;
> +               u8 key[XEN_NETBK_MAX_TOEPLITZ_KEY_SIZE];
> +               u32 mapping[XEN_NETBK_MAX_TOEPLITZ_MAPPING_SIZE];
> +               unsigned int order;
> +       } toeplitz;
> +
>         struct xenbus_watch credit_watch;
>         struct xenbus_watch mcast_ctrl_watch;
>
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 1850ebb..230afde 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -1,3 +1,4 @@
> +
>  /*
>   * Network-device interface management.
>   *
> @@ -151,6 +152,153 @@ void xenvif_wake_queue(struct xenvif_queue *queue)
>         netif_tx_wake_queue(netdev_get_tx_queue(dev, id));
>  }
>
> +static u32 toeplitz_hash(const u8 *k, unsigned int klen,
> +                        const u8 *d, unsigned int dlen)

This should be a common library function, probably in lib directory.

> +{
> +       unsigned int di, ki;
> +       u64 prefix = 0;
> +       u64 hash = 0;
> +
> +       /* Pre-load prefix with the first 8 bytes of the key */
> +       for (ki = 0; ki < 8; ki++) {
> +               prefix <<= 8;
> +               prefix |= (ki < klen) ? k[ki] : 0;
> +       }
> +
> +       for (di = 0; di < dlen; di++) {
> +               u8 byte = d[di];
> +               unsigned int bit;
> +
> +               for (bit = 0x80; bit != 0; bit >>= 1) {
> +                       if (byte & bit)
> +                               hash ^= prefix;
> +                       prefix <<= 1;
> +               }
> +
> +               /* prefix has now been left-shifted by 8, so OR in
> +                * the next byte.
> +                */
> +               prefix |= (ki < klen) ? k[ki] : 0;
> +               ki++;
> +       }
> +
> +       /* The valid part of the hash is in the upper 32 bits. */
> +       return hash >> 32;
> +}
> +
> +static void xenvif_set_toeplitz_hash(struct xenvif *vif, struct sk_buff *skb)
> +{
> +       struct flow_keys flow;
> +       u32 hash = 0;
> +       enum pkt_hash_types type = PKT_HASH_TYPE_NONE;
> +       const u8 *key = vif->toeplitz.key;
> +       u32 flags = vif->toeplitz.flags;
> +       const unsigned int len = XEN_NETBK_MAX_TOEPLITZ_KEY_SIZE;
> +       bool has_tcp_hdr;
> +
> +       /* Quick rejection test: If the network protocol doesn't
> +        * correspond to any enabled hash type then there's no point
> +        * in parsing the packet header.
> +        */
> +       switch (skb->protocol) {
> +       case htons(ETH_P_IP):
> +               if (flags & (XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV4_TCP |
> +                            XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV4))
> +                       break;
> +
> +               goto done;
> +
> +       case htons(ETH_P_IPV6):
> +               if (flags & (XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV6_TCP |
> +                            XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV6))
> +                       break;
> +
> +               goto done;
> +
> +       default:
> +               goto done;
> +       }
> +
> +       memset(&flow, 0, sizeof(flow));
> +       if (!skb_flow_dissect_flow_keys(skb, &flow, 0))

Flow dissector will parse into encapsulations to find IP addresses.
This may or may not be what you want (we'd have to look at NDIS spec).

> +               goto done;
> +
> +       has_tcp_hdr = (flow.basic.ip_proto == IPPROTO_TCP) &&
> +                     !(flow.control.flags & FLOW_DIS_IS_FRAGMENT);
> +
> +       switch (skb->protocol) {
> +       case htons(ETH_P_IP):
> +               if (has_tcp_hdr &&
> +                   (flags & XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV4_TCP)) {
> +                       u8 data[12];
> +
> +                       memcpy(&data[0], &flow.addrs.v4addrs.src, 4);
> +                       memcpy(&data[4], &flow.addrs.v4addrs.dst, 4);
> +                       memcpy(&data[8], &flow.ports.src, 2);
> +                       memcpy(&data[10], &flow.ports.dst, 2);
> +
> +                       hash = toeplitz_hash(key, len,
> +                                            data, sizeof(data));
> +                       type = PKT_HASH_TYPE_L4;
> +               } else if (flags & XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV4) {
> +                       u8 data[8];
> +
> +                       memcpy(&data[0], &flow.addrs.v4addrs.src, 4);
> +                       memcpy(&data[4], &flow.addrs.v4addrs.dst, 4);
> +
> +                       hash = toeplitz_hash(key, len,
> +                                            data, sizeof(data));
> +                       type = PKT_HASH_TYPE_L3;
> +               }
> +
> +               break;
> +
> +       case htons(ETH_P_IPV6):
> +               if (has_tcp_hdr &&
> +                   (flags & XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV6_TCP)) {
> +                       u8 data[36];
> +
> +                       memcpy(&data[0], &flow.addrs.v6addrs.src, 16);
> +                       memcpy(&data[16], &flow.addrs.v6addrs.dst, 16);
> +                       memcpy(&data[32], &flow.ports.src, 2);
> +                       memcpy(&data[34], &flow.ports.dst, 2);
> +
> +                       hash = toeplitz_hash(key, len,
> +                                            data, sizeof(data));
> +                       type = PKT_HASH_TYPE_L4;
> +               } else if (flags & XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV6) {
> +                       u8 data[32];
> +
> +                       memcpy(&data[0], &flow.addrs.v6addrs.src, 16);
> +                       memcpy(&data[16], &flow.addrs.v6addrs.dst, 16);
> +
> +                       hash = toeplitz_hash(key, len,
> +                                            data, sizeof(data));
> +                       type = PKT_HASH_TYPE_L3;
> +               }
> +
> +               break;
> +       }
> +
> +done:
> +       skb_set_hash(skb, hash, type);

Is this necessary, it is potentially overwriting a valid L4 hash that
might be used later in sometling like RFS? Why not just return the
hash value.

> +}
> +
> +static u16 xenvif_select_queue(struct net_device *dev, struct sk_buff *skb,
> +                              void *accel_priv,
> +                              select_queue_fallback_t fallback)
> +{
> +       struct xenvif *vif = netdev_priv(dev);
> +       unsigned int mask = (1u << vif->toeplitz.order) - 1;
> +
> +       if (vif->toeplitz.flags == 0)
> +               return fallback(dev, skb) % dev->real_num_tx_queues;
> +
> +       xenvif_set_toeplitz_hash(vif, skb);
> +
> +       return vif->toeplitz.mapping[skb_get_hash_raw(skb) & mask];
> +}
> +
>  static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>         struct xenvif *vif = netdev_priv(dev);
> @@ -395,6 +543,7 @@ static const struct ethtool_ops xenvif_ethtool_ops = {
>  };
>
>  static const struct net_device_ops xenvif_netdev_ops = {
> +       .ndo_select_queue = xenvif_select_queue,
>         .ndo_start_xmit = xenvif_start_xmit,
>         .ndo_get_stats  = xenvif_get_stats,
>         .ndo_open       = xenvif_open,
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index a1f1a38..41ec7e9 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -2163,6 +2163,89 @@ int xenvif_dealloc_kthread(void *data)
>         return 0;
>  }
>
> +static u32 xenvif_set_toeplitz_flags(struct xenvif *vif, u32 flags)
> +{
> +       if (flags & ~(XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV4 |
> +                     XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV4_TCP |
> +                     XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV6 |
> +                     XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV6_TCP))
> +               return XEN_NETIF_CTRL_STATUS_INVALID_PARAMETER;
> +
> +       vif->toeplitz.flags = flags;
> +
> +       return XEN_NETIF_CTRL_STATUS_SUCCESS;
> +}
> +
> +static u32 xenvif_set_toeplitz_key(struct xenvif *vif, u32 gref, u32 len)
> +{
> +       u8 *key = vif->toeplitz.key;
> +       struct gnttab_copy copy_op = {
> +               .source.u.ref = gref,
> +               .source.domid = vif->domid,
> +               .dest.u.gmfn = virt_to_gfn(key),
> +               .dest.domid = DOMID_SELF,
> +               .dest.offset = xen_offset_in_page(key),
> +               .len = len,
> +               .flags = GNTCOPY_source_gref
> +       };
> +
> +       if (len > XEN_NETBK_MAX_TOEPLITZ_KEY_SIZE)
> +               return XEN_NETIF_CTRL_STATUS_INVALID_PARAMETER;
> +
> +       gnttab_batch_copy(&copy_op, 1);
> +
> +       if (copy_op.status != GNTST_okay)
> +               return XEN_NETIF_CTRL_STATUS_INVALID_PARAMETER;
> +
> +       /* Clear any remaining key octets */
> +       if (len < XEN_NETBK_MAX_TOEPLITZ_KEY_SIZE)
> +               memset(key + len, 0, XEN_NETBK_MAX_TOEPLITZ_KEY_SIZE - len);
> +
> +       return XEN_NETIF_CTRL_STATUS_SUCCESS;
> +}
> +
> +static u32 xenvif_set_toeplitz_mapping_order(struct xenvif *vif,
> +                                            u32 order)
> +{
> +       if (order > XEN_NETBK_MAX_TOEPLITZ_MAPPING_ORDER)
> +               return XEN_NETIF_CTRL_STATUS_INVALID_PARAMETER;
> +
> +       vif->toeplitz.order = order;
> +       memset(vif->toeplitz.mapping, 0, sizeof(u32) << order);
> +
> +       return XEN_NETIF_CTRL_STATUS_SUCCESS;
> +}
> +
> +static u32 xenvif_set_toeplitz_mapping(struct xenvif *vif, u32 gref,
> +                                      u32 len, u32 off)
> +{
> +       u32 *mapping = &vif->toeplitz.mapping[off];
> +       struct gnttab_copy copy_op = {
> +               .source.u.ref = gref,
> +               .source.domid = vif->domid,
> +               .dest.u.gmfn = virt_to_gfn(mapping),
> +               .dest.domid = DOMID_SELF,
> +               .dest.offset = xen_offset_in_page(mapping),
> +               .len = len * sizeof(u32),
> +               .flags = GNTCOPY_source_gref
> +       };
> +
> +       if ((off + len > (1u << vif->toeplitz.order)) ||
> +           copy_op.len > XEN_PAGE_SIZE)
> +               return XEN_NETIF_CTRL_STATUS_INVALID_PARAMETER;
> +
> +       while (len-- != 0)
> +               if (mapping[off++] >= vif->num_queues)
> +                       return XEN_NETIF_CTRL_STATUS_INVALID_PARAMETER;
> +
> +       gnttab_batch_copy(&copy_op, 1);
> +
> +       if (copy_op.status != GNTST_okay)
> +               return XEN_NETIF_CTRL_STATUS_INVALID_PARAMETER;
> +
> +       return XEN_NETIF_CTRL_STATUS_SUCCESS;
> +}
> +
>  static void make_ctrl_response(struct xenvif *vif,
>                                const struct xen_netif_ctrl_request *req,
>                                u32 status, u32 data)
> @@ -2191,9 +2274,48 @@ static void push_ctrl_response(struct xenvif *vif)
>  static void process_ctrl_request(struct xenvif *vif,
>                                  const struct xen_netif_ctrl_request *req)
>  {
> -       /* There is no support for control requests yet. */
> -       make_ctrl_response(vif, req,
> -                          XEN_NETIF_CTRL_STATUS_NOT_SUPPORTED, 0);
> +       u32 status = XEN_NETIF_CTRL_STATUS_NOT_SUPPORTED;
> +       u32 data = 0;
> +
> +       switch (req->type) {
> +       case XEN_NETIF_CTRL_TYPE_GET_TOEPLITZ_FLAGS:
> +               status = XEN_NETIF_CTRL_STATUS_SUCCESS;
> +               data = XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV4 |
> +                      XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV4_TCP |
> +                      XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV6 |
> +                      XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV6_TCP;
> +               break;
> +
> +       case XEN_NETIF_CTRL_TYPE_SET_TOEPLITZ_FLAGS:
> +               status = xenvif_set_toeplitz_flags(vif, req->data[0]);
> +               break;
> +
> +       case XEN_NETIF_CTRL_TYPE_SET_TOEPLITZ_KEY:
> +               status = xenvif_set_toeplitz_key(vif, req->data[0],
> +                                                req->data[1]);
> +               break;
> +
> +       case XEN_NETIF_CTRL_TYPE_GET_TOEPLITZ_MAPPING_ORDER:
> +               status = XEN_NETIF_CTRL_STATUS_SUCCESS;
> +               data = XEN_NETBK_MAX_TOEPLITZ_MAPPING_ORDER;
> +               break;
> +
> +       case XEN_NETIF_CTRL_TYPE_SET_TOEPLITZ_MAPPING_ORDER:
> +               status = xenvif_set_toeplitz_mapping_order(vif,
> +                                                          req->data[0]);
> +               break;
> +
> +       case XEN_NETIF_CTRL_TYPE_SET_TOEPLITZ_MAPPING:
> +               status = xenvif_set_toeplitz_mapping(vif, req->data[0],
> +                                                    req->data[1],
> +                                                    req->data[2]);
> +               break;
> +
> +       default:
> +               break;
> +       }
> +
> +       make_ctrl_response(vif, req, status, data);
>         push_ctrl_response(vif);
>  }
>
> --
> 2.1.4
>
