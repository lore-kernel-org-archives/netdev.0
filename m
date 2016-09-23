From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: VRF: Fix receiving multicast traffic
Date: Fri, 23 Sep 2016 07:49:34 -0600
Message-ID: <1bb15beb-fbab-c365-2519-11cf9d13007c@cumulusnetworks.com>
References: <20160922041308.30848-1-mark.tomlinson@alliedtelesis.co.nz>
 <aac5b560-d757-3281-8e69-7953e7c4b418@cumulusnetworks.com>
 <ee8de997-007c-4035-5f65-a8b389a138ac@alliedtelesis.co.nz>
 <319068be-b1b9-c245-55d6-5e012e57487b@cumulusnetworks.com>
 <f1ead8ba-5404-36f3-40a9-35105006017d@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Mark Tomlinson <Mark.Tomlinson@alliedtelesis.co.nz>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:34268 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034532AbcIWNtp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 09:49:45 -0400
Received: by mail-io0-f174.google.com with SMTP id e66so28937196iod.1
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 06:49:40 -0700 (PDT)
In-Reply-To: <f1ead8ba-5404-36f3-40a9-35105006017d@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/22/16 9:06 PM, Mark Tomlinson wrote:
> 
> On 09/23/2016 10:41 AM, David Ahern wrote:
>> On 9/22/16 4:10 PM, Mark Tomlinson wrote:
>>> On 09/23/2016 03:14 AM, David Ahern wrote:
>>>> l3mdev devices do not support IPv4 multicast so checking mcast against that device should not be working at all. For that reason I was fine with the change in the previous patch. ie., you want the real ingress device there not the vrf device.
>>>>
>>>> What test are you running that says your previous patch broke something?
>>> Although we do not expect any multicast routing to work in an l3mdev,
>>> (IGMP snooping or PIM), we still want to have multicast packets
>>> delivered for protocols such as RIP. This was working before my previous
>>> patch, but these multicast packets are now dropped. This current patch
>>> fixes that again, hopefully still with the benefits of my first patch.
>>>
>> can you discern which check is making that happen?
>>
>> It does not make sense to look at the in_device of a vrf device for mcast addresses. For IPv6 linklocal and mcast is specifically blocked. IPv4 should do the same. So, how is RIP getting the packet at all?
> This might be due to some other changes we've made for VRF and multicast 
> but haven't sent upstream. In particular, a change to do_ip_setsockopt() 
> and its handling of IP_MULTICAST_IF as well as IP_ADD/DROP_MEMBERSHIP. I 
> am guessing that without these changes, we wouldn't be able to receive 
> multicast packets in RIP. With our changes, the in_dev->mc_list does 
> contain the RIP MC address (224.0.0.9) in the master interface, and so 
> the function ip_check_mc_rcu() returns success with the master only.
> 
> Our RIP daemon is VRF-aware. So it does use setsockopt(SO_BINDTODEVICE, 
> "vrf-master") when running in a VRF. Without following it all the way 
> down, I believe that it is this that allows the multicast lookup at the 
> top of ip_check_mc_rcu() to succeed on the vrf-master, but not the 
> ingress interface. That is, in_dev->mc_list does contain 224.0.0.9 only 
> on the vrf-master. Provided the lookup in ip_check_mc_rcu() succeeds (im 
> != NULL), this function can return success.
> 
> Are you interested in the other patches at the moment?
> 

Yes, but with the context of the bigger IPv4 multicast solution. I am on PTO today - about to get on a plane. How about we leave the upstream kernel as is - i.e., drop this patch. You can carry it locally with the others. We can take a look at the bigger mcast picture for 4.10. Agree?
