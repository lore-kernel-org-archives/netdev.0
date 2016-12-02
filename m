From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] tcp: warn on bogus MSS and try to amend it
Date: Fri, 02 Dec 2016 06:45:24 -0800
Message-ID: <1480689924.18162.356.camel@edumazet-glaptop3.roam.corp.google.com>
References: <ef61092947105261f8321a67f726a7fdf9b3c14e.1480675556.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jon Maxwell <jmaxwell37@gmail.com>,
        Alex Sidorenko <alexandre.sidorenko@hpe.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, tlfalcon@linux.vnet.ibm.com,
        Brian King <brking@linux.vnet.ibm.com>, davem@davemloft.net
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35803 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750888AbcLBOp1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 09:45:27 -0500
Received: by mail-pg0-f67.google.com with SMTP id p66so8116463pga.2
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 06:45:26 -0800 (PST)
In-Reply-To: <ef61092947105261f8321a67f726a7fdf9b3c14e.1480675556.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-12-02 at 08:55 -0200, Marcelo Ricardo Leitner wrote:
> There have been some reports lately about TCP connection stalls caused
> by NIC drivers that aren't setting gso_size on aggregated packets on rx
> path. This causes TCP to assume that the MSS is actually the size of the
> aggregated packet, which is invalid.
> 
> Although the proper fix is to be done at each driver, it's often hard
> and cumbersome for one to debug, come to such root cause and report/fix
> it.
> 
> This patch amends this situation in two ways. First, it adds a warning
> on when this situation occurs, so it gives a hint to those trying to
> debug this. It also limit the maximum probed MSS to the adverised MSS,
> as it should never be any higher than that.
> 
> The result is that the connection may not have the best performance ever
> but it shouldn't stall, and the admin will have a hint on what to look
> for.
> 
> Tested with virtio by forcing gso_size to 0.
> 
> Cc: Jonathan Maxwell <jmaxwell37@gmail.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
> v2: Updated msg as suggested by David.
> 
>  net/ipv4/tcp_input.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index a27b9c0e27c08b4e4aeaff3d0bfdf3ae561ba4d8..fd619eb93749b6de56a41669248b337c051d9fe2 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -144,7 +144,10 @@ static void tcp_measure_rcv_mss(struct sock *sk, const struct sk_buff *skb)
>  	 */
>  	len = skb_shinfo(skb)->gso_size ? : skb->len;
>  	if (len >= icsk->icsk_ack.rcv_mss) {
> -		icsk->icsk_ack.rcv_mss = len;
> +		icsk->icsk_ack.rcv_mss = min_t(unsigned int, len,
> +					       tcp_sk(sk)->advmss);
> +		if (icsk->icsk_ack.rcv_mss != len)
> +			pr_warn_once("Driver has suspect GRO implementation, TCP performance may be compromised.\n");
>  	} else {
>  		/* Otherwise, we make more careful check taking into account,
>  		 * that SACKs block is variable.


skb->dev is indeed NULL, but it might be worth getting back the device
using skb->skb_iif maybe ?
