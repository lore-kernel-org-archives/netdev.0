From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH v18 01/15] Add PR_{GET,SET}_NO_NEW_PRIVS to prevent execve
 from granting privs
Date: Fri, 13 Apr 2012 14:16:20 +1000 (EST)
Message-ID: <alpine.LRH.2.02.1204131414580.22039@tundra.namei.org>
References: <1334267284-19166-1-git-send-email-wad@chromium.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, linux-man@vger.kernel.org,
        linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
        linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
        netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
        "David S. Miller" <davem@davemloft.net>, hpa@zytor.com,
        mingo@redhat.com, Oleg Nesterov <oleg@redhat.com>,
        peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
        tglx@linutronix.de, luto@mit.edu, Eric Paris <eparis@redhat.com>,
        Serge Hallyn <serge.hallyn@canonical.com>, djm@mindrot.org,
        scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
        Andrew Morton <akpm@linux-foundation.org>,
        Jonathan Corbet <corbet@lwn.net>, eric.dumazet@gmail.com,
        markus@chromium.org, coreyb@linux.vnet.ibm.com,
        Kees Cook <keescook@chromium.org>,
        A
To: Will Drewry <wad@chromium.org>
Return-path: <kernel-hardening-return-1268-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1334267284-19166-1-git-send-email-wad@chromium.org>
List-Id: netdev.vger.kernel.org

On Thu, 12 Apr 2012, Will Drewry wrote:
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index d85b793..0b06685 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -2016,6 +2016,13 @@ static int selinux_bprm_set_creds(struct linux_binprm *bprm)
>  		new_tsec->sid = old_tsec->exec_sid;
>  		/* Reset exec SID on execve. */
>  		new_tsec->exec_sid = 0;
> +
> +		/*
> +		 * Minimize confusion: if no_new_privs and a transition is
> +		 * explicitly requested, then fail the exec.
> +		 */
> +		if (bprm->unsafe & LSM_UNSAFE_NO_NEW_PRIVS)
> +			return -EPERM;
>  	} else {
>  		/* Check for a default transition on this program. */
>  		rc = security_transition_sid(old_tsec->sid, isec->sid,
> @@ -2029,7 +2036,8 @@ static int selinux_bprm_set_creds(struct linux_binprm *bprm)
>  	ad.selinux_audit_data = &sad;
>  	ad.u.path = bprm->file->f_path;
>  
> -	if (bprm->file->f_path.mnt->mnt_flags & MNT_NOSUID)
> +	if ((bprm->file->f_path.mnt->mnt_flags & MNT_NOSUID) ||
> +	    (bprm->unsafe & LSM_UNSAFE_NO_NEW_PRIVS))
>  		new_tsec->sid = old_tsec->sid;
>  
>  	if (new_tsec->sid == old_tsec->sid) {
> -- 

What about dynamic transitions in SELinux ?


- James
-- 
James Morris
<jmorris@namei.org>
