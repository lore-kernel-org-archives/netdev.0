From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] genetlink: make netns aware
Date: Fri, 19 Jun 2009 03:12:10 +0200
Message-ID: <1245373930.16399.4.camel@johannes.local>
References: <1245323806.13790.1.camel@johannes.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-12+pl/DoTVN6R+TKY3Vl"
Cc: Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:50341 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbZFSBMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 21:12:37 -0400
In-Reply-To: <1245323806.13790.1.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-12+pl/DoTVN6R+TKY3Vl
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-06-18 at 13:17 +0200, Johannes Berg wrote:
> This makes generic netlink network namespace aware.

Please drop this patch, it has a deadlock bug.

> +int genlmsg_multicast(struct sk_buff *skb, u32 pid,
> +		      unsigned int group, gfp_t flags)
> +{
> +	int ret;
> +
> +	if (flags & GFP_ATOMIC) {
> +		rcu_read_lock();
> +		ret =3D genlmsg_mcast(skb, pid, group, flags);
> +		rcu_read_unlock();
> +	} else {
> +		rtnl_lock();
> +		ret =3D genlmsg_mcast(skb, pid, group, flags);
> +		rtnl_unlock();
> +	}
> +
> +	return ret;
> +}

It used to be possible to call genlmsg_multicast() under rtnl, which
will now obviously deadlock unless you also make it GFP_ATOMIC... I'm
inclined to always use RCU here to solve that, comments?

johannes

--=-12+pl/DoTVN6R+TKY3Vl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKOuXlAAoJEODzc/N7+QmaPooQAKNLS4wood46GU0qBaz4i1Zo
/v8p9+ho1u6ot0imssm0hQSf7e9BHpoOY15LAdLvDgoWEGuhJaSL8BDm+SqVEoed
DvYu1G2qq3I89oDuiXtOxQkxyDutXul4sZK6ABke8uEzmfZ6HgnfUMhzMYuVxYHN
dSN9rBS+eBWMp2TUEAqj4K8u+Eq3VzWjP2EXIdRfYiXhySqxkvMs92lbWJ0Iqms5
n8BqC5qi8fL0J4WncpWerW745hpCzxpRBk5zKjEE+V6Hwm3BMYHDXbwn6YcdAGOn
f82wTxl21VP0OeHZMN4sjwLZMJnZjqYD7K5n49jv3LXV78yfCnJFFVesPmLMetMU
fJcMMgKD9QHMRnY+DXCCKP0mgg0aw90teV1Gw+sWPIz/BqnNike8aayUpZFMljjZ
wcKql2TORdt4ZBzV+YtVtINHBUWGsOYcP05SglRf9pub4qoa7OT5tqBQq8tJitOc
G5nGvCX1V+oYEW1ueGioN23jqVlo6AB6ahPSO6gBtxvvIHLhAWshvZ4eUdYN25jV
lqJUz0SCN2rQ7TVSBwmB9nWMnt8gbAo8lCEQWbCkhN9l9sZfLX35nBaU3MRlMTp0
//wt8PZgKMfi4KgX/PzFM1721LhkcDvHMqo3dTtGXy/quxa8revd5pwiomVw+UTD
r8ZC9JGAp7NOlAhNWTEo
=YkZI
-----END PGP SIGNATURE-----

--=-12+pl/DoTVN6R+TKY3Vl--

