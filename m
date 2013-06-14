From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: [tcp] Unable to report zero window when flooded with small packets
Date: Fri, 14 Jun 2013 10:11:33 -0300
Message-ID: <51BB1685.4070103@redhat.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34288 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752163Ab3FNNLi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jun 2013 09:11:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

First of all, sorry the long email, but this is lengthy and I couldn't narrow 
it down. My bisect-fu is failing me.

We got report saying that after this commit:

commit 607bfbf2d55dd1cfe5368b41c2a81a8c9ccf4723
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Mar 20 16:11:27 2008 -0700

     [TCP]: Fix shrinking windows with window scaling

     When selecting a new window, tcp_select_window() tries not to shrink
     the offered window by using the maximum of the remaining offered window
     size and the newly calculated window size. The newly calculated window
     size is always a multiple of the window scaling factor, the remaining
     window size however might not be since it depends on rcv_wup/rcv_nxt.
     This means we're effectively shrinking the window when scaling it down.

     (...)

Linux is unable to advertise zero window when using window scale option. I 
tested it under current net(-next) trees and I can reproduce the issue.

Consider the following load type:
- A tcp peer sends several tiny packets.
- Other peer acts slowly, it won't read its side of this socket for a big while.

If the tiny packets sent by client are smaller (payload) than (1 << Window 
Scale) bytes, server is never able to update available window, as it would be 
always shrinking the window.

As that patch blocks window shrinking with window scaling, then server would 
never advertise zero window, even when buffer is full. Instead, it will start 
simply dropping these packets and client will think the server went 
unreachable, timing out the connection if application doesn't read the socket 
soon enough.

In order to speed up the testing, I'm disabling receive buf moderation by 
setting SO_RCVBUF to 64k after accept(): so we allow a non-optimal window 
scale option. Also, when I want to disable window scaling, I just set 
TCP_WINDOW_CLAMP before listen(). All flow was client->server during the tests.

So, for this issue, small packets + Window Scale option:
v3.0 stock: doesn't work
v3.0 with that commit reverted: works
v3.2 with that commit reverted: doesn't work either
net-next stock: doesn't work
net-next reverted: doesn't work

Further testing revealed that v3.3 and newer also have issue when NOT using 
window scale option. So, for this other issue:
v3.2: it's fine.
v3.3 with 9f42f126154786e6e76df513004800c8c633f020 reverted: works
net-next stock: doesn't work
net-next reverted: doesn't work

commit 9f42f126154786e6e76df513004800c8c633f020
Author: Ian Campbell <Ian.Campbell@citrix.com>
Date:   Thu Jan 5 07:13:39 2012 +0000

     net: pack skb_shared_info more efficiently

     nr_frags can be 8 bits since 256 is plenty of fragments. This allows it to be
     packed with tx_flags.

     Also by moving ip6_frag_id and dataref (both 4 bytes) next to each other 
we can
     avoid a hole between ip6_frag_id and frag_list on 64 bit systems.

with both commits reverted
v3.3: when using WS doesn't work; when not using, works fine
net-next: doesn't work, either

Clearly I'm missing something here, seems there is more than this but I can't 
track it. Perhaps a corner case with rx buf collapsing?

     57 packets pruned from receive queue because of socket buffer overrun
     15 packets pruned from receive queue
     243 packets collapsed in receive queue due to low socket buffer
     TCPRcvCoalesce: 6019

I can provide a reproducer and/or captures if it helps.

Thanks,
Marcelo
