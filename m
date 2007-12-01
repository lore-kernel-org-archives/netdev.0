From: Samir Bellabes <sam@synack.fr>
Subject: Re: [PATCH net-2.6.25] Add packet filtering based on process'ssecurity context.
Date: Sat, 01 Dec 2007 08:18:52 +0100
Message-ID: <m2hcj22883.fsf@synack.fr>
References: <m2sl2p8x8e.fsf@synack.fr>
	<200711302307.EJD21822.JFFMQFSOOHLtVO@I-love.SAKURA.ne.jp>
	<m2k5nz3iyo.fsf@synack.fr>
	<200711302359.GGF60963.LtFFFHQVJOSOOM@I-love.SAKURA.ne.jp>
	<m2r6i71zuk.fsf@synack.fr>
	<200712011248.EJE13060.FFQOOJtOVFSLHM@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jmorris@namei.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-security-module@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org, sds@tycho.nsa.gov
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200712011248.EJE13060.FFQOOJtOVFSLHM@I-love.SAKURA.ne.jp>
	(Tetsuo Handa's message of "Sat, 1 Dec 2007 12:48:42 +0900")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:

> Hello.
> Thank you for detailed explanation.
> Samir Bellabes wrote:
>
>> No, it's performed from the userspace. the goal is to don't touch the
>> network stack at all.
> OK. One thing I'm worrying.
> Use of userspace process assumes that it shall not be killed by some reason
> (SIGKILL or OOM-killer or something).
> What happens if userspace process is dead?

here is the way:
1. a syscall is executed.
2. we send the informations to userspace daemon, and we are waiting for
   what I'm calling a "verdict" on it, there is of course a timer on
   that.
3. userspace daemon asks user - or something that TOMOYO don't seems to
   handle because it's living all in the kernel, a automatic decision
   process, throught a database rules, a XML file rules, etc.. 
4. userspace daemon give its verdict.
5. kernel execute the verdict.

Now, what if the userspace daemon died. There's 2 possibilities for the
moment.

1/ apply a DEFAULT_POLICY after timer expires. this default verdict are
   - DENY
   - GRANT
   - NOTIFY (in kernel log)
   - DELAY (with a fixed limit time). 

2/ something I'm currently designing, is to keep a cache of
rules/decision in the kernel part. The goal is that the system will
auto-learn about the decision of the user, and keep rules decisions
somewhere (database, XML file, ..). When starting, we put this rules
inside the kernel cache rules.
When a event occures (syscall):
   - we are looking for a macthe in the cached rules.
   - if we don't have a verdict in this cache, we are going to ask the
     userspace part for a verdict in this case, and save the decision
     for same matched conditions

When a new rules is applied, deleted or modified for userspace, we are
updating the kernel cache in real-time.
I want to have a tool nearly working as iptables for netfilter rules,
what I mean is that the "brain"/decision part is in the userspace, not
in the kernel.

there is also other reasons to that last point, because with all the
informations coming from the networking event like networking syscalls,
network packets, we can do more than a personnal security tool, we can
do with minimal cost:
    - monitoring, just save the network events (already done)
    - taking others "network decisions" : adding route inside the
      network, auto-mount distant filesystem, starting distant services
      (I have no shame to said that is currently a really big dream :)

> TOMOYO wants to continue packet filtering functionality even if userspace process is dead.
> So, TOMOYO loads all filtering rules inside kernel and performs
> filtering inside kernel.

Yes, as I said this is also something I want to do.

> TOMOYO's goals are
> (1) perform simple stateless packet filtering without any assistance
> outside the kernel

what differences between you approach and netfilter in this case ? if
it's about packet filtering, you already have all you wishes in
netfilter project.

> (2) provide simple approach for people (including me) who disable iptables
>     or worry the correctness of configurations because of very complicated syntax.
>     (Many users disable both iptables/SELinux inside local network because
>     their very-very-flexible-configurations give them a headache.)

No. I'm sorry you can't disable iptables in your model.

security :
what about crafted/bad/bogus packets ? what about stealth scans ?
netfilter is here to protect from this.

usuability:
what about forwarding ?
My goal is that someone having a gateway and a LAN box, he can, by
starting a service which is listening, on the LAN box, automatically
have a forwarding rule added to the gateway, for its service, the time
the process service is living.
It's the same for someone executing a connect() from the LAN to a
outside web service, we are dectecting this syscall, a put a rule on the
gateway to authorize the outgoing forwarding

It's also true for the DMZ, ie start sshd, then we are detecting the
listen() in sshd process, and we are putting a forwarding rule on the
router.
Think about the target is projects like linux-embedded routers.

> (3) allow people describe per-an-application firewall rules in
> understandable syntax.
Yes, that was also my starting point too. helping basics users.

>> Dropping the TCP SYN for a TCP connection, for example, then the
>> process don't see the connection arrived and was dropped.
> That's an advantage.
> Making select() not to say "ready to accept" is what TOMOYO wants
> (although it is very difficult to do so because of (3)).

thanks.

>> With your tool, you will have to learn the ftp client to let incoming
>> connection, reach this dynamic port, so does this mean, as it's dynamic,
>> to allow TCP port 1024-65535 ?
>
>  <kernel> ... /usr/bin/ftp
>  allow_network TCP accept zzz.zzz.zzz.zzz 1024-65535
>
> which means "/usr/bin/ftp is able to accept incoming TCP connections if
> source IP address is zzz.zzz.zzz.zzz and source port is between 1024-65535".
> Users have to add explicitly, but it is very easy and understandable.

so we are losing in granularity against the netfilter conntrack in this
case, because the conntrack will get the exact listening port, and not
all the unprivileged port.
We have to use the conntrack tool, first to continue having all the
existing features (like transparently get a RELATED connection working),
second because the libnetfilter_queue is the place to deal with packets,
and yes, if you want to filtering packets, there only one possibility
for the moment, netfilter.

What is really important with this new way of filtering is the win
regarding the granularity. With netfiler it's basically : IP/port src,
IP/port dst, protocol.
My view is to always have 2 more dimensions : userid and process, and
never fall inside a less granular case.

>> I'm not speaking anymore about socket filtering inside
>> sock->aps->accept(). I do filtering for sock->aps->accept() with the
>> netfilter tool, by handling packets directly.
> For TOMOYO, (3) is more important than making select() not to say "ready to accept".
> Packet filtering without knowing the program's name who picks up this connection is not a TOMOYO's goal.
> So, TOMOYO still wants to do filtering inside sock->aps->accept() or security_socket_post_accept().

ok, same goals, differents ways.

thanks for this discussion, it's really interesting to share the same idea.
regards
sam
