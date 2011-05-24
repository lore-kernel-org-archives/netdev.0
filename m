From: Rick Jones <rick.jones2@hp.com>
Subject: Re: small RPS cache for fragments?
Date: Tue, 24 May 2011 14:38:48 -0700
Message-ID: <1306273128.8149.1444.camel@tardy>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
	 <20110524.160123.2051949867829317339.davem@davemloft.net>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:40487 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757132Ab1EXViu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 17:38:50 -0400
In-Reply-To: <20110524.160123.2051949867829317339.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-24 at 16:01 -0400, David Miller wrote:
> So I looked into implementing this now that it has been established
> that we changed even Linux to emit fragments in-order.
> 
> The first problem we run into is that there is no "context" we can
> use in all the places where skb_get_rxhash() gets called.
> 
> Part of the problem is that we call it from strange places, such as
> egress packet schedulers.  That's completely bogus.
> 
> Examples, FLOW classifier, META e-match, CHOKE, and SFB.
> 
> In fact, for the classifiers this means they aren't making use of the
> precomputed TX hash values in the sockets like __skb_tx_hash() will
> make use of.  So this makes these packet schedulers operate
> potentially more expensively than they need to.
> 
> If we could get rid of those silly cases, the stuff that remains
> (macvtap and net/core/dev.c) could work with a NAPI context during
> rxhash computation and use that to store the IP fragmentation
> on-behind cached information.

Isn't there still an issue (perhaps small) of traffic being sent through
a mode-rr bond, either at the origin or somewhere along the way?  At the
origin point will depend on the presence of UFO and whether it is
propagated up through the bond interface, but as a quick test, I
disabled TSO, GSO and UFO on four e1000e driven interfaces, bonded them
mode-rr and ran a netperf UDP_RR test with a 1473 byte request size and
this is what they looked like at my un-bonded reciever at the other end:

14:31:01.011370 IP (tos 0x0, ttl 64, id 24960, offset 1480, flags
[none], proto UDP (17), length 21)
    tardy.local > raj-8510w.local: udp
14:31:01.011420 IP (tos 0x0, ttl 64, id 24960, offset 0, flags [+],
proto UDP (17), length 1500)
    tardy.local.36073 > raj-8510w.local.59951: UDP, length 1473
14:31:01.011514 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto
UDP (17), length 29)
    raj-8510w.local.59951 > tardy.local.36073: UDP, length 1

rick jones

