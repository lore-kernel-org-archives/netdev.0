From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: breaks blocking receive for other users (was: [PATCH 01/02] core: enable more fine-grained datagram reception control)
Date: Mon, 07 Dec 2015 23:15:56 +0000
Message-ID: <874mft7sur.fsf_-_@doppelsaurus.mobileactivedefense.com>
References: <874mfv7055.fsf@doppelsaurus.mobileactivedefense.com>
	<20151206.233038.1580536748391971635.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rweikusat@mobileactivedefense.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151206.233038.1580536748391971635.davem@davemloft.net> (David
	Miller's message of "Sun, 06 Dec 2015 23:30:38 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:
> From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
> Date: Sun, 06 Dec 2015 21:11:34 +0000
>
>> The __skb_recv_datagram routine in core/ datagram.c provides a general
>> skb reception factility supposed to be utilized by protocol modules
>> providing datagram sockets. It encompasses both the actual recvmsg code
>> and a surrounding 'sleep until data is available' loop. This is
>> inconvenient if a protocol module has to use additional locking in order
>> to maintain some per-socket state the generic datagram socket code is
>> unaware of (as the af_unix code does). The patch below moves the recvmsg
>> proper code into a new __skb_try_recv_datagram routine which doesn't
>> sleep and renames wait_for_more_packets to
>> __skb_wait_for_more_packets, both routines being exported interfaces. The
>> original __skb_recv_datagram routine is reimplemented on top of these
>> two functions such that its user-visible behaviour remains unchanged.
>> 
>> Signed-Off-By: Rainer Weikusat <rweikusat@mobileactivedefense.com>
>
> Applied to net-next.

Because of an oversight, this change breaks blocking datagram reception
for anyone but the AF_UNIX SOCK_DGRAM code. I've noticed this by chance
while running a test program for SOCK_STREAM sockets. The problem seems
to be (fix not yet tested) that a - is missing in the *err check in
__skb_recv_datagram.

Proposed fix:

------------
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 7daff66..fa9dc64 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -275,7 +275,7 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
                if (skb)
                        return skb;
 
-               if (*err != EAGAIN)
+               if (*err != -EAGAIN)
                        break;
        } while (timeo &&
                !__skb_wait_for_more_packets(sk, err, &timeo, last));
-------------

Provided this works (very likely), I'll send a real patch for that ASAP.
