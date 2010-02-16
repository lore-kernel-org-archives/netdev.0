From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH][v4] tcp: fix ICMP-RTO war
Date: Tue, 16 Feb 2010 14:45:25 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1002151535030.7063@wel-95.cs.helsinki.fi>
References: <4B7303C2.5000703@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43706 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755786Ab0BPMp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 07:45:27 -0500
In-Reply-To: <4B7303C2.5000703@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First of all I want to let you know that I've no objection to this fix 
itself (DaveM applied it already), it certainly does it's jobs in 
preventing invalid < RTO_MIN state. However, I wonder if we could do 
further improvements in this area...

On Wed, 10 Feb 2010, Damian Lukowski wrote:

> Make sure, that TCP has a nonzero RTT estimation after three-way
> handshake. Currently, a listening TCP has a value of 0 for srtt,
> rttvar and rto right after the three-way handshake is completed
> with TCP timestamps disabled.
> This will lead to corrupt RTO recalculation and retransmission
> flood when RTO is recalculated on backoff reversion as introduced
> in "Revert RTO on ICMP destination unreachable"
> (f1ecd5d9e7366609d640ff4040304ea197fbc618).
> This behaviour can be provoked by connecting to a server which
> "responds first" (like SMTP) and rejecting every packet after
> the handshake with dest-unreachable, which will lead to softirq
> load on the server (up to 30% per socket in some tests).
> 
> Thanks to Ilpo Jarvinen for providing debug patches and to
> Denys Fedoryshchenko for reporting and testing.
> 
> Changes since v3: Removed bad characters in patchfile.
> 
> Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
> ---
>  net/ipv4/tcp_input.c |    8 +++-----
>  1 files changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 28e0296..da7173b 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -5783,12 +5783,10 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
>  
>  				/* tcp_ack considers this ACK as duplicate
>  				 * and does not calculate rtt.
> -				 * Fix it at least with timestamps.
> +				 * Force it here.
>  				 */
> -				if (tp->rx_opt.saw_tstamp &&
> -				    tp->rx_opt.rcv_tsecr && !tp->srtt)
> -					tcp_ack_saw_tstamp(sk, 0);
> -
> +				tcp_ack_update_rtt(sk, 0, 0);
> +

...Here a zero seq_rtt is given to RTT estimator (it will be effective 
only in the case w/o timestamps, TS case recalculates it from the stored 
timestamps). Maybe we could use some field (timestamp related one comes to 
my mind) in request sock to get a real RTT estimate for non-timestamp case 
too. ...It seems possible to me, though tricky because the request_sock is 
no longer that easily available here so some parameter passing would be 
needed.


-- 
 i.
