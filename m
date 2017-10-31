From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] ipv6: addrconf: increment ifp refcount before
 ipv6_del_addr()
Date: Tue, 31 Oct 2017 10:09:40 -0600
Message-ID: <1af0cf58-cf26-ed98-cb76-9547f3b3eae6@gmail.com>
References: <1509422017.17752.4.camel@edumazet-glaptop3.roam.corp.google.com>
 <f43e1142-e0c6-e2fa-dac8-00579747b91e@gmail.com>
 <1509428829.17752.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:45659 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751295AbdJaQJl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 12:09:41 -0400
Received: by mail-pf0-f196.google.com with SMTP id d28so14128131pfe.2
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 09:09:41 -0700 (PDT)
In-Reply-To: <1509428829.17752.15.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/17 11:47 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> In the (unlikely) event fixup_permanent_addr() returns a failure,
> addrconf_permanent_addr() calls ipv6_del_addr() without the
> mandatory call to in6_ifa_hold(), leading to a refcount error,
> spotted by syzkaller :
> 
> WARNING: CPU: 1 PID: 3142 at lib/refcount.c:227 refcount_dec+0x4c/0x50
> lib/refcount.c:227
> Kernel panic - not syncing: panic_on_warn set ...
> 
...
> 
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: David Ahern <dsahern@gmail.com>
> ---
>  net/ipv6/addrconf.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 4a96ebbf8eda5f59a6ff88e836d666a404d2bf0d..8a1c846d3df949a4638589f187120db22a3525ba 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3335,6 +3335,7 @@ static void addrconf_permanent_addr(struct net_device *dev)
>  		if ((ifp->flags & IFA_F_PERMANENT) &&
>  		    fixup_permanent_addr(idev, ifp) < 0) {
>  			write_unlock_bh(&idev->lock);
> +			in6_ifa_hold(ifp);
>  			ipv6_del_addr(ifp);
>  			write_lock_bh(&idev->lock);
>  
> 
> 

Interestingly, I put the failure sequence into a loop and hit the above
path closing in on 1 million times and I am not seeing a memory leak
with our without this patch.

The above does fix the refcnt and based on other call sites for
ipv6_del_addr is the right thing to do, so...

Acked-by: David Ahern <dsahern@gmail.com>
