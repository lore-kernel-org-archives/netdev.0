From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC 0/5] Add NTF_EXT_AGED to control FDB ageing
 in SW or HW
Date: Sat, 21 Feb 2015 10:29:11 -0800
Message-ID: <54E8CE77.3050709@cumulusnetworks.com>
References: <1424416195-19098-1-git-send-email-sfeldma@gmail.com> <54E76EFA.1050209@cumulusnetworks.com> <54E7876A.3060303@gmail.com> <FFEDCF9956066D4D97C463CC178C7F69F22E02@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"linux@roeck-us.net" <linux@roeck-us.net>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"siva.mannem.lnx@gmail.com" <siva.mannem.lnx@gmail.com>
To: Viswanath Bandaru <vbandaru@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:43098 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbbBUS3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 13:29:13 -0500
Received: by pdev10 with SMTP id v10so15169060pde.10
        for <netdev@vger.kernel.org>; Sat, 21 Feb 2015 10:29:13 -0800 (PST)
In-Reply-To: <FFEDCF9956066D4D97C463CC178C7F69F22E02@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/20/15, 4:20 PM, Viswanath Bandaru wrote:
>> -----Original Message-----
>> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
>> Sent: Saturday, February 21, 2015 12:44 AM
>> To: roopa; sfeldma@gmail.com
>> Cc: netdev@vger.kernel.org; jiri@resnulli.us; linux@roeck-us.net;
>> andrew@lunn.ch; gospo@cumulusnetworks.com; Viswanath Bandaru;
>> siva.mannem.lnx@gmail.com
>> Subject: Re: [PATCH net-next RFC 0/5] Add NTF_EXT_AGED to control FDB
>> ageing in SW or HW
>>
>> On 20/02/15 09:29, roopa wrote:
>>> On 2/19/15, 11:09 PM, sfeldma@gmail.com wrote:
>>>> From: Scott Feldman <sfeldma@gmail.com>
>>>>
>>>> Add a new NTF_EXT_FLAG to mark an FDB as externally aged, for example
>> by
>>>> offload hardware.   Switchdev driver/devices can set this flag when
>>>> learning a
>>>> new FDB entry and SW (the bridge driver) will skip this entry when
>>>> running its ageing task.  If flag is set, the driver/device is
>>>> responsible for calling
>>>> call_netdev_switch_notifiers(NETDEV_SWITCH_FDB_DEL, ...) when entry
>>>> expires.
>>>>
>>>> This give the flexibility for driver/device to decide ageing policy
>>>> based on its capabilities.  For devices managing many FDB entries, it
>>>> is desireable for the device to aged out its own entries.  Devices
>>>> not capable of aged entries can rely of SW to age out the entries.
>>>>
>>> scott, patches look good. However, I am not sure yet if there is a
>>> need to make it a per fdb entry flag.
>> I agree, in fact, most of the HW I have access to only has a global age timer
>> configuration knob. Is this configurable on a per-port basis for higher end
>> switches, or even maybe per-FDB entry?
>>
> The decision to age an entry is on a per-FDB entry, So if the flag is not available in the fdb-entry, then it has to be obtained from associated netdev. I think the per-FDB may be more convenient than keeping it on netdev.

I was not saying netdev, but the bridge could have it...something like 
the below:

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index e0670d7..1815924 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -280,7 +280,8 @@ void br_fdb_cleanup(unsigned long _data)

                 hlist_for_each_entry_safe(f, n, &br->hash[i], hlist) {
                         unsigned long this_timer;
-                       if (f->is_static)
+                       if (f->is_static || (f->added_by_external_learn &&
+                               br->hw_aging_enabled))
                                 continue;
                         this_timer = f->updated + delay;
                         if (time_before_eq(this_timer, jiffies))
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index de09199..68bfb4b 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -246,6 +246,7 @@ struct net_bridge

         unsigned char                   topology_change;
         unsigned char                   topology_change_detected;
+       unsigned char                   hw_aging_enabled;

  #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
         unsigned char                   multicast_router;


I have no objections to the current patchset (they clearly fix the 
problem). I was only wondering if the notion of aging can continue to 
stay in the bridge
and not be carried into every fdb entry. which seems cleaner to me.


>
>>> At some point we will also need the hw ageing parameter to be
>> configurable.
>>> So other approach could be,
>>> - ageing parameter on bridge gets offloaded the hw
> Like everybody said, the ageing is really the switch's property.  If there are two bridges with ports from same switching device, it becomes tricky to configure ageing time on the switch.  ( I think this is what you may be referring to be saying it needs more thought).
Regarding the two bridges with ports from the same switching device, I 
think the switch driver should handle that. Maybe min value etc as 
discussed further in this thread.

Today given that most people are going to use the vlan filtering bridge 
and most likely prefer having a single vlan filtering bridge represent 
their swicth (we do in most cases), I see this being a non critical 
problem to solve.

Thanks,
Roopa
