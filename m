From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [raw v1 2/4] [NET] Use raw_cpu ops for SNMP stats
Date: Tue, 8 Oct 2013 09:21:14 +0200
Message-ID: <20131008072114.GA4455@gmail.com>
References: <20131007183226.334180014@linux.com>
 <0000014194309205-d0af4d2d-a046-4189-b4f0-ffea37374988-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, akpm@linuxfoundation.org,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Steven Rostedt <srostedt@redhat.com>,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Christoph Lameter <cl@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0000014194309205-d0af4d2d-a046-4189-b4f0-ffea37374988-000000@email.amazonses.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Christoph Lameter <cl@linux.com> wrote:

> SNMP stats are not protected by preemption but by bh handling.

Most forms of bh exclusion work via the preemption count though, and 
softirq contexts themselves are generally not preemptible [to other CPUs] 
either.

So the warnings should, in most cases, not trigger.

> Since protection is provided outside of preemption raw_cpu_ops
> need to be used to avoid false positives.

Could you quote the warning that pops up? It might be better to annotate 
the specific safe usages than to potentially hide bugs:

> --- linux.orig/include/net/snmp.h	2013-10-07 09:16:07.595206864 -0500
> +++ linux/include/net/snmp.h	2013-10-07 09:16:07.591206909 -0500
> @@ -126,7 +126,7 @@ struct linux_xfrm_mib {
>  	extern __typeof__(type) __percpu *name[SNMP_ARRAY_SZ]
>  
>  #define SNMP_INC_STATS_BH(mib, field)	\
> -			__this_cpu_inc(mib[0]->mibs[field])
> +			raw_cpu_inc(mib[0]->mibs[field])
>  
>  #define SNMP_INC_STATS_USER(mib, field)	\
>  			this_cpu_inc(mib[0]->mibs[field])
> @@ -141,7 +141,7 @@ struct linux_xfrm_mib {
>  			this_cpu_dec(mib[0]->mibs[field])
>  
>  #define SNMP_ADD_STATS_BH(mib, field, addend)	\
> -			__this_cpu_add(mib[0]->mibs[field], addend)
> +			raw_cpu_add(mib[0]->mibs[field], addend)
>  
>  #define SNMP_ADD_STATS_USER(mib, field, addend)	\
>  			this_cpu_add(mib[0]->mibs[field], addend)

Doing this will hide any true bugs if any of these primitives is used in 
an unsafe context.

Thanks,

	Ingo
