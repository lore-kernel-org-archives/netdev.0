From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCH 3/10] Fix leaking of kernel heap addresses in net/
Date: Thu, 11 Nov 2010 20:20:39 -0500
Message-ID: <20101112012039.GB4683@canuck.infradead.org>
References: <1289524023.5167.67.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	James Morris <jmorris@namei.org>,
	Remi Denis-Courmont <remi.denis-courmont@nokia.com>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Tejun Heo <tj@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Li Zefan <lizf@cn.fujitsu.com>, Joe Perches <joe@perches.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Pavel Eme
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:35089 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754001Ab0KLBWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 20:22:41 -0500
Content-Disposition: inline
In-Reply-To: <1289524023.5167.67.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 11, 2010 at 08:07:03PM -0500, Dan Rosenberg wrote:
> diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
> index 1f85ef2..0ac8ff2 100644
> --- a/net/ipv4/raw.c
> +++ b/net/ipv4/raw.c
> @@ -948,13 +948,26 @@ static void raw_sock_seq_show(struct seq_file *seq, struct sock *sp, int i)
>  	__u16 destp = 0,
>  	      srcp  = inet->inet_num;
>  
> -	seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
> -		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d\n",
> -		i, src, srcp, dest, destp, sp->sk_state,
> -		sk_wmem_alloc_get(sp),
> -		sk_rmem_alloc_get(sp),
> -		0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
> -		atomic_read(&sp->sk_refcnt), sp, atomic_read(&sp->sk_drops));
> +	/* Only expose kernel addresses to privileged readers */
> +	if (capable(CAP_NET_ADMIN))
> +		seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
> +			" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d\n",
> +			i, src, srcp, dest, destp, sp->sk_state,
> +			sk_wmem_alloc_get(sp),
> +			sk_rmem_alloc_get(sp),
> +			0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
> +			atomic_read(&sp->sk_refcnt),
> +			sp, atomic_read(&sp->sk_drops));
> +	else
> +		seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
> +			" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %d %d\n",
> +			i, src, srcp, dest, destp, sp->sk_state,
> +			sk_wmem_alloc_get(sp),
> +			sk_rmem_alloc_get(sp),
> +			0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
> +			atomic_read(&sp->sk_refcnt),
> +			0, atomic_read(&sp->sk_drops));

If we really have to do this. At least don't duplicate all this code. Do
the check in the printf argument:

	seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
		...
		capable(CAP_NET_ADMIN) ? sp : 0,

I would even move the decision whether to expose kernel addresses or not
to a function so we can change behavior in one place.
