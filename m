From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] net: avoid vlan ptype specific match to be leaked on
 real device
Date: Wed, 22 Jun 2016 12:55:44 +0200
Message-ID: <20160622105544.GC2068@nanopsycho.orion>
References: <3d191a3c51bd564da8b0c3ffe1e9c90fa7bd4d7b.1466590952.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:34957 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752564AbcFVMBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 08:01:00 -0400
Received: by mail-wm0-f52.google.com with SMTP id v199so84448666wmv.0
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 05:00:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <3d191a3c51bd564da8b0c3ffe1e9c90fa7bd4d7b.1466590952.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jun 22, 2016 at 12:25:15PM CEST, pabeni@redhat.com wrote:
>Before the commit 0dfe17823945 ("net: vlan: goto another_round
>instead of calling __netif_receive_skb"), on tagged skb ingress,
>ptype specific protocol matches were delivered only to the
>related vlan device, if any.
>After said commit, jumping back to the 'another_round' label, allows
>the later ptype specific check to match both orig_dev and skb->dev,
>delivering the skb to both the vlan device and the underlying
>device.
>This cause i.e. packet sockets bound to a specific protocol type on
>one of said devices to receive also frames really targeting the
>other device.
>This commit resets orig_dev before performing another round due to
>vlan processing, allowing the skb to be delivered once again only
>to the vlan specific ptypes.

I don't get why vlan should behave differently in this comparing to
other stacked devices like bond/team/br etc.

Could you please explain?


>
>Fixes: 0dfe17823945 ("net: vlan: goto another_round instead of calling __netif_receive_skb")
>Reported-by: Ryan Liu <Ryan.Liu@alcatel-lucent.com>
>Reported-by: Cliff Chen <Cliff.Chen@alcatel-lucent.com>
>Signed-off-by: Paolo Abeni <pabeni@redhat.com>
>---
> net/core/dev.c | 9 +++++++--
> 1 file changed, 7 insertions(+), 2 deletions(-)
>
>diff --git a/net/core/dev.c b/net/core/dev.c
>index 904ff43..9d08dd6 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -4144,10 +4144,15 @@ ncls:
> 			ret = deliver_skb(skb, pt_prev, orig_dev);
> 			pt_prev = NULL;
> 		}
>-		if (vlan_do_receive(&skb))
>+		if (vlan_do_receive(&skb)) {
>+			/* avoid delivering to ptype registered on
>+			 * vlan's underlying device only
>+			 */
>+			orig_dev = skb->dev;
> 			goto another_round;
>-		else if (unlikely(!skb))
>+		} else if (unlikely(!skb)) {
> 			goto out;
>+		}
> 	}
> 
> 	rx_handler = rcu_dereference(skb->dev->rx_handler);
>-- 
>1.8.3.1
>
