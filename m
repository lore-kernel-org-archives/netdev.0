From: Stephen Boyd <sboyd@codeaurora.org>
Subject: Re: [PATCH 1/2] workqueue: Catch more locking problems with flush_work()
Date: Thu, 19 Apr 2012 11:36:32 -0700
Message-ID: <4F905B30.4080501@codeaurora.org>
References: <1334805958-29119-1-git-send-email-sboyd@codeaurora.org> <20120419081002.GB3963@zhy>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	netdev@vger.kernel.org, Ben Dooks <ben-linux@fluff.org>
To: Yong Zhang <yong.zhang0@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120419081002.GB3963@zhy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/19/12 01:10, Yong Zhang wrote:
> On Wed, Apr 18, 2012 at 08:25:57PM -0700, Stephen Boyd wrote:
>> If a workqueue is flushed but the work item is not scheduled to
>> run, lockdep checking will be circumvented. For example:
>>
>>  static DEFINE_MUTEX(mutex);
>>
>>  static void my_work(struct work_struct *w)
>>  {
>>          mutex_lock(&mutex);
>>          mutex_unlock(&mutex);
>>  }
>>
>>  static DECLARE_WORK(work, my_work);
>>
>>  static int __init start_test_module(void)
>>  {
>>          schedule_work(&work);
>>          return 0;
>>  }
>>  module_init(start_test_module);
>>
>>  static void __exit stop_test_module(void)
>>  {
>>          mutex_lock(&mutex);
>>          flush_work(&work);
>>          mutex_unlock(&mutex);
>>  }
>>  module_exit(stop_test_module);
>>
>> would only print a warning if the work item was actively running
>> when flush_work() was called. Otherwise flush_work() returns
>> early. In this trivial example nothing could go wrong, but if the
>> work item is schedule via an interrupt we could potentially have a
>> scenario where the work item is running just at the time flush_work()
> You mean flush_work() could be called in interupt? I don't it is
> possible.

No.

>
>> is called. This could become a classic AB-BA locking problem.
> I don't see how the deadlock happen, could you please be more
> specific?
>

Does looking at the second patch help? Basically schedule_work() can run
the callback right between the time the mutex is acquired and
flush_work() is called:

CPU0                        CPU1

<irq>
  schedule_work()           mutex_lock(&mutex)
<irq return>
    my_work()               flush_work() 
      mutex_lock(&mutex)    
      <deadlock>

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
