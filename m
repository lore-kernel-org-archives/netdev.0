From: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>
Subject: Re: [PATCH] phonet netlink: allow multiple messages per skb in route dump
Date: Mon, 19 Jan 2015 22:11:50 +0200
Message-ID: <45863435.BJJN05sX3K@philogene>
References: <1421666124-16055-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Sakari Ailus <sakari.ailus@nokia.com>,
	Remi Denis-Courmont <courmisch@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns207790.ip-94-23-215.eu ([94.23.215.26]:57759 "EHLO
	ns207790.ip-94-23-215.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbbASUTI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 15:19:08 -0500
In-Reply-To: <1421666124-16055-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 janvier 2015, 12:15:24 Johannes Berg a =E9crit :
> From: Johannes Berg <johannes.berg@intel.com>
>=20
> My previous patch to this file changed the code to be bug-compatible
> towards userspace. Unless userspace (which I wasn't able to find)
> implements the dump reader by hand in a wrong way, this isn't needed.

The canonical userspace is there (specifically src/pnroute.c):
https://gitorious.org/meego-cellular/phonet-utils/

AFAICT, it should work either way. By now, I expect what's left of the=20
Maemo/Meego/Mer/whatever community has forked or rewritten it though.

> If it uses libnl or similar code putting multiple messages into a
> single SKB is far more efficient.
>=20
> Change the code to do this. While at it, also clean it up and don't
> use so many variables - just store the address in the callback args
> directly.
>=20
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> ---
>  net/phonet/pn_netlink.c | 22 +++++++---------------
>  1 file changed, 7 insertions(+), 15 deletions(-)
>=20
> diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
> index 54d766842c2b..bc5ee5fbe6ae 100644
> --- a/net/phonet/pn_netlink.c
> +++ b/net/phonet/pn_netlink.c
> @@ -272,31 +272,23 @@ static int route_doit(struct sk_buff *skb, stru=
ct
> nlmsghdr *nlh) static int route_dumpit(struct sk_buff *skb, struct
> netlink_callback *cb) {
>  	struct net *net =3D sock_net(skb->sk);
> -	u8 addr, addr_idx =3D 0, addr_start_idx =3D cb->args[0];
> +	u8 addr;
>=20
>  	rcu_read_lock();
> -	for (addr =3D 0; addr < 64; addr++) {
> -		struct net_device *dev;
> +	for (addr =3D cb->args[0]; addr < 64; addr++) {
> +		struct net_device *dev =3D phonet_route_get_rcu(net, addr << 2);
>=20
> -		dev =3D phonet_route_get_rcu(net, addr << 2);
>  		if (!dev)
>  			continue;
>=20
> -		if (addr_idx++ < addr_start_idx)
> -			continue;
> -		fill_route(skb, dev, addr << 2, NETLINK_CB(cb->skb).portid,
> -			   cb->nlh->nlmsg_seq, RTM_NEWROUTE);
> -		/* fill_route() used to return > 0 (or negative errors) but
> -		 * never 0 - ignore the return value and just go out to
> -		 * call dumpit again from outside to preserve the behavior
> -		 */
> -		goto out;
> +		if (fill_route(skb, dev, addr << 2, NETLINK_CB(cb->skb).portid,
> +			       cb->nlh->nlmsg_seq, RTM_NEWROUTE) < 0)
> +			goto out;
>  	}
>=20
>  out:
>  	rcu_read_unlock();
> -	cb->args[0] =3D addr_idx;
> -	cb->args[1] =3D 0;
> +	cb->args[0] =3D addr;
>=20
>  	return skb->len;
>  }

--=20
R=E9mi
