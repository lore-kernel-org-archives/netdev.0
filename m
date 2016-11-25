From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 5/5] udp: add recvmmsg implementation
Date: Fri, 25 Nov 2016 18:09:00 +0100
Message-ID: <1165706e-b828-cb12-4bea-b77ccca1cb95@stressinduktion.org>
References: <cover.1480086321.git.pabeni@redhat.com>
 <68bfaa7480400457e712fb04ee781410d1bb9479.1480086321.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Sabrina Dubroca <sd@queasysnail.net>
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:36937 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932395AbcKYRJD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 12:09:03 -0500
In-Reply-To: <68bfaa7480400457e712fb04ee781410d1bb9479.1480086321.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25.11.2016 16:39, Paolo Abeni wrote:
> skbs are extracted from the receive queue in burts, and a single
> sk_rmem_alloc/forward allocated memory update is performed for
> each burst.
> MSG_PEEK and MSG_ERRQUEUE are not supported to keep the implementation
> as simple as possible.
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

During review we discussed on how to handle major errors in the kernel:

The old code and the new code still can report back success even though
the kernel got back an EFAULT while copying from kernel space to user
space (due to bad pointers).

I favor that we drop all packets (also the already received batches) in
this case and let the code report -EFAULT and increase sk_drops for all
dropped packets from the queue.

Currently sk_err is set so the next syscall would get an -EFAULT, which
seems very bad and can also be overwritten by incoming icmp packets, so
we never get a notification that we actually had a bad pointer somewhere
in the mmsghdr. Also delivering -EFAULT on the follow-up syscalls really
will make people confused that use strace.

If people would like to know the amount of packets dropped we can make
sk_drops readable by an getsockopt.

Thoughts?

Unfortunately the interface doesn't allow for better error handling.
