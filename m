From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 09/39] wimax: provides user space with information
	needed when opening a WiMAX device
Date: Thu, 27 Nov 2008 10:53:09 +0100
Message-ID: <1227779589.3809.41.camel@johannes.berg>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <61e0e60ace9f0c441b51e5009d304229c4b234d3.1227691434.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-DrqaXZb//6bPK0tL6S3k"
Cc: netdev <netdev@vger.kernel.org>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:58071 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751939AbYK0JyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 04:54:11 -0500
In-Reply-To: <61e0e60ace9f0c441b51e5009d304229c4b234d3.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-DrqaXZb//6bPK0tL6S3k
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-11-26 at 15:07 -0800, Inaky Perez-Gonzalez wrote:
> When user space wants to open a handle to a WiMAX device, it needs
> information that is provided as a response to an "open" generic
> netlink message.

Why is this called "open" when it's not actually any opening that would
be bracketed with "close"? It seems more like "get info" to me?

> +	result =3D -ENOMEM;
> +	reply_skb =3D nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> +	if (reply_skb =3D=3D NULL)
> +		goto error_new;
> +	data =3D genlmsg_put_reply(reply_skb, genl_info,
> +				 &wimax_dev->gnl_family,
> +				 0, WIMAX_GNL_RP_IFINFO);
> +	if (data =3D=3D NULL)
> +		goto error_put_reply;
> +
> +	nla_groups =3D nla_nest_start(reply_skb, WIMAX_GNL_IFINFO_MC_GROUPS);
> +	if (nla_groups =3D=3D NULL)
> +		goto error_groups_start;
> +
> +	list_for_each_entry(pipe_itr, &wimax_dev->pipe_list,
> +			    list_node) {
> +		nla_group =3D nla_nest_start(reply_skb,
> +					   WIMAX_GNL_IFINFO_MC_GROUP);
> +		if (nla_group =3D=3D NULL)
> +			goto error_group_start;
> +
> +		nla_put_u16(reply_skb, WIMAX_GNL_IFINFO_MC_ID,
> +			    pipe_itr->mcg.id);
> +		nla_put_string(reply_skb, WIMAX_GNL_IFINFO_MC_NAME,
> +			       pipe_itr->mcg.name);

All this is discoverable via the genl controller and a pipe naming
scheme, so I don't think you need this "open" command at all.

> +		nla_nest_end(reply_skb, nla_group);
> +	}
> +	nla_nest_end(reply_skb, nla_groups);
> +	genlmsg_end(reply_skb, data);
> +
> +	result =3D genlmsg_reply(reply_skb, genl_info);
> +	if (result < 0)
> +		goto error_reply;
> +	return 0;
> +
> +error_group_start:
> +error_groups_start:
> +error_reply:
> +error_put_reply:
> +	nlmsg_free(reply_skb);
> +error_new:
> +	return result;
> +}
> +
> +
> +static
> +int wimax_gnl_doit_open(struct sk_buff *skb, struct genl_info *info)
> +{
> +	int result;
> +	struct wimax_dev *wimax_dev;
> +
> +	d_fnstart(3, NULL, "(skb %p info %p)\n", skb, info);
> +	result =3D -EPERM;
> +	if (security_netlink_recv(skb, CAP_NET_ADMIN))
> +		goto error_perm;

Ehm, you can do that check by adding the flag below...

> +	result =3D -ENODEV;
> +	wimax_dev =3D wimax_dev_get_by_genl_info(info);
> +	if (wimax_dev =3D=3D NULL)
> +		goto error_no_wimax_dev;
> +	mutex_lock(&wimax_dev->mutex);
> +	result =3D wimax_dev_is_ready(wimax_dev);
> +	if (result < 0)
> +		goto error_not_ready;
> +	result =3D __wimax_gnl_open_reply(wimax_dev, info);
> +error_not_ready:
> +	mutex_unlock(&wimax_dev->mutex);
> +	dev_put(wimax_dev->net_dev);
> +error_no_wimax_dev:
> +error_perm:
> +	d_fnend(3, NULL, "(skb %p info %p) =3D %d\n", skb, info, result);
> +	return result;
> +}
> +
> +
> +struct genl_ops wimax_gnl_open =3D {
> +	.cmd =3D WIMAX_GNL_OP_OPEN,
> +	.flags =3D 0,

GENL_ADMIN_PERM and remove the checks above?


--=-DrqaXZb//6bPK0tL6S3k
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJLm3/AAoJEKVg1VMiehFYOzkQAKw2cx9MHhTX8SfRu6u4rLdJ
T5F3x12RAgRpQDd+Mcp7bDeg8xxJ2jxTQy20w5MDJCZY5eB4H63uG7XAp8W6s8ZZ
5TPCu7f1xh842BmwA6MAZYkgWXjcur95c7QcbXBz4Pwq37YWphciTI4SR9rhecQZ
JysRaOEYs9E0xxvurKW6vxxXt2ZyB18e6KBI46M0aV730Ny3Ywr9LSGoVtiprWhx
6BAgFbUdy5JwAbz+rTGDQLAWlNN+Ikn8rXCqcgnNH9KZTnOZqfaiWVCLIcbGeTSi
f/4Iqd5euSB1YVF2wlwVioLwitJoNoIf9HnE1+bkhBiEDI4eBeiPd/Z1aY+8spKo
BFX/ErX+mSXR+4fv99k4qpyKLQCz4OcQJvF0OIxAy+DZQyFrZeDQY9ItdRRkExHe
JTW3mOP+evG6WbszNrUVIsRUB3fMZK70K7OVudoUuUpSnkJHspR7mFikLb8PIY6Z
MLGsAGX5kPKoRSMlV+N2diZttmEimVWyTPkEMkQUoZnxkw9S//HyjasDVvXO+Qdn
dk3ZQI19SlNVAd2G0rtn/0vkrjYPprVkzE06MDe40Rwr7lUnPBzq0utTzZcT9jOa
V0XX5SplP6bMd8VK452QxFbDPrW6cx1qQkI54Qt5ym1UcpYgAepz2uimGG3C8yzm
RYHRr+y3ZlqUxv3vz7N2
=kh1p
-----END PGP SIGNATURE-----

--=-DrqaXZb//6bPK0tL6S3k--

