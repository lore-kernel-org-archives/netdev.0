From: jeffy <jeffy.chen@rock-chips.com>
Subject: Re: [PATCH] Bluetooth: hidp: might sleep error in hidp_session_thread
Date: Tue, 24 Jan 2017 15:29:34 +0800
Message-ID: <5887025E.9010304@rock-chips.com>
References: <1484920328-20522-1-git-send-email-jeffy.chen@rock-chips.com> <20170124023100.GA18976@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth@vger.kernel.org,
        Douglas Anderson <dianders@chromium.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Peter Hurley <peter@hurleysoftware.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Guenter Roeck <linux@roeck-us.net>
To: Brian Norris <briannorris@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from regular1.263xmail.com ([211.150.99.138]:53171 "EHLO
        regular1.263xmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750713AbdAXHaE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 02:30:04 -0500
In-Reply-To: <20170124023100.GA18976@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi brian,

On 01/24/2017 10:31 AM, Brian Norris wrote:
> Hi Jeffy,
>
> On Fri, Jan 20, 2017 at 09:52:08PM +0800, Jeffy Chen wrote:
>> [   39.044329] do not call blocking ops when !TASK_RUNNING; state=1 set
>> at [<ffffffbffc290358>] hidp_session_thread+0x110/0x568 [hidp]
>> ...
>> [   40.159664] Call trace:
>> [   40.162122] [<ffffffc00024ae08>] __might_sleep+0x64/0x90
>> [   40.167443] [<ffffffc00080568c>] lock_sock_nested+0x30/0x78
>> [   40.173047] [<ffffffbffc1b3ca0>] l2cap_sock_sendmsg+0x90/0xf0
>> [bluetooth]
>> [   40.179842] [<ffffffc0008012c4>] sock_sendmsg+0x4c/0x68
>> [   40.185072] [<ffffffc000801414>] kernel_sendmsg+0x54/0x68
>> [   40.190477] [<ffffffbffc28f4d0>] hidp_send_frame+0x78/0xa0 [hidp]
>> [   40.196574] [<ffffffbffc28f53c>] hidp_process_transmit+0x44/0x98
>> [hidp]
>> [   40.203191] [<ffffffbffc2905ac>] hidp_session_thread+0x364/0x568
>> [hidp]
> Am I crazy, or are several other protocols broken like this too? I see a
> similar structure in net/bluetooth/bnep/core.c and
> net/bluetooth/cmtp/core.c, at least, each of which also call
> kernel_sendmsg(), which might be an l2cap socket (...I think? I'm not a
> bluetooth expert really).
Thanx, uploaded a new serial of patchset, which contains hidp & cmtp & 
bnep:9534023/9534025/9534027
>
>> Following (https://lwn.net/Articles/628628/).
>>
>> Signed-off-by: Jeffy Chen <jeffy.chen@rock-chips.com>
>> ---
>>
>>   net/bluetooth/hidp/core.c | 15 +++++++++------
>>   1 file changed, 9 insertions(+), 6 deletions(-)
>>
>> diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
>> index 0bec458..bfd3fb8 100644
>> --- a/net/bluetooth/hidp/core.c
>> +++ b/net/bluetooth/hidp/core.c
>> @@ -1180,7 +1180,9 @@ static void hidp_session_run(struct hidp_session *session)
>>   	struct sock *ctrl_sk = session->ctrl_sock->sk;
>>   	struct sock *intr_sk = session->intr_sock->sk;
>>   	struct sk_buff *skb;
>> +	DEFINE_WAIT_FUNC(wait, woken_wake_function);
>>   
>> +	add_wait_queue(sk_sleep(intr_sk), &wait);
>>   	for (;;) {
>>   		/*
>>   		 * This thread can be woken up two ways:
>> @@ -1188,12 +1190,10 @@ static void hidp_session_run(struct hidp_session *session)
>>   		 *    session->terminate flag and wakes this thread up.
>>   		 *  - Via modifying the socket state of ctrl/intr_sock. This
>>   		 *    thread is woken up by ->sk_state_changed().
>> -		 *
>> -		 * Note: set_current_state() performs any necessary
>> -		 * memory-barriers for us.
>>   		 */
>> -		set_current_state(TASK_INTERRUPTIBLE);
>>   
>> +		/* Ensure session->terminate is updated */
>> +		smp_mb__before_atomic();
>>   		if (atomic_read(&session->terminate))
>>   			break;
>>   
>> @@ -1227,11 +1227,14 @@ static void hidp_session_run(struct hidp_session *session)
>>   		hidp_process_transmit(session, &session->ctrl_transmit,
>>   				      session->ctrl_sock);
>>   
>> -		schedule();
>> +		wait_woken(&wait, TASK_INTERRUPTIBLE, MAX_SCHEDULE_TIMEOUT);
> I think this looks mostly good, except what about the
> hidp_session_terminate() condition? In that case, you're running
> wake_up_process() -- which won't set WQ_FLAG_WOKEN for us. So what
> happens if we see a hidp_session_terminate() call in between the check
> for the ->terminate count, but before we call wait_woken()? IIUC, I
> think we'll just ignore the call and keep waiting for the next wake
> signal.
>
> I think you might need to rework hidp_session_terminate() too, to
> actually target the wait queue and not just the processes.
>
> IIUC, of course. I could be wrong...
Ok, that make sense, thanx for point that out.
>
> Brian
>
>>   	}
>> +	remove_wait_queue(sk_sleep(intr_sk), &wait);
>>   
>>   	atomic_inc(&session->terminate);
>> -	set_current_state(TASK_RUNNING);
>> +
>> +	/* Ensure session->terminate is updated */
>> +	smp_mb__after_atomic();
>>   }
>>   
>>   /*
>> -- 
>> 2.1.4
>>
>>
>
>
