From: Leon Romanovsky <leon@leon.nu>
Subject: Re: [PATCH] RDS: sync congestion map updating
Date: Sat, 2 Apr 2016 04:14:59 +0300
Message-ID: <20160402011459.GC8565@leon.nu>
References: <1459328902-31968-1-git-send-email-wen.gang.wang@oracle.com>
 <20160330161952.GA2670@leon.nu>
 <56FC09D6.7090602@oracle.com>
 <56FC82B7.3070504@oracle.com>
 <56FC927E.9090404@oracle.com>
 <56FED04C.2060806@oracle.com>
Reply-To: leon@leon.nu
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-rdma@vger.kernel.org,
	Wengang Wang <wen.gang.wang@oracle.com>, netdev@vger.kernel.org
To: santosh shilimkar <santosh.shilimkar@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34368 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753633AbcDBBPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 21:15:16 -0400
Received: by mail-pf0-f169.google.com with SMTP id x3so102180461pfb.1
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 18:15:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <56FED04C.2060806@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 01, 2016 at 12:47:24PM -0700, santosh shilimkar wrote:
> (cc-ing netdev)
> On 3/30/2016 7:59 PM, Wengang Wang wrote:
> >
> >
> >=E5=9C=A8 2016=E5=B9=B403=E6=9C=8831=E6=97=A5 09:51, Wengang Wang =E5=
=86=99=E9=81=93:
> >>
> >>
> >>=E5=9C=A8 2016=E5=B9=B403=E6=9C=8831=E6=97=A5 01:16, santosh shilim=
kar =E5=86=99=E9=81=93:
> >>>Hi Wengang,
> >>>
> >>>On 3/30/2016 9:19 AM, Leon Romanovsky wrote:
> >>>>On Wed, Mar 30, 2016 at 05:08:22PM +0800, Wengang Wang wrote:
> >>>>>Problem is found that some among a lot of parallel RDS
> >>>>>communications hang.
> >>>>>In my test ten or so among 33 communications hang. The send
> >>>>>requests got
> >>>>>-ENOBUF error meaning the peer socket (port) is congested. But
> >>>>>meanwhile,
> >>>>>peer socket (port) is not congested.
> >>>>>
> >>>>>The congestion map updating can happen in two paths: one is in
> >>>>>rds_recvmsg path
> >>>>>and the other is when it receives packets from the hardware. The=
re
> >>>>>is no
> >>>>>synchronization when updating the congestion map. So a bit
> >>>>>operation (clearing)
> >>>>>in the rds_recvmsg path can be skipped by another bit operation
> >>>>>(setting) in
> >>>>>hardware packet receving path.
> >>>>>
> >
> >To be more detailed.  Here, the two paths (user calls recvmsg and
> >hardware receives data) are for different rds socks. thus the
> >rds_sock->rs_recv_lock is not helpful to sync the updating on conges=
tion
> >map.
> >
> For archive purpose, let me try to conclude the thread. I synced
> with Wengang offlist and came up with below fix. I was under
> impression that __set_bit_le() was atmoic version. After fixing
> it like patch(end of the email), the bug gets addressed.
>=20
> I will probably send this as fix for stable as well.
>=20
>=20
> From 5614b61f6fdcd6ae0c04e50b97efd13201762294 Mon Sep 17 00:00:00 200=
1
> From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> Date: Wed, 30 Mar 2016 23:26:47 -0700
> Subject: [PATCH] RDS: Fix the atomicity for congestion map update
>=20
> Two different threads with different rds sockets may be in
> rds_recv_rcvbuf_delta() via receive path. If their ports
> both map to the same word in the congestion map, then
> using non-atomic ops to update it could cause the map to
> be incorrect. Lets use atomics to avoid such an issue.
>=20
> Full credit to Wengang <wen.gang.wang@oracle.com> for
> finding the issue, analysing it and also pointing out
> to offending code with spin lock based fix.

I'm glad that you solved the issue without spinlocks.
Out of curiosity, I see that this patch is needed to be sent
to Dave and applied by him. Is it right?

=E2=9E=9C  linus-tree git:(master) ./scripts/get_maintainer.pl -f net/r=
ds/cong.c
Santosh Shilimkar <santosh.shilimkar@oracle.com> (supporter:RDS -
RELIABLE DATAGRAM SOCKETS)
"David S. Miller" <davem@davemloft.net> (maintainer:NETWORKING
[GENERAL])
netdev@vger.kernel.org (open list:RDS - RELIABLE DATAGRAM SOCKETS)
linux-rdma@vger.kernel.org (open list:RDS - RELIABLE DATAGRAM SOCKETS)
rds-devel@oss.oracle.com (moderated list:RDS - RELIABLE DATAGRAM
SOCKETS)
linux-kernel@vger.kernel.org (open list)

>=20
> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>

Reviewed-by: Leon Romanovsky <leon@leon.nu>
