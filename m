From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Soft lockup in inet_put_port on 4.6
Date: Mon, 12 Dec 2016 19:44:17 +0100
Message-ID: <3c022731-e703-34ac-55f1-60f5b94b6d62@stressinduktion.org>
References: <CALx6S36OVUqAxq9vNnfHp2eJOuG+gSSg896zzaZoc3Og4tyxFw@mail.gmail.com>
 <1481231024.1911284.813071977.72AF4DEE@webmail.messagingengine.com>
 <1481233016.11849.1@smtp.office365.com>
 <1481243432.4930.145.camel@edumazet-glaptop3.roam.corp.google.com>
 <6C6EE0ED-7E78-4866-8AAF-D75FD4719EF3@fb.com>
 <1481335192.3663.0@smtp.office365.com>
 <1481341624.4930.204.camel@edumazet-glaptop3.roam.corp.google.com>
 <1481343298.4930.208.camel@edumazet-glaptop3.roam.corp.google.com>
 <1481565929.24490.0@smtp.office365.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Josef Bacik <jbacik@fb.com>, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:40703 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750933AbcLLSoV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 13:44:21 -0500
In-Reply-To: <1481565929.24490.0@smtp.office365.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12.12.2016 19:05, Josef Bacik wrote:
> On Fri, Dec 9, 2016 at 11:14 PM, Eric Dumazet <eric.dumazet@gmail.com>
> wrote:
>> On Fri, 2016-12-09 at 19:47 -0800, Eric Dumazet wrote:
>>
>>>
>>>  Hmm... Is your ephemeral port range includes the port your load
>>>  balancing app is using ?
>>
>> I suspect that you might have processes doing bind( port = 0) that are
>> trapped into the bind_conflict() scan ?
>>
>> With 100,000 + timewaits there, this possibly hurts.
>>
>> Can you try the following loop breaker ?
> 
> It doesn't appear that the app is doing bind(port = 0) during normal
> operation.  I tested this patch and it made no difference.  I'm going to
> test simply restarting the app without changing to the SO_REUSEPORT
> option.  Thanks,

Would it be possible to trace the time the function uses with trace? If
we don't see the number growing considerably over time we probably can
rule out that we loop somewhere in there (I would instrument
inet_csk_bind_conflict, __inet_hash_connect and inet_csk_get_port).

__inet_hash_connect -> __inet_check_established also takes a lock
(inet_ehash_lockp) which can be locked from inet_diag code path during
socket diag info dumping.

Unfortunately we couldn't reproduce it so far. :/

Thanks,
Hannes
