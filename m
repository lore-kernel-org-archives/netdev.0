From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Re: Nested VLAN causes recursive locking error
Date: Mon, 31 Dec 2007 18:45:55 +0100
Message-ID: <20071231174555.GA3097@ami.dom.local>
References: <20071220135253.GA10932@ff.dom.local> <477904F1.6090403@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Ebbert <cebbert@redhat.com>, Netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:29229 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbXLaRn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 12:43:56 -0500
Received: by ug-out-1314.google.com with SMTP id z38so2311572ugc.16
        for <netdev@vger.kernel.org>; Mon, 31 Dec 2007 09:43:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <477904F1.6090403@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 31, 2007 at 04:04:17PM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> diff -Nurp linux-2.6.24-rc5-/net/8021q/vlan.c linux-2.6.24-rc5+/net/8021q/vlan.c
>> --- linux-2.6.24-rc5-/net/8021q/vlan.c	2007-12-17 13:29:19.000000000 +0100
>> +++ linux-2.6.24-rc5+/net/8021q/vlan.c	2007-12-20 14:21:02.000000000 +0100
>> @@ -307,12 +307,15 @@ int unregister_vlan_device(struct net_de
>>  	return ret;
>>  }
>>  +#ifdef CONFIG_LOCKDEP
>>  /*
>>   * vlan network devices have devices nesting below it, and are a special
>>   * "super class" of normal network devices; split their locks off into a
>>   * separate class since they always nest.
>>   */
>>  static struct lock_class_key vlan_netdev_xmit_lock_key;
>> +static int subclass; /* vlan nesting vlan */
>> +#endif
>>   static const struct header_ops vlan_header_ops = {
>>  	.create	 = vlan_dev_hard_header,
>> @@ -349,7 +352,14 @@ static int vlan_dev_init(struct net_devi
>>  		dev->hard_start_xmit = vlan_dev_hard_start_xmit;
>>  	}
>>  -	lockdep_set_class(&dev->_xmit_lock, &vlan_netdev_xmit_lock_key);
>> +#ifdef CONFIG_LOCKDEP
>> +	if ((real_dev->priv_flags & IFF_802_1Q_VLAN) &&
>> +	    subclass < MAX_LOCKDEP_SUBCLASSES - 1)
>> +		subclass++;
>> +
>
> That will increment the subclass globally, but it should actually just
> use real_dev->subclass + 1. Otherwise we'll permenently fail after
> registering 8 nested devices and unregistering them again.
>

Very good point! (As usual...) Actually, this shouldn't fail but work
with this one, last subclass only, so similarly like now, without this
patch.

Patric, currently I'm not sure this patch is very necessary... Since
I don't use vlans, I don't know how much it's real or theoretical
only problem. Probably the easiest solution would be limiting this
to two subclasses - any nested vlan gets second. Otherwise, it seems
there is some place needed to store these subclasses or use some
unofficial checks on lockdep's structures?

So, if you think this is useful and have better idea how this should
be done, I would be very glad if you re-do this your way (plus there
should be no problem with testing). Otherwise, give me some hint...

Thanks & Happy New Year!
Jarek P.
