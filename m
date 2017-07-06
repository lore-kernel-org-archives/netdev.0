From: Erik Stromdahl <erik.stromdahl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: ath10k: ret used but uninitialized (was: Re: ath10k: add initial
 SDIO support)
Date: Thu, 6 Jul 2017 22:01:57 +0200
Message-ID: <c72d2e7a-195d-bcac-4ce5-f3051531664c@gmail.com>
References: <CAMuHMdWVYA4TejcTjOQh7CBfFwJ=q59pzvuHrpH91Kx=-BK9fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        "ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
        Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMuHMdWVYA4TejcTjOQh7CBfFwJ=q59pzvuHrpH91Kx=-BK9fg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> With gcc 4.1.2:
> 
> drivers/net/wireless/ath/ath10k/sdio.c: In function
> ‘ath10k_sdio_mbox_rxmsg_pending_handler’:
> drivers/net/wireless/ath/ath10k/sdio.c:676: warning: ‘ret’ may be used
> uninitialized in this function
> 
>> +
>> +       *done = true;
>> +
>> +       /* Copy the lookahead obtained from the HTC register table into our
>> +        * temp array as a start value.
>> +        */
>> +       lookaheads[0] = msg_lookahead;
>> +
>> +       timeout = jiffies + SDIO_MBOX_PROCESSING_TIMEOUT_HZ;
> 
> Although very unlikely due to the long timeout, if the code is preempted here,
> and the loop below never entered, ret will indeed be uninitialized.
> 
> It's unclear to me what the proper initialization would be, though, so
> that's why I didn't send a patch.
> 
I think it would be best to use 0 as initial value of ret in this case.
This will make all other interrupts be processed in a normal way.

Kalle: Should I create a new patch (initializing ret with zero)?

>> +       while (time_before(jiffies, timeout)) {
>> +               /* Try to allocate as many HTC RX packets indicated by
>> +                * n_lookaheads.
>> +                */
>> +               ret = ath10k_sdio_mbox_rx_alloc(ar, lookaheads,
>> +                                               n_lookaheads);
>> +               if (ret)
>> +                       break;
>> +
>> +               if (ar_sdio->n_rx_pkts >= 2)
>> +                       /* A recv bundle was detected, force IRQ status
>> +                        * re-check again.
>> +                        */
>> +                       *done = false;
>> +
>> +               ret = ath10k_sdio_mbox_rx_fetch(ar);
>> +
>> +               /* Process fetched packets. This will potentially update
>> +                * n_lookaheads depending on if the packets contain lookahead
>> +                * reports.
>> +                */
>> +               n_lookaheads = 0;
>> +               ret = ath10k_sdio_mbox_rx_process_packets(ar,
>> +                                                         lookaheads,
>> +                                                         &n_lookaheads);
>> +
>> +               if (!n_lookaheads || ret)
>> +                       break;
>> +
>> +               /* For SYNCH processing, if we get here, we are running
>> +                * through the loop again due to updated lookaheads. Set
>> +                * flag that we should re-check IRQ status registers again
>> +                * before leaving IRQ processing, this can net better
>> +                * performance in high throughput situations.
>> +                */
>> +               *done = false;
>> +       }
>> +
>> +       if (ret && (ret != -ECANCELED))
>> +               ath10k_warn(ar, "failed to get pending recv messages: %d\n",
>> +                           ret);
>> +
>> +       return ret;
>> +}
> 
>> +static void ath10k_sdio_irq_handler(struct sdio_func *func)
>> +{
>> +       struct ath10k_sdio *ar_sdio = sdio_get_drvdata(func);
>> +       struct ath10k *ar = ar_sdio->ar;
>> +       unsigned long timeout;
>> +       bool done = false;
>> +       int ret;
> 
> drivers/net/wireless/ath/ath10k/sdio.c: In function ‘ath10k_sdio_irq_handler’:
> drivers/net/wireless/ath/ath10k/sdio.c:1331: warning: ‘ret’ may be
> used uninitialized in this function
> 
>> +
>> +       /* Release the host during interrupts so we can pick it back up when
>> +        * we process commands.
>> +        */
>> +       sdio_release_host(ar_sdio->func);
>> +
>> +       timeout = jiffies + ATH10K_SDIO_HIF_COMMUNICATION_TIMEOUT_HZ;
> 
> Same here.
> 
> Should ret be preinitialized to 0, -ECANCELED, or something else?
> 
ret = 0 or ret = -ECANCELED, will result in no warning message.
-ETIMEDOUT could be used perhaps.

Note that the function is a void function so the error will not get
propagated.

I am fine with ret = 0 in this case as well.
>> +       while (time_before(jiffies, timeout) && !done) {
>> +               ret = ath10k_sdio_mbox_proc_pending_irqs(ar, &done);
>> +               if (ret)
>> +                       break;
>> +       }
>> +
>> +       sdio_claim_host(ar_sdio->func);
>> +
>> +       wake_up(&ar_sdio->irq_wq);
>> +
>> +       if (ret && ret != -ECANCELED)
>> +               ath10k_warn(ar, "failed to process pending SDIO interrupts: %d\n",
>> +                           ret);
>> +}
> 
> Gr{oetje,eeting}s,
> 
>                          Geert
> 
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org
> 
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                  -- Linus Torvalds
> 
