From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: more accurate skb truesize - regression on Microblaze
Date: Tue, 10 Apr 2012 11:38:18 +0200
Message-ID: <1334050698.3126.30.camel@edumazet-glaptop>
References: <4F83EB0E.4020104@monstr.eu>
	 <1334046444.3126.12.camel@edumazet-glaptop>
	 <1334046746.3126.13.camel@edumazet-glaptop>  <4F83F166.4010208@monstr.eu>
	 <1334047544.3126.14.camel@edumazet-glaptop>  <4F83F959.3070302@monstr.eu>
	 <1334049896.3126.23.camel@edumazet-glaptop>  <4F83FD7A.5010602@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	John Williams <john.williams@petalogix.com>,
	David Miller <davem@davemloft.net>
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35087 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752915Ab2DJJiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 05:38:24 -0400
Received: by bkcik5 with SMTP id ik5so4015992bkc.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 02:38:22 -0700 (PDT)
In-Reply-To: <4F83FD7A.5010602@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 11:29 +0200, Michal Simek wrote:
> On 04/10/2012 11:24 AM, Eric Dumazet wrote:
> > On Tue, 2012-04-10 at 11:11 +0200, Michal Simek wrote:
> >
> >> ~ # cat /proc/sys/net/ipv4/tcp_rmem
> >> 4096    87380   130048
> >
> > Are they default values, or tuned by admin ?
> >
> > 130048 bytes isnt enough to let TCP open its rcv window.
> 
> yep. Default value after powerup. What's wrong with that?
> 
> Michal
> 

I guess your tcp performance is driven by these numbers mostly.

receive window wont grow above 64K in these case. a tcpdump could
confirm the issue.

Do you have 130000 pages of memory ?

Seems the net/ipv4/tcp.c code is wrong (or the comment is wrong)

Since its not 1/128 but 1/1024 ....


        /* Set per-socket limits to no more than 1/128 the pressure threshold */
        limit = nr_free_buffer_pages() << (PAGE_SHIFT - 10);
        limit = max(limit, 128UL);
        max_share = min(4UL*1024*1024, limit);

        sysctl_tcp_wmem[0] = SK_MEM_QUANTUM;
        sysctl_tcp_wmem[1] = 16*1024;
        sysctl_tcp_wmem[2] = max(64*1024, max_share);

        sysctl_tcp_rmem[0] = SK_MEM_QUANTUM;
        sysctl_tcp_rmem[1] = 87380;
        sysctl_tcp_rmem[2] = max(87380, max_share);
