From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Incorrect ARP behavior when multiple/none IPv4 address assigned
 to interface
Date: Wed, 24 Oct 2012 12:06:33 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1210241106080.1616@ja.ssi.bg>
References: <50867F51.3030500@mail.ru> <alpine.LFD.2.00.1210232317400.1780@ja.ssi.bg> <50879632.20909@mail.ru>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-579140669-1351069593=:1616"
Cc: netdev@vger.kernel.org
To: Sergey Popovich <popovich_sergei@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:48147 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933474Ab2JXJAR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2012 05:00:17 -0400
In-Reply-To: <50879632.20909@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-579140669-1351069593=:1616
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Wed, 24 Oct 2012, Sergey Popovich wrote:

> Julian Anastasov пишет:
> 
> > > # tcpdump -vv -ieth0 -s1500 -nnpe 'arp'
> > > 13:28:57.395181 08:00:27:3b:63:ae>  0a:00:27:00:00:00, ethertype ARP
> > > (0x0806),
> > > length 42: Ethernet (len 6),.
> > > IPv4 (len 4), Request who-has 10.0.1.2 tell 10.10.10.10, length 28
> > 
> > 	What kind of packet triggers ARP request here?
> > May be this IP packet already has saddr=10.10.10.10 ?
> > arp_solicit() when eth0/arp_announce=0 (default) just
> > ensures that this saddr is local. Or it is a forwarding
> > case and inet_select_addr is used? Also, any reason to put
> > addresses on loopback and not on eth0?
> 
> 1. Sorry, from bug report is not clear to undestand how this is reproduced:
>   1.1. on PC1 run ping 10.0.1.1
>   1.2. on Linux Router start arp-probe-bug.bsh as root user.
> So this kind of packet generated after link layer addresses resolved &
> ICMP Echo Request/Reply in progress (with no packet loss).
> 
> 2. No I do not think that saddr=10.10.10.10 in probe.
> arp_solicit calls inet_select_addr() only if saddr=0.0.0.0.
> Call to arp_solicit() made from net/core/neighbour.c neigh_probe()
> which is static and called from neigh_timer_handler() when entry ages
> out and goes to PROBE phase.

	Indeed, it can happen often to see skb=NULL for
empty arp_queue...

> 3. Reason to put addr on loopback (not actually system loopback, but
> linux dummy interface or any other network interface) described in more
> details in my bug report, but for short:
> 
> Suppose we have 10.0.1.0/24 subnet.
> and many customers with single ip address (common for Internet
> Providers) on differend broadcast domains (VLANs).
> 
> Each customer connected using 4(!) IPv4 address using traditional schema:
> 
> 10.0.1.0/30 - Customer 1 (ip: 10.0.1.2,  gw: 10.0.1.1, mask: /30)
> 10.0.1.4/30 - Customer 2 (ip: 10.0.1.6,  gw: 10.0.1.5, mask: /30)
> 10.0.1.8/30 - Customer 3 (ip: 10.0.1.10, gw: 10.0.1.9, mask: /30)
> ...
> 10.0.1.252/30 - Customer 64 (ip: 10.0.1.254, gw: 10.0.1.253, mask: /30
> 
> As can be seen on each connection we waste at least 2 IP address:
>   one for subnet address (all zeros in host part)
>   one for subnet broadcast (all ones in host part)
> 
> More efficiently to use entire subnet with /24 mask and assign to each
> customer one ip from subnet with mask /24.
> 
> 10.0.1.1/24 - Loopback (dummy) on Linux Router. This is gateway address
>               to customers.
> 10.0.1.2/24 - Customer 1
> 10.0.1.3/24 - Customer 2
> 10.0.1.4/24 - Customer 3
> ...
> 10.0.1.254/24 - Customer 253
> 
> This schema called by some network equipment vendors as "ip unnumbered"
> and works in Linux for years (and thus used with proper NICs by many
> small/medium (and even large) ISPs to aggregate broadband customers).

	But I still don't understand what will prevent
this "ip unnumbered" address assignment schema to work on
eth0/1/2 instead of using many dummy interfaces, they are
only a place to put addresses, it seems.

	dummy module is usually used as blackhole for
traffic or to hide addresses from other interfaces with
some sysctl interface flags.

	For example, can it work in this way?:

eth0: addr 10.0.1.1/24
ip route 10.0.1.2/32 dev eth0 src 10.0.1.1

eth1: addr 10.0.1.1/24
ip route 10.0.1.3/32 dev eth1 src 10.0.1.1

eth2: addr 10.0.2.1/24
ip route 10.0.2.2/32 dev eth2 src 10.0.2.1

	By this way we have subnet on every device and
we can prefer local IP from such subnet in inet_select_addr.
May be arp_ignore=1/2 and arp_announce=1/2 can help here
to put the needed restrictions, i.e. we should not expose
addresses from other devices. It should not cause problem
for proxy_arp because we have more specific /32 routes.

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-579140669-1351069593=:1616--
