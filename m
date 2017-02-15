From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: do not fire tasklet unless necessary
Date: Wed, 15 Feb 2017 06:34:14 -0800
Message-ID: <1487169254.1311.15.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486729678.7793.139.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG9HWiNfGaWF_uB6F0BttPbzc_eSpow_zv7FwiK3GWoYQA@mail.gmail.com>
         <1487165355.1311.2.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG-Akhsxx6JjJckhdYwN0dFeyX17x7RQk1uBm3zc8fkFEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>, jackm@mellanox.com
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34025 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751063AbdBOOeR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 09:34:17 -0500
Received: by mail-pf0-f196.google.com with SMTP id o64so7932242pfb.1
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 06:34:16 -0800 (PST)
In-Reply-To: <CALzJLG-Akhsxx6JjJckhdYwN0dFeyX17x7RQk1uBm3zc8fkFEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-15 at 15:59 +0200, Saeed Mahameed wrote:

> can the tasklet run on a different core ?

No. tasklets are scheduled on local cpu, like softirqs in general.

They are not migrated, unless cpu is removed (hotplug)


> 
> the point is that if the EQ is full of CQEs from different CQs you would
> do the "  kick = list_empty(&tasklet_ctx->list);" test per empty CQ
> list rather than once at the end.
> 
> in mlx4_en case, you have only two CQs on each EQ but in RoCE/IB you
> can have as many CQs as you want.

list_empty() before one list_add_tail() is a single instruction.

By doing this right before manipulating the list, it comes with a zero
cache line penalty.

While if you do it at the wrong place, it incurs one extra cache line
miss.

This extra tasklet invocations can cost 3 % of cpu cycles.
