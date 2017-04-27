From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next V3 2/2] rtnl: Add support for netdev event
 attribute to link messages
Date: Thu, 27 Apr 2017 15:43:07 -0400
Message-ID: <7b5396ae-0cf3-2a1e-9c49-5d6f031adf58@redhat.com>
References: <1492795881-11914-1-git-send-email-vyasevic@redhat.com>
 <1492795881-11914-3-git-send-email-vyasevic@redhat.com>
 <877efb54-2aef-4d1e-c0b4-2ce6aa6562df@cumulusnetworks.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: roopa <roopa@cumulusnetworks.com>, Jiri Pirko <jiri@resnulli.us>
To: David Ahern <dsa@cumulusnetworks.com>,
        Vladislav Yasevich <vyasevich@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55962 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S939604AbdD0TnK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 15:43:10 -0400
In-Reply-To: <877efb54-2aef-4d1e-c0b4-2ce6aa6562df@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2017 09:07 PM, David Ahern wrote:
> On 4/21/17 11:31 AM, Vladislav Yasevich wrote:
>> @@ -1276,9 +1277,40 @@ static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
>>  	return err;
>>  }
>>  
>> +static int rtnl_fill_link_event(struct sk_buff *skb, unsigned long event)
>> +{
>> +	u32 rtnl_event;
>> +
>> +	switch (event) {
>> +	case NETDEV_REBOOT:
>> +		rtnl_event = IFLA_EVENT_REBOOT;
>> +		break;
>> +	case NETDEV_FEAT_CHANGE:
>> +		rtnl_event = IFLA_EVENT_FEAT_CHANGE;
>> +		break;
>> +	case NETDEV_BONDING_FAILOVER:
>> +		rtnl_event = IFLA_EVENT_BONDING_FAILOVER;
>> +		break;
>> +	case NETDEV_NOTIFY_PEERS:
>> +		rtnl_event = IFLA_EVENT_NOTIFY_PEERS;
>> +		break;
>> +	case NETDEV_RESEND_IGMP:
>> +		rtnl_event = IFLA_EVENT_RESEND_IGMP;
>> +		break;
>> +	case NETDEV_CHANGEINFODATA:
>> +		rtnl_event = IFLA_EVENT_CHANGE_INFO_DATA;
>> +		break;
>> +	default:
>> +		return 0;
>> +	}
>> +
>> +	return nla_put_u32(skb, IFLA_EVENT, rtnl_event);
>> +}
>> +
> 
> I still have doubts about encoding kernel events into a uapi.
> 
> For example, NETDEV_CHANGEINFODATA is only for bonds though nothing
> about the name suggests it is a bonding notification. This one was added
> specifically to notify userspace (d4261e5650004), yet seems to happen
> only during a changelink and that already generates a RTM_NEWLINK
> message via do_setlink. Since the rtnetlink_event message does not
> contain anything "NETDEV_CHANGEINFODATA" related what purpose does it
> really serve besides duplicating netlink messages to userspace.
> 

I am not sure about this one, but if you have an app trying to monitor
for this event, it can't really since there is no info in the netlink message.

> The REBOOT, IGMP, FEAT_CHANGE and BONDING_FAILOVER seem to be unique
> messages (code analysis only) which I get for notifying userspace.
> 
> NETDEV_NOTIFY_PEERS is not so clear in how often it duplicates other
> messages.
> 

This one sometimes happens in addition to bonding failover, but not always
(it depends on bonding mode).
For me, having access to this particular event is important as it will
used to trigger a guest announcements.

-vlad
