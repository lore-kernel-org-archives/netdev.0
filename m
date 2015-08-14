From: Philip Downey <pdowney@Brocade.com>
Subject: RE: [PATCH] IGMP: Inhibit reports for local multicast groups
Date: Fri, 14 Aug 2015 08:56:56 +0000
Message-ID: <b74d1e7c6693479bb9caf0c3fef5d7a2@EMEAWP-EXMB12.corp.brocade.com>
References: <1439396033-6264-1-git-send-email-pdowney@brocade.com>
 <20150812.164519.1783786478654950784.davem@davemloft.net>
 <57f72e6a6f024628bd18ef4b139ac31e@EMEAWP-EXMB12.corp.brocade.com>
 <20150813160626.GF32484@lunn.ch>
 <b50a97f544f5437fb18df1cb5b6b6533@EMEAWP-EXMB12.corp.brocade.com>
 <20150813170137.GE32627@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150813170137.GE32627@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew
Answers inline...

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Thursday, August 13, 2015 6:02 PM
> To: Philip Downey
> Cc: David Miller; kuznet@ms2.inr.ac.ru; jmorris@namei.org; yoshfuji@linux-
> ipv6.org; kaber@trash.net; linux-kernel@vger.kernel.org;
> netdev@vger.kernel.org
> Subject: Re: [PATCH] IGMP: Inhibit reports for local multicast groups
> 
> On Thu, Aug 13, 2015 at 04:52:32PM +0000, Philip Downey wrote:
> > Hi Andrew
> > IGMP snooping is designed to prevent hosts on a local network from
> receiving traffic for a multicast group they have not explicitly joined.   Link-
> Local multicast traffic should not have an IGMP client since it is reserved for
> routing protocols.  One would expect that IGMP snooping needs to ignore
> local multicast traffic in the reserved range intended for routers since there
> should be no IGMP client to make "join" requests.
> 
> The point of this patch is that Linux is sending out group membership for
> these addresses, it is acting as a client. What happens with a switch which is
> applying IGMP snooping to link-local multicast groups?
> You turn on this feature, and you no longer get your routing protocol
> messages.

It is expected that link-local multicast is always forwarded by switches otherwise routers may not function correctly.

>From the relevant RFC:

RFC 4541     IGMP and MLD Snooping Switches Considerations      May 2006


2.1.2. Data Forwarding Rules


   1) Packets with a destination IP address outside 224.0.0.X which are
      not IGMP should be forwarded according to group-based port
      membership tables and must also be forwarded on router ports.

      This is the main IGMP snooping functionality for the data path.
      One approach that an implementation could take would be to
      maintain separate membership and multicast router tables in
      software and then "merge" these tables into a forwarding cache.

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

> 
> I had a quick look at RFC 3376. The only mention i spotted for not sending
> IGMP messages is:
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
> But i did not find anything which says all other link-local addresses don't
> need member reports. Did i miss something?

No you did not miss anything - that is correct.
However, the RFCs don't really cover the behavior of routers well in some areas.   Routing protocols which use the 224.0.0.x address space do not need IGMP therefore it makes no sense to distribute membership reports for these groups.  A router which receives an IGMP membership report which includes groups from this reserved address range will ignore it -and probably generate debug messages highlighting an invalid address.

Regards

Philip
> 
>       Andrew
