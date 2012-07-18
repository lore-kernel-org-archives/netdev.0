From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 3/7] net-tcp: Fast Open client - sending SYN-data
Date: Wed, 18 Jul 2012 23:23:24 +0200
Message-ID: <1342646604.2626.3705.camel@edumazet-glaptop>
References: <1342645307-17772-1-git-send-email-ycheng@google.com>
	 <1342645307-17772-4-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com, sivasankar@cs.ucsd.edu,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:33334 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966Ab2GRV1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 17:27:42 -0400
Received: by yhmm54 with SMTP id m54so2101566yhm.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 14:27:42 -0700 (PDT)
In-Reply-To: <1342645307-17772-4-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 14:01 -0700, Yuchung Cheng wrote:
> This patch implements sending SYN-data in tcp_connect(). The data is
> from tcp_sendmsg() with flag MSG_FASTOPEN (implemented in a later patch).
> 
> The length of the cookie in tcp_fastopen_req, init'd to 0, controls the
> type of the SYN. If the cookie is not cached (len==0), the host sends
> data-less SYN with Fast Open cookie request option to solicit a cookie
> from the remote. If cookie is not available (len > 0), the host sends
> a SYN-data with Fast Open cookie option. If cookie length is negative,
>   the SYN will not include any Fast Open option (for fall back operations).
> 
> To deal with middleboxes that may drop SYN with data or experimental TCP
> option, the SYN-data is only sent once. SYN retransmits do not include
> data or Fast Open options. The connection will fall back to regular TCP
> handshake.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

...

>  
>  static long inet_wait_for_connect(struct sock *sk, long timeo)
>  {
> +	const bool write = (sk->sk_protocol == IPPROTO_TCP) &&
> +			   tcp_sk(sk)->fastopen_req &&
> +			   tcp_sk(sk)->fastopen_req->data;
>  	DEFINE_WAIT(wait);
>  
>  	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
> +	if (write)
> +		sk->sk_write_pending++;
>  
>  	/* Basic assumption: if someone sets sk->sk_err, he _must_
>  	 * change state of the socket from TCP_SYN_*.
> @@ -576,6 +581,8 @@ static long inet_wait_for_connect(struct sock *sk, long timeo)
>  		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
>  	}
>  	finish_wait(sk_sleep(sk), &wait);
> +	if (write)
> +		sk->sk_write_pending--;
>  	return timeo;
>  }
>  

It might be cleaner to move the TCP stuff out of this function and put
it in inet_stream_connect(), since inet_stream_connect() is known to
already have TCP magic.

So I suggest you add a "int writebias" argument to this function, and
use :


static long inet_wait_for_connect(struct sock *sk, long timeo,
+                                 int writebias)
 {
        DEFINE_WAIT(wait);
 
        prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+       sk->sk_write_pending += writebias;
 
        /* Basic assumption: if someone sets sk->sk_err, he _must_
         * change state of the socket from TCP_SYN_*.
@@ -576,6 +581,8 @@ static long inet_wait_for_connect(struct sock *sk,
long timeo)
                prepare_to_wait(sk_sleep(sk), &wait,
TASK_INTERRUPTIBLE);
        }
        finish_wait(sk_sleep(sk), &wait);
+       sk->sk_write_pending -= writebias;
        return timeo;
 }
