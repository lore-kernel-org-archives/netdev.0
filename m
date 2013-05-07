From: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC 09/48] Audit: make audit_enabled per user namespace
Date: Tue, 7 May 2013 11:44:35 -0400
Message-ID: <20130507154434.GA15275@redhat.com>
References: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
	<1367893269-9308-10-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1367893269-9308-10-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 07, 2013 at 10:20:30AM +0800, Gao feng wrote:
> diff --git a/include/linux/audit.h b/include/linux/audit.h
> index 684599b..33e6584 100644
> --- a/include/linux/audit.h
> +++ b/include/linux/audit.h
> @@ -441,7 +441,8 @@ extern int audit_filter_type(int type);
>  extern int  audit_receive_filter(int type, int pid, int seq,
>  				void *data, size_t datasz, kuid_t loginuid,
>  				u32 sessionid, u32 sid);
> -extern int audit_enabled;
> +#define audit_enabled (init_user_ns.audit.enabled)
> +#define audit_enabled_ns (ns->audit.enabled)
>  #else /* CONFIG_AUDIT */
>  static inline __printf(4, 5)
>  void audit_log(struct audit_context *ctx, gfp_t gfp_mask, int type,
> @@ -487,6 +488,7 @@ static inline void audit_set_user_ns(struct user_namespace *ns)
>  static inline void audit_free_user_ns(struct user_namespace *ns)
>  { }
>  #define audit_enabled 0
> +#define audit_enabled_ns(ns) 0

conflicting definitions here. maybe the first one should be
	#define audit_enabled_ns(ns) (ns->audit.enabled)?

> @@ -285,14 +282,15 @@ static int audit_do_config_change(char *function_name, int *to_change,
>  				  u32 sid)
>  {
>  	int allow_changes, rc = 0, old = *to_change;
> +	struct user_namespace *ns = current_user_ns();
>  
>  	/* check if we are locked */
> -	if (audit_enabled == AUDIT_LOCKED)
> +	if (ns->audit.enabled == AUDIT_LOCKED)

then you don't use the macro you introduced?

> @@ -609,7 +608,7 @@ static int audit_log_common_recv_msg(struct audit_buffer **ab, u16 msg_type,
>  	char *ctx = NULL;
>  	u32 len;
>  
> -	if (!audit_enabled) {
> +	if (!init_user_ns.audit.enabled) {
>  		*ab = NULL;
>  		return rc;
>  	}

same here

-- 
Aristeu
