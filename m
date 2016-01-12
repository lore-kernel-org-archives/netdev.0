From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net] net: reduce RECURSION_LIMIT to 8
Date: Mon, 11 Jan 2016 16:36:11 -0800
Message-ID: <CAOrHB_DKMW6VoVbu1yvHRQRk92w-uUZWaGQURyRxhO=GaOPXsg@mail.gmail.com>
References: <1452188453-5523-1-git-send-email-hannes@stressinduktion.org>
	<CAOrHB_AWdZw1XDmxVU=bDh=gB2M3cnXUC8MyXCnV1YVjZEAsKw@mail.gmail.com>
	<56939EEF.70403@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:34395 "EHLO
	relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932510AbcALAgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 19:36:16 -0500
Received: from mfilter23-d.gandi.net (mfilter23-d.gandi.net [217.70.178.151])
	by relay4-d.mail.gandi.net (Postfix) with ESMTP id B2497172095
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 01:36:14 +0100 (CET)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
	by mfilter23-d.gandi.net (mfilter23-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id hTWS46dhd_-u for <netdev@vger.kernel.org>;
	Tue, 12 Jan 2016 01:36:13 +0100 (CET)
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	(Authenticated sender: pshelar@ovn.org)
	by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 1904417209A
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 01:36:12 +0100 (CET)
Received: by mail-ig0-f172.google.com with SMTP id z14so113923326igp.1
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 16:36:12 -0800 (PST)
In-Reply-To: <56939EEF.70403@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2016 at 4:24 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On 11.01.2016 07:38, pravin shelar wrote:
>>
>> On Thu, Jan 7, 2016 at 9:40 AM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>>>
>>> When RECURSION_LIMIT was first introduced, Eric proposed a limit of 3.
>>> This limit was later raised to 10 by DaveM. Nowadays it is observed that
>>> configuraion errors in openvswitch cause the STACK_END_MAGIC to be
>>> overwritten shortly after 9 recursion.
>>>
>> Major user of stack space in OVS is sw_flow_key in
>> ovs_vport_receive(). With recent features like IPv6 tunnel support we
>> have increased the size of the flow-key which could have caused the
>> stack overflow sooner.
>> One way to avoid using stack in subsequent recursive call is to use
>> per-cpu storage for the sw_flow_key object. This is already done for
>> OVS recursive actions, so we can expand on that facility.
>
>
> Hmmm. This already came up. I think the difficulty is that ovs_vport_receive
> can be called from actions again with skb_cloned skb before the original's
> skb callstack is actually finished. Data in the percpu area would be
> overwritten while still being used. It would need some more logic IMHO.
>
You can have stack of flow-keys and allocate a flow-key for each recursive call.

> What are recursive actions in ovs? I couldn't find any use of pcpu data in
> there? Thanks! :)
>
There are couple of recursive actions in OVS, e.g.
OVS_ACTION_ATTR_RECIRC. But it is implemented by using per-cpu
flow-key stack to avoid recursive function call.
