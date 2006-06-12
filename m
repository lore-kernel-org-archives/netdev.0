From: "Xiaoliang (David) Wei" <davidwei79@gmail.com>
Subject: Re: The AI parameter of tcp_highspeed.c (in 2.6.18)
Date: Mon, 12 Jun 2006 10:10:17 -0700
Message-ID: <7335583a0606121010g5efde29frd35f88defef82c72@mail.gmail.com>
References: <7335583a0605292112l1f5a6ec3x4b1c1e4ae45688f5@mail.gmail.com>
	 <20060602120507.7e1206d8@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John Heffner" <jheffner@psc.edu>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.227]:39964 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1751415AbWFLRKT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 13:10:19 -0400
Received: by wr-out-0506.google.com with SMTP id i11so1458060wra
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2006 10:10:18 -0700 (PDT)
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20060602120507.7e1206d8@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks, Stephen. But I think there is still a problem with the AIMD
parameter update in HighSpeed TCP code.

Line 125~138 of the code (net/ipv4/tcp_highspeed.c):

	/* Update AIMD parameters */
	if (tp->snd_cwnd > hstcp_aimd_vals[ca->ai].cwnd) {
		while (tp->snd_cwnd > hstcp_aimd_vals[ca->ai].cwnd &&
		       ca->ai < HSTCP_AIMD_MAX - 1)
			ca->ai++;
	} else if (tp->snd_cwnd < hstcp_aimd_vals[ca->ai].cwnd) {
		while (tp->snd_cwnd > hstcp_aimd_vals[ca->ai].cwnd &&
		       ca->ai > 0)
			ca->ai--;

In fact, the second part (decreasing ca->ai) never decreases since the
while loop's inequality is in the reverse direction. This leads to
unfairness with multiple flows (once a flow happens to enjoy a higher
ca->ai, it keeps enjoying that even its cwnd decreases)

Here is a tentative fix (I also added a comment, trying to keep the
change clear):

--- /home/weixl/linux-2.6.16.18/net/ipv4/tcp_highspeed.c	2006-05-22
11:04:35.000000000 -0700
+++ /home/weixl/linux-2.6.16.18/net/ipv4/tcp_highspeed.c.new	2006-06-12
09:56:40.000000000 -0700
@@ -123,13 +123,13 @@
 		tcp_slow_start(tp);
 	else {
 		/* Update AIMD parameters */
+		/* We want to guarantee that hstcp_aimd_vals[ca->ai-1].cwnd  <
snd_cwnd <= hstcp_aimd_vals[ca->ai].cwnd */
 		if (tp->snd_cwnd > hstcp_aimd_vals[ca->ai].cwnd) {
 			while (tp->snd_cwnd > hstcp_aimd_vals[ca->ai].cwnd &&
 			       ca->ai < HSTCP_AIMD_MAX - 1)
 				ca->ai++;
-		} else if (tp->snd_cwnd < hstcp_aimd_vals[ca->ai].cwnd) {
-			while (tp->snd_cwnd > hstcp_aimd_vals[ca->ai].cwnd &&
-			       ca->ai > 0)
+		} else if (ca->ai && tp->snd_cwnd <= hstcp_aimd_vals[ca->ai-1].cwnd) {
+			while (ca->ai && tp->snd_cwnd <= hstcp_aimd_vals[ca->ai-1].cwnd)
 				ca->ai--;
 		}

Thanks.

-David

On 6/2/06, Stephen Hemminger <shemminger@osdl.org> wrote:
> Went backed and looked at the RFC. The problem was just a simple
> translation of table to C array (0 based). Added this to the TCP testing repository.
>
> Subject: [PATCH] Problem observed by Xiaoliang (David) Wei:
>
>   When snd_cwnd is smaller than 38 and the connection is in
>   congestion avoidance phase (snd_cwnd > snd_ssthresh), the snd_cwnd
>   seems to stop growing.
>
> The additive increase was confused because C array's are 0 based.
>
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
>
> ---
>
>  net/ipv4/tcp_highspeed.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>
> 121685b7b61c8faeb87e6c6f0c346b0fe1c46fd2
> diff --git a/net/ipv4/tcp_highspeed.c b/net/ipv4/tcp_highspeed.c
> index b72fa55..ba7c63c 100644
> --- a/net/ipv4/tcp_highspeed.c
> +++ b/net/ipv4/tcp_highspeed.c
> @@ -135,7 +135,8 @@ static void hstcp_cong_avoid(struct sock
>
>                 /* Do additive increase */
>                 if (tp->snd_cwnd < tp->snd_cwnd_clamp) {
> -                       tp->snd_cwnd_cnt += ca->ai;
> +                       /* cwnd = cwnd + a(w) / cwnd */
> +                       tp->snd_cwnd_cnt += ca->ai + 1;
>                         if (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
>                                 tp->snd_cwnd_cnt -= tp->snd_cwnd;
>                                 tp->snd_cwnd++;
> --
> 1.3.3
>
>


-- 
Xiaoliang (David) Wei      Graduate Student, CS@Caltech
http://davidwei.org
***********************************************
