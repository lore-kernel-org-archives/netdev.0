From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression: TCP connections fail over wireless: bad cksum?
Date: Thu, 04 Sep 2014 15:50:07 -0700
Message-ID: <1409871007.26422.125.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5408C788.4050401@tedp.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ted Percival <ted@tedp.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34528 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756085AbaIDWuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 18:50:11 -0400
Received: by mail-pa0-f53.google.com with SMTP id fa1so21025341pad.40
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 15:50:08 -0700 (PDT)
In-Reply-To: <5408C788.4050401@tedp.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-04 at 14:11 -0600, Ted Percival wrote:
> Yesterday's linux-next build introduced a problem with wireless
> networking on my machine. ie. next-20140901 worked fine but
> next-20140902 does not seem able to sustain a TCP connection over
> wireless. Wired networking works fine. I am using the brcmsmac driver
> and the hardware is "Broadcom Corporation BCM4313 802.11b/g/n Wireless
> LAN Controller (rev 01)".
> 
> Pings, even large pings (ping -s 16000) work fine but TCP connections hang.
> 
> I looked through the changes between the bad & good commits from the net
> & net-next trees and I wonder if some of the changes to checksumming
> have surfaced a problem with this driver. When I look at a tcpdump, it
> indicates that all the checksums are wrong (although I don't know if
> that is just due to hardware offload).
> 
> Here is a short trace of the hung connection attempt of
>   curl http://lwn.net/
> 
> $ sudo tcpdump -vvn -i wlan0 port 80
> tcpdump: listening on wlan0, link-type EN10MB (Ethernet), capture size
> 65535 bytes
> 13:20:15.120770 IP (tos 0x0, ttl 64, id 22734, offset 0, flags [DF],
> proto TCP (6), length 60)
>     10.5.51.93.38035 > 72.51.34.34.80: Flags [S], cksum 0xa7e5
> (incorrect -> 0x4fac), seq 2861986597, win 29200, options [mss
> 1460,sackOK,TS val 142315 ecr 0,nop,wscale 7], length 0
> 13:20:16.121755 IP (tos 0x0, ttl 64, id 22735, offset 0, flags [DF],
> proto TCP (6), length 60)
>     10.5.51.93.38035 > 72.51.34.34.80: Flags [S], cksum 0xa7e5
> (incorrect -> 0x4bc3), seq 2861986597, win 29200, options [mss
> 1460,sackOK,TS val 143316 ecr 0,nop,wscale 7], length 0
> 13:20:18.125748 IP (tos 0x0, ttl 64, id 22736, offset 0, flags [DF],
> proto TCP (6), length 60)
>     10.5.51.93.38035 > 72.51.34.34.80: Flags [S], cksum 0xa7e5
> (incorrect -> 0x43ef), seq 2861986597, win 29200, options [mss
> 1460,sackOK,TS val 145320 ecr 0,nop,wscale 7], length 0
> 13:20:22.133743 IP (tos 0x0, ttl 64, id 22737, offset 0, flags [DF],
> proto TCP (6), length 60)
>     10.5.51.93.38035 > 72.51.34.34.80: Flags [S], cksum 0xa7e5
> (incorrect -> 0x3447), seq 2861986597, win 29200, options [mss
> 1460,sackOK,TS val 149328 ecr 0,nop,wscale 7], length 0
> 13:20:30.149754 IP (tos 0x0, ttl 64, id 22738, offset 0, flags [DF],
> proto TCP (6), length 60)
>     10.5.51.93.38035 > 72.51.34.34.80: Flags [S], cksum 0xa7e5
> (incorrect -> 0x14f7), seq 2861986597, win 29200, options [mss
> 1460,sackOK,TS val 157344 ecr 0,nop,wscale 7], length 0
> 
> 
> I don't see anything that looks related in dmesg. The only brcmsmac
> messages I see are:
> 
> [  567.122218] brcmsmac bcma0:0: brcmsmac: brcms_ops_bss_info_changed:
> associated
> [  567.122226] brcmsmac bcma0:0: brcms_ops_bss_info_changed: arp
> filtering: 1 addresses (implement)
> [  567.122231] brcmsmac bcma0:0: brcms_ops_bss_info_changed: qos
> enabled: true (implement)
> [  567.192283] brcmsmac bcma0:0: brcms_ops_bss_info_changed: qos
> enabled: true (implement)
> 
> I am writing to linux-netdev rather than linux-wireless because
> according to Next/SHA1s the wireless & wireless-next trees were not
> updated between next-20140901 and next-20140902, but the net & net-next
> trees were updated, so maybe the regression came from there. (I haven't
> tested next-20140903 because it won't boot for unrelated reasons.)
> 
> Let me know if I should just file this in Bugzilla or what information I
> can provide to help track this down, if it hasn't already been identified.
> 
> The here are the good (-) and bad (+) trees from Next/SHA1s at the
> next-* tags mentioned earlier that I built from.
> 
> -net            38ab1fa981d543e1b00f4ffbce4ddb480cd2effe
> +net            cc25f0cbe4409d6a573b1f3bf7020d5b04076ee9
> 
> -net-next       dace1b54726bffe1c009f7661e3cee6b762f30c8
> +net-next       364a9e93243d1785f310c0964af0e24bf1adac03
> 

Could you post

ethtool -k wlan0

And try 

ethtool -K wlan tx off
