From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ipv4: Add option to get TCP_FASTOPEN to getsockopt()
Date: Tue, 15 Apr 2014 06:52:34 -0700
Message-ID: <1397569954.4222.76.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87r44yixds.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Kenjiro Nakayama <nakayamakenjiro@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87r44yixds.fsf@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-04-15 at 21:35 +0900, Kenjiro Nakayama wrote:
> Hi,
> 
> TCP_FASTOPEN option can be set via setsockopt(), but the value cannot be
> gotten via getsockopt(). This patch adds the option to getsockopt().
> 
> Sighned-off-by: Kenjiro Nakayama <nakayamakenjiro@gmail.com>
> 
>  	Add option to get TCP_FASTOPEN to getsockopt()
> ---
>  net/ipv4/tcp.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 4bd6d52..86186f4 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2916,6 +2916,13 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
>  	case TCP_USER_TIMEOUT:
>  		val = jiffies_to_msecs(icsk->icsk_user_timeout);
>  		break;
> +
> +	case TCP_FASTOPEN:
> +		val = icsk->icsk_accept_queue.fastopenq ?
> +		    icsk->icsk_accept_queue.fastopenq->max_qlen
> +		    : sysctl_tcp_fastopen;
> +		break;
> +
>  	case TCP_TIMESTAMP:
>  		val = tcp_time_stamp + tp->tsoffset;
>  		break;
> --
> 1.9.0

I have no idea why you keep using sysctl_tcp_fastopen in your patches.

It seems you only want your application to
read /proc/sys/net/ipv4/tcp_fastopen ?

And you don't have CONFIG_PROC_FS maybe, and you add a workaround ?

As already mentioned, even if sysctl_tcp_fastopen is set to one, it does
not mean this socket is fastopen enabled.

setsockopt()/getsockopt() for a given key should be symmetrical.

ie :

getsockopt(fd, SOL_TCP, TCP_FASTOPEN, &val, &len);
setsockopt(fd, SOL_TCP, TCP_FASTOPEN, &val, sizeof(val));

should be a no operation. Its obviously not the case with your proposal.

Please address Neal concerns, and add in the changelog what is this
option supposed to do _exactly_.

hint : max_qlen and sysctl_tcp_fastopen do not have the same units,
its like comparing apples and oranges.

Thanks
