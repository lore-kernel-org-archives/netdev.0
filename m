From: Luca Deri <deri@ntop.org>
Subject: Re: Luca Deri's paper: Improving Passive Packet Capture: Beyond Device
 Polling
Date: Tue, 06 Apr 2004 14:25:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4072A1CD.8070905@ntop.org>
References: <20040330142354.GA17671@outblaze.com> <1081033332.2037.61.camel@jzny.localdomain> <c4rvvv$dbf$1@sea.gmane.org> <407286BB.8080107@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Jason Lunz <lunz@falooley.org>, netdev@oss.sgi.com, cpw@lanl.gov,
        ntop-misc@fuji.unipi.it
Return-path: <netdev-bounce@oss.sgi.com>
To: P@draigBrady.com
In-Reply-To: <407286BB.8080107@draigBrady.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,
the problem with libpcap-mmap is that:
- it does not reduce the journey of the packet from NIC to userland=20
beside the last part of it (syscall replaced with mmap). This has a=20
negative impact on the overall performance.
- it does not feature things like kernel packet sampling that pushes=20
people to fetch all the packets out of a NIC then discard most of them=20
(i.e. CPU cycles not very well spent). Somehow this is a limitation of=20
pcap that does not feature a pcap_sample call.

In addition if you do care about performance, I believe you're willing=20
to turn off packet transmission and only do packet receive.=20
Unfortunately I have no access to a "real" traffic generator (I use a PC=20
as traffic generator). However if you read my paper you can see that=20
with a Pentium IV 1.7 you can capture over 500'000 pkt/sec, so in your=20
setup (Xeon + Spirent) you can have better figures.

IRQ: Linux has far too much latency, in particular at high speeds. I'm=20
not the right person who can say "this is the way to go", however I=20
believe that we need some sort of interrupt prioritization like RTIRQ doe=
s.

FYI, I've just polished the code and added kernel packet filtering to=20
PF_RING. As soon as I have completed my tests I will release a new versio=
n.

Finally It would be nice to have in the standard Linux core some packet=20
capture improvements. It could either be based on my work or on somebody=20
else's work. It doesn't really matter as long as Linux gets faster.

Cheers, Luca


P@draigBrady.com wrote:

> Jason Lunz wrote:
>
>> hadi@cyberus.ca said:
>>
>>> Jason Lunz actually seemed to have been doing more work on this and
>>> e1000 - he could provide better perfomance numbers.
>>
>>
>>
>> Well, not really. What I have is still available at:
>>
>> http://gtf.org/lunz/linux/net/perf/
>>
>> ...but those are mainly measurements of very outdated versions of the
>> e1000 napi driver backported to 2.4, running on 1.8Ghz Xeon systems.
>> That work hasn't really been kept up to date, I'm afraid.
>>
>>
>>> It should also be noted that infact packet mmap already uses rings.
>>
>>
>>
>> Yes, I read the paper (but not his code). What stood out to me is that
>> the description of his custom socket implementation matches exactly wh=
at
>> packet-mmap already is.
>>
>> I noticed he only mentioned testing of libpcap-mmap, but did not use
>> mmap packet sockets directly -- maybe there's something about libpcap
>> that limits performance? I haven't looked.
>
>
> That's my experience. I'm thinking of redoing libpcap-mmap completely
> as it has huge amounts of statistics messing in the fast path.
> Also the ring gets corrupted if packets are being received while
> the ring buffer is being setup.
>
> I've a patch for http://public.lanl.gov/cpw/libpcap-0.8.030808.tar.gz
> here: http://www.pixelbeat.org/patches/libpcap-0.8.030808-pb.diff
> (you need to compile with PB defined)
> Note this only addresses the speed issue.
> Also there are newer versions of libpcap-mmap available which I
> haven't looked at yet.
>
>> What I can say for sure is that the napi + packet-mmap performance wit=
h
>> many small packets is almost surely limited by problems with irq/softi=
rq
>> load. There was an excellent thread last week about this with Andrea
>> Arcangeli, Robert Olsson and others about the balancing of softirq and
>> userspace load; they eventually were beginning to agree that running
>> softirqs on return from hardirq and bh was a bigger load than expected
>> when there was lots of napi work to do. So despite NAPI, too much kern=
el
>> time is spent handling (soft)irq load with many small packets.
>
>
> agreed.
>
>> It appears this problem became worse in 2.6 with HZ=3D1000, because no=
w
>> the napi rx softirq work is being done 10X as much on return from the
>> timer interrupt.  I'm not sure if a solution was reached.
>
>
> P=E1draig
> .



--=20
Luca Deri <deri@ntop.org>	http://luca.ntop.org/
Hacker: someone who loves to program and enjoys being
clever about it - Richard Stallman
