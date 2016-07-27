From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] sit: Correctly return -ENOMEM from SIOCGETPRL ioctl.
Date: Wed, 27 Jul 2016 09:28:29 -0700
Message-ID: <CAM_iQpVx9_k6A+wT8RPusAsfNavi7Mo8kp3N+8NCytgmZ5+a8g@mail.gmail.com>
References: <20160727135725.13559-1-phil.turnbull@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Phil Turnbull <phil.turnbull@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35239 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754200AbcG0Q2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 12:28:50 -0400
Received: by mail-io0-f193.google.com with SMTP id q83so5799633iod.2
        for <netdev@vger.kernel.org>; Wed, 27 Jul 2016 09:28:49 -0700 (PDT)
In-Reply-To: <20160727135725.13559-1-phil.turnbull@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 27, 2016 at 6:57 AM, Phil Turnbull <phil.turnbull@oracle.com> wrote:
> -ENOMEM is never returned because the 'out' path unconditionally sets
> 'ret' to zero. Remove the 'out' path and return directly when the
> allocation fails.
>
> Fixes: 300aaeeaab5f ("[IPV6] SIT: Add SIOCGETPRL ioctl to get/dump PRL.")
> Signed-off-by: Phil Turnbull <phil.turnbull@oracle.com>
> ---
>  net/ipv6/sit.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
> index 0619ac70836d..a71514040bb4 100644
> --- a/net/ipv6/sit.c
> +++ b/net/ipv6/sit.c
> @@ -320,8 +320,8 @@ static int ipip6_tunnel_get_prl(struct ip_tunnel *t,
>                  */
>                 kp = kcalloc(ca, sizeof(*kp), GFP_ATOMIC);
>                 if (!kp) {
> -                       ret = -ENOMEM;
> -                       goto out;
> +                       rcu_read_unlock();
> +                       return -ENOMEM;
>                 }

Or even better: we don't have to do the second kcalloc()
within rcu read lock, we can move it before rcu_read_lock()?
