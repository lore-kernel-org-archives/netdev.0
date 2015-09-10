From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] sctp: fix race on protocol/netns initialization
Date: Thu, 10 Sep 2015 13:02:50 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB9194F@AcuExch.aculab.com>
References: <27f20cc781cac28bc2ce7229719748a2f6824bd8.1441827818.git.marcelo.leitner@gmail.com>
 <20150909.171600.1487892650387164045.davem@davemloft.net>
 <55F17D69.2050404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"vyasevich@gmail.com" <vyasevich@gmail.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: 'Marcelo Ricardo Leitner' <marcelo.leitner@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.191]:52095 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754077AbbIJNEE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 09:04:04 -0400
In-Reply-To: <55F17D69.2050404@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner
> Sent: 10 September 2015 13:54
> Em 09-09-2015 21:16, David Miller escreveu:
> > From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> > Date: Wed,  9 Sep 2015 17:03:01 -0300
> >
> >> So the fix then is to invert the initialization order inside
> >> register_pernet_subsys() so that the control socket is created by last
> >> and also block socket creation if netns initialization wasn't yet
> >> performed.
> >
> > If we really need to we could make ->create() fail with -EAFNOSUPPORT
> > if kern==1 until the protocol is fully setup.
> >
> > Or, instead of failing, we could make such ->create() calls block
> > until the control sock init is complete or fails.
> 
> I guess I should have written that paragraph in another order, perhaps like:
> So the fix then is to deny any sctp socket creation until netns
> initialization is sufficiently done. And due to that, we have to
> initialize the control socket as last step in netns initialization, as
> now it can't be created earlier anymore.
> 
> Is it clearer on the intention?
> 
> And my emphasis on userspace sockets was to highlight that a random user
> could trigger it, but yes both users are affected by the issue.
> 
> Strictly speaking, we would have to block ->create() not until the
> control socket init is done but until the protocol is fully loaded. Such
> condition, with this patch, is after net->sctp.auto_asconf_splist is
> initialized. But for blocking until instead of just denying, we would
> need some other mechanism.
> 
> It would be better from the (sctp) user point of view but then such
> solution may better belong to another layer instead and protect all
> protocols at once. (I checked and couldn't find other protocols at risk
> like sctp)

Given that the first ->create() blocks while the protocol code loads
it really wouldn't be right to error a subsequent ->create() because
the load hasn't completed.

I hold a semaphore across sock_create_kern() because of issues with sctp.
(Current kernels are nowhere near as bad as really old ones though.)

	David
