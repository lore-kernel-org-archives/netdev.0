From: David Miller <davem@davemloft.net>
Subject: Re: question about klen in move_addr_to_user()
Date: Tue, 19 Mar 2013 09:55:47 -0400 (EDT)
Message-ID: <20130319.095547.1333124517060824574.davem@davemloft.net>
References: <20130318101007.GO9189@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42743 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922Ab3CSNzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 09:55:49 -0400
In-Reply-To: <20130318101007.GO9189@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 18 Mar 2013 13:10:07 +0300

> The call tree is this:
> 
> __sys_recvmsg() gets the msg->msg_namelen from the user.
> 
> Normally the network protocols set msg->msg_namelen in their
> ->recvmsg() function but some don't like caif_seqpkt_recvmsg() and
> recv_msg() for tipc.

In fact, even TCP will just leave the msg->msg_namelen alone.

I think the best thing to do is to cap the klen to the size of
sockaddr_storage in verify_iovec() when mode is not VERIFY_READ.

But actually, it looks like sendmsg() has a similar problem.
We use m->msg_namelen as-is in verify_iovec() via __sys_sendmsg()
when mode is VERIFY_READ.

This makes me think that we should cap this at the precise moment
we import the user's msghdr.  Which means:

1) Create a helper function copy_msghdr_from_user() and use
   it everywhere we do the straight copy_from_user(msg_sys, ...)

2) In both copy_msghdr_from_user() and get_compat_msghdr(), cap
   the msg_namelen to sizeof(struct sockaddr_storage).

That should eliminate any and all problems in this area.

Thanks Dan.
