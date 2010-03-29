From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 10/12] l2tp: Add L2TP ethernet pseudowire support
Date: Mon, 29 Mar 2010 13:05:10 +0200
Message-ID: <1269860710.2164.19.camel@edumazet-laptop>
References: <20100329095639.30460.30496.stgit@bert.katalix.com>
	 <20100329095731.30460.19852.stgit@bert.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:63518 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755283Ab0C2LFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 07:05:14 -0400
Received: by bwz1 with SMTP id 1so3449366bwz.21
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 04:05:13 -0700 (PDT)
In-Reply-To: <20100329095731.30460.19852.stgit@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 29 mars 2010 =C3=A0 10:57 +0100, James Chapman a =C3=A9crit :

> +static struct l2tp_session *l2tp_eth_session_find_by_ifname(struct n=
et *net, char *ifname)
> +{
> +	struct net_device *dev;
> +
> +	dev =3D dev_get_by_name(net, ifname);
> +	if (dev) {
> +		struct l2tp_eth *priv =3D netdev_priv(dev);
> +		return priv->session;
> +	}
> +
> +	return NULL;
> +}
> +

Not clear to me if  caller of l2tp_eth_session_find_by_ifname()
is able to do dev_put(dev);

l2tp_eth_create() ->


> +static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 sessi=
on_id, u32 peer_session_id, struct l2tp_session_cfg *cfg)
> +{
> +	struct net_device *dev;
> +	char name[IFNAMSIZ];
> +	struct l2tp_tunnel *tunnel;
> +	struct l2tp_session *session;
> +	struct l2tp_eth *priv;
> +	struct l2tp_eth_sess *spriv;
> +	int rc;
> +	struct l2tp_eth_net *pn;
> +
> +	tunnel =3D l2tp_tunnel_find(net, tunnel_id);
> +	if (!tunnel) {
> +		rc =3D -ENODEV;
> +		goto out;
> +	}
> +
> +	session =3D l2tp_session_find(net, tunnel, session_id);
> +	if (session) {
> +		rc =3D -EEXIST;
> +		goto out;
> +	}
> +
> +	if (cfg->ifname) {
> +		session =3D l2tp_eth_session_find_by_ifname(net, cfg->ifname);
> +		if (session) {
> +			rc =3D -EEXIST;
> +			goto out;
> +		}
> +		strlcpy(name, cfg->ifname, IFNAMSIZ);
> +	} else
> +		strcpy(name, L2TP_ETH_DEV_NAME);
> +
> +	session =3D l2tp_session_create(sizeof(*spriv), tunnel, session_id,
> +				      peer_session_id, cfg);
> +	if (!session) {
> +		rc =3D -ENOMEM;
> +		goto out;
> +	}
> +
> +	dev =3D alloc_netdev(sizeof(*priv), name, l2tp_eth_dev_setup);
> +	if (!dev) {
> +		rc =3D -ENOMEM;
> +		goto out_del_session;
> +	}
> +
> +	dev_net_set(dev, net);
> +	if (session->mtu =3D=3D 0)
> +		session->mtu =3D dev->mtu - session->hdr_len;
> +	dev->mtu =3D session->mtu;
> +	dev->needed_headroom +=3D session->hdr_len;
> +
> +	priv =3D netdev_priv(dev);
> +	priv->dev =3D dev;
> +	priv->session =3D session;
> +	INIT_LIST_HEAD(&priv->list);
> +
> +	priv->tunnel_sock =3D tunnel->sock;
> +	session->recv_skb =3D l2tp_eth_dev_recv;
> +	session->session_close =3D l2tp_eth_delete;
> +#ifdef CONFIG_PROC_FS
> +	session->show =3D l2tp_eth_show;
> +#endif
> +
> +	spriv =3D l2tp_session_priv(session);
> +	spriv->dev =3D dev;
> +
> +	rc =3D register_netdev(dev);
> +	if (rc < 0)
> +		goto out_del_dev;
> +
> +	/* Must be done after register_netdev() */
> +	strlcpy(session->ifname, dev->name, IFNAMSIZ);
> +
> +	dev_hold(dev);
> +	pn =3D l2tp_eth_pernet(dev_net(dev));
> +	write_lock(&pn->l2tp_eth_lock);
> +	list_add(&priv->list, &pn->l2tp_eth_dev_list);
> +	write_unlock(&pn->l2tp_eth_lock);
> +
> +	return 0;
> +
> +out_del_dev:
> +	free_netdev(dev);
> +out_del_session:
> +	l2tp_session_delete(session);

	I cant see the dev_put() here


> +out:
> +	return rc;
> +}


