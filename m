From: Tom Herbert <tom@herbertland.com>
Subject: Re: [pull request][net-next 0/3] Mellanox, mlx5 GRE tunnel offloads
Date: Sun, 3 Sep 2017 09:45:00 -0700
Message-ID: <CALx6S34c_Kw9MXxM9hxtps0pOQYScJHftzdJ_pun68xjQzcGHA@mail.gmail.com>
References: <20170830230409.15176-1-saeedm@mellanox.com> <87fuc7ong0.fsf@stressinduktion.org>
 <CALzJLG-u3k11LYFXtZQKT5cvn-iJ4FehBUgkhCHT5Z7XMsMkpA@mail.gmail.com>
 <1504402349.3299394.1093467800.72B91372@webmail.messagingengine.com>
 <CALx6S34kfb5GEH9AAecsaKJ9AtjK=fP_3L=2i98kUwv_sE2s7A@mail.gmail.com>
 <CALzJLG--t8VLs1GiRRVfejenB=XgpLiJHnHC+eokQ4=kwj9hGw@mail.gmail.com>
 <CALx6S356vRYfcsN6FaRmpn2oC0GN9-JwLsF7ybC+w4sEGGsa7w@mail.gmail.com> <CAJ3xEMiNKVZnPcqDavmRduQjJRZSOZTFYOP1-ghpREXegLaB-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:37615 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753068AbdICQpB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 12:45:01 -0400
Received: by mail-qt0-f193.google.com with SMTP id x29so3125281qtc.4
        for <netdev@vger.kernel.org>; Sun, 03 Sep 2017 09:45:01 -0700 (PDT)
In-Reply-To: <CAJ3xEMiNKVZnPcqDavmRduQjJRZSOZTFYOP1-ghpREXegLaB-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Re all sorts of udp encap, sure, we're all on the less-is-more thing and just
> RSS-ing on the ip+udp encap header.
>
> For GRE, I was trying to fight back that rss-ing on inner, but as
> Saeed commented,
> we didn't see something simple through which the HW can do spreading. To make
> sure I follow, you are saying that if this is gre6 tunneling
>
It's pretty common that HW does this since GRE is in widespread use for a while.

> net-next.git]# git grep -p ip6_make_flowlabel net/ include/linux/ include/net/
> include/net/ipv6.h=static inline void iph_to_flow_copy_v6addrs(struct
> flow_keys *flow,
> include/net/ipv6.h:static inline __be32 ip6_make_flowlabel(struct net
> *net, struct sk_buff *skb,
> include/net/ipv6.h=static inline void ip6_set_txhash(struct sock *sk) { }
> include/net/ipv6.h:static inline __be32 ip6_make_flowlabel(struct net
> *net, struct sk_buff *skb,
> net/ipv6/ip6_gre.c=static int ip6gre_header(struct sk_buff *skb,
> struct net_device *dev,
> net/ipv6/ip6_gre.c:                  ip6_make_flowlabel(dev_net(dev), skb,
> net/ipv6/ip6_output.c=int ip6_xmit(const struct sock *sk, struct
> sk_buff *skb, struct flowi6 *fl6,
> net/ipv6/ip6_output.c:  ip6_flow_hdr(hdr, tclass,
> ip6_make_flowlabel(net, skb, fl6->flowlabel,
> net/ipv6/ip6_output.c=struct sk_buff *__ip6_make_skb(struct sock *sk,
> net/ipv6/ip6_output.c:               ip6_make_flowlabel(net, skb,
> fl6->flowlabel,
> net/ipv6/ip6_tunnel.c=int ip6_tnl_xmit(struct sk_buff *skb, struct
> net_device *dev, __u8 dsfield,
> net/ipv6/ip6_tunnel.c:               ip6_make_flowlabel(net, skb,
> fl6->flowlabel, true, fl6));
>
Seems right.

> the sender side (ip6_tnl_xmit?) will set the IPv6 flow label in a
> similar manner done by udp_flow_src_port? and
> if the receiver side hashes on L3 IPv6 src/dst/flow label we'll get
> spreading? nice!
>
As long as the network devices support it.

> Still, what do we do with IPv4 GRE tunnels? and what do we do with HW
> which isn't capable to RSS on flow label?
>
Throw it out and buy hardware that supports flow label! ;-)

Seriously though, flow labels are the only reasonable way that RSS can
be supported in IPv6. If a device tries to do DPI on IPv6 then they'll
eventually need to be able to parse of some number of extension
headers which unlike IPv4 is unbounded in size. So there are going to
be circumstances in which a device either doesn't understand an EH, or
the size of EHs blows it parsing buffer limit so it can't do the DPI.
IMO, telling host implementations that we're not allowed to use
extension headers because middleboxes can't support them is
unacceptable...

Btw, these same arguments apply as to why CHECKSUM_COMPLETE is the
only reasonable way to handle receive checksums in IPv6.

Tom
