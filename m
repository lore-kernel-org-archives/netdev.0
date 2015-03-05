From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
 setlink handler
Date: Thu, 05 Mar 2015 07:01:44 -0800
Message-ID: <54F86FD8.9000409@cumulusnetworks.com>
References: <1425428129-48365-1-git-send-email-roopa@cumulusnetworks.com> <20150305083621.GC2033@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:41318 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360AbbCEPBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 10:01:55 -0500
Received: by pablj1 with SMTP id lj1so37020070pab.8
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 07:01:55 -0800 (PST)
In-Reply-To: <20150305083621.GC2033@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/5/15, 12:36 AM, Jiri Pirko wrote:
> Wed, Mar 04, 2015 at 01:15:29AM CET, roopa@cumulusnetworks.com wrote:
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
>> drivers/net/ethernet/rocker/rocker.c |    3 +++
>> 1 file changed, 3 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>> index e5a15a4..d7c31d2 100644
>> --- a/drivers/net/ethernet/rocker/rocker.c
>> +++ b/drivers/net/ethernet/rocker/rocker.c
>> @@ -3769,6 +3769,9 @@ static int rocker_port_bridge_setlink(struct net_device *dev,
>> 	struct nlattr *attr;
>> 	int err;
>>
>> +	if (flags && !(flags & BRIDGE_FLAGS_SELF))
>> +		return 0;
>> +
> I think that the called should handle this case, not every particular
> driver. How about to put this into rtnl_bridge_setlink?

The problem is setlink can contain many more attributes than just learning.
And for most attributes you want to mirror them in hardware.
Only a few attributes like learning, you want to be able to set them in 
the kernel driver
differently than in hardware.

We have previously discussed encoding hw/sw in the upper bits of bridge 
port attributes.
I was trying to avoid that and use the existing master/self to achieve 
the same.

I will repost alternatives if I can think of something.

Thanks,
Roopa
