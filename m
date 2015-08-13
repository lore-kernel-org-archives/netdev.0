From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Subject: Re: [PATCH] IGMP: Inhibit reports for local multicast groups
Date: Thu, 13 Aug 2015 15:08:09 -0300
Message-ID: <20150813180809.GB22268@indiana.gru.redhat.com>
References: <1439396033-6264-1-git-send-email-pdowney@brocade.com>
 <20150812.164519.1783786478654950784.davem@davemloft.net>
 <57f72e6a6f024628bd18ef4b139ac31e@EMEAWP-EXMB12.corp.brocade.com>
 <20150813160626.GF32484@lunn.ch>
 <b50a97f544f5437fb18df1cb5b6b6533@EMEAWP-EXMB12.corp.brocade.com>
 <20150813170137.GE32627@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Philip Downey <pdowney@Brocade.com>,
	David Miller <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150813170137.GE32627@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 13, 2015 at 07:01:37PM +0200, Andrew Lunn wrote:
> On Thu, Aug 13, 2015 at 04:52:32PM +0000, Philip Downey wrote:
> > Hi Andrew
> > IGMP snooping is designed to prevent hosts on a local network from receiving traffic for a multicast group they have not explicitly joined.   Link-Local multicast traffic should not have an IGMP client since it is reserved for routing protocols.  One would expect that IGMP snooping needs to ignore local multicast traffic in the reserved range intended for routers since there should be no IGMP client to make "join" requests.
> 
> The point of this patch is that Linux is sending out group membership
> for these addresses, it is acting as a client. What happens with a
> switch which is applying IGMP snooping to link-local multicast groups?
> You turn on this feature, and you no longer get your routing protocol
> messages.
> 
> I had a quick look at RFC 3376. The only mention i spotted for not
> sending IGMP messages is:
> 
>    The all-systems multicast address, 224.0.0.1, is handled as a special
>    case.  On all systems -- that is all hosts and routers, including
>    multicast routers -- reception of packets destined to the all-systems
>    multicast address, from all sources, is permanently enabled on all
>    interfaces on which multicast reception is supported.  No IGMP
>    messages are ever sent regarding the all-systems multicast address.
> 
> IGMP v2 has something similar:
> 
>    The all-systems group (address 224.0.0.1) is handled as a special
>    case.  The host starts in Idle Member state for that group on every
>    interface, never transitions to another state, and never sends a
>    report for that group.
> 
> But i did not find anything which says all other link-local addresses
> don't need member reports. Did i miss something?
> 
>       Andrew

>From RFC 4541 (Considerations for Internet Group Management Protocol (IGMP) and
Multicast Listener Discovery (MLD) Snooping Switches):

 2) Packets with a destination IP (DIP) address in the 224.0.0.X range
      which are not IGMP must be forwarded on all ports.

      This recommendation is based on the fact that many host systems do
      not send Join IP multicast addresses in this range before sending
      or listening to IP multicast packets.  Furthermore, since the
      224.0.0.X address range is defined as link-local (not to be
      routed), it seems unnecessary to keep the state for each address
      in this range.  Additionally, some routers operate in the
      224.0.0.X address range without issuing IGMP Joins, and these
      applications would break if the switch were to prune them due to
      not having seen a Join Group message from the router.

So, it looks like some hosts and routers out there in the field do not send
joins for those local addresses. In fact, IPv4 local multicast addresses are
ignored when Linux bridge multicast snooping adds a new group.

static int br_ip4_multicast_add_group(struct net_bridge *br,
...
	if (ipv4_is_local_multicast(group))
		return 0;

Cascardo.
