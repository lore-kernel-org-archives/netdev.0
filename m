From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 2/3] bridge: offload bridge port attributes to switch
 asic if feature flag set
Date: Fri, 05 Dec 2014 06:03:25 -0800
Message-ID: <5481BB2D.6090605@cumulusnetworks.com>
References: <1417746401-8140-3-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bBOCgoH0zL6+82jj2qjcP8n3kSo51x+i5SoqkN8Ff1CBQ@mail.gmail.com> <548156C8.5060602@gmail.com> <54815A4E.3020806@cumulusnetworks.com> <5481A7E1.7070708@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Benjamin LaHaise <bcrl@kvack.org>, Thomas Graf <tgraf@suug.ch>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	John Linville <linville@tuxdriver.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"buytenh@wantstofly.org" <buytenh@wantstofly.org>,
	Aviad Raveh <aviadr@mellanox.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, shm@cumulusnetworks.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:34479 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbaLEODf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 09:03:35 -0500
In-Reply-To: <5481A7E1.7070708@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/5/14, 4:41 AM, Jamal Hadi Salim wrote:
> On 12/05/14 02:10, Roopa Prabhu wrote:
>> On 12/4/14, 10:55 PM, John Fastabend wrote:
>>> On 12/04/2014 10:41 PM, Scott Feldman wrote:
>>>> On Thu, Dec 4, 2014 at 6:26 PM, <roopa@cumulusnetworks.com> wrote:
>>>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>>>
>>>>> This allows offloading to switch asic without having the user to set
>>>>> any flag. And this is done in the bridge driver to rollback kernel
>>>>> settings
>>>>> on hw offload failure if required in the future.
>>>>>
>>>>> With this, it also makes sure a notification goes out only after the
>>>>> attributes are set both in the kernel and hw.
>>>>
>>>> I like this approach as it streamlines the steps for the user in
>>>> setting port flags.  There is one case for FLOODING where you'll have
>>>> to turn off flooding for both, and then turn on flooding in hw. You
>>>> don't want flooding turned on on kernel and hw.
>>>>
>>>>> ---
>>>>>   net/bridge/br_netlink.c |   27 ++++++++++++++++++++++++++-
>>>>>   1 file changed, 26 insertions(+), 1 deletion(-)
>>>>>
>>>>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>>>>> index 9f5eb55..ce173f0 100644
>>>>> --- a/net/bridge/br_netlink.c
>>>>> +++ b/net/bridge/br_netlink.c
>>>>> @@ -407,9 +407,21 @@ int br_setlink(struct net_device *dev, struct
>>>>> nlmsghdr *nlh)
>>>>>                                  afspec, RTM_SETLINK);
>>>>>          }
>>>>>
>>>>> +       if ((dev->features & NETIF_F_HW_SWITCH_OFFLOAD) &&
>>>>> + dev->netdev_ops->ndo_bridge_setlink) {
>>>>> +               int ret = dev->netdev_ops->ndo_bridge_setlink(dev,
>>>>> nlh);
>>>>
>>>> I think you want to up-level this to net/core/rtnetlink.c because
>>>> you're only enabling the feature for one instance of a driver that
>>>> implements ndo_bridge_setlink: the bridge driver.  If another driver
>>>> was MASTER and implemented ndo_bridge_setlink, you'd want same check
>>>> to push setting down to SELF port driver.
>>>
>>> Also if the user set SELF && MASTER flags && had HW_SWITCH_OFFLOAD bit
>>> set we would call ndo_bridge_setlink twice on the dev. Maybe you can
>>> catch this case in rtnetlink.c and only call it once.
>>
>> yes, thought about this and when i looked at iproute2 code, it is either
>> master
>> or self today and i don't think anybody else uses both flags with the
>> current
>> kernel implementation. But yes, that does not stop anybody from setting
>> both flags.
>> I will handle it better in v2.
>
> folks, can we have probably 2-3 sets of patches?
> #1 introduces the flags and doesnt change anything.
> Others to introduce other features.
sure, I was thinking about doing that. I plan to send the "swdev" mode 
related patches first.
And the others as separate sets.




> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
