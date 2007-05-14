From: David Miller <davem@davemloft.net>
Subject: Re: [Oops] unix_dgram_connect locking problem?
Date: Mon, 14 May 2007 03:20:54 -0700 (PDT)
Message-ID: <20070514.032054.95058880.davem@davemloft.net>
References: <20070511150014.GF23638@slug>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: deweerdt@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52361
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754766AbXENKUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 06:20:49 -0400
In-Reply-To: <20070511150014.GF23638@slug>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frederik Deweerdt <deweerdt@free.fr>
Date: Fri, 11 May 2007 17:00:14 +0200

> I think that not unix_state_rlock'ing "other" in
> unix_dgram_connect may cause it to become NULL while passing it to
> selinux_socket_unix_may_send. With the following patch applied, I've
> seen no oops so far (1-2 hours as opposed to a few minutes before applying
> the patch). Any thoughts?

Thanks for this report and patch, similar code in UNIX stream connect
has the following comment:

	/* Latch our state.

	   It is tricky place. We need to grab write lock and cannot
	   drop lock on peer. It is dangerous because deadlock is
	   possible. Connect to self case and simultaneous
	   attempt to connect are eliminated by checking socket
	   state. other is TCP_LISTEN, if sk is TCP_LISTEN we
	   check this before attempt to grab lock.

	   Well, and we have to recheck the state after socket locked.
	 */
 ...
	unix_state_wlock_nested(sk);

So I think we need to be careful about deadlocks wrt. holding
both wlock on sk and rlock on other at the same time in
the dgram case too.
