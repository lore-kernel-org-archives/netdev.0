From: Brian Norris <briannorris-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 3/3] Bluetooth: hidp: fix possible might sleep error in
 hidp_session_thread
Date: Fri, 10 Feb 2017 17:26:51 -0800
Message-ID: <20170211012651.GA101282@google.com>
References: <1485230871-22828-1-git-send-email-jeffy.chen@rock-chips.com>
 <1485230871-22828-3-git-send-email-jeffy.chen@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Douglas Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Johan Hedberg <johan.hedberg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Peter Hurley <peter-WaGBZJeGNqdsbIuE7sb01tBPR1lH4CV8@public.gmane.org>,
        Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
To: Jeffy Chen <jeffy.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1485230871-22828-3-git-send-email-jeffy.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Jeffy,

I'm really not an expert on bluetooth or HIDP, but I can't bring myself
to say that this is correct. I still think you have a problem.

On Tue, Jan 24, 2017 at 12:07:51PM +0800, Jeffy Chen wrote:
> It looks like hidp_session_thread has same pattern as the issue reported in
> old rfcomm:
> 
> 	while (1) {
> 		set_current_state(TASK_INTERRUPTIBLE);
> 		if (condition)
> 			break;
> 		// may call might_sleep here
> 		schedule();
> 	}
> 	__set_current_state(TASK_RUNNING);
> 
> Which fixed at:
> 	dfb2fae Bluetooth: Fix nested sleeps
> 
> So let's fix it at the same way, also follow the suggestion of:
> https://lwn.net/Articles/628628/
> 
> Signed-off-by: Jeffy Chen <jeffy.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
> ---
> 
>  net/bluetooth/hidp/core.c | 23 +++++++++++++++--------
>  1 file changed, 15 insertions(+), 8 deletions(-)
> 
> diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
> index 0bec458..43d6e6a 100644
> --- a/net/bluetooth/hidp/core.c
> +++ b/net/bluetooth/hidp/core.c
> @@ -36,6 +36,7 @@
>  #define VERSION "1.2"
>  
>  static DECLARE_RWSEM(hidp_session_sem);
> +static DECLARE_WAIT_QUEUE_HEAD(hidp_session_wq);
>  static LIST_HEAD(hidp_session_list);
>  
>  static unsigned char hidp_keycode[256] = {
> @@ -1068,12 +1069,15 @@ static int hidp_session_start_sync(struct hidp_session *session)
>   * Wake up session thread and notify it to stop. This is asynchronous and
>   * returns immediately. Call this whenever a runtime error occurs and you want
>   * the session to stop.
> - * Note: wake_up_process() performs any necessary memory-barriers for us.
>   */
>  static void hidp_session_terminate(struct hidp_session *session)
>  {
>  	atomic_inc(&session->terminate);
> -	wake_up_process(session->task);
> +
> +	/* Ensure session->terminate is updated */
> +	smp_mb__after_atomic();
> +
> +	wake_up_interruptible(&hidp_session_wq);

So, you're adding a whole new wait queue here.

>  }
>  
>  /*
> @@ -1180,7 +1184,9 @@ static void hidp_session_run(struct hidp_session *session)
>  	struct sock *ctrl_sk = session->ctrl_sock->sk;
>  	struct sock *intr_sk = session->intr_sock->sk;
>  	struct sk_buff *skb;
> +	DEFINE_WAIT_FUNC(wait, woken_wake_function);
>  
> +	add_wait_queue(&hidp_session_wq, &wait);
>  	for (;;) {
>  		/*
>  		 * This thread can be woken up two ways:
> @@ -1188,12 +1194,10 @@ static void hidp_session_run(struct hidp_session *session)
>  		 *    session->terminate flag and wakes this thread up.
>  		 *  - Via modifying the socket state of ctrl/intr_sock. This
>  		 *    thread is woken up by ->sk_state_changed().
> -		 *
> -		 * Note: set_current_state() performs any necessary
> -		 * memory-barriers for us.
>  		 */
> -		set_current_state(TASK_INTERRUPTIBLE);
>  
> +		/* Ensure session->terminate is updated */
> +		smp_mb__before_atomic();
>  		if (atomic_read(&session->terminate))
>  			break;
>  
> @@ -1227,11 +1231,14 @@ static void hidp_session_run(struct hidp_session *session)
>  		hidp_process_transmit(session, &session->ctrl_transmit,
>  				      session->ctrl_sock);
>  
> -		schedule();
> +		wait_woken(&wait, TASK_INTERRUPTIBLE, MAX_SCHEDULE_TIMEOUT);

And you're waiting on it here.

But you're already on two other wait queues (hidp_session_thread()). So
the nice WQ_FLAG_WOKEN handling will only happen if you get woken via
the new hidp_session_wq queue. But what about the other two? Seems like
again you might have a race condition that would lead you to
(temporarily, at least?) missing a wake-up attempt.

I'm not really sure what the best way to resolve this would be. My best
guess would be to either consolidate the use of these wait queues, or
lese roll a version of wait_woken() to handle 2 or more wait heads...

Am I wrong? I easily could be.

Brian

>  	}
> +	remove_wait_queue(&hidp_session_wq, &wait);
>  
>  	atomic_inc(&session->terminate);
> -	set_current_state(TASK_RUNNING);
> +
> +	/* Ensure session->terminate is updated */
> +	smp_mb__after_atomic();
>  }
>  
>  /*
> -- 
> 2.1.4
> 
> 
