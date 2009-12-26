From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Crazy TCP bug (keepalive flood?) in 2.6.32?
Date: Sat, 26 Dec 2009 16:54:34 +0200
Message-ID: <200912261654.34121.denys@visp.net.lb>
References: <200912092051.18258.denys@visp.net.lb> <4B20C7E6.3040105@tvk.rwth-aachen.de> <alpine.DEB.2.00.0912101218100.7024@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
To: "Ilpo =?iso-8859-15?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:50617 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbZLZOyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2009 09:54:21 -0500
In-Reply-To: <alpine.DEB.2.00.0912101218100.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> ...I thought that myself too but after some thinking I concluded that
> zero packets_out alone would not end up into a loop. ...As the when field
> would then get set to a rather valid value on the first (bogus)
> transmission of the not yet sent segment, so no loop for the next ICMP
> anymore because there should then be plenty of time remaining. I couldn't
> immediately determine whether that packets_out == 0 could occur (I suppose
> we need to think that through but I'm a bit skeptic that it is the reason
> here).
> 
> Another alternative to cause this is that icsk_rto become very small for
> some reason.
> 
Is there anything i can do?
2.6.32.2 have same issue, and actually hosts doing DDoS for my network. It is 
local network with limited capacity and i can manage it, but i imagine if real 
world network will have such issue...
Is there anything i can help to debug this?

I try to disable frto, 
to put keepalive to default value (2 hours) - issue triggered much earlier 
after program restart
tried to disable also timestamps. 

All hosts have similar hardware,  but not completely same.
r8169, Intel motherboards, Dual core processors(E5300), nothing unusual.
Clocksource tsc

Nothing helps to workaround this bug. And weird thing, why it does ignore ICMP 
unreachable?

It seems keeps 10400 bytes in buffer and trying to send them non-stop.

tcp        0  10400 194.146.153.114:8080    172.16.120.230:49435    
ESTABLISHED2078/squid


Proxy-16 ~ # ss -et|grep 120.230
ESTAB      0      0         194.146.153.114:http-alt      172.16.16.120:2307     
uid:101 ino:97182030 sk:d884e3c0
ESTAB      0      10400     194.146.153.114:http-alt     172.16.120.230:49435    
timer:(on,,207) uid:101 ino:97063205 sk:dcdf9c80
Proxy-16 ~ # ss -et|grep 120.230
ESTAB      0      0         194.146.153.114:http-alt      172.16.16.120:2307     
uid:101 ino:97182030 sk:d884e3c0
ESTAB      0      10400     194.146.153.114:http-alt     172.16.120.230:49435    
timer:(on,,88) uid:101 ino:97063205 sk:dcdf9c80
Proxy-16 ~ # ss -et|grep 120.230
ESTAB      0      0         194.146.153.114:http-alt      172.16.16.120:2307     
uid:101 ino:97182030 sk:d884e3c0
ESTAB      0      10400     194.146.153.114:http-alt     172.16.120.230:49435    
timer:(on,,113) uid:101 ino:97063205 sk:dcdf9c80
Proxy-16 ~ # ss -aet|grep 120.230
ESTAB      0      10400     194.146.153.114:http-alt     172.16.120.230:49435    
timer:(on,,7) uid:101 ino:97063205 sk:dcdf9c80
Proxy-16 ~ # ss -aet|grep 120.230
ESTAB      0      10400     194.146.153.114:http-alt     172.16.120.230:49435    
timer:(on,,3) uid:101 ino:97063205 sk:dcdf9c80
Proxy-16 ~ # ss -aet|grep 120.230
ESTAB      0      10400     194.146.153.114:http-alt     172.16.120.230:49435    
timer:(on,,9) uid:101 ino:97063205 sk:dcdf9c80
Proxy-16 ~ # ss -aet|grep 120.230
ESTAB      0      10400     194.146.153.114:http-alt     172.16.120.230:49435    
timer:(on,,221) uid:101 ino:97063205 sk:dcdf9c80


16:39:43.167575 IP (tos 0x0, ttl 64, id 33482, offset 0, flags [DF], proto TCP 
(6), length 1219)
    194.146.153.114.8080 > 172.16.120.230.49435: Flags [P.], cksum 0xe340 
(correct), seq 0:1179, ack 1, win 118, length 1179
16:39:43.168580 IP (tos 0x0, ttl 64, id 33483, offset 0, flags [DF], proto TCP 
(6), length 1219)
    194.146.153.114.8080 > 172.16.120.230.49435: Flags [P.], cksum 0xe340 
(correct), seq 0:1179, ack 1, win 118, length 1179
16:39:43.169571 IP (tos 0x0, ttl 64, id 33484, offset 0, flags [DF], proto TCP 
(6), length 1219)
    194.146.153.114.8080 > 172.16.120.230.49435: Flags [P.], cksum 0xe340 
(correct), seq 0:1179, ack 1, win 118, length 1179


Proxy-16 /config # tcpdump -ni eth0 src host 172.16.120.230 -vvv -s 1500                                                                                                         
tcpdump: WARNING:                                                                                                                                                                
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 1500 
bytes                                                                                                 
                                                                                                                                                                                 
16:41:54.774385 IP (tos 0xc0, ttl 59, id 31922, offset 0, flags [none], proto 
ICMP (1), length 576)                                                                              
    172.16.120.230 > 194.146.153.114: ICMP host 172.16.120.230 unreachable, 
length 556
        IP (tos 0x0, ttl 58, id 31545, offset 0, flags [DF], proto TCP (6), 
length 1219)
    194.146.153.114.8080 > 172.16.120.230.49435: Flags [P.], seq 
3520354182:3520355361, ack 598087346, win 118, length 1179
16:41:54.774509 IP (tos 0xc0, ttl 59, id 31923, offset 0, flags [none], proto 
ICMP (1), length 576)
    172.16.120.230 > 194.146.153.114: ICMP host 172.16.120.230 unreachable, 
length 556
        IP (tos 0x0, ttl 58, id 31634, offset 0, flags [DF], proto TCP (6), 
length 1219)
    194.146.153.114.8080 > 172.16.120.230.49435: Flags [P.], seq 0:1179, ack 
1, win 118, length 1179
16:41:54.774389 IP (tos 0xc0, ttl 59, id 31924, offset 0, flags [none], proto 
ICMP (1), length 576)
    172.16.120.230 > 194.146.153.114: ICMP host 172.16.120.230 unreachable, 
length 556
        IP (tos 0x0, ttl 58, id 31732, offset 0, flags [DF], proto TCP (6), 
length 1219)
    194.146.153.114.8080 > 172.16.120.230.49435: Flags [P.], seq 0:1179, ack 
1, win 118, length 1179

16:41:57.741989 IP (tos 0xc0, ttl 59, id 31925, offset 0, flags [none], proto 
ICMP (1), length 576)
    172.16.120.230 > 194.146.153.114: ICMP host 172.16.120.230 unreachable, 
length 556
        IP (tos 0x0, ttl 58, id 34579, offset 0, flags [DF], proto TCP (6), 
length 1219)
    194.146.153.114.8080 > 172.16.120.230.49435: Flags [P.], seq 0:1179, ack 
1, win 118, length 1179
16:41:57.742169 IP (tos 0xc0, ttl 59, id 31926, offset 0, flags [none], proto 
ICMP (1), length 576)
    172.16.120.230 > 194.146.153.114: ICMP host 172.16.120.230 unreachable, 
length 556
        IP (tos 0x0, ttl 58, id 34689, offset 0, flags [DF], proto TCP (6), 
length 1219)
    194.146.153.114.8080 > 172.16.120.230.49435: Flags [P.], seq 0:1179, ack 
1, win 118, length 1179
16:41:57.742174 IP (tos 0xc0, ttl 59, id 31927, offset 0, flags [none], proto 
ICMP (1), length 576)
    172.16.120.230 > 194.146.153.114: ICMP host 172.16.120.230 unreachable, 
length 556
        IP (tos 0x0, ttl 58, id 34723, offset 0, flags [DF], proto TCP (6), 
length 1219)
    194.146.153.114.8080 > 172.16.120.230.49435: Flags [P.], seq 0:1179, ack 
1, win 118, length 1179
16:42:00.748848 IP (tos 0xc0, ttl 59, id 31928, offset 0, flags [none], proto 
ICMP (1), length 576)
    172.16.120.230 > 194.146.153.114: ICMP host 172.16.120.230 unreachable, 
length 556
        IP (tos 0x0, ttl 58, id 37556, offset 0, flags [DF], proto TCP (6), 
length 1219)
    194.146.153.114.8080 > 172.16.120.230.49435: Flags [P.], seq 0:1179, ack 
1, win 118, length 1179
16:42:00.748856 IP (tos 0xc0, ttl 59, id 31929, offset 0, flags [none], proto 
ICMP (1), length 576)
    172.16.120.230 > 194.146.153.114: ICMP host 172.16.120.230 unreachable, 
length 556
        IP (tos 0x0, ttl 58, id 37597, offset 0, flags [DF], proto TCP (6), 
length 1219)
    194.146.153.114.8080 > 172.16.120.230.49435: Flags [P.], seq 0:1179, ack 
1, win 118, length 1179
16:42:00.759461 IP (tos 0xc0, ttl 59, id 31930, offset 0, flags [none], proto 
ICMP (1), length 576)
    172.16.120.230 > 194.146.153.114: ICMP host 172.16.120.230 unreachable, 
length 556
        IP (tos 0x0, ttl 58, id 37715, offset 0, flags [DF], proto TCP (6), 
length 1219)
    194.146.153.114.8080 > 172.16.120.230.49435: Flags [P.], seq 0:1179, ack 
1, win 118, length 1179

