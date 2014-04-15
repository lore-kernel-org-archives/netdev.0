From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] ipv4: Add option to get TCP_FASTOPEN to getsockopt()
Date: Mon, 14 Apr 2014 20:43:26 -0400
Message-ID: <CADVnQykADoaDAnO+JaXos_Zto-rdP4j3pKw_Uv7JBM6T9Y=JCw@mail.gmail.com>
References: <87tx9v3j58.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Kenjiro Nakayama <nakayamakenjiro@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87tx9v3j58.fsf@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 14, 2014 at 1:39 PM, Kenjiro Nakayama
<nakayamakenjiro@gmail.com> wrote:
> TCP_FASTOPEN option can be set via setsockopt(), but the value cannot be
> gotten via getsockopt(). This patch adds the option to getsockopt().
>
> Sighned-off-by: Kenjiro Nakayama <nakayamakenjiro@gmail.com>
>
>         Add option to get TCP_FASTOPEN to getsockopt()
> ---
>  net/ipv4/tcp.c | 5 +++++
>  1 file changed, 5 insertions(+)
>
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 4bd6d52..6ccdbcc 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2916,6 +2916,11 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
>         case TCP_USER_TIMEOUT:
>                 val = jiffies_to_msecs(icsk->icsk_user_timeout);
>                 break;
> +
> +       case TCP_FASTOPEN:
> +               val = sysctl_tcp_fastopen;
> +               break;
> +
>         case TCP_TIMESTAMP:
>                 val = tcp_time_stamp + tp->tsoffset;
>                 break;
> --
> 1.9.0

Hi,

Please cc the Linux network development mailing list at
netdev@vger.kernel.org (cc-ed) for Linux networking patches like this.

I don't think this is the implementation we'd want for a getsockopt()
for TCP_FASTOPEN. I imagine that since the setsockopt(TCP_FASTOPEN)
enables Fast Open on a listening socket with a given backlog, if we
add a corresponding getsockopt() then it should return that Fast Open
backlog if Fast Open is enabled on the listening socket, or 0
otherwise. That is, basically it would be querying whether
fastopen_init_queue() has been run and returning fastopenq->max_qlen
if so. That way setsockopt(TCP_FASTOPEN, getsockopt(TCP_FASTOPEN))
will be a NOP in most cases, as one would expect.

neal
