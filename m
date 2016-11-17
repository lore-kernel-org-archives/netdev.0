From: Colin Cross <ccross@android.com>
Subject: Re: [Patch net] af_unix: revert "af_unix: use freezable blocking
 calls in read"
Date: Thu, 17 Nov 2016 14:30:34 -0800
Message-ID: <CAMbhsRSQ+eVid4OG_xVMDyuZGfOJ2gj6DvHakOH5vbu3ySHF3A@mail.gmail.com>
References: <1479420564-15799-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, dvyukov@google.com,
        Tejun Heo <tj@kernel.org>,
        "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35794 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752421AbcKQWag (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 17:30:36 -0500
Received: by mail-wm0-f51.google.com with SMTP id a197so1300488wmd.0
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 14:30:36 -0800 (PST)
In-Reply-To: <1479420564-15799-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 17, 2016 at 2:09 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> Commit 2b15af6f95 ("af_unix: use freezable blocking calls in read")
> converts schedule_timeout() to its freezable version, it was probably
> correct at that time, but later, commit 2b514574f7e8
> ("net: af_unix: implement splice for stream af_unix sockets") breaks
> the strong requirement for a freezable sleep, according to
> commit 0f9548ca1091:
>
>     We shouldn't try_to_freeze if locks are held.  Holding a lock can cause a
>     deadlock if the lock is later acquired in the suspend or hibernate path
>     (e.g.  by dpm).  Holding a lock can also cause a deadlock in the case of
>     cgroup_freezer if a lock is held inside a frozen cgroup that is later
>     acquired by a process outside that group.
>
> The pipe_lock is still held at that point. So just revert commit 2b15af6f95.

On my phone 77 threads are blocked in unix_stream_recvmsg.  A simple
revert of this patch will cause every one of those threads to wake up
twice per suspend cycle, which can be multiple times a second.  How
about adding a freezable flag to unix_stream_read_state so
unix_stream_recvmsg can stay freezable, and unix_stream_splice_read
can be unfreezable?
