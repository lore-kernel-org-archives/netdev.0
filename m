From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: af_packet: don't call tpacket_destruct_skb()
 until the skb is sent out
Date: Fri, 10 Sep 2010 19:12:13 +0200
Message-ID: <1284138733.24675.104.camel@edumazet-laptop>
References: <1284124960-3266-1-git-send-email-xiaosuo@gmail.com>
	 <1284128770.24675.41.camel@edumazet-laptop>
	 <AANLkTi=ZzvCNef7r81WZdbZsiSquYhDrnYAY73r4mo+t@mail.gmail.com>
	 <1284137906.24675.97.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52281 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753318Ab0IJRMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 13:12:18 -0400
Received: by fxm16 with SMTP id 16so1900272fxm.19
        for <netdev@vger.kernel.org>; Fri, 10 Sep 2010 10:12:17 -0700 (PDT)
In-Reply-To: <1284137906.24675.97.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 septembre 2010 =C3=A0 18:58 +0200, Eric Dumazet a =C3=A9=
crit :
> Le samedi 11 septembre 2010 =C3=A0 00:47 +0800, Changli Gao a =C3=A9c=
rit :
> > On Fri, Sep 10, 2010 at 10:26 PM, Eric Dumazet <eric.dumazet@gmail.=
com> wrote:
>=20
>=20
> > > Are you sure sock_wfree(skb) is still needed ?
> >=20
> > sock_wfree(skb) is also used to wake up the users who sleep on
> > poll(2). If sock_wfree(skb) is moved into skb->destructor(), and
> > called before skb is sent out, pollers will be waked up without
> > POLLOUT, and since the later skb_shinfo(skb)->destructor() doesn't
> > wake up the pollers, POLLOUT events will be lost, and the poller wi=
ll
> > be blocked forever.
> >=20
>=20
> Then implement poll() to use the number of available slots.
> (not use the default poll() that relies on generic sk / inet queues a=
nd
> counters)
>=20
> Really, sock_wfree() cannot be used at all, or we also must disable
> early orphaning of these skbs.
>=20
> Goal is to replace skb->destructor use in af_packet by
> shinfo->destructor, not mix the two.

Thinking again about this, we also might avoid taking references on
pages and releasing references too.

shinfo->destructor should replace the skb_release_data() logic,
not complement it.

if (shinfo->destructor) {
	shinfo->destructor(skb);
} else {
	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++)
		put_page(skb_shinfo(skb)->frags[i].page);
	if (skb_has_frag_list(skb))
	....
	kfree(skb->head);
}


As long as the mmap zone is correctly protected in af_packet code, of
course (not releasing it as long as some packets are still in flight)



