From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Extremely bad performance with RTL8111/8168B
Date: Tue, 9 Jul 2013 02:09:02 +0200
Message-ID: <20130709000902.GB19366@amd.pavel.ucw.cz>
References: <20130708095459.GA29788@amd.pavel.ucw.cz>
 <1373291269.4979.102.camel@edumazet-glaptop>
 <20130708220149.GA15766@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Hayes Wang <hayeswang@realtek.com>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:49394 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753400Ab3GIAJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 20:09:06 -0400
Content-Disposition: inline
In-Reply-To: <20130708220149.GA15766@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

> Eric Dumazet <eric.dumazet@gmail.com> :
> [8168d failure]
> > It looks like TSO packets are not transmitted, so TCP only 'works'
> > because retransmits use non TSO packets.
> > 
> > Could you report "ethtool -k eth0" ?
> > 
> > try : ethtool -K eth0 tso off
> 
> If so it could be worth adding a test for RTL_GIGA_MAC_VER_25 in
> rtl_test_hw_pad_bug as has been done for RTL_GIGA_MAC_VER_34 (see
> b423e9ae49d78ea3f53b131c8d5a6087aed16fd6).
> 
> 1a9646497b163a8b9da5e70008d809dc91b32855 may be reverted if
> 'ethtool -K eth0 tso off' does not make a difference.

No, that did not seem to make any difference.

pavel@amd:~$ scp /tmp/delme pavel@duo:/tmp
pavel@duo's password: 
delme                                         100%   34MB 653.6KB/s   00:53    
pavel@amd:~$ scp /tmp/delme pavel@duo:/tmp
pavel@duo's password: 
delme                                         100%   34MB 509.4KB/s   01:08    
pavel@amd:~$ 

BTW I'm on 100mbit switch, so advanced stuff needed for gigabit speed
is not too important for me. I may want to connect it with cross cable
in future, but for now...

So I tried:

root@duo:~# ethtool  -K eth0 rx off gro off
root@duo:~# ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: off
tx-checksumming: off
scatter-gather: off
tcp-segmentation-offload: off
udp-fragmentation-offload: off
generic-segmentation-offload: off
generic-receive-offload: off
large-receive-offload: off
ntuple-filters: off
receive-hashing: off
root@duo:~# 
root@duo:~# mii-tool eth0
eth0: negotiated 100baseTx-FD flow-control, link ok

But speed is still the same :-(:

pavel@amd:~$ scp /tmp/delme pavel@duo:/tmp
pavel@duo's password: 
delme                                         100%   34MB 481.1KB/s   01:12    

Aha. I see abnormal ping times from duo to amd. (Cca 80msec range.)
amd has e1000e card, and apparently its interrupt does not
work. Fortunately it is shared with ahci so I can work around that
one... and when I do, transfer gets even slower. Hmm?

I tried tcpdump on duo. Sample:

20:06:44.063284 IP 10.0.0.6.45418 > 10.0.0.9.22: Flags [.], seq 52128:53576, ack 1, win 151, options [nop,nop,TS va
l 162757452 ecr 218614], length 1448
20:06:44.063324 IP 10.0.0.9.22 > 10.0.0.6.45418: Flags [.], ack 47784, win 516, options [nop,nop,TS val 218614 ecr 
162757452,nop,nop,sack 1 {49232:53576}], length 0
20:06:44.064267 IP 10.0.0.6.45418 > 10.0.0.9.22: Flags [.], seq 47784:49232, ack 1, win 151, options [nop,nop,TS va
l 162757452 ecr 218614], length 1448
20:06:44.064308 IP 10.0.0.9.22 > 10.0.0.6.45418: Flags [.], ack 53576, win 501, options [nop,nop,TS val 218614 ecr 
162757452], length 0
20:06:44.064325 IP 10.0.0.6.45418 > 10.0.0.9.22: Flags [.], seq 53576:55024, ack 1, win 151, options [nop,nop,TS va
l 162757452 ecr 218614], length 1448
20:06:44.064357 IP 10.0.0.9.22 > 10.0.0.6.45418: Flags [.], ack 55024, win 521, options [nop,nop,TS val 218614 ecr 
162757452], length 0
20:06:44.065057 IP 10.0.0.9.22 > 10.0.0.6.45418: Flags [P.], seq 1:49, ack 55024, win 521, options [nop,nop,TS val 
218614 ecr 162757452], length 48
20:06:44.065291 IP 10.0.0.6.45418 > 10.0.0.9.22: Flags [.], seq 55024:56472, ack 1, win 151, options [nop,nop,TS va
l 162757453 ecr 218614], length 1448
20:06:44.065326 IP 10.0.0.6.45418 > 10.0.0.9.22: Flags [.], seq 56472:57920, ack 1, win 151, options [nop,nop,TS va
l 162757453 ecr 218614], length 1448
20:06:44.065356 IP 10.0.0.9.22 > 10.0.0.6.45418: Flags [.], ack 57920, win 521, options [nop,nop,TS val 218614 ecr 
162757453], length 0
20:06:44.066356 IP 10.0.0.6.45418 > 10.0.0.9.22: Flags [.], seq 59368:60816, ack 49, win 151, options [nop,nop,TS v
al 162757453 ecr 218614], length 1448
20:06:44.066409 IP 10.0.0.9.22 > 10.0.0.6.45418: Flags [.], ack 57920, win 521, options [nop,nop,TS val 218615 ecr 
162757453,nop,nop,sack 1 {59368:60816}], length 0
20:06:44.066426 IP 10.0.0.6.45418 > 10.0.0.9.22: Flags [.], seq 60816:62264, ack 49, win 151, options [nop,nop,TS v
al 162757453 ecr 218614], length 1448
20:06:44.066462 IP 10.0.0.9.22 > 10.0.0.6.45418: Flags [.], ack 57920, win 521, options [nop,nop,TS val 218615 ecr 
162757453,nop,nop,sack 1 {59368:62264}], length 0
20:06:44.067297 IP 10.0.0.6.45418 > 10.0.0.9.22: Flags [.], seq 62264:63712, ack 49, win 151, options [nop,nop,TS v
al 162757453 ecr 218615], length 1448
20:06:44.067341 IP 10.0.0.9.22 > 10.0.0.6.45418: Flags [.], ack 57920, win 521, options [nop,nop,TS val 218615 ecr 
162757453,nop,nop,sack 1 {59368:63712}], length 0
20:06:44.067359 IP 10.0.0.6.45418 > 10.0.0.9.22: Flags [.], seq 63712:65160, ack 49, win 151, options [nop,nop,TS v
al 162757453 ecr 218615], length 1448

Any other ideas?

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
