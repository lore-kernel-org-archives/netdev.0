From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next] net: make dev_set_mtu() honor notification
 return code
Date: Fri, 10 Jan 2014 16:47:42 +0100
Message-ID: <20140110154742.GE4132@redhat.com>
References: <1389358097-5396-1-git-send-email-vfalico@redhat.com>
 <52D0138D.6050302@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3460 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752491AbaAJPuo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 10:50:44 -0500
Content-Disposition: inline
In-Reply-To: <52D0138D.6050302@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 10, 2014 at 07:36:45AM -0800, Alexander Duyck wrote:
>On 01/10/2014 04:48 AM, Veaceslav Falico wrote:
...snip...
>> -	err = 0;
>> -	if (ops->ndo_change_mtu)
>> -		err = ops->ndo_change_mtu(dev, new_mtu);
>> -	else
>> -		dev->mtu = new_mtu;
>> +	orig_mtu = dev->mtu;
>> +	err = __dev_set_mtu(dev, new_mtu);
>>
>> -	if (!err)
>> -		call_netdevice_notifiers(NETDEV_CHANGEMTU, dev);
>> +	if (!err) {
>> +		err = call_netdevice_notifiers(NETDEV_CHANGEMTU, dev);
>> +		err = notifier_to_errno(err);
>> +		if (err)
>> +			__dev_set_mtu(dev, orig_mtu);
>> +	}
>>  	return err;
>>  }
>>  EXPORT_SYMBOL(dev_set_mtu);
>
>So what about the netdevices that succeeded in changing the MTU based on
>the notifiers?  It seems like you still  have an inconsistent state
>after the failure unless you issue a second call with a notification
>that you reverted to the old MTU.

Good point, thank you. I'll add a second call_netdevice_notifiers() after
setting the original MTU and resend.

Thank you!

>
>Thanks,
>
>Alex
