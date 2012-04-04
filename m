From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: allow splice() to build full TSO packets
Date: Wed, 04 Apr 2012 08:15:28 +0200
Message-ID: <1333520128.18626.382.camel@edumazet-glaptop>
References: <20120403.172126.672236532461758456.davem@davemloft.net>
	 <1333488689.18626.331.camel@edumazet-glaptop>
	 <20120403.173614.962252876842659412.davem@davemloft.net>
	 <20120403.185055.1492466245744649655.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	ycheng@google.com, hkchu@google.com, maze@google.com,
	maheshb@google.com, ilpo.jarvinen@helsinki.fi, nanditad@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:41795 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711Ab2DDGPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 02:15:35 -0400
Received: by wejx9 with SMTP id x9so276470wej.19
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 23:15:34 -0700 (PDT)
In-Reply-To: <20120403.185055.1492466245744649655.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-03 at 18:50 -0400, David Miller wrote:

> Eric, sorry to be a pain, but to clear my conscience can you tell me
> if the sendfile() path do the right thing with your change too?
> 
> I'm concerned about returning back into userspace without at least
> one tcp_push() at the end.

Absolutely, this patch also handles the sendfile() path.

do_sendfile() ->
 do_splice_direct() ->
  splice_direct_to_actor() -> 
   ...
    splice_from_pipe() ->
     splice_from_pipe_feed() ->
      pipe_to_sendpage()  more = (sd->flags & SPLICE_F_MORE) || sd->len < sd->total_len
       sock_sendpage() if (more) flags |= MSG_MORE;
        kernel_sendpage()
         inet_sendpage()
          tcp_sendpage()

So the push is perfomed at the end (last page doesnt have MSG_MORE flag)

Here is what we got _before_ the patch using "netperf -t TCP_SENDFILE --
-m 16K"


07:50:14.097137 IP A > B: Flags [S], seq 2635999430, win 14600, options [mss 1460,sackOK,TS val 56315934 ecr 0,nop,wscale 7], length 0
07:50:14.107211 IP B > A: Flags [S.], seq 2438979637, ack 2635999431, win 14480, options [mss 1460,sackOK,TS val 56315935 ecr 56315934,nop,wscale 7], length 0
07:50:14.117318 IP A > B: Flags [.], ack 1, win 115, options [nop,nop,TS val 56315936 ecr 56315935], length 0
07:50:14.117534 IP A > B: Flags [.], seq 1:2897, ack 1, win 115, options [nop,nop,TS val 56315937 ecr 56315935], length 2896
07:50:14.117543 IP A > B: Flags [.], seq 2897:4345, ack 1, win 115, options [nop,nop,TS val 56315937 ecr 56315935], length 1448
07:50:14.127612 IP B > A: Flags [.], ack 2897, win 136, options [nop,nop,TS val 56315938 ecr 56315937], length 0
07:50:14.127618 IP B > A: Flags [.], ack 4345, win 159, options [nop,nop,TS val 56315938 ecr 56315937], length 0
07:50:14.137698 IP A > B: Flags [.], seq 4345:8689, ack 1, win 115, options [nop,nop,TS val 56315939 ecr 56315938], length 4344
07:50:14.137731 IP A > B: Flags [.], seq 8689:11585, ack 1, win 115, options [nop,nop,TS val 56315939 ecr 56315938], length 2896
07:50:14.147906 IP B > A: Flags [.], ack 8689, win 181, options [nop,nop,TS val 56315940 ecr 56315939], length 0
07:50:14.147910 IP B > A: Flags [.], ack 11585, win 204, options [nop,nop,TS val 56315940 ecr 56315939], length 0
07:50:14.158012 IP A > B: Flags [.], seq 11585:17377, ack 1, win 115, options [nop,nop,TS val 56315941 ecr 56315940], length 5792
07:50:14.158022 IP A > B: Flags [P.], seq 17377:18825, ack 1, win 115, options [nop,nop,TS val 56315941 ecr 56315940], length 1448
07:50:14.158171 IP A > B: Flags [.], seq 18825:21721, ack 1, win 115, options [nop,nop,TS val 56315941 ecr 56315940], length 2896
07:50:14.168361 IP B > A: Flags [.], ack 17377, win 227, options [nop,nop,TS val 56315942 ecr 56315941], length 0
07:50:14.168366 IP B > A: Flags [.], ack 18825, win 249, options [nop,nop,TS val 56315942 ecr 56315941], length 0
07:50:14.168424 IP B > A: Flags [.], ack 21721, win 272, options [nop,nop,TS val 56315942 ecr 56315941], length 0
07:50:14.178460 IP A > B: Flags [.], seq 21721:28961, ack 1, win 115, options [nop,nop,TS val 56315943 ecr 56315942], length 7240
07:50:14.178466 IP A > B: Flags [.], seq 28961:34753, ack 1, win 115, options [nop,nop,TS val 56315943 ecr 56315942], length 5792
07:50:14.188668 IP B > A: Flags [.], ack 28961, win 295, options [nop,nop,TS val 56315944 ecr 56315943], length 0
07:50:14.188675 IP B > A: Flags [.], ack 34753, win 317, options [nop,nop,TS val 56315944 ecr 56315943], length 0
07:50:14.198772 IP A > B: Flags [.], seq 34753:44889, ack 1, win 115, options [nop,nop,TS val 56315945 ecr 56315944], length 10136
07:50:14.198778 IP A > B: Flags [P.], seq 44889:47785, ack 1, win 115, options [nop,nop,TS val 56315945 ecr 56315944], length 2896
07:50:14.208990 IP B > A: Flags [.], ack 44889, win 340, options [nop,nop,TS val 56315946 ecr 56315945], length 0
07:50:14.208995 IP B > A: Flags [.], ack 47785, win 362, options [nop,nop,TS val 56315946 ecr 56315945], length 0
07:50:14.219081 IP A > B: Flags [.], seq 47785:60817, ack 1, win 115, options [nop,nop,TS val 56315947 ecr 56315946], length 13032
07:50:14.219090 IP A > B: Flags [.], seq 60817:68057, ack 1, win 115, options [nop,nop,TS val 56315947 ecr 56315946], length 7240
07:50:14.229357 IP B > A: Flags [.], ack 60817, win 385, options [nop,nop,TS val 56315948 ecr 56315947], length 0
07:50:14.229361 IP B > A: Flags [.], ack 68057, win 408, options [nop,nop,TS val 56315948 ecr 56315947], length 0
07:50:14.239450 IP A > B: Flags [.], seq 68057:73849, ack 1, win 115, options [nop,nop,TS val 56315949 ecr 56315948], length 5792
07:50:14.239458 IP A > B: Flags [.], seq 73849:82537, ack 1, win 115, options [nop,nop,TS val 56315949 ecr 56315948], length 8688
07:50:14.239492 IP A > B: Flags [.], seq 82537:86881, ack 1, win 115, options [nop,nop,TS val 56315949 ecr 56315948], length 4344
07:50:14.249694 IP B > A: Flags [.], ack 73849, win 430, options [nop,nop,TS val 56315950 ecr 56315949], length 0
07:50:14.249699 IP B > A: Flags [.], ack 82537, win 453, options [nop,nop,TS val 56315950 ecr 56315949], length 0
07:50:14.249753 IP B > A: Flags [.], ack 86881, win 476, options [nop,nop,TS val 56315950 ecr 56315949], length 0
07:50:14.259790 IP A > B: Flags [.], seq 86881:98465, ack 1, win 115, options [nop,nop,TS val 56315951 ecr 56315950], length 11584
07:50:14.259796 IP A > B: Flags [.], seq 98465:99913, ack 1, win 115, options [nop,nop,TS val 56315951 ecr 56315950], length 1448
07:50:14.259826 IP A > B: Flags [.], seq 99913:108601, ack 1, win 115, options [nop,nop,TS val 56315951 ecr 56315950], length 8688
07:50:14.259830 IP A > B: Flags [P.], seq 108601:112945, ack 1, win 115, options [nop,nop,TS val 56315951 ecr 56315950], length 4344
