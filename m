From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] tcp: avoid bogus gcc-7 array-bounds warning
Date: Fri, 28 Jul 2017 15:39:41 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0045AAA@AcuExch.aculab.com>
References: <20170728144153.2024234-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <edumazet@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Arnd Bergmann' <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170728144153.2024234-1-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann
> Sent: 28 July 2017 15:42
...
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2202,9 +2202,10 @@ static bool tcp_small_queue_check(struct sock *sk, const struct sk_buff *skb,
>  static void tcp_chrono_set(struct tcp_sock *tp, const enum tcp_chrono new)
>  {
>  	const u32 now = tcp_jiffies32;
> +	enum tcp_chrono old = tp->chrono_type;
> 
> -	if (tp->chrono_type > TCP_CHRONO_UNSPEC)
> -		tp->chrono_stat[tp->chrono_type - 1] += now - tp->chrono_start;
> +	if (old > TCP_CHRONO_UNSPEC)
> +		tp->chrono_stat[old - 1] += now - tp->chrono_start;
>  	tp->chrono_start = now;
>  	tp->chrono_type = new;

What a horrid combination of enum and integers.
Also have u32 chrono_stat[3]; - should probably be [__TCP_CHRONO_MAX - 1]
(or - CHRONO_FIRST which is defined to be 1).

Checking if (old != 0) would make the code more readable.

	David
