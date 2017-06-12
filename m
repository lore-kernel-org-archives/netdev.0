From: AL Yu-Chen Cho <acho@suse.com>
Subject: Re: [PATCH v4 1/3] Bluetooth: bnep: fix possible might sleep error
 in bnep_session
Date: Mon, 12 Jun 2017 16:43:45 +0800
Message-ID: <1497257025.3326.3.camel@suse.com>
References: <1487033725-7208-1-git-send-email-jeffy.chen@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Brian Norris <briannorris@chromium.org>,
        Douglas Anderson <dianders@chromium.org>,
        Johan Hedberg <johan.hedberg@intel.com>,
        Peter Hurley <peter@hurleysoftware.com>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>
To: Jeffy Chen <jeffy.chen@rock-chips.com>,
        linux-bluetooth@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1487033725-7208-1-git-send-email-jeffy.chen@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-02-14 at 08:55 +0800, Jeffy Chen wrote:
> It looks like bnep_session has same pattern as the issue reported in
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
> Signed-off-by: Jeffy Chen <jeffy.chen@rock-chips.com>
> Reviewed-by: Brian Norris <briannorris@chromium.org>
Reviewed-by: AL Yu-Chen Cho <acho@suse.com>
> ---
> 
> Changes in v3:
> Add brian's Reviewed-by.
> 
> Changes in v2:
> Remove unnecessary memory barrier before wake_up_* functions.
> 
>  net/bluetooth/bnep/core.c | 11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
> index fbf251f..4d6b94d 100644
> --- a/net/bluetooth/bnep/core.c
> +++ b/net/bluetooth/bnep/core.c
> @@ -484,16 +484,16 @@ static int bnep_session(void *arg)
>  	struct net_device *dev = s->dev;
>  	struct sock *sk = s->sock->sk;
>  	struct sk_buff *skb;
> -	wait_queue_t wait;
> +	DEFINE_WAIT_FUNC(wait, woken_wake_function);
>  
>  	BT_DBG("");
>  
>  	set_user_nice(current, -15);
>  
> -	init_waitqueue_entry(&wait, current);
>  	add_wait_queue(sk_sleep(sk), &wait);
>  	while (1) {
> -		set_current_state(TASK_INTERRUPTIBLE);
> +		/* Ensure session->terminate is updated */
> +		smp_mb__before_atomic();
>  
>  		if (atomic_read(&s->terminate))
>  			break;
> @@ -515,9 +515,8 @@ static int bnep_session(void *arg)
>  				break;
>  		netif_wake_queue(dev);
>  
> -		schedule();
> +		wait_woken(&wait, TASK_INTERRUPTIBLE,
> MAX_SCHEDULE_TIMEOUT);
>  	}
> -	__set_current_state(TASK_RUNNING);
>  	remove_wait_queue(sk_sleep(sk), &wait);
>  
>  	/* Cleanup session */
> @@ -666,7 +665,7 @@ int bnep_del_connection(struct bnep_conndel_req
> *req)
>  	s = __bnep_get_session(req->dst);
>  	if (s) {
>  		atomic_inc(&s->terminate);
> -		wake_up_process(s->task);
> +		wake_up_interruptible(sk_sleep(s->sock->sk));
>  	} else
>  		err = -ENOENT;
>  
