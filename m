From: David Miller <davem@davemloft.net>
Subject: Re: [iproute2] iproute2: Allow 'ip addr flush' to loop more than
 10 times.
Date: Mon, 28 Jun 2010 23:36:00 -0700 (PDT)
Message-ID: <20100628.233600.242129599.davem@davemloft.net>
References: <1277790959-28075-1-git-send-email-greearb@candelatech.com>
	<20100628.231204.229752207.davem@davemloft.net>
	<4C29925B.9090008@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@gmail.com, netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38320
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751810Ab0F2Gfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 02:35:48 -0400
In-Reply-To: <4C29925B.9090008@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Mon, 28 Jun 2010 23:27:39 -0700

> I'm not sure I understand how this loop could have run forever
> anyway, unless some other process(es) was constantly adding
> addresses at the same time?  Or maybe some ipv6 auto config thing?
> 
> It appears there is already code to detect when the loop
> is done (flushing ~70 IPv4 addresses with -l 0 was one of my
> test cases, and worked as expected).

What happens is that we are simply limited by how many addresses
we can delete in one go, and that limit is 4096 bytes of netlink
message size.

So we have to iterate, reusing that buffer each time, to get them all
done.

The limit exists because meanwhile it is possible that some other
entity could add addresses and thus cause us to loop forever and
never actually delete all of the addresses because every time we
delete a bunch the other entity adds more.

I can understand the reasoning behind the limit, because if this is
run by something automated it's not like someone is at the command
line and hit Ctrl-C to break out of a looping instance.

But practically speaking I bet this never happens.

So what makes sense to me is:

1) Loop forever by default.

2) When the number of loops exceeds a threshold (calculated by the
   number of addresses we see the first dump, divided by the number
   of deletes we can squeeze into the 4096 byte message), we emit
   a warning.

3) A hard limit, off by default, it available via your "-l" new option.

But seriously we can determine forward progress quite easily I think.

Each loop, we see if the dump returns a smaller number of addresses
than the last iteration.  If so, we just keep going.

If the number of addresses increases, I think we can bail in this
case.

This logic would only ever trigger iff another entity is adding a
large number of addresses simultaneously with our flush.  And frankly
speaking the person doing the flush probably doesn't expect that to be
happening.  You're flushing all of the addresses so you can start with
a clean slate and then add specific addresses back, or whatever.

