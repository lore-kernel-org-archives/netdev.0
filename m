From: Daniel Walker <dwalker@mvista.com>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Fri, 04 Apr 2008 09:29:35 -0700
Message-ID: <1207326576.21308.71.camel@localhost.localdomain>
References: <20080404122242.867070732@I-love.SAKURA.ne.jp>
	 <20080404122408.986477936@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Kentaro Takeda <takedakn@nttdata.co.jp>,
	Toshiharu Harada <haradats@nttdata.co.jp>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080404122408.986477936@I-love.SAKURA.ne.jp>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, 2008-04-04 at 21:23 +0900, Tetsuo Handa wrote:

> This patch makes two lines deletion by
>   sed -e 's:search_binary_handler:search_binary_handler_with_transition:'
> TOMOYO does domain transition when execve() is called.
> Thus, distinguishing search_binary_handler() from do_execve() and
> search_binary_handler() from other functions (e.g. load_script())
> makes TOMOYO's domain transition handler simple.
> 
> Signed-off-by: Kentaro Takeda <takedakn@nttdata.co.jp>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Toshiharu Harada <haradats@nttdata.co.jp>
> Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>
> Cc: linux-netdev <netdev@vger.kernel.org>
> ---
>  Documentation/kernel-parameters.txt |   15 ++++
>  arch/ia64/ia32/sys_ia32.c           |    7 ++
>  arch/mips/kernel/ptrace32.c         |    7 ++
>  arch/s390/kernel/ptrace.c           |    7 ++
>  arch/sh/kernel/ptrace_64.c          |    7 ++
>  arch/x86/kernel/ptrace.c            |    7 ++
>  fs/Kconfig                          |    2 
>  fs/Makefile                         |    2 
>  fs/attr.c                           |   19 +++++

>From a reviews perspective what I would want is each set of changes,
file system, networking, arch, etc split into separate patches. For
example you have a number of patches just adding header files. You could
merge the header file with the hook additions. Then you have a natural
code split up which should be easier to review..

> +	/***** TOMOYO Linux start. *****/
> +	if (!ccs_capable(TOMOYO_SYS_PTRACE))
> +		return -EPERM;
> +	/***** TOMOYO Linux end. *****/

For instance if the function name was "tomoyo_check_capable" it would be
clear that it's part of your code.. The current function naming here is
obscure ..
 

> +	/***** CCS start. *****/
> +#if defined(CONFIG_SAKURA) || defined(CONFIG_TOMOYO)
> +	printk(KERN_INFO "Hook version: 2.6.25-rc8-mm1 2008/04/02\n");
> +#endif
> +	/***** CCS end. *****/

This printk clearly needs to go away ..

> --- linux-2.6.25-rc8-mm1.orig/include/linux/init_task.h
> +++ linux-2.6.25-rc8-mm1/include/linux/init_task.h
> @@ -197,6 +197,10 @@ extern struct group_info init_groups;
>  	INIT_IDS							\
>  	INIT_TRACE_IRQFLAGS						\
>  	INIT_LOCKDEP							\
> +	/***** TOMOYO Linux start. *****/        \
> +	.domain_info = &KERNEL_DOMAIN,           \
> +	.tomoyo_flags = 0,                       \
> +	/***** TOMOYO Linux end. *****/          \
>  }

ifdef's ?

> 
> --- linux-2.6.25-rc8-mm1.orig/include/linux/sched.h
> +++ linux-2.6.25-rc8-mm1/include/linux/sched.h
> @@ -29,6 +29,11 @@
>  #define CLONE_NEWNET		0x40000000	/* New network namespace */
>  #define CLONE_IO		0x80000000	/* Clone io context */
>  
> +/***** TOMOYO Linux start. *****/
> +struct domain_info;
> +extern struct domain_info KERNEL_DOMAIN;
> +/***** TOMOYO Linux end. *****/
> +
>  /*
>   * Scheduling policies
>   */
> @@ -1278,6 +1283,10 @@ struct task_struct {
>  	int latency_record_count;
>  	struct latency_record latency_record[LT_SAVECOUNT];
>  #endif
> +	/***** TOMOYO Linux start. *****/
> +	struct domain_info *domain_info;
> +	u32 tomoyo_flags;
> +	/***** TOMOYO Linux end. *****/
>  };

ifdefs? 
 


