From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next v2 8/9] nfp: add a stats handler for flower offloads
Date: Thu, 29 Jun 2017 18:16:41 +0300
Message-ID: <CAJ3xEMg6Eu+wo=P0kUDHCs_N2K=-qDeZ02sMX2wE+48snr9i2Q@mail.gmail.com>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com> <1498681802-2897-9-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:36642 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751974AbdF2PQm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 11:16:42 -0400
Received: by mail-oi0-f50.google.com with SMTP id p187so69085259oif.3
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 08:16:42 -0700 (PDT)
In-Reply-To: <1498681802-2897-9-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 28, 2017 at 11:30 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
>
> Previously there was no way of updating flow rule stats after they
> have been offloaded to hardware. This is solved by keeping track of
> stats received from hardware and providing this to the TC handler
> on request.

> +static void
> +nfp_flower_update_stats(struct nfp_app *app, struct nfp_fl_stats_frame *stats)
> +{
> +       struct nfp_fl_payload *nfp_flow;
> +       unsigned long flower_cookie;
> +
> +       flower_cookie = be64_to_cpu(stats->stats_cookie);
> +
> +       rcu_read_lock();
> +       nfp_flow = nfp_flower_find_in_fl_table(app, flower_cookie);
> +       if (!nfp_flow)
> +               goto exit_rcu_unlock;
> +
> +       if (nfp_flow->meta.host_ctx_id != stats->stats_con_id)
> +               goto exit_rcu_unlock;
> +
> +       spin_lock(&nfp_flow->lock);
> +       nfp_flow->stats.pkts += be32_to_cpu(stats->pkt_count);
> +       nfp_flow->stats.bytes += be64_to_cpu(stats->byte_count);

you're using += with the values you get form the fw, are they incremental?

> +       nfp_flow->stats.used = jiffies;

if nothing was changed since your last reading, it's wrong to say that
used == NOW

> +       spin_unlock(&nfp_flow->lock);

if indeed you need to keep a clone of earlier calls to correctly
compute the (last)used value,
maybe you can get rid of the locking?
