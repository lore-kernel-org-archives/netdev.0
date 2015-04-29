From: Hariprasad S <hariprasad@chelsio.com>
Subject: Re: [PATCH net] cxgb4vf: Implement mailbox access locking and list
 management
Date: Wed, 29 Apr 2015 17:37:32 +0530
Message-ID: <20150429120632.GA8185@hariprasad-pc.asicdesigners.com>
References: <1429014645-20361-1-git-send-email-hariprasad@chelsio.com>
 <20150414.142916.969366711752555436.davem@davemloft.net>
 <20150414.144052.843726517109270692.davem@davemloft.net>
 <4985EFDD773FCB459EF7915D2A3621ADBB8E0A@nice.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>
To: Casey Leedom <leedom@chelsio.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:8789 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1422805AbbD2MHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 08:07:36 -0400
Content-Disposition: inline
In-Reply-To: <4985EFDD773FCB459EF7915D2A3621ADBB8E0A@nice.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 15, 2015 at 03:27:57 +0530, Casey Leedom wrote:
>   I don't believe that there's any ordering requirement other than fairness.  There is an ordering requirement for a single thread of control issuing multiple mailbox requests but that's the job of the thread to issue the requests in the order which is correct.  The issue comes when there are multiple threads attempting to use the mailbox facility at the same time.  Normally this would be guarded by the RTNL one would presume but we ran into cases where a thread would come in and issue mailbox requests without the RTNL being held ...  Hold on a second and I'll look this up ...
> 
>   ... Okay, that took a while but I finally dug it up.  The issue is the for the Virtual Function Driver, the only way to get the Virtual Interface statistics is to issue mailbox commands to ask the firmware for the VI Stats.  And, because the VI Stats command can only retrieve a smallish number of stats per mailbox command, we have to issue three mailbox commands in quick succession.  What we ran into was irqbalance coming in every 10 seconds and interrogating every network interface in the system and apparently doing this without holding RTNL.  But since other accesses under the RTNL could be using the mailbox registers we need to create an exclusion mechanism.
> 
>   We chose a simple first-come/first-served queue because there wasn't a need for anything more and we figured it would provide "fairness" in the presence of an abusive script, etc. (see below).  In reality, the number of mailbox access collisions is going to be very rare but we had to pick some upper bound for a timeout.  The original timeout was only found when a QA engineer was manically doing ifup/ifdown in a scripted llop in order to stress the system.
> 
>   And we picked four times the maximum mailbox execution timeout out of thin air.  Also not that the 10s maximum mailbox command execution timeout was setup for FPGA testing: the ASICs rarely takes more than a few milliseconds.  It would be completely reasonable to set up a lower bound for ASICs.  But again, mailbox timeout rarely happen in real life.
> 
>   And now that I'm reading the original bug report, I see that we ran into exactly the same problem with the Physical Function driver under the same exact test.  So this problem and its fix affect both drivers.
> 
> Casey
> 
> ________________________________________
> From: David Miller [davem@davemloft.net]
> Sent: Tuesday, April 14, 2015 11:40 AM
> To: Hariprasad S
> Cc: netdev@vger.kernel.org; Casey Leedom; Nirranjan Kirubaharan
> Subject: Re: [PATCH net] cxgb4vf: Implement mailbox access locking and list management
> 
> From: David Miller <davem@davemloft.net>
> Date: Tue, 14 Apr 2015 14:29:16 -0400 (EDT)
> 
> > From: Hariprasad Shenai <hariprasad@chelsio.com>
> > Date: Tue, 14 Apr 2015 18:00:45 +0530
> >
> >> +    for (i = 0; ; i += ms) {
> >> +            /* If we've waited too long, return a busy indication.  This
> >> +             * really ought to be based on our initial position in the
> >> +             * mailbox access list but this is a start.  We very rarely
> >> +             * contend on access to the mailbox ...
> >> +             */
> >> +            if (i > 4 * FW_CMD_MAX_TIMEOUT) {
> >
> > So you're going to sit here potentially polling for 40000 ms in a non-preemptable
> > context?
> >
> > I don't think so...

Will send a V2. Any guidance here would be of great help.

Thanks,
Hari

> 
> Also, you haven't really explained in the commit message what the real
> problem is and why the ordering of processing these messages matters
> so much and furthermore what might go wrong if things are processed
> out of order.
> 
> You have to assume I'm a complete idiot when I read your patches and
> it is your job to explain to someone with now knowledge of your driver
> or your hardware what you are doing.
> 
> 
