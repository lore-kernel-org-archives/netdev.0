From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: raw ipv6 broken in 2.4.19
Date: 13 Aug 2002 19:14:34 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <1029258874.772.97.camel@tux>
References: <200208131358.RAA21125@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200208131358.RAA21125@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

On Tue, 2002-08-13 at 15:58, kuznet@ms2.inr.ac.ru wrote: 

> Very strange. We have similar phenomenon reported with TCP, by the way.
> So, I have to assume that checksumming routine is wrong and does some shit
> sort of relying on an uninitialized data.

I've added some debug printk's and found out that it's the call to
csum_fold that fails in skb_copy_and_csum_datagram_iovec.

skb_copy_and_csum_datagram_iovec is called from:

net/ipv6/raw.c:rawv6_recvmsg()
	if (skb->ip_summed==CHECKSUM_UNNECESSARY) {
		err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
	} else if (msg->msg_flags&MSG_TRUNC) {
		if ((unsigned short)csum_fold(skb_checksum(skb, 0, skb->len, skb->csum)))
			goto csum_copy_err;
		err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
	} else {
		err = skb_copy_and_csum_datagram_iovec(skb, 0, msg->msg_iov);
		      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		if (err == -EINVAL)
			goto csum_copy_err;
	}

This obviosly works with my old ISA ne2k clone but not with the tulip.
And the tcpdump looked ok

Does anyone else have an idea or suggestion I can try?

Alexey, when you had checksum problems, did you see invalid checksums in
tcpdump?

-- 
/Martin

Never argue with an idiot. They drag you down to their level, then beat
you with experience.
