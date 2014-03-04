From: Jagan Teki <jagannadh.teki@gmail.com>
Subject: Re: sblk->status_tag on drivers/net/ethernet/broadcom/tg3.c
Date: Tue, 4 Mar 2014 23:25:15 +0530
Message-ID: <CAD6G_RQ130TunwZDL+8vwx__8NsfzE0AfcfnS7z5OXtZF5T8xQ@mail.gmail.com>
References: <CAD6G_RQVD7=v7b6S-muiZBYV7PEykTHOTM23i-BL=wcA5z=4Qg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>
To: netdev@vger.kernel.org,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAD6G_RQVD7=v7b6S-muiZBYV7PEykTHOTM23i-BL=wcA5z=4Qg@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

I have a board setup with PCIe host bridge links to BCRM NIC/tg3 EP.

I'm verifying legacy INT# for ifconfig up operation, typically for
link up EP trigger an interrupt as Assert_INT# and PCIe RC driver
ISR will called and then EP ISR will clear and send Dessert_INT#

But I got the continues interrupts from EP which will keep ISR's in
both PCIe RC and EP in busy loop.

Log dump:
# ifconfig eth0 172.16.0.2 up
RC: handler
tg3_interrupt_tagged: write status = 0x1
RC: handler
tg3_interrupt_tagged: write status = 0x1
RC: handler
tg3_interrupt_tagged: write status = 0x1
RC: handler
tg3_interrupt_tagged: write status = 0x1
............................
..............

I debugged further on EP driver where I could see interrupt
re-enabling is happening continuously by writing 0x0 to onto
MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW

Debug code:
static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
{
      ...................
      printk(" ++status_tag = 0x%x", sblk->status_tag);
      .......................

      tw32_mailbox_f(MAILBOX_
INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
      printk(" write status = 0x%x", tr32(MAILBOX_INTERRUPT_0 +
TG3_64BIT_REG_LOW));
      ..................
      tnapi->last_irq_tag = sblk->status_tag;
      printk(" --status_tag = 0x%x\n", tnapi->last_irq_tag);
}

static int tg3_poll(struct napi_struct *napi, int budget)
{
               printk("%s: ", __func__);
               if (tg3_flag(tp, TAGGED_STATUS)) {
                        /* tp->last_tag is used in tg3_int_reenable() below
                         * to tell the hw how much work has been processed,
                         * so we must read it before checking for more work.
                         */
                        tnapi->last_tag = sblk->status_tag;
                        tnapi->last_irq_tag = tnapi->last_tag;
                        rmb();
                } else
                        sblk->status &= ~SD_STATUS_UPDATED;

                printk(" tag = 0x%x\n", sblk->status_tag);
                if (likely(!tg3_has_work(tnapi))) {
                        napi_complete(napi);
                        printk("calling tg3_int_reenable\n");
                        tg3_int_reenable(tnapi);
                        break;
              }
}

static void tg3_int_reenable(struct tg3_napi *tnapi)
{
        struct tg3 *tp = tnapi->tp;

        printk("%s val = 0x%x\n", __func__, tnapi->last_tag << 24);
        tw32_mailbox(tnapi->int_mbox, tnapi->last_tag << 24);
        ..............................
}

Log dump:
# ifconfig eth0 172.16.0.2 up
RC: handler
tg3_interrupt_tagged: ++status_tag = 0x0 write status = 0x1
--status_tag = 0x0 tg3_poll: tag = 0x0 calling tg3_int_reenable val =
0x0
RC: handler
tg3_interrupt_tagged: ++status_tag = 0x0 write status = 0x1
--status_tag = 0x0 tg3_poll: tag = 0x0 calling tg3_int_reenable val =
0x0
RC: handler
tg3_interrupt_tagged: ++status_tag = 0x0 write status = 0x1
--status_tag = 0x0 tg3_poll: tag = 0x0 calling tg3_int_reenable val =
0x0
RC: handler
tg3_interrupt_tagged: ++status_tag = 0x0 write status = 0x1
--status_tag = 0x0 tg3_poll: tag = 0x0 calling tg3_int_reenable val =
0x0
............................
..............

>From the comments in ISR any non-zero value to intr-mbox-0 clear
the interrupt ie write status as 1 so I assume interrupt is clear and then
in tg3_int_reenable is going to write 0x0 on to intr-mbox-0
which again reenables the interrupt, was my guess is true?

And sblk->status_tag is always 0 in ISR and BH(poll) why is that so?
If it's is 1(unsigned non-zero) then possibly tg3_int_reenable will write
non-zero value on intr-mbox-0 which will clear the interrupt.

Request for any help who updates sblk->status_tag value and
how many time the ISR in PCIe RC and ISR in EP will call for link up?

thanks!
--
Jagan.
