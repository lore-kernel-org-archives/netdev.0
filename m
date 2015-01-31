From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [RFC][PATCHSET] more iov_iter conversion in net/*
Date: Sat, 31 Jan 2015 03:55:13 +0000
Message-ID: <20150131035513.GK29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:54980 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753388AbbAaDzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 22:55:16 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	->sendmsg() side of that business, now.  By the end of it, we
get all ->sendmsg() instances leaving iovec unchanged and ->msg_iter -
drained.

1/18:	netlink: make the check for "send from tx_ring" deterministic
	As discussed last year.
2/18:	raw_send_hdrinc(): pass msghdr
	Switch from passing msg->iov_iter.iov to passing msg itself
3/18:	rawv6_send_hdrinc(): pass msghdr
	Ditto
4/18:	propagate msghdr all way down to __qp_memcpy_to_queue()
	Ditto
5/18:	switch rxrpc_send_data() to iov_iter primitives
	Convert skb_add_data() to iov_iter; allows to get rid of the explicit
messing with iovec in its only caller - skb_add_data() will keep advancing
->msg_iter for us, so there's no need to similate that manually.
6/18:	make the users of rxrpc_kernel_send_data() set kvec-backed msg_iter
properly
	Use iov_iter_kvec() there, get rid of set_fs() games - now that
rxrpc_send_data() uses iov_iter primitives, it'll handle ITER_KVEC just
fine.	
7/18:	stash a pointer to msghdr in struct ping_fakehdr
	... instead of storing its ->mgs_iter.iov there
8/18:	convert tcp_sendmsg() to iov_iter primitives
	There's one potentially subtle change here: in case of short
copy from userland, mainline tcp_send_syn_data() discards the skb it
has allocated and falls back to normal path, where we'll send as much
as possible after rereading the same data again.  This patch trims
SYN+data skb instead - that way we don't need to copy from the same
place twice.  I _think_ it's correct, but I'd really appreciate a review
of that one.
9/18:	switch memcpy_fromiovec()/memcpy_fromiovecend() users to
copy_from_iter()
	That takes care of the majority of ->sendmsg() instances.
10/18:	tipc ->sendmsg() conversion
	This one needs to copy the same data from user potentially more than
once.  Sadly, MTU changes can trigger that ;-/
11/18:	bury net/core/iovec.c - nothing in there is used anymore
12/18:	switch af_alg_make_sg() to iov_iter
	With that, all ->sendmsg() instances are converted to iov_iter
primitives and are agnostic wrt the kind of iov_iter they are working with.
So's the last remaining ->recvmsg() instance that wasn't kind-agnostic yet.
All ->sendmsg() and ->recvmsg() advance ->msg_iter by the amount actually
copied and none of them modifies the underlying iovec, etc.
13/18:	net/socket.c: fold do_sock_{read,write} into callers
14/18:	switch sockets to ->read_iter/->write_iter
15/18:	switch vhost get_indirect() to iov_iter, kill memcpy_fromiovec()
16/18:	vhost: don't bother with copying iovec in handle_tx()
17/18:	vhost: don't bother copying iovecs in handle_rx(), kill
memcpy_toiovecend()
18/18:	vhost: vhost_scsi_handle_vq() should just use copy_from_user()
	... and with that lib/iovec.c is gone - nothing in there has callers
left.

	The pile after that one will be dealing with the kernel_sendmsg and
kernel_recvmg callers - at that point we can start reaping benefits of
consistent way ->msg_iter is handled.  Note that after these changes if
iov_iter_kvec() is used to initialize ->msg_iter, we don't need the games
with get_fs()/set_fs() anymore; just sock_sendmsg()/sock_recvmsg() will do,
so quite a few of those kernel_{send,recv}msg() callers will turn into
sock_{send,recv}msg() ones.
