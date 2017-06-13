From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] igmp: acquire pmc lock for ip_mc_clear_src()
Date: Tue, 13 Jun 2017 13:00:37 -0400 (EDT)
Message-ID: <20170613.130037.2205216485425901214.davem@davemloft.net>
References: <1497286346-26888-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com, edumazet@google.com,
        lucien.xin@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44990 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752211AbdFMRKv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 13:10:51 -0400
In-Reply-To: <1497286346-26888-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 12 Jun 2017 09:52:26 -0700

> Andrey reported a use-after-free in add_grec():
> 
>         for (psf = *psf_list; psf; psf = psf_next) {
> 		...
>                 psf_next = psf->sf_next;
> 
> where the struct ip_sf_list's were already freed by:
> 
>  kfree+0xe8/0x2b0 mm/slub.c:3882
>  ip_mc_clear_src+0x69/0x1c0 net/ipv4/igmp.c:2078
>  ip_mc_dec_group+0x19a/0x470 net/ipv4/igmp.c:1618
>  ip_mc_drop_socket+0x145/0x230 net/ipv4/igmp.c:2609
>  inet_release+0x4e/0x1c0 net/ipv4/af_inet.c:411
>  sock_release+0x8d/0x1e0 net/socket.c:597
>  sock_close+0x16/0x20 net/socket.c:1072
> 
> This happens because we don't hold pmc->lock in ip_mc_clear_src()
> and a parallel mr_ifc_timer timer could jump in and access them.
> 
> The RCU lock is there but it is merely for pmc itself, this
> spinlock could actually ensure we don't access them in parallel.
> 
> Thanks to Eric and Long for discussion on this bug.
> 
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Xin Long <lucien.xin@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.
