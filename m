From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netlink stats: Ability to get stats for a single device?
Date: Tue, 26 Oct 2010 22:37:12 +0200
Message-ID: <1288125432.2652.39.camel@edumazet-laptop>
References: <4CC72C80.9010802@candelatech.com>
	 <20101026.123811.13746869.davem@davemloft.net>
	 <1288122986.2652.20.camel@edumazet-laptop>
	 <4CC73A1E.5050605@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52352 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752798Ab0JZUhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 16:37:17 -0400
Received: by wyf28 with SMTP id 28so5086037wyf.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 13:37:16 -0700 (PDT)
In-Reply-To: <4CC73A1E.5050605@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 octobre 2010 =C3=A0 13:29 -0700, Ben Greear a =C3=A9crit :

> I'm trying to craft my own netlink message...basically:
>=20
>     memset(&snl, 0, sizeof(snl));
>     snl.nl_family =3D AF_NETLINK;
>     snl.nl_pid    =3D 0;
>     snl.nl_groups =3D 0;
>=20
>     memset(&buffer, 0, sizeof(buffer));
>     nlh->nlmsg_type =3D msg_type;
>     nlh->nlmsg_flags =3D NLM_F_MATCH|NLM_F_REQUEST;

dont use F_MATCH : check net/core/rtnetlink.c

vi +1660 net/core/rtnetlink.c

You _dont_ want to call 'dumpit' : so dont use a bit present in
NLM_F_DUMP at all:

        if (kind =3D=3D 2 && nlh->nlmsg_flags&NLM_F_DUMP) {
                struct sock *rtnl;
                rtnl_dumpit_func dumpit;

                dumpit =3D rtnl_get_dumpit(family, type);
                if (dumpit =3D=3D NULL)
                        return -EOPNOTSUPP;

                __rtnl_unlock();
                rtnl =3D net->rtnl;
                err =3D netlink_dump_start(rtnl, skb, nlh, dumpit, NULL=
);
                rtnl_lock();
                return err;
        }

You want instead to call the 'doit' handler  (one device only)

        doit =3D rtnl_get_doit(family, type);
        if (doit =3D=3D NULL)
                return -EOPNOTSUPP;

        return doit(skb, nlh, (void *)&rta_buf[0]);



