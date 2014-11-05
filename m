From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [0/3] net: Kill skb_copy_datagram_const_iovec
Date: Wed, 5 Nov 2014 01:53:55 +0000
Message-ID: <20141105015355.GN7996@ZenIV.linux.org.uk>
References: <20141103002207.GA26588@gondor.apana.org.au>
 <20141103004503.GX7996@ZenIV.linux.org.uk>
 <20141103053751.GA27845@gondor.apana.org.au>
 <20141103.150553.633529234958324183.davem@davemloft.net>
 <20141104054513.GB7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org,
	Steve French <sfrench@samba.org>, Sage Weil <sage@inktank.com>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141104054513.GB7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 04, 2014 at 05:45:13AM +0000, Al Viro wrote:

> Hell knows; I hadn't finished digging through that zoo - got sidetracked back
> then.  *IF* all such places either use a throwaway copy or assume that iovec
> gets modified, we can do the following: switch the access to iovecs to
> iov_iter primitives, with the first kind of callers creating a throwaway
> iov_iter and the second just feeding the same iov_iter to e.g.
> kernel_recvmsg().  iovec will remain constant, iov_iter will be advanced.
> Moreover, in a lot of cases of first kind will be able to get rid of
> throwaway iov_iter (and of manually advancing it), effectively converting
> to the second one.

All right, now I _have_ finished that.  See the resulting notes below.
TL;DR version: looks like hypothesis above is correct, modulo 2 places,
both buggy - cifs smb_send_kvec() apparently relies on ->sendmsg() leaving the
iovec unchanged and so does of the ceph_tcp_sendmsg() callers
(write_partial_kvec()).  For TCP that's not always true.  Another apparent
bug caught in process is iscsi iscsit_do_tx_data() - assumes that iovec is
being consumed by sendmsg().  I don't see how that could not be a bug - TCP
sockets can get there and tcp_sendmsg() normally *doesn't* modify the iovec.
Sometimes it does, unfortunately for other two places...

Maintainers Cc'd...


Full version follows:
-----------------------------------------------------------------------------
->sendmsg(): there's such method in struct proto_ops and in struct proto; the
latter is called by (some of) the former, in cases when ->sendmsg() isn't the
same for the entire family.

Instances of proto ->sendmsg() are, on several occasions, called directly; some
of those calls are from another such instance (with unchanged payload).  There
are two exceptions to that - in tipc_accept() and tipc_connect() we call such
instances with empty payload.  All calls via method are from proto_ops
->sendmsg() instances, payload unchanged.

Instances of proto_ops ->sendmsg() are almost never called directly.  All
exceptions are from another such instance with unchanged payload.

There are two places that call proto_ops ->sendmsg() via method -
__sock_sendmsg_nosec() in net/socket.c, and handle_tx() in drivers/vhost/net.c.
The latter appears to be playing somewhat unusual games with passing NULL iocb,
making it impossible to use the former...  Everybody else in the kernel goes
through __sock_sendmsg_nosec(), though - it's a chokepoint for sendmsg path.

vhost callsite is somewhat worrying - granted, most of the ->sendmsg()
instances don't give a damn about iocb at all.  The rest, though...
E.g. what happens if we do VHOST_NET_SET_BACKEND with backend.fd being an
AF_UNIX socket?  AFAICS, if it ever gets to that ->sendmsg() call afterwards,
we'll get an oops when e.g. unix_dgram_sendmsg() calls kiocb_to_siocb(NULL).
The same goes for AF_NETLINK; AF_TIPC is even more interesting, since there
NULL iocb is used as "we are in weird callchain, socket is already locked"
flag (for tipc_{accept,connect}() callsites).  What's going on there?
[After having talked with mst: drivers/vhost/net.c checks that it's
AF_PACKET/SOCK_RAW (packet_sendmsg()) *or* comes from tun.c (tun_sendmsg())
or from macvtap.c (macvtap_sendmsg()) and all of those ignore iocb completely]

FWIW, the situation with iocb is
	* AF_UNIX and AF_NETLINK use it to get to sock_iocb
	* AF_TIPC uses it as a flag - it never dereferences the damn thing and
only compares it with NULL, to determine whether it's in a normal call chain,
or in tipc_accept/tipc_connect one...
	* everything else ignores it completely, either directly or after
passing it to something that ignores it (rxrpc has unusually deep chain, but it
still ends up ignoring the sucker).

->recvmsg(): again, present in proto_ops and proto, in the same relationship
to each other.  The situation is a bit simpler there: there is only one direct
caller of an instance of struct proto ->recvmsg() and it is in another such
instance, arguments unchanged.  All callers via method are in the instances of
struct proto_ops ->recvmsg(), message-related arguments unchanged.  No direct
callers of struct proto_ops recvmsg, three call sites via method - regular one
in __sock_recvmsg_nosec() plus two in drivers/vhost/net.c.  The latter have
NULL iocb and are saved from oopsing in ->recvmsg() by the same logics that
saves vhost on sendmsg side.  iocb is ignored by everything except AF_UNIX
and AF_NETLINK (those use it for sock_iocb) and neither can be reached from
vhost path.

So it boils down to the following: drivers/vhost/net.c aside, everything goes
through __sock_sendmsg_nosec() on the sendmsg side and __sock_recvmsg_nosec()
on recvmsg one.

Call chains leading to __sock_sendmsg_nosec():

__sock_sendmsg_nosec()
	<- sock_sendmsg_nosec()
		<- ___sys_sendmsg()
			<- __sys_sendmsg()
				<- sys_compat_sendmsg()
				<- sys_sendmsg()
			<- __sys_sendmmsg()
				<- sys_compat_senmmmsg()
				<- sys_sendmmsg()
	<- __sock_sendmsg()
		<- do_sock_write()
			<- sock_aio_write()
				== ->aio_write()
		<- sock_sendmsg()
			<- svc_sendto()	[no iovec at all]
			<- ___sys_sendmsg() [see above]
			<- sys_sendto()
			<- kernel_sendmsg()
All syscalls (and there's quite a tangled mess with sys_socketcall,
assorted ARM wrappers, etc.) end up with iovec discarded.
Ditto for ->aio_write() callers - they all free the iovec soon after
->aio_write() returns and never look at it before freeing.

Call chains leading to __sock_recvmsg_nosec():

__sock_recvmsg_nosec()
	<- sock_recvmsg_nosec()
		<- ___sys_recvmsg()
			<- __sys_recvmsg()
				<- sys_compat_recvmsg()
				<- sys_recvmsg()
			<- __sys_recvmmsg()
				<- sys_compat_recvmmsg()
				<- sys_recvmmsg()
	<- __sock_recvmsg()
		<- do_sock_read()
			<- sock_aio_read()
				== ->aio_read()
		<- sock_recvmsg() [why is it not static, BTW?]
			<- ___sys_recvmsg() [see above]
			<- sys_recvfrom()
			<- kernel_recvmsg()
Again, both the sycalls and ->aio_read() callers end up discarding
iovec.

All of that leaves us with kernel_{send,recv}msg() as the next-order
chokepoints.

kernel_recvmsg() callers:
	drbd drbd_recv_short() - single-element iovec discarded
	nbd sock_xmit() - single-element iovec discarded; would be better off
with advancing iov_iter.
	isdn l1oip_socket_thread() - single-element iovec discarded
	lustre ksocknal_lib_recv_iov() - iovec copied (with unhappy comment),
copy passed to kernel_recvmsg() and discarded
	lustre ksocknal_lib_recv_kiov() - ditto.  Would be much better off
with bvec-based iov_iter
	lustre libcfs_sock_read() - single-element iovec discarded; would be
better off with advancing iov_iter.
	iscsi iscsit_do_rx_data() - assumes that iovec is being consumed.
AFAICS, it's guaranteed to be TCP and tcp_recvmsg() appears to act that way,
so it's probably OK...
	usbip usbip_recv() - single-element iovec discarded; would be better
off with advancing iov_iter
	cifs cifs_readv_from_socket() - iovec copied, copy passed to
kernel_recvmsg() and discarded; *definitely* would be better off with advancing
iov_iter.
	dlm receive_from_sock() - 1- or 2-element iovec discarded.
	ncpfs _recv() - single-element iovec discarded.
	ocfs2 o2net_recv_tcp_msg() - single-element iovec discarded.
	ceph ceph_tcp_recvmsg() - single-element iovec discarded; at least one
of the loops using it would be better off with advancing iov_iter.
	ipvs ip_vs_receive() - single-element iovec discarded.
	sunrpc svc_udp_recvfrom() - no payload (MSG_PEEK, that one)
	tipc tipc_receive_from_sock() - single-element iovec discarded.
	sunrpc svc_recvfrom() - confusing; looks like iovec is a throwaway
one, though (and we might be better off if we could use an iov_iter of bvec
sort instead).

kernel_sendmsg() callers:
	drbd drbd_send() - single-element iovec discarded; would be better
off with advancing iov_iter
	nbd sock_xmit() - ditto
	isdn l1oip_socket_send() - single-element iovec discarded
	iscsi iscsi_sw_tcp_xmit_segment() - single-element iovec discarded
	lustre ksocknal_lib_send_iov() - iovec copied (with unhappy comment),
copy passed to kernel_sendmsg() and discarded
	lustre ksocknal_lib_send_kiov - ditto.  Would be much better off
with bvec iov_iter.
	lustre libcfs_sock_write() - single-element iovec discarded; better
off with advancing iov_iter
	iscsi iscsit_do_tx_data() - assumes that iovec is being consumed.
I don't see how that could not be a bug - TCP sockets can get there.
	usbip stub_send_ret_submit() - iovec is built and discarded;
short write is treated as an error
	usbip stub_send_ret_unlink() - ditto
	usbip vhci_send_cmd_submit() - ditto
	usbip vhci_send_cmd_unlink() - ditto
	cifs smb_send_kvec() - apparently relies on ->sendmsg() leaving the
iovec unchanged.  Looks like a bug - tcp_sendmsg() might drain iovec in some
cases.
	dlm sctp_send_shutdown() - no payload
	dlm sctp_init_assoc() - single-element iovec discarded
	ncpfs do_send() - single-element iovec discarded
	ocfs2 o2net_send_tcp_msg() - callers pass it a throwaway iovec
	bnep bnep_send() - single-element iovec discarded
	bnep_tx_frame() - short iovec is built and discarded
	cmtp_send_frame() - single-element iovec discarded
	hidp_send_frame() - single-element iovec discarded
	rfcomm_send_frame() - single-element iovec discarded
	rfcomm_send_test() - short iovec is built and discarded
	core sock_no_sendpage*() - single-element iovec discarded
	ipvs ip_vs_send_async() - single-element iovec discarded
	rds rds_tcp_sendmsg() - single-element iovec discarded
	rxrpc rxrpc_busy() - single-element iovec discarded
	rxrpc rxrpc_process_call() - short iovec is built and discarded
	rxrpc rxrpc_abort_connection() - short iovec is built and discarded
	rxrpc rxrpc_reject_packets() - assumes that sendmsg drains iovec;
may be a bug.
	rxrpc rxrpc_send_packet() - single-element iovec discarded
	rxrpc rxkad_issue_challenge() - short iovec is built and discarded
	rxrpc rxkad_send_response - short iovec is built and discarded
	sunrpc xs_send_kvec() - single-element iovec discarded; really asks
or iov_iter...
	tipc tipc_send_to_sock() - single-element iovec discarded; for some
reason it seems to believe that short writes never happen...
	ceph ceph_tcp_sendmsg() - one caller appears to discard iovec, another
(write_partial_kvec()) apparently assumes that iovec is unchanged by sendmsg.
Not guaranteed to be true for TCP, AFAICAS.
