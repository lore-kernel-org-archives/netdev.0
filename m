From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH net-next v3 3/9] static_key: WARN on usage before
 jump_label_init was called
Date: Thu, 17 Oct 2013 17:19:40 -0400
Message-ID: <20131017171940.173bab09@gandalf.local.home>
References: <1381987923-1524-1-git-send-email-hannes@stressinduktion.org>
	<1381987923-1524-4-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Andi Kleen <andi@firstfloor.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.225]:62430 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1762569Ab3JQVTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 17:19:41 -0400
In-Reply-To: <1381987923-1524-4-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Oct 2013 07:31:57 +0200
Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> Based on a patch from Andi Kleen.

I'm fine with the patch, but the change log needs a lot more work.
Like, why is this needed?  I know, but does anyone else?

-- Steve



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
