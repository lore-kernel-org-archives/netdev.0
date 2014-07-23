From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] tcp: Fix integer-overflows in TCP vegas
Date: Wed, 23 Jul 2014 08:38:30 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1727BEDC@AcuExch.aculab.com>
References: <1406065017-22102-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Doug Leith <doug.leith@nuim.ie>
To: 'Christoph Paasch' <christoph.paasch@uclouvain.be>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:59044 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757115AbaGWIjz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 04:39:55 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 31238-01 for <netdev@vger.kernel.org>;
 Wed, 23 Jul 2014 09:39:45 +0100 (BST)
In-Reply-To: <1406065017-22102-1-git-send-email-christoph.paasch@uclouvain.be>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Of Christoph Paasch
> In vegas we do a multiplication of the cwnd and the rtt. This
> may overflow and thus their result is stored in a u64. However, we first
> need to cast the cwnd so that actually 64-bit arithmetic is done.
> 
> Cc: Doug Leith <doug.leith@nuim.ie>
> Fixes: 8d3a564da34e (tcp: tcp_vegas cong avoid fix)
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
>  net/ipv4/tcp_vegas.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
> index 9a5e05f27f4f..6a4bdea2a0fb 100644
> --- a/net/ipv4/tcp_vegas.c
> +++ b/net/ipv4/tcp_vegas.c
> @@ -218,7 +218,7 @@ static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack, u32 acked)
>  			 * This is:
>  			 *     (actual rate in segments) * baseRTT
>  			 */
> -			target_cwnd = tp->snd_cwnd * vegas->baseRTT / rtt;
> +			target_cwnd = (u64)tp->snd_cwnd * vegas->baseRTT / rtt;

Won't that add a reference to the 64bit divide function?
If snd_cwnd is small then maybe:
	target_cwnd = (256u * vegas->baseRTT) / rtt * tp->snd_cwnd / 256u;
If large I think low bits are always zero so:
	target_cwnd = (256u * vegas->baseRTT) / rtt * (tp->snd_cwnd / 256u);
Possibly with a different power of 2...

	David
