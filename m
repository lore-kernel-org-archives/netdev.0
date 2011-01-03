From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bridge not routing packets via source bridgeport
Date: Mon, 03 Jan 2011 19:42:15 +0100
Message-ID: <1294080135.2892.1152.camel@edumazet-laptop>
References: <4D220CFB.5060300@d9t.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Daniel Kraft <daniel.kraft@d9t.de>
To: "Sebastian J. Bronner" <sebastian.bronner@d9t.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33790 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242Ab1ACSmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 13:42:23 -0500
Received: by wwa36 with SMTP id 36so14423527wwa.1
        for <netdev@vger.kernel.org>; Mon, 03 Jan 2011 10:42:22 -0800 (PST)
In-Reply-To: <4D220CFB.5060300@d9t.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 03 janvier 2011 =C3=A0 18:52 +0100, Sebastian J. Bronner a =C3=
=A9crit :
> Hi all,
>=20
> we recently upgraded from 2.6.32.25 to 2.6.35.24 and discovered that =
our
> virtual machines can no longer access their own external IP addresses=
=2E
> Testing revealed that 2.6.34 was the last version not to have the
> problem. 2.6.36 still had it. But on to the details.
>=20
> Our setup:
>=20
> We use KVM to virtualise our guests. The physical machines (nodes) ac=
t
> as One-to-One NAT routers to the virtual machines. The virtual machin=
es
> are connected via virtio interfaces in a bridge.
>=20
> Since the virtual machines only know about their RFC-1918 addresses, =
any
> request they make to their NATed global addresses requires a trip
> through the node's netfilter to perform the needed SNAT and DNAT oper=
ations.
>=20
> Take the following setup:
>=20
>    {internet}
>        |
>      (eth0)       <- 1.1.1.254, proxy_arp=3D1
>        |
>      [node]       <- ip_forward=3D1, routes*, nat**
>        |
>     (virbr1)      <- 10.0.0.1
>     /      \
> (vnet0)     |
>    |     (vnet1)
> (veth0)     |     <- 10.0.0.2
>    |     (veth0)  <- 10.0.0.3
>  [vm1]      |
>           [vm2]
>=20
> * The static routes on the node for the vms mentioned above are as fo=
llows:
> # ip r
> 1.1.1.2 dev virbr1 scope link
> 1.1.1.3 dev virbr1 scope link
>=20
> ** The NAT rules are set up as follows (in reality, they're a bit mor=
e
> complicated - but this suffices to illustrate the problem at hand):
> # iptables-save -t nat
> -A PREROUTING -d 1.1.1.2 -j DNAT --to-destination 10.0.0.2
> -A PREROUTING -d 1.1.1.3 -j DNAT --to-destination 10.0.0.3
> -A POSTROUTING -s 10.0.0.2 -j SNAT --to-source 1.1.1.2
> -A POSTROUTING -s 10.0.0.3 -j SNAT --to-source 1.1.1.3
>=20
> This means that 1.1.1.2 maps to 10.0.0.2 (vm1) and
>                 1.1.1.3 maps to 10.0.0.3 (vm2).
>=20
> Assuming ssh is running on both vms, running 'nc -v 1.1.1.3 22' from =
vm1
> gets me ssh's introductory message.
>=20
> Assuming, no service is running on port 23, running 'nc -v 1.1.1.3 23=
'
> from vm1 gets me 'Connection refused'.
>=20
> That's all fine and exactly as it should be. The vms are accessible f=
rom
> the internet as well, and can access the internet.
>=20
> If, however, i run 'nc -v 1.1.1.2 22' from vm1 (or any port for that
> matter), I get a timeout!
>=20
> Running tcpdump on all the involved interfaces showed me that the
> packets successfully traverse veth0 and vnet0 and appear to get lost
> upon reaching virbr1.
>=20
> So, then I decided to set up a packet trace with iptables:
> [on the node]
> # modprobe ipt_LOG
> # iptables -t raw -A PREROUTING -p tcp --dport 4577 -j TRACE
> # tail -f /var/log/messages | grep TRACE
> [on vm1]
> # nc -v 1.1.1.2 4577
>=20
> The results were very interesting, if somewhat dumbfounding. They are
> attached for easier perusal. The gist of it is that the packet in
> question disappears without a trace after going through the DNAT rule=
 in
> the PREROUTING chain of the NAT table. This can be seen happening thr=
ee
> times in vm1-to-1.1.1.2.txt in three and six second intervals (retrie=
s).
>=20
> For comparison, I have also included a trace of a successful packet
> traversal that ends in a 'Connection refused'. It is in vm1-to-1.1.1.=
3.txt.
>=20
> As a last note, I should add that the problem isn't related to the IP
> address. I eliminated that by putting two RFC-1918 IPs on vm1 and
> mapping two IPs to it, then running nc on one IP, while the other one
> was being used as the source IP.
>=20
> The problem appears to be that packets can't be routed out the same
> bridgeport that they arrived from.
>=20
> I hope this all makes sense and that you can reproduce the problem. O=
ne
> virtual machine will suffise to see the problem at work.
>=20
> Feel free to contact me if you need more information or have suggesti=
ons
> for me.
>=20
> Cheers,
> Sebastian Bronner
>=20
> P.S.: The IP addresses are faked. I used vim to replace all instances=
 of
> the real IPs with the fake ones used in this e-mail consistently.

random guess: maybe rp_filter hits you ?


With 2.6.36, a new SNMP counter was added,=20
"netstat -s | grep IPReversePathFilter"



