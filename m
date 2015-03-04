From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
 setlink handler
Date: Wed, 04 Mar 2015 00:51:20 -0800
Message-ID: <54F6C788.2010201@cumulusnetworks.com>
References: <1425428129-48365-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bArwsNUdtNM25Zm=ZccrmVqC8e45E6qsjMdO3s0FrOVog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:32881 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755481AbbCDIvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 03:51:22 -0500
Received: by pdev10 with SMTP id v10so9280315pde.0
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 00:51:21 -0800 (PST)
In-Reply-To: <CAE4R7bArwsNUdtNM25Zm=ZccrmVqC8e45E6qsjMdO3s0FrOVog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/3/15, 11:02 PM, Scott Feldman wrote:
> On Tue, Mar 3, 2015 at 4:15 PM,  <roopa@cumulusnetworks.com> wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> With the recent addition of the NETIF_F_HW_SWITCH_OFFLOAD flag
>> on rocker ports, the second command (bridge link set) below will turn off
>> learning in the rocker hw (Scott/Jiri, need some confirmation from
>> you that this is indeed a problem and if the below patch is ok).
>>
>> ip link set dev swp1 master br0
>> bridge link set dev swp1 learning off master
>> bridge link set dev swp1 learning_sync on self
>>
>> This patch fixes rocker to ignore learning setting when 'master'
>> is set. This makes it possible to set/unset learning in kernel and bridge
>> driver independently.
>>
>> The below command will continue to set learning on in both kernel and rocker
>> hw:
>> bridge link set dev swp1 learning on
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>>   drivers/net/ethernet/rocker/rocker.c |    3 +++
>>   1 file changed, 3 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>> index e5a15a4..d7c31d2 100644
>> --- a/drivers/net/ethernet/rocker/rocker.c
>> +++ b/drivers/net/ethernet/rocker/rocker.c
>> @@ -3769,6 +3769,9 @@ static int rocker_port_bridge_setlink(struct net_device *dev,
>>          struct nlattr *attr;
>>          int err;
>>
>> +       if (flags && !(flags & BRIDGE_FLAGS_SELF))
>> +               return 0;
>> +
>>          protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
>>                                     IFLA_PROTINFO);
>>          if (protinfo) {
>
> NACK on this patch.  This is the problem with netlink creeping into
> ndo ops: it's too tempting to push work-arounds down to driver.
netlink has already crept into the driver. You do parse the netlink 
message right below.
The patch actually does not touch the message. It is just using one of 
the args already passed to the handler.

> In this case, you're making the driver check to see if it's SELF when
> it's already SELF by definition.
>
> Rocker setlink wasn't broken prior to the NETIF_F_HW_SWITCH_OFFLOAD
> patches.
>   Now it is,
sure, I can submit a patch to remove the flag on rocker ports if thats 
what you prefer.

> but this isn't the right fix.
>
> Can we revisit this so these two commands only hit MASTER:
>
>     bridge link set dev swp1 learning on
>     bridge link set dev swp1 learning on master
>
> And this one hits SELF:
>
>      bridge link set dev swp1 learning on self

For the above to work you just need to remove the feature flag in the driver (i can submit a patch).

The reason why it is useful to have it the way it currently is:

the setlink request does not always only contain the 'learning' flag.
It handles vlans too. I dont see rocker parsing vlans yet ie 
IFLA_AF_SPEC (or did i miss it ?)
and in those cases I thought it would be nice to pass the vlan info to 
the rocker ports when it
is added to the bridge driver.

For example the below command will hit the kernel bridge driver and 
rocker today.

bridge vlan add vid 10-20 dev swp1

If you remove the feature flag, you will have to run both

bridge vlan add vid 10-20 dev swp1
bridge vlan add vid 10-20 dev swp1 self


Let me know,
Thanks,
Roopa


   
