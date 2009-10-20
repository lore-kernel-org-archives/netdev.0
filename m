From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Fix IP_MULTICAST_IF
Date: Tue, 20 Oct 2009 06:07:48 +0200
Message-ID: <4ADD3794.8030906@gmail.com>
References: <4ADC96D6.4000909@gmail.com> <20091019.205948.193706797.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43838 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781AbZJTEHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 00:07:46 -0400
In-Reply-To: <20091019.205948.193706797.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 19 Oct 2009 18:41:58 +0200
>=20
>> ipv4/ipv6 setsockopt(IP_MULTICAST_IF) have dubious __dev_get_by_inde=
x() calls.
>=20
> Dubious, how so?
>=20
> Yes, I know RTNL/dev_base_lock, but it's not using what it gets
> back at all.
>=20
> It's testing existence, a boolean, it doesn't dereference the
> 'dev' it gets back at all.
>=20
> This code is intentional and perfectly fine.

If this was intentional, something changed and made the prereq false.

=46inal target might be fine, but an element in the chain, before targe=
t
could be deleted while reader scans hash chain.

/* Device list removal */
static void unlist_netdevice(struct net_device *dev)
{
        ASSERT_RTNL();

        /* Unlink dev from the device chain */
        write_lock_bh(&dev_base_lock);
        list_del(&dev->dev_list);
        hlist_del(&dev->name_hlist);
        hlist_del(&dev->index_hlist);   <<< HERE >>>
        write_unlock_bh(&dev_base_lock);
}


static inline void hlist_del(struct hlist_node *n)
{
        __hlist_del(n);
        n->next =3D LIST_POISON1;   <<< HERE >>>
        n->pprev =3D LIST_POISON2;
}
include/linux/poison.h:#define LIST_POISON1  ((void *) 0x00100100)

reader tries to pass over this delete net_device, doing a dev->index_hl=
ist->next

#define hlist_for_each(pos, head) \
        for (pos =3D (head)->first; pos && ({ prefetch(pos->next); 1; }=
); \
             pos =3D pos->next)

So it should visit a nice memory location ?

