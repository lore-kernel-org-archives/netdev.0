From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: DSA mv88e6xxx RX frame errors and TCP/IP RX failure
Date: Thu, 31 Aug 2017 03:46:24 +0200
Message-ID: <20170831014624.GA18554@lunn.ch>
References: <CAJ+vNU0VzgDkH-ksHgaA0cn3nbCOfcUs_BU90v6xw_QappssgA@mail.gmail.com>
 <20170830220631.GM22289@lunn.ch>
 <CAJ+vNU3Qto9iNdCUExb4NWaa3PA1UWe1kbY1b=sBLPgw_xiz7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Fugang Duan <fugang.duan@nxp.com>
To: Tim Harvey <tharvey@gateworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAJ+vNU3Qto9iNdCUExb4NWaa3PA1UWe1kbY1b=sBLPgw_xiz7g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >                        /* Report late collisions as a frame error. */
> >                         if (status & (BD_ENET_RX_NO | BD_ENET_RX_CL))
> >                                 ndev->stats.rx_frame_errors++;
> >
> > I don't see anywhere else frame errors are counted, but it would be
> > good to prove we are looking in the right place.
> >
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

I did fix an issue recently with that. See 

commit fbbeefdd21049fcf9437c809da3828b210577f36
Author: Andrew Lunn <andrew@lunn.ch>
Date:   Sun Jul 30 19:36:05 2017 +0200

    net: fec: Allow reception of frames bigger than 1522 bytes
    
    The FEC Receive Control Register has a 14 bit field indicating the
    longest frame that may be received. It is being set to 1522. Frames
    longer than this are discarded, but counted as being in error.
    
    When using DSA, frames from the switch has an additional header,
    either 4 or 8 bytes if a Marvell switch is used. Thus a full MTU frame
    of 1522 bytes received by the switch on a port becomes 1530 bytes when
    passed to the host via the FEC interface.
    
    Change the maximum receive size to 2048 - 64, where 64 is the maximum
    rx_alignment applied on the receive buffer for AVB capable FEC
    cores. Use this value also for the maximum receive buffer size. The
    driver is already allocating a receive SKB of 2048 bytes, so this
    change should not have any significant effects.
    
    Tested on imx51, imx6, vf610.
    
    Signed-off-by: Andrew Lunn <andrew@lunn.ch>
    Signed-off-by: David S. Miller <davem@davemloft.net>


However, this is was of an all/nothing problem. All frames with the
full MTU were getting dropped, where as i think you are only seeing a
few dropped?

Anyway, try cherry picking that patch and see if it helps.

	Andrew
