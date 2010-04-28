From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next-2.6 PATCH 1/2] Add netdev port-profile support (take
 III, was iovnl)
Date: Wed, 28 Apr 2010 10:51:36 -0700
Message-ID: <C7FDC3B8.2C7EB%scofeldm@cisco.com>
References: <201004281513.58879.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<chrisw@redhat.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:13410 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756054Ab0D1Rvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 13:51:54 -0400
In-Reply-To: <201004281513.58879.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/28/10 6:13 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:

> On Wednesday 28 April 2010, Scott Feldman wrote:
>>        ip link set DEVICE [ { up | down } ]
>>                           [ arp { on | off } ]
>>                           [ dynamic { on | off } ]
>>                           [ multicast { on | off } ]
>>                           ...
>>                           [ vf NUM [ mac LLADDR ]
>>                                    [ vlan VLANID [ qos VLAN-QOS ] ]
>>                                    [ rate TXRATE ] ]
>>                           [ port_profile [ PORT-PROFILE
>>                                    [ mac LLADDR ]
>>                                    [ host_uuid HOST_UUID ]
>>                                    [ client_uuid CLIENT_UUID ]
>>                                    [ client_name CLIENT_NAME ] ] ]
>>        ip link show [ DEVICE ]
> 
> We will need a few more options to cover draft VDP in addition to the protocol
> your NIC is using. I still think it's possible to use the same interface
> for both, but the differences are obviously showing.
> 
> The missing bits that I can see so far are:
> 
> - You only have 'get' and 'set'. We will also need a 'unset' or 'delete'
>   option in order to get rid of a port profile association.

That's there in my patch.  If you don't specify anything after port-profile
keyword, it's an unset.  See extra "[" and "]" above.  Will that work for
you?

> - VDP has three different ways to 'set' a port profile: 'associate',
>   'pre-associate with resource reservation' and 'pre-associate without
>   resource reservation'. This could become an extra option flag.

Ok, let's add an option flag bit field.  I'm not sure how that looks from
the iproute2 cmd line.  Would you take a stab at defining these?

> - Instead of a port profile name, VDP specifies a tuple like
>    struct vsi_associate {
> unsigned char VSI_Mgr_ID;       /* VSI manager ID */
> unsigned char VSI_Type_ID[3];   /* 24 bit VSI Type ID */
> unsigned char VSI_Type_Version; /* VSI Type version */
>    };
>    I'm not sure how to deal with that best, but there needs to be
>    some parsing of these numbers.

PORT-PROFILE above is a u8* array.  You could decide to encode the tuple in
a string, e.g. "1.12345.1", and let the receiver parse it?  Or pack it in as
binary.  PORT-PROFILE for us is just a string identifier, e.g. "corp-net-10"
or "joes-garage".

> - VDP requires a vlan ID to be part of the association, in addition to
>   the MAC address. In theory, we could have multiple tuples of MAC+VLAN
>   addresses, but we can probably just associate each tuple separately
>   and ignore that part of the standard.

I don't think I have enough information to spec this out for this item.
Would you take a stab at how this would look in the struct and how it would
look from the iproute2 cmd line?  (Note I'm using iproute2 cmd line for
illustrative purposes, but the sender of the msg could be something like
libvirt).

> - we have a set of possible error conditions that can be returned by
>   the switch (invalid format, insufficient resources, unknown VTID,
>   VTID violation, VTID verison violation, out of sync). It should be
>   possible to return each of these to the user with 'get'.

There is a status code in the get cmd as defined in my patch.  I have it as
a u8 with some enum codes.  Can we add to the enum code list?  Or do you
want to return a full string?  Our requirements are we return one of:
{success, error, in-progress}.
 
>> Since we're using netlink sockets, the receiver of the RTM_SETLINK msg can
>> be in kernel- or user-space.  For kernel-space recipient, rtnetlink.c, the
>> new ndo_set_port_profile netdev op is called to set the port-profile.
>> User-space recipients can decide how they propagate the msg to the switch.
>> There is also a RTM_GETLINK cmd to to return port-profile setting of an
>> interface and to also return the status of the last port-profile.
> 
> More on a stylistic note, I'm not convinced that using RTM_SETLINK/GETLINK
> is the right interface for this, unlike the 'ip link set DEV vf ...' stuff,
> because it seems to suggest that this is an option of the adapter itself.
> I actually liked the iovnl family better in this regard, because it kept
> the protocols separate.

Wait a second...I abandoned iovnl and moved to if_link based on suggestions
from you and others.  On 4/21/10 2:13 PM, "Arnd Bergmann" <arnd@arndb.de>
wrote:

   > Right. My preference would probably be make these a subcategory of
   > the if_link, and use the existing RTM_NEWLINK/RTM_DELLINK commands.

My latest with if_link fits best with what we're trying to do with enic.
Note the current interface is per netdev interface (a link), where the
netdev interface could be the adapter itself or any other netdev such as
macvlan, bond, etc.
 
> What I could imagine to unify this is something like
> 
>    ip port_profile set DEVICE [ { pre_associate | pre_associate_rr } ]
>                               { name PORT-PROFILE | vsi MGR:VTID:VER }
>                                     mac LLADDR
>    [ vlan VID ]
>                                     [ host_uuid HOST_UUID ]
>                                     [ client_uuid CLIENT_UUID ]
>                                     [ client_name CLIENT_NAME ]
>    ip port_profile del DEVICE [ mac LLADDR [ vlan VID ] ]
>    ip port_profile show DEVICE

If we want to break port_profile out into it's own ip cmd, I'm ok with that.
What you have above would work for enic.  The netdev would have these ops:

    ndo_set_port_profile
    ndo_get_port_profile
    ndo_del_port_profile

Sounds OK?

-scott

