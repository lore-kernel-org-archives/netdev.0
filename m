From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net_device leak after "bridge: allow creating bridge devices
 with netlink"?
Date: Mon, 22 Aug 2011 14:50:01 +0200
Message-ID: <1314017401.2307.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E525ADA020000780005278A@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, davem@davemloft.net, netdev@vger.kernel.org
To: Jan Beulich <JBeulich@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54001 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674Ab1HVMt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 08:49:59 -0400
Received: by wwf5 with SMTP id 5so5174164wwf.1
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2011 05:49:58 -0700 (PDT)
In-Reply-To: <4E525ADA020000780005278A@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 22 ao=C3=BBt 2011 =C3=A0 12:34 +0100, Jan Beulich a =C3=A9crit=
 :
> Stephen,
>=20
> directly returning the result of register_netdev() from br_add_bridge=
()
> would - to me - appear to be leaking "dev" in case of failure. Or am =
I
> overlooking some implicit mechanism by which this would get freed?
>=20
> Thanks, Jan

You're 100 % right, there is a leak here.

(But "ip" or "brctl" commands first check link already exist before
trying create it, so you need to tweak them to actually hit this bug)

We have to add a free_netdev() call to free the net_device.



diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 2cdf007..e738154 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -231,6 +231,7 @@ static struct net_bridge_port *new_nbp(struct net_b=
ridge *br,
 int br_add_bridge(struct net *net, const char *name)
 {
 	struct net_device *dev;
+	int res;
=20
 	dev =3D alloc_netdev(sizeof(struct net_bridge), name,
 			   br_dev_setup);
@@ -240,7 +241,10 @@ int br_add_bridge(struct net *net, const char *nam=
e)
=20
 	dev_net_set(dev, net);
=20
-	return register_netdev(dev);
+	res =3D register_netdev(dev);
+	if (res)
+		free_netdev(dev);
+	return res;
 }
=20
 int br_del_bridge(struct net *net, const char *name)


