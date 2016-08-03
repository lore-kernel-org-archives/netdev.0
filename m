From: Alan Curry <rlwinm@sdf.org>
Subject: Re: PROBLEM: network data corruption (bisected to e5a4b0bb803b)
Date: Wed, 3 Aug 2016 03:49:26 +0000 (UTC)
Message-ID: <201608030349.u733nRPn000595@sdf.org>
References: <20160728012253.GT2356@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alexmcwhirter@triadic.us, David Miller <davem@davemloft.net>,
	rlwinm@sdf.org, chunkeey@googlemail.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160728012253.GT2356@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Viro wrote:
> 
> Which just might mean that we have *three* issues here -
> 	(1) buggered __copy_to_user_inatomic() (and friends) on some sparcs
> 	(2) your ssl-only corruption
> 	(3) Alan's x86_64 corruption on plain TCP read - no ssl *or* sparc
> anywhere, and no multi-segment recvmsg().  Which would strongly argue in
> favour of some kind of copy_page_to_iter() breakage triggered when handling
> a fragmented skb, as in (1).  Except that I don't see anything similar in
> x86_64 uaccess primitives...
> 

I think I've solved (3) at least...

Using the twin weapons of printk and stubbornness, I have built a working
theory of the bug. I haven't traced it all the way through, so my explanation
may be partly wrong. I do have a patch that eliminates the symptom in all my
tests though. Here's what happens:

A corrupted packet somehow arrives in skb_copy_and_csum_datagram_msg().
During downloads at reasonably high speed, about 0.1% of my incoming
packets are bad. Probably because the access point is that suspicious
Comcast thing.

skb_copy_and_csum_datagram_msg() does this:

		if (skb_copy_and_csum_datagram(skb, hlen, &msg->msg_iter,
					       chunk, &csum))
			goto fault;
		if (csum_fold(csum))
			goto csum_error;

skb_copy_and_csum_datagram() copies the bad data, computes the checksum,
and *advances the iterator*. The checksum is bad, so it goes to
csum_error, which returns without indicating success to userspace, but the
bad data is in the userspace buffer, and since the iterator has advanced,
the proper data doesn't get written to the proper place when it arrives in a
retransmission. The same iterator is still used because we're still in the
same syscall (I guess - this is one of the parts I didn't check out).

My ugly patch fixes this in the most obvious way: make a local copy of
msg->msg_iter before the call to skb_copy_and_csum_datagram(), and copy it
back if the checksum is bad, just before "goto csum_error;". (I wonder if the
other failure exits from this function might need to do the same thing.)

You can probably reproduce this problem if you deliberately inject some
bad TCP checksums into a stream. Just make sure the receiving machine is
in a blocking read() on the socket when the bad packet arrives. You may
need to resend the offending packet afterward with the checksum corrected.

diff --git a/net/core/datagram.c b/net/core/datagram.c
index b7de71f..574d4bf 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -730,6 +730,7 @@ int skb_copy_and_csum_datagram_msg(struct sk_buff *skb,
 {
 	__wsum csum;
 	int chunk = skb->len - hlen;
+	struct iov_iter save_iter;
 
 	if (!chunk)
 		return 0;
@@ -741,11 +742,14 @@ int skb_copy_and_csum_datagram_msg(struct sk_buff *skb,
 			goto fault;
 	} else {
 		csum = csum_partial(skb->data, hlen, skb->csum);
+		memcpy(&save_iter, &msg->msg_iter, sizeof save_iter);
 		if (skb_copy_and_csum_datagram(skb, hlen, &msg->msg_iter,
 					       chunk, &csum))
 			goto fault;
-		if (csum_fold(csum))
+		if (csum_fold(csum)) {
+			memcpy(&msg->msg_iter, &save_iter, sizeof save_iter);
 			goto csum_error;
+		}
 		if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE))
 			netdev_rx_csum_fault(skb->dev);
 	}

-- 
Alan Curry
