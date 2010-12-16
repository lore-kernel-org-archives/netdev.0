From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: increase skb->users instead of skb_clone()
Date: Thu, 16 Dec 2010 15:18:38 +0100
Message-ID: <1292509118.2883.167.camel@edumazet-laptop>
References: <1292479045-3136-1-git-send-email-xiaosuo@gmail.com>
	 <AANLkTikdYi-Cs=4UtjJx-X4bW+LSKTQBTcSv23NS2S+S@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Xinan Tang <xinan.tang@intel.com>, netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37355 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756135Ab0LPOSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 09:18:43 -0500
Received: by wwa36 with SMTP id 36so2479417wwa.1
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 06:18:42 -0800 (PST)
In-Reply-To: <AANLkTikdYi-Cs=4UtjJx-X4bW+LSKTQBTcSv23NS2S+S@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 22:05 +0800, Junchang Wang a =C3=A9=
crit :
> On Thu, Dec 16, 2010 at 1:57 PM, Changli Gao <xiaosuo@gmail.com> wrot=
e:
> > In dev_queue_xmit_nit(), we have to clone skbs as we need to mangle=
 skbs,
> > however, we don't need to clone skbs for all the packet_types.
> >
> > Except for the first packet_type, we increase skb->users instead of
> > skb_clone().
>=20
> Hi Changli,
> Take af_packet for example, I can't see benefit from this patch.
>=20
> > +static inline int deliver_skb(struct sk_buff *skb,
> > +                             struct packet_type *pt_prev,
> > +                             struct net_device *orig_dev)
> > +{
> > +       atomic_inc(&skb->users);
> > +       return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
> > +}
> The increment call will incur skb_shared() failure in packet_rcv.
> In reality, packet_rcv has to clone this packet by itself.
>=20

Yes, and no.

Consider the case you have one receiver.

Packet given after Changli patch wont be shared, so packet_rcv wont
clone it : Thats a win. Only one skb_clone() done instead of two.

Consider case with 2 receivers :

=46irst time we call packet_rcv, packet is shared (because we call
deliver_skb(), so packet_rcv clones it. Normal situation, we really nee=
d
to clone it.

Second time, we give a non shared packet : Thats a win over previous
situation.



