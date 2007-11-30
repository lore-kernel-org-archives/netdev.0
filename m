From: Samir Bellabes <sam@synack.fr>
Subject: Re: [PATCH net-2.6.25] Add packet filtering based on process'ssecurity context.
Date: Fri, 30 Nov 2007 15:29:19 +0100
Message-ID: <m2k5nz3iyo.fsf@synack.fr>
References: <200711212130.EJJ43745.LFOFHOSMJOtFVQ@I-love.SAKURA.ne.jp>
	<200711222235.GCA05378.HtMOJQVFSFOLFO@I-love.SAKURA.ne.jp>
	<Xine.LNX.4.64.0711231005270.4252@us.intercode.com.au>
	<200711241114.FCJ30702.JSMOFQtVHFFOOL@I-love.SAKURA.ne.jp>
	<m2sl2p8x8e.fsf@synack.fr>
	<200711302307.EJD21822.JFFMQFSOOHLtVO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jmorris@namei.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-security-module@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org, sds@tycho.nsa.gov
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200711302307.EJD21822.JFFMQFSOOHLtVO@I-love.SAKURA.ne.jp>
	(Tetsuo Handa's message of "Fri, 30 Nov 2007 23:07:19 +0900")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:

> Hello.
>
> Thank you for feedback.
>
> I have some questions.
>
> (1) Your module uses "struct security_operations" and
>     is registered with register_security().
>
>     TOMOYO also uses "struct security_operations" and
>     must be registered with register_security().
>
>     Can your module and TOMOYO coexist?

Not sure about that.
I already had concerns about the coexistance of my module and SELinux.
I have to take time for that.

> (2) Can your module handle incoming UDP's datagram too?

yes, and better.
In fact, information is not dependant of the protocol at all.
What I mean is that we focus on network's syscalls, so for me, protocol
informations is let to the user for his/her decision.
When the module is catching bind(), we don't care if it's
TCP/DCCP/UDP/. What I care is to give the procotol information to the
user, to let him decide.

> (3) How do you handle race window between security_socket_accept()
>     and sock->ops->accept()?
>
> Samir Bellabes wrote:
>> My approach is to get the informations regarding the socket from
>> socket(), bind() and and accept() syscalls hooks.
>> Pushing this informations to userspace. Here the user can refuse or
>> accept the sycalls.
>
>     If a socket is shared by multiple processes and
>     the user said "Accept this connection" at security_socket_accept(),
>     the process does not always pick up what the user wanted to pick up
>     because there is no mutex between security_socket_accept() and
>     sock->ops->accept().

at security_socket_accept(), the user only accept the fact that the
application is able to go to sock->ops->accept(). That's the purpose of
this hook.

After, when packet are coming, we can catch them with
libnetfilter_queue, and deal with filtering packets.

> (4) If (3) is my misunderstanding (i.e. the user doesn't judge at security_socket_accept()),
>     it means that the user judges it before select() says "ready to accept".
>     Then ... what happens if a socket is shared by multiple programs?
>     The user has to judge without knowing which program will pick up this connection.
>     TOMOYO lets the user judge whether to accept or not
>     with knowing the program's name who picks up this connection.
>
> I think getting information at socket(), bind() and accept() is helpful for detailed judgement,
> but I think it doesn't solve race problem as long as the user judges *before* sock->ops->accept().

here we agree. *but* in my module, the user don't judge before
sock->ops->accept(). He judges when packets are coming, throught the
libnetfilter_queue API, in userspace, and reinject packet if it's ok.

We are really trying to do the same thing, but I'm almost sure this can
be achieved with existing tool in fact, and put more "decision code" in
the userspace, and only keep a managing/detecting tool in the kernelspace.

regards,
sam
