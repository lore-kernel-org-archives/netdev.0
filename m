From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] netlink broadcast return value
Date: Tue, 10 Feb 2009 00:23:06 +0100
Message-ID: <4990BADA.7040309@trash.net>
References: <4985A4C5.4050908@netfilter.org> <20090202.140533.121159038.davem@davemloft.net> <49903B03.2040302@trash.net> <4990B38A.3020207@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34359 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbZBIXXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 18:23:09 -0500
In-Reply-To: <4990B38A.3020207@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso wrote:
> Patrick McHardy wrote:
>> David Miller wrote:
>>> From: Pablo Neira Ayuso <pablo@netfilter.org>
>>> Date: Sun, 01 Feb 2009 14:33:57 +0100
>>>
>>>> In short, I think that the change that I'm proposing would also require
>>>> to fix some netlink_broadcast() clients to skip ENOBUFS errors: they are
>>>> not meaningful for them since they assume that Netlink is unreliable and
>>>> so the return value does not provide any useful information.
>>> I think this analysis is accurate.
>> We have at least one case where the caller wants to know of
>> any successful delivery. Keymanager queries done by xfrm_state
>> want to know whether an acquire was delivered to any keymanager.
>> So we need to continue to indicate this, maybe using a different
>> errno code than -ENOBUFS. I don't have a suggestion which one to
>> use though.
> 
> Indeed, I have missed that spot. I'm not very familiar with that code,
> however, I see that the creation of a state depends on the netlink
> broadcast return value, but how useful is that? I think that the state
> should be created even if the broadcast fails, the userspace daemon
> should request a resync to the kernel as soon as it hits ENOBUFS, then
> it would be in sync again with that state.

The idea is that the kernel is performing an active query. I agree
that there's nothing wrong with installing the SA and indicating the
error to userspace. Userspace could dump the SADB and look for new
larval states, however thats unlikely to be very useful since once
an overflow occurs, you probably have a lot of states.

But unless I'm missing something, there's nothing wrong with this
as long as the error is ignored. The fact that something was received
by some listener doesn't have any meaning anyways, it might have
been "ip monitor". Which somehow raises doubt about your proposed
interface change though, I think anything that wants a reliable
answer whether a packet was delivered to a process handling it
appropriately should use unicast.
