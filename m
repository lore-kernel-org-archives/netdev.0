From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 01/26] switchdev: introduce get/set attrs
 ops
Date: Fri, 03 Apr 2015 18:44:05 -0700
Message-ID: <551F41E5.9020600@cumulusnetworks.com>
References: <1427962212-18411-1-git-send-email-sfeldma@gmail.com> <1427962212-18411-2-git-send-email-sfeldma@gmail.com> <CAGVrzcZvzWDeV7XvZx13fK_u0oYD=mAJKQ5JUNm9UhirBqAHow@mail.gmail.com> <CAE4R7bD9-H_U3ys9hsOx=o51b4rTjjyq3BYBXMmSeXRrvRupSQ@mail.gmail.com> <20150402181606.GF2613@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	"Arad, Ronen" <ronen.arad@intel.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:32903 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635AbbDDBoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 21:44:08 -0400
Received: by paboj16 with SMTP id oj16so51583688pab.0
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 18:44:07 -0700 (PDT)
In-Reply-To: <20150402181606.GF2613@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/2/15, 11:16 AM, Jiri Pirko wrote:
> Thu, Apr 02, 2015 at 07:52:28PM CEST, sfeldma@gmail.com wrote:
>> On Thu, Apr 2, 2015 at 2:09 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>> [snip]
>>>
>>>> +       int err = -EOPNOTSUPP;
>>>> +
>>>> +       if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
>>>> +               return err;
>>> That check is currently going to prevent DSA from working, since we do
>>> not yet advertise NETIF_HW_SWITCH_OFFLOAD (which should be fixed). In
>>> general, though I am not sure this is entirely desirable to check that
>>> here for multiple reasons:
>>>
>>> - stacked devices typically propagate lower devices dev->features, but
>>> if they are purposely not doing it, this might start breaking
>>> - is not that check, used as it is now, that unconditionally, end-up
>>> being redundant with e.g: getting the switch device id to identify
>>> this net_device as a switch port net_device?
>>>
>>> I kind of preferred when we had this moved into the
>>> __swdev_attr_{get,set} caller, such we had finer control over whether
>>> or not checking for these kinds of features makes sense for a
>>> particular operation.
>> I dropped it in my v1 patch set all together, but then it came back in
>> v2.  I understand how it works, giving the user the ability to turn
>> on/off offload support on a port at run-time, but I don't understand
>> the application.  I agree with you that we already have finer-grained
>> ability to know if a sub-feature is supported or not based on what the
>> driver implements (like switch ID or STP state).  I don't know what
>> this master switch is used for.  Why would the user turn off
>> offloading on a port at run-time after the device has already been
>> programmed with some offloading tasks?  What tells the device to stop
>> those offloads now.  And then later, the user flips the switch to turn
>> back on offloads on the port.   How do we restore the device?
>>
>> Roopa, can you help us understand how NETIF_F_HW_SWITCH_OFFLOAD is used?
> Documentation patch required?
I can provide a documentation patch.
The use for this today is:
a) to recognize a switch port, instead of walking lowerdevs all the time 
(sometimes this could be in the packet path).
b) There are drivers today that support bridge l2 ndo ops only via 
'self' (directly going to the nic driver).
the bridge driver vlan offload bridge_setlink/bridge_getlink switchdev 
calls also use the same ndo ops when you add a vlan to a bridge (this is 
from within the bridge driver. Same will be true for fdb). This flag 
also serves the purpose of not breaking those drivers because they dont 
advertise this flag
c) I see it as a nice switch to turn off offload in some environments. 
The driver has a choice to support this or simply reject it.
In the cases where it supports it, maybe it could flush all its tables 
and send pkts to software.

Agree that the use of swdev_get_parent_id in the same place is making it 
redundant.
In the initial days, if i remember correctly, we used an ndo op with a 
similar name that was also shared by other nic
devices... which made it difficult to rely on the op.

since the rest of the kernel has always used features on netdev instead 
of ops, seems like a feature check instead of a 'op' check will keep it 
consistent.

Thanks,
Roopa
