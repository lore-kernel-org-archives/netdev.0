From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Subject: Re: [PATCHv2 net-next 2/4] bridge: adhere to querier election
 mechanism specified by RFCs
Date: Fri, 27 Jun 2014 02:12:23 +0200
Message-ID: <20140627001223.GA28373@Linus-Debian>
References: <1400994205-31165-1-git-send-email-linus.luessing@web.de>
 <1400994205-31165-3-git-send-email-linus.luessing@web.de>
 <CADAe=+KViC7uej0KM4TrQXxrk-amU7CX73buviMU17jpQm61bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	b.a.t.m.a.n@lists.open-mesh.org
To: Ajith Adapa <adapa.ajith@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:64694 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750699AbaF0AM2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 20:12:28 -0400
Content-Disposition: inline
In-Reply-To: <CADAe=+KViC7uej0KM4TrQXxrk-amU7CX73buviMU17jpQm61bw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ajith,


On Mon, Jun 23, 2014 at 07:58:21AM +0530, Ajith Adapa wrote:
> Hi Luessing,
> 
> As per RFC 4541, snooping switches send query with source address as
> 0.0.0.0 since port in a L2 switch doesn't have ip-address configured.

Hm, I'm not quite sure whether this is true. Do you have a
section/paragraph in RFC4541 which says that?

To me, it seems that 0.0.0.0/:: should only be used when the
topology changes, on links becoming active (the RFC uses the example
of STP). As a performance optimization but not as the source
address for General Queries.

In section 2.1.1 1) b) says:

     "The 0.0.0.0 address represents a special case where the switch
      is proxying IGMP Queries for faster network convergence,
      but is not itself the Querier."

In section 2.1.1 4) it says:

     "If the switch is not the Querier, it should use the 'all-zeros' IP
      Source Address in these proxy queries (even though some hosts may
      elect to not process queries with a 0.0.0.0 IP Source Address)."

(which seems to imply that if a switch is the selected Querier, that
it should use something other than the 'all-zeros' IP Source
Address?)

Also, section 2.1.1 4) says:

"[...] even though some hosts may elect to not process queries with a
 0.0.0.0 IP Source Address"

Which seems to indicate that 0.0.0.0 might be a bad choice to get
reliable IGMP Reports and might only make sense for performance
optimizations (at least for IPv4 - for IPv6 it doesn't make sense
to me to send General Queries with '::' source address at all
since '::' is ignored by hosts per RFC).

(*)

> 
> With current changes linux bridge will always select a querier who sends a
> query message with 0.0.0.0. Right ?
> 
> +       if (ntohl(saddr) <= ntohl(br->ip4_querier.addr.u.ip4))
> +               goto update;

Yes. Which is what the querier election mechanism in the RFCs for
IGMPv2/IGMPv3 (RFC2236/RFC3376) specifies, I think. (**)

> 
> Currently linux bridge sends a query message with source address as
> 0.0.0.0. Right ?

For IPv4, this is currently the default, yes. (there's a sysfs switch
to change that, if desired) (***)

> 
> What should be the expected behaviour ?

Hm, good question.

Regarding (***): After rereading RFC4541 a few more times, I think
(*) would be the right choice: The bridge code should probably be
changed to always use an available, non-zero IPv4 source address
for General Queries. If none is available it, doesn't make sense
to me to become the selected Querier at all (should be changed for
IPv6, too: Currently it refrains from sending Query messages
then, but thinks a valid querier were in the network, enabling
the multicast snooping of the bridge).


Regarding (**): Now that you're mentioning that, you're right, my
change isn't quite straightforward in that regard, a few lines
earlier there is:

> +       if (!br->ip4_querier.addr.u.ip4)
> +               goto update;

So it would select the all-zeros Querier if it receives such
messages. But would happily switch to a non-all-zeros Querier as
well if receiving such messages...

And now, this baffles me, section 2.1.1 4) again:

     "When such proxy queries are received, they must not be included in
      the Querier election process."

If we were following that, a snooping switch and a true multicast
router could potentially have an argument about which becomes the
selected IGMP querier? (for IPv6/MLD this dilemma should not
exist, I think)

I'm currently unsure, whether we should follow
RFC2236(IGMPv2)+RFC3376(IGMPv3) or the informational (!) RFC4541.

Or am I overlooking something? What do others think?

Cheers, Linus
