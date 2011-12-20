From: Shriram Rajagopalan <rshriram@cs.ubc.ca>
Subject: Re: [PATCH] net/sched: sch_plug - Queue traffic until an explicit
 release command
Date: Tue, 20 Dec 2011 11:05:56 -0600
Message-ID: <CAP8mzPNmqPjmYZHT5d21D1yjz293wF+EF0BwoMAu+M=7VtHHSg@mail.gmail.com>
References: <1324329752-28459-1-git-send-email-rshriram@cs.ubc.ca> <1324391902.17751.227.camel@mojatatu>
Reply-To: rshriram@cs.ubc.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Brendan Cully <brendan@cs.ubc.ca>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.cs.ubc.ca ([142.103.6.52]:39825 "EHLO smtp.cs.ubc.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751407Ab1LTRGl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 12:06:41 -0500
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	(authenticated bits=0)
	by smtp.cs.ubc.ca (8.14.3/8.13.6) with ESMTP id pBKH6c2p002100
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 20 Dec 2011 09:06:39 -0800
Received: by eekc4 with SMTP id c4so6733756eek.19
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2011 09:06:37 -0800 (PST)
In-Reply-To: <1324391902.17751.227.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 20, 2011 at 8:38 AM, Jamal Hadi Salim <jhs@mojatatu.com> wr=
ote:
>
> Sorry - I didnt see your earlier CC. Cyberus.ca is probably the
> worst service provider in Canada (maybe the world; i am sure there
> are better ISPs in the middle of an ocean somewhere, deep underwater
> probably).
>
> On Mon, 2011-12-19 at 13:22 -0800, rshriram@cs.ubc.ca wrote:
>> This qdisc can be used to implement output buffering, an essential
>> functionality required for consistent recovery in checkpoint based
>> fault tolerance systems.
>
> I am trying to figure where this qdisc runs - is it in the hypervisor=
?
>

In dom0. Basically the setup is like this:
 Guest (veth0)
 dom0 (vif0.0 --> eth0)

   packets coming out of veth0 appear as incoming packets in vif0.0
 Once Remus (or any other output commit style system is started)
 the following commands could be executed in dom0, to activate this qdi=
sc
 ip link set ifb0 up
 tc qdisc add dev vif0.0 ingress
 tc filter add dev vif0.0 parent ffff: proto ip pref 10 u32 match u32
0 0 action mirred egress redirect dev eth0


>> The qdisc supports two operations - plug and
>> unplug. When the qdisc receives a plug command via netlink request,
>> packets arriving henceforth are buffered until a corresponding unplu=
g
>> command is received.
>
> Ok, so plug indicates "start of checkpoint" and unplug the end.
> Seems all you want is at a certain point to throttle the qdisc and
> later on unplug/unthrottle, correct?
> Sounds to me like a generic problem that applies to all qdiscs?
>

Oh yes. But throttle functionality doesnt seem to be implemented
in the qdisc code base. there is a throttle flag but looking at the
qdisc scheduler, I could see no references to this flag or related acti=
ons.
That is why in the dequeue function, I return NULL until the release po=
inter
is set.

And we need a couple of netlink api calls (PLUG/UNPLUG) to manipulate
the qdisc from userspace

>> Its intention is to support speculative execution by allowing genera=
ted
>> network traffic to be rolled back. It is used to provide network
>> protection for domUs in the Remus high availability project, availab=
le as
>> part of Xen. This module is generic enough to be used by any other
>> system that wishes to add speculative execution and output buffering=
 to
>> its applications.
>
> Should get a nice demo effect of showing a simple ping working with
> zero drops,

I have done better. When Remus is activated for a Guest VM, I pull the
plug from the primary physical host and the ssh connection to the domU,
with top command running (and/or xeyes) continues to run seamlessly. ;)

>but: what is the effect of not even having this qdisc?

When the guest VM recovers on another physical host, it is restored to =
the
most recent checkpoint. With a checkpoint frequency of 25ms, in the wor=
st case
on failover, one checkpoint worth of execution could be lost. With the =
loss of
the physical machine and its output buffer, the packets (tcp,udp, etc)
are also lost.

But that does not affect the "consistency" of the state of Guest and
client connections,
as the client (say TCP clients) only think that there was some packet
loss and "resend"
the packets. The resuming Guest VM on the backup host would pickup the
connection
from where it left off.

OTOH, if the packets were released before the checkpoint was done,
then we have the
classic orphaned messages problem. If the client and the Guest VM
exchange a bunch
of packets, the TCP window moves. When the Guest VM resumes on the back=
up host,
it is basically rolled back in time (by 25ms or so), i.e. it does not
know about the shift
in the tcp window. Hence, the client and Guest's tcp sequence numbers
would be out of
sync and the connection would hang. For other protocols like UDP etc,
the "unmodified"
client may be capable of handling packet losses but not the server
application forgetting
about stuff it had acknowledged.


> If you just switch the qdisc to a sleeping state from user space, all
> packets arriving at that qdisc will be dropped during the checkpoint
> phase (and the kernel code will be tiny or none).

Which we dont want. I want to buffer the packets and then release them
once the checkpoint is committed at the backup host.

> If you do nothing some packets will be buffered and a watchdog
> will recover them when conditions become right.

Doing nothing is sort of what this qdisc does, so that the packets
get buffered. The watchdog in this case is the user space process
that sends the netlink command UNPLUG to release the packets.
(aka conditions become right).

One could do this with any qdisc but the catch here is that the qdisc
stops releasing packets only when it hits the stop pointer (ie start of
the next checkpoint buffer). Simply putting a qdisc to sleep would
prevent it from releasing packets from the current buffer (whose checkp=
oint
has been acked).


> So does this qdisc add anything different?
>
> [Note: In your case when arriving packets find the queue filled up
> you will drop lotsa packets - depending on traffic patterns; so
> not much different than above]
>
>> +
>> +#define FIFO_BUF =A0 =A0(10*1024*1024)
>
> Aha.
> Technically - use tc to do this. Conceptually:
> This is probably what makes you look good in a demo if you have one;
> huge freaking buffer. If you are doing a simple ping (or a simple
> interactive session like ssh) and you can failover in 5 minutes you
> still wont be able to fill that buffer!
>

I agree. Its more sensible to configure it via the tc command. I would
probably have to end up issuing patches for the tc code base too.

> Look at the other feedback given to you (Stephen and Dave responded).
>
> If a qdisc is needed, should it not be a classful qdisc?
>

I dont understand. why ?

shriram

> cheers,
> jamal
>
