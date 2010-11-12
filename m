From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/10] Fix leaking of kernel heap addresses in net/
Date: Fri, 12 Nov 2010 15:11:46 +0000
Message-ID: <1289574706.2247.4.camel@achroite.uk.solarflarecom.com>
References: <1289524023.5167.67.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
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
Received: from mail.solarflare.com ([216.237.3.220]:20766 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757099Ab0KLPLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 10:11:53 -0500
In-Reply-To: <1289524023.5167.67.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-11-11 at 20:07 -0500, Dan Rosenberg wrote:
> diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
> index 1f85ef2..0ac8ff2 100644
> --- a/net/ipv4/raw.c
> +++ b/net/ipv4/raw.c
[...]
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
[...]

This could just be written as:

	seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %lx %d\n",
		i, src, srcp, dest, destp, sp->sk_state,
		sk_wmem_alloc_get(sp),
		sk_rmem_alloc_get(sp),
		0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
		atomic_read(&sp->sk_refcnt),
		capable(CAP_NET_ADMIN) ? (unsigned long)sp : 0UL,
		atomic_read(&sp->sk_drops));

Similarly for other formats that you want to make conditional on
CAP_NET_ADMIN.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

