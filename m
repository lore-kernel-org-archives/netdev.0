From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH v2 rfc 0/8] IGMP snooping for local traffic
Date: Wed, 6 Sep 2017 12:52:32 +0300
Message-ID: <4ef8c5d7-4a2b-80eb-65ee-53d6c1631924@cumulusnetworks.com>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
 <20170905171141.7040519b@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, jiri@resnulli.us,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:33263 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752319AbdIFJwh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 05:52:37 -0400
Received: by mail-wm0-f51.google.com with SMTP id f145so15705915wme.0
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 02:52:36 -0700 (PDT)
In-Reply-To: <20170905171141.7040519b@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/09/17 03:11, Stephen Hemminger wrote:
> On Wed,  6 Sep 2017 01:35:02 +0200
> Andrew Lunn <andrew@lunn.ch> wrote:
> 
>> After the very useful feedback from Nikolay, i threw away what i had,
>> and started again. To recap:
>>
>> The linux bridge supports IGMP snooping. It will listen to IGMP
>> reports on bridge ports and keep track of which groups have been
>> joined on an interface. It will then forward multicast based on this
>> group membership.
>>
>> When the bridge adds or removed groups from an interface, it uses
>> switchdev to request the hardware add an mdb to a port, so the
>> hardware can perform the selective forwarding between ports.
>>
>> What is not covered by the current bridge code, is IGMP joins/leaves
>> from the host on the brX interface. These are not reported via
>> switchdev so that hardware knows the local host is interested in the
>> multicast frames.
>>
>> Luckily, the bridge does track joins/leaves on the brX interface. The
>> code is obfusticated, which is why i missed it with my first attempt.
>> So the first patch tries to remove this obfustication. Currently,
>> there is no notifications sent when the bridge interface joins a
>> group. The second patch adds them. bridge monitor then shows
>> joins/leaves in the same way as for other ports of the bridge.
>>
>> Then starts the work passing down to the hardware that the host has
>> joined/left a group. The existing switchdev mdb object cannot be used,
>> since the semantics are different. The existing
>> SWITCHDEV_OBJ_ID_PORT_MDB is used to indicate a specific multicast
>> group should be forwarded out that port of the switch. However here we
>> require the exact opposite. We want multicast frames for the group
>> received on the port to the forwarded to the host. Hence add a new
>> object SWITCHDEV_OBJ_ID_HOST_MDB, a multicast database entry to
>> forward to the host. This new object is then propagated through the
>> DSA layers. No DSA driver changes should be needed, this should just
>> work...
>>
>> Getting the frames to the bridge as requested turned up an issue or
>> three. The offload_fwd_mark is not being set by DSA, so the bridge
>> floods the received frames back to the switch ports, resulting in
>> duplication since the hardware has already flooded the packet. Fixing
>> that turned up an issue with the meaning of
>> SWITCHDEV_ATTR_ID_PORT_PARENT_ID in DSA. A DSA fabric of three
>> switches needs to look to the software bridge as a single
>> switch. Otherwise the offload_fwd_mark does not work, and we get
>> duplication on the non-ingress switch. But each switch returned a
>> different value. And they were not unique.
>>
>> The third and last issue will be explained in a followup email.
>>
>> Open questions:
>>
>> Is sending notifications going to break userspace?
>> Is this new switchdev object O.K. for the few non-DSA switches that exist?
>> Is the SWITCHDEV_ATTR_ID_PORT_PARENT_ID change acceptable?
>>
>>    Andrew
>>
>> Andrew Lunn (8):
>>   net: bridge: Rename mglist to host_joined
>>   net: bridge: Send notification when host join/leaves a group
>>   net: bridge: Add/del switchdev object on host join/leave
>>   net: dsa: slave: Handle switchdev host mdb add/del
>>   net: dsa: switch: handle host mdb add/remove
>>   net: dsa: switch: Don't add CPU port to an mdb by default
>>   net: dsa: set offload_fwd_mark on received packets
>>   net: dsa: Fix SWITCHDEV_ATTR_ID_PORT_PARENT_ID
>>
>>  include/net/switchdev.h   |  1 +
>>  net/bridge/br_input.c     |  2 +-
>>  net/bridge/br_mdb.c       | 50 +++++++++++++++++++++++++++++---
>>  net/bridge/br_multicast.c | 18 +++++++-----
>>  net/bridge/br_private.h   |  2 +-
>>  net/dsa/dsa.c             |  1 +
>>  net/dsa/dsa_priv.h        |  7 +++++
>>  net/dsa/port.c            | 26 +++++++++++++++++
>>  net/dsa/slave.c           | 16 ++++++++---
>>  net/dsa/switch.c          | 72 +++++++++++++++++++++++++++++++++++++++--------
>>  net/switchdev/switchdev.c |  2 ++
>>  11 files changed, 168 insertions(+), 29 deletions(-)
>>
> 
> This looks much cleaner. I don't have DSA hardware or infrastructure to look deeper.
> 

+1

This version looks great!
