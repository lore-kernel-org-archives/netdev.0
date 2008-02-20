From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Wed, 20 Feb 2008 19:38:38 +0100
Message-ID: <20080220183837.GA2881@ami.dom.local>
References: <47B0C9F7.5040200@katalix.com> <20080211224924.GA2863@ami.dom.local> <47B0DD1E.5000608@katalix.com> <20080211.213048.192442721.davem@davemloft.net> <47B17BCD.2070903@katalix.com> <20080214130016.GA2583@ff.dom.local> <47BA0214.40703@katalix.com> <20080219230640.GA2755@ami.dom.local> <47BC4F2C.4000802@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:1816 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756742AbYBTSfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 13:35:17 -0500
Received: by ug-out-1314.google.com with SMTP id z38so809437ugc.16
        for <netdev@vger.kernel.org>; Wed, 20 Feb 2008 10:35:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47BC4F2C.4000802@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 20, 2008 at 04:02:52PM +0000, James Chapman wrote:
...
> I tried your ppp_generic patch with only the hlist_lock bh patch in  
> pppol2tp and it seems to fix the ppp create/delete issue. However, when  
> I added much more traffic into the test (flood pings over ppp interfaces  
> while repeatedly creating/deleting the L2TP (PPP) sessions) I get a soft  
> lockup detected in pppol2tp_xmit() after anything between 1 minute and  
> an hour. :( I'm investigating that now.
>
> Thanks for your help!

Not at all!

>
>> (testing patch #1)

But I hope you tested with the fixed (take 2) version of this patch...

Since it's quite experimental (testing) this patch could be wrong
as it is, but I hope it should show the proper way to solve this
problem. Probably you did some of these, but here are a few of my
suggestions for testing this:

1) try my patch with your full bh locking changing patch;
2) add while loops to these trylocks on failure, with e.g.  __delay(1);
   this should work like full locks again, but there should be no (this
   kind of) lockdep reports;
3) I send here another testing patch with this second way to do this:
   on the write side, but it's even more "experimental" and only a
   proof of concept (should be applied on vanilla ppp_generic).

Regards,
Jarek P.

(testing patch #2)

---

 drivers/net/ppp_generic.c |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 4dc5b4b..70bd255 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -2606,11 +2606,16 @@ ppp_connect_channel(struct channel *pch, int unit)
 	ppp = ppp_find_unit(unit);
 	if (!ppp)
 		goto out;
-	write_lock_bh(&pch->upl);
+
 	ret = -EINVAL;
-	if (pch->ppp)
-		goto outl;
+	read_lock_bh(&pch->upl);
+	if (pch->ppp) {
+		read_unlock_bh(&pch->upl);
+		goto out;
+	}
+	read_unlock_bh(&pch->upl);
 
+	atomic_inc(&ppp->file.refcnt);
 	ppp_lock(ppp);
 	if (pch->file.hdrlen > ppp->file.hdrlen)
 		ppp->file.hdrlen = pch->file.hdrlen;
@@ -2619,13 +2624,14 @@ ppp_connect_channel(struct channel *pch, int unit)
 		ppp->dev->hard_header_len = hdrlen;
 	list_add_tail(&pch->clist, &ppp->channels);
 	++ppp->n_channels;
-	pch->ppp = ppp;
-	atomic_inc(&ppp->file.refcnt);
 	ppp_unlock(ppp);
-	ret = 0;
 
- outl:
+	/* avoid lock dependency with ppp_locks */
+	write_lock_bh(&pch->upl);
+	BUG_ON(pch->ppp);
+	pch->ppp = ppp;
 	write_unlock_bh(&pch->upl);
+	ret = 0;
  out:
 	mutex_unlock(&all_ppp_mutex);
 	return ret;
