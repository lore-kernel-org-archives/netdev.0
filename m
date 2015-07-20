From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 -next] net: fib: use fib result when zero-length prefix
 aliases exist
Date: Mon, 20 Jul 2015 10:49:35 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1507200938570.1481@ja.home.ssi.bg>
References: <1437154621-18180-1-git-send-email-fw@strlen.de> <alpine.LFD.2.11.1507180045330.2410@ja.home.ssi.bg> <20150718180546.GA7835@breakpoint.cc> <alpine.LFD.2.11.1507191327090.1658@ja.home.ssi.bg> <20150719230345.GA11985@breakpoint.cc>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:33832 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753669AbbGTHtw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2015 03:49:52 -0400
In-Reply-To: <20150719230345.GA11985@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 20 Jul 2015, Florian Westphal wrote:

> > 	You mean:
> > 
> > - NUD_FAILED/NUD_NONE: no timer is pending, no current probing,
> > we can direct traffic that will set NUD_INCOMPLETE and will
> > send ARP probe
> > 
> > - NUD_INCOMPLETE: GW is currently probed, do not use it for
> > round-robin, direct traffic to another NUD_FAILED/NUD_NONE GW
> 
> Yes, thats what I meant.

	Then, may be something like diff below?

> Let me give you an example why I still think that fib_detect_death
> is not optimal.
> 
> Test VM is running net-next with your proposed patch on top.
> 
> Its much better, the weird round-robin behaviour reported is gone.
> 
> The VM has two interfaces,
> eth0, 192.168.7.10
> eth1, 192.168.8.10
> 
> ip route del default
> ip route add tos 0x0 via 192.168.7.1
> ip route add tos 0x10 via 192.168.8.2
> 
> 7.1 is reachable via eth0 (7.10/24)
> 8.2 *should* be rechable via eth1 (8.10/24)
> 
> I say *should* because I deliberately deleted this address from gateway
> connected to that interface.
> 
> Now, I run
> 
> ping -Q 0x10 192.168.0.7
> 
> Packets get sent via tos 0x0.  So far, so good.
> 
> Now I add back 192.168.8.2.
> 
> But no probe takes place so packets continue to be sent via tos 0 route.
> 
> neigh_lookup returns NULL -> state is NUD_NONE -> gw is deemed unreachable

	So, this is a case when configuration changes,
for example, simple change in list of routes is not noticed?
The best option would be to keep genid value together with
tb_default but if we move this field to fa it becomes costly
and not worth it.

	May be we can just play with the state as already
discussed? Example separate diff (to be ported for net-next).

ipv4: be more aggressive when probing alternative gateways

Currently, we do not notice if new alternative gateways
are added. We can do it by checking for present neigh
entry. Also, gateways that are currently probed (NUD_INCOMPLETE)
can be skipped from round-robin probing.

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index c7358ea..cd1732a 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -421,13 +421,15 @@ static int fib_detect_death(struct fib_info *fi, int order,
 	if (n) {
 		state = n->nud_state;
 		neigh_release(n);
+	} else {
+		return 0;
 	}
 	if (state == NUD_REACHABLE)
 		return 0;
 	if ((state & NUD_VALID) && order != dflt)
 		return 0;
 	if ((state & NUD_VALID) ||
-	    (*last_idx < 0 && order > dflt)) {
+	    (*last_idx < 0 && order > dflt && state != NUD_INCOMPLETE)) {
 		*last_resort = fi;
 		*last_idx = order;
 	}

Regards

--
Julian Anastasov <ja@ssi.bg>
