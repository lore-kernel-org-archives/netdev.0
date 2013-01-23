From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: v3 for tcp friends?
Date: Tue, 22 Jan 2013 22:46:46 -0800
Message-ID: <1358923606.12374.746.camel@edumazet-glaptop>
References: <20120903.154833.1547153833820955116.davem@davemloft.net>
	 <CAEkNxbGJ6OGy3HDSeToXO_cDt7azpRZvy_CbQH0_UJ_mCS2s3w@mail.gmail.com>
	 <20120904.125841.2293649688957878987.davem@davemloft.net>
	 <50FCEE64.80203@gmail.com> <50FCEEC5.9010404@gmail.com>
	 <CA+WLrf8xuJ3UXK-tZQykuTPMXu67WsNKWNuNzBKk7MBAidW-CQ@mail.gmail.com>
	 <CAEkNxbH0MAAU9oiwwrFTbMJP1yzfNdxD5NDdZOqGnvhTLvodoQ@mail.gmail.com>
	 <50FF5592.60008@gmail.com>  <50FF7F64.2060902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Bruce Curtis <brutus@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:42855 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950Ab3AWGqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 01:46:49 -0500
Received: by mail-pa0-f41.google.com with SMTP id bj3so4560664pad.14
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 22:46:49 -0800 (PST)
In-Reply-To: <50FF7F64.2060902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-23 at 14:12 +0800, Li Yu wrote:
> Oops, this hang is not since TCP friends patch!
> 
> sk_sndbuf_get() is broken by 32 bits integer overflow
> because of so large value in net.ipv4.tcp_{rmem,wmem}.
> 
> but this hang also can be found in net-next.git
> (3.8.0-rc3+), if we run below commands, then all new
> TCP connections stop working!
> 
> # when TCP friends is disabled
> sysctl -w net.ipv4.tcp_rmem="4096 4294967296 4294967296" # 4GB
> sysctl -w net.ipv4.tcp_wmem="4096 4294967296 4294967296"

Right we need to make sure we dont overflow.

Try the following fix :

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index a25e1d2..1459145 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -549,14 +549,16 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_wmem,
 		.maxlen		= sizeof(sysctl_tcp_wmem),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.extra1		= &zero,
+		.proc_handler	= proc_dointvec_minmax
 	},
 	{
 		.procname	= "tcp_rmem",
 		.data		= &sysctl_tcp_rmem,
 		.maxlen		= sizeof(sysctl_tcp_rmem),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.extra1		= &zero,
+		.proc_handler	= proc_dointvec_minmax
 	},
 	{
 		.procname	= "tcp_app_win",
