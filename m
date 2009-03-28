From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 6/6] smack: Add a new '-CIPSO' option to the network address
 label configuration
Date: Fri, 27 Mar 2009 20:05:38 -0700
Message-ID: <49CD9402.1060903@schaufler-ca.com>
References: <20090327205520.17777.32557.stgit@flek.lan> <20090327211101.17777.7763.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, etienne.basset@numericable.fr,
	Casey Schaufler <casey@schaufler-ca.com>
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090327211101.17777.7763.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Moore wrote:
> From: Etienne Basset <etienne.basset@numericable.fr>
>
> This patch adds a new special option '-CIPSO' to the Smack subsystem. When used
> in the netlabel list, it means "use CIPSO networking". A use case is when your
> local network speaks CIPSO and you want also to connect to the unlabeled
> Internet. This patch also add some documentation describing that. The patch
> also corrects an oops when setting a '' SMACK64 xattr to a file.
>
> Signed-off-by: Etienne Basset <etienne.basset@numericable.fr>
> Signed-off-by: Paul Moore <paul.moore@hp.com>
>   

Acked-by: Casey Schaufler <casey@schaufler-ca.com>


> ---
>
>  Documentation/Smack.txt       |   42 ++++++++++++++++++++++++++++++++++++-----
>  security/smack/smack.h        |    3 +++
>  security/smack/smack_access.c |    3 +++
>  security/smack/smack_lsm.c    |   11 +++++++++--
>  security/smack/smackfs.c      |   38 +++++++++++++++++++++++++++++--------
>  5 files changed, 82 insertions(+), 15 deletions(-)
>
> diff --git a/Documentation/Smack.txt b/Documentation/Smack.txt
> index 989c2fc..629c92e 100644
> --- a/Documentation/Smack.txt
> +++ b/Documentation/Smack.txt
> @@ -184,14 +184,16 @@ length. Single character labels using special characters, that being anything
>  other than a letter or digit, are reserved for use by the Smack development
>  team. Smack labels are unstructured, case sensitive, and the only operation
>  ever performed on them is comparison for equality. Smack labels cannot
> -contain unprintable characters or the "/" (slash) character.
> +contain unprintable characters or the "/" (slash) character. Smack labels
> +cannot begin with a '-', which is reserved for special options.
>  
>  There are some predefined labels:
>  
> -	_ Pronounced "floor", a single underscore character.
> -	^ Pronounced "hat", a single circumflex character.
> -	* Pronounced "star", a single asterisk character.
> -	? Pronounced "huh", a single question mark character.
> +	_ 	Pronounced "floor", a single underscore character.
> +	^ 	Pronounced "hat", a single circumflex character.
> +	* 	Pronounced "star", a single asterisk character.
> +	? 	Pronounced "huh", a single question mark character.
> +	@ 	Pronounced "Internet", a single at sign character.
>  
>  Every task on a Smack system is assigned a label. System tasks, such as
>  init(8) and systems daemons, are run with the floor ("_") label. User tasks
> @@ -412,6 +414,36 @@ sockets.
>  	A privileged program may set this to match the label of another
>  	task with which it hopes to communicate.
>  
> +Smack Netlabel Exceptions
> +
> +You will often find that your labeled application has to talk to the outside,
> +unlabeled world. To do this there's a special file /smack/netlabel where you can
> +add some exceptions in the form of :
> +@IP1	   LABEL1 or
> +@IP2/MASK  LABEL2
> +
> +It means that your application will have unlabeled access to @IP1 if it has
> +write access on LABEL1, and access to the subnet @IP2/MASK if it has write
> +access on LABEL2.
> +
> +Entries in the /smack/netlabel file are matched by longest mask first, like in
> +classless IPv4 routing.
> +
> +A special label '@' and an option '-CIPSO' can be used there :
> +@      means Internet, any application with any label has access to it
> +-CIPSO means standard CIPSO networking
> +
> +If you don't know what CIPSO is and don't plan to use it, you can just do :
> +echo 127.0.0.1 -CIPSO > /smack/netlabel
> +echo 0.0.0.0/0 @      > /smack/netlabel
> +
> +If you use CIPSO on your 192.168.0.0/16 local network and need also unlabeled
> +Internet access, you can have :
> +echo 127.0.0.1      -CIPSO > /smack/netlabel
> +echo 192.168.0.0/16 -CIPSO > /smack/netlabel
> +echo 0.0.0.0/0      @      > /smack/netlabel
> +
> +
>  Writing Applications for Smack
>  
>  There are three sorts of applications that will run on a Smack system. How an
> diff --git a/security/smack/smack.h b/security/smack/smack.h
> index 5e5a3bc..42ef313 100644
> --- a/security/smack/smack.h
> +++ b/security/smack/smack.h
> @@ -132,6 +132,8 @@ struct smack_known {
>  #define XATTR_NAME_SMACKIPIN	XATTR_SECURITY_PREFIX XATTR_SMACK_IPIN
>  #define XATTR_NAME_SMACKIPOUT	XATTR_SECURITY_PREFIX XATTR_SMACK_IPOUT
>  
> +#define SMACK_CIPSO_OPTION 	"-CIPSO"
> +
>  /*
>   * How communications on this socket are treated.
>   * Usually it's determined by the underlying netlabel code
> @@ -199,6 +201,7 @@ u32 smack_to_secid(const char *);
>  extern int smack_cipso_direct;
>  extern char *smack_net_ambient;
>  extern char *smack_onlycap;
> +extern const char *smack_cipso_option;
>  
>  extern struct smack_known smack_known_floor;
>  extern struct smack_known smack_known_hat;
> diff --git a/security/smack/smack_access.c b/security/smack/smack_access.c
> index 5856419..ac0a270 100644
> --- a/security/smack/smack_access.c
> +++ b/security/smack/smack_access.c
> @@ -261,6 +261,9 @@ char *smk_import(const char *string, int len)
>  {
>  	struct smack_known *skp;
>  
> +	/* labels cannot begin with a '-' */
> +	if (string[0] == '-')
> +		return NULL;
>  	skp = smk_import_entry(string, len);
>  	if (skp == NULL)
>  		return NULL;
> diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
> index 8ed502c..9215149 100644
> --- a/security/smack/smack_lsm.c
> +++ b/security/smack/smack_lsm.c
> @@ -609,6 +609,9 @@ static int smack_inode_setxattr(struct dentry *dentry, const char *name,
>  	    strcmp(name, XATTR_NAME_SMACKIPOUT) == 0) {
>  		if (!capable(CAP_MAC_ADMIN))
>  			rc = -EPERM;
> +		/* a label cannot be void and cannot begin with '-' */
> +		if (size == 0 || (size > 0 && ((char *)value)[0] == '-'))
> +			rc = -EINVAL;
>  	} else
>  		rc = cap_inode_setxattr(dentry, name, value, size, flags);
>  
> @@ -1323,8 +1326,12 @@ static char *smack_host_label(struct sockaddr_in *sip)
>  		* so we have found the most specific match
>  		*/
>  		if ((&snp->smk_host.sin_addr)->s_addr ==
> -		    (siap->s_addr & (&snp->smk_mask)->s_addr))
> +		    (siap->s_addr & (&snp->smk_mask)->s_addr)) {
> +			/* we have found the special CIPSO option */
> +			if (snp->smk_label == smack_cipso_option)
> +				return NULL;
>  			return snp->smk_label;
> +		}
>  
>  	return NULL;
>  }
> @@ -1486,7 +1493,7 @@ static int smack_inode_setsecurity(struct inode *inode, const char *name,
>  	struct socket *sock;
>  	int rc = 0;
>  
> -	if (value == NULL || size > SMK_LABELLEN)
> +	if (value == NULL || size > SMK_LABELLEN || size == 0)
>  		return -EACCES;
>  
>  	sp = smk_import(value, size);
> diff --git a/security/smack/smackfs.c b/security/smack/smackfs.c
> index 856c8a2..e03a7e1 100644
> --- a/security/smack/smackfs.c
> +++ b/security/smack/smackfs.c
> @@ -86,6 +86,9 @@ LIST_HEAD(smack_rule_list);
>  
>  static int smk_cipso_doi_value = SMACK_CIPSO_DOI_DEFAULT;
>  
> +const char *smack_cipso_option = SMACK_CIPSO_OPTION;
> +
> +
>  #define	SEQ_READ_FINISHED	1
>  
>  /*
> @@ -565,6 +568,11 @@ static ssize_t smk_write_cipso(struct file *file, const char __user *buf,
>  		goto unlockedout;
>  	}
>  
> +	/* labels cannot begin with a '-' */
> +	if (data[0] == '-') {
> +		rc = -EINVAL;
> +		goto unlockedout;
> +	}
>  	data[count] = '\0';
>  	rule = data;
>  	/*
> @@ -808,9 +816,18 @@ static ssize_t smk_write_netlbladdr(struct file *file, const char __user *buf,
>  	if (m > BEBITS)
>  		return -EINVAL;
>  
> -	sp = smk_import(smack, 0);
> -	if (sp == NULL)
> -		return -EINVAL;
> +	/* if smack begins with '-', its an option, don't import it */
> +	if (smack[0] != '-') {
> +		sp = smk_import(smack, 0);
> +		if (sp == NULL)
> +			return -EINVAL;
> +	} else {
> +		/* check known options */
> +		if (strcmp(smack, smack_cipso_option) == 0)
> +			sp = (char *)smack_cipso_option;
> +		else
> +			return -EINVAL;
> +	}
>  
>  	for (temp_mask = 0; m > 0; m--) {
>  		temp_mask |= mask_bits;
> @@ -849,18 +866,23 @@ static ssize_t smk_write_netlbladdr(struct file *file, const char __user *buf,
>  			smk_netlbladdr_insert(skp);
>  		}
>  	} else {
> -		rc = netlbl_cfg_unlbl_static_del(&init_net, NULL,
> -			&skp->smk_host.sin_addr, &skp->smk_mask,
> -			PF_INET, &audit_info);
> +		/* we delete the unlabeled entry, only if the previous label
> +		 * wasnt the special CIPSO option */
> +		if (skp->smk_label != smack_cipso_option)
> +			rc = netlbl_cfg_unlbl_static_del(&init_net, NULL,
> +					&skp->smk_host.sin_addr, &skp->smk_mask,
> +					PF_INET, &audit_info);
> +		else
> +			rc = 0;
>  		skp->smk_label = sp;
>  	}
>  
>  	/*
>  	 * Now tell netlabel about the single label nature of
>  	 * this host so that incoming packets get labeled.
> +	 * but only if we didn't get the special CIPSO option
>  	 */
> -
> -	if (rc == 0)
> +	if (rc == 0 && sp != smack_cipso_option)
>  		rc = netlbl_cfg_unlbl_static_add(&init_net, NULL,
>  			&skp->smk_host.sin_addr, &skp->smk_mask, PF_INET,
>  			smack_to_secid(skp->smk_label), &audit_info);
>
>
>   

