From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: The AI parameter of tcp_highspeed.c (in 2.6.18)
Date: Fri, 2 Jun 2006 12:05:07 -0700
Message-ID: <20060602120507.7e1206d8@dxpl.pdx.osdl.net>
References: <7335583a0605292112l1f5a6ec3x4b1c1e4ae45688f5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:37504 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751433AbWFBTFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2006 15:05:14 -0400
To: "Xiaoliang (David) Wei" <davidwei79@gmail.com>,
	John Heffner <jheffner@psc.edu>
In-Reply-To: <7335583a0605292112l1f5a6ec3x4b1c1e4ae45688f5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Went backed and looked at the RFC. The problem was just a simple
translation of table to C array (0 based). Added this to the TCP testing repository.

Subject: [PATCH] Problem observed by Xiaoliang (David) Wei:

  When snd_cwnd is smaller than 38 and the connection is in
  congestion avoidance phase (snd_cwnd > snd_ssthresh), the snd_cwnd
  seems to stop growing.

The additive increase was confused because C array's are 0 based.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---

 net/ipv4/tcp_highspeed.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

121685b7b61c8faeb87e6c6f0c346b0fe1c46fd2
diff --git a/net/ipv4/tcp_highspeed.c b/net/ipv4/tcp_highspeed.c
index b72fa55..ba7c63c 100644
--- a/net/ipv4/tcp_highspeed.c
+++ b/net/ipv4/tcp_highspeed.c
@@ -135,7 +135,8 @@ static void hstcp_cong_avoid(struct sock
 
 		/* Do additive increase */
 		if (tp->snd_cwnd < tp->snd_cwnd_clamp) {
-			tp->snd_cwnd_cnt += ca->ai;
+			/* cwnd = cwnd + a(w) / cwnd */
+			tp->snd_cwnd_cnt += ca->ai + 1;
 			if (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
 				tp->snd_cwnd_cnt -= tp->snd_cwnd;
 				tp->snd_cwnd++;
-- 
1.3.3

