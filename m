From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: tcp: Fix a PTO timing granularity issue
Date: Tue, 26 May 2015 09:23:55 -0700
Message-ID: <1432657435.4060.267.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432650358-11470-1-git-send-email-ido@wizery.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Nandita Dukkipati <nanditad@google.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ido Yariv <idox.yariv@intel.com>
To: Ido Yariv <ido@wizery.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432650358-11470-1-git-send-email-ido@wizery.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-05-26 at 10:25 -0400, Ido Yariv wrote:
> The Tail Loss Probe RFC specifies that the PTO value should be set to
> max(2 * SRTT, 10ms), where SRTT is the smoothed round-trip time.
> 
> The PTO value is converted to jiffies, so the timer might expire
> prematurely. This is especially problematic on systems in which HZ=100.
> 
> To work around this issue, increase the number of jiffies by one,
> ensuring that the timeout won't expire in less than 10ms.
> 
> Signed-off-by: Ido Yariv <idox.yariv@intel.com>
> ---
>  net/ipv4/tcp_output.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 534e5fd..6f57d3d 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2207,7 +2207,7 @@ bool tcp_schedule_loss_probe(struct sock *sk)
>  	if (tp->packets_out == 1)
>  		timeout = max_t(u32, timeout,
>  				(rtt + (rtt >> 1) + TCP_DELACK_MAX));
> -	timeout = max_t(u32, timeout, msecs_to_jiffies(10));
> +	timeout = max_t(u32, timeout, msecs_to_jiffies(10) + 1);
>  
>  	/* If RTO is shorter, just schedule TLP in its place. */
>  	tlp_time_stamp = tcp_time_stamp + timeout;

Have you really hit an issue, or did you send this patch after all these
msecs_to_jiffies() discussions on lkml/netdev ?

Not sure this is the right fix.

TLP was really tested with an effective min delay of 10ms.

Adding 10% for the sake of crazy HZ=100 builds seems a high price.
(All recent TCP changes were tested with HZ=1000 BTW ...)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 534e5fdb04c11152bae36f47a786e8b10b823cd3..5321df89af9b59c6727395c489e6f9b2770dcd5e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2208,6 +2208,9 @@ bool tcp_schedule_loss_probe(struct sock *sk)
 		timeout = max_t(u32, timeout,
 				(rtt + (rtt >> 1) + TCP_DELACK_MAX));
 	timeout = max_t(u32, timeout, msecs_to_jiffies(10));
+#if HZ <= 100
+	timeout = max_t(u32, timeout, 2);
+#endif
 
 	/* If RTO is shorter, just schedule TLP in its place. */
 	tlp_time_stamp = tcp_time_stamp + timeout;
