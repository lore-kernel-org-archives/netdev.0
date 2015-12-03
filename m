From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next v2 01/28] net: dev: Check CHANGEUPPER notifier
 return value
Date: Thu, 3 Dec 2015 08:37:37 +0200
Message-ID: <CAJ3xEMg=Jiwc9vT_yLFbPGsk4Wm_p8=Gx3jX4STyOimZmq-bGg@mail.gmail.com>
References: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
	<1449086871-19911-2-git-send-email-jiri@resnulli.us>
	<565F7CD2.2080207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>, yotamg@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>, vfalico@gmail.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andrew Lunn <andrew@lunn.ch>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:35441 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbbLCGhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 01:37:38 -0500
Received: by ioc74 with SMTP id 74so71195201ioc.2
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 22:37:37 -0800 (PST)
In-Reply-To: <565F7CD2.2080207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 3, 2015 at 1:20 AM, John Fastabend <john.fastabend@gmail.com> wrote:
> On 15-12-02 12:07 PM, Jiri Pirko wrote:
>> From: Ido Schimmel <idosch@mellanox.com>
>>
>> switchdev drivers reflect the newly requested topology to hardware when
>> CHANGEUPPER is received, after software links were already formed.
>> However, the operation can fail and user will not be notified, as the
>> return value of the notifier is not checked.
>>
>> Add this check and rollback software links if necessary.

>>  net/core/dev.c | 7 +++++--
>>  1 file changed, 5 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 5df6cbc..df33f82 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -5490,8 +5490,11 @@ static int __netdev_upper_dev_link(struct net_device *dev,
>>                       goto rollback_lower_mesh;
>>       }
>>
>> -     call_netdevice_notifiers_info(NETDEV_CHANGEUPPER, dev,
>> -                                   &changeupper_info.info);
>> +     ret = call_netdevice_notifiers_info(NETDEV_CHANGEUPPER, dev,
>> +                                         &changeupper_info.info);
>> +     if (ret)
>> +             goto rollback_lower_mesh;
>> +
>
> hmm small nit (take it or leave it) but I think it would be more
> correct if this was
>
>         if (ret == NOTIFY_BAD)
>                 goto rollback_lower_mesh;
>
> It seems that NOTIFY_DONE, NOTIFY_OK and NOTIFY_STOP_MASK would be
> valid return codes that don't indicate an error. However seeing I
> couldn't find any cases of NOTIFY_OK/NOTIFY_STOP_MASK from the
> CHANGEUPPER event it doesn't matter in practice.

When saying that you couldn't find any such cases in the current code,
can't they
be added in the future? and hence following your suggestion would
eliminate future
wrong behaviour, right?

>>       return 0;
>>
>>  rollback_lower_mesh:
