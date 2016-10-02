From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH] net: rtnl: avoid uninitialized data in IFLA_VF_VLAN_LIST
 handling
Date: Sun, 2 Oct 2016 12:03:37 +0300
Message-ID: <86297d37-c01a-070a-fe26-b8f160cb0e5b@mellanox.com>
References: <20160930161416.18660-1-arnd@arndb.de>
 <CANn89iK2FQufz4NCan1y0dQME2RUOzc3NXXhqYd418ctHNc6fA@mail.gmail.com>
 <201609301838.05349.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        "Hannes Frederic Sowa" <hannes@stressinduktion.org>,
        Nogah Frankel <nogahf@mellanox.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "Moshe Shemesh" <moshe@mellanox.com>
To: Arnd Bergmann <arnd@arndb.de>, Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0076.outbound.protection.outlook.com ([104.47.2.76]:10592
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750856AbcJBTgb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 2 Oct 2016 15:36:31 -0400
In-Reply-To: <201609301838.05349.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnd,


On 30/09/2016 7:38 PM, Arnd Bergmann wrote:
> On Friday 30 September 2016, Eric Dumazet wrote:
>>> @@ -1753,6 +1753,9 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr **tb)
>>>
>>>                          len++;
>>>                  }
>>> +               if (len == 0)
>>> +                       return -EINVAL;
>>> +
>>>                  err = ops->ndo_set_vf_vlan(dev, ivvl[0]->vf, ivvl[0]->vlan,
>>>                                             ivvl[0]->qos, ivvl[0]->vlan_proto);
>>>                  if (err < 0)
>>> --
>>> 2.9.0
>>>
Reviewed-by: Moshe Shemesh <moshe@mellanox.com>

Thanks for the fix, I will add the flag to my makefile.
>> So, if I read this code, we build an array, but call ndo_set_vf_vlan()
>> only using first element ?
>>
>> Looks like the bug should be fixed in a different way.
> I was wondering about this too, but didn't understand enough about it to say
> if it was intentional or not.
It is intentional.
The change we need here is the option to set the VF vlan protocol, so 
our hw will insert either S-TAG or C-TAG per VF. The previous version of 
this patch didn't use any array.
Then we got a comment, which makes sense, that the new UAPI interface 
should be able to support a future driver that might want to set both 
S-TAG and C-TAG per VF.
We could have used a single struct on kernel side instead of a list of 
size 1, but this would cause bad/not scalable code in the parsing stage.
As the UAPI is a list, in the parsing stage we thought it is more 
correct to use the constant MAX_VLAN_LIST_LEN and iterate as of a 
general case, even though currently the list size is one.

>   I just realized that I forgot to add Moshe and Tariq
> on Cc (I relied on scripts/get_maintainer.pl, but didn't double-check).
> I've added them to Cc now, hope they can clarify this.
>
> 	Arnd

Regards,
Moshe and Tariq
