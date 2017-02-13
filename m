From: jeffy <jeffy.chen@rock-chips.com>
Subject: Re: [PATCH 1/3] Bluetooth: bnep: fix possible might sleep error in
 bnep_session
Date: Mon, 13 Feb 2017 12:13:00 +0800
Message-ID: <58A1324C.9070205@rock-chips.com>
References: <1485230871-22828-1-git-send-email-jeffy.chen@rock-chips.com> <20170211014044.GB101282@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth@vger.kernel.org,
        Douglas Anderson <dianders@chromium.org>,
        Johan Hedberg <johan.hedberg@intel.com>,
        Peter Hurley <peter@hurleysoftware.com>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>
To: Brian Norris <briannorris@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170211014044.GB101282@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi brian,

On 02/11/2017 09:40 AM, Brian Norris wrote:
> Hi,
>
> On Tue, Jan 24, 2017 at 12:07:49PM +0800, Jeffy Chen wrote:
>> It looks like bnep_session has same pattern as the issue reported in
>> old rfcomm:
>>
>> 	while (1) {
>> 		set_current_state(TASK_INTERRUPTIBLE);
>> 		if (condition)
>> 			break;
>> 		// may call might_sleep here
>> 		schedule();
>> 	}
>> 	__set_current_state(TASK_RUNNING);
>>
>> Which fixed at:
>> 	dfb2fae Bluetooth: Fix nested sleeps
>>
>> So let's fix it at the same way, also follow the suggestion of:
>> https://lwn.net/Articles/628628/
>>
>> Signed-off-by: Jeffy Chen <jeffy.chen@rock-chips.com>
>> ---
>>
>>   net/bluetooth/bnep/core.c | 15 +++++++++------
>>   1 file changed, 9 insertions(+), 6 deletions(-)
>>
>> diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
>> index fbf251f..da04d51 100644
>> --- a/net/bluetooth/bnep/core.c
>> +++ b/net/bluetooth/bnep/core.c
>> @@ -484,16 +484,16 @@ static int bnep_session(void *arg)
>>   	struct net_device *dev = s->dev;
>>   	struct sock *sk = s->sock->sk;
>>   	struct sk_buff *skb;
>> -	wait_queue_t wait;
>> +	DEFINE_WAIT_FUNC(wait, woken_wake_function);
>>   
>>   	BT_DBG("");
>>   
>>   	set_user_nice(current, -15);
>>   
>> -	init_waitqueue_entry(&wait, current);
>>   	add_wait_queue(sk_sleep(sk), &wait);
>>   	while (1) {
>> -		set_current_state(TASK_INTERRUPTIBLE);
>> +		/* Ensure session->terminate is updated */
>> +		smp_mb__before_atomic();
>>   
>>   		if (atomic_read(&s->terminate))
>>   			break;
>> @@ -515,9 +515,8 @@ static int bnep_session(void *arg)
>>   				break;
>>   		netif_wake_queue(dev);
>>   
>> -		schedule();
>> +		wait_woken(&wait, TASK_INTERRUPTIBLE, MAX_SCHEDULE_TIMEOUT);
>>   	}
>> -	__set_current_state(TASK_RUNNING);
>>   	remove_wait_queue(sk_sleep(sk), &wait);
>>   
>>   	/* Cleanup session */
>> @@ -666,7 +665,11 @@ int bnep_del_connection(struct bnep_conndel_req *req)
>>   	s = __bnep_get_session(req->dst);
>>   	if (s) {
>>   		atomic_inc(&s->terminate);
>> -		wake_up_process(s->task);
>> +
>> +		/* Ensure session->terminate is updated */
>> +		smp_mb__after_atomic();
>> +
> __wake_up() suggests:
>
>   * It may be assumed that this function implies a write memory barrier before
>   * changing the task state if and only if any tasks are woken up.
>
> so the above barrier is probably unnecessary. I'm not so sure about the
> one before atomic_read(); seems fine.
Got it, thanx!
>
> Other than that, I this looks ok:
>
> Reviewed-by: Brian Norris <briannorris@chromium.or>
>
> But I haven't been testing BNEP.
>
> Brian
>
>> +		wake_up_interruptible(sk_sleep(s->sock->sk));
>>   	} else
>>   		err = -ENOENT;
>>   
>> -- 
>> 2.1.4
>>
>>
>
>
