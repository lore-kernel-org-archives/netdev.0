From: Julian Anastasov <ja@ssi.bg>
Subject: Re: BUG - routes not correctly deleted when address is deleted
Date: Wed, 1 Dec 2010 12:08:42 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1012011136420.1645@ja.ssi.bg>
References: <20101130165539.40ce02c1@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:52723 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751976Ab0LAKHh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Dec 2010 05:07:37 -0500
In-Reply-To: <20101130165539.40ce02c1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 	Hello,

On Tue, 30 Nov 2010, Stephen Hemminger wrote:

> If multiple addresses are assigned to an interface, and
> a route is created that uses that address.  The route is not
> deleted when the address is deleted.  Linux does cleanup properly
> when the last address is deleted; it seems the FIB lacks the callback
> to cleanup routes referencing an address.
>
> Simple example:
>
> # modprobe dummy
> # ip li set dev dummy0 up
> # ip addr add 192.168.74.160/24 dev dummy0
> # ip addr add 192.168.18.11/24 dev dummy0
> # ip ro add 74.11.49.0/24 via 192.168.74.160

 	Such routes look as old way to create direct
routes over some device, used by "route" tool.
Device is inherited from the local IP used as gateway.
Such local gateways IPs are not used, see rt_set_nexthop()
where nh_scope is checked. FIB removes routes only when
the deleted IP is a prefsrc for this route, so may be
it is a good idea to use prefsrc.

> # ip addr del 192.168.74.160/24 dev dummy0
> # ip ro show dev dummy0
> 74.11.49.0/24 via 192.168.74.160
> 192.168.18.0/24  proto kernel  scope link  src 192.168.18.11
>
> Before I go off and either brute force it (add another call back
> into fib_hash and fib_trie), is there a better way?

 	Adding prefsrc is recommended. For me, it is not fatal
such routes to stay because nh_gw is not used. It is a
way to say at configuration time:

ip ro add 74.11.49.0/24 dev eth0

 	If you need such route to depend on the lifetime
of some local IP then you need to specify prefsrc.

 	If you go ahead with changes may be you should call 
fib_sync_down_dev from fib_del_ifaddr by providing the IP
as new argument. While fib_sync_down_addr is called when this
IP is removed from the last device where it was configured,
now for nh_gw fib_sync_down_dev should be called for every
fib_del_ifaddr call. For me, it is a complication, not sure
what others think.

Regards

--
Julian Anastasov <ja@ssi.bg>
