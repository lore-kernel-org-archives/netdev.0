From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Netem Delay Normal Distribution
Date: Sun, 27 Oct 2013 12:27:42 -0700
Message-ID: <1382902062.4045.14.camel@edumazet-glaptop.roam.corp.google.com>
References: <CAJx7G_xkrVkC7HGQZogivA_6-i2Gas6aJd-sOFNMEbmq8=cS0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: anirup dutta <adutta2@uh.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:62440 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141Ab3J0T1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 15:27:43 -0400
Received: by mail-pa0-f53.google.com with SMTP id kx10so3498077pab.26
        for <netdev@vger.kernel.org>; Sun, 27 Oct 2013 12:27:43 -0700 (PDT)
In-Reply-To: <CAJx7G_xkrVkC7HGQZogivA_6-i2Gas6aJd-sOFNMEbmq8=cS0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-10-26 at 21:31 -0500, anirup dutta wrote:
> Hello,
> 
> I try this on my device
> 
> sudo tc qdisc del dev eth0 root netem delay 100ms 20ms distribution normal
> 
> I use iperf for transmitting UDP packets and I modified its code to
> get per packet delay. When I plot the distribution of delays and
> analyze the delays they pass the normality tests.
> 
> The only problem that I am not able to understand is that the mean of
> those delays shift to 125ms. Its not only me. There was another study
> and it observed the same thing.
> 
> http://www.researchgate.net/publication/224256550_An_Empirical_Study_of_NetEm_Network_Emulation_Functionalities/file/d912f5058c9b1e409b.pdf
> 
> Figure 7
> 
> I found out that this command is valid
> 
> sudo tc qdisc del dev eth0 root netem delay 1ms 20ms distribution normal
> 
> So I have a feeling that mean gets shifted from the base delay to
> avoid negative delay values.
> 
> It would be great if someone can confirm how it is implemented?

What version of linux are you running exactly ? We had many fixes in
netem...

Here are my results running latest net-next tree. I see no problem for
the mean, but for the min/max (range of the variation)

Omitting "distribution normal" gets expected results :

lpq83:~# tc qd del dev eth0 root
lpq83:~# tc qdisc add dev eth0 root netem delay 100ms 20ms                    
lpq83:~# ping -i 0.1 -q -c 100 lpq84
100 packets transmitted, 100 received, 0% packet loss, time 19721ms
rtt min/avg/max/mdev = 80.504/100.383/120.106/11.534 ms, pipe 2

But using "distribution normal" impacts the min/max :

lpq83:~# tc qd del dev eth0 root
lpq83:~# tc qdisc add dev eth0 root netem delay 10ms 2ms distribution normal
lpq83:~# ping -i 0.1 -q -c 100 lpq84
100 packets transmitted, 100 received, 0% packet loss, time 9963ms
rtt min/avg/max/mdev = 4.829/10.214/13.973/1.988 ms


lpq83:~# tc qd del dev eth0 root
lpq83:~# tc qdisc add dev eth0 root netem delay 100ms 20ms distribution normal
lpq83:~# ping -i 0.1 -q -c 100 lpq84
100 packets transmitted, 100 received, 0% packet loss, time 19166ms
rtt min/avg/max/mdev = 46.137/100.035/159.869/21.136 ms, pipe 2

So the mean seems OK, but the min/max seems scaled by a 2 factor.

NETEM_DIST_SCALE seems to be 8192 in the kernel, but the tc injects
distribution tables with s16 integers, in the -32768 .. 32768 range

Stephen, do you have an idea of what is wrong 
(the distribution files in /usr/lib/tc or the kernel )?

Relevant code in tabledist() is :

        t = dist->table[rnd % dist->size];
        x = (sigma % NETEM_DIST_SCALE) * t;
        if (x >= 0)
                x += NETEM_DIST_SCALE/2;
        else
                x -= NETEM_DIST_SCALE/2;

        return  x / NETEM_DIST_SCALE + (sigma / NETEM_DIST_SCALE) * t + mu;


root@edumazet-glaptop:/usr/lib/tc# head -n 4 /usr/lib/tc/normal.dist 
# This is the distribution table for the normal distribution.
 -32768 -28307 -26871 -25967 -25298 -24765 -24320 -23937
 -23600 -23298 -23025 -22776 -22546 -22333 -22133 -21946
 -21770 -21604 -21445 -21295 -21151 -21013 -20882 -20755

root@edumazet-glaptop:/usr/lib/tc# tail -n 4 /usr/lib/tc/normal.dist 
 19816 19911 20009 20109 20213 20319 20430 20544
 20663 20786 20914 21047 21186 21331 21484 21644
 21813 21991 22181 22384 22601 22836 23091 23370
 23679 24027 24424 24888 25450 26164 27159 28858
