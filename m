From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: reduce cpu usage when SO_SNDBUF is set
Date: Mon, 20 Jun 2016 15:29:04 -0700
Message-ID: <1466461744.6850.29.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1466457781-24123-1-git-send-email-jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35283 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235AbcFTW3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 18:29:51 -0400
Received: by mail-pf0-f194.google.com with SMTP id t190so12375641pfb.2
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 15:29:07 -0700 (PDT)
In-Reply-To: <1466457781-24123-1-git-send-email-jbaron@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-06-20 at 17:23 -0400, Jason Baron wrote:
> From: Jason Baron <jbaron@akamai.com>
> 
> When SO_SNDBUF is set and we are under tcp memory pressure, the effective
> write buffer space can be much lower than what was set using SO_SNDBUF. For
> example, we may have set the buffer to 100kb, but we may only be able to
> write 10kb. In this scenario poll()/select()/epoll(), are going to
> continuously return POLLOUT, followed by -EAGAIN from write(), and thus
> result in a tight loop. Note that epoll in edge-triggered does not have
> this issue since it only triggers once data has been ack'd. There is no
> issue here when SO_SNDBUF is not set, since the tcp layer will auto tune
> the sk->sndbuf.
> 
> Introduce a new socket flag, SOCK_SHORT_WRITE, such that we can mark the
> socket when we have a short write due to memory pressure. By then testing
> for SOCK_SHORT_WRITE in tcp_poll(), we hold off the POLLOUT until a
> non-zero amount of data has been ack'd. In a previous approach:
> http://marc.info/?l=linux-netdev&m=143930393211782&w=2, I had introduced a
> new field in 'struct sock' to solve this issue, but its undesirable to add
> bloat to 'struct sock'. We also could address this issue, by waiting for
> the buffer to become completely empty, but that may reduce throughput since
> the write buffer would be empty while waiting for subsequent writes. This
> change brings us in line with the current epoll edge-trigger behavior for
> the poll()/select() and epoll level-trigger.
> 
> We guarantee that SOCK_SHORT_WRITE will eventually clear, since when we set
> SOCK_SHORT_WRITE, we make sure that sk_wmem_queued is non-zero and
> SOCK_NOSPACE is set as well (in sk_stream_wait_memory()).
> 
> I tested this patch using 10,000 sockets, and setting SO_SNDBUF on the
> server side, to induce tcp memory pressure. A single server thread reduced
> its cpu usage from 100% to 19%, while maintaining the same level of
> throughput.
> 
> Signed-off-by: Jason Baron <jbaron@akamai.com>
> ---


When this bug was added, and by which commit ?

This looks serious, but your patch looks way too complex.

This SOCK_SHORT_WRITE bit constantly cleared in sk_stream_write_space()
is expensive, because it dirties sk_flags which is not supposed to
written often. This field is located in a read mostly cache line.

I believe my suggestion was not to add a per socket bit,
but have a global state like tcp_memory_pressure. (or reuse it)

Ie , when under global memory pressure, tcp_poll() should apply a
strategy to give POLLOUT only on sockets having less than 4K
(tcp_wmem[0]) of memory consumed in their write queue.
