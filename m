From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 29 Jul 2003 01:36:32 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307290008170.1632-100000@u.domain.uli>
References: <20030727183547.784b6ab5.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-net@vger.kernel.org>, <bloemsaa@xs4all.nl>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030727183547.784b6ab5.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Sun, 27 Jul 2003, David S. Miller wrote:

> It would be really nice if people might consider that it could even be
> possible to make things like the IPVS layer install the appropriate
> NETFILTER_ARP chain rules when the IPVS configuration installed dictates
> that one is needed.

	This is not a kernel job

> People using IPVS wouldn't even need to do _ANYTHING_ if IPVS were
> to do that.

	Only if IPVS runs on these boxes, not always true.

> And all of that would be _FINE_ because like ARP netfilter, IPVS lies
> inside of netfilter where such things which change networking behavior
> semantics radically belong.

	This is good assumption but as usually the world is not
perfect. First, the shared IPs should be used only for IPVS talks.
With so many places in the kernel calling inet_select_addr() I do not
think "hidden" should be blamed to add explicit checks into the
IP layer. This is a better safe than sorry situation. Thank Alexey
for the added checks.

	Second, arp_filter is useless for filtering of
our announcements and thus for IPVS setups. Also, ARP has never used
preferred source addresses. I have a patch for this but I consider
it incorrect. So, prefsrc does not play here too. The prefsrc is
used only from the IP Layer when the originating connections
demand autobind. They are not used for incoming connections.
With rp_filter=0 and arp_filter=1 the ARP can easily announce
local IPs on the wrong interface. arp_filter can not stop that.

	So, for IPVS setups the only valid solutions are:

- hidden (patch)
- arptables (needs recent kernels and/or patch)
- iparp (patch)

	We have only patches. I assume the things will change only
when the people see that arptables is working. Then they will need time
to adopt their clusters to the new tools. I hope that will happen
in 2.6 and we will stop talking about hidden.

	BTW, would you consider iparp for kernel inclusion? I know
it is duplicated work, just asking?: http://www.ssi.bg/~ja/#iparp

	Some rules (in response to other posts):

- the shared IPs have ARP requirements (obvious to everyone)
- the shared IPs have IP requirements (autobinding to shared IPs
and their ports should be prohibited, with rules or with policy as
in the case with "hidden"). Even explicit binding to such IPs can
be prohibited. Do we need iptables hooks for denying autobind
for some IPs?

	As for, ARP and the RFCs, the RFCs are free enough to allow
ip-to-hwaddr lookups and announcements. All the other requirements
we have can be solved with ARP filters:

- dropping incoming probes
- fixing our announcements (eg. one IP announced only through specific
interface, etc)
- proxy arp answering
- deciding what to put in ARP cache

	dropping probes, fixing announcements, all is part of
the game. We should be able to do everything on our LAN as long as
the upper layers are happy with the ARP service and there is sane
and well defined behavior. There are defaults for usual setups known
to the RFC authors and there are knobs to make Linux more powerful.

Regards

--
Julian Anastasov <ja@ssi.bg>
