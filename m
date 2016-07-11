From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: Multi-thread udp 4.7 regression, bisected to 71d8c47fc653
Date: Mon, 11 Jul 2016 18:26:42 +0200
Message-ID: <20160711162642.GA5462@salvia>
References: <CAB9dFduvE0dKzZ8Dm5RVVrUAq1Auvj8t9xXAyARGyO4NmowvYw@mail.gmail.com>
 <20160627142238.GA10613@breakpoint.cc>
 <CAB9dFds=qY=Dk++p7qVX7a8aOOH4wn0rtL3m4poO6HMQPuPrnA@mail.gmail.com>
 <20160627153820.GB10613@breakpoint.cc>
 <CAB9dFdvQ4UyKNMmOSx+FePyR0_Q425XLJRb_k5h+4JOSkQkf3w@mail.gmail.com>
 <CAB9dFds7KQxihReHhW9CXJeY9+=4BPema3ZawVA89U45QL5uBw@mail.gmail.com>
 <20160705122803.GA26862@salvia>
 <CAB9dFdv_ShA2cSez7Ut31XnW7OWufV59bfG-zN4Z0K3CgPvwuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="YiEDa0DAkWCtVeE4"
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>,
	Thorsten Leemhuis <regressions@leemhuis.info>,
	netfilter-devel@vger.kernel.org
To: Marc Dionne <marc.c.dionne@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44520 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753308AbcGKQ0v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2016 12:26:51 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id B81FC8D0511
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 18:26:46 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 9BC029EBAE
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 18:26:46 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 000029EBC1
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 18:26:43 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <CAB9dFdv_ShA2cSez7Ut31XnW7OWufV59bfG-zN4Z0K3CgPvwuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Jul 10, 2016 at 04:48:26PM -0300, Marc Dionne wrote:
> An update here since I've had some interactions with Pablo off list.
> 
> Further testing shows that the underlying cause of the different test
> results is a udp packet that has a bogus source port number.  In the
> test the server process tries to send an ack to the bogus port and the
> flow is disrupted.
> 
> Notes:
> - The packet with the bad source port is from a sendmsg() call that
> has hit the connection tracker clash code introduced by 71d8c47fc653
> - Packets are successfully sent after the bad one, from the same
> socket, with the correct source port number
> - The problem does not reproduce with 71d8c47fc653 reverted, or
> without nf_conntrack loaded
> - The bogus port numbers start at 1024, bumping up by 1 every few
> times the problem occurs (1025, 1026, etc.)
> - The patch above does not change the behaviour
> - Enabling lockdep does not show anything
> 
> Our workaround for the original race was to retry sendmsg() once on
> EPERM errors, and that had been effective.
> I can trigger the insertion clash easily with some simple test code,
> but I have not been able so far to reproduce the packets with bad
> source port numbers with some simpler code that I could share.

The NAT nul-binding is triggering the source port mangling, even if
there is no NAT rules in place. The following patch skips the clash
resolution for NAT by now since we don't see a simple solution for
this case at the moment.

Could you give a try to this patch in these two cases?

1) No NAT in place: Make sure iptable_nat module is not there. Or if
   you're using nf_tables, just make sure you have no nat chains at
   all.

2) With NAT in place, you hit back the EPERM errors that you've
   observed so far.

Please, test both scenarios and report back. Thanks.

--YiEDa0DAkWCtVeE4
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-conntrack-skip-clash-resolution-if-nat-is-.patch"

>From c3b9dfbcf35ea38a3dce22daf7450fc23c620aea Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 11 Jul 2016 17:28:54 +0200
Subject: [PATCH] netfilter: conntrack: skip clash resolution if nat is in
 place

The clash resolution is not easy to apply if the NAT table is
registered. Even if no NAT rules are installed, the nul-binding ensures
that a unique tuple is used, thus, the packet that loses race gets a
different source port number, as described by:

http://marc.info/?l=netfilter-devel&m=146818011604484&w=2

Clash resolution with NAT is also problematic if addresses/port range
ports are used since the conntrack that wins race may describe a
different mangling that we may have earlier applied to the packet via
nf_nat_setup_info().

Fixes: 71d8c47fc653 ("netfilter: conntrack: introduce clash resolution on insertion race")
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index e0e9c9a..2b0f80a 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -657,6 +657,7 @@ static int nf_ct_resolve_clash(struct net *net, struct sk_buff *skb,
 
 	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
 	if (l4proto->allow_clash &&
+	    !nfct_nat(ct) &&
 	    !nf_ct_is_dying(ct) &&
 	    atomic_inc_not_zero(&ct->ct_general.use)) {
 		nf_ct_acct_merge(ct, ctinfo, (struct nf_conn *)skb->nfct);
-- 
2.1.4


--YiEDa0DAkWCtVeE4--
