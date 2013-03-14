From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next 0/4]  Allow bridge to function in non-promisc
 mode
Date: Thu, 14 Mar 2013 11:10:34 -0400
Message-ID: <5141E86A.8090607@redhat.com>
References: <1363139126-13396-1-git-send-email-vyasevic@redhat.com> <20130313203100.GB9821@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52193 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755766Ab3CNPKh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Mar 2013 11:10:37 -0400
In-Reply-To: <20130313203100.GB9821@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/2013 04:31 PM, Michael S. Tsirkin wrote:
> On Tue, Mar 12, 2013 at 09:45:22PM -0400, Vlad Yasevich wrote:
>> The series adds an ability for the bridge to function in non-promiscuous mode.
>> We do it in 3 steps.
>> First we add an interface to palce the switch into non-promisc mode.  In
>> this mode, all port of the switch turn promisc off and turn on IFF_ALLMULTI
>> to continue handling multicast traffic.
>
> Hmm why not go the extra mile and do same thing for multicast?

That would be simple enough to add, as I think all this would require is 
an additional dev_mc_sync() call.

I wanted to get basic functionality and unicast working.

>
>> Second we add an ability to designate a bridge port as uplink.
>> Third we add IFF_UNICAST_FLT support to the bridge and sync all unicast
>> HW addresses to the uplink ports.
>> Default bridge operation continues to remain "promiscuous".  The new
>> functionality has to be enabled via sysfs (similar to other bridge extensions).
>>
>> The uplink mode is implemented as a flag on a bridge port.  The api to
>> change that flag follows the existing api to enable/disable other existing
>> flags.
>
> Actually, it seems a bit tricky to use correctly.  Specifying MACs is
> straight-forward enough, but as you add and remove interfaces, you would
> need to play with uplink and promisc bits.

Not the promisc bits since this patch series proposes a bridge wide 
setting.  Yes, uplink bits would need to be played with though.  I'd 
really love to specify those bits when the link is added, but the 
netlink operation for bridge is a bit odd.

May be I should re-fix that.

>  I also think that for setups
> you describe, where we really want to forward traffic to VMs and that's
> all, promisc mode is an implementation detail. If true it's a mistake to
> expose it in an interface.  Here's an idea how we could make it work
> automatically:

This is something Stephen suggested earlier and controlling promisc mode
based on whether uplinks are set or not.

>
> - Like your patch does, allow two kinds of ports: port that only wants
>    specific addresses and "wildcard" port that can get all addresses
>    All ports default to wildcard as a compatible way
> - For port A, if there is some wildcard port besides A, A must be
>    promiscous since maybe it needs to get packets that will be later
>    forwardd to A
> - For port A, if there are no wildcard ports, or if A is the only
>    wildcard, A does not need to be promiscous.
>    Instead we can program it with addresses of all other ports.

So, according to the above, you can only ever have 1 port that is 
'address specific'.  If you have more then one, they have to be 
promiscuous to allow bridging between them.

The alternative might be to manipulate mac filter based on the
addresses learned.  This will most likely rather quickly put the port in 
promiscuous mode anyway if the event that a bridge is not really an edge 
device.

-vlad
>
> Exactly same logic applies, separately, for unicast, where promisc
> means all uni, and multicast, where promisc means all multi.
>
> Now there's no special unplink port, no need to enable/disable special
> mode, nothing: just program addresses for ports and go.
>
>
>> Changes since rfc v2:
>> * Sync/unsync address on uplink upon the uplink flag change.  This allows
>> for uplink replacements without loss of addresses.
>>
>> Changes since rfc v1:
>> * Fixed submit log
>> * Simplifyied uplink logic.  Uplink is now a flag per port.  This removes the
>>    need for a separate list.
>> * Clean-up hw list once the port has been removed.
>>
>> Vlad Yasevich (4):
>>    bridge: Add sysfs interface to control promisc mode
>>    bridge: Allow an ability to designate an uplink port
>>    bridge: Implement IFF_UNICAST_FLT
>>    bridge: sync device list when a new uplink is designated
>>
>>   include/uapi/linux/if_link.h |    1 +
>>   net/bridge/br_device.c       |   52 +++++++++++++++++++++++++++++++++++++++++-
>>   net/bridge/br_fdb.c          |    6 +++++
>>   net/bridge/br_if.c           |   24 +++++++++++++++----
>>   net/bridge/br_netlink.c      |   13 ++++++++++
>>   net/bridge/br_private.h      |    3 ++
>>   net/bridge/br_sysfs_br.c     |   17 +++++++++++++
>>   net/bridge/br_sysfs_if.c     |   27 +++++++++++++++++++++
>>   8 files changed, 137 insertions(+), 6 deletions(-)
>>
>> --
>> 1.7.7.6
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
