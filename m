From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: Re: Incorrect ARP behavior when multiple/none IPv4 address assigned
 to interface
Date: Wed, 24 Oct 2012 10:18:10 +0300
Message-ID: <50879632.20909@mail.ru>
References: <50867F51.3030500@mail.ru> <alpine.LFD.2.00.1210232317400.1780@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp9.mail.ru ([94.100.176.54]:45524 "EHLO smtp9.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933828Ab2JXHS3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2012 03:18:29 -0400
Received: from [195.234.68.4] (port=35100 helo=tuxracer.localdomain)
	by smtp9.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1TQvES-0007Pi-4s
	for netdev@vger.kernel.org; Wed, 24 Oct 2012 11:18:28 +0400
In-Reply-To: <alpine.LFD.2.00.1210232317400.1780@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julian Anastasov =D0=BF=D0=B8=D1=88=D0=B5=D1=82:

>> # tcpdump -vv -ieth0 -s1500 -nnpe 'arp'
>> 13:28:57.395181 08:00:27:3b:63:ae>  0a:00:27:00:00:00, ethertype ARP=
 (0x0806),
>> length 42: Ethernet (len 6),.
>> IPv4 (len 4), Request who-has 10.0.1.2 tell 10.10.10.10, length 28
>
> 	What kind of packet triggers ARP request here?
> May be this IP packet already has saddr=3D10.10.10.10 ?
> arp_solicit() when eth0/arp_announce=3D0 (default) just
> ensures that this saddr is local. Or it is a forwarding
> case and inet_select_addr is used? Also, any reason to put
> addresses on loopback and not on eth0?

1. Sorry, from bug report is not clear to undestand how this is reprodu=
ced:
   1.1. on PC1 run ping 10.0.1.1
   1.2. on Linux Router start arp-probe-bug.bsh as root user.
So this kind of packet generated after link layer addresses resolved &
ICMP Echo Request/Reply in progress (with no packet loss).

2. No I do not think that saddr=3D10.10.10.10 in probe.
arp_solicit calls inet_select_addr() only if saddr=3D0.0.0.0.
Call to arp_solicit() made from net/core/neighbour.c neigh_probe()
which is static and called from neigh_timer_handler() when entry ages
out and goes to PROBE phase.

3. Reason to put addr on loopback (not actually system loopback, but
linux dummy interface or any other network interface) described in more=
=20
details in my bug report, but for short:

Suppose we have 10.0.1.0/24 subnet.
and many customers with single ip address (common for Internet
Providers) on differend broadcast domains (VLANs).

Each customer connected using 4(!) IPv4 address using traditional schem=
a:

10.0.1.0/30 - Customer 1 (ip: 10.0.1.2,  gw: 10.0.1.1, mask: /30)
10.0.1.4/30 - Customer 2 (ip: 10.0.1.6,  gw: 10.0.1.5, mask: /30)
10.0.1.8/30 - Customer 3 (ip: 10.0.1.10, gw: 10.0.1.9, mask: /30)
=2E..
10.0.1.252/30 - Customer 64 (ip: 10.0.1.254, gw: 10.0.1.253, mask: /30

As can be seen on each connection we waste at least 2 IP address:
   one for subnet address (all zeros in host part)
   one for subnet broadcast (all ones in host part)

More efficiently to use entire subnet with /24 mask and assign to each=20
customer one ip from subnet with mask /24.

10.0.1.1/24 - Loopback (dummy) on Linux Router. This is gateway address
               to customers.
10.0.1.2/24 - Customer 1
10.0.1.3/24 - Customer 2
10.0.1.4/24 - Customer 3
=2E..
10.0.1.254/24 - Customer 253

This schema called by some network equipment vendors as "ip unnumbered"
and works in Linux for years (and thus used with proper NICs by many
small/medium (and even large) ISPs to aggregate broadband customers).

> 	Your case 2 can be also solved with proper ordering of
> the primaries, eg. first add /32 primaries, then /31, ... /25, /24.
> You can also use decreasing scope for the addresses if global
> scope is not needed for them, it can help for the ordering.
>
Yes you are right, but it is not clear to understand at configure
time:-).

> 	For the proposed patch: providing iph->saddr to
> inet_select_addr() in icmp_send() looks better than before.
> Still, inet_select_addr() is incorrect function to use
> from icmp_send(), there is the risk to expose scope link
> addresses.
>
Correct, but using sysctl icmp_errors_use_inbound_ifaddr as for
me is not right entirely:
   ICMP might be generated for address that is not directly reachable
   (more than hop away from interface on which packet arrives -
    reachable via gw on interface) and thus it is better to rely on
   prefsrc of route associated with this  interface when sending ICMP i=
n
   ip_route_output_slow() that is already done and works correctly.

Using iph->saddr is done as contermeasure only used then such sysctl is
activated (default: no).

> 	The other part from patch in inet_select_addr() looks
> correct to me but comes with some price for the arp_solicit()
> and icmp_send() cases, a slowdown that may not be liked by
> others.
Yes, we looking at all interfaces in system and all primary addresses
on.

>
> 	About fib_info_update_nh_saddr: same fib_info can
> be used for different subnets, so we can not check the
> destination. But routes to directly connected hosts
> usually come with prefsrc (proto kernel), so it is not a
> problem.
Yes, I point to this to clarify this to me. Thank you.

--=20
SP5474-RIPE
Sergey Popovich
