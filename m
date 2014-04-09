From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Does IPv6 support Jumbograms ?
Date: Thu, 10 Apr 2014 00:35:46 +0200
Message-ID: <20140409223546.GH27255@order.stressinduktion.org>
References: <5345A2B3.7040602@gmail.com> <1397079665.16584.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Francois WELLENREITER <f.wellenreiter@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33599 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932719AbaDIWfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 18:35:48 -0400
Content-Disposition: inline
In-Reply-To: <1397079665.16584.17.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 09, 2014 at 02:41:05PM -0700, Eric Dumazet wrote:
> On Wed, 2014-04-09 at 21:42 +0200, Francois WELLENREITER wrote:
> > Hi there,
> > 
> > I've been recently running performance tests with the loopback interface
> > increasing the MTU over the 65535 byte limit.
> > I was really surprised to see that a simple scp onto the ::1 address
> > systematically blocked after transferring about 2,4 MB.
> > My interpretation of this behavior is that the current IPv6 kernel layer
> > does not support Jumbograms at all. Am I wrong ?
> > If that's not the case, what could then the right interpretation of this
> > issue ?
> > And whenever I'm right, is there any plan to support this feature in a
> > near future ?
> 
> What do you mean by blocked ?
> 
> Please give more details (kernel version, exact mtu...), because it
> should not happen !
> 
> # ifconfig lo mtu 100000
> # scp -6 vmlinux edumazet@ip6-localhost:/tmp
> Password: 
> vmlinux
> 100%   24MB  23.5MB/s   00:00    
> # ls -l /tmp/vmlinux
> -rwxr-xr-x 1 edumazet eng 24668915 Apr  9 14:37 /tmp/vmlinux

I couldn't test it on my development system with a recent net-next kernel
yet, but on my laptop with a distribution 3.13.9 kernel this happened too.

I tested with two netcats and threw a dd from /dev/zero into it with a
1MB block size. ssh seems not to be aggressive enough to trigger this:

# tcpdump -i lo -vvv -nKS tcp and port 9988
# tcpdump -i lo -nKS -vvv tcp and port 9988
tcpdump: listening on lo, link-type EN10MB (Ethernet), capture size 65535 bytes
00:26:02.914511 IP6 (hlim 64, next-header TCP (6) payload length: 40) ::1.52141 > ::1.nsesrvr: Flags [S], seq 2750352628, win 43690, options [mss 65535,sackOK,TS val 43288646 ecr 0,nop,wscale 7], length 0
00:26:02.914593 IP6 (hlim 64, next-header TCP (6) payload length: 40) ::1.nsesrvr > ::1.52141: Flags [S.], seq 1418051855, ack 2750352629, win 43690, options [mss 65535,sackOK,TS val 43288647 ecr 43288646,nop,wscale 7], length 0
00:26:02.914659 IP6 (hlim 64, next-header TCP (6) payload length: 32) ::1.52141 > ::1.nsesrvr: Flags [.], seq 2750352629, ack 1418051856, win 342, options [nop,nop,TS val 43288647 ecr 43288647], length 0
00:26:02.915013 IP6 (hlim 64, next-header TCP (6) payload length: 8224) ::1.52141 > ::1.nsesrvr: Flags [P.], seq 2750352629:2750360821, ack 1418051856, win 342, options [nop,nop,TS val 43288647 ecr 43288647], length 8192
00:26:02.915089 IP6 (hlim 64, next-header TCP (6) payload length: 32) ::1.nsesrvr > ::1.52141: Flags [.], seq 1418051856, ack 2750360821, win 1366, options [nop,nop,TS val 43288647 ecr 43288647], length 0
00:26:02.915289 IP6 (hlim 64, next-header TCP (6) payload length: 8224) ::1.52141 > ::1.nsesrvr: Flags [P.], seq 2750360821:2750369013, ack 1418051856, win 342, options [nop,nop,TS val 43288647 ecr 43288647], length 8192
00:26:02.915342 IP6 (hlim 64, next-header TCP (6) payload length: 32) ::1.nsesrvr > ::1.52141: Flags [.], seq 1418051856, ack 2750369013, win 2389, options [nop,nop,TS val 43288647 ecr 43288647], length 0
00:26:02.915467 IP6 (hlim 64, next-header TCP (6) payload length: 8224) ::1.52141 > ::1.nsesrvr: Flags [P.], seq 2750369013:2750377205, ack 1418051856, win 342, options [nop,nop,TS val 43288647 ecr 43288647], length 8192
00:26:02.915558 IP6 (hlim 64, next-header TCP (6) payload length: 32) ::1.nsesrvr > ::1.52141: Flags [.], seq 1418051856, ack 2750377205, win 3413, options [nop,nop,TS val 43288648 ecr 43288647], length 0
00:26:02.915723 IP6 (hlim 64, next-header TCP (6) payload length: 8224) ::1.52141 > ::1.nsesrvr: Flags [P.], seq 2750377205:2750385397, ack 1418051856, win 342, options [nop,nop,TS val 43288648 ecr 43288648], length 8192
00:26:02.915778 IP6 (hlim 64, next-header TCP (6) payload length: 32) ::1.nsesrvr > ::1.52141: Flags [.], seq 1418051856, ack 2750385397, win 3639, options [nop,nop,TS val 43288648 ecr 43288648], length 0
00:26:02.915898 IP6 (hlim 64, next-header TCP (6) payload length: 8224) ::1.52141 > ::1.nsesrvr: Flags [P.], seq 2750385397:2750393589, ack 1418051856, win 342, options [nop,nop,TS val 43288648 ecr 43288648], length 8192
00:26:02.915952 IP6 (hlim 64, next-header TCP (6) payload length: 32) ::1.nsesrvr > ::1.52141: Flags [.], seq 1418051856, ack 2750393589, win 3639, options [nop,nop,TS val 43288648 ecr 43288648], length 0
00:26:02.916072 IP6 (hlim 64, next-header TCP (6) payload length: 8224) ::1.52141 > ::1.nsesrvr: Flags [P.], seq 2750393589:2750401781, ack 1418051856, win 342, options [nop,nop,TS val 43288648 ecr 43288648], length 8192
00:26:02.916126 IP6 (hlim 64, next-header TCP (6) payload length: 32) ::1.nsesrvr > ::1.52141: Flags [.], seq 1418051856, ack 2750401781, win 3639, options [nop,nop,TS val 43288648 ecr 43288648], length 0
00:26:02.916245 IP6 (hlim 64, next-header TCP (6) payload length: 8224) ::1.52141 > ::1.nsesrvr: Flags [P.], seq 2750401781:2750409973, ack 1418051856, win 342, options [nop,nop,TS val 43288648 ecr 43288648], length 8192

00:26:02.916850 IP6 (hlim 64, next-header TCP (6) payload length: 19) ::1.52141 > ::1.nsesrvr: [|tcp]
00:26:02.918682 IP6 (hlim 64, next-header TCP (6) payload length: 19) ::1.52141 > ::1.nsesrvr: [|tcp]
00:26:02.919852 IP6 (hlim 64, next-header TCP (6) payload length: 19) ::1.52141 > ::1.nsesrvr: [|tcp]
00:26:02.920966 IP6 (hlim 64, next-header TCP (6) payload length: 19) ::1.52141 > ::1.nsesrvr: [|tcp]
00:26:02.922092 IP6 (hlim 64, next-header TCP (6) payload length: 19) ::1.52141 > ::1.nsesrvr: [|tcp]
00:26:02.923194 IP6 (hlim 64, next-header TCP (6) payload length: 19) ::1.52141 > ::1.nsesrvr: [|tcp]
00:26:02.955634 IP6 (hlim 64, next-header TCP (6) payload length: 32) ::1.nsesrvr > ::1.52141: Flags [.], seq 1418051856, ack 2750409973, win 3639, options [nop,nop,TS val 43288688 ecr 43288648], length 0
00:26:02.955832 IP6 (hlim 64, next-header TCP (6) payload length: 19) ::1.52141 > ::1.nsesrvr: [|tcp]
00:26:03.160698 IP6 (hlim 64, next-header TCP (6) payload length: 19) ::1.52141 > ::1.nsesrvr: [|tcp]
00:26:03.572148 IP6 (hlim 64, next-header TCP (6) payload length: 19) ::1.52141 > ::1.nsesrvr: [|tcp]
00:26:04.394117 IP6 (hlim 64, next-header TCP (6) payload length: 19) ::1.52141 > ::1.nsesrvr: [|tcp]

Hmm... that is strange.

Bye,

  Hannes
