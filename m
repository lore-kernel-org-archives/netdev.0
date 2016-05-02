From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/2] net: SOCKWQ_ASYNC_NOSPACE optimizations
Date: Mon, 2 May 2016 21:12:29 +0200
Message-ID: <20160502191229.GA1946@nanopsycho.orion>
References: <1461605974-4242-1-git-send-email-edumazet@google.com>
 <1461605974-4242-2-git-send-email-edumazet@google.com>
 <20160502161602.GA1984@nanopsycho.orion>
 <1462206138.5535.255.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, eladr@mellanox.com,
	idosch@mellanox.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:32840 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754722AbcEBTMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 15:12:32 -0400
Received: by mail-wm0-f66.google.com with SMTP id r12so169685wme.0
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 12:12:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1462206138.5535.255.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, May 02, 2016 at 06:22:18PM CEST, eric.dumazet@gmail.com wrote:
>On Mon, 2016-05-02 at 18:16 +0200, Jiri Pirko wrote:
>> Mon, Apr 25, 2016 at 07:39:32PM CEST, edumazet@google.com wrote:
>> >SOCKWQ_ASYNC_NOSPACE is tested in sock_wake_async()
>> >so that a SIGIO signal is sent when needed.
>> >
>> >tcp_sendmsg() clears the bit.
>> >tcp_poll() sets the bit when stream is not writeable.
>> >
>> >We can avoid two atomic operations by first checking if socket
>> >is actually interested in the FASYNC business (most sockets in
>> >real applications do not use AIO, but select()/poll()/epoll())
>> >
>> >This also removes one cache line miss to access sk->sk_wq->flags
>> >in tcp_sendmsg()
>> >
>> >Signed-off-by: Eric Dumazet <edumazet@google.com>
>> 
>> I just bisected down to this. This is causing a regression for me when
>> my nfs mount becomes stuck. I can easily reproduce this if you need to
>> test the fix.
>
>What do you mean by 'when nfs mount becomes stuck' ?
>
>Is this patch making nfs not functional , or does it make recovery from
>some nfs error bad ?

I can mount nfs on the host. But when I do something (compile a kernel
module in my case), it gets stuck. Then I cannot even ssh to the machine.
No messages in dmesg. I didn't debug it any further. I just bisected and
verified that this patch caused this behaviour.
