From: David Miller <davem@davemloft.net>
Subject: Re: net/udp: slab-out-of-bounds Read in udp_recvmsg
Date: Wed, 15 Mar 2017 15:08:29 -0700 (PDT)
Message-ID: <20170315.150829.1653001387394027005.davem@davemloft.net>
References: <CACT4Y+aKW-yNfdWBvAWck3xNFKKeKEf8BNOmtFg2EZZjN98BVg@mail.gmail.com>
        <1489593673.28631.150.camel@edumazet-glaptop3.roam.corp.google.com>
        <1489594233.28631.152.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, ycheng@google.com, soheil@google.com,
        ncardwell@google.com, zzoru007@gmail.com, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        syzkaller@googlegroups.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489594233.28631.152.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 15 Mar 2017 09:10:33 -0700

> @@ -692,12 +692,17 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
>  	    ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2))
>  		empty = 0;
>  	if (!empty) {
> +		unsigned int hlen = skb_headlen(skb);
> +
>  		put_cmsg(msg, SOL_SOCKET,
>  			 SCM_TIMESTAMPING, sizeof(tss), &tss);
>  
> -		if (skb->len && (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_STATS))
> +		if (hlen &&
> +		    (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_STATS) &&
> +		    sk->sk_protocol == IPPROTO_TCP &&
> +		    sk->sk_type == SOCK_STREAM)
>  			put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPING_OPT_STATS,
> -				 skb->len, skb->data);
> +				 hlen, skb->data);

Hmmm, what is the true intention of SOF_TIMESTAMPING_OPT_STATS then?  The
existing code seems to want to dump the entire SKB into the cmsg, and if
that's the case then the fix is to linearlize the skb before the put_cmsg()
or have a way to put a non-linear SKB into a cmsg.
