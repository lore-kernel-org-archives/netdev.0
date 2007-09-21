From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Fri, 21 Sep 2007 14:47:49 +0200
Message-ID: <46F3BD75.6010904@trash.net>
References: <20070920184323.3795.0@janus.isnogud.escape.de> <20070920184532.3795.2@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63702 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbXIUMzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 08:55:39 -0400
In-Reply-To: <20070920184532.3795.2@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> +static int can_create(struct net *net, struct socket *sock, int protocol)
> +{
> +	...
> +
> +	spin_lock(&proto_tab_lock);
> +	cp = proto_tab[protocol];
> +	if (cp && !try_module_get(cp->prot->owner))
> +		cp = NULL;
> +	spin_unlock(&proto_tab_lock);
> +
> +	/* check for success and correct type */
> +	if (!cp || cp->type != sock->type) {
> +		ret = -EPROTONOSUPPORT;
> +		goto errout;
> +	}
> +
> +	if (cp->capability >= 0 && !capable(cp->capability)) {
> +		ret = -EPERM;
> +		goto errout;
> +	}
> +
> +	sock->ops = cp->ops;


You drop the module reference again when leaving this function.
So sock->ops might contain a stale pointer if the module is
unloaded after this. You need to either keep the module reference
while the socket is alive or remove stale references when
unregistering the protocol.

