From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/1] tcp: sysctl: Fix a race to avoid
 unexpected 0 window from space
Date: Fri, 24 Mar 2017 13:31:47 -0700
Message-ID: <20170324133147.55d2ea3a@xeon-e3>
References: <1490310312-20661-1-git-send-email-gfree.wind@foxmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Gao Feng <fgao@ikuai8.com>
To: gfree.wind@foxmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:35245 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756207AbdCXUcA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 16:32:00 -0400
Received: by mail-pg0-f44.google.com with SMTP id t143so534646pgb.2
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 13:31:59 -0700 (PDT)
In-Reply-To: <1490310312-20661-1-git-send-email-gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Mar 2017 07:05:12 +0800
gfree.wind@foxmail.com wrote:

> From: Gao Feng <fgao@ikuai8.com>
> 
> Because sysctl_tcp_adv_win_scale could be changed any time, so there
> is one race in tcp_win_from_space.
> For example,
> 1.sysctl_tcp_adv_win_scale<=0 (sysctl_tcp_adv_win_scale is negative now)
> 2.space>>(-sysctl_tcp_adv_win_scale) (sysctl_tcp_adv_win_scale is postive now)  
> 
> As a result, tcp_win_from_space returns 0. It is unexpected.
> 
> Certainly if the compiler put the sysctl_tcp_adv_win_scale into one
> register firstly, then use the register directly, it would be ok.
> But we could not depend on the compiler behavior.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  include/net/tcp.h | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 6ec4ea6..119b592 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1252,9 +1252,11 @@ void tcp_select_initial_window(int __space, __u32 mss, __u32 *rcv_wnd,
>  
>  static inline int tcp_win_from_space(int space)
>  {
> -	return sysctl_tcp_adv_win_scale<=0 ?
> -		(space>>(-sysctl_tcp_adv_win_scale)) :  
> -		space - (space>>sysctl_tcp_adv_win_scale);
> +	int tcp_adv_win_scale = sysctl_tcp_adv_win_scale;
> +
> +	return tcp_adv_win_scale <= 0 ?
> +		(space>>(-tcp_adv_win_scale)) :
> +		space - (space>>tcp_adv_win_scale);
>  }
>  
>  /* Note: caller must be prepared to deal with negative returns */

You need to use READ_ONCE() to be safe. The compiler is free to optimized the code back
to the original unless READ_ONCE() is used.
