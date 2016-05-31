From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [net v4] veth: advertise peer link once both links are tied together
Date: Tue, 31 May 2016 08:54:56 +0200
Message-ID: <m3bn3mg1j3.fsf@neo.luffy.cx>
References: <574C69DE.3050305@6wind.com>
	<1464676221-4873-1-git-send-email-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:44954 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751283AbcEaGy7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 02:54:59 -0400
In-Reply-To: <1464676221-4873-1-git-send-email-vincent@bernat.im> (Vincent
	Bernat's message of "Tue, 31 May 2016 08:30:21 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 31 mai 2016 08:30 CEST, Vincent Bernat <vincent@bernat.im>=C2=
=A0:

> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index f37a6e61d4ad..aaa1b023b9f2 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -466,6 +466,8 @@ static int veth_newlink(struct net *src_net, stru=
ct net_device *dev,
> =20
>  	priv =3D netdev_priv(peer);
>  	rcu_assign_pointer(priv->peer, dev);
> +
> +	rtmsg_ifinfo(RTM_NEWLINK, peer, ~0U, GFP_KERNEL);
>  	return 0;

Well, this is wrong here too because the NEWLINK message for dev was no=
t
issued either (link state is not initialized), so we are back to square
one.

     3: veth0@NONE: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOW=
N group default
         link/ether fa:ba:12:26:99:00 brd ff:ff:ff:ff:ff:ff
     3: veth0@veth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DO=
WN group default
         link/ether fa:ba:12:26:99:00 brd ff:ff:ff:ff:ff:ff
     4: veth1@veth0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop s=
tate DOWN group default
         link/ether ea:e4:e2:26:3c:87 brd ff:ff:ff:ff:ff:ff

The netlink message for veth1 is sent by rtnl_newlink() after invocatio=
n
of veth_newlink(). So, I don't see any easy way to fix that. Maybe not
worth it.
--=20
Let the data structure the program.
            - The Elements of Programming Style (Kernighan & Plauger)
