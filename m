From: Michal Soltys <soltys@ziu.info>
Subject: Re: ebtables on a stick
Date: Wed, 30 Nov 2011 00:11:36 +0100
Message-ID: <4ED566A8.2000108@ziu.info>
References: <925A849792280C4E80C5461017A4B8A2A04879@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487A@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487F@mail733.InfraSupportEtc.com> <20111128143901.GA589422@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Greg Scott <GregScott@Infrasupport.com>, netdev@vger.kernel.org
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:3725 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756433Ab1K2XL2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Nov 2011 18:11:28 -0500
In-Reply-To: <20111128143901.GA589422@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-11-28 15:39, David Lamparter wrote:
> On Sun, Nov 27, 2011 at 09:10:08AM -0600, Greg Scott wrote:
>>  I have a situation that needs to route mostly and bridge only a
>>  little bit.
>>
>>  I have a private internal LAN, 192.168.10.nnn.  But one host in the
>>  internal side needs a real public IP Address, call it 1.2.115.157.
>>  Everything except that public IP host needs to route.  The public
>>  host needs to bridge so it can interact with the world.  But it also
>>  needs to interact with the internal LAN.
>>
>>  I have a Linux brouter set up with eth0 facing the Internet, eth1
>>  facing the LAN as follows:
>>
>>  ifconfig eth0 1.2.115.146 mask 255.255.255.240 ifconfig eth1
>>  192.168.10.1 mask 255.255.255.0
> [...]
> 
> This doesn't answer your question, but your use case is better solved
> with proxy arp.
> 
> ip route add 1.2.115.157/32 dev eth1
> ip neigh add proxy 1.2.115.157 dev eth0
> # ... adjust iptables rules to make sure traffic is allowed
> # optional, but I'd recommend:
> iptables -t raw -I PREROUTING -d 1.2.115.157 -j NOTRACK
> iptables -t raw -I PREROUTING -s 1.2.115.157 -j NOTRACK
> 
> on the target host:
> 
> ip addr add 1.2.115.157/32 dev ethX
> ip route add 192.168.10.1/24 dev ethX
> ip route add default via 192.168.10.1


In addition to what David wrote, you might want specify 'src' option on
certain routes, and/or specify scopes by hand.

For example if the lan host in question has something like:

ip add add 192.168.10.2/24 broad + dev eth0 scope link ip add add
1.2.115.157/32 dev eth0 scope global ip ro add unicast default via
192.168.10.1 dev eth0 src 1.2.115.157

Then the 'src' will prefer public ip for non-lan communication (even
without scopes).

Make sure, when you (likely) do snat with iptables on the router, to
skip this address in such case (in case of not using notrack).

BTW, scopes can help with masquerade target on router (not important in
your case as you have static addresses, but still), as it will choose
candidates with global scope.
