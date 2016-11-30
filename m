From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [WIP] net+mlx4: auto doorbell
Date: Tue, 29 Nov 2016 23:28:36 -0800
Message-ID: <CAADnVQLSxkeOkZMAq=PRdPevSLTC6un-pj_QKD1wNeFZSYY-Sw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Rick Jones <rick.jones2@hpe.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:32815 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750810AbcK3H27 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 02:28:59 -0500
Received: by mail-lf0-f68.google.com with SMTP id 98so14850863lfs.0
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 23:28:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 10:58 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>  {
> @@ -496,8 +531,13 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
>         wmb();
>
>         /* we want to dirty this cache line once */
> -       ACCESS_ONCE(ring->last_nr_txbb) = last_nr_txbb;
> -       ACCESS_ONCE(ring->cons) = ring_cons + txbbs_skipped;
> +       WRITE_ONCE(ring->last_nr_txbb, last_nr_txbb);
> +       ring_cons += txbbs_skipped;
> +       WRITE_ONCE(ring->cons, ring_cons);
> +       WRITE_ONCE(ring->ncons, ring_cons + last_nr_txbb);
> +
> +       if (dev->doorbell_opt)
> +               mlx4_en_xmit_doorbell(dev, ring);
...
> +       /* Doorbell avoidance : We can omit doorbell if we know a TX completion
> +        * will happen shortly.
> +        */
> +       if (send_doorbell &&
> +           dev->doorbell_opt &&
> +           (s32)(READ_ONCE(ring->prod_bell) - READ_ONCE(ring->ncons)) > 0)
> +               send_doorbell = false;

this is awesome idea!
I'm missing though why you need all these read_once/write_once.
It's a tx ring that is already protected by tx queue lock
or completion is happening without grabbing the lock?
Then how do we make sure that we don't race here
and indeed above prod_bell - ncons > 0 condition is safe?
Good description of algorithm would certainly help ;)
