From: Andreas Jellinghaus <aj@dungeon.inka.de>
Subject: Re: NAT before IPsec with 2.6
Date: Wed, 28 Jan 2004 14:43:13 +0100
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <1075297393.5668.19.camel@simulacron>
References: <20040124082252.GA19035@alpha.home.local>
	 <Pine.LNX.4.44.0401241015470.32723-100000@filer.marasystems.com>
	 <20040124092721.GA19140@alpha.home.local>
	 <20040127103917.GC11761@sunbeam.de.gnumonks.org>
	 <20040127132725.GA14685@openoffice.nl>
	 <pan.2004.01.27.21.13.32.754125@dungeon.inka.de>
	 <20040128085831.GM11761@sunbeam.de.gnumonks.org>
	 <1075285293.5055.29.camel@simulacron>
	 <20040128130050.GS11761@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040128130050.GS11761@sunbeam.de.gnumonks.org>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

Hi Harald,

The userland could be improved to be more flexible,
then it could configure the same issue with and
without interface, depending on the needs. From
protocol perspective that wouldn't be visible, 
so I realy don't see any interoperability issues here.

ip, esp, inner ip, tcp/udp, payload.
the packet can look the same, whether you use some
interface to assemble it or not. ike and setting
spd plus tunnel is the issue, but thats userspace.

ok, but thats not a netfilter topic.

> I think you would see the packet even more often:
> 
> 1) LOCAL_OUT of original packet 
> 2) POST_ROUTING of original packet
> 3) LOCAL_OUT of tunnelled packet
> 4) POST_ROUTING of tunneled packet
> 5) LOCAL_OUT of ESP/AH packet
> 6) POST_ROUTING of ESP/AH packet

one change you want to add is POST_ROUTING before
encapsilating. add that hook at the start of ipip_xmit,
too (renameing ipip_xmit to ipip_xmit_finish
and a new ipip_xmit with only the hook), and things
should be in sync. same for the other tunnels.

the other change you want to make is set the interface
to some other value after encapsulation. what value?
will it be possible to specify the value?
I'm still thinking about that and in what scenario you
would need to differ say ipsec0 and ipsec1.
but such scenarios could exist. 

maybe one vpn/gateway/router shared by two small companies,
both want to keep their network private ?

[setkey debugging]
> yes, but I'd rather don't put both of them into one patch.

sure. are there netfilter routines that can be reused,
or are they somehow tied to the NF core? netfilter formats
the packets nicely for debugging.

> > an interface, but avoiding the interface. but please keep
> > tunnel with interface and tunnel without interface in sync.
> 
> What do you mean by that? 

if you add a hook in ah/esp, add the same hooks to ipip, ipgre,
ip6_tunnel etc. Currently netfilter/tunneling is more or
less consistent - without interface there are some issues,
but the tunnelling fits fine into the big netfilter picture
(the one with 5 hooks explained). 

if ah/esp used different hooks than the real tunnels,
that would make the situation less easy.

also, what is the status of the new hooks?
dropped or do you still plan to add a different
hook, even if it calls the same table?
POST_XFRM is a bad name, better something
like POST_ENCAP or POST_DECAP, because IMO
tunnels should call that hook, too, so it
should be a generic name, not tied to xfrm.


>  From my point of view, it should be like
> (1-6) above.   This way anybody can filter on any kind of header bit at
> any layer of the encapsulation. 

ah, wait. it will be only 4 steps,
3+5 and 4+6 are merged, because the tunnel calls xfrm itself,
so it does both at once. that could be changed of course,
if you want that flexibility.

but i wonder:
if you want to change the untunneld packet, you can do that
in 1/2. if you want to change the encrypted packet, you can
do that i 5/6. 3/4 has the same (as payload) you see in 1/2,
and the same header that has 5/6. so what is the benefit
of two additional steps?

Regards, Andreas
