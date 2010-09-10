From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: af_packet: don't call tpacket_destruct_skb()
 until the skb is sent out
Date: Fri, 10 Sep 2010 18:58:26 +0200
Message-ID: <1284137906.24675.97.camel@edumazet-laptop>
References: <1284124960-3266-1-git-send-email-xiaosuo@gmail.com>
	 <1284128770.24675.41.camel@edumazet-laptop>
	 <AANLkTi=ZzvCNef7r81WZdbZsiSquYhDrnYAY73r4mo+t@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44541 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992Ab0IJQ6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 12:58:32 -0400
Received: by fxm16 with SMTP id 16so1887237fxm.19
        for <netdev@vger.kernel.org>; Fri, 10 Sep 2010 09:58:31 -0700 (PDT)
In-Reply-To: <AANLkTi=ZzvCNef7r81WZdbZsiSquYhDrnYAY73r4mo+t@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 11 septembre 2010 =C3=A0 00:47 +0800, Changli Gao a =C3=A9cri=
t :
> On Fri, Sep 10, 2010 at 10:26 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:


> > Are you sure sock_wfree(skb) is still needed ?
>=20
> sock_wfree(skb) is also used to wake up the users who sleep on
> poll(2). If sock_wfree(skb) is moved into skb->destructor(), and
> called before skb is sent out, pollers will be waked up without
> POLLOUT, and since the later skb_shinfo(skb)->destructor() doesn't
> wake up the pollers, POLLOUT events will be lost, and the poller will
> be blocked forever.
>=20

Then implement poll() to use the number of available slots.
(not use the default poll() that relies on generic sk / inet queues and
counters)

Really, sock_wfree() cannot be used at all, or we also must disable
early orphaning of these skbs.

Goal is to replace skb->destructor use in af_packet by
shinfo->destructor, not mix the two.


> >
> >
> >> +     kfree(arg);
> >
> > this new kmalloc()/kfree() for each sent packet wont please the guy=
s
> > using af_packet/mmap interface...
>=20
> Embed these two pointers into skb_shared_info? It may slow the others=
=2E

we have some room because of SKB_PAD alignment,




