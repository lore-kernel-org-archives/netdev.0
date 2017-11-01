From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] tcp_nv: fix division by zero in tcpnv_acked()
Date: Wed, 1 Nov 2017 15:13:51 +0100
Message-ID: <20171101151351.42e699cf@shemminger-XPS-13-9360>
References: <150954313588.153848.10192893966808917578.stgit@buzz>
        <5FF5EDEE-FF34-43E0-9DFA-6CBDB206360D@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Lawrence Brakmo <brakmo@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5FF5EDEE-FF34-43E0-9DFA-6CBDB206360D@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 1 Nov 2017 13:47:17 +0000
Lawrence Brakmo <brakmo@fb.com> wrote:

> Thank you for finding and fixing this.
> 
> On 11/1/17, 6:32 AM, "Konstantin Khlebnikov" <khlebnikov@yandex-team.ru> wrote:
> 
>     Average RTT could become zero. This happened in real life at least twice.
>     This patch treats zero as 1us.
>     
>     Signed-off-by: Konstantin Khlebnikov khlebnikov@yandex-team.ru
> Acked-by: Lawrence Brakmo <Brakmo@fb.com>
>     ---
>      net/ipv4/tcp_nv.c |    2 +-
>      1 file changed, 1 insertion(+), 1 deletion(-)
>     
>     diff --git a/net/ipv4/tcp_nv.c b/net/ipv4/tcp_nv.c
>     index 1ff73982e28c..125fc1450b01 100644
>     --- a/net/ipv4/tcp_nv.c
>     +++ b/net/ipv4/tcp_nv.c
>     @@ -252,7 +252,7 @@ static void tcpnv_acked(struct sock *sk, const struct ack_sample *sample)
>      
>      	/* rate in 100's bits per second */
>      	rate64 = ((u64)sample->in_flight) * 8000000;
>     -	rate = (u32)div64_u64(rate64, (u64)(avg_rtt * 100));
>     +	rate = (u32)div64_u64(rate64, (u64)(avg_rtt ?: 1) * 100);

Why is this code using expensive 64 bit by 64 bit divide when avg_rtt should never be bigger
than 32 bits?
