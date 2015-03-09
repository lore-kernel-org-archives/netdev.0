From: "Arad, Ronen" <ronen.arad@intel.com>
Subject: RE: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
 setlink handler
Date: Mon, 9 Mar 2015 15:59:13 +0000
Message-ID: <E4CD12F19ABA0C4D8729E087A761DC35067E6A8D@ORSMSX101.amr.corp.intel.com>
References: <CAE4R7bArwsNUdtNM25Zm=ZccrmVqC8e45E6qsjMdO3s0FrOVog@mail.gmail.com>
 <54F6C788.2010201@cumulusnetworks.com>
 <20150305080218.GB2033@nanopsycho.orion>
 <54F86E4B.9040403@cumulusnetworks.com>
 <CAE4R7bCQHcR4Ne-ssCRRvw0czKxRJfykcBFY6c_9haRF3pRJYA@mail.gmail.com>
 <54F8C00C.2010303@cumulusnetworks.com>
 <CAE4R7bAaLxCebc7cuYB9NQ_Duo8a6LvxWDwWOD9Wn8ROWjvDGw@mail.gmail.com>
 <54FC5A60.7000800@cumulusnetworks.com>
 <CAE4R7bDrhnK_a9dvyMqSJkGgod6AM=HDE6CAKkG_RnjuDxB2-Q@mail.gmail.com>
 <CAJieiUhHdXOZjWkb4s_GviLwzq5Gct-1o8xv8b-JeM46S4e-dg@mail.gmail.com>
 <20150309064043.GB2053@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Scott Feldman <sfeldma@gmail.com>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jiri Pirko <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40839 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753087AbbCIP7P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 11:59:15 -0400
In-Reply-To: <20150309064043.GB2053@nanopsycho.orion>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of Jiri Pirko
>Sent: Monday, March 09, 2015 6:41 AM
>To: Roopa Prabhu
>Cc: Scott Feldman; Netdev; David S. Miller
>Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
>setlink handler
>
>Mon, Mar 09, 2015 at 01:12:47AM CET, roopa@cumulusnetworks.com wrote:
>>On Sun, Mar 8, 2015 at 4:17 PM, Scott Feldman <sfeldma@gmail.com> wrote:
>>
>>> On Sun, Mar 8, 2015 at 7:19 AM, roopa <roopa@cumulusnetworks.com> wrote:
>>> > On 3/6/15, 1:52 AM, Scott Feldman wrote:
>>>
>>> [cut]
>>>
>>> >> I'm saying port driver's ndo_bridge_setlink shouldn't be called unless
>>> >> SELF is set.  The port driver shouldn't have to check if it's SELF,
>>> >> that's my main beef with this patch.  If the app (iproute2) wants to
>>> >> mirror an attribute, then it can set both MASTER and SELF.  This is
>>> >> consistent with ndo_fdb ops, where MASTER targets the bridge's FDB and
>>> >> SELF targets the device's FDB.
>>> >
>>> >
>>> > bridge setlink/dellink ndo sets/clears bridge port flags, vlans.
>>> >
>>> > 4 ways to the ndo op gets called (value in brackets is the bridge flags):
>>> >
>>> > 1. ndo_bridge_setlink ()
>>> > 2. ndo_bridge_setlink (master)
>>> > 3. ndo_bridge_setlink (self)
>>> > 4. ndo_bridge_setlink (master | self)
>>> >
>>> >
>>> > in case of 1) and 2) today, bridge driver also calls into the port driver
>>> > (as part of NETIF_F_HW_SWITCH_OFFLOAD) because vlans and other port flags
>>> > need to be offloaded if they are set on master (I understand that rocker
>>> > does not use bridge setlink ndo op for vlans. But it is completely valid
>>> for
>>> > a switch driver to use the ndo setlink op for offloading vlan config)
>>> >
>>> > One thing i can do is the NETIF_F_HW_SWITCH_OFFLOAD case only applies in
>>> > case 1 above. ie when bridge flags is zero.
>>> >
>>> > which leads to the following commands to disable learning in the bridge
>>> > driver and enable it in hw,
>>> >
>>> > 1. bridge link learning on - enable learning in both rocker and bridge
>>> > driver due to the NETIF_F_HW_SWITCH_OFFLOAD flag
>>> > 2. bridge link learning off master - learning disable only in the bridge
>>> > driver
>>> >
>>> > With this i think we hit a compromise, rocker setlink can be called when
>>> > flags is zero, but we still get a valid sequence of commands to
>>> > enable/disable certain port flags only in the bridge driver or port
>>> driver
>>> > without having an explicit self check in rocker.
>>> >
>>> > (my work laptop is broken..., I will re-post the patch tomorrow if you
>>> are
>>> > ok with the plan)
>>>
>>> I'm not OK with the plan; it doesn't address the issue.  I'm saying
>>> port driver's ndo_bridge_setlink shouldn't be called unless SELF is
>>> set.
>>>
>>
>>but, why scott ?. With l2, l3 and all other offloads, we try not to change
>>user commands.
>>Before switchdev 'self' was always used to go to nic drivers directly to
>>program fdb.
>>l2 never used the bridge driver.
>
>
>I also think that is is fine that in case either master or self are not set,
>driver ndo setlink is called as well (in case the offload bit is on). It
>makes it transparent for user in case he does not care what in under. In
>case he cares, he can specify master or self to achieve exactly what he
>needs. I like it that way.
>
>
It would be nice to have switch driver implementation that could work
Consistently with and without the bridge driver. I expect use case where a bridge is only used when L3 is needed or to leverage L2 protocols that are implemented by the bridge driver (e.g. STP, IGMP snooping).

If my driver can process setlink requests using SELF flag today, I'd like it
to work the same when setlink is propagated down from a bridge master or
from a team/bond master.

There is current issue with notification.
When SELF flag is set, the bridge driver does not offload to the port driver
and notification is issued by rtnetlink.c by calling the port getlink ndo.
This call, however, is done with zero filter_mask such that VLAN information
is not included in the notification.
When SELF flag is not set, bridge driver offloads to the port and issues the 
notification. In that case it sets the filter to VLAN_COMPRESSED.
I don't see how I can get my driver to behave consistently with and without
a bridge. 
The closest I can get notification with and without a bridge is for the
driver to examine the flags. If SELF is set, the driver knows it got invoked
directly from rtnetlink and it should notify VLAN setting as the subsequent
notification triggered by rtnetlink won't.
When the switch driver does not see SELF set it knows that it was invoked by
The bridge driver which already takes care of notification including VLAN
information. 

>
>>
>>with switchdev l2 offloads, we are using the bridge driver.
>>But there is a need to turn off/on some attributes in hw independently of
>>attributes in the kernel bridge driver. To that i had suggested we continue
>>to use 'self'
>>for those attributes without introducing a new hw mode.
>>
>>
>>>
>>> We have this currently, looking from the user's cmd:
>>>
>>> bridge link set                               calls into bridge and port
>>> driver
>>> bridge link set master                    calls into bridge and port driver
>>> bridge link set self                         calls into port driver
>>> bridge link set self master              calls into bridge and port driver
>>>
>>> Your proposal above changes it to:
>>>
>>> bridge link set                               calls into bridge and port
>>> driver
>>> bridge link set master                    calls into bridge
>>> bridge link set self                         calls into port driver
>>> bridge link set self master              calls into bridge and port driver
>>>
>>> Which is still no good because the default case (neither self or
>>> master explicitly set) calls into the port driver.  Before all of
>>> these changes, we had:
>>>
>>> bridge link set                               calls into bridge
>>> bridge link set master                    calls into bridge
>>> bridge link set hwmode veb|vepa     calls into port driver
>>>
>>> hwmode was a way to set SELF.  We wanted to add "self" flag to command
>>> to be more like bridge fdb cmd.  I assumed the default case (bridge
>>> set link) would continue to work as before.  So we'd have:
>>>
>>> bridge link set                               calls into bridge
>>> bridge link set master                    calls into bridge
>>> bridge link set self                         calls into port driver
>>> bridge link set self master              calls into bridge and port driver
>>>
>>> But that's not what we got.  Your changes changed the default case
>>> (and the bridge link set master case) to call into both bridge and
>>> port driver even though user didn't specify self.
>>>
>>
>>I have made sure that no default case has changed. It works this way only
>>when
>>the driver advertises offload using NETIF_F_HW_SWITCH_OFFLOAD.
>>Which means the driver is interested in involving the bridge driver in all
>>l2 offloads
>>(And this includes all bridge ndo ops setlink/dellink/stp/fdb).
>>
>>http://www.spinics.net/lists/netdev/msg314407.html
>>
>>
>>
>>
>>>
>>> How hard would it be to get back to original default behavior?
>>>
>>
>>Am not sure which default behavior you are talking about. If you are
>>talking about default behavior before switchdev,
>>that has not changed. For switch devices which want the bridge driver
>>involved and who advertise the NETIF_F_HW_SWITCH_OFFLOAD flag, this is new
>>behavior. And rocker does advertise this flag today.
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
