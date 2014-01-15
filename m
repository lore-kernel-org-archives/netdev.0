From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4 2/3] Send comm and cmdline in SCM_PROCINFO
Date: Tue, 14 Jan 2014 23:03:02 -0500
Message-ID: <20140115040302.GX13431@madcap2.tricolour.ca>
References: <1377614400-27122-1-git-send-email-jkaluza@redhat.com>
	<1389600109-30739-1-git-send-email-jkaluza@redhat.com>
	<1389600109-30739-3-git-send-email-jkaluza@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Jan Kaluza <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1389600109-30739-3-git-send-email-jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On 14/01/13, Jan Kaluza wrote:
> Server-like processes in many cases need credentials and other
> metadata of the peer, to decide if the calling process is allowed to
> request a specific action, or the server just wants to log away this
> type of information for auditing tasks.
> 
> The current practice to retrieve such process metadata is to look that
> information up in procfs with the $PID received over SCM_CREDENTIALS.
> This is sufficient for long-running tasks, but introduces a race which
> cannot be worked around for short-living processes; the calling
> process and all the information in /proc/$PID/ is gone before the
> receiver of the socket message can look it up.
> 
> This introduces a new SCM type called SCM_PROCINFO to allow the direct
> attaching of "comm" and "cmdline" to SCM, which is significantly more
> efficient and will reliably avoid the race with the round-trip over
> procfs.
> 
> To achieve that, new struct called unix_skb_parms_scm had to be created,
> because otherwise unix_skb_parms would be too big.
> 
> scm_get_current_procinfo is inspired by ./fs/proc/base.c.
> 
> Signed-off-by: Jan Kaluza <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Acked-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

> ---
>  include/linux/socket.h |  2 ++
>  include/net/af_unix.h  | 11 +++++++--
>  include/net/scm.h      | 24 +++++++++++++++++++
>  net/core/scm.c         | 65 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  net/unix/af_unix.c     | 57 +++++++++++++++++++++++++++++++++++++------
>  5 files changed, 150 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/socket.h b/include/linux/socket.h
> index eeac565..5a41f35 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h
> @@ -131,6 +131,8 @@ static inline struct cmsghdr * cmsg_nxthdr (struct msghdr *__msg, struct cmsghdr
>  #define SCM_CREDENTIALS 0x02		/* rw: struct ucred		*/
>  #define SCM_SECURITY	0x03		/* rw: security label		*/
>  #define SCM_AUDIT	0x04		/* rw: struct uaudit		*/
> +#define SCM_PROCINFO	0x05	/* rw: comm + cmdline (NULL terminated
> +					   array of char *) */
>  
>  struct ucred {
>  	__u32	pid;
> diff --git a/include/net/af_unix.h b/include/net/af_unix.h
> index 3b9d22a..05c7678 100644
> --- a/include/net/af_unix.h
> +++ b/include/net/af_unix.h
> @@ -27,6 +27,13 @@ struct unix_address {
>  	struct sockaddr_un name[0];
>  };
>  
> +struct unix_skb_parms_scm {
> +	kuid_t loginuid;
> +	unsigned int sessionid;
> +	char *procinfo;
> +	int procinfo_len;
> +};
> +
>  struct unix_skb_parms {
>  	struct pid		*pid;		/* Skb credentials	*/
>  	kuid_t			uid;
> @@ -36,12 +43,12 @@ struct unix_skb_parms {
>  	u32			secid;		/* Security ID		*/
>  #endif
>  	u32			consumed;
> -	kuid_t			loginuid;
> -	unsigned int		sessionid;
> +	struct unix_skb_parms_scm *scm;
>  };
>  
>  #define UNIXCB(skb) 	(*(struct unix_skb_parms *)&((skb)->cb))
>  #define UNIXSID(skb)	(&UNIXCB((skb)).secid)
> +#define UNIXSCM(skb)	(*(UNIXCB((skb)).scm))
>  
>  #define unix_state_lock(s)	spin_lock(&unix_sk(s)->lock)
>  #define unix_state_unlock(s)	spin_unlock(&unix_sk(s)->lock)
> diff --git a/include/net/scm.h b/include/net/scm.h
> index 67de64f..f084e19 100644
> --- a/include/net/scm.h
> +++ b/include/net/scm.h
> @@ -30,11 +30,17 @@ struct scm_fp_list {
>  	struct file		*fp[SCM_MAX_FD];
>  };
>  
> +struct scm_procinfo {
> +	char *procinfo;
> +	int len;
> +};
> +
>  struct scm_cookie {
>  	struct pid		*pid;		/* Skb credentials */
>  	struct scm_fp_list	*fp;		/* Passed files		*/
>  	struct scm_creds	creds;		/* Skb credentials	*/
>  	struct scm_audit	audit;		/* Skb audit	*/
> +	struct scm_procinfo	procinfo;	/* Skb procinfo */
>  #ifdef CONFIG_SECURITY_NETWORK
>  	u32			secid;		/* Passed security ID 	*/
>  #endif
> @@ -45,6 +51,7 @@ void scm_detach_fds_compat(struct msghdr *msg, struct scm_cookie *scm);
>  int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *scm);
>  void __scm_destroy(struct scm_cookie *scm);
>  struct scm_fp_list *scm_fp_dup(struct scm_fp_list *fpl);
> +int scm_get_current_procinfo(char **procinfo);
>  
>  #ifdef CONFIG_SECURITY_NETWORK
>  static __inline__ void unix_get_peersec_dgram(struct socket *sock, struct scm_cookie *scm)
> @@ -72,10 +79,20 @@ static inline void scm_set_audit(struct scm_cookie *scm,
>  	scm->audit.sessionid = sessionid;
>  }
>  
> +static inline void scm_set_procinfo(struct scm_cookie *scm,
> +				    char *procinfo, int len)
> +{
> +	scm->procinfo.procinfo = procinfo;
> +	scm->procinfo.len = len;
> +}
> +
>  static __inline__ void scm_destroy_cred(struct scm_cookie *scm)
>  {
>  	put_pid(scm->pid);
>  	scm->pid  = NULL;
> +	kfree(scm->procinfo.procinfo);
> +	scm->procinfo.procinfo = NULL;
> +	scm->procinfo.len = 0;
>  }
>  
>  static __inline__ void scm_destroy(struct scm_cookie *scm)
> @@ -88,6 +105,8 @@ static __inline__ void scm_destroy(struct scm_cookie *scm)
>  static __inline__ int scm_send(struct socket *sock, struct msghdr *msg,
>  			       struct scm_cookie *scm, bool forcecreds)
>  {
> +	char *procinfo;
> +	int len;
>  	memset(scm, 0, sizeof(*scm));
>  	scm->creds.uid = INVALID_UID;
>  	scm->creds.gid = INVALID_GID;
> @@ -96,6 +115,9 @@ static __inline__ int scm_send(struct socket *sock, struct msghdr *msg,
>  			     current_gid());
>  		scm_set_audit(scm, audit_get_loginuid(current),
>  			      audit_get_sessionid(current));
> +		len = scm_get_current_procinfo(&procinfo);
> +		if (len > 0)
> +			scm_set_procinfo(scm, procinfo, len);
>  	}
>  	unix_get_peersec_dgram(sock, scm);
>  	if (msg->msg_controllen <= 0)
> @@ -148,6 +170,8 @@ static __inline__ void scm_recv(struct socket *sock, struct msghdr *msg,
>  		};
>  		put_cmsg(msg, SOL_SOCKET, SCM_CREDENTIALS, sizeof(ucreds), &ucreds);
>  		put_cmsg(msg, SOL_SOCKET, SCM_AUDIT, sizeof(uaudits), &uaudits);
> +		put_cmsg(msg, SOL_SOCKET, SCM_PROCINFO, scm->procinfo.len,
> +				 scm->procinfo.procinfo);
>  	}
>  
>  	scm_destroy_cred(scm);
> diff --git a/net/core/scm.c b/net/core/scm.c
> index b442e7e..4accb07 100644
> --- a/net/core/scm.c
> +++ b/net/core/scm.c
> @@ -339,3 +339,68 @@ struct scm_fp_list *scm_fp_dup(struct scm_fp_list *fpl)
>  	return new_fpl;
>  }
>  EXPORT_SYMBOL(scm_fp_dup);
> +
> +int scm_get_current_procinfo(char **procinfo)
> +{
> +	int res = 0;
> +	unsigned int len;
> +	char *buffer = NULL;
> +	struct mm_struct *mm;
> +	int comm_len = strlen(current->comm);
> +
> +	*procinfo = NULL;
> +
> +	buffer = kmalloc(PAGE_SIZE, GFP_KERNEL);
> +	if (!buffer)
> +		return -ENOMEM;
> +
> +	mm = get_task_mm(current);
> +	if (!mm)
> +		goto out;
> +	if (!mm->arg_end)
> +		goto out_mm;    /* Shh! No looking before we're done */
> +
> +	len = mm->arg_end - mm->arg_start;
> +
> +	if (len > PAGE_SIZE)
> +		len = PAGE_SIZE;
> +
> +	res = access_process_vm(current, mm->arg_start, buffer, len, 0);
> +
> +	/* If the nul at the end of args has been overwritten, then
> +	 * assume application is using setproctitle(3).
> +	 */
> +	if (res > 0 && buffer[res-1] != '\0' && len < PAGE_SIZE) {
> +		len = strnlen(buffer, res);
> +		if (len < res) {
> +			res = len;
> +		} else {
> +			len = mm->env_end - mm->env_start;
> +			if (len > PAGE_SIZE - res)
> +				len = PAGE_SIZE - res;
> +			res += access_process_vm(current, mm->env_start,
> +						 buffer+res, len, 0);
> +			res = strnlen(buffer, res);
> +		}
> +	}
> +
> +	/* strlen(comm) + \0 + len of cmdline */
> +	len = comm_len + 1 + res;
> +	*procinfo = kmalloc(len, GFP_KERNEL);
> +	if (!*procinfo) {
> +		res = -ENOMEM;
> +		goto out_mm;
> +	}
> +
> +	memcpy(*procinfo, current->comm, comm_len + 1); /* include \0 */
> +	if (res > 0)
> +		memcpy(*procinfo + comm_len + 1, buffer, res);
> +	res = len;
> +
> +out_mm:
> +	mmput(mm);
> +out:
> +	kfree(buffer);
> +	return res;
> +}
> +EXPORT_SYMBOL(scm_get_current_procinfo);
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index bc02a25..35ab97f0 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -1361,9 +1361,14 @@ static void unix_destruct_scm(struct sk_buff *skb)
>  	struct scm_cookie scm;
>  	memset(&scm, 0, sizeof(scm));
>  	scm.pid  = UNIXCB(skb).pid;
> +	if (UNIXCB(skb).scm) {
> +		scm.procinfo.procinfo = UNIXSCM(skb).procinfo;
> +		scm.procinfo.len = UNIXSCM(skb).procinfo_len;
> +	}
>  	if (UNIXCB(skb).fp)
>  		unix_detach_fds(&scm, skb);
>  
> +	kfree(UNIXCB(skb).scm);
>  	/* Alas, it calls VFS */
>  	/* So fscking what? fput() had been SMP-safe since the last Summer */
>  	scm_destroy(&scm);
> @@ -1410,15 +1415,31 @@ static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool sen
>  {
>  	int err = 0;
>  
> +	if (!UNIXCB(skb).scm) {
> +		UNIXCB(skb).scm = kmalloc(sizeof(struct unix_skb_parms_scm),
> +					  GFP_KERNEL);
> +		if (!UNIXCB(skb).scm)
> +			return -ENOMEM;
> +	}
> +
>  	UNIXCB(skb).pid  = get_pid(scm->pid);
>  	UNIXCB(skb).uid = scm->creds.uid;
>  	UNIXCB(skb).gid = scm->creds.gid;
> -	UNIXCB(skb).loginuid = scm->audit.loginuid;
> -	UNIXCB(skb).sessionid = scm->audit.sessionid;
> +	UNIXSCM(skb).loginuid = scm->audit.loginuid;
> +	UNIXSCM(skb).sessionid = scm->audit.sessionid;
>  	UNIXCB(skb).fp = NULL;
>  	if (scm->fp && send_fds)
>  		err = unix_attach_fds(scm, skb);
>  
> +	UNIXSCM(skb).procinfo = NULL;
> +	if (scm->procinfo.procinfo) {
> +		UNIXSCM(skb).procinfo_len = scm->procinfo.len;
> +		UNIXSCM(skb).procinfo = kmemdup(scm->procinfo.procinfo,
> +					scm->procinfo.len, GFP_KERNEL);
> +		if (!UNIXSCM(skb).procinfo)
> +			return -ENOMEM;
> +	}
> +
>  	skb->destructor = unix_destruct_scm;
>  	return err;
>  }
> @@ -1438,8 +1459,10 @@ static void maybe_add_creds(struct sk_buff *skb, const struct socket *sock,
>  	    test_bit(SOCK_PASSCRED, &other->sk_socket->flags)) {
>  		UNIXCB(skb).pid  = get_pid(task_tgid(current));
>  		current_uid_gid(&UNIXCB(skb).uid, &UNIXCB(skb).gid);
> -		UNIXCB(skb).loginuid = audit_get_loginuid(current);
> -		UNIXCB(skb).sessionid = audit_get_sessionid(current);
> +		UNIXSCM(skb).loginuid = audit_get_loginuid(current);
> +		UNIXSCM(skb).sessionid = audit_get_sessionid(current);
> +		UNIXSCM(skb).procinfo_len = scm_get_current_procinfo(
> +			&UNIXSCM(skb).procinfo);
>  	}
>  }
>  
> @@ -1833,7 +1856,17 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
>  		memset(&tmp_scm, 0, sizeof(tmp_scm));
>  	}
>  	scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).uid, UNIXCB(skb).gid);
> -	scm_set_audit(siocb->scm, UNIXCB(skb).loginuid, UNIXCB(skb).sessionid);
> +	if (UNIXCB(skb).scm) {
> +		scm_set_audit(siocb->scm, UNIXSCM(skb).loginuid,
> +			      UNIXSCM(skb).sessionid);
> +		if (UNIXSCM(skb).procinfo) {
> +			scm_set_procinfo(siocb->scm,
> +					 kmemdup(UNIXSCM(skb).procinfo,
> +						 UNIXSCM(skb).procinfo_len,
> +						 GFP_KERNEL),
> +					 UNIXSCM(skb).procinfo_len);
> +		}
> +	}
>  	unix_set_secdata(siocb->scm, skb);
>  
>  	if (!(flags & MSG_PEEK)) {
> @@ -2013,8 +2046,18 @@ again:
>  		} else if (test_bit(SOCK_PASSCRED, &sock->flags)) {
>  			/* Copy credentials */
>  			scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).uid, UNIXCB(skb).gid);
> -			scm_set_audit(siocb->scm, UNIXCB(skb).loginuid,
> -				      UNIXCB(skb).sessionid);
> +			if (UNIXCB(skb).scm) {
> +				scm_set_audit(siocb->scm,
> +					      UNIXSCM(skb).loginuid,
> +					      UNIXSCM(skb).sessionid);
> +				if (UNIXSCM(skb).procinfo) {
> +					scm_set_procinfo(siocb->scm,
> +						kmemdup(UNIXSCM(skb).procinfo,
> +						UNIXSCM(skb).procinfo_len,
> +						GFP_KERNEL),
> +						UNIXSCM(skb).procinfo_len);
> +				}
> +			}
>  			check_creds = 1;
>  		}
>  
> -- 
> 1.8.3.1
> 

- RGB

--
Richard Guy Briggs <rbriggs-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
