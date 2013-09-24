From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [pchecks v1 2/4] Use raw cpu ops for calls that would trigger
 with checks
Date: Tue, 24 Sep 2013 09:32:50 +0200
Message-ID: <20130924073250.GD28538@gmail.com>
References: <20130923191256.584672290@linux.com>
 <000001414c3d064a-ebe0610b-6951-4a74-bd33-8480e3e1e364-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, akpm@linuxfoundation.org,
	Steven Rostedt <srostedt@redhat.com>,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>, netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <000001414c3d064a-ebe0610b-6951-4a74-bd33-8480e3e1e364-000000@email.amazonses.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(netdev Cc:-ed)

* Christoph Lameter <cl@linux.com> wrote:

> These location triggered during testing with KVM.
> 
> These are fetches without preemption off where we judged that
> to be more performance efficient or where other means of
> providing synchronization (BH handling) are available.

> Index: linux/include/net/snmp.h
> ===================================================================
> --- linux.orig/include/net/snmp.h	2013-09-12 13:26:29.216103951 -0500
> +++ linux/include/net/snmp.h	2013-09-12 13:26:29.208104037 -0500
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

Are the networking folks fine with allowing unafe operations of SNMP stats 
in preemptible sections, or should the kernel produce an optional warning 
message if CONFIG_PREEMPT_DEBUG=y and these ops are used in preemptible 
(non-bh, non-irq-handler, non-irqs-off, etc.) sections?

RAW_SNMP_*_STATS() ops could be used to annotate those places where that 
kind of usage is safe.

Thanks,

	Ingo
