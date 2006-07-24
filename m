From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Tue, 25 Jul 2006 00:52:03 +0400
Message-ID: <20060724205203.GA5629@ms2.inr.ac.ru>
References: <20060718081625.GA13830@2ka.mipt.ru> <20060718230121.GA31474@ms2.inr.ac.ru> <20060719155204.0de8882b@localhost.localdomain> <20060719.130150.39158599.davem@davemloft.net> <20060724115415.7cc7acc6@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, johnpol@2ka.mipt.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:62889 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S932178AbWGXUwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 16:52:42 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060724115415.7cc7acc6@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Also, there is some code for refcnt's in it that looks wrong.

Yes, it is disgusting. rcu does not allow to increase socket refcnt
in lookup routine.

Ben's version looks cleaner here, it does not touch refcnt
in rcu lookups. But it is dubious too:

 do_time_wait:
+       sock_hold(sk);

is obviously in violation of the rule. Probably, rcu lookup should do something
like:

if (!atomic_inc_not_zero(&sk->sk_refcnt))
	pretend_it_is_not_found; 

It is clear Ben did not look into IBM patch, because one known place
of trouble is missed: when socket moves from established to timewait,
timewait bucket must be inserted before established socket is removed.

Alexey
