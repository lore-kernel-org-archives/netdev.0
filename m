From: David Miller <davem@davemloft.net>
Subject: Re: [patch] RxRPC: use copy_to_user() instead of memcpy()
Date: Tue, 19 Mar 2013 09:42:40 -0400 (EDT)
Message-ID: <20130319.094240.1315516663563952557.davem@davemloft.net>
References: <20130318105503.GA17102@longonot.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42615 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755332Ab3CSNmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 09:42:42 -0400
In-Reply-To: <20130318105503.GA17102@longonot.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 18 Mar 2013 13:55:03 +0300

> This is a user pointer.  Changing the memcpy() to copy_to_user()
> fixes a hang on my system.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> I'm not very familiar with this code, so please review this
> carefully.

It really should be a kernel pointer, not a user pointer.

For example, look at how recvfrom() cooks up a recvmsg method
call:

	struct sockaddr_storage address;
 ...
	msg.msg_name = (struct sockaddr *)&address;
	msg.msg_namelen = sizeof(address);
 ...
	err = sock_recvmsg(sock, &msg, size, flags);

recvmsg() proper works similarly, copying the user msghdr into a
kernel space copy via verify_iovec() or verify_compat_iovec() (and
I can understand how it's not obvious that this is the function
that performs this operation).

>  		/* copy the peer address and timestamp */
>  		if (!continue_call) {
> -			if (msg->msg_name && msg->msg_namelen > 0)
> -				memcpy(msg->msg_name,
> -				       &call->conn->trans->peer->srx,
> -				       sizeof(call->conn->trans->peer->srx));

I bet the size is too large for a sockaddr_storage, and therefore we
spam the kernel stack.  So I can only guess that changing this to a
copy_to_user() fixes the hang because it simply faults on the kernel
destination address.

->srx should be a "struct sockaddr_rxrpc" but that doesn't appear to
exceed the 128-byte size of sockaddr_storage.
