From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: reduce RECURSION_LIMIT to 8
Date: Mon, 11 Jan 2016 13:24:15 +0100
Message-ID: <56939EEF.70403@stressinduktion.org>
References: <1452188453-5523-1-git-send-email-hannes@stressinduktion.org>
 <CAOrHB_AWdZw1XDmxVU=bDh=gB2M3cnXUC8MyXCnV1YVjZEAsKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:47985 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759797AbcAKMYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 07:24:17 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id BE60A20C11
	for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 07:24:16 -0500 (EST)
In-Reply-To: <CAOrHB_AWdZw1XDmxVU=bDh=gB2M3cnXUC8MyXCnV1YVjZEAsKw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11.01.2016 07:38, pravin shelar wrote:
> On Thu, Jan 7, 2016 at 9:40 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> When RECURSION_LIMIT was first introduced, Eric proposed a limit of 3.
>> This limit was later raised to 10 by DaveM. Nowadays it is observed that
>> configuraion errors in openvswitch cause the STACK_END_MAGIC to be
>> overwritten shortly after 9 recursion.
>>
> Major user of stack space in OVS is sw_flow_key in
> ovs_vport_receive(). With recent features like IPv6 tunnel support we
> have increased the size of the flow-key which could have caused the
> stack overflow sooner.
> One way to avoid using stack in subsequent recursive call is to use
> per-cpu storage for the sw_flow_key object. This is already done for
> OVS recursive actions, so we can expand on that facility.

Hmmm. This already came up. I think the difficulty is that 
ovs_vport_receive can be called from actions again with skb_cloned skb 
before the original's skb callstack is actually finished. Data in the 
percpu area would be overwritten while still being used. It would need 
some more logic IMHO.

What are recursive actions in ovs? I couldn't find any use of pcpu data 
in there? Thanks! :)

We could as an intermediate step add a recursion counter to openvswitch 
and limit call chains to depth 5, what do you think?

Bye,
Hannes
