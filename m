From: "James Nichols" <jamesnichols3@gmail.com>
Subject: Re: After many hours all outbound connections get stuck in SYN_SENT
Date: Wed, 19 Dec 2007 12:38:09 -0500
Message-ID: <83a51e120712190938j7c7a2c23xbe5c9da050d9956@mail.gmail.com>
References: <83a51e120712160834r29112fb0xa1f61c35f180bf8f@mail.gmail.com>
	 <Pine.LNX.4.64.0712191424360.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:57186 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752569AbXLSRiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 12:38:10 -0500
Received: by nf-out-0910.google.com with SMTP id g13so1603089nfb.21
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 09:38:09 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0712191424360.31652@kivilampi-30.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > When I stop and start the Java application, all the new outbound
> > connections still get stuck in SYN_SENT state.
>
> Is it so that they don't timeout at all? You can collect some of their
> state from /proc/net/tcp (shows at least timers and attempt counters)....

The outbound connections to timeout.  I've watched that they send
tcp_syn_retries SYN packets before eventually timing out.



> Are you sure that you just don't get unlucky at some point of time and
> all 200 available threads are just temporarily stuck and your application
> is just very slowly progressing then?

Yeah, I'm sure that it isn't an unlucky point of time.  If I restart
the application when this problem occurs, all the outbound connections
still fail.


> > For a long time, the only thing that would resolve this was rebooting
> > the entire machine.  Once I did this, the outbound connections could
> > be made succesfully.
>
> To the very same hosts? Or to another set of hosts?

Yes, to the same exact set of hosts.



> > And the problem almost instanteaously resolved itself and outbound
> > connection attempts were succesful.
>
> New or the pending ones?

I'm fairly sure that sockets that were already open in SYN_SENT state
when I turned tcp_sack off started to work as the count of sockets in
SYN_SENT state drops very rapidly.


> >  In my case, it worked fine for about 38 hours before hitting a
> > wall where no outbound connections could be made.
>
> How accurate number? Is the lockup somehow related to daytime cycle?

It is 38 hours +/- a half hour or so.  It isn't related to the time of
day, as it happens through out day/night depending on when the server
was restarted.  A new developement in this area is that after the
first 38 hours of system time the problem would occur, so I disable
tcp_sack and the problem clears itself up and outbound connections are
succesful.  After a couple of hours I re-enable tcp_sack and the next
SYN_SENT issue doesn't occur until more than 50 hours later (so like
90 hours after system start).  It's as if the first time it occurs and
I turn tcp_sack off, it doesn't just reset the clock another 38 hours,
but gives even more time until the problem occurs again.




> > Is there a kernel buffer or some data structure that tcp_sack uses
> > that gets filled up after an extended period of operation?
>
> SACK has pretty little meaning in context of SYNs, there's only the
> sackperm(itted) TCP option which is sent along with the SYN/SYN-ACK.
>
> The SACK scoreboard is currently included to the skbs (has been like
> this for very long time), so no additional data structures should be
> there because of SACK...

I've been seeing this problem for about 4 years, so could it be
related to the scoreboard implementation somehow?



> /proc/net/tcp couple of times in a row, try something something like
> this:
>
> for i in (seq 1 40); do cat /proc/net/tcp; echo "-----"; sleep 10; done

I can set up to do this the next time the problem occurs.


> > I'm running kernel 2.6.18 on RedHat, but have had this problem occur
> > on earlier kernel versions (all 2.4 and 2.6).
>
> I've done some fixes to SACK processing since 2.6.18 (not sure if RedHat
> has backported them). Though they're not that critical nor anything in
> them should affect in SYN_SENT state.

Ok, unless there is direct evidence that there is a fix to this
problem in a later kernel I won't be able to upgrade.  If there is a
redhat provided patch I can probably do that.
