From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] net: Fix potential NULL pointer dereference in __skb_try_recv_datagram
Date: Mon, 04 Jan 2016 16:14:00 +0000
Message-ID: <87wprptj93.fsf@doppelsaurus.mobileactivedefense.com>
References: <1451416224-15871-1-git-send-email-jacob@teenage.engineering>
	<87y4cdyrbn.fsf@doppelsaurus.mobileactivedefense.com>
	<20151229.150843.2021692616139434395.davem@davemloft.net>
	<CAEnXRPtJBoOn+JgXDEUdL07WkbYVViAT_+LBiV4X=NVQ3SiDaQ@mail.gmail.com>
	<CANn89iLpuz4nP+hPoGUHY8KSv=GwSE1x13D3qDeAQDJjV-S7pw@mail.gmail.com>
	<CAEnXRPsVe5ROz=Vo0fTODrs3EsEWoU1hzHVvyEwMyMCrE3BwDA@mail.gmail.com>
	<CAM_iQpVQNPQ1LNvG+h3=UvTM9Lm-adhryQk-ad4aeckHS-V0ew@mail.gmail.com>
	<CAEnXRPsH-eTwwd7FvODL+0Qu9CLY-uGYT9z81cH-by5baEdbhg@mail.gmail.com>
	<1451921108.8255.74.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jacob Siverskog <jacob@teenage.engineering>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Al Viro <viro@zeniv.linux.org.uk>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451921108.8255.74.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Mon, 04 Jan 2016 10:25:08 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> writes:
> On Mon, 2016-01-04 at 10:10 +0100, Jacob Siverskog wrote:

[...]

>> I believe the crash occurred between these two actions. I just saw
>> that there are some interesting events in the log prior to the crash:
>> kernel: Bluetooth: Unable to push skb to HCI core(-6)
>> kernel: (stc):  proto stack 4's ->recv failed
>> kernel: (stc): remove_channel_from_table: id 3
>> kernel: (stc): remove_channel_from_table: id 2
>> kernel: (stc): remove_channel_from_table: id 4
>> kernel: (stc):  all chnl_ids unregistered
>> kernel: (stk) :ldisc_install = 0(stc): st_tty_close
>> 
>> The first print is from btwilink.c. However, I can't see the
>> connection between Bluetooth (BLE) and UDP/IPv6 (we're not using
>> 6LoWPAN or anything similar).
>> 
>> Thanks, Jacob
>
> Definitely these details are useful ;)
>
> Could you try :
>
> diff --git a/drivers/misc/ti-st/st_core.c b/drivers/misc/ti-st/st_core.c
> index 6e3af8b42cdd..0c99a74fb895 100644
> --- a/drivers/misc/ti-st/st_core.c
> +++ b/drivers/misc/ti-st/st_core.c
> @@ -912,7 +912,9 @@ void st_core_exit(struct st_data_s *st_gdata)
>  		skb_queue_purge(&st_gdata->txq);
>  		skb_queue_purge(&st_gdata->tx_waitq);
>  		kfree_skb(st_gdata->rx_skb);
> +		st_gdata->rx_skb = NULL;
>  		kfree_skb(st_gdata->tx_skb);
> +		st_gdata->tx_skb = NULL;
>  		/* TTY ldisc cleanup */
>  		err = tty_unregister_ldisc(N_TI_WL);
>  		if (err)

Hmm ... the code continues with

		err = tty_unregister_ldisc(N_TI_WL);
		if (err)
			pr_err("unable to un-register ldisc %ld", err);
		/* free the global data pointer */
		kfree(st_gdata);

So who would ever see that the rx_skb and tx_skb pointers were cleared
prior to freeing the data structure containing them?
