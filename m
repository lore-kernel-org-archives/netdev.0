From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: A problem about ICMP packet-too-big message handler
Date: Thu, 29 Jan 2015 11:16:16 +0800
Message-ID: <54C9A600.9080004@huawei.com>
References: <54C78B8D.1070104@huawei.com> <20150128121026.GM13046@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:53487 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755391AbbA2DQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 22:16:37 -0500
In-Reply-To: <20150128121026.GM13046@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/1/28 20:10, Steffen Klassert wrote:
> On Tue, Jan 27, 2015 at 08:58:53PM +0800, Yang Yingliang wrote:
>> Hi,
>>
>> My kernel is 3.10 LTS.
>>
>> I got a problem here about handling ICMP packet-too-big message.
>>
>> Before sending a packet-too-big packet :
>>
>> # ip -6 route list table local
>> local ::1 dev lo  metric 0 
>> local fe80:: dev lo  metric 0 
>> local fe80:: dev lo  metric 0 
>> local fe80:: dev lo  metric 0 
>> local fe80:: dev lo  metric 0 
>> local fe80:: dev lo  metric 0 
>> local fe80:: dev lo  metric 0 
>> local fe80::1 dev lo  metric 0 	//It  does not have expire value
>> local fe80::200:ff:fe00:0 dev lo  metric 0 
>> local fe80::200:ff:fe00:0 dev lo  metric 0 
>> local fe80::200:ff:fe00:0 dev lo  metric 0 
>> local fe80::200:ff:fe00:0 dev lo  metric 0 
>> local fe80::200:ff:fe00:2 dev lo  metric 0 
>> local fe80::5054:ff:fe12:3456 dev lo  metric 0
>>
>>
>> After sending a packet-too-big packet
>>
>> ip -6 route list table local
>> local ::1 dev lo  metric 0 
>> local fe80:: dev lo  metric 0 
>> local fe80:: dev lo  metric 0 
>> local fe80:: dev lo  metric 0 
>> local fe80:: dev lo  metric 0 
>> local fe80:: dev lo  metric 0 
>> local fe80:: dev lo  metric 0 
>> local fe80::1 dev lo  metric 0  expires _597_  //It has expire value
> 
> Is this route still present after the expiration time is elapsed?
> 
>> local fe80::200:ff:fe00:0 dev lo  metric 0 
>> local fe80::200:ff:fe00:0 dev lo  metric 0 
>> local fe80::200:ff:fe00:0 dev lo  metric 0 
>> local fe80::200:ff:fe00:0 dev lo  metric 0 
>> local fe80::200:ff:fe00:2 dev lo  metric 0 
>> local fe80::5054:ff:fe12:3456 dev lo  metric 0
>>
>> When time is up, I can't ping fe80::1 .
>> Is it ok or a bug ?
> 
> This looks pretty similar to a bug I discovered recently.
> In my case, a ipv6 host route dissapeared 10 minutes after
> a PMTU event. As a result, this host was not reachable
> anymore.
> 
> This happens because we don't clone host routes before
> we use them. If a PMTU event happens, the original route
> is marked with an expire value. After the expiration time
> is elapsed, the original route is deleted and we loose
> conectivity to the host.
> 
> I'm currently testing patches to fix this. With these
> patches the ipv6 host routes are cloned if they are
> gateway routes, i.e. if PMTU events can happen.
> 
> I fear it will not fix your case because PMTU events are
> not expected to happen at local fe80 routes.

I found current kernel will do ip6_update_pmtu() anyway after
receiving an ICMPV6_PKT_TOOBIG type packet in icmpv6_err().

Does it need some more condition ? Like this:

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index a5e95199585e..7c0a28add109 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -89,8 +89,10 @@ static void icmpv6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	/* icmpv6_notify checks 8 bytes can be pulled, icmp6hdr is 8 bytes */
 	struct icmp6hdr *icmp6 = (struct icmp6hdr *) (skb->data + offset);
 	struct net *net = dev_net(skb->dev);
+	const struct ipv6hdr *iph = (struct ipv6hdr *) skb->data;
 
-	if (type == ICMPV6_PKT_TOOBIG)
+	if (type == ICMPV6_PKT_TOOBIG &&
+	    !(ipv6_addr_type(&iph->daddr) & IPV6_ADDR_LINKLOCAL))
 		ip6_update_pmtu(skb, net, info, 0, 0);
 	else if (type == NDISC_REDIRECT)
 		ip6_redirect(skb, net, skb->dev->ifindex, 0);


Regards,
Yang
