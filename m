From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] ipv6: recreate ipv6 link-local addresses when
 increasing MTU over IPV6_MIN_MTU
Date: Mon, 26 Oct 2015 10:07:32 -0700
Message-ID: <562E5DD4.40908@gmail.com>
References: <1445870205-27202-1-git-send-email-hannes@stressinduktion.org>
 <562E4C26.3030501@gmail.com>
 <1445875501.168420.420547673.4BB6C209@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:32907 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429AbbJZRHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 13:07:34 -0400
Received: by pabla5 with SMTP id la5so623479pab.0
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 10:07:33 -0700 (PDT)
In-Reply-To: <1445875501.168420.420547673.4BB6C209@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2015 09:05 AM, Hannes Frederic Sowa wrote:
> Hi Alex,
>
> On Mon, Oct 26, 2015, at 16:52, Alexander Duyck wrote:
>> On 10/26/2015 07:36 AM, Hannes Frederic Sowa wrote:
>>> Take into consideration that the interface might be disabled for IPv6,
>>> thus switch event type.
>>>
>>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>>> ---
>>>    net/ipv6/addrconf.c | 7 +++++--
>>>    1 file changed, 5 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>>> index d0c685c..c2dcebe 100644
>>> --- a/net/ipv6/addrconf.c
>>> +++ b/net/ipv6/addrconf.c
>>> @@ -3149,6 +3149,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
>>>    
>>>    	case NETDEV_UP:
>>>    	case NETDEV_CHANGE:
>>> +netdev_change:
>>>    		if (dev->flags & IFF_SLAVE)
>>>    			break;
>>>    
>>> @@ -3244,8 +3245,10 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
>>>    
>>>    		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
>>>    			idev = ipv6_add_dev(dev);
>>> -			if (!IS_ERR(idev))
>>> -				break;
>>> +			if (!IS_ERR(idev)) {
>>> +				event = NETDEV_UP;
>>> +				goto netdev_change;
>>> +			}
>>>    		}
>>>    
>>>    		/*
>> Seems like this code isn't quite correct.  You are calling ipv6_add_dev
>> for slave devices, and if I understand things correctly I don't believe
>> that was happening before and may be an unintended side effect.
> Hmm, could you quickly help me where I get into this situation? I made
> sure I enter the NETDEV_UP part before the IFF_SLAVE test and
> disable_ipv6 te

I think I was getting a bit a head of myself.  I was looking over the 
NETDEV_UP code and thinking that we could just fall into that path since 
it is already calling ipv6_add_dev.  However now I am wondering if maybe 
we need to look at adding an idev allocation somewhere before the 
disable_ipv6 check.  I assume that is why you were allocating the idev 
before you were getting into NETDEV_UP?

>> You might want to instead just make it so that you only do the jump, and
>> perhaps change the code in the NETDEV_UP/NETDEV_CHANGE section so that
>> you test for NETDEV_CHANGE instead of NETDEV_UP.  That should be enough
>> to get the effect you are looking for and I believe there would be no
>> change to behaviour other than adding IPv6 link-local addresses when the
>> MTU is increased.
>>
>> Give me a bit and I can submit an alternative that may actually work out
>> a bit better I think.
> If you go the NETDEV_CHANGE route instead of NETDEV_UP, you end up with
> the IF_READY flag already set from ipv6_add_dev and thus won't do any
> initialization of the device.

What I meant was that you don't need to change the event.  If you change 
the check inside the NETDEV_UP/CHANGE code path so that it tests for 
event != NETDEV_CHANGE instead of event == NETDEV_UP you don't need to 
change the event type.

> Sure, I wait.

Might be a bit longer.  I just realized that I think there is another 
bug here where you are going through the NETDEV_UP path even though the 
interface isn't up.  I'll run through some testing this morning to work 
out the kinks.

- Alex
