From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: sysctl_net_core: check SNDBUF and RCVBUF for min
 length
Date: Wed, 11 Mar 2015 06:25:08 -0700
Message-ID: <1426080308.11398.37.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426073357-6211-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vasily.isaenko@oracle.com
To: Alexey Kodanev <alexey.kodanev@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:45004 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752738AbbCKNZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 09:25:11 -0400
In-Reply-To: <1426073357-6211-1-git-send-email-alexey.kodanev@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-11 at 14:29 +0300, Alexey Kodanev wrote:
> sysctl has sysctl.net.core.rmem_*/wmem_* parameters which can be
> set to incorrect values. Given that 'struct sk_buff' allocates from
> rcvbuf, incorrectly set buffer length could result to memory
> allocation failures. For example, set them as follows:
> 
>     # sysctl net.core.rmem_default=64
>       net.core.wmem_default = 64
>     # sysctl net.core.wmem_default=64
>       net.core.wmem_default = 64
>     # ping localhost -s 1024 -i 0 > /dev/null
> 

Yeah, root users seem to act like monkeys these days ;)

Note the real bug is in unix_stream_sendmsg(), as it assumes
 sk_sndbuf > 130 :

	/* Keep two messages in the pipe so it schedules better */
	size = min_t(int, size, (sk->sk_sndbuf >> 1) - 64);

The 64 here seems to assume skb overhead of linux 0.1 on a hypothetical
16bit host ;)

I guess your fix is fine, but might break applications that were
expecting that sysctl net.core.wmem_default=512  would effectively limit
queue occupancy to one skb (without crashing unix_stream_sendmsg())

As commit eea86af6b1e18d6fa did not trigger bug reports, I think we
should get your patch, and eventually adjust SOCK_MIN_SNDBUF if required
later.

Note that we should also limit max value, because of possible arithmetic
overflows for sk->sk_wmem_alloc.

A max of (1U << 31) might be reasonable ?
