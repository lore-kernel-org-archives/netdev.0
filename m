From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net] net: reduce RECURSION_LIMIT to 8
Date: Tue, 12 Jan 2016 12:41:52 -0800
Message-ID: <CAOrHB_C95YDAKk=AmLB4uXyzLz4B=DNZe-jM8OSa1=BBUqUX0w@mail.gmail.com>
References: <1452188453-5523-1-git-send-email-hannes@stressinduktion.org>
	<CAOrHB_AWdZw1XDmxVU=bDh=gB2M3cnXUC8MyXCnV1YVjZEAsKw@mail.gmail.com>
	<56939EEF.70403@stressinduktion.org>
	<CAOrHB_DKMW6VoVbu1yvHRQRk92w-uUZWaGQURyRxhO=GaOPXsg@mail.gmail.com>
	<56945B7A.6010601@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:52196 "EHLO
	relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753145AbcALUl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 15:41:58 -0500
Received: from mfilter28-d.gandi.net (mfilter28-d.gandi.net [217.70.178.159])
	by relay5-d.mail.gandi.net (Postfix) with ESMTP id 6F79D41C08A
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 21:41:55 +0100 (CET)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
	by mfilter28-d.gandi.net (mfilter28-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id XD8i66MYDVkn for <netdev@vger.kernel.org>;
	Tue, 12 Jan 2016 21:41:54 +0100 (CET)
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	(Authenticated sender: pshelar@ovn.org)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id F1EBA41C088
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 21:41:53 +0100 (CET)
Received: by mail-ig0-f177.google.com with SMTP id z14so152917266igp.0
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 12:41:53 -0800 (PST)
In-Reply-To: <56945B7A.6010601@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2016 at 5:48 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On 12.01.2016 01:36, pravin shelar wrote:
>>
>> On Mon, Jan 11, 2016 at 4:24 AM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>>>
>>> On 11.01.2016 07:38, pravin shelar wrote:
>>>>
>>>>
>>>> On Thu, Jan 7, 2016 at 9:40 AM, Hannes Frederic Sowa
>>>> <hannes@stressinduktion.org> wrote:
>>>>>
>>>>>
>>>>> When RECURSION_LIMIT was first introduced, Eric proposed a limit of 3.
>>>>> This limit was later raised to 10 by DaveM. Nowadays it is observed
>>>>> that
>>>>> configuraion errors in openvswitch cause the STACK_END_MAGIC to be
>>>>> overwritten shortly after 9 recursion.
>>>>>
>>>> Major user of stack space in OVS is sw_flow_key in
>>>> ovs_vport_receive(). With recent features like IPv6 tunnel support we
>>>> have increased the size of the flow-key which could have caused the
>>>> stack overflow sooner.
>>>> One way to avoid using stack in subsequent recursive call is to use
>>>> per-cpu storage for the sw_flow_key object. This is already done for
>>>> OVS recursive actions, so we can expand on that facility.
>>>
>>>
>>>
>>> Hmmm. This already came up. I think the difficulty is that
>>> ovs_vport_receive
>>> can be called from actions again with skb_cloned skb before the
>>> original's
>>> skb callstack is actually finished. Data in the percpu area would be
>>> overwritten while still being used. It would need some more logic IMHO.
>>>
>> You can have stack of flow-keys and allocate a flow-key for each recursive
>> call.
>
>
> Hmm, I came up with something like that but the other day I find it
> unpleasant and think that the kmalloc might anyway end up in the fast
> path:
>
We can avoid the kmalloc using per-cpu array of flow-key. Infact for
first four recursion can be done using stack to avoid any performance
penalty of accessing percpu variables.

>
>
>>> What are recursive actions in ovs? I couldn't find any use of pcpu data
>>> in
>>> there? Thanks! :)
>>>
>> There are couple of recursive actions in OVS, e.g.
>> OVS_ACTION_ATTR_RECIRC. But it is implemented by using per-cpu
>> flow-key stack to avoid recursive function call.
>
>
> Ahh, the deferred_action stuff. I understand. So the idea would be to
> lift even the first entry point to deferred_action a like?
>
> This sounds like it could work but I fear we should find a solution
> for stable, as this seems like a bit more work.
>

I am fine with OVS specific recursion limit as stable tree fix for this issue.

Thanks.
