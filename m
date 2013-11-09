From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH net-next 2/2] udp: add sk opt to allow sending pkt
 with src 0.0.0.0
Date: Sat, 9 Nov 2013 16:46:29 +0200 (EET)
Message-ID: <alpine.LFD.2.03.1311091610090.1411@ssi.bg>
References: <20131105205744.GK8832@order.stressinduktion.org> <1383958474-6255-1-git-send-email-nicolas.dichtel@6wind.com> <1383958474-6255-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	davem@davemloft.net, David.Laight@ACULAB.COM, jiri@resnulli.us,
	vyasevich@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:35320 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752592Ab3KIOt0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Nov 2013 09:49:26 -0500
In-Reply-To: <1383958474-6255-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sat, 9 Nov 2013, Nicolas Dichtel wrote:

> This feature allows to a send packets with address source set to 0.0.0.0 even if
> an ip address is available on another interface.
> 
> It's useful for DHCP client, to allow them to use UDP sockets and be compliant
> with the RFC2131, Section 4.1:
> 
> 4.1 Constructing and sending DHCP messages
> ...
>    DHCP messages broadcast by a client prior to that client obtaining
>    its IP address must have the source address field in the IP header
>    set to 0.
> 
> Based on a previous work from
> Guillaume Gaudonville <guillaume.gaudonville@6wind.com>.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

...

> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 89909dd730dd..f58945187dbd 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c

...

> +	if (up->src_any && sk->sk_bound_dev_if) {
> +		struct net_device *dev;
> +		struct in_device *in_dev;
> +
> +		rcu_read_lock();
> +		dev = dev_get_by_index_rcu(sock_net(sk), sk->sk_bound_dev_if);
> +		in_dev = dev ? __in_dev_get_rcu(dev) : NULL;
> +		if (!inet_confirm_addr(sock_net(sk), in_dev, 0, 0,
> +				       RT_SCOPE_HOST))

	I don't have an opinion about UDP_SRC_ANY, just some
comments...

	Can a simple !in_dev->ifa_list check replace the
!inet_confirm_addr call? Looking at __inet_insert_ifa()
it seems only 0.0.0.0 does not add an ifa. Long ago
adding 0.0.0.0 was a way to create in_dev for dev but
now in_dev is created on device registration, i.e. even
before addresses are added.

	For the first patch, may be it is not needed.
We have two choices:

1. Do not change args and just fix comments. Of course,
it is tricky to use this function by using scope instead
of in_dev as a key for device-specific matching because
such interface is confusing.

2. Add 'net' arg and use in_dev as explained in my
previous email. Not sure if changing args of exported
function is acceptable.

Regards

--
Julian Anastasov <ja@ssi.bg>
