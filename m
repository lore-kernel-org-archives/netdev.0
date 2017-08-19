From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net-next] net: ipv6: put host and anycast routes on device with address
Date: Fri, 18 Aug 2017 20:28:53 -0400
Message-ID: <87inhkl7sq.fsf@stressinduktion.org>
References: <1502997440-32334-1-git-send-email-dsahern@gmail.com>
        <87wp60lb70.fsf@stressinduktion.org>
        <75e79efe-4a41-7b15-b7bb-8ed0624b72b5@gmail.com>
        <0bcba874-7fc3-508c-bf78-ae5832312845@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:40889 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752328AbdHSA2y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 20:28:54 -0400
In-Reply-To: <0bcba874-7fc3-508c-bf78-ae5832312845@gmail.com> (David Ahern's
        message of "Fri, 18 Aug 2017 18:14:18 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsahern@gmail.com> writes:

> On 8/18/17 6:05 PM, David Ahern wrote:
>> On 8/18/17 5:15 PM, Hannes Frederic Sowa wrote:
>>> Hello David,
>>>
>>> David Ahern <dsahern@gmail.com> writes:
>>>
>>>> @@ -2688,15 +2716,9 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
>>>>  {
>>>>  	u32 tb_id;
>>>>  	struct net *net = dev_net(idev->dev);
>>>> -	struct net_device *dev = net->loopback_dev;
>>>> +	struct net_device *dev = idev->dev;
>>>>  	struct rt6_info *rt;
>>>>  
>>>> -	/* use L3 Master device as loopback for host routes if device
>>>> -	 * is enslaved and address is not link local or multicast
>>>> -	 */
>>>> -	if (!rt6_need_strict(addr))
>>>> -		dev = l3mdev_master_dev_rcu(idev->dev) ? : dev;
>>>> -
>>>>  	rt = ip6_dst_alloc(net, dev, DST_NOCOUNT);
>>>>  	if (!rt)
>>>>  		return ERR_PTR(-ENOMEM);
>>>
>>> I am afraid this change might break Java:
>>>
>>> <http://hg.openjdk.java.net/jdk9/jdk9/jdk/file/65464a307408/src/java.base/unix/native/libnet/net_util_md.c#l574>
>>>
>>> I am all in for this change, but maybe it might be necessary to mask
>>> RTF_LOCAL routes with "lo" somehow.
>> 
>> That's asinine. The if_inet6 processing is just getting the 'lo'
>> interface index. Why scan the file looking for that? The ipv6_route
>> processing is assembling routes against the loopback device regardless
>> of what the route is. Do you know why - what the route list is used for?
>
>
> If I read it correctly, seems to be a 2.4 workaround:
> - only user of the route list is needsLoopbackRoute()
> - only caller of needsLoopbackRoute is here:
>
> http://hg.openjdk.java.net/jdk9/jdk9/jdk/file/65464a307408/src/java.base/unix/native/libnet/net_util_md.c#l828

I agree that it looks like dead code now. But I know for sure that this
code has been excercised at least at some point in time and caused
problems for JVMs on Linux with IPv6.

On the top of this file I found this comment:

-- >8 --
/* following code creates a list of addresses from the kernel
 * routing table that are routed via the loopback address.
 * We check all destination addresses against this table
 * and override the scope_id field to use the relevant value for "lo"
 * in order to work-around the Linux bug that prevents packets destined
 * for certain local addresses from being sent via a physical interface.
 */
-- 8< --

I don't know if it makes sense to dive down into java history (and I
also found e.g. net-snmp scanning /proc/net/ipv6_route). The same
problem might be visible via RTM_GETROUTE dumps if applications
implement their own source address selection maybe. :/

Bye, Hannes
