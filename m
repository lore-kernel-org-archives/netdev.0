From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH net-next 2/4] gtp: add genl cmd to enable GTP
 encapsulation on UDP socket
Date: Tue, 14 Mar 2017 13:28:25 +0100 (CET)
Message-ID: <1491326012.385002.1489494505868.JavaMail.zimbra@tpip.net>
References: <20170314112548.24027-1-aschultz@tpip.net> <20170314112548.24027-3-aschultz@tpip.net> <20170314114330.GB2992@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: laforge <laforge@gnumonks.org>,
        osmocom-net-gprs <osmocom-net-gprs@lists.osmocom.org>,
        netdev <netdev@vger.kernel.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>
To: pablo <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:35466 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751115AbdCNM2a (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 08:28:30 -0400
In-Reply-To: <20170314114330.GB2992@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- On Mar 14, 2017, at 12:43 PM, pablo pablo@netfilter.org wrote:

> On Tue, Mar 14, 2017 at 12:25:46PM +0100, Andreas Schultz wrote:
> 
>> @@ -1254,6 +1293,8 @@ static struct nla_policy gtp_genl_policy[GTPA_MAX + 1] = {
>>  	[GTPA_NET_NS_FD]	= { .type = NLA_U32, },
>>  	[GTPA_I_TEI]		= { .type = NLA_U32, },
>>  	[GTPA_O_TEI]		= { .type = NLA_U32, },
>> +	[GTPA_PDP_HASHSIZE]	= { .type = NLA_U32, },
> 
> This per PDP hashsize attribute clearly doesn't belong here.
> 
> Moreover, we now have a rhashtable implementation, so we hopefully we
> can get rid of this. It should be very easy to convert this to use
> rhashtable, and it is very much desiderable.

This would mean I have to mix the unrelated rhashtable change with moving the
hash into the socket. This certainly is not desirable either.

So, I'm going to have a look at the rhashtable thing and send a patch first
to convert the hashes to it.

>> +	[GTPA_FD]		= { .type = NLA_U32, },
> 
> This new atttribute has nothing to do with the PDP context.
> And enum gtp_attrs *only* describe a PDP context. Adding more
> attributes there to mix semantics is not the way to go.

You seem to assume that the network device or the APN/VRF is the root entity
for the GTP tunnels. That is IMHO wrong. The 3GPP specification clearly defines
a GTP entity that is completely Independent from an APN or the local IP endpoint.

A GTP entity serves multiple local IP endpoints, It manages outgoing tunnels
by the local APN/VRF, source IP, destination IP and remote tunnel id, incoming
tunnels are managed by the local destination IP, local tunnel id and VRF/APN.

Therefor a PDP context needs the following attributes:

 * local source/destination IP (and port - but that's for different series)
 * remote destination IP
 * local and remote TEID
 * VRF/APN

The local source and destination IP is implicitly contained in the socket, therefor
the socket needs to part of the context. The VRF/APN is contained in the network
device reference. So this also needs to part of the PDP context.

Having either the socket or the network device as the sole root container for a
GTP entity is wrong since the PDP context always refer both.

> You likely have to inaugurate a new enum. This gtp_attrs enum only
> related to the PDP description.
> 
> Why not add some interface to attach more sockets to the gtp device
> globally? So still the gtp device is the top-level structure. 

That is IMHO the wrong model. In a real live setup it likely to have a
few GTP sockets and possibly hundreds if not thousands of network device
attached to them (we already had the discussion why this kind of sharing
makes sense). 
So from a resource perspective alone, having the network device as root makes
no sense.

> Then add
> a netlink attribute to specify to what VRF this tunnel belongs to,
> instead of implicitly using the socket to achieve this.

You got that the wrong way arround. The VRF is already in the PDP context
through the network device reference. The socket is added to the PDP context
to select the outgoing source IP of the GTP tunnel in order to support
multiple GTP source IP's per GTP entity.

> Another possibility is to explicitly have an interface to add
> new/delete VRFs, attach sockets to them.

We already have that interface. It's the create a GTP network interface
genl API. I explained a few lines above why I think that adding sockets to
GTP network devices is wrong.

> In general, I'm still not convinced this is the right design for this.

Following your "add VRF" idea, I would end up with a pseudo network device
that represents a GTP entity. This would be the root instance for all the
VRF's and GTP sockets. Although being a network device, it would not
behave in any way like a network device, it would not handle traffic or
have IP(v6) addresses attached to it.
I would then further have GTP VRF network devices. Those would be "real"
network device that handle traffic and have IP addresses/route attached
to them.

I'm not sure if this pseudo GTP entity root device fits well with
other networking concepts. And more over, I can't really see the need
for such an construct.

This need for an in-kernel root entity seem to come the concept that
the kernel *owns* the tunnels and that tunnel a static and independent
from the user space control instance.

I think that the user space control instance should own the tunnels and
only use the kernel facility to manage them. When the user space instance
goes away, so should the tunnels.
>From that perspective,  I want to keep the kernel facilities to the absolute
needed minimum.

Regards 
Andreas
