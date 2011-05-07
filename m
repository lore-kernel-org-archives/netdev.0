From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] ipv4: Initialize on-stack cork more efficiently.
Date: Sat, 07 May 2011 07:11:44 +0200
Message-ID: <1304745104.2821.590.camel@edumazet-laptop>
References: <20110506.152623.232747437.davem@davemloft.net>
	 <1304721317.2821.156.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44284 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490Ab1EGFLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 01:11:49 -0400
Received: by wya21 with SMTP id 21so2824892wya.19
        for <netdev@vger.kernel.org>; Fri, 06 May 2011 22:11:48 -0700 (PDT)
In-Reply-To: <1304721317.2821.156.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 07 mai 2011 =C3=A0 00:35 +0200, Eric Dumazet a =C3=A9crit :
> Le vendredi 06 mai 2011 =C3=A0 15:26 -0700, David Miller a =C3=A9crit=
 :
> > ip_setup_cork() explicitly initializes every member of
> > inet_cork except flags, addr, and opt.  So we can simply
> > set those three members to zero instead of using a
> > memset() via an empty struct assignment.
> >=20
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> > ---
> >  net/ipv4/ip_output.c |    5 ++++-
> >  1 files changed, 4 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> > index eb0647a..5f5fe4f 100644
> > --- a/net/ipv4/ip_output.c
> > +++ b/net/ipv4/ip_output.c
> > @@ -1408,7 +1408,7 @@ struct sk_buff *ip_make_skb(struct sock *sk,
> >  			    struct ipcm_cookie *ipc, struct rtable **rtp,
> >  			    unsigned int flags)
> >  {
> > -	struct inet_cork cork =3D {};
> > +	struct inet_cork cork;
> >  	struct sk_buff_head queue;
> >  	int err;
> > =20
> > @@ -1417,6 +1417,9 @@ struct sk_buff *ip_make_skb(struct sock *sk,
> > =20
> >  	__skb_queue_head_init(&queue);
> > =20
> > +	cork.flags =3D 0;
> > +	cork.addr =3D 0;
> > +	cork.opt =3D 0;
> >  	err =3D ip_setup_cork(sk, &cork, ipc, rtp);
> >  	if (err)
> >  		return ERR_PTR(err);
>=20
> Very nice, thanks for finishing this stuff :)
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20

By the way, when I spotted this "struct inet_cork cork =3D {};" to be
optimized, my idea was to add yet another case of fastpath to UDP send =
:

=46or small datagrams (most UDP uses : RTP, DNS...),
perform the user->kernel copy before route lookup, so that we can
perform an RCU route lookup. This would tremendously speedup UDP, since
the refcount handling is our last hot spot (not counting qdisc if
present)

   PerfTop:   16142 irqs/sec  kernel:97.5%  exact:  0.0% [1000Hz cycles=
],  (all, 16 CPUs)
-----------------------------------------------------------------------=
------------------------------------

             samples  pcnt function                 DSO
             _______ _____ ________________________ ___________________=
___

            16735.00 24.2% __ip_route_output_key    vmlinux            =
  =20
             9706.00 14.1% dst_release              vmlinux            =
  =20
             6754.00  9.8% __ip_make_skb            vmlinux            =
  =20
             5737.00  8.3% udp_send_skb             vmlinux            =
  =20
             5384.00  7.8% ip_finish_output         vmlinux            =
  =20
             3578.00  5.2% udp_sendmsg              vmlinux            =
  =20
             1435.00  2.1% copy_user_generic_string vmlinux            =
  =20
             1358.00  2.0% ia32_sysenter_target     vmlinux            =
  =20
             1095.00  1.6% __ip_append_data         vmlinux            =
  =20
              832.00  1.2% kfree                    vmlinux            =
  =20
              794.00  1.2% __memset                 vmlinux            =
  =20
              677.00  1.0% fget_light               vmlinux            =
  =20
              641.00  0.9% sock_wfree               vmlinux            =
  =20
              637.00  0.9% dev_queue_xmit           vmlinux            =
  =20


