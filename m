From: James Chapman <jchapman@katalix.com>
Subject: Re: PPP-over-L2TP kernel support, new patch for review
Date: Wed, 22 Sep 2004 22:28:53 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095888533.4151ee95ed23c@www.katalix.com>
References: <E1CA4kn-0005jn-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: bcrl@kvack.org, davem@davemloft.net, netdev@oss.sgi.com, kleptog@svana.org,
        mostrows@styx.uwaterloo.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CA4kn-0005jn-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Herbert,

Quoting Herbert Xu <herbert@gondor.apana.org.au>:

> James Chapman <jchapman@katalix.com> wrote:
> >
> > The biggest difference in our approaches is that Martijn and I use a
> > PPPoL2TP socket per session bound through a plain AF_INET UDP tunnel
> > socket while Ben uses a new AF_L2TP tunnel socket and no separate
> > socket per session. Both have their merits.
>
> Can you elaborate on the merits of having a socket? It would seem to me
> that not having a socket is a lot more scalable.  After all IPsec doesn't
> carry a socket around per session.

What I meant by "both have their merits" is that both general
approaches have their merits. It's a shame Martijn isn't available
right now (he's moving home to a new country) as he came up with the
initial kernel driver concept. Anyway, I'm sure he'll chime in later.

We could have implemented this thing by hooking specific UDP ports out
in udp.c or adding to the UDP encap framework that you use for IPsec.
Neither seem ideal for this case -- modifying core code in udp.c to
add support for a new UDP protocol just seemed wrong.  IPsec is
special -- it is a core technology that the IP stack should know
about. L2TP isn't special at all.

There are several reasons why I think the approach taken is a
reasonable compromise:-

- No changes to core kernel code needed. The new L2TP support can be
  loaded as a module into current 2.4 and 2.6 Linux distributions.

- It fits well into the existing PPPoX framework. This is, after all,
  PPP over L2TP.

- Implementing a new socket address family for the tunnel socket
  instead of using a plain UDP socket meant cloning a lot of UDP
  code. We thought it might break IPsec assumptions and having code
  that did almost the same thing as other components of the kernel
  was not ideal. It also seemed to set the wrong precedent for adding
  a new UDP protocol.

- Having PPP create a socket and bind it to the L2TP tunnel UDP socket
  gave us all the packet hooks we needed to implement the L2TP
  datapath. And using a per-session socket made it trivial to add
  control and status APIs for userspace. Also, for handling L2TP
  (optional) data packet reordering, the socket buffer would help
  when holding packets for their predecessors, preventing one bad
  session from breaking others in the tunnel.

- For VPN usage scenarios where 50 or so L2TP sessions would be
  unusually large, the extra socket overhead didn't seem to matter
  that much when weighed up against all its advantages. Since in the
  VPN case, PPP sessions are locally terminated, there's also a
  net_device per session. Are we going to get rid of that too?

We keep coming back to the scalability issue. Sure this driver
wouldn't work when handling thousands of sessions, but I just don't
think it's an issue in the VPN case. People will be nailing up their
VPNs directly with hardware-assisted IPsec or even MPLS well before we
hear users complaining that they want Linux's L2TP to support
thousands of sessions for VPN use.

Please don't get me wrong, I'm not saying that scalability doesn't
matter. But I do think we're getting hung up on the need to support
thousands of L2TP sessions carrying non-terminated PPP sessions as a
typical Linux use case. Linux systems, especially those built from the
core kernel source distribution, are much more likely to be using L2TP
for VPNs, terminating PPP locally.

There are many problems to solve first in order to handle thousands of
sessions before our proposed driver's limitations become an issue, i.e.
single daemon pppd and how to handle each PPP interface without a
net_device. Ben's Babylon-based solution does this but it won't solve
the VPN problem.

I really want to see an end to those userspace pty pppd hacks being
used by current L2TP, PPTP and PPPoE solutions. I think the proposed
driver solves that problem well for L2TP and because it can be
installed in current Linux installations with little effort (as a
module), it stands a reasonable chance.

I'll shut up now, I've gone on long enough. Thanks for reading this
far! :)

/james
