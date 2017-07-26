From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP fast retransmit issues
Date: Wed, 26 Jul 2017 06:31:21 -0700
Message-ID: <1501075881.12695.15.camel@edumazet-glaptop3.roam.corp.google.com>
References: <200d9a12e9f2f5791d4c5ce2d47a1239@vsen.dk>
         <1501069756.12695.11.camel@edumazet-glaptop3.roam.corp.google.com>
         <a025f5b2ed6e1f287f68b6bb5137a988@vsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Klavs Klavsen <kl@vsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f178.google.com ([209.85.128.178]:35853 "EHLO
        mail-wr0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750893AbdGZNbZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 09:31:25 -0400
Received: by mail-wr0-f178.google.com with SMTP id y43so131645159wrd.3
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 06:31:24 -0700 (PDT)
In-Reply-To: <a025f5b2ed6e1f287f68b6bb5137a988@vsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-07-26 at 14:18 +0200, Klavs Klavsen wrote:
> the 192.168.32.44 is a Centos 7 box.

Could you grab a capture on this box, to see if the bogus packets are
sent by it, or later mangled by a middle box ?

> 
> Could you help me by elaborating on how to see why the "dup ack" (sack 
> blocks) are bogus?


tcpdump -S ...

01:37:44.455158 IP 62.242.222.50.54004 > 192.168.32.44.22: Flags [.], seq 370328274:370329622, ack 4062374366, win 1382, options [nop,nop,TS val 769439585 ecr 510569974], length 1348
01:37:44.455159 IP 62.242.222.50.54004 > 192.168.32.44.22: Flags [.], seq 370329622:370330970, ack 4062374366, win 1382, options [nop,nop,TS val 769439585 ecr 510569974], length 1348
01:37:44.455160 IP 62.242.222.50.54004 > 192.168.32.44.22: Flags [.], seq 370330970:370332318, ack 4062374366, win 1382, options [nop,nop,TS val 769439585 ecr 510569974], length 1348
01:37:44.455160 IP 62.242.222.50.54004 > 192.168.32.44.22: Flags [.], seq 370332318:370333666, ack 4062374366, win 1382, options [nop,nop,TS val 769439585 ecr 510569974], length 1348

01:37:44.455163 IP 192.168.32.44.22 > 62.242.222.50.54004: Flags [.], ack 370166514, win 2730, options [nop,nop,TS val 510569975 ecr 769439578,nop,nop,sack 1 {3012336703:3012338051}], length 0

3012336703:3012338051 is clearly outside of the window.
Receiver claims to have received bytes that were never sent.

01:37:44.455169 IP 192.168.32.44.22 > 62.242.222.50.54004: Flags [.], ack 370166514, win 2730, options [nop,nop,TS val 510569975 ecr 769439578,nop,nop,sack 1 {3012336703:3012339399}], length 0
01:37:44.455172 IP 192.168.32.44.22 > 62.242.222.50.54004: Flags [.], ack 370166514, win 2730, options [nop,nop,TS val 510569975 ecr 769439578,nop,nop,sack 1 {3012336703:3012340747}], length 0
01:37:44.455175 IP 192.168.32.44.22 > 62.242.222.50.54004: Flags [.], ack 370166514, win 2730, options [nop,nop,TS val 510569975 ecr 769439578,nop,nop,sack 1 {3012336703:3012342095}], length 0
01:37:44.455178 IP 192.168.32.44.22 > 62.242.222.50.54004: Flags [.], ack 370166514, win 2730, options [nop,nop,TS val 510569975 ecr 769439578,nop,nop,sack 1 {3012336703:3012343443}], length 0
01:37:44.455181 IP 192.168.32.44.22 > 62.242.222.50.54004: Flags [.], ack 370166514, win 2730, options [nop,nop,TS val 510569976 ecr 769439578,nop,nop,sack 1 {3012336703:3012344791}], length 0
01:37:44.455183 IP 192.168.32.44.22 > 62.242.222.50.54004: Flags [.], ack 370166514, win 2730, options [nop,nop,TS val 510569976 ecr 769439578,nop,nop,sack 1 {3012336703:3012346139}], length 0
01:37:44.455186 IP 192.168.32.44.22 > 62.242.222.50.54004: Flags [.], ack 370166514, win 2730, options [nop,nop,TS val 510569976 ecr 769439578,nop,nop,sack 1 {3012336703:3012347487}], length 0
01:37:44.455189 IP 192.168.32.44.22 > 62.242.222.50.54004: Flags [.], ack 370166514, win 2730, options [nop,nop,TS val 510569977 ecr 769439578,nop,nop,sack 1 {3012336703:3012348835}], length 0



> 
> Thank you very much. I'll try to capture the same scp done on mac - and 
> see if it also gets DUP ACK's - and how they look in comparison (since 
> it works on Mac clients).
> 
> Eric Dumazet skrev den 2017-07-26 13:49:
> > On Wed, 2017-07-26 at 13:07 +0200, Klavs Klavsen wrote:
> >> Hi guys,
> >> 
> >> Me and my colleagues have an annoying issue with our Linux desktops 
> >> and
> >> the company's Junos VPN.
> >> 
> >> We connect with openconnect (some use the official Pulse client) - 
> >> which
> >> then opens up a tun0 device - and traffic runs through that.
> >> 
> >> If we try to scp a file of ~100MB (f.ex. linux-4.12.3.tar.xz :) - it
> >> stalls after sending 20-30% typicly.. then starts again after some 
> >> time,
> >> and typicly dies before finishing. I've captured it with tcpdump (its 
> >> a
> >> large 77Mb file - thats how far it got before it died :) -
> >> http://blog.klavsen.info/fast-retransmit-problem-junos-linux
> >> 
> >> I've attached an image of wireshark - where the (AFAIK) interesting 
> >> part
> >> starts.. Where my client starts getting DUP ACK's.. but my Linux 
> >> client
> >> does nothing :(
> >> I've tried to upgrade to latest Ubuntu-mainline kernel build (4.12.3)
> >> and it changed nothing.
> >> 
> >> The problem goes away, if I do:
> >> sysctl -w net.ipv4.tcp_sack=0
> >> 
> >> I've tried specificly enabling net.ipv4.tcp_fack=1 - but that did not
> >> help.
> >> 
> >> This is not an issue on Mac OSX or Windows clients.
> >> 
> >> None of the Linux users here figured, that could be a Linux kernel 
> >> issue
> >> - but the evidence seems to suggest it - and all my googleing and
> >> reading does not lead me to any other conclusion.
> >> 
> >> It may ofcourse be that Junos has implemented the standard 
> >> badly/wrongly
> >> - and Windows/Mac has done a workaround for that?
> >> 
> >> I hope you can help me figure out whats going wrong.
> >> 
> > 
> > sack blocks returned by the remote peer are completely bogus.
> > 
> > Maybe a firewall is messing with them ?
> > 
> > I suspect ACK packets might be simply dropped because of invalid SACK
> > information.
> 
