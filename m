From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next 4/4] gianfar: use netif_tx_queue_stopped instead
 of __netif_subqueue_stopped
Date: Sun, 18 Mar 2012 19:24:44 -0400
Message-ID: <CAP=VYLpzpbLVAJ6=L1jdoZWcyAWPPKGMFTKBVU=7=HR+qTxwwA@mail.gmail.com>
References: <1332089787-24086-1-git-send-email-paul.gortmaker@windriver.com>
	<1332106761-18293-1-git-send-email-paul.gortmaker@windriver.com>
	<1332106761-18293-5-git-send-email-paul.gortmaker@windriver.com>
	<1332107741.9397.27.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, therbert@google.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:45179 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753640Ab2CRXYp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2012 19:24:45 -0400
Received: by lahj13 with SMTP id j13so4321628lah.19
        for <netdev@vger.kernel.org>; Sun, 18 Mar 2012 16:24:44 -0700 (PDT)
In-Reply-To: <1332107741.9397.27.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 18, 2012 at 5:55 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> On Sun, 2012-03-18 at 17:39 -0400, Paul Gortmaker wrote:
>> The __netif_subqueue_stopped() just does the following:
>>
>> =A0 =A0 =A0 =A0 struct netdev_queue *txq =3D netdev_get_tx_queue(dev=
, queue_index);
>> =A0 =A0 =A0 =A0 return netif_tx_queue_stopped(txq);
>>
>> and since we already have the txq in scope, we can just call that
>> directly in this case.
>>
>> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
>> ---
>> =A0drivers/net/ethernet/freescale/gianfar.c | =A0 =A02 +-
>> =A01 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/=
ethernet/freescale/gianfar.c
>> index 6e66cc3..d9428f0 100644
>> --- a/drivers/net/ethernet/freescale/gianfar.c
>> +++ b/drivers/net/ethernet/freescale/gianfar.c
>> @@ -2565,7 +2565,7 @@ static int gfar_clean_tx_ring(struct gfar_priv=
_tx_q *tx_queue)
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 /* If we freed a buffer, we can restart transmission, if=
 necessary */
>> - =A0 =A0 if (__netif_subqueue_stopped(dev, tqi) && tx_queue->num_tx=
bdfree)
>> + =A0 =A0 if (netif_tx_queue_stopped(txq) && tx_queue->num_txbdfree)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_wake_subqueue(dev, tqi);
>>
>> =A0 =A0 =A0 /* Update dirty indicators */
>
> Please change netif_wake_subqueue() as well ;)

I looked at this earlier when I added patch #4 but I was concerned abou=
t
the different semantics.

The netif_wake_subqueue() just returns on a netpoll_trap but the other
netif_tx_wake_queue() actually calls netif_tx_start_queue() for the sam=
e
netpoll_trap instance.  Maybe that is OK, but I didn't want to be chang=
ing
the behaviour of subtleties in stuff where I am clearly still learning.

Thanks,
Paul.

>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
