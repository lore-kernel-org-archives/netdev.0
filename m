From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Restrict local IP announcements in ARP requests
Date: Tue, 10 Feb 2004 02:31:23 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402100154010.1251@u.domain.uli>
References: <Pine.LNX.4.58.0402081149001.6268@u.domain.uli>
 <20040209140853.69ab8bea.davem@redhat.com> <Pine.LNX.4.58.0402100049470.1251@u.domain.uli>
 <20040209151053.1f63937a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040209151053.1f63937a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Mon, 9 Feb 2004, David S. Miller wrote:

> > not for IPVS :) It is mostly to work with other stacks because
> > I'm flooded with emails about how Linux ARP can be more friendly.
>
> So this new 'arp_announce' change suggestion will preempt any need for
> hidden and make everyone happy?

	For IPVS like setups it solves only one part:
arp_announce=2 but for such setups we still need per IP filtering
of ARP requests which is not possible to filter with ip rules.
If you look at http://www.ssi.bg/~ja/hidden-2.5.67-1.diff
you will see that:

- the arp_solicit change is solvable with arp_announce=2. If
hidden touches there it needs IP lookup. The good news is that
inet_addr_type is replaced with ip_dev_find.

	If hidden does not change arp_solicit then the users will use:

	{all,lo}/hidden=1, eth0/arp_announce=2

	If hidden changes arp_solicit then only hidden will be used

- hidden adds ip_dev_find call in arp_rcv for the broadcast case,
and only if hidden is enabled with all/hidden=1, so it is ugly
but fast if all/hidden=0

- hidden changes inet_select_addr() which is not needed for
IPVS setups and can be solved with careful preferred source usage,
so this change can be ignored

	So, if hidden exists and is disabled it will not delay
too much the processing but it is true that both arp_rcv and
arp_solicit become more and more loaded with ugly checks.
You do not need to decide today about it :)

	Another question while I'm looking at arp_rcv:

- what happens if request comes with SIP=0, should we provide
answer (proxy_arp) if there is valid remote target? Can be useful
for setups where we split a logical subnet. But solving
this problem will require cleaning up the arp_process function.
In any case, it does not look so hard to me :)

> About output_route vs. inet_select_addr(), probably the latter is better.
> Your goal is to differentiate between primary and seconday addrs on a device
> right?  Route lookup is also more expensive, probably.

	ok

Regards

--
Julian Anastasov <ja@ssi.bg>
