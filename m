From: jeffy <jeffy.chen@rock-chips.com>
Subject: Re: [PATCH v3 3/3] Bluetooth: hidp: fix possible might sleep error
 in hidp_session_thread
Date: Tue, 14 Feb 2017 08:57:50 +0800
Message-ID: <58A2560E.6000504@rock-chips.com>
References: <1486959154-25810-1-git-send-email-jeffy.chen@rock-chips.com> <1486959154-25810-3-git-send-email-jeffy.chen@rock-chips.com> <CAKdAkRTxN3TrNYwFB1AXz4XgOoJdKpgkgHSdqf299CoHfMZ2vQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth@vger.kernel.org,
        Brian Norris <briannorris@chromium.org>,
        Douglas Anderson <dianders@chromium.org>,
        Johan Hedberg <johan.hedberg@intel.com>,
        Peter Hurley <peter@hurleysoftware.com>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        lkml <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKdAkRTxN3TrNYwFB1AXz4XgOoJdKpgkgHSdqf299CoHfMZ2vQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dmitry,

On 02/14/2017 05:27 AM, Dmitry Torokhov wrote:
> Hi Jeffy,
>
> On Sun, Feb 12, 2017 at 8:12 PM, Jeffy Chen <jeffy.chen@rock-chips.com> wrote:
>> It looks like hidp_session_thread has same pattern as the issue reported in
>> old rfcomm:
>>
>>          while (1) {
>>                  set_current_state(TASK_INTERRUPTIBLE);
>>                  if (condition)
>>                          break;
>>                  // may call might_sleep here
>>                  schedule();
>>          }
>>          __set_current_state(TASK_RUNNING);
>>
>> Which fixed at:
>>          dfb2fae Bluetooth: Fix nested sleeps
>>
>> So let's fix it at the same way, also follow the suggestion of:
>> https://lwn.net/Articles/628628/
>>
>> Signed-off-by: Jeffy Chen <jeffy.chen@rock-chips.com>
>> 1/ Fix could not wake up by wake attempts on original wait queues.
>> 2/ Remove unnecessary memory barrier before wake_up_* functions.
>>
>> ---
>>
>> Changes in v3: None
>> Changes in v2: None
>>
>>   net/bluetooth/hidp/core.c | 33 ++++++++++++++++++++++-----------
>>   1 file changed, 22 insertions(+), 11 deletions(-)
>>
>> diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
>> index 0bec458..076bc50 100644
>> --- a/net/bluetooth/hidp/core.c
>> +++ b/net/bluetooth/hidp/core.c
>> @@ -36,6 +36,7 @@
>>   #define VERSION "1.2"
>>
>>   static DECLARE_RWSEM(hidp_session_sem);
>> +static DECLARE_WAIT_QUEUE_HEAD(hidp_session_wq);
>>   static LIST_HEAD(hidp_session_list);
>>
>>   static unsigned char hidp_keycode[256] = {
>> @@ -1068,12 +1069,12 @@ static int hidp_session_start_sync(struct hidp_session *session)
>>    * Wake up session thread and notify it to stop. This is asynchronous and
>>    * returns immediately. Call this whenever a runtime error occurs and you want
>>    * the session to stop.
>> - * Note: wake_up_process() performs any necessary memory-barriers for us.
>> + * Note: wake_up_interruptible() performs any necessary memory-barriers for us.
>>    */
>>   static void hidp_session_terminate(struct hidp_session *session)
>>   {
>>          atomic_inc(&session->terminate);
>> -       wake_up_process(session->task);
>> +       wake_up_interruptible(&hidp_session_wq);
>>   }
>>
>>   /*
>> @@ -1180,7 +1181,9 @@ static void hidp_session_run(struct hidp_session *session)
>>          struct sock *ctrl_sk = session->ctrl_sock->sk;
>>          struct sock *intr_sk = session->intr_sock->sk;
>>          struct sk_buff *skb;
>> +       DEFINE_WAIT_FUNC(wait, woken_wake_function);
>>
>> +       add_wait_queue(&hidp_session_wq, &wait);
>>          for (;;) {
>>                  /*
>>                   * This thread can be woken up two ways:
>> @@ -1188,12 +1191,10 @@ static void hidp_session_run(struct hidp_session *session)
>>                   *    session->terminate flag and wakes this thread up.
>>                   *  - Via modifying the socket state of ctrl/intr_sock. This
>>                   *    thread is woken up by ->sk_state_changed().
>> -                *
>> -                * Note: set_current_state() performs any necessary
>> -                * memory-barriers for us.
>>                   */
>> -               set_current_state(TASK_INTERRUPTIBLE);
>>
>> +               /* Ensure session->terminate is updated */
>> +               smp_mb__before_atomic();
>>                  if (atomic_read(&session->terminate))
>>                          break;
>>
>> @@ -1227,11 +1228,22 @@ static void hidp_session_run(struct hidp_session *session)
>>                  hidp_process_transmit(session, &session->ctrl_transmit,
>>                                        session->ctrl_sock);
>>
>> -               schedule();
>> +               wait_woken(&wait, TASK_INTERRUPTIBLE, MAX_SCHEDULE_TIMEOUT);
>>          }
>> +       remove_wait_queue(&hidp_session_wq, &wait);
>>
>>          atomic_inc(&session->terminate);
>> -       set_current_state(TASK_RUNNING);
>> +
>> +       /* Ensure session->terminate is updated */
>> +       smp_mb__after_atomic();
>> +}
>> +
>> +int hidp_session_wake_function(wait_queue_t *wait, unsigned int mode,
>> +                              int sync, void *key)
> static?
Oops, sure.
>
>> +{
>> +       wake_up_interruptible(&hidp_session_wq);
>> +
>> +       return default_wake_function(wait, mode, sync, key);
> I do not think you need to call default_wake_function() here: the
> process is waiting on hidp_session_wq, so the wakeup above is what
> will wake up the session. By the time you get to call
> default_wake_function() task will already be in wrong state. I think
> we should simply return "false" instead of calling
> default_wake_function().
Ok, thanx.
>
>>   }
>>
>>   /*
>> @@ -1244,7 +1256,8 @@ static void hidp_session_run(struct hidp_session *session)
>>   static int hidp_session_thread(void *arg)
>>   {
>>          struct hidp_session *session = arg;
>> -       wait_queue_t ctrl_wait, intr_wait;
>> +       DEFINE_WAIT_FUNC(ctrl_wait, hidp_session_wake_function);
>> +       DEFINE_WAIT_FUNC(intr_wait, hidp_session_wake_function);
>>
>>          BT_DBG("session %p", session);
>>
>> @@ -1254,8 +1267,6 @@ static int hidp_session_thread(void *arg)
>>          set_user_nice(current, -15);
>>          hidp_set_timer(session);
>>
>> -       init_waitqueue_entry(&ctrl_wait, current);
>> -       init_waitqueue_entry(&intr_wait, current);
>>          add_wait_queue(sk_sleep(session->ctrl_sock->sk), &ctrl_wait);
>>          add_wait_queue(sk_sleep(session->intr_sock->sk), &intr_wait);
>>          /* This memory barrier is paired with wq_has_sleeper(). See
>> --
>> 2.1.4
>>
>>
> Thanks.
>
