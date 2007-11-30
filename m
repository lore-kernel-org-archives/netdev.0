From: Samir Bellabes <sam@synack.fr>
Subject: Re: [PATCH net-2.6.25] Add packet filtering based on process'ssecurity context.
Date: Fri, 30 Nov 2007 17:07:31 +0100
Message-ID: <m2r6i71zuk.fsf@synack.fr>
References: <Xine.LNX.4.64.0711231005270.4252@us.intercode.com.au>
	<200711241114.FCJ30702.JSMOFQtVHFFOOL@I-love.SAKURA.ne.jp>
	<m2sl2p8x8e.fsf@synack.fr>
	<200711302307.EJD21822.JFFMQFSOOHLtVO@I-love.SAKURA.ne.jp>
	<m2k5nz3iyo.fsf@synack.fr>
	<200711302359.GGF60963.LtFFFHQVJOSOOM@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jmorris@namei.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-security-module@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org, sds@tycho.nsa.gov
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200711302359.GGF60963.LtFFFHQVJOSOOM@I-love.SAKURA.ne.jp>
	(Tetsuo Handa's message of "Fri, 30 Nov 2007 23:59:13 +0900")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:

> Hello.
>
> Samir Bellabes wrote:
>> at security_socket_accept(), the user only accept the fact that the
>> application is able to go to sock->ops->accept(). That's the purpose of
>> this hook.
> Yes. This hook can't perform filtering.

By "filtering", you should mean "packets filtring", shouldn't you ?
because this hook is able to deny the accept() syscall for a process, so
it's a kind of "filtring" too.

>> After, when packet are coming, we can catch them with
>> libnetfilter_queue, and deal with filtering packets.
> Is this performed inside sock->ops->accept()?

No, it's performed from the userspace. the goal is to don't touch the
network stack at all.
after accepting a successful security_socket_accept(), the processus
will wait for client. first packet will arrived. Here we do the
filtering, and give the ability to the user to deny packets.
Dropping the TCP SYN for a TCP connection, for example, then the
process don't see the connection arrived and was dropped.

Another important point which make me sure we should need to use the
libnetfilter_queue is that the we need to work with the conntrack tool
to automatically let some connections going throught the firewall.

One example, a ftp client will listen on a arbitrary port for the
incoming data channel. This job is already handle with the conntrack_ftp
extension by netfilter.
With your tool, you will have to learn the ftp client to let incoming
connection, reach this dynamic port, so does this mean, as it's dynamic,
to allow TCP port 1024-65535 ? 
With the approach of using the libnetfilter_queue, we can first put the
network packet inside the conntrack, let the packets in the RELATED
state going trought the firewall and be ACCEPTED, and for others
packets, let the user decide.

>> here we agree. *but* in my module, the user don't judge before
>> sock->ops->accept(). He judges when packets are coming, throught the
>> libnetfilter_queue API, in userspace, and reinject packet if it's ok.
> I didn't understand what is happening.
> Is there a hook which can perform filtering inside sock->ops->accept()?

I'm not speaking anymore about socket filtering inside
sock->aps->accept(). I do filtering for sock->aps->accept() with the
netfilter tool, by handling packets directly.
So there's two thing, first dealing with socket filtering for socket(),
bind(), listen(), accept() (just to let application to have the right to
execute the syscall)
Then for managing the data inside the connection, I will use the packet
by packet way, with netfilter and libnetfilter_queue.

I really need time to made a real release, to show code. I will take it.

regards,
sam
