From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH] bridge: pass correct vlan id to multicast code
Date: Tue, 29 Oct 2013 11:00:36 -0400
Message-ID: <526FCD94.5090100@redhat.com>
References: <1382989507-23061-1-git-send-email-vyasevic@redhat.com> <20131029023646.GA2795@amosk.info>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	makita.toshiaki@lab.ntt.co.jp
To: Amos Kong <akong@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23753 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752287Ab3J2PAp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 11:00:45 -0400
In-Reply-To: <20131029023646.GA2795@amosk.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/28/2013 10:36 PM, Amos Kong wrote:
> On Mon, Oct 28, 2013 at 03:45:07PM -0400, Vlad Yasevich wrote:

>> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
>> index 8b0b610..686284f 100644
>> --- a/net/bridge/br_multicast.c
>> +++ b/net/bridge/br_multicast.c
>> @@ -947,7 +947,8 @@ void br_multicast_disable_port(struct net_bridge_port *port)
>>
>>   static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
>>   					 struct net_bridge_port *port,
>> -					 struct sk_buff *skb)
>> +					 struct sk_buff *skb,
>> +					 u16 vid)
>>   {
>>   	struct igmpv3_report *ih;
>>   	struct igmpv3_grec *grec;
>> @@ -957,12 +958,10 @@ static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
>>   	int type;
>>   	int err = 0;
>>   	__be32 group;
>> -	u16 vid = 0;
>>
>>   	if (!pskb_may_pull(skb, sizeof(*ih)))
>>   		return -EINVAL;
>>
>> -	br_vlan_get_tag(skb, &vid);
>

Sorry, missed this question last time.

> After applied the patch, we always use vid in br_dev_xmit()->br_allowed_ingress(),
> is it possible that the vlan of bridge is re-enabled when other
> changed functions are called?
>

If the frame was allowed to enter, then the current configuration should 
apply the the frame.  If the config changes during the frame
processing we don't really want to use that.  Otherwise, you'd get
inconsistent results.

> We can just add a enabled checking before this kind of br_vlan_get_tag()?
>
> if (!br->vlan_enabled)
>      br_vlan_get_tag(skb2, &vid);
>

This sort of what the next patches I am working on do.  But we still 
want to get the vlan id once and then use it throught out.  There is
no need to retrieve it again.

-vlad

>
>>   	ih = igmpv3_report_hdr(skb);
>>   	num = ntohs(ih->ngrec);
>>   	len = sizeof(*ih);
>
> ...
>
