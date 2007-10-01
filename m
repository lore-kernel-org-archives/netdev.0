From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] memory leak in netlink user->kernel processing
Date: Mon, 01 Oct 2007 10:42:45 -0600
Message-ID: <m13awuyeey.fsf@ebiederm.dsl.xmission.com>
References: <20071001142907.GA10022@iris.sw.ru> <470105EA.3090209@trash.net>
	<47010B07.5060009@gmail.com> <47010C3B.7040902@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Denis V. Lunev" <dlunev@gmail.com>,
	"Denis V. Lunev" <den@openvz.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:33737 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590AbXJAQnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 12:43:13 -0400
In-Reply-To: <47010C3B.7040902@trash.net> (Patrick McHardy's message of "Mon,
	01 Oct 2007 17:03:23 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> Denis V. Lunev wrote:
>> By the way, Patrick, this looks like nlk->pid == 0 if and only if this
>> is a kernel socket. Right?
>>
>
> Thats correct.
>
>> I have told with Alexey Kuznetsov and we have discrovered a way to get
>> rid of
>>         skb_queue_tail(&sk->sk_receive_queue, skb);
>>         sk->sk_data_ready(sk, len);
>> in netlink_sendskb/etc for kernel sockets and make user->kernel packets
>> processing truly synchronous.
>>
>> The idea is simple, we should queue/wakeup in kernel->user direction and
>> simply call nlk->data_ready for user->kernel direction. This will remove
>> all the crap we have now. But we need a mark to determine the direction.
>> Which one will be better? (nlk->data_ready) or (nlk->pid == 0)
>
>
> Both would work fine, but I think nlk->pid is better since its
> actually the "address".

Maybe.  nlk->pid is also 0, before the socket is bound so it does
not serve as a reliable indicator that you have a kernel socket.

My gut feel says the best test is:
(nlk->flags & NETLINK_KERNEL_SOCKET)

There is no confusion in that and it is dead obvious what we
are testing for.  Although we do still need to properly handle
the case when netlink_kernel_create is called with a NULL
input method.  As long as get the proper -ECONNREFUSED the
code path doesn't look like it matters.

Eric

