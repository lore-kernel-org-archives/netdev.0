From: Debabrata Banerjee <dbavatar@gmail.com>
Subject: Re: [PATCH net-next v4 1/2] fix return of iptunnel_xmit
Date: Fri, 9 Oct 2015 14:11:17 -0400
Message-ID: <CAATkVEyO6pQDJqv6yADD5hAZ15k2NpKWBunwxmvYi7P46Z1gjA@mail.gmail.com>
References: <1444382858-6725-1-git-send-email-aschultz@tpip.net>
	<1444382858-6725-2-git-send-email-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: Andreas Schultz <aschultz@tpip.net>,
	Joshua Hunt <johunt@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35537 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093AbbJISLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 14:11:18 -0400
Received: by wicge5 with SMTP id ge5so79076317wic.0
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 11:11:17 -0700 (PDT)
In-Reply-To: <1444382858-6725-2-git-send-email-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andreas, I think we need to use the net_xmit defines so the errors are
masked properly, how about:

-       if (unlikely(net_xmit_eval(err)))
-               pkt_len = 0;
-       return pkt_len;
+       if (likely(net_xmit_eval(err) == 0))
+               return pkt_len;
+       else
+               return net_xmit_errno(err);
+
+       return 0;

On Fri, Oct 9, 2015 at 5:27 AM, Andreas Schultz <aschultz@tpip.net> wrote:
> All users of iptunnel_xmit expect the return value to be the packet
> length on success (>0), negative for a tx error and zero for a tx
> dropped error. In cset 0e6fbc5b6c6218987c93b8c7ca60cf786062899d the
> negative return case was lost.
>
> This bug was introduced when the ip_tunnel_core code was refactored.
>
> Fixes: 0e6fbc5b6c6218987c93b8c7ca60cf786062899d
> Signed-off-by: Andreas Schultz <aschultz@tpip.net>
> Acked-by: Jiri Benc <jbenc@redhat.com>
> Acked-by: Pravin B Shelar <pshelar@nicira.com>
> ---
> Change in v2:
>  - remove unused variable pkt_len
>
> Change in v3:
>  - reworked based on comment from Jiri Benc
>
> Change in v4:
>  - rebased to net-next to avoid merge conflicts
>  - added Acked-By from Jiri Benc and Pravin B Shelar
>
> ---
>  net/ipv4/ip_tunnel_core.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
> index 6cb9009..453d569 100644
> --- a/net/ipv4/ip_tunnel_core.c
> +++ b/net/ipv4/ip_tunnel_core.c
> @@ -80,9 +80,12 @@ int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
>         __ip_select_ident(net, iph, skb_shinfo(skb)->gso_segs ?: 1);
>
>         err = ip_local_out(net, sk, skb);
> -       if (unlikely(net_xmit_eval(err)))
> -               pkt_len = 0;
> -       return pkt_len;
> +       if (likely(net_xmit_eval(err) == 0))
> +               return pkt_len;
> +       if (err < 0)
> +               return err;
> +
> +       return 0;
>  }
>  EXPORT_SYMBOL_GPL(iptunnel_xmit);
>
> --
> 2.1.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
