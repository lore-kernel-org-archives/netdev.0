From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: Regression introduced by "net: ipconfig: Support using "delayed"
 DHCP replies"
Date: Tue, 9 Aug 2016 14:30:40 +0200
Message-ID: <CAMuHMdVuvKLGj2YdbwRZhvrM9QRCHyLMGSeK-wRa+QchEQekyA@mail.gmail.com>
References: <CAMuHMdVjugL0y-C+vet=qbcER8rjuFKwFgrutRUAs=uOk0JZ1A@mail.gmail.com>
 <20160809101819.GL17139@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20160809101819.GL17139@pengutronix.de>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Uwe,

On Tue, Aug 9, 2016 at 12:18 PM, Uwe Kleine-König
<u.kleine-koenig@pengutronix.de> wrote:
> On Tue, Aug 09, 2016 at 12:02:44PM +0200, Geert Uytterhoeven wrote:
>> On current net-next, I see the following corruption during DHCP on
>> r8a7791/koelsch, which uses the sh_eth driver:
>>
>>      Sending DHCP requests ., OK
>>      IP-Config: Got DHCP answer from 192.168.97.254, my address is 192.168.97.28
>>      IP-Config: Complete:
>> -         device=eth0, hwaddr=2e:09:0a:00:6d:85, ipaddr=192.168.97.28,
>> mask=255.255.255.0, gw=192.168.97.254
>> +         device=^M\xffffffc0\xffffffa0\xffffffe1,
>> hwaddr=0e:9e:45:ac:dd:b4:3a:88:95:e1:50:af:0c:44:92:c0:6c:46:9f:02:34:1e:58:21:cd:c3:40:0c:ed:80:b1:74:10:0c:04:31:06:9f:04:01:04:93:5c:51:83:18:46:09,
>> ipaddr=192.168.97.28, mask=255.255.255.0, gw=192.168.97.254
>
> I fail to see the reason from looking at the patch.
>
> Is this reproducible?

Yes, it is reproducible.

> Can you please enable pr_debug output and provide the corresponding output?

Aha, enabling DEBUG made the issue go away, but only once.
So there must be some race condition.

Adding more debug code, to show what ic_dev contains:

    IP-Config: ee052000/eth0 UP (able=1, xid=22d7167b)
    IP-Config: ee04f800/usb0 UP (able=1, xid=3a2ba2e5)
    DHCP: Sending message type 1 (eth0)
    DHCP: Got message type 2 (eth0)
    DHCP: Offered address 192.168.97.28 by server 192.168.97.254

    DHCP/BOOTP: Got extension ...

    ic_bootp_recv:1162: ic_dev: device not set -> ee198dc0->eea51800/eth0
(means: ic_device at 0xee198dc0, dev points to 0xeea51800 with name eth0)

    DHCP: Sending message type 3 (eth0)
    DHCP: Got message type 5 (eth0)

    DHCP/BOOTP: Got extension ...

    ic_bootp_recv:1162: ic_dev: device ee198dc0->eea51800/eth0 ->
ee198dc0->eea51800/eth0

    IP-Config: Complete:
    ip_auto_config:1556: ic_dev =
ee198dc0->c05aaa44/^M\xffffffc0\xffffffa0\xffffffe1

ic_dev->dev no longer points to eth0, but to a piece of the kernel.
System.map says:

    c05aaa44 t __node_free_rcu

Perhaps ic_dev has been freed already?

Adding more debug code shows that ic_close_devs() frees the ic_device
that is in use, before IP Config is complete:

    ic_close_devs:338
    ic_close_devs:348: kfree(ee198dc0)
                             ^^^^^^^^
    IP-Config: Downing eea56000/usb0
    ic_close_devs:348: kfree(edff0240)
    ic_close_devs:352

> What is your kernel command line?

earlyprintk ignore_loglevel ip=dhcp root=/dev/nfs
nfsroot=192.168.97.21:/home/koelsch/debian-armhf

> Are there >1 eth devices?

The board has a single Ethernet interface.
However, enabling DEBUG showed ipconfig also uses usb0.

> I will try to reproduce and fix later today.
>
>> It may also crash in ip_auto_config() with e.g. "Unable to handle kernel NULL
>> pointer dereference at virtual address 0000017d".
>>
>> I've bisected this to commit 2647cffb2bc6fbed163d377390eb7ca552c7c1cb
>> ('net: ipconfig: Support using "delayed" DHCP replies').
>> Unfortunately just reverting that commit on current net-next is not a
>> solution, as
>> that may lead to DHCP failures:
>>
>>     DHCP/BOOTP: Ignoring delayed packet
>>     timed out!
>>     [...]
>>     IP-Config: Retrying forever (NFS root)...
>>
>> Reverting also commit e068853409aa1720 ("net: ipconfig: drop inter-device
>> timeout") fixes that, though.
>
> That's not surprising. e068853409aa1720 was only possible because of
> 2647cffb2bc6fbed163d377390eb7ca552c7c1cb.

Sure, just pointing that out in case David wants to fix the regression by
reverting.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
