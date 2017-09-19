From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn/i4l: check the message proto does not change
 across fetches
Date: Tue, 19 Sep 2017 16:29:22 -0700 (PDT)
Message-ID: <20170919.162922.1587166055870567077.davem@davemloft.net>
References: <1505847178-3179-1-git-send-email-mengxu.gatech@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, johannes.berg@intel.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        meng.xu@gatech.edu, sanidhya@gatech.edu, taesoo@gatech.edu
To: mengxu.gatech@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505847178-3179-1-git-send-email-mengxu.gatech@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Meng Xu <mengxu.gatech@gmail.com>
Date: Tue, 19 Sep 2017 14:52:58 -0400

> In isdn_ppp_write(), the header (i.e., protobuf) of the buffer is fetched
> twice from userspace. The first fetch is used to peek at the protocol
> of the message and reset the huptimer if necessary; while the second
> fetch copies in the whole buffer. However, given that buf resides in
> userspace memory, a user process can race to change its memory content
> across fetches. By doing so, we can either avoid resetting the huptimer
> for any type of packets (by first setting proto to PPP_LCP and later
> change to the actual type) or force resetting the huptimer for LCP packets.
> 
> This patch does a memcmp between the two fetches and abort if changes to
> the protobuf is detected across fetches.
> 
> Signed-off-by: Meng Xu <mengxu.gatech@gmail.com>

Doing a memcmp() for every buffer is expensive, ugly, and not the
way we usually handle this kind of issue.

Instead, atomically copy the entire buffer, as needed.

Something like:

	struct sk_buff *skb = NULL;
	unsigned char protobuf[4];
	unsigned char *cpy_buf;

	if (lp->isdn_device >= 0 && lp->isdn_channel >= 0 &&
	    (dev->drv[lp->isdn_device]->flags & DRV_FLAG_RUNNING) &&
	    lp->dialstate == 0 &&
	    (lp->flags & ISDN_NET_CONNECTED)) {
			/*
			 * we need to reserve enough space in front of
			 * sk_buff. old call to dev_alloc_skb only reserved
			 * 16 bytes, now we are looking what the driver want
			 */
			hl = dev->drv[lp->isdn_device]->interface->hl_hdrlen;
			skb = alloc_skb(hl + count, GFP_ATOMIC);
			if (!skb) {
				printk(KERN_WARNING "isdn_ppp_write: out of memory!\n");
				return count;
			}
			skb_reserve(skb, hl);
			cpy_buf = skb_put(skb, count);
	} else {
		cpy_buf = protobuf;
		count = sizeof(protobuf);
	}
	if (copy_from_user(cpy_buf, buf, count)) {
		kfree_skb(skb);
		return -EFAULT;
	}
	proto = PPP_PROTOCOL(cpy_buf);
	if (proto != PPP_LCP)
		lp->huptimer = 0;
	...
