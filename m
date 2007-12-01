From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH net-2.6.25] Add packet filtering based on process'ssecurity context.
Date: Sat, 1 Dec 2007 12:48:42 +0900
Message-ID: <200712011248.EJE13060.FFQOOJtOVFSLHM@I-love.SAKURA.ne.jp>
References: <m2sl2p8x8e.fsf@synack.fr>
	<200711302307.EJD21822.JFFMQFSOOHLtVO@I-love.SAKURA.ne.jp>
	<m2k5nz3iyo.fsf@synack.fr>
	<200711302359.GGF60963.LtFFFHQVJOSOOM@I-love.SAKURA.ne.jp>
	<m2r6i71zuk.fsf@synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jmorris@namei.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-security-module@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org, sds@tycho.nsa.gov
To: sam@synack.fr
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <m2r6i71zuk.fsf@synack.fr>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Thank you for detailed explanation.

Samir Bellabes wrote:
> By "filtering", you should mean "packets filtring", shouldn't you ?
> because this hook is able to deny the accept() syscall for a process, so
> it's a kind of "filtring" too.
Yes, you are right.

> No, it's performed from the userspace. the goal is to don't touch the
> network stack at all.
OK. One thing I'm worrying.
Use of userspace process assumes that it shall not be killed by some reason
(SIGKILL or OOM-killer or something).
What happens if userspace process is dead?
TOMOYO wants to continue packet filtering functionality even if userspace process is dead.
So, TOMOYO loads all filtering rules inside kernel and performs filtering inside kernel.

TOMOYO's goals are
(1) perform simple stateless packet filtering without any assistance outside the kernel
(2) provide simple approach for people (including me) who disable iptables
    or worry the correctness of configurations because of very complicated syntax.
    (Many users disable both iptables/SELinux inside local network because
    their very-very-flexible-configurations give them a headache.)
(3) allow people describe per-an-application firewall rules in understandable syntax.

> Dropping the TCP SYN for a TCP connection, for example, then the
> process don't see the connection arrived and was dropped.
That's an advantage.
Making select() not to say "ready to accept" is what TOMOYO wants
(although it is very difficult to do so because of (3)).

> With your tool, you will have to learn the ftp client to let incoming
> connection, reach this dynamic port, so does this mean, as it's dynamic,
> to allow TCP port 1024-65535 ?
Yes. Users add lines like

 <kernel> /usr/sbin/vsftpd
 allow_network TCP accept xxx.xxx.xxx.xxx-yyy.yyy.yyy.yyy 1024-65535

which means "/usr/sbin/vsftpd is able to accept incoming TCP connections
if source IP address is between xxx.xxx.xxx.xxx-yyy.yyy.yyy.yyy and
source port is between 1024-65535" and

 <kernel> ... /usr/bin/ftp
 allow_network TCP accept zzz.zzz.zzz.zzz 1024-65535

which means "/usr/bin/ftp is able to accept incoming TCP connections if
source IP address is zzz.zzz.zzz.zzz and source port is between 1024-65535".
Users have to add explicitly, but it is very easy and understandable.

> I'm not speaking anymore about socket filtering inside
> sock->aps->accept(). I do filtering for sock->aps->accept() with the
> netfilter tool, by handling packets directly.
For TOMOYO, (3) is more important than making select() not to say "ready to accept".
Packet filtering without knowing the program's name who picks up this connection is not a TOMOYO's goal.
So, TOMOYO still wants to do filtering inside sock->aps->accept() or security_socket_post_accept().

Thank you.

