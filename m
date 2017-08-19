From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v2 net-next] net: ipv6: put host and anycast routes on
 device with address
Date: Fri, 18 Aug 2017 18:14:18 -0600
Message-ID: <0bcba874-7fc3-508c-bf78-ae5832312845@gmail.com>
References: <1502997440-32334-1-git-send-email-dsahern@gmail.com>
 <87wp60lb70.fsf@stressinduktion.org>
 <75e79efe-4a41-7b15-b7bb-8ed0624b72b5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Ahern <dsahern@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36865 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751077AbdHSAOU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 20:14:20 -0400
Received: by mail-pg0-f68.google.com with SMTP id 83so17193961pgb.4
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 17:14:20 -0700 (PDT)
In-Reply-To: <75e79efe-4a41-7b15-b7bb-8ed0624b72b5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/18/17 6:05 PM, David Ahern wrote:
> On 8/18/17 5:15 PM, Hannes Frederic Sowa wrote:
>> Hello David,
>>
>> David Ahern <dsahern@gmail.com> writes:
>>
>>> @@ -2688,15 +2716,9 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
>>>  {
>>>  	u32 tb_id;
>>>  	struct net *net = dev_net(idev->dev);
>>> -	struct net_device *dev = net->loopback_dev;
>>> +	struct net_device *dev = idev->dev;
>>>  	struct rt6_info *rt;
>>>  
>>> -	/* use L3 Master device as loopback for host routes if device
>>> -	 * is enslaved and address is not link local or multicast
>>> -	 */
>>> -	if (!rt6_need_strict(addr))
>>> -		dev = l3mdev_master_dev_rcu(idev->dev) ? : dev;
>>> -
>>>  	rt = ip6_dst_alloc(net, dev, DST_NOCOUNT);
>>>  	if (!rt)
>>>  		return ERR_PTR(-ENOMEM);
>>
>> I am afraid this change might break Java:
>>
>> <http://hg.openjdk.java.net/jdk9/jdk9/jdk/file/65464a307408/src/java.base/unix/native/libnet/net_util_md.c#l574>
>>
>> I am all in for this change, but maybe it might be necessary to mask
>> RTF_LOCAL routes with "lo" somehow.
> 
> That's asinine. The if_inet6 processing is just getting the 'lo'
> interface index. Why scan the file looking for that? The ipv6_route
> processing is assembling routes against the loopback device regardless
> of what the route is. Do you know why - what the route list is used for?


If I read it correctly, seems to be a 2.4 workaround:
- only user of the route list is needsLoopbackRoute()
- only caller of needsLoopbackRoute is here:

http://hg.openjdk.java.net/jdk9/jdk9/jdk/file/65464a307408/src/java.base/unix/native/libnet/net_util_md.c#l828
