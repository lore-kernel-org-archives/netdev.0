From: "Dimitrios Michailidis" <dm@chelsio.com>
Subject: RE: [PATCH] cxgb4vf: fix crash due to manipulating queues before registration
Date: Fri, 29 Oct 2010 00:36:22 -0700
Message-ID: <8A71B368A89016469F72CD08050AD334088DA49E@maui.asicdesigners.com>
References: <1288297007-663-1-git-send-email-leedom@chelsio.com> <20101028.132122.245402585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>,
	"Casey Leedom" <leedom@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31545 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957Ab0J2Hg1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 03:36:27 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Before commit "net: allocate tx queues in register_netdevice"
> > netif_tx_stop_all_queues and related functions could be used between
> > device allocation and registration but now only after registration.
> > cxgb4 has such a call before registration and crashes now.  Move it
> > after register_netdev.
> >
> > Signed-off-by: Casey Leedom <leedom@chelsio.com>
> 
> Why are you manipulating the queue at all here?
> 
> The queue state is "don't care" at this point in time,
> and has no meaning until ->open() is invoked.

The reason for the call at its initial pre register_netdev location was
an attempt to make the queues have the same state at the time of each
open.  Without it at the first open __QUEUE_STATE_XOFF is not set due to
0-initialization but at subsequent opens it is set because close stops
the queues.  I agree however that this disparity is not functionally
significant.  Further, I believe moving the call after register_netdev
is buggy as open can be called after registration and it can clash with
the queue stopping.  It seems then that these netif_tx_stop_all_queues
calls have to go now.

