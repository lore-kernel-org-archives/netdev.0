From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [patch net-next v2 01/28] net: dev: Check CHANGEUPPER notifier
 return value
Date: Thu, 3 Dec 2015 10:25:00 +0200
Message-ID: <20151203082500.GB3075@colbert.mtl.com>
References: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
 <1449086871-19911-2-git-send-email-jiri@resnulli.us>
 <565F7CD2.2080207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jiri Pirko <jiri@resnulli.us>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <eladr@mellanox.com>, <yotamg@mellanox.com>,
	<ogerlitz@mellanox.com>, <j.vosburgh@gmail.com>,
	<vfalico@gmail.com>, <gospo@cumulusnetworks.com>,
	<dsa@cumulusnetworks.com>, <nikolay@cumulusnetworks.com>,
	<pjonnala@broadcom.com>, <f.fainelli@gmail.com>,
	<sfeldma@gmail.com>, <roopa@cumulusnetworks.com>, <andrew@lunn.ch>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0062.outbound.protection.outlook.com ([157.56.112.62]:32477
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751580AbbLCIZP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 03:25:15 -0500
Content-Disposition: inline
In-Reply-To: <565F7CD2.2080207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Dec 03, 2015 at 01:20:50AM IST, john.fastabend@gmail.com wrote:
>On 15-12-02 12:07 PM, Jiri Pirko wrote:
>> From: Ido Schimmel <idosch@mellanox.com>
>> 
>> switchdev drivers reflect the newly requested topology to hardware when
>> CHANGEUPPER is received, after software links were already formed.
>> However, the operation can fail and user will not be notified, as the
>> return value of the notifier is not checked.
>> 
>> Add this check and rollback software links if necessary.
>> 
>> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>> v1->v2:
>> -new patch
>> ---
>>  net/core/dev.c | 7 +++++--
>>  1 file changed, 5 insertions(+), 2 deletions(-)
>> 
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 5df6cbc..df33f82 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -5490,8 +5490,11 @@ static int __netdev_upper_dev_link(struct net_device *dev,
>>  			goto rollback_lower_mesh;
>>  	}
>>  
>> -	call_netdevice_notifiers_info(NETDEV_CHANGEUPPER, dev,
>> -				      &changeupper_info.info);
>> +	ret = call_netdevice_notifiers_info(NETDEV_CHANGEUPPER, dev,
>> +					    &changeupper_info.info);
>> +	if (ret)
>> +		goto rollback_lower_mesh;
>> +
>
>hmm small nit (take it or leave it) but I think it would be more
>correct if this was
>
>	if (ret == NOTIFY_BAD)
>		goto rollback_lower_mesh;
>
>It seems that NOTIFY_DONE, NOTIFY_OK and NOTIFY_STOP_MASK would be
>valid return codes that don't indicate an error. However seeing I
>couldn't find any cases of NOTIFY_OK/NOTIFY_STOP_MASK from the
>CHANGEUPPER event it doesn't matter in practice.
>

Hi,

It's actually not a small nit. I forgot to call 'notifier_to_errno' and
then check its retrun value instead that of the notifier. This would
return 0 for NOTIFY_{DONE,OK,STOP_MASK} and -1 for NOTIFY_BAD.

Thank you.

>Thanks,
>John
>
>>  	return 0;
>>  
>>  rollback_lower_mesh:
>> 
>
