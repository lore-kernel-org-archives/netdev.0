From: Henrik Petander <lpetande@tml.hut.fi>
Subject: Re: [patch]: ipv6 tunnel for MIPv6
Date: Wed, 04 Jun 2003 17:30:30 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EDE0286.4000304@tml.hut.fi>
References: <Pine.LNX.4.44.0305301712300.3584-200000@rhea.tcs.hut.fi>	<Pine.LNX.4.44.0305301735340.3584-200000@rhea.tcs.hut.fi>	<20030531.003858.108351451.yoshfuji@linux-ipv6.org> <20030603.213830.85382657.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, vnuorval@tcs.hut.fi, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, ajtuomin@morphine.tml.hut.fi,
   lpetande@morphine.tml.hut.fi, jagana@us.ibm.com, kumarkr@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030603.213830.85382657.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> I am VERY UPSET that there appears to be NO dialogue between USAGI and
> MIPV6 folks to discuss design of MIPV6.  If you do not talk together,
> how can you guys possibly coordinate efforts and not avoid duplicated
> work?

I am sorry about the long delay in the extension header addition
mechanism discussion. The issues involved with interactions between xfrm
stacked destinations and mipv6 were at least to me somewhat fuzzy. To
understand them better we developed a prototype of the mipv6 extension
header addition and processing. This unfortunately took too long, due to
other work.

In any case, I hope we can all work better together from now on. In
hopes of starting a working dialogue, I'll try to summarize the current
situation on our side.

1. Tunnel

The tunneling code should be ready, Ville just sent a  patch without
dependancies on source address based routing. All received and future
comments about that are highly appreciated.

2. Source address based routing

Ville sent the patch. The semantical changes to the original code were
in our opinion necessary to get source address based routing working
more as IPv4 policy routing.  Let's discuss this more.

3. API

We've added kernel support for the API to accept routing header type 2
and to do the additional checks necessary.  Also home address option
API support has been written.  In fact, you can add any destination
option to the new DO position with this.

There is a (sub)group working on MIPv6 extensions to the Advanced Socket
API for IPv6.  To me it seems pointless to add anything other to the
spec than a way to insert a destination option header to the third
possible DO position (i.e. between routing header and fragmentation
header).  This could be done just by adding new type, let's call it
IPV6_NOFRAGDSTOPTS.  Everything else should be doable with the
existing ASA.  We would like to hear comments on this.

Is a rtnetlink extension enough for adding mobility routes or do
we need to support ioctl too?

4. Source address selection

We think adding new home address flag to addresses is the best and
easiest way making the source address selection to work with MIPv6.
I'm sure USAGI will add the relevant checks to their source address
selection code for that.  Dave, Antti already brought this up some weeks
ago, but got no answer. Is the home address bit OK with you?

5. MIPv6 extension header adding

We have been also testing how the mipv6 extension header adding would
work in practice through the development of a prototype for the purpose.
Based on the work it seems (to me) that the use of xfrm for storing the
mipv6 stuff conflicts with its primary use, especially if there are
overlapping entries for IPSec and MIPv6.

Storing of the mipv6 information would in our opinion be achieved more
cleanly by using cached routes which included the mipv6 information (two
extra addresses and flags). The routes would contain modified nexthop
information and mip6_output as the  rt->u.dst.output function.
Mip6_output would add the extension headers based on the information
stored in the route. The routes would have a stacked dst entry, which
would be used for actual output.

Our prototype  currently works with tcp, tcp + ipsec and raw sockets,
but has only a hackish interface through route ioctl for testing. I can
send a preview patch of the code for discussion, if the general approach
makes sense to you. I would like to hear your opinions on this and also
if you (USAGI) have planned something else for storing the mipv6 state.


Henrik
