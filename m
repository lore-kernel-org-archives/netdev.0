From: Tomeu Vizoso <tomeu@tomeuvizoso.net>
Subject: Re: [linux-next] oops in ip_route_input_noref
Date: Thu, 17 Sep 2015 09:26:47 +0200
Message-ID: <CAAObsKDpLXfDSV=WBtbR-7PgheP5ujVBUbMajTcY1O8LjmSajA@mail.gmail.com>
References: <20150916092447.GA945@swordfish> <55F9578C.40209@ericsson.com>
 <55F9699E.5080807@cumulusnetworks.com> <20150916234738.GA592@swordfish>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Ahern <dsa@cumulusnetworks.com>,
	Richard Alpe <richard.alpe@ericsson.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37180 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753153AbbIQH1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 03:27:10 -0400
Received: by wicfx3 with SMTP id fx3so14956388wic.0
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 00:27:08 -0700 (PDT)
In-Reply-To: <20150916234738.GA592@swordfish>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17 September 2015 at 01:47, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> On (09/16/15 07:07), David Ahern wrote:
>> Hi Sergey:
>>
>
> Hi,
>
> sorry for long reply. Baremetal. So grabbing the backtrace is
> a bit complicated. But it looks very close to what Richard Alpe
> has posted.

Hi,

in this boot log you will find a backtrace:
https://lava.collabora.co.uk/scheduler/job/67404/log_file

(ip_route_input_noref) from [] (ip_rcv+0x39c/0x6e8)
(ip_rcv) from [] (__netif_receive_skb_core+0x5ec/0x7c0)
(__netif_receive_skb_core) from [] (netif_receive_skb_internal+0x34/0xa4)
(netif_receive_skb_internal) from [] (napi_gro_receive+0x78/0xa4)
(napi_gro_receive) from [] (rtl8169_poll+0x2dc/0x5dc)
(rtl8169_poll) from [] (net_rx_action+0x1d4/0x2d0)
(net_rx_action) from [] (__do_softirq+0xfc/0x214)
(__do_softirq) from [] (irq_exit+0xb0/0x118)
(irq_exit) from [] (__handle_domain_irq+0x60/0xb4)
(__handle_domain_irq) from [] (gic_handle_irq+0x54/0x94)
(gic_handle_irq) from [] (__irq_svc+0x54/0x70)

This is on a jetson-tk1 booting a multi_v7_defconfig kernel.

I expect this issue to appear in today's kernelci.org boots.

I don't see this or any other boot error after applying David's patch.

Regards,

Tomeu

> in IRQ
>
> RIP is at ip_route_input_noref
>
> [    0.877597]  [<ffffffff8158e13c>] arp_process+0x39c/0x690
> [    0.877597]  [<ffffffff8158e57e>] arp_rcv+0x13e/0x170
>
>
>         -ss
>
>
>> Is this with KVM or baremetal?
>>
>> -----8<-----
>> thanks for the analysis
>>
>> >>addr2line -e vmlinux -i 0xffffffff8146c0b1
>> >>net/ipv4/route.c:1815
>> >>net/ipv4/route.c:1905
>> >>
>> >>
>> >>which seems to be this line ip_route_input_noref()->ip_route_input_slow():
>> >>...
>> >>1813         rth->rt_is_input = 1;
>> >>1814         if (res.table)
>> >>1815                 rth->rt_table_id = res.table->tb_id;
>> >>1816
>> >>...
>> >>
>> >>
>> >>added by b7503e0cdb5dbec5d201aa69d8888c14679b5ae8
>> >>
>> >>     net: Add FIB table id to rtable
>> >>
>> >>     Add the FIB table id to rtable to make the information available for
>> >>     IPv4 as it is for IPv6.
>> >>
>> >>
>> >>    -ss
>>
>> Hi Richard:
>>
>> >I to get an Oops in ip_route_input_noref(). It happens occasionally during bootup.
>> >KVM environment using virtio driver. Let me know if you need any additional info or
>> >if you want me to try to bisect it.
>> >
>> >Starting network...
>> >...
>> >[    0.877040] BUG: unable to handle kernel NULL pointer dereference at 0000000000000056
>> >[    0.877597] IP: [<ffffffff8155b5e2>] ip_route_input_noref+0x1a2/0xb00
>>
>> Can you send me your kernel config and qemu command line? KVM with virtio
>> networking is a primary test vehicle, and I did not encounter this at all.
>>
>> Thanks,
>> David
>>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
