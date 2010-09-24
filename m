From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/5] AF_UNIX: find peers on multicast Unix stream
 sockets
Date: Fri, 24 Sep 2010 20:00:37 +0200
Message-ID: <1285351237.2478.7.camel@edumazet-laptop>
References: <20100924182257.11abd9a6@chocolatine.cbg.collabora.co.uk>
	 <1285349116-17529-4-git-send-email-alban.crequy@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Ian Molton <ian.molton@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dbus@freedesktop.org
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39805 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757168Ab0IXSAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 14:00:45 -0400
In-Reply-To: <1285349116-17529-4-git-send-email-alban.crequy@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 24 septembre 2010 =C3=A0 18:25 +0100, Alban Crequy a =C3=A9=
crit :

> @@ -1612,7 +1671,12 @@ static int unix_stream_sendmsg(struct kiocb *k=
iocb, struct socket *sock,
>  	} else {
>  		sunaddr =3D NULL;
>  		err =3D -ENOTCONN;
> -		other =3D NULL; /* FIXME: get the list of other connection */
> +		max_others =3D atomic_read(&unix_nr_multicast_socks);
> +		others =3D kzalloc((max_others + 1) * sizeof(void *), GFP_KERNEL);
> +		unix_find_other(sock_net(sk), u->addr->name,
> +		    u->addr->len, 0, u->addr->hash, 1, others, max_others, &err);
> +		other =3D others[0];
> +		kfree(others);
>  		if (!other)
>  			goto out_err;
>  	}

Seriously, this block sizing against unix_nr_multicast_socks is not
scalable. What happens if we have 1000 sockets ?
kzalloc() to clear 8000 bytes ?
Its also unsafe.

(say you kzalloc() a buffer for 2 sockets, and another cpu inserts a ne=
w
socket. unix_find_socket_byname() can overflow the buffer)


You should use a list, and allocates elements in
unix_find_socket_byname()

struct item {
	struct item *next;
	struct sock *s;
};


