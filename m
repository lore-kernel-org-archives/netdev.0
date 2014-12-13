From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [WTF?] random test in netlink_sendmsg()
Date: Sat, 13 Dec 2014 03:25:00 +0000
Message-ID: <20141213032500.GH22149@ZenIV.linux.org.uk>
References: <20141212213242.GE22149@ZenIV.linux.org.uk>
 <20141212.200758.944592759380344519.davem@davemloft.net>
 <20141213015415.GG22149@ZenIV.linux.org.uk>
 <20141212.213313.1419808296502891420.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:53616 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964843AbaLMDZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 22:25:03 -0500
Content-Disposition: inline
In-Reply-To: <20141212.213313.1419808296502891420.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2014 at 09:33:13PM -0500, David Miller wrote:

> Ok, so we just adjust the AF_PACKET check to test msg_iovlen==1 as
> well, and that takes care of that case.

AF_NETLINK, I suppose?  AF_PACKET is avoiding all those contortions - they
simply do
        if (po->tx_ring.pg_vec)
                return tpacket_snd(po, msg);
        else
                return packet_snd(sock, msg, len);
IOW, if you have done PACKET_TX_RING, you get msg_iov completely ignored and
tx_ring used as data source, otherwise you get data coming from msg_iov.

For AF_NETLINK what you suggest would work, AFAICS.  It's still bloody weird,
(if we want to be able to mix from-msg_iov and from-tx_ring sends on the same
socket, I'd probably go with MSG_<something> in flags), but existing userland
ABI is existing userland ABI...

So in term of msg_iter, it turns into
	/* It's a really convoluted way for userland to ask for mmaped
	 * sendmsg(), but that's what we've got...  */
	if (netlink_tx_is_mmaped(sk) &&
	    msg->msg_iter.type == KVEC_ITER &&
	    msg->msg_iter.nr_segs == 1 &&
	    msg->msg_iter.iov->iov_base == NULL) {
		err = netlink_mmap_sendmsg(sk, msg, dst_portid, dst_group,
					   siocb);
                goto out;
	}

OK, that works...

Next fun place: AF_CAIF/SOCK_SEQPACKET has sendmsg() treating NULL
msg_iov[0].iov_base as EINVAL.  No idea why - without that check zero-length
sendmsg() with such msg_iov would work and non-zero-length one would
fail with EFAULT instead.  And this check is just as random in case of
msg_iovlen being 0.  Could CAIF folks explain what's going on there?
My preference would be to remove that check completely...
