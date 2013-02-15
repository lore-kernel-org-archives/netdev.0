From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp: sysctl to disable TCP simultaneous connect
Date: Fri, 15 Feb 2013 11:47:35 +0100
Message-ID: <20130215104735.GD9300@1wt.eu>
References: <20130207175240.GA12520@www.outflux.net> <20130207103950.662698ea@nehalam.linuxnetplumber.net> <CAGXu5jJiupzommJYPEYQnk-4i9FUKai0NcPnihLN-QpWV64jtQ@mail.gmail.com> <87y5eq87pa.fsf@xmission.com> <CAGXu5jJKQSDo61TD0Jgn9Gq8TL2rCUVbA=Kq4AvfeFUb2FdJMw@mail.gmail.com> <87r4ki6oi1.fsf@xmission.com> <20130215075539.GB7535@1wt.eu> <87621tyikg.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook@chromium.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Rob Landley <rob@landley.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Yuchung Cheng <ycheng@google.com>,
	Shan Wei <davidshan@tencent.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87621tyikg.fsf@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Fri, Feb 15, 2013 at 02:31:27AM -0800, Eric W. Biederman wrote:
> > I'm not saying this will
> > not eventually happen, but there are significant risks associated with
> > this feature.  Netfilter had this in the window tracking patches around
> > 2002-2003 and this had to be reverted because a client was able to establish
> > complete connections by sending SYN-SYN/ACK-ACK itself. Other products will
> > fall through these cracks.
> 
> Interesting.  It works for me here on 3.8.
> 
> I was able to get two machines to perform a simultaneous TCP open and
> successfully pass each other a message.

I'm not surprized, I've been doing demos of this that using netcat as well.

> Between those two machines were to NAT routers use conntrack ip
> masquerading.

If these NAT routers were recent enough linux kernels, that should work
as last I checked, this was reintroduced differently in netfilter (I don't
know when BTW), but with direction controls to avoid the original issue.
Still since the discovery of this issue in 2002, I've been used to check
for this support in many firewall products and load balancers I tested,
and I've yet to find one which supports this.

> Those two NAT routers were connected by a third router that just routed
> their between their public addresses.
> 
> Well strictly speaking they were network namespaces created with
> ip netns add .. and connected by veth tunnels, but it still worked
> and it definitely exercised the proper code paths.
> 
> > And last but not least, it's the only behaviour in TCP which allows a
> > random attacker to prevent a connection from establishing by guessing
> > only a 16-bit port, regardless of any sequence number. Considering how
> > we've been bothered by people who considered that our sequence numbers
> > were not random enough, I already expect that the absolute lack of need
> > of a sequence number will bring new funny articles.
> 
> I don't quite understand the DOS potential.  Is the problem the attacker
> makes it look like a different connection has already suceeded so that
> legitimate connections get a RST?

The memories I have about this were that once the attacker managed to send
its SYN to the victim, the socket switched to SYN-RECV with an ack value
corresponding to the attacker's seq and definitely refused any valid SYN-ACK
from the expected server.

> I'm not clear how that differs in practice in DoS potential from simply
> spoofing a SYN to a listening port.

This is a DoS in that you prevent a client from establishing a connection
without having to guess a sequence number. Clients cannot use SYN cookies
nor any such mechanism here to protect against such spoofed SYNs. And in
practice it's very easy to detect certain port numbers. What I remember
from my tests back then is that the product used the default 32768-61000
source port range and made a connection attempt every few minutes (5 or
15 I don't remember). So by sending only a few SYNs per second to the
ports you were expecting to be used due to the uptime and the update
frequency, you could prevent it from establishing a connection to the
remote site.

Some variants might also involve having a buddy server on the net
receiving one connection form this server to shorten the source port
range to attack when the uptime is unknown (eg: web page containing
an image, ad, etc).

> > Back then, I did a PoC which permanently prevented an anti-virus proxy
> > from establishing any connection to its update server, and it did not
> > require a lot of traffic obviously. People running such proxies probably
> > don't need webrtc with its assorted lot of issues.
> >
> > I'm not advocating for pushing the patch, I understand it's not desired.
> > I just want to ensure that people understand what simultaneous connect
> > means in terms of DoS for a feature which is rarely used and rarely
> > technically possible at all.
> 
> When the STUNT folks measured the TCP simultaneous open feasiblity back
> in 2005 they measured an average 88% success rate in estabilishing TCP
> peer connections in the wild.  So unless something has changed
> drastically (or their mesasurements were wildly inaccurate) it
> technically feasible a very interesting percentage of the time.

I suspect it works best in environments it targets : end user to end
user with almost direct connectivity.

> Beyond that it is a sufficiently common trick for establishing peer to
> peer communications that an RFC has been written allowing peer to
> peer code written by different authors to interoperate.
> 
> I just want to make it clear that for a lot of interesting cases TCP
> simultaneous open works today and is very interesting for getting
> client machines talking directly to each other.

I understand what it can be useful to, I'm just saying that there are
environments where this behaviour is clearly not desirable at all,
which led me to propose a sysctl so that users could basically decide
whether they were in the server camp or in the client camp.

Regards,
Willy
