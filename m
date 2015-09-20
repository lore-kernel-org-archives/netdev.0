From: Aaron Conole <aconole@bytheb.org>
Subject: Re: [PATCH v2] [net] af_unix: return data from multiple SKBs on recv() with MSG_PEEK flag
Date: Sun, 20 Sep 2015 15:07:56 -0400
Message-ID: <87twqo7vub.fsf@bytheb.org>
References: <1442740705-16452-1-git-send-email-aconole@bytheb.org>
	<1442767564.29850.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:34263 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755882AbbITTH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 15:07:59 -0400
Received: by qgez77 with SMTP id z77so75432320qge.1
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 12:07:58 -0700 (PDT)
In-Reply-To: <1442767564.29850.35.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Sun, 20 Sep 2015 09:46:04 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Sun, 2015-09-20 at 05:18 -0400, Aaron Conole wrote:
>> From: Aaron Conole <aaron@bytheb.org>
>> 
>
> I am wondering what this is expected to do, and how this code would
> possibly not trigger a crash.
Are you suspecting it should crash from a possible double-lock case?
On line 2125, there is an unconditional unlock, which should be 
guaranteeing that there is no longer a condition to 'double lock' the
socket.

With my patch, I re-do a lock just before entering skb_peek_next, and
then loop to again: label (line 2078); I admit that there is a check
at the top of the loop which I do not include (the check for SOCK_DEAD).
Do you think this check is needed (and the cause for your concern on
the suspected crash)?

I will re-do the testing as you outline later, and report the results.

> Are you 100% sure you tested this patch and code path ?
Yes, 100%; I used the python code attached to the bug before hacking on
this function whatsoever to ensure that the bug still exists in current
kernel (it does). Then after my patch, I reran the same test. There 
were no oops, bugs, panics, or other errors reported.

> Before resending v3, please make sure to compile and test with
> CONFIG_LOCKDEP=y. Add a temporary (in your tree, not final patch)
>
> pr_err_once("went there at least one time\n");
>
> (to make sure this code path was tested)
I will do this testing as requested; my current config does include
LOCKDEP_SUPPORT=y.

> It might be time to get rid of unix_sk macro for a proper function to
> avoid these kind of errors.
>
> diff --git a/include/net/af_unix.h b/include/net/af_unix.h
> index 4a167b30a12f..cb1b9bbda332 100644
> --- a/include/net/af_unix.h
> +++ b/include/net/af_unix.h
> @@ -63,7 +63,11 @@ struct unix_sock {
>  #define UNIX_GC_MAYBE_CYCLE	1
>  	struct socket_wq	peer_wq;
>  };
> -#define unix_sk(__sk) ((struct unix_sock *)__sk)
> +
> +static inline struct unix_sock *unix_sk(struct sock *sk)
> +{
> +	return (struct unix_sock *)sk;
> +}
>  
>  #define peer_wait peer_wq.wait
If you'd like, I'll add this to a V3 version of this patch, re-do
testing with your requested config above, and report the results.

> Thanks.
Thank you for the feedback, it is very good.

-Aaron
