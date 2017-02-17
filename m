From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] TCP_NOTSENT_LOWAT behavior
Date: Thu, 16 Feb 2017 23:07:05 -0800
Message-ID: <1487315225.1311.76.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1487312405-18480-1-git-send-email-johunt@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, jbaron@akamai.com
To: Josh Hunt <johunt@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35654 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752574AbdBQHHH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 02:07:07 -0500
Received: by mail-pf0-f196.google.com with SMTP id 68so3456905pfx.2
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 23:07:07 -0800 (PST)
In-Reply-To: <1487312405-18480-1-git-send-email-johunt@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-02-17 at 01:20 -0500, Josh Hunt wrote:
> Eric
> 
> A team here was using the TCP_NOTSENT_LOWAT socket option and noticed that
> more unsent data than they were expecting was sitting in the write queue. I
> took a look and noticed that while we don't allow allocation of new skbs once
> we exceed this value, we still allow adding data to the skb at the tail of the
> write queue. In this context that means we could add up to size_goal to the
> skb, which could be up to 64kb.
> 
> The patch below attempts to put a cap on the amount we allow to write over
> the TCP_NOTSENT_LOWAT value at 50%. In cases where the setting is smaller this
> will allow the # of unsent bytes to more closely reflect the value. In cases
> where the setting is 128kb or higher this will have no impact compared to the
> current behavior. This should have two benefits: 1) finer-grain control of the
> amount of unsent data, 2) reduction of TCP memory for values of TCP_NOTSENT_LOWAT
> < 128k.
> 
> I reran the netperf results from your original commit with and without my patch:
> 
> 4.10.0-rc8:
> # echo $(( 128 * 1024 )) > /proc/sys/net/ipv4/tcp_notsent_lowat
> # (./super_netperf 200 -H remote -t TCP_STREAM -l 90 &); sleep 60; grep TCP /proc/net/protocols
> TCPv6     2064      2   21735   no     208   yes  ipv6        y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
> TCP       1912    465   21735   no     208   yes  kernel      y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
> 
> # echo $(( 64 * 1024 )) > /proc/sys/net/ipv4/tcp_notsent_lowat
> # (./super_netperf 200 -H remote -t TCP_STREAM -l 90 &); sleep 60; grep TCP /proc/net/protocols
> TCPv6     2064      2   19859   no     208   yes  ipv6        y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
> TCP       1912    465   19859   no     208   yes  kernel      y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
> 
> 4.10.0-rc8 + patch:
> # echo $(( 128 * 1024 )) > /proc/sys/net/ipv4/tcp_notsent_lowat
> # (./super_netperf 200 -H remote -t TCP_STREAM -l 90 &); sleep 60; grep TCP /proc/net/protocols
> TCPv6     2064      2   21570   no     208   yes  ipv6        y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
> TCP       1912    465   21570   no     208   yes  kernel      y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
> 
> # echo $(( 64 * 1024 )) > /proc/sys/net/ipv4/tcp_notsent_lowat
> # (./super_netperf 200 -H remote -t TCP_STREAM -l 90 &); sleep 60; grep TCP /proc/net/protocols
> TCPv6     2064      2   18257   no     208   yes  ipv6        y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
> TCP       1912    465   18257   no     208   yes  kernel      y  y  y  y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
> 
> I still need to do more testing, but wanted to get feedback on the idea.
> 
> Josh
> 

This adds a cost to fast path. tcp_sendmsg() is insane.

We have one skb granularity (64KB) already for SO_SNDBUF, regardless of
TCP_NOTSENT_LOWAT being used or not.

It makes no sense really to try so hard to add all these checks.

I would prefer we fix the under run problem of TCP_NOTSENT_LOWAT

Namely : SACKs can come, but we do not send EPOLLOUT, and we can starve
the output or TLP

Thanks
