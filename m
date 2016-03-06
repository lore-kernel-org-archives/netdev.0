From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] sctp: use gfp insteaad of GFP_NOWAIT in
 idr_alloc_cyclic when sctp_assoc_set_id
Date: Sun, 06 Mar 2016 15:21:16 -0800
Message-ID: <1457306476.2663.28.camel@edumazet-ThinkPad-T530>
References: <ef48b2b8895b4d0fab07b4e72b464d5a11d3bd79.1457193572.git.lucien.xin@gmail.com>
	 <1457196133.2663.3.camel@edumazet-ThinkPad-T530>
	 <CADvbK_faS8mNtUNiVT6d-kLRnngQ=4+z6meuO0XM+RJG50iaNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem <davem@davemloft.net>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35524 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785AbcCFXVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 18:21:19 -0500
In-Reply-To: <CADvbK_faS8mNtUNiVT6d-kLRnngQ=4+z6meuO0XM+RJG50iaNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On dim., 2016-03-06 at 13:52 +0800, Xin Long wrote:
> On Sun, Mar 6, 2016 at 12:42 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On sam., 2016-03-05 at 23:59 +0800, Xin Long wrote:
> >
> > Are you sure idr_alloc(... GFP_KERNEL) makes sense inside spin_lock_bh()
> > section ?
> >
> > idr_alloc() has :
> >
> > might_sleep_if(gfpflags_allow_blocking(gfp_mask));
> >
> > A debug kernel (CONFIG_DEBUG_ATOMIC_SLEEP=y) should probably complain at
> > this point ?
> >
> OK, I got you, does it make sense to you if I just change GFP_NOWAIT
> to GFP_ATOMIC
> when sctp_assoc_set_id call idr_alloc_cyclic()?  which also can avoid
> this call trace in my
> test.
> 
> >
> >

What is the problem of being not able to allocate memory at this point ?

If really it bothers you (although we have thousands of other places it
can happen), maybe add __GFP_NOWARN

But whatever flag we use here, idr_alloc() _can_ fail.

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 2bf8ec92dde4..2ae3874e3696 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1606,7 +1606,8 @@ int sctp_assoc_set_id(struct sctp_association *asoc, gfp_t gfp)
 		idr_preload(gfp);
 	spin_lock_bh(&sctp_assocs_id_lock);
 	/* 0 is not a valid assoc_id, must be >= 1 */
-	ret = idr_alloc_cyclic(&sctp_assocs_id, asoc, 1, 0, GFP_NOWAIT);
+	ret = idr_alloc_cyclic(&sctp_assocs_id, asoc, 1, 0,
+			       (gfp & ~__GFP_DIRECT_RECLAIM) | __GFP_NOWARN);
 	spin_unlock_bh(&sctp_assocs_id_lock);
 	if (preload)
 		idr_preload_end();
