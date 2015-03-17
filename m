From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4] switchdev: fix stp update API to work with
 layered netdevices
Date: Tue, 17 Mar 2015 05:42:23 -0700
Message-ID: <5508212F.9090006@cumulusnetworks.com>
References: <1426527159-8039-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bDSUaUvhQQ5jHFSU9bJ8fQt1O=2jzi_NjipiqQ-hRUbzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:33931 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206AbbCQMmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 08:42:24 -0400
Received: by pdbni2 with SMTP id ni2so8800167pdb.1
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 05:42:24 -0700 (PDT)
In-Reply-To: <CAE4R7bDSUaUvhQQ5jHFSU9bJ8fQt1O=2jzi_NjipiqQ-hRUbzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/16/15, 11:10 PM, Scott Feldman wrote:
> On Mon, Mar 16, 2015 at 10:32 AM,  <roopa@cumulusnetworks.com> wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> make it same as the netdev_switch_port_bridge_setlink/dellink
>> api (ie traverse lowerdevs to get to the switch port).
>>
>> removes "WARN_ON(!ops->ndo_switch_parent_id_get)" because
>> direct bridge ports can be stacked netdevices (like bonds
>> and team of switch ports) which may not imeplement this ndo.
>>
>> v2 to v3:
>>          - remove changes to bond and team. Bring back the
>>          transparently following lowerdevs like i initially
>>          had for setlink/getlink
>>          (http://www.spinics.net/lists/netdev/msg313436.html)
>>          dave and scott feldman also seem to prefer it be that
>>          way and move to non-transparent way of doing things
>>          if we see a problem down the lane.
>>
>> v3 to v4:
>>          - fix ret initialization
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>>   net/switchdev/switchdev.c |   20 ++++++++++++++++----
>>   1 file changed, 16 insertions(+), 4 deletions(-)
>>
>> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>> index c9bfa00..e593b59 100644
>> --- a/net/switchdev/switchdev.c
>> +++ b/net/switchdev/switchdev.c
>> @@ -47,11 +47,23 @@ EXPORT_SYMBOL_GPL(netdev_switch_parent_id_get);
>>   int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
>>   {
>>          const struct swdev_ops *ops = dev->swdev_ops;
>> +       struct net_device *lower_dev;
>> +       struct list_head *iter;
>> +       int ret = -EOPNOTSUPP, err;
>>
>> -       if (!ops || !ops->swdev_port_stp_update)
>> -               return -EOPNOTSUPP;
>> -       WARN_ON(!ops->swdev_parent_id_get);
>> -       return ops->swdev_port_stp_update(dev, state);
>> +       if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
>> +               return ret;
> I would drop the NETIF_F_HW_SWITCH_OFFLOAD check.  It's not telling
> you anything more than the next test for ops->swdev_port_stp_update.

This was mainly to avoid lowerdev walk where you know that the dev does 
not have the feature.
example: the bond carries this feature flag  if any of its slaves have it.
The lowerdev walk can be stopped at the bond.

I don't mind removing the check, if you prefer that.

thanks,
Roopa
