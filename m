From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: net_device leak after "bridge: allow creating bridge devices
 with netlink"?
Date: Mon, 22 Aug 2011 08:55:32 -0700
Message-ID: <20110822085532.2ff4479c@nehalam.ftrdhcpuser.net>
References: <4E525ADA020000780005278A@nat28.tlf.novell.com>
	<1314017401.2307.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Beulich <JBeulich@novell.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40338 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751254Ab1HVPzV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 11:55:21 -0400
In-Reply-To: <1314017401.2307.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Aug 2011 14:50:01 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le lundi 22 ao=FBt 2011 =E0 12:34 +0100, Jan Beulich a =E9crit :
> > Stephen,
> >=20
> > directly returning the result of register_netdev() from br_add_brid=
ge()
> > would - to me - appear to be leaking "dev" in case of failure. Or a=
m I
> > overlooking some implicit mechanism by which this would get freed?
> >=20
> > Thanks, Jan
>=20
> You're 100 % right, there is a leak here.
>=20
> (But "ip" or "brctl" commands first check link already exist before
> trying create it, so you need to tweak them to actually hit this bug)
>=20
> We have to add a free_netdev() call to free the net_device.
>=20
>=20
>=20
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index 2cdf007..e738154 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -231,6 +231,7 @@ static struct net_bridge_port *new_nbp(struct net=
_bridge *br,
>  int br_add_bridge(struct net *net, const char *name)
>  {
>  	struct net_device *dev;
> +	int res;
> =20
>  	dev =3D alloc_netdev(sizeof(struct net_bridge), name,
>  			   br_dev_setup);
> @@ -240,7 +241,10 @@ int br_add_bridge(struct net *net, const char *n=
ame)
> =20
>  	dev_net_set(dev, net);
> =20
> -	return register_netdev(dev);
> +	res =3D register_netdev(dev);
> +	if (res)
> +		free_netdev(dev);
> +	return res;
>  }
> =20
>  int br_del_bridge(struct net *net, const char *name)

Missing Signed-off-by:?

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
