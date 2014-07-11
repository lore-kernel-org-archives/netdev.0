From: Arvid Brodin <arvid.brodin@alten.se>
Subject: Re: [PATCH net-next 00/10] net/hsr: Use list_head+rcu, better frame
 dispatch, etc.
Date: Fri, 11 Jul 2014 17:45:28 +0200
Message-ID: <53C00698.4000901@alten.se>
References: <53B71DB8.1040505@alten.se> <20140708.114548.1274719854380242049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:49961 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750823AbaGKPux (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2014 11:50:53 -0400
In-Reply-To: <20140708.114548.1274719854380242049.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-07-08 20:45, David Miller wrote:
>=20
> Just one question:
>=20
> @@ -575,6 +579,13 @@ int hsr_dev_finalize(struct net_device *hsr_dev,=
 struct net_device *slave[2],
>  		}
>  	}
> =20
> +	for (i =3D 0; i < HSR_MAX_SLAVE; i++) {
> +		res =3D netdev_rx_handler_register(slave[i], hsr_handle_frame,
> +						 hsr);
> +		if (res)
> +			goto fail;
> +	}
> +
>  	/* Make sure we recognize frames from ourselves in hsr_rcv() */
>  	res =3D hsr_create_self_node(&hsr->self_node_db, hsr_dev->dev_addr,
>  				   hsr->slave[1]->dev_addr);
>=20
> If one of the slaves fails to register it's RX handler here, what unr=
egisters
> the slaves which already succeeded?

This looks like it's from "[PATCH net-next 02/10] net/hsr: Switch from =
dev_add_pack() to=20
netdev_rx_handler_register()". If so, the code under the fail: label ca=
lls restore_slaves(),=20
which in turn iterates over the slaves. From the same patch:=20

@@ -402,8 +402,12 @@ static void restore_slaves(struct net_device *hsr_=
dev)
 			netdev_info(hsr_dev,
 				    "Cannot restore slave promiscuity (%s, %d)\n",
 				    hsr->slave[i]->name, res);
+
+		if (hsr->slave[i]->rx_handler =3D=3D hsr_handle_frame)
+			netdev_rx_handler_unregister(hsr->slave[i]);
 	}
=20
+
 	rtnl_unlock();
 }
=20

--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
