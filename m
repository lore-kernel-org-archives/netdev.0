From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] userns: Add basic quota support v4
Date: Wed, 29 Aug 2012 12:10:29 +1000
Message-ID: <20120829021029.GC13691@dastard>
References: <87lih2h6i4.fsf@xmission.com>
 <87harqecvk.fsf@xmission.com>
 <20120827085034.GA8998@quack.suse.cz>
 <87wr0j7u3j.fsf_-_@xmission.com>
 <20120828090544.GC5146@quack.suse.cz>
 <87a9xe7wfn.fsf@xmission.com>
 <20120828175101.GF5146@quack.suse.cz>
 <87y5ky6dff.fsf_-_@xmission.com>
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
In-Reply-To: <87y5ky6dff.fsf_-_@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 28, 2012 at 12:09:56PM -0700, Eric W. Biederman wrote:
> 
> Add the data type struct kqid which holds the kernel internal form of
> the owning identifier of a quota.  struct kqid is a replacement for
> the implicit union of uid, gid and project stored in an unsigned int
> and the quota type field that is was used in the quota data
> structures.  Making the data type explicit allows the kuid_t and
> kgid_t type safety to propogate more thoroughly through the code,
> revealing more places where uid/gid conversions need be made.
> 
> Along with the data type struct kqid comes the helper functions
> qid_eq, qid_lt, from_kqid, from_kqid_munged, qid_valid, make_kqid,

I think Jan's comment about from_kqid being named id_from_kgid is
better, though I also think it would read better as kqid_to_id().
ie:

	id = kqid_to_id(ns, qid);

> make_kqid_invalid, make_kqid_uid, make_kqid_gid.

and these named something like uid_to_kqid()

> Change struct dquot dq_id to a struct kqid and remove the now
> unecessary dq_type.
> 
> Update the signature of dqget, quota_send_warning, dquot_get_dqblk,
> and dquot_set_dqblk to use struct kqid.
> 
> Make minimal changes to ext3, ext4, gfs2, ocfs2, and xfs to deal with
> the change in quota structures and signatures.  The ocfs2 changes are
> larger than most because of the extensive tracing throughout the ocfs2
> quota code that prints out dq_id.

How did you test that this all works? e.g. run xfstests -g quota on
each of those filesystems and check for no regressions? And if you
wrote any tests, can you convert them to be part of xfstests so that
namespace aware quotas get tested regularly?

> 
> v4:
>   - Rename struct qown struct kqid and associated changes
>     to the naming of the helper functions.
>   - Use qid_t to hold the userspace identifier representation
>     of quota identifiers in all new code.
> v3:
>   - Add missing negation on qown_valid
> v2:
>   - Renamed qown_t struct qown
>   - Added the quota type to struct qown.
>   - Removed enum quota_type (In this patch it was just noise)
>   - Added qown_lt, make_qown_invalid, make_qown_uid, make_qown_gid
>   - Taught qown to handle xfs project ids (but only in init_user_ns).
>     Q_XGETQUOTA calls .get_quotblk with project ids.

Q_XSETQLIM was modified to handle project quotas as well, I assume?

> index fed504f..96944c0 100644
> --- a/fs/xfs/xfs_quotaops.c
> +++ b/fs/xfs/xfs_quotaops.c
> @@ -97,28 +97,29 @@ xfs_fs_set_xstate(
>  STATIC int
>  xfs_fs_get_dqblk(
>  	struct super_block	*sb,
> -	int			type,
> -	qid_t			id,
> +	struct kqid		qid,
>  	struct fs_disk_quota	*fdq)
>  {
>  	struct xfs_mount	*mp = XFS_M(sb);
> +	xfs_dqid_t		xfs_id;
>  
>  	if (!XFS_IS_QUOTA_RUNNING(mp))
>  		return -ENOSYS;
>  	if (!XFS_IS_QUOTA_ON(mp))
>  		return -ESRCH;
>  
> -	return -xfs_qm_scall_getquota(mp, id, xfs_quota_type(type), fdq);
> +	xfs_id = from_kqid(&init_user_ns, qid);
> +	return -xfs_qm_scall_getquota(mp, xfs_id, xfs_quota_type(qid.type), fdq);
>  }

Why a temporary variable? Why not just:

	return -xfs_qm_scall_getquota(mp, from_kqid(&init_user_ns, qid),
				      xfs_quota_type(qid.type), fdq);

Indeed, why not drive the struct kqid down another level into
xfs_qm_scall_getquota() where all they are used for is parameters to
the xfs_qm_dqget() function?

>  
>  STATIC int
>  xfs_fs_set_dqblk(
>  	struct super_block	*sb,
> -	int			type,
> -	qid_t			id,
> +	struct kqid		qid,
>  	struct fs_disk_quota	*fdq)
>  {
>  	struct xfs_mount	*mp = XFS_M(sb);
> +	xfs_dqid_t		xfs_id;
>  
>  	if (sb->s_flags & MS_RDONLY)
>  		return -EROFS;
> @@ -127,7 +128,8 @@ xfs_fs_set_dqblk(
>  	if (!XFS_IS_QUOTA_ON(mp))
>  		return -ESRCH;
>  
> -	return -xfs_qm_scall_setqlim(mp, id, xfs_quota_type(type), fdq);
> +	xfs_id = from_kqid(&init_user_ns, qid);
> +	return -xfs_qm_scall_setqlim(mp, xfs_id, xfs_quota_type(qid.type), fdq);
>  }

Same is true here....

>  
>  const struct quotactl_ops xfs_quotactl_operations = {
> diff --git a/fs/xfs/xfs_trans_dquot.c b/fs/xfs/xfs_trans_dquot.c
> index bcb6054..46de393 100644
> --- a/fs/xfs/xfs_trans_dquot.c
> +++ b/fs/xfs/xfs_trans_dquot.c
> @@ -575,12 +575,14 @@ xfs_quota_warn(
>  	struct xfs_dquot	*dqp,
>  	int			type)
>  {
> +	int qtype;
> +	struct kqid qid;
>  	/* no warnings for project quotas - we just return ENOSPC later */
>  	if (dqp->dq_flags & XFS_DQ_PROJ)
>  		return;
> -	quota_send_warning((dqp->dq_flags & XFS_DQ_USER) ? USRQUOTA : GRPQUOTA,
> -			   be32_to_cpu(dqp->q_core.d_id), mp->m_super->s_dev,
> -			   type);
> +	qtype = (dqp->dq_flags & XFS_DQ_USER) ? USRQUOTA : GRPQUOTA;
> +	qid = make_kqid(&init_user_ns, qtype, be32_to_cpu(dqp->q_core.d_id));
> +	quota_send_warning(qid, mp->m_super->s_dev, type);
>  }
>  
>  /*
> diff --git a/include/linux/quota.h b/include/linux/quota.h
> index 524ede8..0e73250 100644
> --- a/include/linux/quota.h
> +++ b/include/linux/quota.h
> @@ -181,10 +181,161 @@ enum {
>  #include <linux/dqblk_v2.h>
>  
>  #include <linux/atomic.h>
> +#include <linux/uidgid.h>
>  
>  typedef __kernel_uid32_t qid_t; /* Type in which we store ids in memory */
>  typedef long long qsize_t;	/* Type in which we store sizes */

>From fs/xfs/xfs_types.h:

typedef __uint32_t              prid_t;         /* project ID */

Perhaps it would be better to have an official kprid_t definition
here, i.e:

>  
> +struct kqid {			/* Type in which we store the quota identifier */
> +	union {
> +		kuid_t uid;
> +		kgid_t gid;
> +		qid_t prj;

		kprid_t prid;

> +	};
> +	int type; /* USRQUOTA (uid) or GRPQUOTA (gid) or XQM_PRJQUOTA (prj) */
> +};
> +
> +static inline bool qid_eq(struct kqid left, struct kqid right)
> +{
> +	if (left.type != right.type)
> +		return false;
> +	switch(left.type) {
> +	case USRQUOTA:
> +		return uid_eq(left.uid, right.uid);
> +	case GRPQUOTA:
> +		return gid_eq(left.gid, right.gid);
> +	case XQM_PRJQUOTA:
> +		return left.prj == right.prj;
> +	default:
> +		BUG();

BUG()? Seriously? The most this justifies is a WARN_ON_ONCE() to
indicate a potential programming error, not bringing down the entire
machine.

> +	}
> +}
> +
> +static inline bool qid_lt(struct kqid left, struct kqid right)
> +{
> +	if (left.type < right.type)
> +		return true;
> +	if (left.type > right.type)
> +		return false;
> +	switch (left.type) {
> +	case USRQUOTA:
> +		return uid_lt(left.uid, right.uid);
> +	case GRPQUOTA:
> +		return gid_lt(left.gid, right.gid);
> +	case XQM_PRJQUOTA:
> +		return left.prj < right.prj;
> +	default:
> +		BUG();
> +	}
> +}

What is this function used for? it's not referenced at all by the
patch, and there's no documentation/comments explaining why it
exists or how it is intended to be used....

> +static inline qid_t from_kqid(struct user_namespace *user_ns, struct kqid qid)
> +{
> +	switch (qid.type) {
> +	case USRQUOTA:
> +		return from_kuid(user_ns, qid.uid);
> +	case GRPQUOTA:
> +		return from_kgid(user_ns, qid.gid);
> +	case XQM_PRJQUOTA:
> +		return (user_ns == &init_user_ns) ? qid.prj : -1;
> +	default:
> +		BUG();
> +	}
> +}

Oh, this can return an error. That's only checked in a coupl eof
places this function is called. it needs tobe checked everywhere,
otherwise we now have the possibility of quota usage being accounted
to uid/gid/prid 0xffffffff when namespace matches are not found.

> +static inline qid_t from_kqid_munged(struct user_namespace *user_ns,
> +				   struct kqid qid)

What does munging do to the return value? how is it different to
from_kqid()? Document your API....


> +static inline struct kqid make_kqid(struct user_namespace *user_ns,
> +				    int type, qid_t qid)
> +{
> +	struct kqid kqid;
> +
> +	kqid.type = type;
> +	switch (type) {
> +	case USRQUOTA:
> +		kqid.uid = make_kuid(user_ns, qid);
> +		break;
> +	case GRPQUOTA:
> +		kqid.gid = make_kgid(user_ns, qid);
> +		break;
> +	case XQM_PRJQUOTA:
> +		if (user_ns == &init_user_ns)
> +			kqid.prj = qid;
> +		else
> +			kqid.prj = -1;
> +		break;

		kqid.prj = (user_ns == &init_user_ns) ? qid : -1;

> +	default:
> +		BUG();
> +	}
> +	return kqid;
> +}
> +
> +static inline struct kqid make_kqid_invalid(int type)
> +{
> +	struct kqid kqid;
> +
> +	kqid.type = type;
> +	switch (type) {
> +	case USRQUOTA:
> +		kqid.uid = INVALID_UID;
> +		break;
> +	case GRPQUOTA:
> +		kqid.gid = INVALID_GID;
> +		break;
> +	case XQM_PRJQUOTA:
> +		kqid.prj = -1;
> +		break;
> +	default:
> +		BUG();
> +	}
> +	return kqid;
> +}
> +
> +static inline struct kqid make_kqid_uid(kuid_t uid)
> +{
> +	struct kqid kqid = {
> +		.type = USRQUOTA,
> +		.uid  = uid,
> +	};
> +	return kqid;
> +}

Isn't this sort of construct frowned upon? i.e. returning a
structure out of scope? It may be inline code and hence work, but
this strikes me as a landmine waiting for someone to tread on....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
