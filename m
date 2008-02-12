From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] [RFC] Smack: unlabeled outgoing ambient packets - v2
Date: Tue, 12 Feb 2008 14:42:24 -0500
Message-ID: <200802121442.24768.paul.moore@hp.com>
References: <47B0E1A1.7090902@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: casey@schaufler-ca.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763766AbYBLTnP@vger.kernel.org>
In-Reply-To: <47B0E1A1.7090902@schaufler-ca.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 11 February 2008 7:00:33 pm Casey Schaufler wrote:
> This patch differs significantly from the previous version.
> I think that I am using the netlbl interfaces more appropriately,
> Paul, please let me know if there's a better approach.

Nope, this approach is what I was talking about.  There are some minor 
issues discussed below but they should be easy/quick to fix.

> It's inconvenient that netlbl_sock_setattr frees the domain passed.
> I see that it makes sense for SELinux with the way SELinux treats
> secctx's, but Smack is more careful about memory usage and I have
> to do what I consider a gratuitous kalloc because of this behavior.
> Would you be open to a patch to change this if it included the
> SELinux changes?

I've looked at this before from a SELinux point of view to see if I 
could get rid of this extra memory allocation/copy and there just isn't 
a clean way to do it ("clean" being very subjective).  The problem is 
you either have to hold the policy lock while you make the NetLabel 
call (not a good idea), move the selinux_netlbl_sock_setsid() 
functionality back into security/selinux/ss/services.c (not desired by 
the SELinux folks who like to keep the selinux/ss/ directory minimal), 
or do the allocatin in security_netlbl_sid_to_secattr() and free it in 
selinux_netlbl_sock_setsid().  Of those options, only the last is 
really possible and it's so prone to memory leakage that I'm hesitant 
to say it's better than what we currently have.  Right now you do a 
call to netlbl_secattr_init() to start, do what you want with the 
secattr, and then you call netlbl_secattr_destroy() which will clean up 
_everything_ so nothing is leaked.  It works out really well because 
all of the _secattr_init() calls are matched by _secattr_destroy() 
calls within the same function; very easy to quickly scan and ensure 
there are no problems (the memory leak for a few weeks ago was quickly 
caught by looking at the code).  I'm in no hurry to loose this handy 
little property of the secattr, although I do agree that it isn't 
optimal for SMACK at present.  On the plus side this only happens once 
per-socket and not per-packet so I don't expect the malloc/copy to be 
fatal at this point.

You've got my mind revisiting this idea so give me a while and let me 
see if I can think of something that should be palatable to everyone 
involved.  In the meantime, I think you should fixup the few little 
nits in this patch and get it merged as it is a nice improvement and 
something that I believe most SMACK users will want.

>  security/smack/smack_lsm.c |   20 ++++++------
>  security/smack/smackfs.c   |   54
> +++++++++++++++++++++++++---------- 2 files changed, 49
> insertions(+), 25 deletions(-)
>
> diff -uprN -X linux-2.6.25-g0210-base//Documentation/dontdiff
> linux-2.6.25-g0210-base/security/smack/smackfs.c
> linux-2.6.25-g0210/security/smack/smackfs.c ---
> linux-2.6.25-g0210-base/security/smack/smackfs.c	2008-02-10
> 19:30:47.000000000 -0800 +++
> linux-2.6.25-g0210/security/smack/smackfs.c	2008-02-11
> 07:14:54.000000000 -0800 @@ -45,6 +45,7 @@ enum smk_inos {
>   */
>  static DEFINE_MUTEX(smack_list_lock);
>  static DEFINE_MUTEX(smack_cipso_lock);
> +static DEFINE_MUTEX(smack_ambient_lock);
>
>  /*
>   * This is the "ambient" label for network traffic.
> @@ -363,6 +364,27 @@ void smk_cipso_doi(void)
>  		       __func__, __LINE__, rc);
>  }
>
> +/**
> + * smk_unlbl_ambient - initialize the unlabeled domain
> + */
> +void smk_unlbl_ambient(char *oldambient)
> +{
> +	int rc;
> +	struct netlbl_audit audit_info;

You should try and populate the 'audit_info' struct with actual info so 
the generated audit record is more useful for people who care about 
those things.  It's only two fields, 'secid' and 'loginuid', which are 
pretty self-explanatory.

> +	if (oldambient != NULL) {
> +		rc = netlbl_cfg_map_del(oldambient, &audit_info);
> +		if (rc != 0)
> +			printk(KERN_WARNING "%s:%d remove rc = %d\n",
> +			       __func__, __LINE__, rc);
> +	}
> +
> +	rc = netlbl_cfg_unlbl_add_map(smack_net_ambient, &audit_info);
> +	if (rc != 0)
> +		printk(KERN_WARNING "%s:%d add rc = %d\n",
> +		       __func__, __LINE__, rc);
> +}
> +
>  /*
>   * Seq_file read operations for /smack/cipso
>   */
> @@ -709,7 +731,6 @@ static ssize_t smk_read_ambient(struct f
>  				size_t cn, loff_t *ppos)
>  {
>  	ssize_t rc;
> -	char out[SMK_LABELLEN];
>  	int asize;
>
>  	if (*ppos != 0)
> @@ -717,23 +738,18 @@ static ssize_t smk_read_ambient(struct f
>  	/*
>  	 * Being careful to avoid a problem in the case where
>  	 * smack_net_ambient gets changed in midstream.
> -	 * Since smack_net_ambient is always set with a value
> -	 * from the label list, including initially, and those
> -	 * never get freed, the worst case is that the pointer
> -	 * gets changed just after this strncpy, in which case
> -	 * the value passed up is incorrect. Locking around
> -	 * smack_net_ambient wouldn't be any better than this
> -	 * copy scheme as by the time the caller got to look
> -	 * at the ambient value it would have cleared the lock
> -	 * and been changed.
>  	 */
> -	strncpy(out, smack_net_ambient, SMK_LABELLEN);
> -	asize = strlen(out) + 1;
> +	mutex_lock(&smack_ambient_lock);
>
> -	if (cn < asize)
> -		return -EINVAL;
> +	asize = strlen(smack_net_ambient) + 1;
>
> -	rc = simple_read_from_buffer(buf, cn, ppos, out, asize);
> +	if (cn >= asize)
> +		rc = simple_read_from_buffer(buf, cn, ppos,
> +					     smack_net_ambient, asize);
> +	else
> +		rc = -EINVAL;
> +
> +	mutex_unlock(&smack_ambient_lock);
>
>  	return rc;
>  }
> @@ -751,6 +767,7 @@ static ssize_t smk_write_ambient(struct
>  				 size_t count, loff_t *ppos)
>  {
>  	char in[SMK_LABELLEN];
> +	char *oldambient;
>  	char *smack;
>
>  	if (!capable(CAP_MAC_ADMIN))
> @@ -766,7 +783,13 @@ static ssize_t smk_write_ambient(struct
>  	if (smack == NULL)
>  		return -EINVAL;
>
> +	mutex_lock(&smack_ambient_lock);
> +
> +	oldambient = smack_net_ambient;
>  	smack_net_ambient = smack;
> +	smk_unlbl_ambient(oldambient);
> +
> +	mutex_unlock(&smack_ambient_lock);

There is still the potential for a race here between when you change 
the 'smack_net_ambient' value and when you actually change the NetLabel 
configuration as you still allow new sockets to be created/labeled 
regardless of the 'smack_ambient_lock'.  That said, considering that 
this is a privileged operation and one that I don't expect to be very 
frequent it's probably not a big deal, I just wanted to make sure you 
were aware of that.

>  	return count;
>  }
> @@ -974,6 +997,7 @@ static int __init init_smk_fs(void)
>
>  	sema_init(&smack_write_sem, 1);
>  	smk_cipso_doi();
> +	smk_unlbl_ambient(NULL);
>
>  	return err;
>  }
> diff -uprN -X linux-2.6.25-g0210-base//Documentation/dontdiff
> linux-2.6.25-g0210-base/security/smack/smack_lsm.c
> linux-2.6.25-g0210/security/smack/smack_lsm.c ---
> linux-2.6.25-g0210-base/security/smack/smack_lsm.c	2008-02-10
> 19:30:47.000000000 -0800 +++
> linux-2.6.25-g0210/security/smack/smack_lsm.c	2008-02-10
> 20:10:47.000000000 -0800 @@ -1251,7 +1251,7 @@ static void
> smack_to_secattr(char *smack
>
>  	switch (smack_net_nltype) {
>  	case NETLBL_NLTYPE_CIPSOV4:
> -		nlsp->domain = NULL;
> +		nlsp->domain = kstrdup(smack, GFP_ATOMIC);
>  		nlsp->flags = NETLBL_SECATTR_DOMAIN;
>  		nlsp->flags |= NETLBL_SECATTR_MLS_LVL;

Should have noticed this sooner, how about replacing the above two lines 
with the following?

 nlsp->flags = NETLBL_SECATTR_DOMAIN | NETLBL_SECATTR_MLS_LVL;

> @@ -1276,21 +1276,21 @@ static void smack_to_secattr(char *smack
>   * Convert the outbound smack value (smk_out) to a
>   * secattr and attach it to the socket.
>   *
> - * Returns 0 on success or an error code
> + * The return from netlbl_sock_setattr is ignored because
> + * the defaulting label behavior provided by netlbl takes
> + * care of the error cases.

Not quite ... NetLabel will take care of making sure things are labeled 
correctly (default vs. ambient) but it can still fail for a variety of 
reasons: memory pressure, labeling protocol cannot represent the 
security attributes you passed, etc.  Moral of the story, you still 
need to check the return value of netlbl_sock_setattr() and deal with 
failures in a sane manner.

>   */
> -static int smack_netlabel(struct sock *sk)
> +static void smack_netlabel(struct sock *sk)
>  {
>  	struct socket_smack *ssp = sk->sk_security;
>  	struct netlbl_lsm_secattr secattr;
> -	int rc = 0;
> +	int rc;
>
>  	netlbl_secattr_init(&secattr);
>  	smack_to_secattr(ssp->smk_out, &secattr);
>  	if (secattr.flags != NETLBL_SECATTR_NONE)

You can keep the above if-statement if you like, but NetLabel handles 
this case gracefully (if it doesn't let me know, it's a bug) so it 
isn't necessary.

>  		rc = netlbl_sock_setattr(sk, &secattr);
> -
>  	netlbl_secattr_destroy(&secattr);
> -	return rc;
>  }
>
>  /**
> @@ -1340,7 +1340,7 @@ static int smack_inode_setsecurity(struc
>  		ssp->smk_in = sp;
>  	else if (strcmp(name, XATTR_SMACK_IPOUT) == 0) {
>  		ssp->smk_out = sp;
> -		return smack_netlabel(sock->sk);
> +		smack_netlabel(sock->sk);

See above comments regarding return values.

>  	} else
>  		return -EOPNOTSUPP;
>
> @@ -1367,7 +1367,8 @@ static int smack_socket_post_create(stru
>  	/*
>  	 * Set the outbound netlbl.
>  	 */
> -	return smack_netlabel(sock->sk);
> +	smack_netlabel(sock->sk);
> +	return 0;

Same thing.

>  }
>
>  /**
> @@ -2199,7 +2200,6 @@ static int smack_socket_getpeersec_dgram
>  static void smack_sock_graft(struct sock *sk, struct socket *parent)
>  {
>  	struct socket_smack *ssp;
> -	int rc;
>
>  	if (sk == NULL)
>  		return;
> @@ -2212,7 +2212,7 @@ static void smack_sock_graft(struct sock
>  	ssp->smk_out = current->security;
>  	ssp->smk_packet[0] = '\0';
>
> -	rc = smack_netlabel(sk);
> +	smack_netlabel(sk);

Once more, but with feeling.

>  }
>
>  /**

-- 
paul moore
linux security @ hp
