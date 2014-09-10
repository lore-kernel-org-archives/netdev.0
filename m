From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: Question about synchronize_net() in AF_PACKET close()
Date: Wed, 10 Sep 2014 10:19:34 -0300
Message-ID: <54104FE6.4030404@redhat.com>
References: <CAN8CM3zo3bMxZV_UvywCPNjJrMwMA2-+POfY8cR429iodHRc+A@mail.gmail.com> <20140909.150000.1647602729214485795.davem@davemloft.net>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com, stephen@networkplumber.org
To: martin@martingkelly.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21859 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750734AbaIJNTt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 09:19:49 -0400
In-Reply-To: <20140909.150000.1647602729214485795.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 09-09-2014 19:00, David Miller escreveu:
> From: Martin Kelly <martin@martingkelly.com>
> Date: Tue, 9 Sep 2014 14:44:56 -0700
>
>> In net/packet/af_packet.c, I noticed the following few lines within
>> packet_release:
>>
>>           synchronize_net();
>>           /*
>>            *      Now the socket is dead. No more input will appear.
>>            */
>>           sock_orphan(sk);
>>           sock->sk = NULL;
>>
>>  From testing and code analysis, I have found that it appears to be safe
>> to move sock_orphan and sock->sk = NULL before the synchronize_net()
>> call like so:
>>
>>           /*
>>            *      Now the socket is dead. No more input will appear.
>>            */
>>           sock_orphan(sk);
>>           sock->sk = NULL;
>>           synchronize_net();
>>
>> Could some RCU and/or networking experts chime in about whether this a
>> safe operation? For all I know, there is some deep, fundamental reason
>> why those lines are in the order they are. On the other hand, perhaps
>> there is not.
>
> The synchronize_net() is also there to protect against the prot hook
> which can run asynchronously from the core packet input path on any
> cpu.
>
> You probably want to reference commit:
>
> commit 808f5114a9206fee855117d416440e1071ab375c
> Author: stephen hemminger <shemminger@vyatta.com>
> Date:   Mon Feb 22 07:57:18 2010 +0000
>
>      packet: convert socket list to RCU (v3)
>
> which put the synchronize_net() there in the first place.

And also http://patchwork.ozlabs.org/patch/181605/
Which was an attempt on improving it.

Marcelo
