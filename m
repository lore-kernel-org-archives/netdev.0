From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Fix potential NULL pointer dereference in
 __skb_try_recv_datagram
Date: Mon, 04 Jan 2016 10:25:08 -0500
Message-ID: <1451921108.8255.74.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1451416224-15871-1-git-send-email-jacob@teenage.engineering>
	 <87y4cdyrbn.fsf@doppelsaurus.mobileactivedefense.com>
	 <20151229.150843.2021692616139434395.davem@davemloft.net>
	 <CAEnXRPtJBoOn+JgXDEUdL07WkbYVViAT_+LBiV4X=NVQ3SiDaQ@mail.gmail.com>
	 <CANn89iLpuz4nP+hPoGUHY8KSv=GwSE1x13D3qDeAQDJjV-S7pw@mail.gmail.com>
	 <CAEnXRPsVe5ROz=Vo0fTODrs3EsEWoU1hzHVvyEwMyMCrE3BwDA@mail.gmail.com>
	 <CAM_iQpVQNPQ1LNvG+h3=UvTM9Lm-adhryQk-ad4aeckHS-V0ew@mail.gmail.com>
	 <CAEnXRPsH-eTwwd7FvODL+0Qu9CLY-uGYT9z81cH-by5baEdbhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Al Viro <viro@zeniv.linux.org.uk>,
	LKML <linux-kernel@vger.kernel.org>
To: Jacob Siverskog <jacob@teenage.engineering>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEnXRPsH-eTwwd7FvODL+0Qu9CLY-uGYT9z81cH-by5baEdbhg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-01-04 at 10:10 +0100, Jacob Siverskog wrote:
> On Wed, Dec 30, 2015 at 11:30 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> > On Wed, Dec 30, 2015 at 6:30 AM, Jacob Siverskog
> > <jacob@teenage.engineering> wrote:
> >> On Wed, Dec 30, 2015 at 2:26 PM, Eric Dumazet <edumazet@google.com> wrote:
> >>> How often can you trigger this bug ?
> >>
> >> Ok. I don't have a good repro to trigger it unfortunately, I've seen it just a
> >> few times when bringing up/down network interfaces. Does the trace
> >> give any clue?
> >>
> >
> > A little bit. You need to help people to narrow down the problem
> > because there are too many places using skb->next and skb->prev.
> >
> > Since you mentioned it seems related to network interface flip,
> > what network interfaces are you using? What's is your TC setup?
> >
> > Thanks.
> 
> The system contains only one physical network interface (TI WL1837,
> wl18xx module).
> The state prior to the crash was as follows:
> - One virtual network interface active (as STA, associated with access point)
> - Bluetooth (BLE only) active (same physical chip, co-existence,
> btwilink/st_drv modules)
> 
> Actions made around the time of the crash:
> - Bluetooth disabled
> - One additional virtual network interface brought up (also as STA)
> 
> I believe the crash occurred between these two actions. I just saw
> that there are some interesting events in the log prior to the crash:
> kernel: Bluetooth: Unable to push skb to HCI core(-6)
> kernel: (stc):  proto stack 4's ->recv failed
> kernel: (stc): remove_channel_from_table: id 3
> kernel: (stc): remove_channel_from_table: id 2
> kernel: (stc): remove_channel_from_table: id 4
> kernel: (stc):  all chnl_ids unregistered
> kernel: (stk) :ldisc_install = 0(stc): st_tty_close
> 
> The first print is from btwilink.c. However, I can't see the
> connection between Bluetooth (BLE) and UDP/IPv6 (we're not using
> 6LoWPAN or anything similar).
> 
> Thanks, Jacob

Definitely these details are useful ;)

Could you try :

diff --git a/drivers/misc/ti-st/st_core.c b/drivers/misc/ti-st/st_core.c
index 6e3af8b42cdd..0c99a74fb895 100644
--- a/drivers/misc/ti-st/st_core.c
+++ b/drivers/misc/ti-st/st_core.c
@@ -912,7 +912,9 @@ void st_core_exit(struct st_data_s *st_gdata)
 		skb_queue_purge(&st_gdata->txq);
 		skb_queue_purge(&st_gdata->tx_waitq);
 		kfree_skb(st_gdata->rx_skb);
+		st_gdata->rx_skb = NULL;
 		kfree_skb(st_gdata->tx_skb);
+		st_gdata->tx_skb = NULL;
 		/* TTY ldisc cleanup */
 		err = tty_unregister_ldisc(N_TI_WL);
 		if (err)
