From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] userns: Add basic quota support v2
Date: Tue, 28 Aug 2012 11:05:44 +0200
Message-ID: <20120828090544.GC5146@quack.suse.cz>
References: <87lih2h6i4.fsf@xmission.com>
 <87harqecvk.fsf@xmission.com>
 <20120827085034.GA8998@quack.suse.cz>
 <87wr0j7u3j.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>,
	Steven Whitehouse <swhiteho@redhat.com>,
	Mark Fasheh <mfasheh@suse.com>,
	Joel Becker <jlbec@evilplan.org>, Ben Myers <bpm@sgi.com>,
	Alex Elder <elder@kernel.org>,
	Dmitry Monakhov <dmonakhov@openvz.org>,
	Abhijith Das <adas@redhat.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87wr0j7u3j.fsf_-_@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon 27-08-12 17:12:16, Eric W. Biederman wrote: 
> Add the data type struct qown which holds the owning identifier of a
> quota.  struct qown is a replacement for the implicit union of uid,
> gid and project stored in an unsigned int and the quota type field
> that is was used in the quota data structures.  Making the data type
> explicit allows the kuid_t and kgid_t type safety to propogate more
> thoroughly through the code, revealing more places where uid/gid
> conversions need be made.
> 
> Allong with the data type struct qown comes the helper functions
  ^^^^ Along

> qown_eq, qown_lt, from_qown, from_qown_munged, qown_valid, make_qown,
> make_qown_invalid, make_qown_uid, make_qown_gid.
> 
> Replace struct dquot dq_id and dq_type with dq_own a struct qown.
> 
> Update the signature of dqget, quota_send_warning, dquot_get_dqblk,
> and dquot_set_dqblk to use struct qown.
> 
> Make minimal changes to ext3, ext4, gfs2, ocfs2, and xfs to deal with
> the change in quota structures and signatures.  The ocfs2 changes are
> larger than most because of the extensive tracing throughout the ocfs2
> quota code that prints out dq_id.
> 
> v2:
>  - Renamed qown_t struct qown
>  - Added the quota type to struct qown.
>  - Removed enum quota_type (In this patch it was just noise)
>  - Added qown_lt, make_qown_invalid, make_qown_uid, make_qown_gid
>  - Taught qown to handle xfs project ids (but only in init_user_ns). 
>    Q_XGETQUOTA calls .get_quotblk with project ids.
  Just a couple one minor comments below...

> @@ -130,13 +130,17 @@ static void copy_to_if_dqblk(struct if_dqblk *dst, struct fs_disk_quota *src)
>  static int quota_getquota(struct super_block *sb, int type, qid_t id,
>  			  void __user *addr)
>  {
> +	struct qown qown;
>  	struct fs_disk_quota fdq;
>  	struct if_dqblk idq;
>  	int ret;
>  
>  	if (!sb->s_qcop->get_dqblk)
>  		return -ENOSYS;
> -	ret = sb->s_qcop->get_dqblk(sb, type, id, &fdq);
> +	qown = make_qown(current_user_ns(), type, id);
> +	if (qown_valid(qown))
            ^ missing '!'

> +		return -EINVAL;
> +	ret = sb->s_qcop->get_dqblk(sb, qown, &fdq);
>  	if (ret)
>  		return ret;
>  	copy_to_if_dqblk(&idq, &fdq);
...
> +static inline u32 from_qown(struct user_namespace *user_ns, struct qown qown)
> +{
> +	switch (qown.type) {
> +	case USRQUOTA:
> +		return from_kuid(user_ns, qown.uid);
> +	case GRPQUOTA:
> +		return from_kgid(user_ns, qown.gid);
> +	case XQM_PRJQUOTA:
> +		return (user_ns == &init_user_ns) ? qown.prj : -1;
> +	default:
> +		BUG();
> +	}
> +}
  I would like a bit more if the function somehow expressed in its name
that it returns id. id_from_qown() might be a bit too long given how often
it is used. qown2id() would be OK but it would be inconsistent with how
names of other functions you've added are formed. So I'm somewhat
undecided...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
