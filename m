From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [tcp] Unable to report zero window when flooded with small
 packets
Date: Mon, 1 Jul 2013 15:50:57 +0200
Message-ID: <20130701135057.GA4198@minipsycho.brq.redhat.com>
References: <51BB1685.4070103@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	kaber@trash.net, eric.dumazet@gmail.com, davem@davemloft.net
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:43398 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753798Ab3GANxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 09:53:10 -0400
Received: by mail-wi0-f174.google.com with SMTP id k10so3087693wiv.7
        for <netdev@vger.kernel.org>; Mon, 01 Jul 2013 06:53:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <51BB1685.4070103@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jun 14, 2013 at 03:11:33PM CEST, mleitner@redhat.com wrote:
>Hi there,
>
>First of all, sorry the long email, but this is lengthy and I
>couldn't narrow it down. My bisect-fu is failing me.
>
>We got report saying that after this commit:
>
>commit 607bfbf2d55dd1cfe5368b41c2a81a8c9ccf4723
>Author: Patrick McHardy <kaber@trash.net>
>Date:   Thu Mar 20 16:11:27 2008 -0700
>
>    [TCP]: Fix shrinking windows with window scaling
>
>    When selecting a new window, tcp_select_window() tries not to shrink
>    the offered window by using the maximum of the remaining offered window
>    size and the newly calculated window size. The newly calculated window
>    size is always a multiple of the window scaling factor, the remaining
>    window size however might not be since it depends on rcv_wup/rcv_nxt.
>    This means we're effectively shrinking the window when scaling it down.
>
>    (...)
>
>Linux is unable to advertise zero window when using window scale
>option. I tested it under current net(-next) trees and I can
>reproduce the issue.
>
>Consider the following load type:
>- A tcp peer sends several tiny packets.
>- Other peer acts slowly, it won't read its side of this socket for a big while.
>
>If the tiny packets sent by client are smaller (payload) than (1 <<
>Window Scale) bytes, server is never able to update available window,
>as it would be always shrinking the window.
>
>As that patch blocks window shrinking with window scaling, then
>server would never advertise zero window, even when buffer is full.
>Instead, it will start simply dropping these packets and client will
>think the server went unreachable, timing out the connection if
>application doesn't read the socket soon enough.
>
>In order to speed up the testing, I'm disabling receive buf
>moderation by setting SO_RCVBUF to 64k after accept(): so we allow a
>non-optimal window scale option. Also, when I want to disable window
>scaling, I just set TCP_WINDOW_CLAMP before listen(). All flow was
>client->server during the tests.
>
>So, for this issue, small packets + Window Scale option:
>v3.0 stock: doesn't work
>v3.0 with that commit reverted: works
>v3.2 with that commit reverted: doesn't work either
>net-next stock: doesn't work
>net-next reverted: doesn't work
>
>Further testing revealed that v3.3 and newer also have issue when NOT
>using window scale option. So, for this other issue:
>v3.2: it's fine.
>v3.3 with 9f42f126154786e6e76df513004800c8c633f020 reverted: works
>net-next stock: doesn't work
>net-next reverted: doesn't work
>
>commit 9f42f126154786e6e76df513004800c8c633f020
>Author: Ian Campbell <Ian.Campbell@citrix.com>
>Date:   Thu Jan 5 07:13:39 2012 +0000
>
>    net: pack skb_shared_info more efficiently
>
>    nr_frags can be 8 bits since 256 is plenty of fragments. This allows it to be
>    packed with tx_flags.
>
>    Also by moving ip6_frag_id and dataref (both 4 bytes) next to
>each other we can
>    avoid a hole between ip6_frag_id and frag_list on 64 bit systems.
>
>with both commits reverted
>v3.3: when using WS doesn't work; when not using, works fine
>net-next: doesn't work, either
>
>Clearly I'm missing something here, seems there is more than this but
>I can't track it. Perhaps a corner case with rx buf collapsing?
>
>    57 packets pruned from receive queue because of socket buffer overrun
>    15 packets pruned from receive queue
>    243 packets collapsed in receive queue due to low socket buffer
>    TCPRcvCoalesce: 6019
>
>I can provide a reproducer and/or captures if it helps.
>
>Thanks,
>Marcelo
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

Dave, Eric, would you please give this a quick look? Thanks
