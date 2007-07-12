From: Pavel Emelianov <xemul@openvz.org>
Subject: Re: [PATCH 2/2] Virtual ethernet device driver
Date: Thu, 12 Jul 2007 17:36:42 +0400
Message-ID: <46962E6A.5020906@openvz.org>
References: <4695F0BF.1000305@openvz.org> <4695F214.6020401@openvz.org> <46961F21.7030409@trash.net> <4696293A.4030108@openvz.org> <46962AC5.2030005@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:15036 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761635AbXGLNg5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2007 09:36:57 -0400
In-Reply-To: <46962AC5.2030005@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Pavel Emelianov wrote:
>> Patrick McHardy wrote:
>>
>>> Pavel Emelianov wrote:
>>>
>>>> +static int veth_newlink(struct net_device *dev,
>>>> +			 struct nlattr *tb[], struct nlattr *data[])
>>>> +{
>>>> +	int err;
>>>> +	struct net_device *peer;
>>>> +	struct veth_priv *priv;
>>>> +	char ifname[IFNAMSIZ];
>>>> +
>>>> +	/*
>>>> +	 * prepare the devices info
>>>> +	 */
>>>> +
>>>> +	if (tb[IFLA_ADDRESS] == NULL)
>>>> +		random_ether_addr(dev->dev_addr);
>>>> +
>>>> +	if (data != NULL && data[VETH_INFO_PEER] != NULL) {
>>>> +		err = nla_parse_nested(tb, IFLA_INFO_MAX,
>>>> +				data[VETH_INFO_PEER], ifla_policy);
>>>> +		if (err < 0)
>>>> +			return err;
>>>> +	}
>>>
>>> Not having a peer should be an error, no?
>>
>> No. That's the intention - if the user doesn't specify "peer" in the
>> command line then two _identical_ devices are created. Of course, if
>> he specifies one name - there'll be a collision, but one can say
>> "my_own_veth_number_%d" and everything will be ok. Or just use the 
>> default name provided. E.g. "ip link add type veth" will send a packet
>> with data[VETH_INFO_PEER} == NULL, but this is OK! User just wants a 
>> default tunnel and he will get it :)
> 
> I see.
> 
>> Does this answer your second comment below?
> 
> 
> No, to get unique names the sequence has to be:
> 
> dev_alloc_name
> register_netdevice
> dev_alloc_name
> register_netdevice
> 
> But you have:
> 
> dev_alloc_name
> dev_alloc_name (<- might allocate same name as first call)
> register_netdevice
> register_netdevice

Oops :) You're right. That's the problem. I was carried away by
testing the "peer" options and checking for names rather than
"veth%d" to work...

By the way, that will create some problems. You see, your patches
imply that the register_netdevice() will be called at the very end
of the ->newlink callback. Otherwise, the error path of any code
following the registering will have to call unregister_netdevice()
which will BUG() in free_netdev() in rtnl_newlink() - the device
state will be neither UNINITIALIZED nor UNREGISTERED :(

>>>> +static __exit void veth_exit(void)
>>>> +{
>>>> +	struct veth_priv *priv, *next;
>>>> +
>>>> +	rtnl_lock();
>>>> +	__rtnl_link_unregister(&veth_link_ops);
>>>> +
>>>> +	list_for_each_entry_safe(priv, next, &veth_list, list)
>>>> +		veth_dellink(priv->dev);
>>>> +	rtnl_unlock();
>>>
>>> Devices are unregistered automatically through the dellink function,
>>> rtnl_link_unregister(..) is enough.
>>
>> OK. This looks like a minor and not-significant comment, so
>> do I need to resend the patch or David is OK to take it and
>> I will send an incremental one?
> 
> 
> An incremental patch for this is fine I guess, your code is correct,
> its merely a simplification.
> 

Thanks,
Pavel
