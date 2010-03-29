From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH v2 10/12] l2tp: Add L2TP ethernet pseudowire support
Date: Mon, 29 Mar 2010 13:10:03 +0100
Message-ID: <4BB0989B.1040504@katalix.com>
References: <20100329095639.30460.30496.stgit@bert.katalix.com>	 <20100329095731.30460.19852.stgit@bert.katalix.com> <1269860710.2164.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:37165 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751976Ab0C2MKR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Mar 2010 08:10:17 -0400
In-Reply-To: <1269860710.2164.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le lundi 29 mars 2010 =E0 10:57 +0100, James Chapman a =E9crit :
>=20
>> +static struct l2tp_session *l2tp_eth_session_find_by_ifname(struct =
net *net, char *ifname)
>> +{
>> +	struct net_device *dev;
>> +
>> +	dev =3D dev_get_by_name(net, ifname);
>> +	if (dev) {
>> +		struct l2tp_eth *priv =3D netdev_priv(dev);
>> +		return priv->session;
>> +	}
>> +
>> +	return NULL;
>> +}
>> +
>=20
> Not clear to me if  caller of l2tp_eth_session_find_by_ifname()
> is able to do dev_put(dev);
>=20
> l2tp_eth_create() ->

Good catch. If a device name were specified by the caller when creating
the new session (usually the default name is used), a dev_put() is
needed, since the dev_get_by_name() call is only used to test if a
device with that name already exists. I'll roll a fix into the next
patch version.

>> +static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 sess=
ion_id, u32 peer_session_id, struct l2tp_session_cfg *cfg)
>> +{
>> +	struct net_device *dev;
>> +	char name[IFNAMSIZ];
>> +	struct l2tp_tunnel *tunnel;
>> +	struct l2tp_session *session;
>> +	struct l2tp_eth *priv;
>> +	struct l2tp_eth_sess *spriv;
>> +	int rc;
>> +	struct l2tp_eth_net *pn;
>> +
>> +	tunnel =3D l2tp_tunnel_find(net, tunnel_id);
>> +	if (!tunnel) {
>> +		rc =3D -ENODEV;
>> +		goto out;
>> +	}
>> +
>> +	session =3D l2tp_session_find(net, tunnel, session_id);
>> +	if (session) {
>> +		rc =3D -EEXIST;
>> +		goto out;
>> +	}
>> +
>> +	if (cfg->ifname) {
>> +		session =3D l2tp_eth_session_find_by_ifname(net, cfg->ifname);
>> +		if (session) {
>> +			rc =3D -EEXIST;
>> +			goto out;
>> +		}
>> +		strlcpy(name, cfg->ifname, IFNAMSIZ);
>> +	} else
>> +		strcpy(name, L2TP_ETH_DEV_NAME);
>> +
>> +	session =3D l2tp_session_create(sizeof(*spriv), tunnel, session_id=
,
>> +				      peer_session_id, cfg);
>> +	if (!session) {
>> +		rc =3D -ENOMEM;
>> +		goto out;
>> +	}
>> +
>> +	dev =3D alloc_netdev(sizeof(*priv), name, l2tp_eth_dev_setup);
>> +	if (!dev) {
>> +		rc =3D -ENOMEM;
>> +		goto out_del_session;
>> +	}
>> +
>> +	dev_net_set(dev, net);
>> +	if (session->mtu =3D=3D 0)
>> +		session->mtu =3D dev->mtu - session->hdr_len;
>> +	dev->mtu =3D session->mtu;
>> +	dev->needed_headroom +=3D session->hdr_len;
>> +
>> +	priv =3D netdev_priv(dev);
>> +	priv->dev =3D dev;
>> +	priv->session =3D session;
>> +	INIT_LIST_HEAD(&priv->list);
>> +
>> +	priv->tunnel_sock =3D tunnel->sock;
>> +	session->recv_skb =3D l2tp_eth_dev_recv;
>> +	session->session_close =3D l2tp_eth_delete;
>> +#ifdef CONFIG_PROC_FS
>> +	session->show =3D l2tp_eth_show;
>> +#endif
>> +
>> +	spriv =3D l2tp_session_priv(session);
>> +	spriv->dev =3D dev;
>> +
>> +	rc =3D register_netdev(dev);
>> +	if (rc < 0)
>> +		goto out_del_dev;
>> +
>> +	/* Must be done after register_netdev() */
>> +	strlcpy(session->ifname, dev->name, IFNAMSIZ);
>> +
>> +	dev_hold(dev);
>> +	pn =3D l2tp_eth_pernet(dev_net(dev));
>> +	write_lock(&pn->l2tp_eth_lock);
>> +	list_add(&priv->list, &pn->l2tp_eth_dev_list);
>> +	write_unlock(&pn->l2tp_eth_lock);
>> +
>> +	return 0;
>> +
>> +out_del_dev:
>> +	free_netdev(dev);
>> +out_del_session:
>> +	l2tp_session_delete(session);
>=20
> 	I cant see the dev_put() here
>=20
>=20
>> +out:
>> +	return rc;
>> +}
>=20
>=20
>=20


--=20
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

