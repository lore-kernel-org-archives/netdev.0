From: Jagan Teki <jagannadh.teki@gmail.com>
Subject: Re: sblk->status_tag on drivers/net/ethernet/broadcom/tg3.c
Date: Tue, 4 Mar 2014 23:10:59 +0530
Message-ID: <CAD6G_RSiT3CmuDR_fJny+NsfO=GT8pH=NB16Zmp1KUGUk3XiwQ@mail.gmail.com>
References: <CAD6G_RQVD7=v7b6S-muiZBYV7PEykTHOTM23i-BL=wcA5z=4Qg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:41094 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751282AbaCDRk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 12:40:59 -0500
Received: by mail-yk0-f171.google.com with SMTP id q9so15050956ykb.2
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 09:40:59 -0800 (PST)
In-Reply-To: <CAD6G_RQVD7=v7b6S-muiZBYV7PEykTHOTM23i-BL=wcA5z=4Qg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Accidental sent please ignore this it's incomplete

On Tue, Mar 4, 2014 at 11:09 PM, Jagan Teki <jagannadh.teki@gmail.com> wrote:
> Hi All,
>
> I have a board setup with PCIe host bridge links to BCRM NIC/tg3 EP.
>
> I'm verifying legacy INT# for ifconfig up operation, typically for
> link up EP trigger an interrupt as
> Assert_INT# and PCIe RC driver ISR will called and then EP ISR will
> clear and send Dessert_INT#
>
> But I got the continues interrupts from EP which will keep ISR's in
> both PCIe RC and EP in busy loop.
>
> Log dump:
> # ifconfig eth0 172.16.0.2 up
> RC: handler
> tg3_interrupt_tagged: write status = 0x1
> RC: handler
> tg3_interrupt_tagged: write status = 0x1
> RC: handler
> tg3_interrupt_tagged: write status = 0x1
> RC: handler
> tg3_interrupt_tagged: write status = 0x1
> ............................
> ..............
>
> I debugged further on to EP driver where I could see there is
> interrupt re-enabling is happining
> by writing 0x0 to onto MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW
>
> Debug code:
> static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
> {
>       ...................
>       printk(" ++status_tag = 0x%x", sblk->status_tag);
>       .......................
>
>       tw32_mailbox_f(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
>       printk(" write status = 0x%x", tr32(MAILBOX_INTERRUPT_0 +
> TG3_64BIT_REG_LOW));
>       ..................
>       tnapi->last_irq_tag = sblk->status_tag;
>       printk(" --status_tag = 0x%x\n", tnapi->last_irq_tag);
> }
>
> static int tg3_poll(struct napi_struct *napi, int budget)
> {
>
>                if (tg3_flag(tp, TAGGED_STATUS)) {
>                         /* tp->last_tag is used in tg3_int_reenable() below
>                          * to tell the hw how much work has been processed,
>                          * so we must read it before checking for more work.
>                          */
>                         tnapi->last_tag = sblk->status_tag;
>                         tnapi->last_irq_tag = tnapi->last_tag;
>                         rmb();
>                 } else
>                         sblk->status &= ~SD_STATUS_UPDATED;
>
>                 printk(" tag = 0x%x\n", sblk->status_tag);
>                 if (likely(!tg3_has_work(tnapi))) {
>                         napi_complete(napi);
>                         printk("calling tg3_int_reenable\n");
>                         tg3_int_reenable(tnapi);
>                         break;
>               }
> }
>
> static void tg3_int_reenable(struct tg3_napi *tnapi)
> {
>         struct tg3 *tp = tnapi->tp;
>
>         printk("%s val = 0x%x\n", __func__, tnapi->last_tag << 24);
>         tw32_mailbox(tnapi->int_mbox, tnapi->last_tag << 24);
>         ..............................
> }
>
> Log dump:
>
> # ifconfig eth0 172.16.0.2 up
> RC: handler
> tg3_interrupt_tagged: ++status_tag = 0x0 write status = 0x1 --status_tag = 0x0
> RC: handler
> tg3_interrupt_tagged: write status = 0x1
> RC: handler
> tg3_interrupt_tagged: write status = 0x1
> RC: handler
> tg3_interrupt_tagged: write status = 0x1
> ............................
> ..............
>
>
>
>
>
>
>
>
> thanks!
> --
> Jagan.



-- 
Jagan.
