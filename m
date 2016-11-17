From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] af_unix: revert "af_unix: use freezable blocking
 calls in read"
Date: Thu, 17 Nov 2016 14:47:10 -0800
Message-ID: <CAM_iQpWo5QteX+WtWCgkKL9ras5+GeGUgPYJsReg9Wm_TXNRMw@mail.gmail.com>
References: <1479420564-15799-1-git-send-email-xiyou.wangcong@gmail.com> <CAMbhsRSQ+eVid4OG_xVMDyuZGfOJ2gj6DvHakOH5vbu3ySHF3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>,
        "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
To: Colin Cross <ccross@android.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f196.google.com ([209.85.213.196]:35417 "EHLO
        mail-yb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750849AbcKQWrb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 17:47:31 -0500
Received: by mail-yb0-f196.google.com with SMTP id d59so9070840ybi.2
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 14:47:31 -0800 (PST)
In-Reply-To: <CAMbhsRSQ+eVid4OG_xVMDyuZGfOJ2gj6DvHakOH5vbu3ySHF3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 17, 2016 at 2:30 PM, Colin Cross <ccross@android.com> wrote:
> On Thu, Nov 17, 2016 at 2:09 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> Commit 2b15af6f95 ("af_unix: use freezable blocking calls in read")
>> converts schedule_timeout() to its freezable version, it was probably
>> correct at that time, but later, commit 2b514574f7e8
>> ("net: af_unix: implement splice for stream af_unix sockets") breaks
>> the strong requirement for a freezable sleep, according to
>> commit 0f9548ca1091:
>>
>>     We shouldn't try_to_freeze if locks are held.  Holding a lock can cause a
>>     deadlock if the lock is later acquired in the suspend or hibernate path
>>     (e.g.  by dpm).  Holding a lock can also cause a deadlock in the case of
>>     cgroup_freezer if a lock is held inside a frozen cgroup that is later
>>     acquired by a process outside that group.
>>
>> The pipe_lock is still held at that point. So just revert commit 2b15af6f95.
>
> On my phone 77 threads are blocked in unix_stream_recvmsg.  A simple
> revert of this patch will cause every one of those threads to wake up
> twice per suspend cycle, which can be multiple times a second.  How
> about adding a freezable flag to unix_stream_read_state so
> unix_stream_recvmsg can stay freezable, and unix_stream_splice_read
> can be unfreezable?

Fair enough, I didn't know it could have such an impact.
I will send v2.

Thanks.
