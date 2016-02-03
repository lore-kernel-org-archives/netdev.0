From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 111751] New: Kernel send tcp reset when receive icmp
 redirect
Date: Tue, 02 Feb 2016 18:35:52 -0800
Message-ID: <1454466952.7627.211.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160203115616.5549851a@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33577 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932232AbcBCCf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 21:35:56 -0500
Received: by mail-pa0-f44.google.com with SMTP id cy9so4829751pac.0
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 18:35:55 -0800 (PST)
In-Reply-To: <20160203115616.5549851a@samsung9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-02-03 at 11:56 +1100, Stephen Hemminger wrote:
> 
> Begin forwarded message:
> 
> Date: Tue, 2 Feb 2016 11:42:41 +0000
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
> Subject: [Bug 111751] New: Kernel send tcp reset when receive icmp redirect
> 
> 
> https://urldefense.proofpoint.com/v2/url?u=https-3A__bugzilla.kernel.org_show-5Fbug.cgi-3Fid-3D111751&d=CwICaQ&c=IL_XqQWOjubgfqINi2jTzg&r=q_lvUiVm1uM6QEw9TPH-6jiV__hsrE6xXUAtATPE9x0&m=UNO95AZfSkcQcZYh6NtZCATnWsJA165x3m2P3_Yo4mY&s=8874491L4x2GOXBxBlNCQJaF3d2Jryc776RbYqRVTS8&e= 
> 
>             Bug ID: 111751
>            Summary: Kernel send tcp reset when receive icmp redirect
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 4.4.0
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>           Assignee: shemminger@linux-foundation.org
>           Reporter: pety@rusnet.ru
>         Regression: No
> 
> Network scheme:
> 
>           server1
> router----eth0------buggy-linux-box
> 
> router ip          - 192.168.113.246/30
> 
> server1 ip on eth0 - 192.168.113.245/30, 192.168.113.158/27 (aliases), default
> to 192.168.113.246
> 
> buggy-linux-box ip - 192.168.113.133/27
> 
> When I try telnet (or ssh, for example) to 192.168.113.133 from
> 192.168.113.115, I receive tcp reset:
> 
> 13:55:22.341015 IP (tos 0x10, ttl 62, id 54936, offset 0, flags [DF], proto TCP
> (6), length 60)
>     192.168.113.115.33160 > 192.168.113.133.23: Flags [S], cksum 0x681c
> (correct), seq 1552183701, win 5840, options [mss 1460,sackOK,TS val
>  1739695885 ecr 0,nop,wscale 9], length 0
> 
> 13:55:22.341039 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto TCP (6),
> length 60)
>     192.168.113.133.23 > 192.168.113.115.33160: Flags [S.], cksum 0x6ac8
> (incorrect -> 0x4221), seq 1195050131, ack 1552183702, win 28960, o
> ptions [mss 1460,sackOK,TS val 337210292 ecr 1739695885,nop,wscale 7], length 0
> 
> 13:55:22.341188 IP (tos 0xc0, ttl 64, id 29828, offset 0, flags [none], proto 
> ICMP (1), length 88)
>     192.168.113.158 > 192.168.113.133: ICMP redirect 192.168.113.115 to host
> 192.168.113.246, length 68
>         IP (tos 0x0, ttl 63, id 0, offset 0, flags [DF], proto TCP (6), length
> 60)
>     192.168.113.133.23 > 192.168.113.115.33160: Flags [S.], cksum 0x4221
> (correct), seq 1195050131, ack 1552183702, win 28960, options [mss
> 1460,sackOK,TS val 337210292 ecr 1739695885,nop,wscale 7], length 0
> 
> 13:55:22.341264 IP (tos 0x10, ttl 62, id 54937, offset 0, flags [DF], proto TCP
> (6), length 52)
>     192.168.113.115.33160 > 192.168.113.133.23: Flags [.], cksum 0xe201
> (correct), seq 1, ack 1, win 12, options [nop,nop,TS val 1739695885
> ecr 337210292], length 0
> 
> 13:55:22.341281 IP (tos 0x10, ttl 64, id 28000, offset 0, flags [DF], proto TCP
> (6), length 40)
>     192.168.113.133.23 > 192.168.113.115.33160: Flags [R], cksum 0x77d8
> (correct), seq 1195050132, win 0, length 0
> 
> 13:55:22.341284 IP (tos 0x10, ttl 62, id 54938, offset 0, flags [DF], proto TCP
> (6), length 76)
>     192.168.113.115.33160 > 192.168.113.133.23: Flags [P.], cksum 0x8590
> (correct), seq 1:25, ack 1, win 12, options [nop,nop,TS val 1739695
> 885 ecr 337210292], length 24 [telnet DO SUPPRESS GO AHEAD, WILL TERMINAL TYPE,
> WILL NAWS, WILL TSPEED, WILL LFLOW, WILL LINEMODE, WILL NEW-
> ENVIRON, DO STATUS]
> 
> 13:55:22.341289 IP (tos 0x10, ttl 64, id 28001, offset 0, flags [DF], proto TCP
> (6), length 40)
>     192.168.113.133.23 > 192.168.113.115.33160: Flags [R], cksum 0x77d8
> (correct), seq 1195050132, win 0, length 0
> ^C
> 7 packets captured
> 7 packets received by filter
> 0 packets dropped by kernel
> 
> If I turn off sending redirects on server1, or reject incoming ICMP with
> iptables (on buggy-box), the problem is gone.
> 
> Looks like kernel 4.1.15 without this problem.
> 

Thanks Stephen for the report. I am cooking a fix.
