From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: initialize max window for a new fastopen socket
Date: Thu, 19 Jan 2017 11:41:03 -0500 (EST)
Message-ID: <20170119.114103.1784185156530691440.davem@davemloft.net>
References: <1484832999-1849-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, ycheng@google.com,
        ncardwell@google.com
To: alexey.kodanev@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59980 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753551AbdASQlF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 11:41:05 -0500
In-Reply-To: <1484832999-1849-1-git-send-email-alexey.kodanev@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Kodanev <alexey.kodanev@oracle.com>
Date: Thu, 19 Jan 2017 16:36:39 +0300

> Found that if we run LTP netstress test with large MSS (65K),
> the first attempt from server to send data comparable to this
> MSS on fastopen connection will be delayed by the probe timer.
> 
> Here is an example:
> 
>      < S  seq 0:0 win 43690 options [mss 65495 wscale 7 tfo cookie] length 32
>      > S. seq 0:0 ack 1 win 43690 options [mss 65495 wscale 7] length 0
>      < .  ack 1 win 342 length 0
> 
> Inside tcp_sendmsg(), tcp_send_mss() returns max MSS in 'mss_now',
> as well as in 'size_goal'. This results the segment not queued for
> transmition until all the data copied from user buffer. Then, inside
> __tcp_push_pending_frames(), it breaks on send window test and
> continues with the check probe timer.
> 
> Fragmentation occurs in tcp_write_wakeup()...
> 
> +0.2 > P. seq 1:43777 ack 1 win 342 length 43776
>      < .  ack 43777, win 1365 length 0
>      > P. seq 43777:65001 ack 1 win 342 options [...] length 21224
>      ...
> 
> This also contradicts with the fact that we should bound to the half
> of the window if it is large.
> 
> Fix this flaw by correctly initializing max_window. Before that, it
> could have large values that affect further calculations of 'size_goal'.
> 
> Fixes: 168a8f58059a ("tcp: TCP Fast Open Server - main code path")
> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>

Applied and queued up for -stable, thanks.
