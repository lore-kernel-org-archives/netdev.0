From: John Heffner <johnwheffner@gmail.com>
Subject: Re: Missing TCP SYN on loopback, retransmits after 1s
Date: Tue, 22 Nov 2011 21:06:04 -0500
Message-ID: <CABrhC0m75OHmdDD-crr=tvTiRq_hnh7WpHtLjM9TKgTa24MSOA@mail.gmail.com>
References: <20111122181320.38a70cf8@telperion.jlyo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jesse Young <jlyo@jlyo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:45225 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754746Ab1KWCGG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 21:06:06 -0500
Received: by ywt32 with SMTP id 32so856371ywt.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 18:06:05 -0800 (PST)
In-Reply-To: <20111122181320.38a70cf8@telperion.jlyo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Offhand, I'd guess you're overflowing the TCP SYN queue.  (You can try
tuning tcp_max_syn_backlog.)

  -John


On Tue, Nov 22, 2011 at 7:13 PM, Jesse Young <jlyo@jlyo.org> wrote:
> Hi all,
>
> I am experiencing packet loss over TCP/IPv[46], which causes 1 second
> delays when connect()ing to a socket. This happens even on loopback, =
and
> on multiple kernels. On the older kernels, the connect() time is near=
ly
> 3 seconds, I believe this is due to a recent TCP connect retrasmit
> parameter changed in the kernel.
>
> 1. Linux dc-s1000-2114 2.6.32-35-server #78-Ubuntu SMP Tue Oct 11
> =A0 =A016:26:12 UTC 2011 x86_64 GNU/Linux
> 2. Linux dc-a1000-2131.cleversafelabs.com 2.6.39.4-2-clevos+ #1 SMP
> =A0 =A0Tue Nov 8 09:06:49 CST 2011 x86_64 x86_64 x86_64 GNU/Linux
> 3. Linux telperion.jlyo.org 3.1.0-4-ARCH #1 SMP PREEMPT Mon Nov 7
> =A0 =A022:47:18 CET 2011 x86_64 Intel(R) Core(TM) i7-2630QM CPU @ 2.0=
0GHz
> =A0 =A0GenuineIntel GNU/Linux
>
> I have created some test cases which reify this problem, the first se=
t
> of tests use select() multiplexing, and have some problems, however,
> they exhibit odd behavior as well, especially in the difference betwe=
en
> tcp4 and tcp6.
>
> Please note: these tests will quickly exaust the amount of available
> ephemeral TCP ports on your system, which will cause any TCP connect(=
)
> calls in other processes to return with EADDRNOTAVAIL. However, ports
> will become available after a short while.
>
> The first test fails super quick, while the others haven't timed out
> so far. =A0NOTE: The second test requires /proc/sys/net/ipv6/bindv6on=
ly
> to be set to 1.
>
> ./packetloss :: ::1
> ./packetloss :: 127.0.0.1
> ./packetloss 0.0.0.0 127.0.0.1
>
> The other tests run a client and server in different processes.
> Run the "close" daemon using one of:
> ./closed ::
> ./closed 0.0.0.0
>
> And flood connect() pings against 8009, the port closed listens on.
> ./tcping -f -p8009 ::1
> ./tcping -f -p8009 127.0.0.1
>
> Wait for a pause, then ^C, and notice the max statistic is ~1000ms.
>
> These tests have been rn between machines on a relativley noiseless
> ethernet LAN with similar results.
>
> What's also puzzling, is that I see no packet drop reporting in
> $ ifconfig lo
> lo: flags=3D73<UP,LOOPBACK,RUNNING> =A0mtu 16436 =A0metric 1
> inet 127.0.0.1 =A0netmask 255.0.0.0
> inet6 ::1 =A0prefixlen 128 =A0scopeid 0x10<host>
> loop =A0txqueuelen 0 =A0(Local Loopback)
> RX packets 276411482 =A0bytes 15822880567 (14.7 GiB)
> RX errors 0 =A0dropped 0 =A0overruns 0 =A0frame 0
> TX packets 276411482 bytes 15822880567 (14.7 GiB)
> TX errors 0 dropped 0 overruns 0 carrier 0 collisions
>
> I'm thinking this may be a bug in the TCP/IP stack, however, I'm not
> certain if I'm missing a socket option, or some other configuration
> that may elimiate this behavior.
>
> If there's anything else I can help you with, please don't hesitate
> to Cc me.
>
> Thanks,
> Jesse
>
> Attached: syndrop.pcap
>
> Get the code here
> https://github.com/jlyo/packetloss
> git clone git://github.com/jlyo/packetloss.git
>
> https://github.com/jlyo/tcping
> git clone git://github.com/jlyo/tcping.git
>
> https://github.com/jlyo/closed
> git clone git://github.com/jlyo/closed.git
