From: Ilia Mirkin <imirkin@alum.mit.edu>
Subject: Re: DSA mv88e6xxx RX frame errors and TCP/IP RX failure
Date: Wed, 30 Aug 2017 20:38:39 -0400
Message-ID: <CAKb7UvhZ5Sft9wbfOSDN4RJkwRp-fvhcmadZZ+=oAtaLcFMV8Q@mail.gmail.com>
References: <CAJ+vNU0VzgDkH-ksHgaA0cn3nbCOfcUs_BU90v6xw_QappssgA@mail.gmail.com>
 <20170830220631.GM22289@lunn.ch> <CAJ+vNU3Qto9iNdCUExb4NWaa3PA1UWe1kbY1b=sBLPgw_xiz7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Fugang Duan <fugang.duan@nxp.com>
To: Tim Harvey <tharvey@gateworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJ+vNU3Qto9iNdCUExb4NWaa3PA1UWe1kbY1b=sBLPgw_xiz7g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 30, 2017 at 8:22 PM, Tim Harvey <tharvey@gateworks.com> wrote:
> On Wed, Aug 30, 2017 at 3:06 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>> On Wed, Aug 30, 2017 at 12:53:56PM -0700, Tim Harvey wrote:
>>> Greetings,
>>>
>>> I'm seeing RX frame errors when using the mv88e6xxx DSA driver on
>>> 4.13-rc7. The board I'm using is a GW5904 [1] which has an IMX6 FEC
>>> MAC (eth0) connected via RGMII to a MV88E6176 with its downstream
>>> P0/P1/P2/P3 to front panel RJ45's (lan1-lan4).
>>
>> Hi Tim
>>
>> Can you confirm the counter is this one:
>>
>>                        /* Report late collisions as a frame error. */
>>                         if (status & (BD_ENET_RX_NO | BD_ENET_RX_CL))
>>                                 ndev->stats.rx_frame_errors++;
>>
>> I don't see anywhere else frame errors are counted, but it would be
>> good to prove we are looking in the right place.
>>
>
> Andrew,
>
> (adding IMX FEC driver maintainer to CC)
>
> Yes, that's one of them being hit. It looks like ifconfig reports
> 'frame' as the accumulation of a few stats so here are some more
> specifics from /sys/class/net/eth0/statistics:
>
> root@xenial:/sys/devices/soc0/soc/2100000.aips-bus/2188000.ethernet/net/eth0/statistics#
> for i in `ls rx_*`; do echo $i:$(cat $i); done
> rx_bytes:103229
> rx_compressed:0
> rx_crc_errors:22
> rx_dropped:0
> rx_errors:22
> rx_fifo_errors:0
> rx_frame_errors:22
> rx_length_errors:22
> rx_missed_errors:0
> rx_nohandler:0
> rx_over_errors:0
> rx_packets:1174
> root@xenial:/sys/devices/soc0/soc/2100000.aips-bus/2188000.ethernet/net/eth0/statistics#
> ifconfig eth0
> eth0      Link encap:Ethernet  HWaddr 00:D0:12:41:F3:E7
>           inet6 addr: fe80::2d0:12ff:fe41:f3e7/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:1207 errors:22 dropped:0 overruns:0 frame:66
>           TX packets:42 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:106009 (103.5 KiB)  TX bytes:4604 (4.4 KiB)
>
> Instrumenting fec driver I see the following getting hit:
>
> status & BD_ENET_RX_LG /* rx_length_errors: Frame too long */
> status & BD_ENET_RX_CR  /* rx_crc_errors: CRC Error */
> status & BD_ENET_RX_CL /* rx_frame_errors: Collision? */
>
> Is this a frame size issue where the MV88E6176 is sending frames down
> that exceed the MTU because of headers added?

Not sure if this is relevant to you, but
https://github.com/laanwj/linux-freedreno-a2xx/commit/076b6542fa27499072ec6c3a7941c8b3c79ba1fd
was necessary to fix some MTU issues on a i.MX51. Not sure if it's
upstream yet or not.

Cheers,

  -ilia
