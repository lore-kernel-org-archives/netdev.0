From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] drivers/net: Use RCU_INIT_POINTER(x, NULL) in tun.c
Date: Sun, 23 Mar 2014 12:54:17 -0700
Message-ID: <1395604457.9117.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395599552-7486-1-git-send-email-monamagarwal123@gmail.com>
	 <20140323194113.GA13633@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Monam Agarwal <monamagarwal123@gmail.com>, davem@davemloft.net,
	jasowang@redhat.com, xemul@parallels.com, wuzhy@linux.vnet.ibm.com,
	therbert@google.com, yamato@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140323194113.GA13633@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-03-23 at 21:41 +0200, Michael S. Tsirkin wrote:

> The rcu_assign_pointer() ensures that the initialization of a structure       
> is carried out before storing a pointer to that structure. 
> In the case of the NULL pointer, there is no structure to initialize,
> so we can safely drop smp_wmb in this case.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> --
> 
> Lightly tested.
> v is evaluated twice here but that should be ok since this
> only happens when v is a constant, so evaluating it should
> have no side effects.
> Paul, what do you think?
> 
> diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
> index 72bf3a0..d33c9ec 100644
> --- a/include/linux/rcupdate.h
> +++ b/include/linux/rcupdate.h
> @@ -587,7 +587,8 @@ static inline void rcu_preempt_sleep_check(void)
>   */
>  #define rcu_assign_pointer(p, v) \
>  	do { \
> -		smp_wmb(); \
> +		if (!__builtin_constant_p(v) || (v)) \
> +			smp_wmb(); \
>  		ACCESS_ONCE(p) = RCU_INITIALIZER(v); \
>  	} while (0)
>  

Yeah, I suggest you read d322f45ceed525daa changelog ;)
