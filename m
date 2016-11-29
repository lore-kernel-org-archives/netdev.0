From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net] openvswitch: Fix skb leak in IPv6 reassembly.
Date: Mon, 28 Nov 2016 23:39:56 -0800
Message-ID: <CAOrHB_BuRhQrsY5pRGOK9Zo-fEN149Ts9Jj2ADUTQzx84Xd9+A@mail.gmail.com>
References: <20161128234353.4262-1-diproiettod@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Florian Westphal <fw@strlen.de>, Joe Stringer <joe@ovn.org>
To: Daniele Di Proietto <diproiettod@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:58235 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752169AbcK2HkC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 02:40:02 -0500
Received: from mfilter37-d.gandi.net (mfilter37-d.gandi.net [217.70.178.168])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id B6DC9FB8C2
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 08:40:00 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter37-d.gandi.net (mfilter37-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 2B23r4QO9g5F for <netdev@vger.kernel.org>;
        Tue, 29 Nov 2016 08:39:59 +0100 (CET)
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
        (Authenticated sender: pshelar@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 2A4F2FB8B9
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 08:39:58 +0100 (CET)
Received: by mail-io0-f177.google.com with SMTP id c21so264747059ioj.1
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 23:39:58 -0800 (PST)
In-Reply-To: <20161128234353.4262-1-diproiettod@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 3:43 PM, Daniele Di Proietto
<diproiettod@ovn.org> wrote:
> If nf_ct_frag6_gather() returns an error other than -EINPROGRESS, it
> means that we still have a reference to the skb.  We should free it
> before returning from handle_fragments, as stated in the comment above.
>
> Fixes: daaa7d647f81 ("netfilter: ipv6: avoid nf_iterate recursion")
> CC: Florian Westphal <fw@strlen.de>
> CC: Pravin B Shelar <pshelar@ovn.org>
> CC: Joe Stringer <joe@ovn.org>
> Signed-off-by: Daniele Di Proietto <diproiettod@ovn.org>
> ---
>  net/openvswitch/conntrack.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> index 31045ef..fecefa2 100644
> --- a/net/openvswitch/conntrack.c
> +++ b/net/openvswitch/conntrack.c
> @@ -370,8 +370,11 @@ static int handle_fragments(struct net *net, struct sw_flow_key *key,
>                 skb_orphan(skb);
>                 memset(IP6CB(skb), 0, sizeof(struct inet6_skb_parm));
>                 err = nf_ct_frag6_gather(net, skb, user);
> -               if (err)
> +               if (err) {
> +                       if (err != -EINPROGRESS)
> +                               kfree_skb(skb);
>                         return err;
> +               }
>

This fixes the code. But the patch is adding yet another skb-kfree in
conntrack code. we could simplify it by reusing error handling in
do_execute_actions().
If you think that is too complicated for stable branch, I am fine with
this patch going in as it is.
