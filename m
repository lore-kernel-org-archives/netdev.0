From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v5 net-next] tcp: switch rtt estimations to usec
 resolution
Date: Mon, 24 Feb 2014 15:51:30 -0800
Message-ID: <20140224155130.4c286cca@samsung-9>
References: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com>
	<alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg>
	<1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com>
	<1393181458.2316.56.camel@edumazet-glaptop2.roam.corp.google.com>
	<1393216927.2316.62.camel@edumazet-glaptop2.roam.corp.google.com>
	<1393266251.2316.68.camel@edumazet-glaptop2.roam.corp.google.com>
	<alpine.LFD.2.11.1402242240290.1941@ja.home.ssi.bg>
	<1393280025.2316.76.camel@edumazet-glaptop2.roam.corp.google.com>
	<alpine.LFD.2.11.1402250056250.1941@ja.home.ssi.bg>
	<1393284682.2316.83.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
	Yuchung Cheng <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:52513 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752727AbaBXXvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 18:51:33 -0500
Received: by mail-pa0-f44.google.com with SMTP id bj1so12703pad.31
        for <netdev@vger.kernel.org>; Mon, 24 Feb 2014 15:51:33 -0800 (PST)
In-Reply-To: <1393284682.2316.83.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Feb 2014 15:31:22 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Upcoming congestion controls for TCP require usec resolution for RTT
> estimations. Millisecond resolution is simply not enough these days.
> 
> FQ/pacing in DC environments also require this change for finer control
> and removal of bimodal behavior due to the current hack in
> tcp_update_pacing_rate() for 'small rtt'
> 
> TCP_CONG_RTT_STAMP no longer is needed.
> 
> As Julian Anastasov pointed out, we need to keep user compatibility :
> tcp_metrics used to export RTT and RTTVAR in msec resolution,
> so we added RTT_US and RTTVAR_US. An iproute2 patch is needed
> to use the new attributes if provided by the kernel.
> 
> In this example ss command displays a srtt of 32 usecs
> 
> lpk51:~# ./ss -i dst lpk52
> Netid  State      Recv-Q Send-Q   Local Address:Port       Peer
> Address:Port   
> tcp    ESTAB      0      1         10.246.11.51:42959
> 10.246.11.52:64614   
>          cubic wscale:6,6 rto:201 rtt:0.032/0.001 ato:40 mss:1448
> cwnd:10 send
> 3620.0Mbps pacing_rate 7240.0Mbps unacked:1 rcv_rtt:993 rcv_space:29559
>  
> Updated iproute2 ip command displays :
> 
> lpk51:~# ./ip tcp_metrics | grep 10.246.11.52
> 10.246.11.52 age 561.914sec cwnd 10 rtt 274us rttvar 213us source
> 10.246.11.51
> 
> Old binary displays :
> 
> lpk51:~# ip tcp_metrics | grep 10.246.11.52
> 10.246.11.52 age 561.914sec cwnd 10 rtt 250us rttvar 125us source
> 10.246.11.51
> 
> With help from Julian Anastasov and Yuchung Cheng
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Larry Brakmo <brakmo@google.com>
> Cc: Julian Anastasov <ja@ssi.bg>

The original reason I kept ms resolution and added the flag was
that accessing high resolution time is expensive for systems where
TSC is not stable.  Google may live in a world of SMP systems with
good X86 CPUs with working TSC, but other architectures and system
config's may have non-working TSC.
