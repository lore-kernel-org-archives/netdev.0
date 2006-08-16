From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to use rtnl_notify()
Date: Wed, 16 Aug 2006 21:39:50 +1000
Message-ID: <20060816113950.GA29003@gondor.apana.org.au>
References: <20060815122300.GV14627@postel.suug.ch> <E1GDBbw-0006Kz-00@gondolin.me.apana.org.au> <20060816105856.GW14627@postel.suug.ch> <20060816111240.GA28846@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hasso@estpak.ee, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49676 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751013AbWHPLkV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 07:40:21 -0400
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20060816111240.GA28846@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 16, 2006 at 09:12:40PM +1000, herbert wrote:
> 
> Any notification that sets the netlink pid to current->pid is
> *completely* bogus.  Let me repeat this, the netlink pid is not
> a process ID.

BTW, I'm not having a go at either Thomas or Jamal.  You guys
are oo the same side for once :).

I honestly believe that we have a misunderstanding here which needs
to be sorted out.  It gets worse because that misunderstanding has
made it into the manpages package which only causes more confusion.

So let's step back a bit and think about where does this pid really
come from.  The field in question is nlmsg_pid.  Its primary purpose
is to identify unicast transactions along with the field nlmsg_seq.
It was not designed to identify the origin of a broadcast kernel
notification to a third party.

For this purpose, the value of nlmsg_pid is set to the address of
the destination socket for a particular unicast message (also known
as the pid).

That pid in turn has only a vague connection with the process ID
of the process owning the socket.  For practical purposes, we
should not treat it as a process ID it can easily be claimed by
another process (think socket + bind + fork).

For a broadcast notification, the nlmsg_pid field is meaningless
because the nlmsg_seq field is also meaningless.  I'm not denying
that it wouldn't be useful to have the originator's socket address
in there.  What I'm saying is that it's the wrong place to put
that information.

In any case, putting current->pid in this field is definitely
a bad idea because it only encourages people to confuse the
netlink pid with the process ID which can lead to security
problems later on.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
