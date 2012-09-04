From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question regarding kernel panic in net/ipv4/tcp_output.c
Date: Tue, 04 Sep 2012 14:23:08 +0200
Message-ID: <1346761388.13121.21.camel@edumazet-glaptop>
References: <trinity-daf22487-c4bf-4a4e-ae69-ed50d70f6169-1346759712289@3capp-webde-bs16>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: smka2012@email.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39417 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778Ab2IDMXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 08:23:16 -0400
Received: by bkwj10 with SMTP id j10so2607833bkw.19
        for <netdev@vger.kernel.org>; Tue, 04 Sep 2012 05:23:15 -0700 (PDT)
In-Reply-To: <trinity-daf22487-c4bf-4a4e-ae69-ed50d70f6169-1346759712289@3capp-webde-bs16>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-09-04 at 13:55 +0200, smka2012@email.de wrote:
> Hi,
>  
> I recently had a severe issue with multiple servers that stopped
> working at the same time. By using the stacktrace, I could locate the
> following line in the tcp_retransmit_skb function of the tcp_output.c
> kernel source that led to a kernel panic on all servers. I am using
> Debian 6.0 with the kernel version 2.6.32-45.
>  
> (gdb) list *(tcp_retransmit_skb+0x66)
> 0x1a93 is in tcp_retransmit_skb (net/ipv4/tcp_output.c:1905).
> 1900  if (atomic_read(&sk->sk_wmem_alloc) >
> 1901      min(sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2),
> sk->sk_sndbuf))
> 1902   return -EAGAIN;
> 1903
> 1904  if (before(TCP_SKB_CB(skb)->seq, tp->snd_una)) {
> 
> --->
> 1905   if (before(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
> 1906    BUG();
> <---
>  
> 1907   if (tcp_trim_head(sk, skb, tp->snd_una - TCP_SKB_CB(skb)->seq))
> 1908    return -ENOMEM;
> 1909  }
>  
> Now I am interested in getting to know what can lead to a situation
> that the condition in line 1905 evaluates true and why the kernel goes
> into the BUG() function in that case and does not only return an
> error. All servers reached this line of code. They all were connected
> to a switch that broke the same time. However, I cannot say if the
> switch broke before the servers and eventually affected the servers or
> if the switch was also itself affected by some external event. 
>  
> Thank you very much for your help.
>  
> Kind Regards,
> Sascha
> --

You can see this BUG() as an early notification of a hard to
debug/diagnose bug.

We shouldnt take this path at all.

If we do, we have an earlier bug that we should fix anyway, because
machine is going to crash.

It would be nice you sent the stack trace you had.
