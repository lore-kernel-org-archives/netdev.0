From: James Chapman <jchapman@katalix.com>
Subject: Re: PPP-over-L2TP kernel support, new patch for review
Date: Wed, 22 Sep 2004 10:58:12 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095847092.41514cb435b7e@www.katalix.com>
References: <1095714704.414f4790cd168@www.katalix.com> <20040920141704.16085067.davem@davemloft.net> <1095760525.414ffa8d111a1@www.katalix.com> <20040921210427.GB19575@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, kleptog@svana.org, mostrows@styx.uwaterloo.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Benjamin LaHaise <bcrl@kvack.org>, "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040921210427.GB19575@kvack.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Although Ben and I are both working on L2TP projects, I think we're
targetting two totally different usage scenarios.

Time for some ASCII art...

1. ISP scenario

               +----+
            ---+ D  |
            ---| S  |      +--------+              +-------+
            ---| L  |======|  LAC   |==============| LNS   |
            ---| A  |      |        |              |       |
            ---| M  |      +--------+              +-------+
            ---|    |
            ---|    |
            ---|    |
               +----+
     thousands       PPPoA           each PPP session
     of PPP          or              tunneled thru
     clients         PPPoE           L2TP session to LNS


2. VPN scenario

           +---+                                  +------+
           |LAC+----------------------------------|      |
           +---+                                  |      |
           +---+                                  |      |
           |LAC+----------------------------------| LNS  |
           +---+                                  |      |
           +---+                                  |      |
           |LAC+----------------------------------|      |
           +---+                                  |      |
                                                  +------+
        PPP client                               Terminates
        in each LAC.                             multiple tunnels
        Typically 1
        session per tunnel

Ben is addressing the ISP case, where client PPP sessions are
terminated only temporarily at the LAC while it authenticates the PPP
users to decide how to tunnel them. Each PPP session is then tunneled
straight through the LAC via an L2TP session (inside an L2TP tunnel)
to the LNS. Scalability is important here, which Ben has addressed.

I'm addressing the VPN case, where multiple clients (M$ L2TP/IPSEC
or rp-l2tp/openl2tp clients) connect to an enterprise VPN server.
Current solutions involve userspace pty hacks in the datapath,
shunting data in and out of pppd ttys. The proposed driver moves the
datapath into the kernel where it should be. The driver integrates
with existing PPP and IPSEC kernel subsystems and will handle
hundreds of sessions today.

The biggest difference in our approaches is that Martijn and I use a
PPPoL2TP socket per session bound through a plain AF_INET UDP tunnel
socket while Ben uses a new AF_L2TP tunnel socket and no separate
socket per session. Both have their merits.

If I can put the case for our driver, Linux really needs a good VPN
solution. I know of two companies that run their offices with Linux
servers yet they both retain a Microsoft server _only_ to provide VPN
access to off-site workers. Including this driver in the kernel will
enable us to build binary packages for OpenL2TP and perhaps other L2TP
solutions like rp-l2tp would be updated to use it too. Being able to
handle hundreds (not thousands) of sessions is more than adequate
in this case.

Where do we go from here then? Perhaps both approaches are equally
valid and could even co-exist in the Linux kernel distribution?

/james

Quoting Benjamin LaHaise <bcrl@kvack.org>:

> > - Architecture seems to be using char devices for communication with
> >   the kernel and all the PPP datapath is handled by custom virtual
> >   net_devices; the generic PPP kernel code isn't used as far as I can
> >   tell. Unfortunately it is very old (linux-2.0 era I think) but Ben
> >   has probably updated it.
>
> I've updated it.  The current build is at http://www.kvack.org/~bcrl/babylon/
> and is 1.6-pre3-bcrl8.

[snip]
