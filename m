From: Alexander Popov <alex.popov@linux.com>
Subject: Re: BUG at net/sctp/socket.c:7425
Date: Mon, 30 Jan 2017 14:19:53 +0300
Message-ID: <6864a599-ed80-b6f8-d1eb-14b6d9cef913@linux.com>
References: <48766e1c-99c9-3a88-0fec-998bf4db9a3a@linux.com>
 <20170129104002.GJ3781@localhost.localdomain>
Reply-To: alex.popov@linux.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        syzkaller <syzkaller@googlegroups.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:35504 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751188AbdA3LUY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 06:20:24 -0500
In-Reply-To: <20170129104002.GJ3781@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29.01.2017 13:40, Marcelo Ricardo Leitner wrote:
> On Sun, Jan 29, 2017 at 03:35:31AM +0300, Alexander Popov wrote:
>> Hello,
>>
>> I'm running the syzkaller fuzzer for v4.10-rc4 (0aa0313f9d576affd7747cc3f179feb097d28990)
>> and have such a crash in sctp code:
>>
> ...
>>
>> Unfortunately, I didn't manage to get a C program reproducing the crash (looks like race).
>> However, I stably hit it on my setup - so I can help fixing the issue.
>>
>> The crash happens here:
>> 	/* Let another process have a go.  Since we are going
>> 	 * to sleep anyway.
>> 	 */
>> 	release_sock(sk);
>> 	current_timeo = schedule_timeout(current_timeo);
>>> 	BUG_ON(sk != asoc->base.sk);
>> 	lock_sock(sk);
>>
>> I've added some debugging output and see, that the original value of asoc->base.sk is
>> changed to the address of another struct sock, which appeared in sctp_endpoint_init()
>> shortly before the crash.
> 
> You need some threading for this to happen.  asoc->base.sk will change
> if you peeloff the association.
> It seems you had one thread waiting for some sndbuf to be available on a
> sendmsg() call and another thread did a peeloff on the association that
> the first thread was using.
> Yeah I think this will reproduce it.
> And in this case, it's probably better if we just return -EPIPE as the
> association doesn't exist in that socket anymore instead of the BUG_ON.

Thanks for your reply and patch, Marcelo.
I've checked your explanation and agree with it. The situation looks like this:
...
[   55.719561] sctp_endpoint_init: sk ffff88006718c8c0
[   55.721158] sctp_association_init: asoc ffff880059e96818, base.sk = ffff88006718c8c0
...
[   56.144070] sctp_wait_for_sndbuf: asoc:ffff880059e96818, timeo:9223372036854775807,
msg_len:24
[   56.148650] sctp_endpoint_init: sk ffff880068bca480
[   56.149216] sctp_sock_migrate: asoc ffff880059e96818 from oldsk ffff88006718c8c0 to
newsk ffff880068bca480
[   56.150442] sctp_assoc_migrate: asoc ffff880059e96818 to newsk ffff880068bca480
[   56.168827] crash!!! asoc ffff880059e96818: sk ffff88006718c8c0 != base.sk ffff880068bca480
[   56.169801] ------------[ cut here ]------------
[   56.170151] kernel BUG at net/sctp/socket.c:7433!
...


> ---8<---
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 26a514269b92..e9870aead88b 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -6838,7 +6838,8 @@ static int sctp_wait_for_sndbuf(struct sctp_association *asoc, long *timeo_p,
>  		 */
>  		sctp_release_sock(sk);
>  		current_timeo = schedule_timeout(current_timeo);
> -		BUG_ON(sk != asoc->base.sk);
> +		if (sk != asoc->base.sk)
> +			goto do_error;
>  		sctp_lock_sock(sk);
>  
>  		*timeo_p = current_timeo;

Tested your fix.
Acked-by: Alexander Popov <alex.popov@linux.com>
