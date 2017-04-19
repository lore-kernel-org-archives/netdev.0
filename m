From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net] net: ipv6: RTF_PCPU should not be settable from
 userspace
Date: Wed, 19 Apr 2017 14:52:32 -0700
Message-ID: <20170419215232.2lu7kaebwg75ikn3@giedrius-mbp.dhcp.thefacebook.com>
References: <1492636783-29756-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <andreyknvl@google.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:59434 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752577AbdDSVwj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 17:52:39 -0400
Content-Disposition: inline
In-Reply-To: <1492636783-29756-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 19, 2017 at 02:19:43PM -0700, David Ahern wrote:
> Andrey reported a fault in the IPv6 route code:
>
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] SMP KASAN
> Modules linked in:
> CPU: 1 PID: 4035 Comm: a.out Not tainted 4.11.0-rc7+ #250
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff880069809600 task.stack: ffff880062dc8000
> RIP: 0010:ip6_rt_cache_alloc+0xa6/0x560 net/ipv6/route.c:975
> RSP: 0018:ffff880062dced30 EFLAGS: 00010206
> RAX: dffffc0000000000 RBX: ffff8800670561c0 RCX: 0000000000000006
> RDX: 0000000000000003 RSI: ffff880062dcfb28 RDI: 0000000000000018
> RBP: ffff880062dced68 R08: 0000000000000001 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
> R13: ffff880062dcfb28 R14: dffffc0000000000 R15: 0000000000000000
> FS:  00007feebe37e7c0(0000) GS:ffff88006cb00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000205a0fe4 CR3: 000000006b5c9000 CR4: 00000000000006e0
> Call Trace:
>  ip6_pol_route+0x1512/0x1f20 net/ipv6/route.c:1128
>  ip6_pol_route_output+0x4c/0x60 net/ipv6/route.c:1212
> ...
>
> Andrey's syzkaller program passes rtmsg.rtmsg_flags with the RTF_PCPU bit
> set. Flags passed to the kernel are blindly copied to the allocated
> rt6_info by ip6_route_info_create making a newly inserted route appear
> as though it is a per-cpu route. ip6_rt_cache_alloc sees the flag set
> and expects rt->dst.from to be set - which it is not since it is not
> really a per-cpu copy. The subsequent call to __ip6_dst_alloc then
> generates the fault.
>
> Fix by checking for the flag and failing with EINVAL.
Thanks for the fix.

Acked-by: Martin KaFai Lau <kafai@fb.com>

>
> Fixes: d52d3997f843f ("ipv6: Create percpu rt6_info")
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  include/uapi/linux/ipv6_route.h | 2 +-
>  net/ipv6/route.c                | 4 ++++
>  2 files changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/include/uapi/linux/ipv6_route.h b/include/uapi/linux/ipv6_route.h
> index 85bbb1799df3..d496c02e14bc 100644
> --- a/include/uapi/linux/ipv6_route.h
> +++ b/include/uapi/linux/ipv6_route.h
> @@ -35,7 +35,7 @@
>  #define RTF_PREF(pref)	((pref) << 27)
>  #define RTF_PREF_MASK	0x18000000
>
> -#define RTF_PCPU	0x40000000
> +#define RTF_PCPU	0x40000000	/* read-only: can not be set by user */
>  #define RTF_LOCAL	0x80000000
>
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 4ba7c49872ff..a1bf426c959b 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1854,6 +1854,10 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg)
>  	int addr_type;
>  	int err = -EINVAL;
>
> +	/* RTF_PCPU is an internal flag; can not be set by userspace */
> +	if (cfg->fc_flags & RTF_PCPU)
> +		goto out;
> +
>  	if (cfg->fc_dst_len > 128 || cfg->fc_src_len > 128)
>  		goto out;
>  #ifndef CONFIG_IPV6_SUBTREES
> --
> 2.9.3
>
