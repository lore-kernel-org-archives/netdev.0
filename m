From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Phonet: hold GPRS device while cleaning up
Date: Mon, 08 Dec 2008 02:21:53 -0800 (PST)
Message-ID: <20081208.022153.93642210.davem@davemloft.net>
References: <1228730965-19087-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35247
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750933AbYLHKVw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2008 05:21:52 -0500
In-Reply-To: <1228730965-19087-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Mon,  8 Dec 2008 12:09:25 +0200

This is just a side-comment about the phonet stack, not directly
related to this patch.

> diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
> index 9978afb..9602bfc 100644
> --- a/net/phonet/pep-gprs.c
> +++ b/net/phonet/pep-gprs.c
> @@ -340,8 +340,10 @@ void gprs_detach(struct sock *sk)
>  	release_sock(sk);
> =20
>  	printk(KERN_DEBUG"%s: detached\n", net->name);
> +	dev_hold(net); /* TX work still needs it */
>  	unregister_netdev(net);
>  	flush_scheduled_work();
> +	dev_put(net);
>  	sock_put(sk);
>  	skb_queue_purge(&dev->tx_queue);
>  }

Can we get the phonet stack using more sensible local
variable names for netdev pointers?

We have network namespace objects, and everything says
"net" as the variable name to hold pointers to such
objects.

Using the same local variable name for "struct netdev"
pointers breeds confusion and makes phonet patches and
code difficult to read for people familiar with the
rest of the Linux networking.

Since you use "dev", which is the typical way to name
netdev pointers in networking code, for the phonet et al.
private stuff, one thing you can do is adopt the technique
I usually use:

1) Driver/subsystem private objects get a two letter local
   variable name, the second letter is 'p' for pointer.
   So a TG3 driver private pointer variable is "tp".  You'll
   see this in pretty much every single driver I ever wrote.

2) struct netdev pointer variables are "dev"

3) Network namespace pointer variables are "net"

With this we'll achieve consistency and much easier to read
and validate patches.

Just a suggestion :)
