From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next V4 3/3] net: Add GRO support for vxlan traffic
Date: Tue, 14 Jan 2014 23:47:17 +0200
Message-ID: <CAJZOPZJP7NGdQnHs1tVXny19w4mstEaEBi5WEvktZ4MumCfy0w@mail.gmail.com>
References: <1389715212-14504-1-git-send-email-ogerlitz@mellanox.com>
	<1389715212-14504-4-git-send-email-ogerlitz@mellanox.com>
	<CA+mtBx_HSwucbA-8v9rENBATSpk+o4gUnNuyortkKRzGffjN7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:63599 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751655AbaANVrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 16:47:17 -0500
Received: by mail-pb0-f51.google.com with SMTP id rp16so203151pbb.24
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 13:47:17 -0800 (PST)
In-Reply-To: <CA+mtBx_HSwucbA-8v9rENBATSpk+o4gUnNuyortkKRzGffjN7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 7:59 PM, Tom Herbert <therbert@google.com> wrote:
>
> On Tue, Jan 14, 2014 at 8:00 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> > Add GRO handlers for vxlann, by using the UDP GRO infrastructure.

[...]
>
> >  /* Notify netdevs that UDP port started listening */
> > -static void vxlan_notify_add_rx_port(struct sock *sk)
> > +static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
> >  {
> >         struct net_device *dev;
> > +       struct sock *sk = vs->sock->sk;
> >         struct net *net = sock_net(sk);
> >         sa_family_t sa_family = sk->sk_family;
> >         __be16 port = inet_sk(sk)->inet_sport;
> > +       int err;
> > +
> > +       if (sa_family == AF_INET) {

> Is this necessary? What about support for AF_INET6?

Point taken -- the UDP GRO code for both ipv4 and ipv6 would work the same.

So we can export udp_gro_receive/complete from net/ipv4/udp_offload.c
such that they can be referred from net/ipv6/udp_offload.c


>
> > +               err = udp_add_offload(&vs->udp_offloads);
> > +               if (err)
> > +                       pr_warn("vxlan: udp_add_offload failed with status %d\n", err);
> > +       }
> >
> >         rcu_read_lock();
> >         for_each_netdev_rcu(net, dev) {
