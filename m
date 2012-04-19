From: Stephen Boyd <sboyd@codeaurora.org>
Subject: Re: [PATCH 1/2] workqueue: Catch more locking problems with flush_work()
Date: Thu, 19 Apr 2012 11:10:41 -0700
Message-ID: <4F905521.9020901@codeaurora.org>
References: <1334805958-29119-1-git-send-email-sboyd@codeaurora.org> <20120419152841.GA10553@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ben Dooks <ben-linux@fluff.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120419152841.GA10553@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/19/12 08:28, Tejun Heo wrote:
> On Wed, Apr 18, 2012 at 08:25:57PM -0700, Stephen Boyd wrote:
>> @@ -2513,8 +2513,11 @@ bool flush_work(struct work_struct *work)
>>  		wait_for_completion(&barr.done);
>>  		destroy_work_on_stack(&barr.work);
>>  		return true;
>> -	} else
>> +	} else {
>> +		lock_map_acquire(&work->lockdep_map);
>> +		lock_map_release(&work->lockdep_map);
>>  		return false;
> We don't have this annotation when start_flush_work() succeeds either,
> right?  IOW, would lockdep trigger when an actual deadlock happens?

I believe it does although I haven't tested it.

> If not, why not add the acquire/release() before flush_work() does
> anything?
>

I was worried about causing false positive lockdep warnings in the case
that start_flush_work() succeeds and returns true. In that case, lockdep
is told about the cwq lockdep map:

static bool start_flush_work(struct work_struct *work, struct wq_barrier *barr,
                             bool wait_executing)
{

        .....

        if (cwq->wq->saved_max_active == 1 || cwq->wq->flags & WQ_RESCUER)
                lock_map_acquire(&cwq->wq->lockdep_map);
        else
                lock_map_acquire_read(&cwq->wq->lockdep_map);


and so if we acquired the work->lockdep_map before the
cwq->wq->lockdep_map we would get a warning about ABBA between these two
lockdep maps. At least that is what I'm lead to believe when I look at
what process_one_work() is doing. Please correct me if I'm wrong.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
