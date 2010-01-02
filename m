From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [RFC 6/9] snet: introduce snet_hooks.c and snet_hook.h
Date: Sat, 2 Jan 2010 23:13:03 +0300
Message-ID: <20100102201303.GB27402@ioremap.net>
References: <1262437456-24476-1-git-send-email-sam@synack.fr> <1262437456-24476-7-git-send-email-sam@synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Samir Bellabes <sam@synack.fr>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1262437456-24476-7-git-send-email-sam@synack.fr>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Sat, Jan 02, 2010 at 02:04:13PM +0100, Samir Bellabes (sam@synack.fr) wrote:
> This patch adds the snet LSM's subsystem
> 
> snet_hooks provides the security hook's functions and the security_operations
> structure. Currently hook functions are only related to network stack.
> 
> For each hook function, there is a generic mecanism:
>  0. check if the event [syscall, protocol] is registered
>  1. prepare informations for userspace
>  2. send informations to userspace (snet_netlink)
>  3. wait for verdict from userspace (snet_verdict)
>  4. apply verdict for the syscall
> 
> steps 3 and 4 are only valid for LSM hooks which are returning a value (a way to
> 'filter' the syscall). For hooks returning 'void', steps 3 and 4 don't exist,
> but snet sends security informations to userspace (step 2) to update the global
> security policy.
> 
> Signed-off-by: Samir Bellabes <sam@synack.fr>
> ---

> +#define SNET_DBG_V4()							\
> +	snet_dbg("%u.%u.%u.%u:%u->%u.%u.%u.%u:%u\n",			\
> +		 NIPQUAD(info.src.u3.ip), info.src.u.port,		\
> +		 NIPQUAD(info.dst.u3.ip), info.dst.u.port)
> +
> +#define SNET_DBG_V6()							\
> +	snet_dbg("%pI6:%u->%pI6:%u\n",					\
> +		 &info.src.u3.ip, info.src.u.port,			\
> +		 &info.dst.u3.ip, info.dst.u.port)
> +

There are cool %pi4 and %pi6 format modifiers for IP addresses.

> +#define SNET_CHECK_LISTENERS()						\
> +do {									\
> +	if (atomic_read(&snet_num_listeners) < 0) {			\
> +		snet_dbg("number of listeners is negative\n");		\
> +		verdict = SNET_VERDICT_GRANT;				\
> +		goto out;						\
> +	} else if (atomic_read(&snet_num_listeners) == 0) {		\
> +		verdict = SNET_VERDICT_GRANT;				\
> +		goto out;						\
> +	}								\
> +} while (0)
> +
> +#define SNET_DO_VERDICT(sys, family)					\
> +do {									\
> +	if (verdict_id == 0)						\
> +		goto skip_send_wait;					\
> +	/* sending networking informations to userspace */		\
> +	snet_nl_send_event(verdict_id, sys, protocol,			\
> +			   family, (void *)&info,			\
> +			   sizeof(struct snet_sock_info));		\
> +	/* waiting for userspace reply or timeout */			\
> +	verdict = snet_verdict_wait(verdict_id);			\
> +		/* removing verdict */					\
> +	snet_verdict_remove(verdict_id);				\
> +} while (0)
> +
> +#define SNET_CHECK_LISTENERS_NOVERDICT()				\
> +do {									\
> +	if (atomic_read(&snet_num_listeners) < 0) {			\
> +		snet_dbg("number of listeners is negative\n");		\
> +		goto out;						\
> +	} else if (atomic_read(&snet_num_listeners) == 0) {		\
> +		goto out;						\
> +	}								\
> +} while (0)
> +
> +#define SNET_DO_SEND_EVENT(sys, family)					\
> +do {									\
> +	/* sending networking informations to userspace */		\
> +	snet_nl_send_event(0, sys, protocol,				\
> +			   family, (void *)&info,			\
> +			   sizeof(struct snet_sock_info));		\
> +} while (0)
> +

Why do you need those ugly macroses which reference external objects?
Can it be refactored into some inline function with common error value
instead?


-- 
	Evgeniy Polyakov
