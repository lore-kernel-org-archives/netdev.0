From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [PATCH 1/1] netfilter: Add possibility to turn off netfilters defrag per netns
Date: Wed, 4 Jan 2012 21:45:10 +0100
Message-ID: <201201042145.10698.hans@schillstrom.com>
References: <1325664443-10320-1-git-send-email-hans.schillstrom@ericsson.com> <201201041248.36881.hans.schillstrom@ericsson.com> <20120104174035.GB3489@1984>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Patrick McHardy <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120104174035.GB3489@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday, January 04, 2012 18:40:35 Pablo Neira Ayuso wrote:
> On Wed, Jan 04, 2012 at 12:48:35PM +0100, Hans Schillstrom wrote:
> > I like that idea, an "early" table at prio -500 with PREROUTING.
> > There is also a need for a new flag "--allfrags"
> > i.e. all fragments needs to be sorted out and sent to same dest for defrag.
> > 
> > ex.
> > iptables -t early -A PREROUTING -i eth0 --allfrags -j NOTRACK
> 
> New tables add too much overhead. We have discussed this before with
> Patrick.
> 
> Since this still remains specific to your needs, I think you can
> remove nf_conntrack module in your setup.
> 
> I don't come with one sane setup that may want selectively defragment
> some traffic yes and other not.
> 
> Am I missing anything else?
>

I might have been a little bit unclear, so I'll try the opposite :-)

Network namesapce i.e. Linux Containers (LXC) creates new possibilities,
Linux moves to new domains - Large Clusters controllers.

When you have two or more interfaces (on different machines) that receives data
from the Internet you will sooner or later end up with fragments on different
interfaces.

If you deal with Virtual IP:s in the cluster (which is very common)
there must be some place where packet defrag occurs, before sending
it to a load balancer.

Hardware is cheap but space and power consumption is not, so
no one wants extra hardware. If possible extra hops should also be avoided.

With existing functionality an extra level of physical machines must be
added between the (FW/GW) and the Load-Balancers to do the defrag,
which is not very efficient.

With a solution where it's possible to sort out fragments early
(based on ex source address) and send them to the same Container for defragmentation
no extra hardware is needed and only fragmented packet have an extra hop.


A Simplified Example:
(ASCII grapichs have some limitaions)

            Blade 1
         +------------+
         |   +-----+  | Defrag/LB
Inet A   |   | FW. |  |  Trafic                 VIP 11.1.1.1
---------+-> | LXC |--|-->+                     Blade a
         |   +-----+  |   |                    +-------+
         |      |<----|---+                    | Appl. |
         |   +-----+  |   |       +-------- >  | Serv. |
         |   | LB. |__|___|_______|            +-------+
         |   | IPVS|  |   |       |
         |   +-----+  |   |       |
         +------------+   |       |
                          |       |
            Blade 2       |       |
         +------------+   |       |             VIP 11.1.1.1
         |   +-----+  |   |       |             Blade b
Inet B   |   | FW. |  |   |       |            +-------+
---------+-> | LXC |--|-->|       |            | Appl. |
         |   +-----+  |   |       +----------> | Serv. |
         |      | <---|---+       |            +-------+
         |   +-----+  |   |       |
         |   | LB. |__|___|_______|
         |   | IPVS|  |   |       |             VIP 11.1.1.1
         |   +-----+  |   |       |             Blade c
         +------------+   |       |            +-------+
                          |       |            | Appl. |
            Blade n       |       +--------->  | Serv. |
         +------------+   |       |            +-------+
         |   +-----+  |   |       |
Inet N   |   | FW. |  |   |       |             VIP 11.1.1.1
---------+-> | LXC |--|-->|       |             Blade x
         |   +-----+  |   |       |            +-------+
         |      |<----|---+       |            | Appl. |
         |   +-----+  |           +--------->  | Serv. |
         |   | LB. |__|___________|            +-------+
         |   | IPVS|  |
         |   +-----+  |
         +------------+

You might even co-locate the Appl on the FW/GW Blades.
The ideal solution would be where you can sort out fragments based on interface
and have defrag on others. (In this case even the first fragment)

Regards
Hans Schillstrom
