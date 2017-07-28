From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH v2] net: inet: diag: expose sockets cgroup classid
Date: Thu, 27 Jul 2017 20:23:47 -0700
Message-ID: <20170727202347.533f9b5b@cakuba.netronome.com>
References: <20170727181352.18547-1-alexander.levin@verizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>
To: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170727181352.18547-1-alexander.levin@verizon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Jul 2017 18:11:32 +0000, Levin, Alexander (Sasha Levin)
wrote:
> This is useful for directly looking up a task based on class id rather than
> having to scan through all open file descriptors.
> 
> Signed-off-by: Sasha Levin <alexander.levin@verizon.com>
> ---
> 
> Changes in V2:
>  - Addressed comments from Cong Wang (use nla_put_u32())
> 
>  include/uapi/linux/inet_diag.h |  1 +
>  net/ipv4/inet_diag.c           | 10 ++++++++++
>  2 files changed, 11 insertions(+)
> 
> diff --git a/include/uapi/linux/inet_diag.h b/include/uapi/linux/inet_diag.h
> index bbe201047df6..678496897a68 100644
> --- a/include/uapi/linux/inet_diag.h
> +++ b/include/uapi/linux/inet_diag.h
> @@ -142,6 +142,7 @@ enum {
>  	INET_DIAG_PAD,
>  	INET_DIAG_MARK,
>  	INET_DIAG_BBRINFO,
> +	INET_DIAG_CLASS_ID,
>  	__INET_DIAG_MAX,
>  };
>  
> diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
> index 3828b3a805cd..2c2445d4bb58 100644
> --- a/net/ipv4/inet_diag.c
> +++ b/net/ipv4/inet_diag.c
> @@ -274,6 +274,16 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
>  			goto errout;
>  	}
>  
> +	if (ext & (1 << (INET_DIAG_CLASS_ID - 1))) {
> +		u32 classid = 0;
> +
> +#ifdef CONFIG_SOCK_CGROUP_DATA
> +		classid = sock_cgroup_classid(&sk->sk_cgrp_data);
> +#endif
> +
> +		nla_put_u32(skb, INET_DIAG_CLASS_ID, classid);

You need to check the return value from nla_put_u32() and goto errout
if it's set.  

Perhaps adding __must_check to the nla_put_*() helpers would be a good
idea.

> +	}
> +
>  out:
>  	nlmsg_end(skb, nlh);
>  	return 0;
