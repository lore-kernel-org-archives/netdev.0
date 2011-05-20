From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH FINAL] SCTP: fix race between sctp_bind_addr_free() and
 sctp_bind_addr_conflict()
Date: Fri, 20 May 2011 19:27:17 -0400
Message-ID: <20110520232717.GA5038@redhat.com>
References: <4DD575A1.4080405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, vladislav.yasevich@hp.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jacek Luczak <difrost.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51225 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751600Ab1ETX10 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 May 2011 19:27:26 -0400
Content-Disposition: inline
In-Reply-To: <4DD575A1.4080405@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2011 at 09:55:13PM +0200, Jacek Luczak wrote:
 > During the sctp_close() call, we do not use rcu primitives to
 > destroy the address list attached to the endpoint.  At the same
 > time, we do the removal of addresses from this list before
 > attempting to remove the socket from the port hash
 >=20
 > As a result, it is possible for another process to find the socket
 > in the port hash that is in the process of being closed.  It then
 > proceeds to traverse the address list to find the conflict, only
 > to have that address list suddenly disappear without rcu() critical
 > section.
 >=20
 > Fix issue by closing address list removal inside RCU critical
 > section.
 >=20
 > Race can result in a kernel crash with general protection fault or
 > kernel NULL pointer dereference:
 >=20
 > kernel: general protection fault: 0000 [#1] SMP
 > kernel: RIP: 0010:[<ffffffffa02f3dde>]  [<ffffffffa02f3dde>] sctp_bi=
nd_addr_conflict+0x64/0x82 [sctp]
 > kernel: Call Trace:
 > kernel:  [<ffffffffa02f415f>] ? sctp_get_port_local+0x17b/0x2a3 [sct=
p]
 > kernel:  [<ffffffffa02f3d45>] ? sctp_bind_addr_match+0x33/0x68 [sctp=
]
 > kernel:  [<ffffffffa02f4416>] ? sctp_do_bind+0xd3/0x141 [sctp]
 > kernel:  [<ffffffffa02f5030>] ? sctp_bindx_add+0x4d/0x8e [sctp]
 > kernel:  [<ffffffffa02f5183>] ? sctp_setsockopt_bindx+0x112/0x4a4 [s=
ctp]
 > kernel:  [<ffffffff81089e82>] ? generic_file_aio_write+0x7f/0x9b
 > kernel:  [<ffffffffa02f763e>] ? sctp_setsockopt+0x14f/0xfee [sctp]
 > kernel:  [<ffffffff810c11fb>] ? do_sync_write+0xab/0xeb
 > kernel:  [<ffffffff810e82ab>] ? fsnotify+0x239/0x282
 > kernel:  [<ffffffff810c2462>] ? alloc_file+0x18/0xb1
 > kernel:  [<ffffffff8134a0b1>] ? compat_sys_setsockopt+0x1a5/0x1d9
 > kernel:  [<ffffffff8134aaf1>] ? compat_sys_socketcall+0x143/0x1a4
 > kernel:  [<ffffffff810467dc>] ? sysenter_dispatch+0x7/0x32
 >=20
 > Signed-off-by: Jacek Luczak <luczak.jacek@gmail.com>
 > Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>
 > CC: Eric Dumazet <eric.dumazet@gmail.com>
 >=20
 > ---
 >  net/sctp/bind_addr.c |   10 ++++------
 >  1 files changed, 4 insertions(+), 6 deletions(-)
 >=20
 > diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
 > index faf71d1..6150ac5 100644
 > --- a/net/sctp/bind_addr.c
 > +++ b/net/sctp/bind_addr.c
 > @@ -140,14 +140,12 @@ void sctp_bind_addr_init(struct sctp_bind_addr=
 *bp, __u16 port)
 >  /* Dispose of the address list. */
 >  static void sctp_bind_addr_clean(struct sctp_bind_addr *bp)
 >  {
 > -	struct sctp_sockaddr_entry *addr;
 > -	struct list_head *pos, *temp;
 > +	struct sctp_sockaddr_entry *addr, *temp;
 > =20
 >  	/* Empty the bind address list. */
 > -	list_for_each_safe(pos, temp, &bp->address_list) {
 > -		addr =3D list_entry(pos, struct sctp_sockaddr_entry, list);
 > -		list_del(pos);
 > -		kfree(addr);
 > +	list_for_each_entry_safe(addr, temp, &bp->address_list, list) {
 > +		list_del_rcu(&addr->list);
 > +		call_rcu(&addr->rcu, sctp_local_addr_free);
 >  		SCTP_DBG_OBJCNT_DEC(addr);

Just saw this land in Linus tree, and it broke the build for me..

net/sctp/bind_addr.c: In function =E2=80=98sctp_bind_addr_clean=E2=80=99=
:
net/sctp/bind_addr.c:148:24: error: =E2=80=98sctp_local_addr_free=E2=80=
=99 undeclared (first use in this function)
net/sctp/bind_addr.c:148:24: note: each undeclared identifier is report=
ed only once for each function it appears in
make[2]: *** [net/sctp/bind_addr.o] Error 1

	Dave

=20
