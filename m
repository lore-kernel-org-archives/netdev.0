From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: tcp: Fix a PTO timing granularity issue
Date: Wed, 27 May 2015 11:36:42 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB40A1A@AcuExch.aculab.com>
References: <1432663992.4060.286.camel@edumazet-glaptop2.roam.corp.google.com>
 <1432671437-19140-1-git-send-email-ido@wizery.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Ido Yariv <idox.yariv@intel.com>
To: 'Ido Yariv' <ido@wizery.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Nandita Dukkipati <nanditad@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432671437-19140-1-git-send-email-ido@wizery.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Of Ido Yariv
> Sent: 26 May 2015 21:17
> The Tail Loss Probe RFC specifies that the PTO value should be set to
> max(2 * SRTT, 10ms), where SRTT is the smoothed round-trip time.
> 
> The PTO value is converted to jiffies, so the timer may expire
> prematurely.
> 
> This is especially problematic on systems in which HZ <= 100, so work
> around this by setting the timeout to at least 2 jiffies on such
> systems.
> 
> The 10ms figure was originally selected based on tests performed with
> the current implementation and HZ = 1000. Thus, leave the behavior on
> systems with HZ > 100 unchanged.
> 
> Signed-off-by: Ido Yariv <idox.yariv@intel.com>
> ---
>  net/ipv4/tcp_output.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 534e5fd..5321df8 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2208,6 +2208,9 @@ bool tcp_schedule_loss_probe(struct sock *sk)
>  		timeout = max_t(u32, timeout,
>  				(rtt + (rtt >> 1) + TCP_DELACK_MAX));
>  	timeout = max_t(u32, timeout, msecs_to_jiffies(10));
> +#if HZ <= 100
> +	timeout = max_t(u32, timeout, 2);
> +#endif

Why not:
	timeout = max_t(u32, timeout, max_t(u32, 2, msecs_to_jiffies(10)));
I think the RH max_t() is a compile time constant.

You need 2 jiffies to guarantee a non-zero timeout.
Even if HZ=199 with a 'rounding down' msecs_to_jiffies() you get 1 jiffy
and a possible immediate timeout.

There are probably other places where msecs_to_jiffies() better not return 1.

	David
