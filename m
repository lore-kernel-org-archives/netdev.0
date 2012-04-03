From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: allow splice() to build full TSO packets
Date: Tue, 03 Apr 2012 23:31:29 +0200
Message-ID: <1333488689.18626.331.camel@edumazet-glaptop>
References: <1333481821.18626.322.camel@edumazet-glaptop>
	 <20120403.172126.672236532461758456.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	ycheng@google.com, hkchu@google.com, maze@google.com,
	maheshb@google.com, ilpo.jarvinen@helsinki.fi, nanditad@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:58340 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754866Ab2DCVbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 17:31:35 -0400
Received: by wejx9 with SMTP id x9so102913wej.19
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 14:31:34 -0700 (PDT)
In-Reply-To: <20120403.172126.672236532461758456.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-03 at 17:21 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 03 Apr 2012 21:37:01 +0200
> 
> > vmsplice()/splice(pipe, socket) call do_tcp_sendpages() one page at a
> > time, adding at most 4096 bytes to an skb. (assuming PAGE_SIZE=4096)
> > 
> > The call to tcp_push() at the end of do_tcp_sendpages() forces an
> > immediate xmit when pipe is not already filled, and tso_fragment() try
> > to split these skb to MSS multiples.
> > 
> > 4096 bytes are usually split in a skb with 2 MSS, and a remaining
> > sub-mss skb (assuming MTU=1500)
> 
> Interesting.
> 
> But why doesn't TCP_NAGLE_CORK save us?  That gets passed down into
> the push pending frames logic when MSG_MORE is specified.
> 
> As far as I can tell, the combination of TCP_NAGLE_CORK and the TSO
> deferral logic should do the right thing here.
> 
> Obviously you see different behavior, but why?
> 
> Also, by eliding the tcp_push() call you are introducing other side
> effects:
> 
> 1) we won't do the tcp_mark_push logic
> 
> 2) we don't set the URG seq
> 
> I think #2 can never happen in the vmsplice/splice path, but #1 might
> matter.
> 
> That's why I want to concentrate on why the tcp_push() path doesn't
> behave properly when MSG_MORE is set.

It behaves properly I think, but in the tcp_sendmsg() perspective only.

The code in tcp_sendmsg() and do_tcp_sendpages() is similar (actually
probably copy/pasted) but the thing is tcp_sendmsg() is called once per
sendmsg() call (and the push logic is OK at the end of it), while a
single splice() system call can call do_tcp_sendpages() 16 times (or
even more if pipe buffer was extended by fcntl(F_SETPIPE_SZ))

Maybe a real fix would be to call do_tcp_sendpages() exactly once, but I
tried this today and found needed surgery was complex). Also this would
lock socket for a long period and could add latencies because of backlog
processing.
