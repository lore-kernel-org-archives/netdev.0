From: Mark Tomlinson <Mark.Tomlinson@alliedtelesis.co.nz>
Subject: Re: [PATCH] net: VRF: Fix receiving multicast traffic
Date: Fri, 23 Sep 2016 03:06:42 +0000
Message-ID: <f1ead8ba-5404-36f3-40a9-35105006017d@alliedtelesis.co.nz>
References: <20160922041308.30848-1-mark.tomlinson@alliedtelesis.co.nz>
 <aac5b560-d757-3281-8e69-7953e7c4b418@cumulusnetworks.com>
 <ee8de997-007c-4035-5f65-a8b389a138ac@alliedtelesis.co.nz>
 <319068be-b1b9-c245-55d6-5e012e57487b@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
To: David Ahern <dsa@cumulusnetworks.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:49863 "EHLO
        gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933666AbcIWDGs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 23:06:48 -0400
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (Client did not present a certificate)
        by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id 75BD586053
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 15:06:44 +1200 (NZST)
In-Reply-To: <319068be-b1b9-c245-55d6-5e012e57487b@cumulusnetworks.com>
Content-Language: en-US
Content-ID: <00A66208CD316F428A43514C66273479@atlnz.lc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 09/23/2016 10:41 AM, David Ahern wrote:
> On 9/22/16 4:10 PM, Mark Tomlinson wrote:
>> On 09/23/2016 03:14 AM, David Ahern wrote:
>>> l3mdev devices do not support IPv4 multicast so checking mcast against =
that device should not be working at all. For that reason I was fine with t=
he change in the previous patch. ie., you want the real ingress device ther=
e not the vrf device.
>>>
>>> What test are you running that says your previous patch broke something=
?
>> Although we do not expect any multicast routing to work in an l3mdev,
>> (IGMP snooping or PIM), we still want to have multicast packets
>> delivered for protocols such as RIP. This was working before my previous
>> patch, but these multicast packets are now dropped. This current patch
>> fixes that again, hopefully still with the benefits of my first patch.
>>
> can you discern which check is making that happen?
>
> It does not make sense to look at the in_device of a vrf device for mcast=
 addresses. For IPv6 linklocal and mcast is specifically blocked. IPv4 shou=
ld do the same. So, how is RIP getting the packet at all?
This might be due to some other changes we've made for VRF and multicast=20
but haven't sent upstream. In particular, a change to do_ip_setsockopt()=20
and its handling of IP_MULTICAST_IF as well as IP_ADD/DROP_MEMBERSHIP. I=20
am guessing that without these changes, we wouldn't be able to receive=20
multicast packets in RIP. With our changes, the in_dev->mc_list does=20
contain the RIP MC address (224.0.0.9) in the master interface, and so=20
the function ip_check_mc_rcu() returns success with the master only.

Our RIP daemon is VRF-aware. So it does use setsockopt(SO_BINDTODEVICE,=20
"vrf-master") when running in a VRF. Without following it all the way=20
down, I believe that it is this that allows the multicast lookup at the=20
top of ip_check_mc_rcu() to succeed on the vrf-master, but not the=20
ingress interface. That is, in_dev->mc_list does contain 224.0.0.9 only=20
on the vrf-master. Provided the lookup in ip_check_mc_rcu() succeeds (im=20
!=3D NULL), this function can return success.

Are you interested in the other patches at the moment?
