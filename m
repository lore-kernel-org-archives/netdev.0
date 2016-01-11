From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net] net: reduce RECURSION_LIMIT to 8
Date: Sun, 10 Jan 2016 22:38:22 -0800
Message-ID: <CAOrHB_AWdZw1XDmxVU=bDh=gB2M3cnXUC8MyXCnV1YVjZEAsKw@mail.gmail.com>
References: <1452188453-5523-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:45352 "EHLO
	relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbcAKGi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 01:38:27 -0500
Received: from mfilter28-d.gandi.net (mfilter28-d.gandi.net [217.70.178.159])
	by relay6-d.mail.gandi.net (Postfix) with ESMTP id 2A71BFB8B1
	for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 07:38:26 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
	by mfilter28-d.gandi.net (mfilter28-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id 1QFvfMs84cai for <netdev@vger.kernel.org>;
	Mon, 11 Jan 2016 07:38:24 +0100 (CET)
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	(Authenticated sender: pshelar@ovn.org)
	by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id BC4DBFB88B
	for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 07:38:23 +0100 (CET)
Received: by mail-io0-f179.google.com with SMTP id 1so292604819ion.1
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 22:38:23 -0800 (PST)
In-Reply-To: <1452188453-5523-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 7, 2016 at 9:40 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> When RECURSION_LIMIT was first introduced, Eric proposed a limit of 3.
> This limit was later raised to 10 by DaveM. Nowadays it is observed that
> configuraion errors in openvswitch cause the STACK_END_MAGIC to be
> overwritten shortly after 9 recursion.
>
Major user of stack space in OVS is sw_flow_key in
ovs_vport_receive(). With recent features like IPv6 tunnel support we
have increased the size of the flow-key which could have caused the
stack overflow sooner.
One way to avoid using stack in subsequent recursive call is to use
per-cpu storage for the sw_flow_key object. This is already done for
OVS recursive actions, so we can expand on that facility.


> This patch tries to be conservative and reduces the limit to 8 without
> further measurements. It seems ovs uses the stack more than other parts
> of the networking stack - I couldn't bring the system down with a non-ovs
> tunneling setup.
>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> I don't do crazy run-time estimation of the stack size for one recursion
> and try automatically to come up with a limit per arch or kconfig
> settings, as I assume that all systems should behave the same regarding
> the recursion maximum. All configurations should run on all kinds of
> systems. I consider 8 recursions to be plenty enough for the time being.
>
>  net/core/dev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index ae00b894e67555..d93da7df84325d 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2941,7 +2941,7 @@ static void skb_update_prio(struct sk_buff *skb)
>  DEFINE_PER_CPU(int, xmit_recursion);
>  EXPORT_SYMBOL(xmit_recursion);
>
> -#define RECURSION_LIMIT 10
> +#define RECURSION_LIMIT 8
>
>  /**
>   *     dev_loopback_xmit - loop back @skb
> --
> 2.5.0
>
