From: Andreas Jellinghaus <aj@dungeon.inka.de>
Subject: Re: NAT before IPsec with 2.6
Date: Wed, 28 Jan 2004 11:21:34 +0100
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <1075285293.5055.29.camel@simulacron>
References: <20040124082252.GA19035@alpha.home.local>
	 <Pine.LNX.4.44.0401241015470.32723-100000@filer.marasystems.com>
	 <20040124092721.GA19140@alpha.home.local>
	 <20040127103917.GC11761@sunbeam.de.gnumonks.org>
	 <20040127132725.GA14685@openoffice.nl>
	 <pan.2004.01.27.21.13.32.754125@dungeon.inka.de>
	 <20040128085831.GM11761@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040128085831.GM11761@sunbeam.de.gnumonks.org>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Wed, 2004-01-28 at 09:58, Harald Welte wrote:
> However, it doesn't reset the skb->nfct pointer,

the tunnels do. 

In summary it looks to me, like you want to have everything that a
real tunnel with an interface offers, but for some reason you don't
want the tunnel with the interface. right?

so, why?

> - no working connection tracking in any kind of ipsec scenario
that is not true. ipip_rcv:
                nf_conntrack_put(skb->nfct);
                skb->nfct = NULL;
ipip_xmit:
        nf_conntrack_put(skb->nfct);
        skb->nfct = NULL;

the only problem is stability and scheduling in atomic with xfrm+ipip
(i guess a bug, I hope someone who understands the code could take a
look at it).

> > use an interface, and you will see the packet twice, plus the interface
> > does the route lookup on the encrypted packet. so no ugly hacks in the
> > routing table are necessary.
> 
> Did anybody propose ugly hacks in the routing table?

if you don't use an interface, you need them in real world setups.
with an interface both gw and client put the route to each others
static vpn ip on ipsec0 and then configure the tunnel ips, and
those ip will be used to lookup the interface where to send the
encrypted packet.

with the current code without using interfaces, the ip of the
vpn tunnel needs to be moved to the interface that will be used
to reach the vpn gateway. even worse, you need to play with
source address selection to make sure an outgoing packet has
your static vpn ip, and not the dynamic ip of whatever net
you are currently using. 

example:
      up ip addr add 192.168.3.1 dev wlan0
      up ip route del default dev wlan0
      up ip route add default via 192.168.1.1 src 192.168.3.1 dev wlan0
      down ip addr del 192.168.3.1 dev wlan0

and swithcing from wlan0 to eth0 does not only require
the tunnel to be reconfigured (local and remote ip), but
also changes in the routing table. that is horrible.

and yes, of course you want static ip addresses for "road warrior"
clients! for example smtp servers need to these to allow relaying
or not.


> So we absolutely _need_ a symmetric-to-incoming behaviour like:

use an tunnel interface and you have that.
(adding pre_/post_ routing is very simple, simply cut&paste to the
_rcv and _xmit functions.

sure, you can archive the same thing without using tunnel interfaces.
But i wonder if that creates a simple solution, easy to understand.

my basic question is: how will these changes affect setups with tunnel
interfaces? 


[other issue]
if we are to look at the calls to xfrm anyway: would it be possible to
add a debugging facility for dropped packets? I know, that is not a
netfilter issue, but I guess many people will find it problematic,
if they cannot see what packets are dropped by the xfrm logic.
I'm only rasing the issue, because that code is most likely put
to the same places we are discussiong right now (ah, esp, ipip_rcv,
ipip_xmit, ...).

> I'm not proposing to route before encapsulating.

that is currently done. I'm glad if that "feature" is removed.


>   I just propose of
> calling the same netfilter functions that we usually call before/after
> routing at different places :)

fine. I don't understand what the benefit of doing everything like with
an interface, but avoiding the interface. but please keep
tunnel with interface and tunnel without interface in sync.

Regards, Andreas
