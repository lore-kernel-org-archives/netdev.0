From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/6] net: Pass kern from net_proto_family.create to
 sk_alloc
Date: Sat, 09 May 2015 09:51:42 -0700
Message-ID: <1431190302.566.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
	 <87wq0kcqlm.fsf@x220.int.ebiederm.org>
	 <20150508140733.GA13325@gondor.apana.org.au>
	 <87sib76kef.fsf@x220.int.ebiederm.org>
	 <20150509011339.GA19116@gondor.apana.org.au>
	 <87383633pu.fsf_-_@x220.int.ebiederm.org>
	 <87ioc21oza.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Ying Xue <ying.xue@windriver.com>,
	netdev@vger.kernel.org, cwang@twopensource.com, xemul@openvz.org,
	maxk@qti.qualcomm.com, stephen@networkplumber.org, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, tom@herbertland.com,
	jchapman@katalix.com, erik.hugne@ericsson.com,
	jon.maloy@ericsson.com, horms@verge.net.au,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:34184 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902AbbEIQvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 12:51:45 -0400
Received: by iedfl3 with SMTP id fl3so93614722ied.1
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 09:51:44 -0700 (PDT)
In-Reply-To: <87ioc21oza.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-05-08 at 21:09 -0500, Eric W. Biederman wrote:
> In preparation for changing how struct net is refcounted
> on kernel sockets pass the knowledge that we are creating
> a kernel socket from sock_create_kern through to sk_alloc.

...

>  
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 3262f3e2b8b2..1a1c4f7b3ec5 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -2148,7 +2148,7 @@ static int tun_chr_open(struct inode *inode, struct file * file)
>  	DBG1(KERN_INFO, "tunX: tun_chr_open\n");
>  
>  	tfile = (struct tun_file *)sk_alloc(net, AF_UNSPEC, GFP_KERNEL,
> -					    &tun_proto);
> +					    &tun_proto, 0);
>  	if (!tfile)
>  		return -ENOMEM;
>  	RCU_INIT_POINTER(tfile->tun, NULL);
...

> index 3a4898ec8c67..d8dcf91732b0 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1514,7 +1514,7 @@ static inline void unlock_sock_fast(struct sock *sk, bool slow)
>  
> 
>  struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
> -		      struct proto *prot);
> +		      struct proto *prot, int kern);


Problem adding lot of parameters to functions, is that 0 (or false)
means nothing when we read the code later and we have to go back to
sk_alloc() definition to check.

Sure, at the time you write the code everything is clear, but in 2 years
we wont have the context in our heads.

I would use an enumeration to ease code readability maybe.

enum sk_alloc_kern {
	SK_ALLOC_USER,
	SK_ALLOC_KERN,
};
