From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [REGRESSION, bisect]cxgb4 port failure with TSO traffic after
 commit 10d3be569243def8("tcp-tso: do not split TSO packets at retransmit
 time")
Date: Mon, 27 Jun 2016 11:21:19 +0200
Message-ID: <1467019279.6850.145.camel@edumazet-glaptop3.roam.corp.google.com>
References: <6DE8042992C3D3488ACEF3F2607097E3C4A81CA5@nice.asicdesigners.com>
	 <CANn89iLpBC5tUqpdSE4jCMKFgUi=mg=2kPZtMaRh-cnBhvauNg@mail.gmail.com>
	 <6DE8042992C3D3488ACEF3F2607097E3C4A82805@nice.asicdesigners.com>
	 <CANn89i+ePpSDYPtQeZa=fdN84=4WKdDb88P-dOVyPyY_DMK02g@mail.gmail.com>
	 <1466785507.6850.105.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160627071750.GA13304@v4.asicdesigners.com>
	 <1467014782.6850.144.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160627085957.GB13319@v4.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hariprasad S <hariprasad@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	Kumar A S <kumaras@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"ycheng@google.com" <ycheng@google.com>
To: Arjun V <arjun@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34338 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbcF0JV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 05:21:27 -0400
Received: by mail-wm0-f65.google.com with SMTP id 187so22885476wmz.1
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 02:21:26 -0700 (PDT)
In-Reply-To: <20160627085957.GB13319@v4.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-06-27 at 14:29 +0530, Arjun V wrote:
> On Monday, June 06/27/16, 2016 at 13:36:22 +0530, Eric Dumazet wrote:
> > On Mon, 2016-06-27 at 12:47 +0530, Arjun V wrote:
> > 
> > > Eric,
> > > 
> > > Thanks for the quick patch. It didn't help much. We still see packets larger than 65536 with the patch.
> > > 
> > > Below is the dump_stack() trace I am seeing for packets larger than 65536 in our xmit routine:
> > 
> > What values do you get for skb->len ?
> >
> These are the skb->len values I am hitting in t4_eth_xmit() for around half hour run of netperf bidi(800 connections total)
> packet with skb->len 69570 detected
> packet with skb->len 66674 detected

Ok please add :

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5c7ed147449c1b7ba029b12e033ad779a631460a..39bd2a2b8f4d931c514fe62a00541efef29157ad 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -845,6 +845,7 @@ static unsigned int tcp_xmit_size_goal(struct sock *sk, u32 mss_now,
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	u32 new_size_goal, size_goal;
+	u32 res;
 
 	if (!large_allowed || !sk_can_gso(sk))
 		return mss_now;
@@ -862,7 +863,11 @@ static unsigned int tcp_xmit_size_goal(struct sock *sk, u32 mss_now,
 		size_goal = tp->gso_segs * mss_now;
 	}
 
-	return max(size_goal, mss_now);
+	res = max(size_goal, mss_now);
+	if (res >= 65536)
+		pr_err_once("tcp_xmit_size_goal() -> %u size_goal %u, mss_now %u gso_max_size %u gso_segs %u\n",
+			    res, size_goal, mss_now, sk->sk_gso_max_size, tp->gso_segs);
+	return res;
 }
 
 static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
