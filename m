From: Jason Lunz <lunz@falooley.org>
Subject: Re: Luca Deri's paper: Improving Passive Packet Capture: Beyond Device Polling
Date: Mon, 5 Apr 2004 16:03:11 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <c4rvvv$dbf$1@sea.gmane.org>
References: <20040330142354.GA17671@outblaze.com> <1081033332.2037.61.camel@jzny.localdomain>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hadi@cyberus.ca said:
> Jason Lunz actually seemed to have been doing more work on this and
> e1000 - he could provide better perfomance numbers.

Well, not really. What I have is still available at:

http://gtf.org/lunz/linux/net/perf/

...but those are mainly measurements of very outdated versions of the
e1000 napi driver backported to 2.4, running on 1.8Ghz Xeon systems.
That work hasn't really been kept up to date, I'm afraid.

> It should also be noted that infact packet mmap already uses rings.

Yes, I read the paper (but not his code). What stood out to me is that
the description of his custom socket implementation matches exactly what
packet-mmap already is.

I noticed he only mentioned testing of libpcap-mmap, but did not use
mmap packet sockets directly -- maybe there's something about libpcap
that limits performance? I haven't looked.

What I can say for sure is that the napi + packet-mmap performance with
many small packets is almost surely limited by problems with irq/softirq
load. There was an excellent thread last week about this with Andrea
Arcangeli, Robert Olsson and others about the balancing of softirq and
userspace load; they eventually were beginning to agree that running
softirqs on return from hardirq and bh was a bigger load than expected
when there was lots of napi work to do. So despite NAPI, too much kernel
time is spent handling (soft)irq load with many small packets.

It appears this problem became worse in 2.6 with HZ=1000, because now
the napi rx softirq work is being done 10X as much on return from the
timer interrupt.  I'm not sure if a solution was reached.

Jason
