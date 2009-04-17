From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: dropwatch for network drop monitor
Date: Fri, 17 Apr 2009 13:22:39 -0400
Message-ID: <20090417172239.GC2723@hmsreliant.think-freely.org>
References: <200904171257.n3HCvOba029938@post.webmailer.de> <20090417132848.GA2723@hmsreliant.think-freely.org> <49E88F2A.4010301@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54416 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758630AbZDQRWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 13:22:50 -0400
Content-Disposition: inline
In-Reply-To: <49E88F2A.4010301@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 17, 2009 at 04:16:10PM +0200, Oliver Hartkopp wrote:
> Hi Neil,
> 
> >> Initalizing kallsyms db
> >> dropwatch> start
> >> Enabling monitoring...
> >> Waiting for activation ack....
> >> Waiting for activation ack....
> >> Waiting for activation ack....
> >> Waiting for activation ack....
> >> Waiting for activation ack....
> >> Waiting for activation ack....
> >> Failed activation request, error: Operation now in progress
> >> Shutting down ...
> >> vwagwolkf320:/home/hartko/dropwatch/src# 
> 
> Indeed i only get this the second time.
> 
> The first time i get
> 
> hartko@vwagwolkf320:~/dropwatch/src$ ./dropwatch
> Initalizing kallsyms db
> dropwatch> start
> Enabling monitoring...
> Kernel monitoring activated.
> Issue Ctrl-C to stop monitoring
> 
> But Ctrl-C does not work. I only get 100% CPU load on the CPU executing dropwatch.
> 
> After killing the process, i get the above originally described behaviour.
> 
> 
> >>
> >> And in my kernel log i get at the same time:
> >> [ 7070.568482] netlink: 60 bytes leftover after parsing attributes.
> 
> And this comes every time, i invoke dropwatch.
> 
> I'm running a debian system here on a Dell 830 Laptop with Core2Duo and the
> latest linux-2.6 git
> 
> Regards,
> Oliver
> 
> ps. Do i need to be root to run dropwatch?
> 
> 

Quick update for you, I've reproduced the problem.  The inability to restart
after the first few errors is actually by design.  Since you had to kill the
user space process, it left the kernel bits in a state where they were still
monitoring, so a second start command (when you restarted the user space daemon)
caused an error, and the program shutdown (which I probably shouldn't do,
returning instead to the command console).  You can work around this by issuing
a stop command, which successfully stops the kernel bits and lets you restart
them.

This also tells me that the kernel netlink warning is not fatal (as our netlink
message commands are getting processed properly).  I still need to figure out
why thats happening though.

As for the ctrl-c issue, I've got no idea whats going on there, its like the
recv operation is restarting after we catch the SIGINT.  I think I may just
switch that to a poll operation on the netlink socket and stdin input.  That
should fix that up quick.  Expect a git commit on that sometime this weekend,
and some subseqent netdev posts to fix the kernel bits. 

Thanks!
Neil

