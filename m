From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCHv2 net-next 1/2] tcp: RTO Restart (RTOR)
Date: Tue, 8 Dec 2015 12:50:18 +0200 (EET)
Message-ID: <alpine.DEB.2.10.1512081246070.19242@melkinpaasi.cs.helsinki.fi>
References: <cover.1449478261.git.per.hurtig@kau.se> <cover.1449561786.git.per.hurtig@kau.se> <8cd2c4817d86e30b09fe398c6bfcb7a89521bdb3.1449561786.git.per.hurtig@kau.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	ncardwell@google.com, nanditad@google.com, tom@herbertland.com,
	ycheng@google.com, viro@zeniv.linux.org.uk, fw@strlen.de,
	mleitner@redhat.com, daniel@iogearbox.net, willemb@google.com,
	pasi.sarolahti@iki.fi, stephen@networkplumber.org,
	Netdev <netdev@vger.kernel.org>, anna.brunstrom@kau.se,
	apetlund@simula.no, michawe@ifi.uio.no, mohammad.rajiullah@kau.se
To: Per Hurtig <per.hurtig@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from script.cs.helsinki.fi ([128.214.11.1]:36455 "EHLO
	script.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932537AbbLHKuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 05:50:24 -0500
In-Reply-To: <8cd2c4817d86e30b09fe398c6bfcb7a89521bdb3.1449561786.git.per.hurtig@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Dec 2015, Per Hurtig wrote:

> This patch implements the RTO restart modification (RTOR). When data is
> ACKed, and the RTO timer is restarted, the time elapsed since the last
> outstanding segment was transmitted is subtracted from the calculated RTO
> value. This way, the RTO timer will expire after exactly RTO seconds, and
> not RTO + RTT [+ delACK] seconds.
> 
> This patch also implements a new sysctl (tcp_timer_restart) that is used
> to control the timer restart behavior.
> 
> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
> ---
>  Documentation/networking/ip-sysctl.txt | 12 ++++++++++++
>  include/net/tcp.h                      |  6 ++++++
>  net/ipv4/sysctl_net_ipv4.c             | 10 ++++++++++
>  net/ipv4/tcp_input.c                   | 29 +++++++++++++++++++++++++++++
>  4 files changed, 57 insertions(+)
> 
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index 2ea4c45..4094128 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -591,6 +591,18 @@ tcp_syn_retries - INTEGER
>  	with the current initial RTO of 1second. With this the final timeout
>  	for an active TCP connection attempt will happen after 127seconds.
>  
> +tcp_timer_restart - INTEGER
> +	Controls how the RTO and PTO timers are restarted (RTOR and TLPR).
> +	If set (per timer or combined) the timers are restarted with
> +	respect to the earliest outstanding segment, to not extend tail loss
> +	latency unnecessarily.
> +	Possible values:
> +		0 disables RTOR and TLPR.
> +		1 enables RTOR.
> +		2 enables TLPR.
> +		3 enables RTOR and TLPR.
> +	Default: 3
> +
>  tcp_timestamps - BOOLEAN
>  	Enable timestamps as defined in RFC1323.
>  
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index f80e74c..833efb7 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -76,6 +76,11 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
>  /* After receiving this amount of duplicate ACKs fast retransmit starts. */
>  #define TCP_FASTRETRANS_THRESH 3
>  
> +/* Disable RTO Restart if the number of outstanding segments is at least. */
> +#define TCP_TIMER_RTORESTART	1
> +#define TCP_TIMER_TLPRESTART	2
> +#define TCP_RTORESTART_THRESH	4

Unfortunately the comment got now separated from the actual define.


-- 
 i.
