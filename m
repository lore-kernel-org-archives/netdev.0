From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: ipv6: tunnel: hang when destroying ipv6 tunnel
Date: Fri, 6 Apr 2012 20:44:37 +0900
Message-ID: <201204062044.EJE13062.OLMQtSVFHOFOJF@I-love.SAKURA.ne.jp>
References: <CA+1xoqcAXyh306=2=QKWyM3BE44=MT+nsuRQn5YLOLgbtZqicA@mail.gmail.com>
	<CA+1xoqe1Wc_uifrKsko6hu+py9Ahz3Q0p1tRxup09jmh2NZ1rw@mail.gmail.com>
	<201204011221.GAG51016.JQFSFFOtLOMVHO@I-love.SAKURA.ne.jp>
	<CA+1xoqe+T=iUtUeFdeqmRvMZ7TMCgkLs_1QYv-4YNtn-jCoMCQ@mail.gmail.com>
	<201204052329.EBH52139.FFOLQMOJSVHOFt@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: oleg@redhat.com, eric.dumazet@gmail.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davej@redhat.com
To: levinsasha928@gmail.com, garlick@llnl.gov, ericvh@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201204052329.EBH52139.FFOLQMOJSVHOFt@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa wrote:
> Most suspicious change is net/9p/client.c because it is changing handling of
> ERESTARTSYS case.
> 
> --- linux-3.3.1/net/9p/client.c
> +++ linux-next/net/9p/client.c
> @@ -740,10 +740,18 @@
>                         c->status = Disconnected;
>                 goto reterr;
>         }
> +again:
>         /* Wait for the response */
>         err = wait_event_interruptible(*req->wq,
>                                        req->status >= REQ_STATUS_RCVD);
> 
> +       if ((err == -ERESTARTSYS) && (c->status == Connected)
> +                                 && (type == P9_TFLUSH)) {
> +               sigpending = 1;
> +               clear_thread_flag(TIF_SIGPENDING);
> +               goto again;
> +       }
> +

I think this loop is bad with regard to response to SIGKILL.
If wait_event_interruptible() was interrupted by SIGKILL, it will
spin until req->status >= REQ_STATUS_RCVD becomes true.
Rather,

	if ((c->status == Connected) && (type == P9_TFLUSH))
		err = wait_event_killable(*req->wq,
					  req->status >= REQ_STATUS_RCVD);
	else
		err = wait_event_interruptible(*req->wq,
					       req->status >= REQ_STATUS_RCVD);

would be safer.



>  error:
>         /*
>          * Fid is not valid even after a failed clunk
> +        * If interrupted, retry once then give up and
> +        * leak fid until umount.
>          */
> -       p9_fid_destroy(fid);
> +       if (err == -ERESTARTSYS) {
> +               if (retries++ == 0)
> +                       goto again;

I think it is possible that the process is interrupted again upon retrying.
I suspect the handling of err == -ERESTARTSYS case when retries != 0.
It is returning without calling p9_fid_destroy(), which will be
unexpected behaviour for the various callers.

> +       } else
> +               p9_fid_destroy(fid);
>         return err;
>  }
>  EXPORT_SYMBOL(p9_client_clunk);
