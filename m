From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: Re: stmmac/RTL8211F/Meson GXBB: TX throughput problems
Date: Sat, 5 Nov 2016 13:20:19 +0100
Message-ID: <CAFBinCAUYx6NwFb2NctgiOGXzQxg2QXLUKdGoOZLEKqy-tS8zg@mail.gmail.com>
References: <CAFBinCALSL_-izJ2tEsAjevAw90kGNTrQ3na3D1YV8f1dS1=Xg@mail.gmail.com>
 <ff6f3501-fbd5-3e79-dcc1-549406a5144b@st.com> <CAFBinCD42A_SqQz8GM-H+A32dMELknAytHuJ5T2YgZ3BrMKA3A@mail.gmail.com>
 <20160917232312.1e30d425@gmail.com> <d59f6e2c-15ff-779d-da2f-8eb5f5a535a6@st.com>
 <CAFBinCD_-KjVa70iOhBSGaXZc9uKy2m4d2yVr-AfLiV7F=3EqQ@mail.gmail.com> <1478190980.6632.26.camel@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Johnson Leung <r58129@freescale.com>, netdev@vger.kernel.org,
        =?UTF-8?Q?Andr=C3=A9_Roth?= <neolynx@gmail.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        linux-amlogic@lists.infradead.org, ganbold@freebsd.org,
        yongari@freebsd.org
To: Jerome Brunet <jbrunet@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37320 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754523AbcKEMUl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Nov 2016 08:20:41 -0400
Received: by mail-wm0-f53.google.com with SMTP id t79so95997812wmt.0
        for <netdev@vger.kernel.org>; Sat, 05 Nov 2016 05:20:40 -0700 (PDT)
In-Reply-To: <1478190980.6632.26.camel@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 3, 2016 at 5:36 PM, Jerome Brunet <jbrunet@baylibre.com> wrote:
> Hi all,
>
> I did several tests on this issue with amlogic's S905 SoC (Synopsys MAC
> - user ID: 0x11, Synopsys ID: 0x37.)
>
> With the OdroidC2 (PHY Realtek RTL8211F), EEE is on by default.
> Just before launching iperf3, here are the ethtool stats regarding LPI:
>      irq_tx_path_in_lpi_mode_n: 6
>      irq_tx_path_exit_lpi_mode_n: 5
>      irq_rx_path_in_lpi_mode_n: 76
>      irq_rx_path_exit_lpi_mode_n: 75
>      phy_eee_wakeup_error_n: 0
>
> Sending data with iperf usually works for little while (between 0 and
> 10s)
>
> # iperf3 -c 192.168.1.170 -p12345
> Connecting to host 192.168.1.170, port 12345
> local 192.168.1.30 port 54450 connected to 192.168.1.170 port 12345
> Interval           Transfer     Bandwidth       Retr  Cwnd
> 0.00-1.00   sec   112 MBytes   938 Mbits/sec    0    409 KBytes
> 1.00-2.00   sec   112 MBytes   940 Mbits/sec    0    426 KBytes
> 2.00-3.00   sec   112 MBytes   939 Mbits/sec    0    426 KBytes
> 3.00-4.00   sec   112 MBytes   940 Mbits/sec    0    426 KBytes
> 4.00-5.00   sec   112 MBytes   940 Mbits/sec    0    426 KBytes
> 5.00-6.00   sec   112 MBytes   939 Mbits/sec    0    426 KBytes
> 6.00-7.00   sec  9.26 MBytes  77.6 Mbits/sec    2   1.41 KBytes
> 7.00-8.00   sec  0.00 Bytes  0.00 bits/sec    1   1.41 KBytes
> 8.00-9.00   sec  0.00 Bytes  0.00 bits/sec    0   1.41 KBytes
> ^C10.00-13.58  sec  0.00 Bytes  0.00 bits/sec    1   1.41 KBytes
> - - - - - - - - - - - - - - - - - - - - - - - - -
> Interval           Transfer     Bandwidth       Retr
> 0.00-13.58  sec   681 MBytes   421 Mbits/sec    4             sender
> 0.00-13.58  sec  0.00 Bytes  0.00 bits/sec                  receiver
> iperf3: interrupt - the client has terminated
>
> iperf3 does not exit ant the link seems completely broken. We cannot
> send or receive until the interface is brought down then up again.
>
> Here are the LPI related stats after the test:
>      irq_tx_path_in_lpi_mode_n: 48
>      irq_tx_path_exit_lpi_mode_n: 48
>      irq_rx_path_in_lpi_mode_n: 325
>      irq_rx_path_exit_lpi_mode_n: 325
>      phy_eee_wakeup_error_n: 0
>
> Like Martin, I tried playing around with eee in stmmac, but I could not
> improve the situation. Then I tried disabling EEE advertisement on the
> PHY (patch attached). With this patch, iperf3 runs nicely for me.
>
> This is what the folks of FreeBSD have done for the Same MAC/PHY
> combination [0]
>
> On the P200 Board (PHY Micrel KSZ9031), EEE is off by default. There is
> no problem on this board right now. I tried to force the activation of
> EEE on this board and ended up in the same situation as the OdroidC2
> (link broken). The stats were a bit different though:
>      irq_tx_path_in_lpi_mode_n: 28
>      irq_tx_path_exit_lpi_mode_n: 28
>      irq_rx_path_in_lpi_mode_n: 408
>      irq_rx_path_exit_lpi_mode_n: 408
>      phy_eee_wakeup_error_n: 5440
>
> To everybody having similar issue with their OdroidC2, could you try
> the attached patch and let us know if it changes anything for you ?
I have tried this on my Vega S95 Meta clone - the patch can be found
here if anyone cares: [0].
Unfortunately this does not improve the situation for me:
# iperf3 --client 192.168.1.100
Connecting to host 192.168.1.100, port 5201
[  4] local 192.168.1.198 port 50720 connected to 192.168.1.100 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-1.00   sec   178 KBytes  1.46 Mbits/sec   13   1.41 KBytes
[  4]   1.00-2.00   sec  0.00 Bytes  0.00 bits/sec    1   1.41 KBytes
[  4]   2.00-3.00   sec  0.00 Bytes  0.00 bits/sec    1   1.41 KBytes
[  4]   3.00-4.00   sec  5.66 KBytes  46.3 Kbits/sec    4   1.41 KBytes
[  4]   4.00-5.00   sec  63.6 KBytes   521 Kbits/sec    2   1.41 KBytes
[  4]   5.00-6.00   sec  0.00 Bytes  0.00 bits/sec    4   1.41 KBytes
[  4]   6.00-7.00   sec  0.00 Bytes  0.00 bits/sec    2   1.41 KBytes
[  4]   7.00-8.00   sec  0.00 Bytes  0.00 bits/sec    1   1.41 KBytes
[  4]   8.00-9.00   sec  0.00 Bytes  0.00 bits/sec    0   1.41 KBytes
[  4]   9.00-10.00  sec  0.00 Bytes  0.00 bits/sec    1   1.41 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-10.00  sec   247 KBytes   203 Kbits/sec   29             sender
[  4]   0.00-10.00  sec  90.5 KBytes  74.1 Kbits/sec                  receiver

iperf Done.
# iperf3 --client 192.168.1.100 -R
Connecting to host 192.168.1.100, port 5201
Reverse mode, remote host 192.168.1.100 is sending
[  4] local 192.168.1.198 port 50724 connected to 192.168.1.100 port 5201
[ ID] Interval           Transfer     Bandwidth
[  4]   0.00-1.00   sec   111 MBytes   930 Mbits/sec
[  4]   1.00-2.00   sec   111 MBytes   935 Mbits/sec
[  4]   2.00-3.00   sec   111 MBytes   934 Mbits/sec
[  4]   3.00-4.00   sec   111 MBytes   934 Mbits/sec
[  4]   4.00-5.00   sec   111 MBytes   934 Mbits/sec
[  4]   5.00-6.00   sec   111 MBytes   935 Mbits/sec
[  4]   6.00-7.00   sec   111 MBytes   935 Mbits/sec
[  4]   7.00-8.00   sec   111 MBytes   934 Mbits/sec
[  4]   8.00-9.00   sec   111 MBytes   934 Mbits/sec
[  4]   9.00-10.00  sec   111 MBytes   934 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-10.00  sec  1.09 GBytes   936 Mbits/sec    0             sender
[  4]   0.00-10.00  sec  1.09 GBytes   934 Mbits/sec                  receiver

iperf Done.
#

However, if I remove the realtek,disable-eee-* properties and use
max-speed = <100>; instead ethernet is working fine (but limited to
100Mbit/s obviously).

> Peppe, Alexandre,
> What is your view on this ? I'm not sure that removing EEE
> advertisement is the right way to address the problem ?
> Could it be an issue stmmac ?
> If there is any other information / test which would help understand
> the issue, please let me know.
I CC'ed the two FreeBSD developers to who added the corresponding
FreeBSD code. Maybe they could also explain why that change was
needed.
Peppe's and Alexandre's feedback will hopefully also lead to
improvements in the FreeBSD driver.


[0] https://paste.kde.org/p9lwilneh
