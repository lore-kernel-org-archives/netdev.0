From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: After many hours all outbound connections get stuck in SYN_SENT
Date: Wed, 19 Dec 2007 14:54:51 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712191424360.31652@kivilampi-30.cs.helsinki.fi>
References: <83a51e120712160834r29112fb0xa1f61c35f180bf8f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: James Nichols <jamesnichols3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43960 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092AbXLSMyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 07:54:53 -0500
In-Reply-To: <83a51e120712160834r29112fb0xa1f61c35f180bf8f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Dec 2007, James Nichols wrote:

> I have a Java application that makes a large number of outbound
> webservice calls over HTTP/TCP.  The hosts contacted are a fixed set
> of about 2000 hosts and a web service call is made to each of them
> approximately every 5 mintues by a pool of 200 Java threads.  Over
> time, on average a percentage of these hosts are unreachable for one
> reason or another, usually because they are on wireless cell phone
> NICs, so there is a persistent count of sockets in the SYN_SENT state
> in the range of about 60-80.  This is fine, as these failed connection
> attempts eventually time out.
> 
> However, after approximately 38 hours of operation, all outbound
> connection attempts get stuck in the SYN_SENT state.  It happens
> instantaneously, where I go from the baseline of about 60-80 sockets
> in SYN_SENT to a count of 200 (corresponding to the # of java threads
> that make these calls).
> 
> When I stop and start the Java application, all the new outbound
> connections still get stuck in SYN_SENT state.

Is it so that they don't timeout at all? You can collect some of their 
state from /proc/net/tcp (shows at least timers and attempt counters)....

> During this time, I am
> still able to SSH to the box and run wget to Google, cnn, etc, so the
> problem appears to be specific to the hosts that I'm accessing via the
> webservices.

Are you sure that you just don't get unlucky at some point of time and 
all 200 available threads are just temporarily stuck and your application 
is just very slowly progressing then?

> For a long time, the only thing that would resolve this was rebooting
> the entire machine.  Once I did this, the outbound connections could
> be made succesfully.

To the very same hosts? Or to another set of hosts?

> However, very recently when I had once of these incidents I disabled 
> tcp_sack via:
> 
> echo "0" > /proc/sys/net/ipv4/tcp_sack
> 
> And the problem almost instanteaously resolved itself and outbound
> connection attempts were succesful.

New or the pending ones?

> I hadn't attempted this before because I assumed that if any of my 
> network
> equipment or remote hosts had a problem with SACK, that it would never
> work.

Many bugs just are not like that at all... Usually people who coded things 
had at least some clue :-), so things work "almost correctly"...

>  In my case, it worked fine for about 38 hours before hitting a
> wall where no outbound connections could be made.

How accurate number? Is the lockup somehow related to daytime cycle?

> Is there a kernel buffer or some data structure that tcp_sack uses
> that gets filled up after an extended period of operation?

SACK has pretty little meaning in context of SYNs, there's only the 
sackperm(itted) TCP option which is sent along with the SYN/SYN-ACK.

The SACK scoreboard is currently included to the skbs (has been like 
this for very long time), so no additional data structures should be
there because of SACK...

> How can I debug this problem in the kernel to find out what the root cause is?
> 
> I emailed linux-kernel and they asked for output of netstat -s, I can
> get this the next
> time it occurs- any other usefull data to collect?

/proc/net/tcp couple of times in a row, try something something like
this:

for i in (seq 1 40); do cat /proc/net/tcp; echo "-----"; sleep 10; done


> I'm running kernel 2.6.18 on RedHat, but have had this problem occur
> on earlier kernel versions (all 2.4 and 2.6).

I've done some fixes to SACK processing since 2.6.18 (not sure if RedHat 
has backported them). Though they're not that critical nor anything in 
them should affect in SYN_SENT state.


-- 
 i.
