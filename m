From: Jan =?ISO-8859-1?Q?L=FCbbe?= <jluebbe@debian.org>
Subject: Re: Kernel panic when using bridge
Date: Tue, 12 Apr 2011 15:02:33 +0200
Message-ID: <1302613353.30934.22.camel@polaris.local>
References: <4D9E62D9.5010400@scotdoyle.com>
	 <20110408121700.0aad53fe@nehalam>	<4D9FE5BE.6060600@scotdoyle.com>
	 <20110409161908.a2aca120.shimoda.hiroaki@gmail.com>
	 <4DA39330.2030102@scotdoyle.com> <20110411183105.46e86684@nehalam>
	 <4DA3CB4B.9090506@scotdoyle.com> <1302581384.3603.14.camel@edumazet-laptop>
	 <1302582172.3603.18.camel@edumazet-laptop> <4DA3E074.5090603@scotdoyle.com>
	 <1302587490.3603.22.camel@edumazet-laptop> <4DA3F909.5020609@scotdoyle.com>
	 <1302608951.3233.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Scot Doyle <lkml@scotdoyle.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sirius.lasnet.de ([78.47.116.19]:55600 "EHLO sirius.lasnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750901Ab1DLNCo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 09:02:44 -0400
In-Reply-To: <1302608951.3233.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi! 

On Tue, 2011-04-12 at 13:49 +0200, Eric Dumazet wrote:
> Considering recent changes in ip_options_echo() I would suggest to add
> following patch and/or revert commit 8628bd8af7c4c14f40
> (ipv4: Fix IP timestamp option (IPOPT_TS_PRESPEC) handling in
> ip_options_echo())

I've read this thread, but I'm not sure why my patch is related to these
kernel panics. The behavior is only changed for packets with the
timestamp option in prespecified addresses mode. Even then, it shouldn't
cause ip_options_build to write to unallocated memory later.

> diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
> index 28a736f..35f2bf9 100644
> --- a/net/ipv4/ip_options.c
> +++ b/net/ipv4/ip_options.c
> @@ -200,6 +200,11 @@ int ip_options_echo(struct ip_options * dopt, struct sk_buff * skb)
>                 *dptr++ = IPOPT_END;
>                 dopt->optlen++;
>         }
> +       if (unlikely(dopt->optlen > 40)) {
> +               pr_err("ip_options_echo() fatal error optlen=%u > 40\n", dopt->optlen);
> +               print_hex_dump(KERN_ERR, "ip options: ", DUMP_PREFIX_OFFSET,
> +                       16, 1, dopt->__data, dopt->optlen, false);
> +       }
>         return 0;
>  }

Here you check dopt->optlen, which certainly should be 40 at most. The
calculation of dopt->optlen wasn't changed by my patch, though.

Regards,
Jan

