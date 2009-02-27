From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: [PATCH] net: more timeouts that reach -1
Date: Fri, 27 Feb 2009 23:51:05 +0800
Message-ID: <20090227154440.M53654@cooldavid.org>
References: <49A5286D.80304@gmail.com> <20090227114015.M80857@cooldavid.org> <25e057c00902270737x529fb5b8m2fdbb044fa75ab0d@mail.gmail.com>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=big5
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: roel kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([220.133.139.86]:55157 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755720AbZB0Pwe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 10:52:34 -0500
In-Reply-To: <25e057c00902270737x529fb5b8m2fdbb044fa75ab0d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Feb 2009 16:37:30 +0100, roel kluin wrote
> On Fri, Feb 27, 2009 at 12:43 PM, Guo-Fu Tseng <cooldavid@cooldavid.org> wrote:
> > There should be no difference after this modification.
> > The return value of this function is: "limit > 0 ? limit : 0;"
> 
> There is:
> In the last iteration limit is 1 during the test before it is decremented to 0.
> 
> rxdesc = rxring->desc;
> rxdesc += i;
> 
> If then we break out of the loop by the 'goto out;', we continue with:
> 
> out:
>         atomic_set(&rxring->next_to_clean, i);
> 
> out_inc:
>         atomic_inc(&jme->rx_cleaning);
> 
> but since limit is already decremented, 0 is returned.
> 
> >
> > Guo-Fu Tseng
> >
> 
> Roel
I see.
But the correct patch should be following one, right?

===================================================================
--- jme.c	(revision 580)
+++ jme.c	(working copy)
@@ -958,13 +958,14 @@
 		goto out_inc;
 
 	i = atomic_read(&rxring->next_to_clean);
-	while (limit-- > 0) {
+	while (limit > 0) {
 		rxdesc = rxring->desc;
 		rxdesc += i;
 
 		if ((rxdesc->descwb.flags & RXWBFLAG_OWN) ||
 		!(rxdesc->descwb.desccnt & RXWBDCNT_WBCPL))
 			goto out;
+		--limit;
 
 		desccnt = rxdesc->descwb.desccnt & RXWBDCNT_DCNT;
 



Guo-Fu Tseng

