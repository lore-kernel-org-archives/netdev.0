From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH net-next v4 3/9] static_key: WARN on usage before
 jump_label_init was called
Date: Wed, 6 Nov 2013 16:16:49 -0500
Message-ID: <20131106161649.2bb1dbb0@gandalf.local.home>
References: <1382212139-20301-1-git-send-email-hannes@stressinduktion.org>
	<1382212139-20301-4-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Andi Kleen <andi@firstfloor.org>,
	Ingo Molnar <mingo@kernel.org>, Jason Baron <jbaron@akamai.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.226]:12332 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756020Ab3KFVQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 16:16:54 -0500
In-Reply-To: <1382212139-20301-4-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the late reply, but this was sent while I was getting ready
for my two week conference trip.

Note, this should not go through the net tree, but instead should go
through tip, as it deals with jump labels and not networking.

Otherwise, this patch looks good.

Reviewed-by: Steven Rostedt <rostedt@goodmis.org>


-- Steve


Sat, 19 Oct 2013 21:48:53 +0200
Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> Usage of the static key primitives to toggle a branch must not be used
> before jump_label_init() is called from init/main.c. jump_label_init
> reorganizes and wires up the jump_entries so usage before that could
> have unforeseen consequences.
> 
> Following primitives are now checked for correct use:
> * static_key_slow_inc
> * static_key_slow_dec
> * static_key_slow_dec_deferred
> * jump_label_rate_limit
> 
> The x86 architecture already checks this by testing if the default_nop
> was already replaced with an optimal nop or with a branch instruction. It
> will panic then. Other architectures don't check for this.
> 
> Because we need to relax this check for the x86 arch to allow code to
> transition from default_nop to the enabled state and other architectures
> did not check for this at all this patch introduces checking on the
> static_key primitives in a non-arch dependent manner.
> 
> All checked functions are considered slow-path so the additional check
> does no harm to performance.
> 
> The warnings are best observed with earlyprintk.
> 
> Based on a patch from Andi Kleen.
> 
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Andi Kleen <andi@firstfloor.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  include/linux/jump_label.h           | 10 ++++++++++
>  include/linux/jump_label_ratelimit.h |  2 ++
>  init/main.c                          |  7 +++++++
>  kernel/jump_label.c                  |  5 +++++
>  4 files changed, 24 insertions(+)
> 
> diff --git a/include/linux/jump_label.h b/include/linux/jump_label.h
> index a507907..e96be72 100644
> --- a/include/linux/jump_label.h
> +++ b/include/linux/jump_label.h
> @@ -48,6 +48,13 @@
>  
>  #include <linux/types.h>
>  #include <linux/compiler.h>
> +#include <linux/bug.h>
> +
> +extern bool static_key_initialized;
> +
> +#define STATIC_KEY_CHECK_USE() WARN(!static_key_initialized,		      \
> +				    "%s used before call to jump_label_init", \
> +				    __func__)
>  
>  #if defined(CC_HAVE_ASM_GOTO) && defined(CONFIG_JUMP_LABEL)
>  
> @@ -128,6 +135,7 @@ struct static_key {
>  
>  static __always_inline void jump_label_init(void)
>  {
> +	static_key_initialized = true;
>  }
>  
>  static __always_inline bool static_key_false(struct static_key *key)
> @@ -146,11 +154,13 @@ static __always_inline bool static_key_true(struct static_key *key)
>  
>  static inline void static_key_slow_inc(struct static_key *key)
>  {
> +	STATIC_KEY_CHECK_USE();
>  	atomic_inc(&key->enabled);
>  }
>  
>  static inline void static_key_slow_dec(struct static_key *key)
>  {
> +	STATIC_KEY_CHECK_USE();
>  	atomic_dec(&key->enabled);
>  }
>  
> diff --git a/include/linux/jump_label_ratelimit.h b/include/linux/jump_label_ratelimit.h
> index 1137883..089f70f 100644
> --- a/include/linux/jump_label_ratelimit.h
> +++ b/include/linux/jump_label_ratelimit.h
> @@ -23,12 +23,14 @@ struct static_key_deferred {
>  };
>  static inline void static_key_slow_dec_deferred(struct static_key_deferred *key)
>  {
> +	STATIC_KEY_CHECK_USE();
>  	static_key_slow_dec(&key->key);
>  }
>  static inline void
>  jump_label_rate_limit(struct static_key_deferred *key,
>  		unsigned long rl)
>  {
> +	STATIC_KEY_CHECK_USE();
>  }
>  #endif	/* HAVE_JUMP_LABEL */
>  #endif	/* _LINUX_JUMP_LABEL_RATELIMIT_H */
> diff --git a/init/main.c b/init/main.c
> index af310af..27bbec1a 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -136,6 +136,13 @@ static char *execute_command;
>  static char *ramdisk_execute_command;
>  
>  /*
> + * Used to generate warnings if static_key manipulation functions are used
> + * before jump_label_init is called.
> + */
> +bool static_key_initialized __read_mostly = false;
> +EXPORT_SYMBOL_GPL(static_key_initialized);
> +
> +/*
>   * If set, this is an indication to the drivers that reset the underlying
>   * device before going ahead with the initialization otherwise driver might
>   * rely on the BIOS and skip the reset operation.
> diff --git a/kernel/jump_label.c b/kernel/jump_label.c
> index 297a924..9019f15 100644
> --- a/kernel/jump_label.c
> +++ b/kernel/jump_label.c
> @@ -58,6 +58,7 @@ static void jump_label_update(struct static_key *key, int enable);
>  
>  void static_key_slow_inc(struct static_key *key)
>  {
> +	STATIC_KEY_CHECK_USE();
>  	if (atomic_inc_not_zero(&key->enabled))
>  		return;
>  
> @@ -103,12 +104,14 @@ static void jump_label_update_timeout(struct work_struct *work)
>  
>  void static_key_slow_dec(struct static_key *key)
>  {
> +	STATIC_KEY_CHECK_USE();
>  	__static_key_slow_dec(key, 0, NULL);
>  }
>  EXPORT_SYMBOL_GPL(static_key_slow_dec);
>  
>  void static_key_slow_dec_deferred(struct static_key_deferred *key)
>  {
> +	STATIC_KEY_CHECK_USE();
>  	__static_key_slow_dec(&key->key, key->timeout, &key->work);
>  }
>  EXPORT_SYMBOL_GPL(static_key_slow_dec_deferred);
> @@ -116,6 +119,7 @@ EXPORT_SYMBOL_GPL(static_key_slow_dec_deferred);
>  void jump_label_rate_limit(struct static_key_deferred *key,
>  		unsigned long rl)
>  {
> +	STATIC_KEY_CHECK_USE();
>  	key->timeout = rl;
>  	INIT_DELAYED_WORK(&key->work, jump_label_update_timeout);
>  }
> @@ -212,6 +216,7 @@ void __init jump_label_init(void)
>  		key->next = NULL;
>  #endif
>  	}
> +	static_key_initialized = true;
>  	jump_label_unlock();
>  }
>  
