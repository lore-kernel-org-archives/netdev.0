From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH 12/12] [RFC] can: avoid using timeval for uapi
Date: Mon, 05 Oct 2015 20:51:08 +0200
Message-ID: <5612C69C.7020803@hartkopp.net>
References: <1443612402-3000775-1-git-send-email-arnd@arndb.de> <1443612402-3000775-13-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1443612402-3000775-13-git-send-email-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Arnd,

thanks for picking up this y2038 api issue.

On 09/30/2015 01:26 PM, Arnd Bergmann wrote:
> The can subsystem communicates with user space using a bcm_msg_head
> header, which contains two timestamps. This is problematic for
> multiple reasons:
> 
> a) The structure layout is currently incompatible between 64-bit
>    user space and 32-bit user space, and cannot work in compat
>    mode (other than x32).
> 
> b) The timeval structure layout will change in 32-bit user
>    space when we fix the y2038 overflow problem by redefining
>    time_t to 64-bit, making new 32-bit user space incompatible
>    with the current kernel interface.
>    Cars last a long time and often use old kernels, so the actual
>    users of this code are the most likely ones to migrate to y2038
>    safe user space.
> 
> This tries to work around part of the problem by changing the
> publicly visible user interface in the header, but not the binary
> interface. Fortunately, the values passed around in the structure
> are relative times and do not actually suffer from the y2038
> overflow, so 32-bit is enough here.
> 
> We replace the use of 'struct timeval' with a newly defined
> 'struct bcm_timeval' that uses the exact same binary layout
> as before and that still suffers from problem a) but not problem
> b).
> 
> The downside of this approach is that any user space program
> that currently assigns a timeval structure to these members
> rather than writing the tv_sec/tv_usec portions individually
> will suffer a compile-time error when built with an updated
> kernel header. Fixing this error makes it work fine with old
> and new headers though.

I double checked some (more) BCM applications I have access to.

E.g. https://github.com/linux-can/can-tests

When you do a 'git grep ival1' there you get something like

tst-bcm-cycle.c:        msg.msg_head.ival1.tv_sec = 1;
tst-bcm-cycle.c:        msg.msg_head.ival1.tv_usec = 0;
tst-bcm-cycle.c:        msg.msg_head.ival1.tv_sec = 0;
tst-bcm-cycle.c:        msg.msg_head.ival1.tv_usec = 0;
tst-bcm-dump.c: msg.msg_head.ival1.tv_sec       = timeout / 1000000;
tst-bcm-dump.c: msg.msg_head.ival1.tv_usec      = timeout % 1000000;
(..)

So the usual way to assign values to ival1 and ival2 is NOT to assign an
existing struct timeval but to directly assign its tv_[u]sec elements.

I applied your bcm.h changes to my local can-tests tree and it compiles
without any problems - as expected. I don't see any serious drawback with your
idea. I wonder whether developers would ever notice this change ...

> We could address problem a) by using '__u32' or 'int' members
> rather than 'long', but that would have a more significant
> downside in also breaking support for all existing 64-bit user
> binaries that might be using this interface, which is likely
> not acceptable.

Indeed.

> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
> Cc: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>

Thanks for your good suggestion to make the BCM API y2038 proof!

Acked-by: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>

> Cc: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> Cc: linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---
>  include/uapi/linux/can/bcm.h |  7 ++++++-
>  net/can/bcm.c                | 15 ++++++++++-----
>  2 files changed, 16 insertions(+), 6 deletions(-)
> 
> diff --git a/include/uapi/linux/can/bcm.h b/include/uapi/linux/can/bcm.h
> index 89ddb9dc9bdf..7a291dc1ff15 100644
> --- a/include/uapi/linux/can/bcm.h
> +++ b/include/uapi/linux/can/bcm.h
> @@ -47,6 +47,11 @@
>  #include <linux/types.h>
>  #include <linux/can.h>
>  
> +struct bcm_timeval {
> +	long tv_sec;
> +	long tv_usec;
> +};
> +
>  /**
>   * struct bcm_msg_head - head of messages to/from the broadcast manager
>   * @opcode:    opcode, see enum below.
> @@ -62,7 +67,7 @@ struct bcm_msg_head {
>  	__u32 opcode;
>  	__u32 flags;
>  	__u32 count;
> -	struct timeval ival1, ival2;
> +	struct bcm_timeval ival1, ival2;
>  	canid_t can_id;
>  	__u32 nframes;
>  	struct can_frame frames[0];
> diff --git a/net/can/bcm.c b/net/can/bcm.c
> index a1ba6875c2a2..6863310d6973 100644
> --- a/net/can/bcm.c
> +++ b/net/can/bcm.c
> @@ -96,7 +96,7 @@ struct bcm_op {
>  	canid_t can_id;
>  	u32 flags;
>  	unsigned long frames_abs, frames_filtered;
> -	struct timeval ival1, ival2;
> +	struct bcm_timeval ival1, ival2;
>  	struct hrtimer timer, thrtimer;
>  	struct tasklet_struct tsklet, thrtsklet;
>  	ktime_t rx_stamp, kt_ival1, kt_ival2, kt_lastmsg;
> @@ -131,6 +131,11 @@ static inline struct bcm_sock *bcm_sk(const struct sock *sk)
>  	return (struct bcm_sock *)sk;
>  }
>  
> +static inline ktime_t bcm_timeval_to_ktime(struct bcm_timeval tv)
> +{
> +	return ktime_set(tv.tv_sec, tv.tv_usec * NSEC_PER_USEC);
> +}
> +
>  #define CFSIZ sizeof(struct can_frame)
>  #define OPSIZ sizeof(struct bcm_op)
>  #define MHSIZ sizeof(struct bcm_msg_head)
> @@ -953,8 +958,8 @@ static int bcm_tx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
>  		op->count = msg_head->count;
>  		op->ival1 = msg_head->ival1;
>  		op->ival2 = msg_head->ival2;
> -		op->kt_ival1 = timeval_to_ktime(msg_head->ival1);
> -		op->kt_ival2 = timeval_to_ktime(msg_head->ival2);
> +		op->kt_ival1 = bcm_timeval_to_ktime(msg_head->ival1);
> +		op->kt_ival2 = bcm_timeval_to_ktime(msg_head->ival2);
>  
>  		/* disable an active timer due to zero values? */
>  		if (!op->kt_ival1.tv64 && !op->kt_ival2.tv64)
> @@ -1134,8 +1139,8 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
>  			/* set timer value */
>  			op->ival1 = msg_head->ival1;
>  			op->ival2 = msg_head->ival2;
> -			op->kt_ival1 = timeval_to_ktime(msg_head->ival1);
> -			op->kt_ival2 = timeval_to_ktime(msg_head->ival2);
> +			op->kt_ival1 = bcm_timeval_to_ktime(msg_head->ival1);
> +			op->kt_ival2 = bcm_timeval_to_ktime(msg_head->ival2);
>  
>  			/* disable an active timer due to zero value? */
>  			if (!op->kt_ival1.tv64)
> 
