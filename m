From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3 8/8] geneve: break dependency to network
 drivers
Date: Fri, 8 Jan 2016 22:18:06 +0100
Message-ID: <5690278E.5090903@stressinduktion.org>
References: <1452123571-19140-1-git-send-email-hannes@stressinduktion.org>
 <1452123571-19140-9-git-send-email-hannes@stressinduktion.org>
 <CAEh+42h79Sxc4JwzH_zMm+MZ-CmQWGdX1Qiz7epJmj2nCiAAVQ@mail.gmail.com>
 <5690204B.7000004@stressinduktion.org>
 <CAEh+42izmdn5hHBxQWfSQEduWE2OeY0puM-5DEU-iHTWYXdobQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:37740 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752162AbcAHVSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 16:18:09 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id DB7C7209FA
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 16:18:08 -0500 (EST)
In-Reply-To: <CAEh+42izmdn5hHBxQWfSQEduWE2OeY0puM-5DEU-iHTWYXdobQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.01.2016 22:12, Jesse Gross wrote:
> On Fri, Jan 8, 2016 at 12:47 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> On 07.01.2016 01:18, Jesse Gross wrote:
>>>
>>> I think we should merge vxlan_get_rx_port() and geneve_get_rx_port()
>>> into a single generic function. For drivers that support both, they
>>> now have two calls to get notified for all offloaded ports. This
>>> actually can cause problems related to duplicates, similar to what you
>>> feared before.
>>
>>
>> Checking out the ndo_add_vxlan_port callbacks, we cannot change how we
>> refresh the ports unfortunately. For some drivers it might be easy to
>> update, some look a little bit more complicated.
>>
>> I guess we should try to keep more complexity in the core and make sure we
>> only call those functions if necessary for the particular type of offload
>> than to replicate the logic in each driver.
>>
>> If you agree I prepare this series with the changes to have separate
>> callbacks, address your other feedback and send it out.
>
> I'm not sure that I totally understand, do you have an example of a
> problematic driver?

bnx2x e.g. does refcounting on the port. So when it will implement 
geneve offloading, it will refcount the vxlan port multiple times with 
the current schema. Currently this is safe, as bnx2x doesn't care about 
geneve and thus no further callbacks will happen. But I fear drivers 
being broken as soon as they implement geneve additionally with the 
current schema.

> I think what I was proposing is fairly simple, so maybe I wasn't
> totally clear. Here's what I think we can do:
>
> In your most recent series, vxlan_get_rx_port() and
> geneve_get_rx_port() have the same implementation. I think we can
> merge them into a single function (i.e. udp_tunnel_get_rx_port()). For
> all of the drivers that only implement VXLAN offloads, this is just a
> 1:1 switch so there should be no functionality change. There's only
> one driver than currently implements both (i40e) and it calls both
> vxlan_get_rx_port() and geneve_get_rx_port() back to back. We can just
> collapse this into a single call and since that will trigger both
> offloads to refresh, the behavior should again be the same as we have.

I totally understood that. I am just fearing future additions of offload 
while not updating the current vxlan offloading then as well.

My current series ATM implements just what you proposed.

> I do know that there are so drivers that try to do clever things as
> far as refcounting, etc. However, since the callbacks are the same as
> we did before, it shouldn't introduce any issues.

Agreed. I can push the series out now as you proposed and we have to 
intercept all upcoming driver changes in regard to geneve offloading and 
review them. :)

Bye,
Hannes
