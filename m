From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH V2 net-next] LISP: Locator/Identifier Separation Protocol
Date: Thu, 5 Jun 2014 15:12:31 -0700
Message-ID: <CA+mtBx9OdgWad6WJvNoUWreoyef9sd0AbHAsNWTSHaD1z=Tj8A@mail.gmail.com>
References: <4D3092DF-BB04-4C50-88B9-EBBA349C7B17@logicalelegance.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Vina Ermagan (vermagan)" <vermagan@cisco.com>,
	"Lorand Jakab -X (lojakab - M SQUARED CONSULTING INC. at Cisco)"
	<lojakab@cisco.com>
To: Christopher White <chris@logicalelegance.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:63486 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752980AbaFEWMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 18:12:32 -0400
Received: by mail-ie0-f171.google.com with SMTP id to1so1544934ieb.2
        for <netdev@vger.kernel.org>; Thu, 05 Jun 2014 15:12:32 -0700 (PDT)
In-Reply-To: <4D3092DF-BB04-4C50-88B9-EBBA349C7B17@logicalelegance.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chris. Some comments inline.

On Thu, Jun 5, 2014 at 2:14 PM, Christopher White
<chris@logicalelegance.com> wrote:
> This is a static tunnel implementation of LISP as described in RFC 6830:
>   http://tools.ietf.org/html/rfc6830
>
> This driver provides point-to-point LISP dataplane
> encapsulation/decapsulation for statically configured endpoints. It provides
> support for IPv4 in IPv4 and IPv6 in IPv4. IPv6 outer headers are not
> supported yet. Instance ID is supported on a per device basis.

Please add GRO support also (maybe as a follow-on patch). This should
be pretty straightforward.

> +static inline struct rtable *find_route(struct net *net,
> +                                       __be32 *saddr, __be32 daddr,
> +                                       u8 ipproto, u8 tos, u32 skb_mark)
> +{
> +       struct rtable *rt;
> +
> +       /* Tunnel configuration keeps DSCP part of TOS bits, But Linux
> +        * router expect RT_TOS bits only.
> +        */
> +       struct flowi4 fl = { .daddr             = daddr,
> +                            .saddr             = *saddr,
> +                            .flowi4_tos        = RT_TOS(tos),
> +                            .flowi4_mark       = skb_mark,
> +                            .flowi4_proto      = ipproto };
> +
> +       rt = ip_route_output_key(net, &fl);
> +       *saddr = fl.saddr;
> +       return rt;
> +}
> +
Looks like a function that should be in common header file?


> +/* Compute source UDP port for outgoing packet.
> + * Currently we use the flow hash.
> + */
> +static u16 get_src_port(struct sk_buff *skb, struct net *net)
> +{
> +       u32 hash = skb_get_hash(skb);
> +       unsigned int range;
> +       int high;
> +       int low;
> +
> +       if (!hash)
> +               hash = jhash2((const u32 *)skb->data, 2 * ETH_ALEN, 0);
> +
> +       inet_get_local_port_range(net, &low, &high);
> +       range = (high - low) + 1;
> +       return (((u64)hash * range) >> 32) + low;
> +}
> +

This is going to be a common function in UDP tunneling protocols so it
should probably be in udp.h and maybe called udp_tunnel_get_src_port
(returns __be16 also). VXLAN should be fixed to call this also instead
of having its own version.

> +static void lisp_build_header(const struct lisp_dev *dev,
> +                             struct sk_buff *skb)
> +{
> +       struct udphdr *udph = udp_hdr(skb);
> +       struct lisphdr *lisph = (struct lisphdr *)(udph + 1);
> +       struct net *net = dev_net(dev->dev);
> +       __u32 iid;
> +
> +       udph->dest = dev->encap_port;
> +       udph->source = htons(get_src_port(skb, net));

Don't need htons of get_src_port is implemented properly.

> +       udph->len = htons(skb->len - skb_transport_offset(skb));
> +
> +       /* We don't support echo nonce algorithm */
> +       lisph->nonce_present = 0;
> +       lisph->locator_status_bits_present = 1; /* Set LSB */
> +       lisph->solicit_echo_nonce = 0;          /* No echo noncing */
> +
> +       /* No mapping versioning, nonce instead */
> +       lisph->map_version_present = 0;
> +
> +       /* Store the tun_id as Instance ID  */
> +       lisph->instance_id_present = 1;
> +
> +       /* Reserved flags, set to 0  */
> +       lisph->reserved_flags = 0;
> +       lisph->u1.nonce[0] = 0;
> +       lisph->u1.nonce[1] = 0;
> +       lisph->u1.nonce[2] = 0;
> +
> +       /* Include the instance ID for this device */
> +       iid = htonl(dev->iid << 8);
> +       memcpy(&lisph->u2.word2.instance_id, &iid, 3);
> +       lisph->u2.word2.locator_status_bits = 1;
> +}
> +
> +static void lisp_sock_put(struct sk_buff *skb)
> +{
> +       sock_put(skb->sk);
> +}
> +
> +/* On transmit, associate with the tunnel socket */
> +static void lisp_set_owner(struct sock *sk, struct sk_buff *skb)
> +{
> +       skb_orphan(skb);
> +       sock_hold(sk);
> +       skb->sk = sk;
> +       skb->destructor = lisp_sock_put;
> +}
> +
> +/* Transmit local sourced packets with LISP encapsulation
> + */
> +static netdev_tx_t lisp_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +       struct lisp_dev *lispdev = netdev_priv(dev);
> +       struct net *net = dev_net(lispdev->dev);
> +       struct lisp_sock *s = lispdev->ls_socket;
> +       int network_offset = skb_network_offset(skb);
> +       struct rtable *rt;
> +       int min_headroom;
> +       __be32 saddr;
> +       __be32 daddr;
> +       __be16 df;
> +       int sent_len;
> +       int err;
> +
> +       if (skb->protocol != htons(ETH_P_IP) &&
> +           skb->protocol != htons(ETH_P_IPV6)) {
> +               kfree_skb(skb);
> +               return 0;
> +       }
> +
> +       /* Route lookup */
> +       saddr = lispdev->local.sin.sin_addr.s_addr;
> +       daddr = lispdev->remote.sin.sin_addr.s_addr;
> +       rt = find_route(net,
> +                       &saddr,
> +                       daddr,
> +                       IPPROTO_UDP,
> +                       lispdev->tos,
> +                       skb->mark);
> +       if (IS_ERR(rt)) {
> +               err = PTR_ERR(rt);
> +               goto error;
> +       }
> +       skb = lisp_handle_offloads(skb,
> +                                  s->sock->sk->sk_no_check_tx);
> +
> +       if (IS_ERR(skb))
> +               goto rx_tx_err;
> +
> +       min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
> +               + sizeof(struct iphdr) + LISP_HLEN;
> +
> +       if (skb_headroom(skb) < min_headroom || skb_header_cloned(skb)) {
> +               int head_delta = SKB_DATA_ALIGN(min_headroom -
> +                                               skb_headroom(skb) +
> +                                               16);
> +
> +               err = pskb_expand_head(skb, max_t(int, head_delta, 0),
> +                                      0, GFP_ATOMIC);
> +               if (unlikely(err))
> +                       goto err_free_rt;
> +       }
> +
> +       /* Reset l2 headers. */
> +       skb_pull(skb, network_offset);
> +       skb_reset_mac_header(skb);
> +       vlan_set_tci(skb, 0);
> +
Is the above necessary, shouldn't there be no mac header when
transmitting on LISP interface?

> +       skb_reset_inner_headers(skb);
> +
> +       __skb_push(skb, LISP_HLEN);
> +       skb_reset_transport_header(skb);
> +
> +       lisp_build_header(lispdev, skb);
> +
> +       /* Offloading */
> +       lisp_set_owner(lispdev->ls_socket->sock->sk, skb);
> +       skb->ignore_df = 1;
> +
> +       df = 0;
> +       udp_set_csum(lispdev->ls_socket->sock->sk, skb, saddr, daddr,
> +                    skb->len);

This should be in lisp_build_header where UDP fields are set.

> +       sent_len = iptunnel_xmit(lispdev->ls_socket->sock->sk, rt, skb,
> +                                saddr, daddr,
> +                                IPPROTO_UDP, lispdev->tos,
> +                                lispdev->ttl, df, false);
> +
> +       iptunnel_xmit_stats(sent_len, &dev->stats, dev->tstats);
> +       return NETDEV_TX_OK;
> +
> +rx_tx_err:
> +       dev->stats.tx_errors++;
> +err_free_rt:
> +       ip_rt_put(rt);
> +error:
> +       iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
> +       return NETDEV_TX_OK;
> +}
> +
> +/* Callback from net/ipv4/udp.c to receive packets */
> +static int lisp_udp_encap_rcv(struct sock *sk, struct sk_buff *skb)
> +{
> +       struct lisp_sock *s;
> +       __be16 port;
> +
> +       if (!pskb_may_pull(skb, LISP_HLEN))
> +               goto error;
> +
> +       if (iptunnel_pull_header(skb, LISP_HLEN, 0))
> +               goto drop;
> +
> +       port = inet_sk(sk)->inet_sport;
> +       s = rcu_dereference_sk_user_data(sk);
> +       if (!s)
> +               goto drop;
> +
> +       /* If the NIC driver gave us an encapsulated packet
> +        * with the encapsulation mark, the device checksummed it
> +        * for us. Otherwise force the upper layers to verify it.
> +        */
> +       if ((skb->ip_summed != CHECKSUM_UNNECESSARY &&
> +            skb->ip_summed != CHECKSUM_PARTIAL) ||
> +           !skb->encapsulation)
> +               skb->ip_summed = CHECKSUM_NONE;
> +
> +       skb->encapsulation = 0;
> +       s->rcv(s, skb);

Why not just call lisp_rcv directly?

> +       return 0;
> +drop:
> +       kfree_skb(skb);
> +       return 0;
> +error:
> +       return 1;
> +}
> +
> +static inline struct lisphdr *lisp_hdr(const struct sk_buff *skb)
> +{
> +       return (struct lisphdr *)(udp_hdr(skb) + 1);
> +}

This is only called in lisp_rcv, no need for function definition.

> +
> +static void lisp_rcv(struct lisp_sock *s,
> +                    struct sk_buff *skb)
> +{
> +       struct lisp_dev *lispdev;
> +       struct iphdr *iph, *inner_iph;
> +       struct lisphdr *lisph;
> +       struct pcpu_sw_netstats *stats;
> +       __be16 protocol;
> +       __u32 iid = 0;
> +
> +       iph = ip_hdr(skb);
> +       lisph = lisp_hdr(skb);
> +       inner_iph = (struct iphdr *)(lisph + 1);
> +       switch (inner_iph->version) {
> +       case 4:
> +               protocol = htons(ETH_P_IP);
> +               break;
> +       case 6:
> +               protocol = htons(ETH_P_IPV6);
> +               break;
> +       default:
> +               kfree_skb(skb);
> +               return;
> +       }
> +
> +       if (lisph->instance_id_present)
> +               iid = ntohl(*((__be32 *)(&lisph->u2.word2.instance_id))) >> 8;
> +
> +       /* Find the IID in our configuration */
> +       lispdev = lisp_find_iid(s, iid);
> +       if (!lispdev) {
> +               netdev_info(lispdev->dev, "Instance ID 0x%x not found\n", iid);
> +               goto drop;
> +       }
> +
> +       skb->protocol = protocol;
> +       skb->dev = lispdev->dev;
> +       skb_reset_network_header(skb);
> +
> +       stats = this_cpu_ptr(lispdev->dev->tstats);
> +       u64_stats_update_begin(&stats->syncp);
> +       stats->rx_packets++;
> +       stats->rx_bytes += skb->len;
> +       u64_stats_update_end(&stats->syncp);
> +
> +       netif_rx(skb);
> +       return;
> +drop:
> +       kfree_skb(skb);
> +}
> +
> +static const struct net_device_ops lisp_netdev_ops = {
> +       .ndo_init               = lisp_init,
> +       .ndo_uninit             = lisp_uninit,
> +       .ndo_start_xmit         = lisp_xmit,
> +       .ndo_get_stats64        = ip_tunnel_get_stats64,
> +       .ndo_change_mtu         = lisp_change_mtu
> +};
> +
> +/* Info for udev */
> +static struct device_type lisp_type = {
> +       .name   = "lisp",
> +};
> +
> +
> +static int create_v4_sock(struct net *net, __be16 port, struct socket **psock,
> +                         u32 flags)
> +{
> +       struct sock *sk;
> +       struct socket *sock;
> +       struct sockaddr_in lisp_addr = {
> +               .sin_family             = AF_INET,
> +               .sin_addr.s_addr        = htonl(INADDR_ANY),
> +               .sin_port               = port,
> +       };
> +       int rc;
> +
> +       /* Create UDP socket for encapsulation receive. */
> +       rc = sock_create_kern(AF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
> +       if (rc < 0) {
> +               pr_debug("UDP socket create failed\n");
> +               return rc;
> +       }
> +
> +       /* Put in proper namespace */
> +       sk = sock->sk;
> +       sk_change_net(sk, net);
> +
> +       rc = kernel_bind(sock, (struct sockaddr *)&lisp_addr,
> +                        sizeof(lisp_addr));
> +       if (rc < 0) {
> +               pr_debug("bind for UDP socket %pI4:%u (%d)\n",
> +                        &lisp_addr.sin_addr, ntohs(lisp_addr.sin_port), rc);
> +               sk_release_kernel(sk);
> +               return rc;
> +       }
> +
> +       *psock = sock;
> +       /* Disable multicast loopback */
> +       inet_sk(sk)->mc_loop = 0;
> +
> +       if (!(flags & LISP_F_UDP_CSUM))
> +               sock->sk->sk_no_check_tx = 1;
> +       return 0;
> +}
Another function that is common among UDP tunneling protocols and
should be in common code.
