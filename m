From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: panics in tcp_ack
Date: Sun, 02 Jun 2013 17:36:27 -0700
Message-ID: <1370219787.24311.113.camel@edumazet-glaptop>
References: <51ABE067.2050507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:51197 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754730Ab3FCAg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 20:36:29 -0400
Received: by mail-pd0-f174.google.com with SMTP id 3so4843599pdj.19
        for <netdev@vger.kernel.org>; Sun, 02 Jun 2013 17:36:29 -0700 (PDT)
In-Reply-To: <51ABE067.2050507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-06-02 at 19:16 -0500, Rob Herring wrote:
> Sorry, this time with proper line wrapping...
> 
> I'm debugging a kernel panic in the networking stack that happens with a
> cluster (20-40 nodes) of Calxeda highbank (ARM Cortex A9) nodes and
> typically only after 10-24 hours. The node are transferring files
> between nodes over TCP with 20 clients and servers per node. The kernel
> is based on ubuntu 3.5 kernel which is based on 3.5.7.11. So far testing
> has shown that 3.8.11 based (ubuntu raring) kernel is fixed. Attempts to
> bisect have not yielded results as it seems multiple problems mask the
> issue. Perhaps there is some new feature which has indirectly fixed the
> problem in 3.8.
> 
> This commit appears to fix a similar panic and seems to reduce the
> frequency after picking it up in the latest 3.5 stable:
> 
> commit 16fad69cfe4adbbfa813de516757b87bcae36d93
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Thu Mar 14 05:40:32 2013 +0000
> 
>     tcp: fix skb_availroom()
>         Chrome OS team reported a crash on a Pixel ChromeBook in TCP stack :
>         https://code.google.com/p/chromium/issues/detail?id=182056
>         commit a21d45726acac (tcp: avoid order-1 allocations on wifi and tx
>     path) did a poor choice adding an 'avail_size' field to skb, while
>     what we really needed was a 'reserved_tailroom' one.
>         It would have avoided commit 22b4a4f22da (tcp: fix retransmit of
>     partially acked frames) and this commit.
>         Crash occurs because skb_split() is not aware of the 'avail_size'
>     management (and should not be aware)
>         Signed-off-by: Eric Dumazet <edumazet@google.com>
>     Reported-by: Mukesh Agrawal <quiche@chromium.org>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> I've searched thru 3.8 and 3.9 stable fixes looking for possibly
> relevant commits and applied these commits not in 3.5 stable. However,
> they have not helped:
> 
> net: drop dst before queueing fragments
> tcp: call tcp_replace_ts_recent() from tcp_ack()
> tcp: Reallocate headroom if it would overflow csum_start
> tcp: incoming connections might use wrong route under synflood
> 

try also :

commit 093162553c33e94 (tcp: force a dst refcount when prequeue packet)
commit 0d4f0608619de59 (tcp: dont handle MTU reduction on LISTEN socket)
commit 6731d2095bd4aef (tcp: fix for zero packets_in_flight was too
broad)
commit 2e5f421211ff76c (tcp: frto should not set snd_cwnd to 0)
