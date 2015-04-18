From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCHSET] printk, netconsole: implement reliable netconsole
Date: Sat, 18 Apr 2015 22:09:35 +0900
Message-ID: <201504182209.FDC13506.FHFVOOQMJLFtSO@I-love.SAKURA.ne.jp>
References: <20150417174522.GD16743@htj.duckdns.org>
	<201504180303.GAB26011.OLJFSMVFFOHtOQ@I-love.SAKURA.ne.jp>
	<20150417180732.GF16743@htj.duckdns.org>
	<201504180320.CFG26062.FtSJLOOQOFVFMH@I-love.SAKURA.ne.jp>
	<20150417182654.GG16743@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150417182654.GG16743@htj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tejun Heo wrote:
> > If we can assume that scheduler is working, adding a kernel thread that
> > does
> > 
> >   while (1) {
> >       read messages with metadata from /dev/kmsg
> >       send them using UDP network
> >   }
> > 
> > might be easier than modifying netconsole module.
> 
> But, I mean, if we are gonna do that in kernel, we better do it
> properly where it belongs.  What's up with "easier than modifying
> netconsole module"?  Why is netconsole special?  And how would the
> above be any less complex than a single timer function?  What am I
> missing?

User space daemon is sometimes disturbed unexpectedly due to

  (a) SIGKILL by OOM-killer
  (b) spurious ptrace() by somebody
  (c) spurious signals such as SIGSTOP / SIGINT
  (d) stalls triggered by page faults under OOM condition
  (e) other problems such as scheduler being not working

We have built-in protection for (a) named /proc/$pid/oom_score_adj , but
we need to configure access control modules for protecting (b) and (c),
and we don't have protection for (d). Thinking from OOM stall discussion,
(d) is fatal when trying to obtain kernel messages under problematic
condition. I thought that a kernel thread that does

  while (1) {
      read messages with metadata from /dev/kmsg
      send them using UDP network
  }

is automatically protected from (a), (b), (c) and (d), and it could be
implemented outside of netconsole module.
