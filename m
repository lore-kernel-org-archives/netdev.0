From: Laura Abbott <labbott@redhat.com>
Subject: Re: [PATCH v2 1/2] Revert "vsock: Fix blocking ops call in
 prepare_to_wait"
Date: Thu, 17 Mar 2016 11:07:14 -0700
Message-ID: <56EAF252.6000003@redhat.com>
References: <1458231156-18845-1-git-send-email-imbrenda@linux.vnet.ibm.com>
 <1458231156-18845-2-git-send-email-imbrenda@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: labbott@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34274 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936205AbcCQSHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 14:07:17 -0400
Received: by mail-pf0-f173.google.com with SMTP id x3so130521749pfb.1
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 11:07:17 -0700 (PDT)
In-Reply-To: <1458231156-18845-2-git-send-email-imbrenda@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/17/2016 09:12 AM, Claudio Imbrenda wrote:
> This reverts commit 5988818008257ca42010d6b43a3e0e48afec9898 ("vsock: Fix
> blocking ops call in prepare_to_wait")
>

I don't think having this as a separate patch does a lot of good. You
can probably fold this into the next patch with a note saying that
you are removing this broken behavior. If you really want this to
be separate, please add a description of why this is being reverted.

Thanks,
Laura

> Signed-off-by: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
> ---
>   net/vmw_vsock/af_vsock.c | 19 +++++++++++++------
>   1 file changed, 13 insertions(+), 6 deletions(-)
>
> diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
> index bbe65dc..7fd1220 100644
> --- a/net/vmw_vsock/af_vsock.c
> +++ b/net/vmw_vsock/af_vsock.c
> @@ -1557,6 +1557,8 @@ static int vsock_stream_sendmsg(struct socket *sock, struct msghdr *msg,
>   	if (err < 0)
>   		goto out;
>
> +	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
> +
>   	while (total_written < len) {
>   		ssize_t written;
>
> @@ -1576,9 +1578,7 @@ static int vsock_stream_sendmsg(struct socket *sock, struct msghdr *msg,
>   				goto out_wait;
>
>   			release_sock(sk);
> -			prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
>   			timeout = schedule_timeout(timeout);
> -			finish_wait(sk_sleep(sk), &wait);
>   			lock_sock(sk);
>   			if (signal_pending(current)) {
>   				err = sock_intr_errno(timeout);
> @@ -1588,6 +1588,8 @@ static int vsock_stream_sendmsg(struct socket *sock, struct msghdr *msg,
>   				goto out_wait;
>   			}
>
> +			prepare_to_wait(sk_sleep(sk), &wait,
> +					TASK_INTERRUPTIBLE);
>   		}
>
>   		/* These checks occur both as part of and after the loop
> @@ -1633,6 +1635,7 @@ static int vsock_stream_sendmsg(struct socket *sock, struct msghdr *msg,
>   out_wait:
>   	if (total_written > 0)
>   		err = total_written;
> +	finish_wait(sk_sleep(sk), &wait);
>   out:
>   	release_sock(sk);
>   	return err;
> @@ -1713,6 +1716,7 @@ vsock_stream_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
>   	if (err < 0)
>   		goto out;
>
> +	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
>
>   	while (1) {
>   		s64 ready = vsock_stream_has_data(vsk);
> @@ -1723,7 +1727,7 @@ vsock_stream_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
>   			 */
>
>   			err = -ENOMEM;
> -			goto out;
> +			goto out_wait;
>   		} else if (ready > 0) {
>   			ssize_t read;
>
> @@ -1746,7 +1750,7 @@ vsock_stream_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
>   					vsk, target, read,
>   					!(flags & MSG_PEEK), &recv_data);
>   			if (err < 0)
> -				goto out;
> +				goto out_wait;
>
>   			if (read >= target || flags & MSG_PEEK)
>   				break;
> @@ -1769,9 +1773,7 @@ vsock_stream_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
>   				break;
>
>   			release_sock(sk);
> -			prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
>   			timeout = schedule_timeout(timeout);
> -			finish_wait(sk_sleep(sk), &wait);
>   			lock_sock(sk);
>
>   			if (signal_pending(current)) {
> @@ -1781,6 +1783,9 @@ vsock_stream_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
>   				err = -EAGAIN;
>   				break;
>   			}
> +
> +			prepare_to_wait(sk_sleep(sk), &wait,
> +					TASK_INTERRUPTIBLE);
>   		}
>   	}
>
> @@ -1811,6 +1816,8 @@ vsock_stream_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
>   		err = copied;
>   	}
>
> +out_wait:
> +	finish_wait(sk_sleep(sk), &wait);
>   out:
>   	release_sock(sk);
>   	return err;
>
