From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] net: reflect the fwmark for replies with no socket
Date: Wed, 12 Mar 2014 10:22:25 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1403120857160.1504@ja.home.ssi.bg>
References: <1394536541-25702-1-git-send-email-lorenzo@google.com> <alpine.LFD.2.11.1403112242190.1769@ja.home.ssi.bg> <CAKD1Yr0WAZaUgtDS2CpiNZsB48U6mT9vd+NniV4jrVTB5DhrQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:58198 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755262AbaCLIXl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 04:23:41 -0400
In-Reply-To: <CAKD1Yr0WAZaUgtDS2CpiNZsB48U6mT9vd+NniV4jrVTB5DhrQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 12 Mar 2014, Lorenzo Colitti wrote:

> On Wed, Mar 12, 2014 at 5:52 AM, Julian Anastasov <ja@ssi.bg> wrote:
> >         If you can do it with CONNMARK save+restore,
> > do not change behavior for existing setups. It is
> > hard to predict how the mark is used in ip and
> > POST ROUTING rules.
> 
> I think CONNMARK save/restore can do some of this but not all of it.
> 
> For example, consider the case of mark-based routing ("ip rule add
> fwmark 123 lookup 456"). Setting the mark when emitting the packet
> from protocol code (i.e., this patch), will cause the right route to
> be selected. This will properly follow the routing policy chain
> (including match routes like "unreachable" and "prohibit" if present),
> use the right MTU, select the right source address for ICMP errors,
> pick the right MSS/rwin for inclusion in SYN+ACK packets, and so on.

	I agree that CONNMARK will do second route lookup
in the OUTPUT hook, ipt_mangle_out will detect the mark
change, so it is a slower alternative. And limited as
you pointed out.

> Some of this can be done after the fact using a combination of the
> route target, snat/masquerade, MSS rewriting, and so on. However, that
> essentially requires duplicating routing and source address selection
> into iptables rules. This is brittle and particularly difficult when
> dealing with IPv6, where routes can come from autoconf and source
> address selection is more complex than in IPv4. It also requires using
> snat/masquerade for IPv6, which is something we should avoid if
> possible. In general rule it seems to me that it's better to have the
> kernel emit the correct packet the first time around than having to
> use iptables CONNTRACK to fix it up after the fact.
> 
> How much of a concern is modifying existing behaviour? Personally I
> think reflecting the mark is better than just using 0 all the time,

	Problem should be for setups that use fwmark
for different purposes in both directions. There can
be many examples, one is for asymmetric routing,
ip rule that delivers locally the marked packets:

1. PRE_ROUTING: set mark for dport 80
2. ip rule ... fwmark N table to_local;
   ip route add local 0/0 dev lo table to_local
3. IPVS direct routing to many proxies on LAN

	What we can say is that such ip rule with fwmark
will start to work for the output traffic unexpectedly.
The TOS replying suffers from the same problem, I guess
routing by TOS is not used much and nobody complained.

> but of course, it's possible that people are explicitly matching mark
> 0 in firewall rules or routing tables. Would it be better if this was
> a sysctl?

	sysctl looks better to me. For example,
ip_reply_fwmark(net, fwmark) that will return 0 or
fwmark depending on net->ipv4.sysctl_reply_fwmark boolean.
Similar for ip6_reply_fwmark() and net->ipv6.sysctl_reply_fwmark.
You can select the right names.

Regards

--
Julian Anastasov <ja@ssi.bg>
