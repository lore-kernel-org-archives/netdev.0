From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at net/ipv4/tcp.c:1301 tcp_cleanup_rbuf+0x4f/0x110()
Date: Wed, 23 May 2012 18:36:58 +0200
Message-ID: <1337791018.3361.3024.camel@edumazet-glaptop>
References: <CAJyhjX22Vna=TwuhD-FqyoXEd9D8wq_VdHbAAWwmqO1hZ34FRA@mail.gmail.com>
	 <CAJyhjX1VKQpAbqkxnWFNrRSVBuSRYaNQSUXYWqYfoE0GnmVokQ@mail.gmail.com>
	 <1337697203.3361.190.camel@edumazet-glaptop>
	 <CAJyhjX2f_XFgVZpS1hLy5CWKY7eYA5MzQSHsfRgc40-2Rxztkw@mail.gmail.com>
	 <1337785681.3361.2923.camel@edumazet-glaptop>
	 <CAJyhjX02wjsVE2pM26a+7xTrAJwvLZo0UL-W6h8zMKEiC5qTug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sergio Correia <lists@uece.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:37710 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643Ab2EWQhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 12:37:03 -0400
Received: by eaak11 with SMTP id k11so2135225eaa.19
        for <netdev@vger.kernel.org>; Wed, 23 May 2012 09:37:02 -0700 (PDT)
In-Reply-To: <CAJyhjX02wjsVE2pM26a+7xTrAJwvLZo0UL-W6h8zMKEiC5qTug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-23 at 12:56 -0300, Sergio Correia wrote:
> On Wed, May 23, 2012 at 12:08 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Tue, 2012-05-22 at 11:47 -0300, Sergio Correia wrote:
> >> Hi Eric,
> > ...
> >> Yes, it's an Atheros AR9285 adapter.
> >> This morning I did a make mrproper before rebuilding the kernel
> >> (should I always do that?), but the warning has just appeared again.
> >
> > OK, I am taking a look at this problem, thanks.
> >
> 
> Thanks. Let me know if you need additional info. As of now, my dmesg
> basically shows only those warnings.

I believe I found the bug and am testing a fix right now.

By the way, we might have the same problem in tcp collapses.

TCP coalescing (introduced in linux-3.5) triggers the problem faster.

Please test following patch :

 net/ipv4/tcp_input.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cfa2aa1..b224eb8 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4555,6 +4555,11 @@ static bool tcp_try_coalesce(struct sock *sk,
 
 	if (tcp_hdr(from)->fin)
 		return false;
+
+	/* Its possible this segment overlaps with prior segment in queue */
+	if (TCP_SKB_CB(from)->seq != TCP_SKB_CB(to)->end_seq)
+		return false;
+
 	if (!skb_try_coalesce(to, from, fragstolen, &delta))
 		return false;
 
