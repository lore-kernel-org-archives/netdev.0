From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: Recent select() handling change breaks Poptop
Date: Mon, 6 Dec 2004 21:48:40 -0800
Message-ID: <20041207054840.GD61527@gaz.sfgoth.com>
References: <20041207003525.GA22933@linuxace.com> <20041207025218.GB61527@gaz.sfgoth.com> <20041207045302.GA23746@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Phil Oester <kernel@linuxace.com>
Content-Disposition: inline
In-Reply-To: <20041207045302.GA23746@linuxace.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(adding netdev to cc:)

Phil Oester wrote:
> >   2. a "tcpdump -nvv" of its udp traffic (ideally captured from a seperate
> >      server, but from the server would probably be OK too)
> 
> PPTP uses TCP 1723 and GRE (proto 47), so there is no udp traffic involved.
> I suspect the change was made to all datagram traffic with the assumption 
> that UDP was the only protocol impacted.  Perhaps GRE was not considered?

Yeah, it looks like the problem for sure.  The patch modifies the
structure "inet_dgram_ops" to use udp_poll(), but looking farther down:

static struct inet_protosw inetsw_array[] =
[...]
                .type =       SOCK_DGRAM,
                .protocol =   IPPROTO_UDP,
                .prot =       &udp_prot,
                .ops =        &inet_dgram_ops,
[...]
               .type =       SOCK_RAW,
               .protocol =   IPPROTO_IP,        /* wild card */
               .prot =       &raw_prot,
               .ops =        &inet_dgram_ops,
[...]

so it looks like udp_poll() will end up getting used for both SOCK_DGRAM
and SOCK_RAW inet sockets; obviously Poptop is using the latter and failing
as a result.  No need for the strace/tcpdump data I guess.

The fix is to just make a copy of the inet_dgram_ops called inet_udp_ops
and make the udp_poll() change only in that one (and obviously change the
SOCK_DGRAM case there to use &inet_udp_ops).  I don't have time right this
second to spin a patch, but could you try that out and see if it fixes
your problem.

-Mitch
