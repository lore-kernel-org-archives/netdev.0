From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: bcmgenet: add BQL support
Date: Fri, 08 Apr 2016 21:53:28 -0700
Message-ID: <1460177608.6473.463.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459903801-83727-1-git-send-email-pgynther@google.com>
	 <20160408.163648.2055481752216023669.davem@davemloft.net>
	 <CAGXr9JE8Qp-u4gjm08oB8nXDoQxFM12=Da2=MZbWcZrRXOCi_w@mail.gmail.com>
	 <1460166979.6473.451.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAGXr9JEiz3W3HxBJSHbk1pjikTP6M-Dg9o7wNCQpqc1sguZQpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>, opendmb@gmail.com,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Petri Gynther <pgynther@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:33066 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077AbcDIExh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 00:53:37 -0400
Received: by mail-qg0-f53.google.com with SMTP id j35so106842036qge.0
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 21:53:36 -0700 (PDT)
In-Reply-To: <CAGXr9JEiz3W3HxBJSHbk1pjikTP6M-Dg9o7wNCQpqc1sguZQpw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-08 at 21:13 -0700, Petri Gynther wrote:

> What values does the networking core program into BQL dynamic limits
> that my code in netdev->ndo_open() would wipe out?
> 

0 and 0

Clearing again these values by 0 and 0 is defensive programming.

As I said, no BQL enabled driver does that, and we do not want various
drivers implementing BQL in various ways.

Having the same logic is easier for code review and maintenance.

This was proven to work for many years.

> You mentioned the queue init path:
> netdev_init_one_queue() -> dql_init() -> dql_reset()
> 
> that is called when the netdev is created and Tx queues allocated.
> 
> But, does the networking core somewhere set *different* values for BQL
> dynamic limits than what dql_reset() did, before opening the device?
> 
> > For example, tg3 calls netdev_tx_reset_queue() only when freeing tx
> > rings, as it might have freed skb(s) not from normal TX complete path
> > and thus missed appropriate dql_completed().
> >
> 
> Looking at the tg3 driver, it calls:
> tg3_stop()
>   tg3_free_rings()
>     netdev_tx_reset_queue()
> 
> netdev_tx_reset_queue() is called unconditionally, as long as the Tx
> ring exists. So "ip link set dev eth<x> down" would cause it to be
> called.
> 
> Why is it OK to call netdev_tx_reset_queue() from the
> netdev->ndo_stop() path, but not from netdev->ndo_open() path?

Because we properly init BQL state when a device is created in core
networking stack. So that we do not have to copy the same code over and
over in 100 drivers. This is called code factorization.


Put these calls in bcmgenet_fini_dma(), to follow the BQL model used in
all other drivers.

Thanks.
