From: Liu Yu <allanliuyu@gmail.com>
Subject: Re: [PATCH] tcp_cubic: fix divide error when SYN flood
Date: Tue, 22 Apr 2014 10:33:24 +0800
Message-ID: <5355D4F4.2020302@gmail.com>
References: <5355CBB0.7020905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:61378 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754356AbaDVCby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 22:31:54 -0400
Received: by mail-pb0-f53.google.com with SMTP id rp16so4358607pbb.40
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 19:31:53 -0700 (PDT)
In-Reply-To: <5355CBB0.7020905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


please ignore this.
sorry for bad format.

Liu Yu said, at 2014/4/22 9:53:
> 
> From: Liu Yu <allanyuliu@tencent.com>
> 
> commit b9f47a3aaeab (tcp_cubic: limit delayed_ack ratio to prevent
> divide error) try to prevent divide error, but it still has a little
> chance that delayed_ack can reach zero. In case machine sufferring
> continuous SYN flood, the argument cnt could be big, and so that
> ratio+cnt could get overflow and may happen to be zero. If so,
> min(ratio, ACK_RATIO_LIMIT) will calculate to be zero.
> 
> The crash log may like this:
> ..
> <6>[27536.083145] possible SYN flooding on port 8080. Sending cookies.
> <6>[27596.092124] possible SYN flooding on port 8080. Sending cookies.
> <6>[27656.109832] possible SYN flooding on port 8080. Sending cookies.
> <0>[27676.940730] divide error: 0000 [#1] SMP
> <0>[27676.987890] last sysfs file: /sys/class/scsi_host/host0/proc_name
> ..
> 
> CC: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: Liu Yu <allanyuliu@tencent.com>
> ---
> net/ipv4/tcp_cubic.c | 4 ++--
> 1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
> index 8bf2245..9d332b9 100644
> --- a/net/ipv4/tcp_cubic.c
> +++ b/net/ipv4/tcp_cubic.c
> @@ -404,12 +404,12 @@ static void bictcp_acked(struct sock *sk, u32 cnt, s32 rtt_us)
> u32 delay;
> 
> if (icsk->icsk_ca_state == TCP_CA_Open) {
> - u32 ratio = ca->delayed_ack;
> + u64 ratio = ca->delayed_ack;
> 
> ratio -= ca->delayed_ack >> ACK_RATIO_SHIFT;
> ratio += cnt;
> 
> - ca->delayed_ack = min(ratio, ACK_RATIO_LIMIT);
> + ca->delayed_ack = min_t(u64, ratio, ACK_RATIO_LIMIT);
> }
> 
> /* Some calls are for duplicates without timetamps */
> 
