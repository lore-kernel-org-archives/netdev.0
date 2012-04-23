From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHv2] workqueue: Catch more locking problems with
 flush_work()
Date: Mon, 23 Apr 2012 11:07:57 -0700
Message-ID: <20120423180757.GD5406@google.com>
References: <20120420173529.GD32324@google.com>
 <1334968130-20724-1-git-send-email-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ben Dooks <ben-linux@fluff.org>,
	Yong Zhang <yong.zhang0@gmail.com>
To: Stephen Boyd <sboyd@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:33826 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784Ab2DWSIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 14:08:20 -0400
Content-Disposition: inline
In-Reply-To: <1334968130-20724-1-git-send-email-sboyd@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 20, 2012 at 05:28:50PM -0700, Stephen Boyd wrote:
> If a workqueue is flushed with flush_work() lockdep checking can
> be circumvented. For example:
> 
>  static DEFINE_MUTEX(mutex);
> 
>  static void my_work(struct work_struct *w)
>  {
>          mutex_lock(&mutex);
>          mutex_unlock(&mutex);
>  }
> 
>  static DECLARE_WORK(work, my_work);
> 
>  static int __init start_test_module(void)
>  {
>          schedule_work(&work);
>          return 0;
>  }
>  module_init(start_test_module);
> 
>  static void __exit stop_test_module(void)
>  {
>          mutex_lock(&mutex);
>          flush_work(&work);
>          mutex_unlock(&mutex);
>  }
>  module_exit(stop_test_module);
> 
> would not always print a warning when flush_work() was called.
> In this trivial example nothing could go wrong since we are
> guaranteed module_init() and module_exit() don't run concurrently,
> but if the work item is schedule asynchronously we could have a
> scenario where the work item is running just at the time flush_work()
> is called resulting in a classic ABBA locking problem.
> 
> Add a lockdep hint by acquiring and releasing the work item
> lockdep_map in flush_work() so that we always catch this
> potential deadlock scenario.
> 
> Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>

Applied to wq/for-3.5.  Let's see whether it triggers spuriously.

Thanks.

-- 
tejun
