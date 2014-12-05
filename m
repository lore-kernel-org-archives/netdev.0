From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 2/3] bridge: offload bridge port attributes to switch
 asic if feature flag set
Date: Fri, 05 Dec 2014 06:04:44 -0800
Message-ID: <5481BB7C.6010403@cumulusnetworks.com>
References: <1417746401-8140-3-git-send-email-roopa@cumulusnetworks.com> <5481B16C.8050904@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:34635 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801AbaLEOFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 09:05:03 -0500
In-Reply-To: <5481B16C.8050904@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ack again, will fix the formatting issues. thanks

On 12/5/14, 5:21 AM, Sergei Shtylyov wrote:
> Hello.
>
> On 12/5/2014 5:26 AM, roopa@cumulusnetworks.com wrote:
>
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>> This allows offloading to switch asic without having the user to set
>> any flag. And this is done in the bridge driver to rollback kernel 
>> settings
>> on hw offload failure if required in the future.
>
>> With this, it also makes sure a notification goes out only after the
>> attributes are set both in the kernel and hw.
>> ---
>>   net/bridge/br_netlink.c |   27 ++++++++++++++++++++++++++-
>>   1 file changed, 26 insertions(+), 1 deletion(-)
>
>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>> index 9f5eb55..ce173f0 100644
>> --- a/net/bridge/br_netlink.c
>> +++ b/net/bridge/br_netlink.c
>> @@ -407,9 +407,21 @@ int br_setlink(struct net_device *dev, struct 
>> nlmsghdr *nlh)
>>                   afspec, RTM_SETLINK);
>>       }
>>
>> +    if ((dev->features & NETIF_F_HW_SWITCH_OFFLOAD) &&
>> +            dev->netdev_ops->ndo_bridge_setlink) {
>> +        int ret = dev->netdev_ops->ndo_bridge_setlink(dev, nlh);
>
>    Need empty line after declaration.
>
>> +        if (ret && ret != -EOPNOTSUPP) {
>> +            /* XXX Fix this in the future to rollback
>> +             * kernel settings and return error
>> +             */
>> +            br_warn(p->br, "error offloading bridge attributes "
>> +                    "on port %u(%s)\n", (unsigned int) p->port_no,
>
>    Don't break up the message strings. Also, your continuation lines 
> should start under the next character after ( on the first line.
>
>> +                    p->dev->name);
>> +        }
>> +    }
>> +
>>       if (err == 0)
>>           br_ifinfo_notify(RTM_NEWLINK, p);
>> -
>
>    Why?
>
>>   out:
>>       return err;
>>   }
>> @@ -433,6 +445,19 @@ int br_dellink(struct net_device *dev, struct 
>> nlmsghdr *nlh)
>>       err = br_afspec((struct net_bridge *)netdev_priv(dev), p,
>>               afspec, RTM_DELLINK);
>>
>> +    if (dev->features & NETIF_F_HW_SWITCH_OFFLOAD
>> +            && dev->netdev_ops->ndo_bridge_setlink) {
>> +        int ret = dev->netdev_ops->ndo_bridge_dellink(dev, nlh);
>> +        if (ret && ret != -EOPNOTSUPP) {
>> +            /* XXX Fix this in the future to rollback
>> +             * kernel settings and return error
>> +             */
>> +            br_warn(p->br, "error offloading bridge attributes "
>> +                    "on port %u(%s)\n", (unsigned int) p->port_no,
>> +                    p->dev->name);
>
>    Same comments here.
>
>> +        }
>> +    }
>> +
>>       return err;
>>   }
>>   static int br_validate(struct nlattr *tb[], struct nlattr *data[])
>
> WBR, Sergei
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
