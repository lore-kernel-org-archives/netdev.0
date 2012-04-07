From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: ipv6: tunnel: hang when destroying ipv6 tunnel
Date: Sat, 7 Apr 2012 09:06:50 +0900
Message-ID: <201204070906.HHC13855.QOSFVOMtFFLJOH@I-love.SAKURA.ne.jp>
References: <201204011221.GAG51016.JQFSFFOtLOMVHO@I-love.SAKURA.ne.jp>
	<CA+1xoqe+T=iUtUeFdeqmRvMZ7TMCgkLs_1QYv-4YNtn-jCoMCQ@mail.gmail.com>
	<201204052329.EBH52139.FFOLQMOJSVHOFt@I-love.SAKURA.ne.jp>
	<201204062044.EJE13062.OLMQtSVFHOFOJF@I-love.SAKURA.ne.jp>
	<20120406180905.GA10835@llnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: levinsasha928@gmail.com, ericvh@gmail.com, oleg@redhat.com,
	eric.dumazet@gmail.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davej@redhat.com
To: garlick@llnl.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:65398 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412Ab2DGAGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 20:06:54 -0400
In-Reply-To: <20120406180905.GA10835@llnl.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jim Garlick wrote:
> > I think this loop is bad with regard to response to SIGKILL.
> > If wait_event_interruptible() was interrupted by SIGKILL, it will
> > spin until req->status >= REQ_STATUS_RCVD becomes true.
> > Rather,
> > 
> > 	if ((c->status == Connected) && (type == P9_TFLUSH))
> > 		err = wait_event_killable(*req->wq,
> > 					  req->status >= REQ_STATUS_RCVD);
> > 	else
> > 		err = wait_event_interruptible(*req->wq,
> > 					       req->status >= REQ_STATUS_RCVD);
> > 
> > would be safer.
> 
> Does that work?  What prevents p9_client_rpc() from recursing via
> p9_client_flush() on receipt of SIGKILL? 

Sorry, I'm not a 9p user and I can't test whether that works or not.
But at least, continuing the loop even after SIGKILL is not good.
If you have to wait for req->status >= REQ_STATUS_RCVD becomes true, can you
use a kernel thread that waits req->status >= REQ_STATUS_RCVD to become true
and delegate the job of notifying the server from a userspace task to the
kernel thread?

> Yes but in the unlikely event that this happens, the effect is a small
> memory leak for the duration of the mount.  On the other hand if the
> fid is destroyed without successfully informing the server, then
> subsequent operations that involve new file references will fail
> when that fid number is reused, and the mount becomes unusable.

I don't know whether Sasha's problem is caused by this patch or not.
But p9_client_clunk() is called from many functions in fs/9p/ directory.
They are assuming that p9_client_clunk() will call p9_fid_destroy() but
this patch is breaking that assumption. I think this is the cause of hang which
Sasha is experiencing because Sasha's trace shows that call_usermodehelper() is
blocked by functions in fs/9p/ directory. Seems inconsistency state problem.
