From: Benjamin Poirier <bpoirier@suse.de>
Subject: Re: [PATCH net 1/3] unix/dgram: peek beyond 0-sized skbs
Date: Fri, 26 Apr 2013 14:35:10 -0400
Message-ID: <1367001312-6719-1-git-send-email-bpoirier@suse.de>
References: <1366915736.8964.171.camel@edumazet-glaptop>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366915736.8964.171.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013/04/25 11:48, Eric Dumazet wrote:
> On Thu, 2013-04-25 at 09:47 -0400, Benjamin Poirier wrote:
> > "77c1090 net: fix infinite loop in __skb_recv_datagram()" (v3.8) introduced a
> > regression:
> > After that commit, recv can no longer peek beyond a 0-sized skb in the queue.
> > __skb_recv_datagram() instead stops at the first skb with len == 0 and results
> > in the system call failing with -EFAULT via skb_copy_datagram_iovec().
> 
> 
> if MSG_PEEK is not used, what happens here ?

I'm not sure what you're question is aiming at, but if MSG_PEEK isn't used,
there's no difference with regards to this patch. It's all in the "if (flags &
MSG_PEEK)" block.

More generally, without MSG_PEEK, a sequence of
	send(..., len=10, ...); send(len=0); send(len=20)
results in
	recv()=10; recv()=0; recv()=20; recv()= /* blocks */

With flags=MSG_PEEK, a sequence of
	send(len=10); send(len=0); send(len=20)
resulted (without any patch) in
	setsockopt(..., SO_PEEK_OFF -> 0);
	recv()=10; recv()=0; recv()=0; recv()=0; ...
and with v2 of the patch, results in
	setsockopt(..., SO_PEEK_OFF -> 0);
	recv()=10; recv()=0; recv()=20; recv()= /* blocks */

We could also have the following sequence
	setsockopt(..., SO_PEEK_OFF -> 10);
	recv()=0; recv()=20; recv()= /* blocks */
or
	setsockopt(..., SO_PEEK_OFF -> 5);
	recv()=5; recv()=0; recv()=20; recv()= /* blocks */
or the unfortunate
	setsockopt(..., SO_PEEK_OFF -> 0);
	recv()=10; recv()=0; recv()=20;
	setsockopt(..., SO_PEEK_OFF -> 0);
	recv()=10;         ; recv()=20; recv()= /* blocks */

That last one could be changed by resetting the skb->peeked flag for all
buffers the queue during sock_setsockopt SO_PEEK_OFF. If you think it's better
that way.

> 
> It doesn't look right to me that we return -EFAULT if skb->len is 0,
> EFAULT is reserved to faulting (ie reading/writing at least one byte)

That's what happens when skb_copy_datagram_iovec() is asked to copy > 0 bytes
out of a skb with len == 0.

Perhaps skb_copy_datagram_iovec() should be changed to use EINVAL in that case
but we can avoid that kind of call altogether by fixing the problem with
MSG_PEEK.

> 
> How are we telling the user message had 0 byte, but its not EOF ?
> 

We aren't, but what's EOF on a datagram socket?

Thank you for the review.


Subject: [PATCH net v2 1/3] unix/dgram: peek beyond 0-sized skbs

"77c1090 net: fix infinite loop in __skb_recv_datagram()" (v3.8) introduced a
regression:
After that commit, recv can no longer peek beyond a 0-sized skb in the queue.
__skb_recv_datagram() instead stops at the first skb with len == 0 and results
in the system call failing with -EFAULT via skb_copy_datagram_iovec().

When peeking at an offset with 0-sized skb(s), each one of those is received
only once, in sequence. The offset starts moving forward again after receiving
datagrams with len > 0.

Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
---

* v2 also fix the situation when sk_peek_off must advance to and beyond a
  0-sized skb

* v1 fix the case when SO_PEEK_OFF is used to set sk_peek_off beyond a
  0-sized skb

 net/core/datagram.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index 368f9c3..99c4f52 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -187,7 +187,8 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 		skb_queue_walk(queue, skb) {
 			*peeked = skb->peeked;
 			if (flags & MSG_PEEK) {
-				if (*off >= skb->len && skb->len) {
+				if (*off >= skb->len && (skb->len || *off ||
+							 skb->peeked)) {
 					*off -= skb->len;
 					continue;
 				}
-- 
1.7.10.4
