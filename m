From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 6/14][RTNL]: Introduce the rtnl_kill_links call.
Date: Fri, 11 Apr 2008 12:01:31 +0400
Message-ID: <47FF1ADB.1090805@openvz.org>
References: <47FE2AD4.9080609@openvz.org> <47FE2E01.6030000@openvz.org> <37533.192.168.101.12.1207865395.squirrel@intranet>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	Denis Lunev <den@openvz.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	Patrick McHardy <kaber@trash.net>
To: Daniel Hokka Zakrisson <daniel@hozac.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:48438 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755166AbYDKHhf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 03:37:35 -0400
In-Reply-To: <37533.192.168.101.12.1207865395.squirrel@intranet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>> index da99ac0..bc39e41 100644
>> --- a/net/core/rtnetlink.c
>> +++ b/net/core/rtnetlink.c
>> @@ -269,6 +269,26 @@ int rtnl_link_register(struct rtnl_link_ops *ops)
>>
>>  EXPORT_SYMBOL_GPL(rtnl_link_register);
>>
>> +static void __rtnl_kill_links(struct net *net, struct rtnl_link_ops *ops)
>> +{
>> +	struct net_device *dev;
>> +restart:
>> +	for_each_netdev(net, dev) {
>> +		if (dev->rtnl_link_ops == ops) {
>> +			ops->dellink(dev);
>> +			goto restart;
>> +		}
>> +	}
>> +}
>> +
>> +void rtnl_kill_links(struct net *net, struct rtnl_link_ops *ops)
>> +{
>> +	rtnl_lock();
>> +	__rtnl_kill_links(net, ops);
>> +	rtnl_unlock();
>> +}
>> +EXPORT_SYMBOL_GPL(rtnl_kill_links);
>> +
>>  /**
>>   * __rtnl_link_unregister - Unregister rtnl_link_ops from rtnetlink.
>>   * @ops: struct rtnl_link_ops * to unregister
>> @@ -277,17 +297,10 @@ EXPORT_SYMBOL_GPL(rtnl_link_register);
>>   */
>>  void __rtnl_link_unregister(struct rtnl_link_ops *ops)
>>  {
>> -	struct net_device *dev, *n;
>>  	struct net *net;
>>
>>  	for_each_net(net) {
>> -restart:
>> -		for_each_netdev_safe(net, dev, n) {
>> -			if (dev->rtnl_link_ops == ops) {
>> -				ops->dellink(dev);
>> -				goto restart;
>> -			}
>> -		}
>> +		__rtnl_kill_links(net, ops);
> 
> This was _safe, and now it's not. Is that intentional?

Yup - we goto restart in case we del some link, so there's no need
in _safe iteration. 

This goto was added by Partick (commit 68365458 [NET]: rtnl_link: 
fix use-after-free) and I suspect he simply forgot to remove the 
_safe iterator (I put him in Cc to correct me if I'm wrong).

>>  	}
>>  	list_del(&ops->list);
>>  }
>> --
>> 1.5.3.4
> 

