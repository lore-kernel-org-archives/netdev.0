From: jamal <hadi@cyberus.ca>
Subject: Re: 2.6.23-rc5: possible irq lock inversion dependency detected
Date: Tue, 11 Sep 2007 08:01:46 -0400
Message-ID: <1189512106.4231.6.camel@localhost>
References: <alpine.DEB.0.999.0709021455510.7103@sheep.housecafe.de>
	 <20070910130024.GA27939@gondor.apana.org.au>
	 <1189469081.14002.3.camel@localhost>
	 <20070911021812.GA1544@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Qkdn9XYEaPjByoZ+fQ1E"
Cc: Christian Kujau <lists@nerdbynature.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:24938 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757526AbXIKMBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 08:01:50 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1420845wxd
        for <netdev@vger.kernel.org>; Tue, 11 Sep 2007 05:01:49 -0700 (PDT)
In-Reply-To: <20070911021812.GA1544@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Qkdn9XYEaPjByoZ+fQ1E
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2007-11-09 at 10:18 +0800, Herbert Xu wrote:

> Jamal, it's the police_lock that we need to make _bh.  The
> ingress_lock is already _bh because of the spin_lock_bh that
> directly precedes it.
> 
> Oh and I think the same thing applies for the other actions
> too.

ga-Dang. Ok, here it is. If you see(?) any more farts let me know.
I am around for another 30 minutes and off for about 18 hours.
 
Christian, i took your config and qos setup but I cant reproduce the
issue - i think i may need some of that wireless setup to recreate. So
if you can test this and validate it works we can push it forward.

cheers,
jamal

--=-Qkdn9XYEaPjByoZ+fQ1E
Content-Disposition: attachment; filename=act_bhl
Content-Type: text/plain; name=act_bhl; charset=us-ascii
Content-Transfer-Encoding: 7bit

[NET_SCHED] protect action config/dump from irqs

>From the sharp laser eyes of Herbert Xu to my slow farting brain...
(with no apologies to C Heston)

On Mon, 2007-10-09 at 21:00 +0800, Herbert Xu wrote:
On Sun, Sep 02, 2007 at 01:11:29PM +0000, Christian Kujau wrote:
> > 
> > after upgrading to 2.6.23-rc5 (and applying davem's fix [0]), lockdep 
> > was quite noisy when I tried to shape my external (wireless) interface:
> > 
> > [ 6400.534545] FahCore_78.exe/3552 just changed the state of lock:
> > [ 6400.534713]  (&dev->ingress_lock){-+..}, at: [<c038d595>] 
> > netif_receive_skb+0x2d5/0x3c0
> > [ 6400.534941] but this lock took another, soft-read-irq-unsafe lock in the 
> > past:
> > [ 6400.535145]  (police_lock){-.--}
> 
> This is a genuine dead-lock.  The police lock can be taken
> for reading with softirqs on.  If a second CPU tries to take
> the police lock for writing, while holding the ingress lock,
> then a softirq on the first CPU can dead-lock when it tries
> to get the ingress lock.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

--- a/net/sched/act_police.c	2007/09/11 10:39:36	1.1
+++ b/net/sched/act_police.c	2007/09/11 10:51:47
@@ -56,7 +56,7 @@
 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
 	struct rtattr *r;
 
-	read_lock(&police_lock);
+	read_lock_bh(&police_lock);
 
 	s_i = cb->args[0];
 
@@ -85,7 +85,7 @@
 		}
 	}
 done:
-	read_unlock(&police_lock);
+	read_unlock_bh(&police_lock);
 	if (n_i)
 		cb->args[0] += n_i;
 	return n_i;
--- a/net/sched/act_api.c	2007/09/11 10:47:51	1.1
+++ b/net/sched/act_api.c	2007/09/11 10:50:47
@@ -68,7 +68,7 @@
 	int err = 0, index = -1,i = 0, s_i = 0, n_i = 0;
 	struct rtattr *r ;
 
-	read_lock(hinfo->lock);
+	read_lock_bh(hinfo->lock);
 
 	s_i = cb->args[0];
 
@@ -96,7 +96,7 @@
 		}
 	}
 done:
-	read_unlock(hinfo->lock);
+	read_unlock_bh(hinfo->lock);
 	if (n_i)
 		cb->args[0] += n_i;
 	return n_i;
@@ -156,13 +156,13 @@
 {
 	struct tcf_common *p;
 
-	read_lock(hinfo->lock);
+	read_lock_bh(hinfo->lock);
 	for (p = hinfo->htab[tcf_hash(index, hinfo->hmask)]; p;
 	     p = p->tcfc_next) {
 		if (p->tcfc_index == index)
 			break;
 	}
-	read_unlock(hinfo->lock);
+	read_unlock_bh(hinfo->lock);
 
 	return p;
 }

--=-Qkdn9XYEaPjByoZ+fQ1E--

