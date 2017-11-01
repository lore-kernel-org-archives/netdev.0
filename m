From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp_nv: fix division by zero in tcpnv_acked()
Date: Wed, 01 Nov 2017 07:17:08 -0700
Message-ID: <1509545828.3828.44.camel@edumazet-glaptop3.roam.corp.google.com>
References: <150954313588.153848.10192893966808917578.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Lawrence Brakmo <brakmo@fb.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        linux-kernel@vger.kernel.org
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <150954313588.153848.10192893966808917578.stgit@buzz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-11-01 at 16:32 +0300, Konstantin Khlebnikov wrote:
> Average RTT could become zero. This happened in real life at least twice.
> This patch treats zero as 1us.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  net/ipv4/tcp_nv.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/tcp_nv.c b/net/ipv4/tcp_nv.c
> index 1ff73982e28c..125fc1450b01 100644
> --- a/net/ipv4/tcp_nv.c
> +++ b/net/ipv4/tcp_nv.c
> @@ -252,7 +252,7 @@ static void tcpnv_acked(struct sock *sk, const struct ack_sample *sample)
>  
>  	/* rate in 100's bits per second */
>  	rate64 = ((u64)sample->in_flight) * 8000000;
> -	rate = (u32)div64_u64(rate64, (u64)(avg_rtt * 100));
> +	rate = (u32)div64_u64(rate64, (u64)(avg_rtt ?: 1) * 100);
>  
>  	/* Remember the maximum rate seen during this RTT
>  	 * Note: It may be more than one RTT. This function should be
> 

BTW, this div64_u64() could be replaced by a u32 divide (aka do_div()),
slightly less expensive.


rate64 = ((u64)sample->in_flight) * 80000;
do_div(rate64, avg_rtt ?: 1);
rate = (u32)rate64;
