From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 1/2] ipv4: add forwarding_uses_pmtu knob to protect forward path to use pmtu info
Date: Tue, 31 Dec 2013 19:41:09 +0100
Message-ID: <20131231184109.GB31490@order.stressinduktion.org>
References: <20131220130822.GD32129@order.stressinduktion.org> <20131230.222044.884570280065942449.davem@davemloft.net> <20131231035247.GA27636@order.stressinduktion.org> <20131231.010403.73052460631688921.davem@davemloft.net> <20131231070223.GE27636@order.stressinduktion.org> <CABrhC0kqn2Gpjv=4sseOf_2CmubKjaJaY4C3icsDpUeBsVWDXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60716 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755555Ab3LaSlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 13:41:10 -0500
Content-Disposition: inline
In-Reply-To: <CABrhC0kqn2Gpjv=4sseOf_2CmubKjaJaY4C3icsDpUeBsVWDXg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Tue, Dec 31, 2013 at 12:59:06PM -0500, John Heffner wrote:
> I'm not completely sure I understand the attack.  Perhaps a more
> thorough explanation or concrete example is in order.  I understand
> that it might be possible to spoof ICMP packet-too-big messages to a
> router, but that router would need a socket listening that would
> handle these messages.

No, an open socket is not needed in case of icmp echo reply payloads
on frag_needed notifications. And you really have to be careful about
bound raw sockets to any addresses on such an interface (e.g. some dhcp
clients, or maybe not bound at all to an interface).

> Is this a problem in practice?  Routers in
> critical forwarding paths are usually pretty well hardened, and don't
> have services running on the forwarding path interfaces (or use
> firewall rules to control access to those services).  Are such routers
> vulnerable?  Is there a reason we need to compromise and increase
> complexity of the routing code to handle poorly-configured routers?

Given the whole complexity in forwarding path I don't think that this
change does add a lot more.

The essential part of the attack is, that there is a way to spray the
fragmentation queue with already made-up answers and correctly guessed
fragmentation ids and wait for a user to issue a DNS request whose answer
is gonna to be fragmented on the path (or on the DNS name system, that
is the reason for IP_PMTUDISC_INTERFACE). In the paper they also found
a way to precompute the checksums so that after reassembling the valid
packet with the spoofed one, the whole packet is still valid. Sorry, I
don't have access to working code, as this does not yet seemed published.

The trick to prevent this attack is to configure the DNS server to
not emit packets above a specified size and make sure they don't get
fragmented locally (the mtu value needs to be somewhat lower than the
average MTU size of the internet, some people even say default min_pmtu
is the right choice). Of course, packets on paths which have a mtu below the
max-udp-size mtu will still get (rightfully) fragmented. But there seem to be
not that many paths out there (I hope, I don't have numbers for that).

Bascially all forwarding hops could be used for that, not only the
routers in critical forwarding paths.

Also IMHO I think using the mtu of the next-hop forwarding network is
just the right thing to do besides the presented attack on DNS.

Greetings,

  Hannes
