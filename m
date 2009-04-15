From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] Multicast: Avoid useless duplication of multicast	messages
Date: Wed, 15 Apr 2009 13:19:41 -0400
Message-ID: <49E6172D.8080201@hp.com>
References: <20090414182731.GD14305@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904141447310.30596@qirst.com> <20090414204445.GB17196@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904141740280.3973@qirst.com> <20090415110714.GA21448@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904150841550.10217@qirst.com> <20090415142208.GB21448@hmsreliant.think-freely.org> <49E5F1FF.1000801@hp.com> <20090415155702.GC21448@hmsreliant.think-freely.org> <49E6063B.3040107@hp.com> <20090415163812.GD21448@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:44982 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753103AbZDORTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 13:19:45 -0400
In-Reply-To: <20090415163812.GD21448@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman wrote:
find the multicast in the socket's list.
>>
> Also see above, hes using multicast group 239.x.x.x.  SSM only encompases
> addresses in the 232.0.0.1 to 232.255.255.255 range.  He's using ASM not SSM,
> regardless of what SSM allows.  I agree it sounds like we have a bug in SSM
> behavior, but its not overly relevant to this discussion (saving for the fact
> that his new feature would inadvertantly fix the bug, in addition to altering
> ASM behavior).  If we want to fix the SSM bug, thats great, lets fix it, but
> lets not do it by introducing a new behavior to ASM.

Sorry, but I don't buy it.  What we have is essentially "backward-brokeness".

Looking at BSD, which was the root of the original brokeness, they have it fixed.
The code will skip sockets that are not members of a particular group.  So, we
are trying really hard to stay bug-for-bug compatible with old implementations.

> 
> And thats all moot anyway, becaues Christoph (unless I'm mistaken) is not, and
> does not want to restrict source sending privlidges.  He wants to get data on
> multicast groups from all/any source, he just doesn't want to get multicast data
> from groups he didn't explicitly join in the app doing the receiving, which is
> exactly what you can currently use bind for.

Let's look at it the other way.  What is broken if we actually filter based on the
socket group membership?  The only applications that will be impacted are ones that
do not join groups themselves and expect to get multicast traffic.  Such applications
are broken to start with.

We already do group membership check for the socket. We simply incorrectly determine
that any socket that doesn't list a group.

What's worse is that if you have a socket that doesn't care about any mulicast
destinations (never did an ADD_MEMBERSHIP), it will still get multicast traffic if
it bound to that port.

We need to take into account the socket's multicast group list.

-vlad

> 
> Neil
> 
>> -vlad
>>
>>> In particular, if we fail to match the 'datagram's destination address',
>>>> we deliver the packet, which I believe is in violation of the "MUST NOT" above.
>>>>
>>> I think only if the SSM model is used via the socket extensions the RFC
>>> describes.  If Christophs app is subscribing via IP_ADD_SOURCE_MEMBERSHIP, then
>>> yes, we have a problem.  But everything I've read says he uses the standard, any-source
>>> IP_ADD_MEMBERSHIP option which I think makes assertions from RFC 4607 void.
>>> Christoph, are you using IP_ADD_SOURCE_MEMBERSHIP?
>>>
>>> Neil
>>>
>>>> I've CC'd Dave Stevens, since I'd like to hear his opinion regarding this text.
>>>>
>>>> Thanks
>>>> -vlad
>>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
> 

