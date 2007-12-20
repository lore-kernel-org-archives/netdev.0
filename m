From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/3] XFRM: Assorted IPsec fixups
Date: Fri, 21 Dec 2007 09:25:38 +1100 (EST)
Message-ID: <Xine.LNX.4.64.0712210925130.27551@us.intercode.com.au>
References: <20071220214200.12122.89628.stgit@flek.lan>
	<20071220214219.12122.57208.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-audit@redhat.com
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <20071220214219.12122.57208.stgit@flek.lan>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Thu, 20 Dec 2007, Paul Moore wrote:

> This patch fixes a number of small but potentially troublesome things in the
> XFRM/IPsec code:
> 
>  * Use the 'audit_enabled' variable already in include/linux/audit.h
>    Removed the need for extern declarations local to each XFRM audit fuction
> 
>  * Convert 'sid' to 'secid' everywhere we can
>    The 'sid' name is specific to SELinux, 'secid' is the common naming
>    convention used by the kernel when refering to tokenized LSM labels,
>    unfortunately we have to leave 'ctx_sid' in 'struct xfrm_sec_ctx' otherwise
>    we risk breaking userspace
> 
>  * Convert address display to use standard NIP* macros
>    Similar to what was recently done with the SPD audit code, this also also
>    includes the removal of some unnecessary memcpy() calls
> 
>  * Move common code to xfrm_audit_common_stateinfo()
>    Code consolidation from the "less is more" book on software development
> 
>  * Proper spacing around commas in function arguments
>    Minor style tweak since I was already touching the code
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Acked-by: James Morris <jmorris@namei.org>

> ---
> 
>  include/net/xfrm.h     |   14 ++++++-------
>  net/xfrm/xfrm_policy.c |   15 ++++++--------
>  net/xfrm/xfrm_state.c  |   53 ++++++++++++++++++++----------------------------
>  3 files changed, 36 insertions(+), 46 deletions(-)
> 
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index 32b99e2..ac6cf09 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -548,7 +548,7 @@ struct xfrm_audit
>  };
>  
>  #ifdef CONFIG_AUDITSYSCALL
> -static inline struct audit_buffer *xfrm_audit_start(u32 auid, u32 sid)
> +static inline struct audit_buffer *xfrm_audit_start(u32 auid, u32 secid)
>  {
>  	struct audit_buffer *audit_buf = NULL;
>  	char *secctx;
> @@ -561,8 +561,8 @@ static inline struct audit_buffer *xfrm_audit_start(u32 auid, u32 sid)
>  
>  	audit_log_format(audit_buf, "auid=%u", auid);
>  
> -	if (sid != 0 &&
> -	    security_secid_to_secctx(sid, &secctx, &secctx_len) == 0) {
> +	if (secid != 0 &&
> +	    security_secid_to_secctx(secid, &secctx, &secctx_len) == 0) {
>  		audit_log_format(audit_buf, " subj=%s", secctx);
>  		security_release_secctx(secctx, secctx_len);
>  	} else
> @@ -571,13 +571,13 @@ static inline struct audit_buffer *xfrm_audit_start(u32 auid, u32 sid)
>  }
>  
>  extern void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
> -				  u32 auid, u32 sid);
> +				  u32 auid, u32 secid);
>  extern void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result,
> -				  u32 auid, u32 sid);
> +				  u32 auid, u32 secid);
>  extern void xfrm_audit_state_add(struct xfrm_state *x, int result,
> -				 u32 auid, u32 sid);
> +				 u32 auid, u32 secid);
>  extern void xfrm_audit_state_delete(struct xfrm_state *x, int result,
> -				    u32 auid, u32 sid);
> +				    u32 auid, u32 secid);
>  #else
>  #define xfrm_audit_policy_add(x, r, a, s)	do { ; } while (0)
>  #define xfrm_audit_policy_delete(x, r, a, s)	do { ; } while (0)
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index d2084b1..c8f0656 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -24,6 +24,7 @@
>  #include <linux/netfilter.h>
>  #include <linux/module.h>
>  #include <linux/cache.h>
> +#include <linux/audit.h>
>  #include <net/dst.h>
>  #include <net/xfrm.h>
>  #include <net/ip.h>
> @@ -2317,15 +2318,14 @@ static inline void xfrm_audit_common_policyinfo(struct xfrm_policy *xp,
>  	}
>  }
>  
> -void
> -xfrm_audit_policy_add(struct xfrm_policy *xp, int result, u32 auid, u32 sid)
> +void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
> +			   u32 auid, u32 secid)
>  {
>  	struct audit_buffer *audit_buf;
> -	extern int audit_enabled;
>  
>  	if (audit_enabled == 0)
>  		return;
> -	audit_buf = xfrm_audit_start(sid, auid);
> +	audit_buf = xfrm_audit_start(auid, secid);
>  	if (audit_buf == NULL)
>  		return;
>  	audit_log_format(audit_buf, " op=SPD-add res=%u", result);
> @@ -2334,15 +2334,14 @@ xfrm_audit_policy_add(struct xfrm_policy *xp, int result, u32 auid, u32 sid)
>  }
>  EXPORT_SYMBOL_GPL(xfrm_audit_policy_add);
>  
> -void
> -xfrm_audit_policy_delete(struct xfrm_policy *xp, int result, u32 auid, u32 sid)
> +void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result,
> +			      u32 auid, u32 secid)
>  {
>  	struct audit_buffer *audit_buf;
> -	extern int audit_enabled;
>  
>  	if (audit_enabled == 0)
>  		return;
> -	audit_buf = xfrm_audit_start(sid, auid);
> +	audit_buf = xfrm_audit_start(auid, secid);
>  	if (audit_buf == NULL)
>  		return;
>  	audit_log_format(audit_buf, " op=SPD-delete res=%u", result);
> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index 95df01c..dd38e6f 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
> @@ -19,6 +19,7 @@
>  #include <linux/ipsec.h>
>  #include <linux/module.h>
>  #include <linux/cache.h>
> +#include <linux/audit.h>
>  #include <asm/uaccess.h>
>  
>  #include "xfrm_hash.h"
> @@ -1996,69 +1997,59 @@ void __init xfrm_state_init(void)
>  static inline void xfrm_audit_common_stateinfo(struct xfrm_state *x,
>  					       struct audit_buffer *audit_buf)
>  {
> -	if (x->security)
> +	struct xfrm_sec_ctx *ctx = x->security;
> +	u32 spi = ntohl(x->id.spi);
> +
> +	if (ctx)
>  		audit_log_format(audit_buf, " sec_alg=%u sec_doi=%u sec_obj=%s",
> -				 x->security->ctx_alg, x->security->ctx_doi,
> -				 x->security->ctx_str);
> +				 ctx->ctx_alg, ctx->ctx_doi, ctx->ctx_str);
>  
>  	switch(x->props.family) {
>  	case AF_INET:
> -		audit_log_format(audit_buf, " src=%u.%u.%u.%u dst=%u.%u.%u.%u",
> +		audit_log_format(audit_buf,
> +				 " src=" NIPQUAD_FMT " dst=" NIPQUAD_FMT,
>  				 NIPQUAD(x->props.saddr.a4),
>  				 NIPQUAD(x->id.daddr.a4));
>  		break;
>  	case AF_INET6:
> -		{
> -			struct in6_addr saddr6, daddr6;
> -
> -			memcpy(&saddr6, x->props.saddr.a6,
> -				sizeof(struct in6_addr));
> -			memcpy(&daddr6, x->id.daddr.a6,
> -				sizeof(struct in6_addr));
> -			audit_log_format(audit_buf,
> -					 " src=" NIP6_FMT " dst=" NIP6_FMT,
> -					 NIP6(saddr6), NIP6(daddr6));
> -		}
> +		audit_log_format(audit_buf,
> +				 " src=" NIP6_FMT " dst=" NIP6_FMT,
> +				 NIP6(*(struct in6_addr *)x->props.saddr.a6),
> +				 NIP6(*(struct in6_addr *)x->id.daddr.a6));
>  		break;
>  	}
> +
> +	audit_log_format(audit_buf, " spi=%u(0x%x)", spi, spi);
>  }
>  
> -void
> -xfrm_audit_state_add(struct xfrm_state *x, int result, u32 auid, u32 sid)
> +void xfrm_audit_state_add(struct xfrm_state *x, int result,
> +			  u32 auid, u32 secid)
>  {
>  	struct audit_buffer *audit_buf;
> -	u32 spi;
> -	extern int audit_enabled;
>  
>  	if (audit_enabled == 0)
>  		return;
> -	audit_buf = xfrm_audit_start(sid, auid);
> +	audit_buf = xfrm_audit_start(auid, secid);
>  	if (audit_buf == NULL)
>  		return;
> -	audit_log_format(audit_buf, " op=SAD-add res=%u",result);
> +	audit_log_format(audit_buf, " op=SAD-add res=%u", result);
>  	xfrm_audit_common_stateinfo(x, audit_buf);
> -	spi = ntohl(x->id.spi);
> -	audit_log_format(audit_buf, " spi=%u(0x%x)", spi, spi);
>  	audit_log_end(audit_buf);
>  }
>  EXPORT_SYMBOL_GPL(xfrm_audit_state_add);
>  
> -void
> -xfrm_audit_state_delete(struct xfrm_state *x, int result, u32 auid, u32 sid)
> +void xfrm_audit_state_delete(struct xfrm_state *x, int result,
> +			     u32 auid, u32 secid)
>  {
>  	struct audit_buffer *audit_buf;
> -	u32 spi;
> -	extern int audit_enabled;
>  
>  	if (audit_enabled == 0)
>  		return;
> -	audit_buf = xfrm_audit_start(sid, auid);
> +	audit_buf = xfrm_audit_start(auid, secid);
>  	if (audit_buf == NULL)
>  		return;
> -	audit_log_format(audit_buf, " op=SAD-delete res=%u",result);
> +	audit_log_format(audit_buf, " op=SAD-delete res=%u", result);
>  	xfrm_audit_common_stateinfo(x, audit_buf);
> -	spi = ntohl(x->id.spi);
> -	audit_log_format(audit_buf, " spi=%u(0x%x)", spi, spi);
>  	audit_log_end(audit_buf);
>  }
>  EXPORT_SYMBOL_GPL(xfrm_audit_state_delete);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
James Morris
<jmorris@namei.org>
