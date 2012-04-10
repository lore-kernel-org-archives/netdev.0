From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: more accurate skb truesize - regression on Microblaze
Date: Tue, 10 Apr 2012 10:27:24 +0200
Message-ID: <1334046444.3126.12.camel@edumazet-glaptop>
References: <4F83EB0E.4020104@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	John Williams <john.williams@petalogix.com>,
	David Miller <davem@davemloft.net>
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:50629 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753309Ab2DJI1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 04:27:32 -0400
Received: by bkcik5 with SMTP id ik5so3959876bkc.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 01:27:28 -0700 (PDT)
In-Reply-To: <4F83EB0E.4020104@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 10:10 +0200, Michal Simek wrote:
> Hi Eric,
> 
> I have spent some time to investigate what it is causing regression on our network bechmark
> and I have identified that your patch "net: more accurate skb truesize" is causing that.
> 
> I see regression especially on incoming tcp (RX) connection which is 20%. On TX I see regression till 5%.
> 
> In general microblaze systems are pretty sensitive for memory usage and working with it.
> Increasing packet sizes has big impact on performance.
> I was surprised that regression is so high.
> 
>  From microblaze point of view is more important to remove that performance regression
> than having more accurate memory accounting. 20% performance regression is simple so high
> for that.
> Isn't there any other way to doing better memory accounting?
> Or is there any workaround which would be possible to use?
> 
> Thanks,
> Michal
> 

Hi Michal

We are currently working on the issue.

TCP stack was a bit optimistic in the ideal skb->len / skb->truesize
ratio that happened to 'mostly work' before my patch, but not anymore
after it.

memory accounting was wrong, we really wanted to be accurate, or risk
OOM and crashes.

Now we must fix tcp.

In the meantime you could try :

echo 1 >/proc/sys/net/ipv4/tcp_adv_win_scale

BTW, some NIC drivers are known to provide fat skb in their rx path, and
need to be fixed as well. (Some others just lie about skb->truesize to
avoid the tcp slowdown, see my previous iwlwifi patch)
