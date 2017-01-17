From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net] lwtunnel: fix autoload of lwt modules
Date: Tue, 17 Jan 2017 17:26:02 +0000
Message-ID: <0e226af4-cb62-9b20-f8a2-191b0aaffb11@brocade.com>
References: <1484631185-9428-1-git-send-email-dsa@cumulusnetworks.com>
 <e6637ef9-02e4-bbfc-b5f0-bdd7c560714e@brocade.com>
 <8b621810-f7b3-05bb-413b-29389125c6ea@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>,
        roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:57942 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750863AbdAQR0P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 12:26:15 -0500
In-Reply-To: <8b621810-f7b3-05bb-413b-29389125c6ea@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/01/17 17:07, David Ahern wrote:
> On 1/17/17 3:04 AM, Robert Shearman wrote:
>> Is it safe to release the rtnl lock here? E.g. neither fib_get_nhs nor fib_create_info take a reference on the device and further up inet_rtm_newroute has a pointer to the struct fib_table without taking a reference.
>
> fib tables can not be deleted so that reference is safe.

Looks like we can free a table on unmerging. Admittedly this is the 
local table so is unlikely to be one that lwtunnels are used on, but 
does it not need to be safe against races anyway?

> You are right about the dev reference in the IPv4 path but the thing is build_state does not need the device reference.
>
> Roopa: do you recall why dev is passed to build_state? Nothing about the encap should require a device reference and none of the current encaps use it.
>
>>
>> Unfortunately, I think more invasive changes are required to solve this. I'm happy to work on solving this.
>
> I have a patch that removes passing dev to build_state. Walking the remainder of the code I do not see any more references that would be affected by dropping rtnl here on the add path. Still looking at the delete path.
>

Ok, I'll continue looking too and let you know if there's anything else 
that pops up.

Having said that, even if we eliminate all the unreferenced objects in 
the current code, what are the chances that we'll be able to keep it 
this way going forward? Perhaps it would be safer to retry the insert 
operation from as close to the start as possible?

Thanks,
Rob
