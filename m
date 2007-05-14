From: Frederik Deweerdt <deweerdt@free.fr>
Subject: Re: [Oops] unix_dgram_connect locking problem?
Date: Mon, 14 May 2007 20:49:08 +0200
Message-ID: <20070514184908.GB3938@slug>
References: <20070511150014.GF23638@slug> <20070514.032054.95058880.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.190]:57937 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754726AbXENSu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 14:50:29 -0400
Received: by mu-out-0910.google.com with SMTP id w1so1194182mue
        for <netdev@vger.kernel.org>; Mon, 14 May 2007 11:50:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070514.032054.95058880.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Mon, May 14, 2007 at 03:20:54AM -0700, David Miller wrote:
> From: Frederik Deweerdt <deweerdt@free.fr>
> Date: Fri, 11 May 2007 17:00:14 +0200
> 
> > I think that not unix_state_rlock'ing "other" in
> > unix_dgram_connect may cause it to become NULL while passing it to
> > selinux_socket_unix_may_send. With the following patch applied, I've
> > seen no oops so far (1-2 hours as opposed to a few minutes before applying
> > the patch). Any thoughts?
> 
> Thanks for this report and patch, similar code in UNIX stream connect
> has the following comment:
> 
> 	/* Latch our state.
> 
> 	   It is tricky place. We need to grab write lock and cannot
> 	   drop lock on peer. It is dangerous because deadlock is
> 	   possible. Connect to self case and simultaneous
> 	   attempt to connect are eliminated by checking socket
> 	   state. other is TCP_LISTEN, if sk is TCP_LISTEN we
> 	   check this before attempt to grab lock.
> 
> 	   Well, and we have to recheck the state after socket locked.
> 	 */
>  ...
> 	unix_state_wlock_nested(sk);
> 
> So I think we need to be careful about deadlocks wrt. holding
> both wlock on sk and rlock on other at the same time in
> the dgram case too.
Thanks for your answer. I'll write and test a patch taking this into
account. I'm thinking to check if sk == other, in which case we don't
need to rlock. This is sufficient to avoid the deadlock case, isn't
it?. If yes, I wonder why the stream case has to resort to the sk_state?

Thanks,
Frederik
