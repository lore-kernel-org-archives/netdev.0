From: Avery Fay <avery@mixpanel.com>
Subject: Invalid timestamp? causing tight ack loop (hundreds of thousands of
 packets / sec)
Date: Tue, 3 Feb 2015 22:50:54 -0800
Message-ID: <CAO-X30uMA7=DTm5KqqvYC5RVTM0bg9pKBO1nX1+6x_2pF_fWfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:40677 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbbBDGuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 01:50:55 -0500
Received: by mail-qg0-f52.google.com with SMTP id z107so56138794qgd.11
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 22:50:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Let me say first: if there's a better place to ask this, please point
me in that direction.

We've been having huge packets / sec spikes in the past few days.
After some investigation, it looks like single connections are getting
stuck in a loop (see tcpdump below). Each "stuck" connection will
generate about 200kpps. It looks like our side is rejecting packets
with "packets rejects in established connections because of timestamp"
from netstat -s (internally PAWSEstab counter) and then generating an
additional packet that we send out. All of these connections originate
from georgia tech, but so far (not completely verified) it doesn't
seem like there's any pattern to the client/os other than the fact
that they're trying to make an https request to us.

As a temporary countermeasure, we've disabled net.ipv4.tcp_timestamps,
which solves the immediate problem.

Our server is 174.36.240.86 running Ubuntu 12.04 with kernel 3.13.0-35-generic

The client is 128.61.57.205 and in this case almost certainly has user
agent (we found successful requests 10 seconds before the tcpdump with
same ip): Dalvik/2.1.0 (Linux; U; Android 5.0; XT1095
Build/LXE22.46-11)

Beginning of tcpdump:

05:36:10.723423 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags [S],
seq 4192140517, win 65535, options [mss 1380,sackOK,TS val 3985707 ecr
0,nop,wscale 8], length 0
05:36:10.723431 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags
[S.], seq 1191654135, ack 4192140518, win 28960, options [mss
1460,sackOK,TS val 3311875276 ecr 3985707,nop,wscale 7], length 0
05:36:10.742480 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags [.],
ack 1, win 343, options [nop,nop,TS val 3985710 ecr 3311875276],
length 0
05:36:10.742534 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags [.],
ack 1, win 343, options [nop,nop,TS val 3985710 ecr 3311875276],
length 0
05:36:10.761060 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], seq 1:227, ack 1, win 343, options [nop,nop,TS val 3985712 ecr
3311875276], length 226
05:36:10.761067 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 227, win 235, options [nop,nop,TS val 3311875285 ecr 3985712],
length 0
05:36:10.761122 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
seq 1:2737, ack 227, win 235, options [nop,nop,TS val 3311875285 ecr
3985712], length 2736
05:36:10.761129 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags
[P.], seq 2737:3256, ack 227, win 235, options [nop,nop,TS val
3311875285 ecr 3985712], length 519
05:36:10.798133 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags
[P.], seq 2737:3256, ack 227, win 235, options [nop,nop,TS val
3311875295 ecr 3985712], length 519
05:36:11.018130 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
seq 1:1369, ack 227, win 235, options [nop,nop,TS val 3311875350 ecr
3985712], length 1368
05:36:11.458134 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
seq 1:1369, ack 227, win 235, options [nop,nop,TS val 3311875460 ecr
3985712], length 1368
05:36:12.338130 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
seq 1:1369, ack 227, win 235, options [nop,nop,TS val 3311875680 ecr
3985712], length 1368
05:36:14.102128 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
seq 1:1369, ack 227, win 235, options [nop,nop,TS val 3311876121 ecr
3985712], length 1368
05:36:17.634130 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
seq 1:1369, ack 227, win 235, options [nop,nop,TS val 3311877004 ecr
3985712], length 1368
05:36:20.820850 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[F.], seq 227, ack 1, win 343, options [nop,nop,TS val 3986717 ecr
3311875285], length 0
05:36:20.820879 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags
[F.], seq 3256, ack 228, win 235, options [nop,nop,TS val 3311877800
ecr 3986717], length 0
05:36:20.835368 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr
3311875276,nop,nop,sack 1 {3256:3256}], length 0
05:36:20.835373 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877804 ecr 3986717],
length 0
05:36:20.835375 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.835378 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877804 ecr 3986717],
length 0
05:36:20.849735 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr
3311875276,nop,nop,sack 2 {3257:3257}{3256:3256}], length 0
05:36:20.849740 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877807 ecr 3986717],
length 0
05:36:20.849783 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.849785 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877807 ecr 3986717],
length 0
05:36:20.849787 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.849788 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877807 ecr 3986717],
length 0
05:36:20.849789 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.849790 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877807 ecr 3986717],
length 0
05:36:20.864132 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.864137 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877811 ecr 3986717],
length 0
05:36:20.864185 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.864189 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877811 ecr 3986717],
length 0
05:36:20.864226 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.864228 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877811 ecr 3986717],
length 0
05:36:20.864229 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.864230 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877811 ecr 3986717],
length 0
05:36:20.864231 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.864233 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877811 ecr 3986717],
length 0
05:36:20.864282 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.864285 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877811 ecr 3986717],
length 0
05:36:20.878523 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.878530 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877815 ecr 3986717],
length 0
05:36:20.878532 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.878534 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877815 ecr 3986717],
length 0
05:36:20.878620 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.878624 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877815 ecr 3986717],
length 0
05:36:20.878625 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.878627 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877815 ecr 3986717],
length 0
05:36:20.878628 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.878629 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877815 ecr 3986717],
length 0
05:36:20.878630 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.878632 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877815 ecr 3986717],
length 0
05:36:20.878632 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.878634 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877815 ecr 3986717],
length 0
05:36:20.878635 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.878636 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877815 ecr 3986717],
length 0
05:36:20.878672 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.878674 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877815 ecr 3986717],
length 0
05:36:20.878678 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.878679 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877815 ecr 3986717],
length 0
05:36:20.878724 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.878726 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877815 ecr 3986717],
length 0
05:36:20.878816 IP 128.61.57.205.34574 > 174.36.240.86.443: Flags
[P.], ack 1, win 343, options [nop,nop,TS val 3985712 ecr 3311875276],
length 0
05:36:20.878818 IP 174.36.240.86.443 > 128.61.57.205.34574: Flags [.],
ack 228, win 235, options [nop,nop,TS val 3311877815 ecr 3986717],
length 0

At this point, it just repeats until some timeout is hit. I haven't
timed it, but probably one or two minutes.

I guess I have a few questions:

1.) What's going on here? It looks like maybe there's some packet loss
and then connection termination gets stuck in a loop because the
client timestamp went down?
2.) Is there a better way to mitigate this other than disabling
tcp_timestamps or blocking gatech ips?
3.) Is this our problem (ok, obviously our problem since we're
affected but...), a kernel problem, or a gatech problem?

I'd really appreciate any help on this,

Avery
