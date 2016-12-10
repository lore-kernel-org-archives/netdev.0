From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Soft lockup in inet_put_port on 4.6
Date: Fri, 09 Dec 2016 19:47:04 -0800
Message-ID: <1481341624.4930.204.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CALx6S36OVUqAxq9vNnfHp2eJOuG+gSSg896zzaZoc3Og4tyxFw@mail.gmail.com>
         <1481231024.1911284.813071977.72AF4DEE@webmail.messagingengine.com>
         <1481233016.11849.1@smtp.office365.com>
         <1481243432.4930.145.camel@edumazet-glaptop3.roam.corp.google.com>
         <6C6EE0ED-7E78-4866-8AAF-D75FD4719EF3@fb.com>
         <1481335192.3663.0@smtp.office365.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35371 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751888AbcLJDrH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 22:47:07 -0500
Received: by mail-pg0-f67.google.com with SMTP id p66so4151717pga.2
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 19:47:06 -0800 (PST)
In-Reply-To: <1481335192.3663.0@smtp.office365.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-12-09 at 20:59 -0500, Josef Bacik wrote:
> On Thu, Dec 8, 2016 at 8:01 PM, Josef Bacik <jbacik@fb.com> wrote:
> > 
> >>  On Dec 8, 2016, at 7:32 PM, Eric Dumazet <eric.dumazet@gmail.com> 
> >> wrote:
> >> 
> >>>  On Thu, 2016-12-08 at 16:36 -0500, Josef Bacik wrote:
> >>> 
> >>>  We can reproduce the problem at will, still trying to run down the
> >>>  problem.  I'll try and find one of the boxes that dumped a core 
> >>> and get
> >>>  a bt of everybody.  Thanks,
> >> 
> >>  OK, sounds good.
> >> 
> >>  I had a look and :
> >>  - could not spot a fix that came after 4.6.
> >>  - could not spot an obvious bug.
> >> 
> >>  Anything special in the program triggering the issue ?
> >>  SO_REUSEPORT and/or special socket options ?
> >> 
> > 
> > So they recently started using SO_REUSEPORT, that's what triggered 
> > it, if they don't use it then everything is fine.
> > 
> > I added some instrumentation for get_port to see if it was looping in 
> > there and none of my printk's triggered.  The softlockup messages are 
> > always on the inet_bind_bucket lock, sometimes in the process context 
> > in get_port or in the softirq context either through inet_put_port or 
> > inet_kill_twsk.  On the box that I have a coredump for there's only 
> > one processor in the inet code so I'm not sure what to make of that.  
> > That was a box from last week so I'll look at a more recent core and 
> > see if it's different.  Thanks,
> 
> Ok more investigation today, a few bullet points
> 
> - With all the debugging turned on the boxes seem to recover after 
> about a minute.  I'd get the spam of the soft lockup messages all on 
> the inet_bind_bucket, and then the box would be fine.
> - I looked at a core I had from before I started investigating things 
> and there's only one process trying to get the inet_bind_bucket of all 
> the 48 cpus.
> - I noticed that there was over 100k twsk's in that original core.
> - I put a global counter of the twsk's (since most of the softlockup 
> messages have the twsk timers in the stack) and noticed with the 
> debugging kernel it started around 16k twsk's and once it recovered it 
> was down to less than a thousand.  There's a jump where it goes from 8k 
> to 2k and then there's only one more softlockup message and the box is 
> fine.
> - This happens when we restart the service with the config option to 
> start using SO_REUSEPORT.
> 
> The application is our load balancing app, so obviously has lots of 
> connections opened at any given time.  What I'm wondering and will test 
> on Monday is if the SO_REUSEPORT change even matters, or if simply 
> restarting the service is what triggers the problem.  One thing I 
> forgot to mention is that it's also using TCP_FASTOPEN in both the 
> non-reuseport and reuseport variants.
> 
> What I suspect is happening is the service stops, all of the sockets it 
> had open go into TIMEWAIT with relatively the same timer period, and 
> then suddenly all wake up at the same time which coupled with the 
> massive amount of traffic that we see per box anyway results in so much 
> contention and ksoftirqd usage that the box livelocks for a while.  
> With the lock debugging and stuff turned on we aren't able to service 
> as much traffic so it recovers relatively quickly, whereas a normal 
> production kernel never recovers.
> 
> Please keep in mind that I"m a file system developer so my conclusions 
> may be completely insane, any guidance would be welcome.  I'll continue 
> hammering on this on Monday.  Thanks,

Hmm... Is your ephemeral port range includes the port your load
balancing app is using ?
