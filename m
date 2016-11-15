From: Rolf Neugebauer <rolf.neugebauer@docker.com>
Subject: Re: [PATCH net] gro_cells: mark napi struct as not busy poll candidates
Date: Tue, 15 Nov 2016 17:08:28 +0000
Message-ID: <CA+pO-2e4d1u_KQY4Ao9UmqV2Nh3bCos9gxD1Pvx8brnHfXQSRQ@mail.gmail.com>
References: <CA+pO-2f+7QfsLiFwvGcNqTrQ0t8B5+w0vZHFrshWsSWgDE6iUg@mail.gmail.com>
 <CAM_iQpUNRyv3wHi3cJpcH6avo+D7Gxwqp+iybUxYc7PCo3WUPw@mail.gmail.com>
 <20161110212404.GB4127@linux.vnet.ibm.com> <CA+pO-2ddoJYvhVoV3Bo+-3K7V63eY9sbKzKwYrut65GZXs6_1g@mail.gmail.com>
 <20161112002347.GL4127@linux.vnet.ibm.com> <CAM_iQpUDnPfVayQv7Q+ZtC_2_ZbX9MRX=514gFpF3E6XY+GtSA@mail.gmail.com>
 <CAM_iQpUq14GsvGyz2xA1PkDq5YO743T68Zh2zm=NJZQ9S2Ahqg@mail.gmail.com>
 <20161114162417.GJ4127@linux.vnet.ibm.com> <CAM_iQpXL+JaVG86+h2ucYs4Dm0zJKHq+4Nm+gk75wESGOzTmJQ@mail.gmail.com>
 <20161114181425.GN4127@linux.vnet.ibm.com> <87y40lhfrt.fsf@xmission.com>
 <1479163571.8455.83.camel@edumazet-glaptop3.roam.corp.google.com>
 <1479164967.8455.87.camel@edumazet-glaptop3.roam.corp.google.com> <1479169722.8455.108.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        David Miller <davem@davemloft.net>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Justin Cormack <justin.cormack@docker.com>,
        Ian Campbell <ian.campbell@docker.com>,
        Eric Dumazet <edumazet@google.com>,
        Rolf Neugebauer <rolf.neugebauer@docker.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:34059 "EHLO
        mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751576AbcKORIa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 12:08:30 -0500
Received: by mail-qk0-f169.google.com with SMTP id q130so143206106qke.1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 09:08:29 -0800 (PST)
In-Reply-To: <1479169722.8455.108.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 15, 2016 at 12:28 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Rolf Neugebauer reported very long delays at netns dismantle.
>
> Eric W. Biederman was kind enough to look at this problem
> and noticed synchronize_net() occurring from netif_napi_del() that was
> added in linux-4.5
>
> Busy polling makes no sense for tunnels NAPI.
> If busy poll is used for sessions over tunnels, the poller will need to
> poll the physical device queue anyway.
>
> netif_tx_napi_add() could be used here, but function name is misleading,
> and renaming it is not stable material, so set NAPI_STATE_NO_BUSY_POLL
> bit directly.
>
> This will avoid inserting gro_cells napi structures in napi_hash[]
> and avoid the problematic synchronize_net() (per possible cpu) that
> Rolf reported.

Thanks for the quick turn-around. I've tested this on both 4.9-rc5 and
4.8.7  with different CPU configs and it dramatically reduced the
delay. I still see a small (1s) delay for creating a new namespace
after deleting one in one config but will follow up with the details
on the original email thread.

>
> Fixes: 93d05d4a320c ("net: provide generic busy polling to all NAPI drivers")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Rolf Neugebauer <rolf.neugebauer@docker.com>
> Reported-by: Eric W. Biederman <ebiederm@xmission.com>

Tested-by: Rolf Neugebauer <rolf.neugebauer@docker.com>

> ---
>  include/net/gro_cells.h |    3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/include/net/gro_cells.h b/include/net/gro_cells.h
> index d15214d673b2e8e08fd6437b572278fb1359f10d..2a1abbf8da74368cd01adc40cef6c0644e059ef2 100644
> --- a/include/net/gro_cells.h
> +++ b/include/net/gro_cells.h
> @@ -68,6 +68,9 @@ static inline int gro_cells_init(struct gro_cells *gcells, struct net_device *de
>                 struct gro_cell *cell = per_cpu_ptr(gcells->cells, i);
>
>                 __skb_queue_head_init(&cell->napi_skbs);
> +
> +               set_bit(NAPI_STATE_NO_BUSY_POLL, &cell->napi.state);
> +
>                 netif_napi_add(dev, &cell->napi, gro_cell_poll, 64);
>                 napi_enable(&cell->napi);
>         }
>
>
