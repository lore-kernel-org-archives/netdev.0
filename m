From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: net/can: use-after-free in bcm_rx_thr_flush
Date: Tue, 22 Nov 2016 18:29:30 +0100
Message-ID: <5abd6ebd-1249-71a9-da30-65d8371a2a36@hartkopp.net>
References: <CAAeHK+xhwpVO=xHqEOyP-Tm6cx1+jDLDpYT0hpMwM2PCf7W3Jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+xhwpVO=xHqEOyP-Tm6cx1+jDLDpYT0hpMwM2PCf7W3Jw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrey,

thanks for the report.

Although I can't see the issue in the code ...

On 11/22/2016 10:22 AM, Andrey Konovalov wrote:

> ==================================================================
> BUG: KASAN: use-after-free in bcm_rx_thr_flush+0x284/0x2b0
> Read of size 1 at addr ffff88006c1faae5 by task a.out/3874
>
> page:ffffea0001b07e80 count:1 mapcount:0 mapping:          (null) index:0x0
> flags: 0x100000000000080(slab)
> page dumped because: kasan: bad access detected

(..)

>
> The buggy address belongs to the object at ffff88006c1faae0
>  which belongs to the cache kmalloc-32 of size 32

???

> The buggy address ffff88006c1faae5 is located 5 bytes inside
>  of 32-byte region [ffff88006c1faae0, ffff88006c1fab00)

(..)

> Memory state around the buggy address:
>  ffff88006c1fa980: fc fc fb fb fb fb fc fc fb fb fb fb fc fc fb fb
>  ffff88006c1faa00: fb fb fc fc fb fb fb fb fc fc fb fb fb fb fc fc
>> ffff88006c1faa80: fb fb fb fb fc fc fb fb fb fb fc fc fb fb fb fb
>                                                        ^
>  ffff88006c1fab00: fc fc fb fb fb fb fc fc 00 00 00 00 fc fc 00 00
>  ffff88006c1fab80: 00 00 fc fc fb fb fb fb fc fc fb fb fb fb fc fc
> ==================================================================

(should be some zero initialized memory here)

The relevant code of bcm_rx_do_flush() can be found here:

http://lxr.free-electrons.com/source/net/can/bcm.c#L589

static inline int bcm_rx_do_flush(struct bcm_op *op, int update,
				  unsigned int index)
{
	struct canfd_frame *lcf = op->last_frames + op->cfsiz * index;

	if ((op->last_frames) && (lcf->flags & RX_THR)) {  <<<----- !!!
		if (update)
			bcm_rx_changed(op, lcf);
		return 1;
	}
	return 0;
}


lcf->flags points into an array of struct canfd_frame at offset 5 which 
is allocated here:

http://lxr.free-electrons.com/source/net/can/bcm.c#L1105

	/* create and init array for received CAN frames */
	op->last_frames = kzalloc(msg_head->nframes * op->cfsiz,
				  GFP_KERNEL);

So why does KASAN complain about accessing some kind of 32 byte cache 
when it should point into a zero initialized allocated space?

I will write some other test cases with a similar setting of options to 
check if I can trigger the instability too.

Tnx & regards,
Oliver
