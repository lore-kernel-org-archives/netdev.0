From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 13/15] userns: Add basic quota support
Date: Mon, 27 Aug 2012 08:54:21 -0700
Message-ID: <87haro8h5e.fsf@xmission.com>
References: <87lih2h6i4.fsf@xmission.com> <87harqecvk.fsf@xmission.com>
	<20120827085034.GA8998@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>,
	Steven Whitehouse <swhiteho@redhat.com>,
	cluster-devel@redhat.com, Mark Fasheh <mfasheh@suse.com>,
	Joel Becker <jlbec@evilplan.org>, ocfs2-devel@oss.oracle.com,
	Ben Myers <bpm@sgi.com>, Alex Elder <elder@kernel.org>,
	xfs@oss.sgi.com, Dmitry Monakhov <dmonakhov@openvz.org>
To: Jan Kara <jack@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120827085034.GA8998@quack.suse.cz> (Jan Kara's message of
	"Mon, 27 Aug 2012 10:50:34 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Kara <jack@suse.cz> writes:

>   Hello,
>
> On Sat 25-08-12 17:05:35, Eric W. Biederman wrote:
>> Two helper are added dqgetusr and dqgetgrp to allow the quota
>> infrastructure to be called with a kuid and a kgid respectively.  This
>> creates type safe variants of dqget and leads to shorter more
>> comprehensible code.
>   It would look more comprehensible to me to have functions like:
> kuid2qown() and kgid2qown() and then call dqget(sb, kuid2qown(attr->uid))
> (see below for qown_t change proposal). The code then at the first look
> explains what is going on... Hmm?
>
>> Place the USRQUOTA and GRPQUOTA defines into enum quota_type.  This
>> brings with it the ability for the compiler to check that switch
>> statements handle every quota type, and the ability to mark which
>> values store the type of a quota entry.
>   OK, makes sense.
>
>> Add the data type qown_t a union of kuid_t and kgid_t. qown_t is a
>> replacement for the implicit union of uid and gid stored in an
>> unsigned int that is was used in the quota data structures.  Making
>> the data type explicit allows the kuid_t and kgid_t type safety to
>> propogate more thoroughly through the code, revealing more places
>> where uid/gid conversions need be made.
>   Hum, when we already do this, wouldn't it make more sense to embed quota
> type in qown_t? Because with the union thing you have no meaningful way of
> accessing that type without having quota type anyway. So having that in a
> single structure makes a lot of sense, plus it makes prototypes shorter...
> And you have to call make_qown() anyway...

So I think there was a reason for having the type separate but I'm not
seeing that reason off the top of my head.

I think it was filesystems like gfs2 doing weird things.  But I tell
you want I will play with this and if I can't reproduce find a reason
for putting them in one structure I will because there are definitely
good reasons for doing that.


>> Allong with the data type qown_t comes the helper functions
>> qown_eq, from_qown, from_qown_munged, qown_valid, and make_qown.
>> 
>> Update struct dquot dq_id to be a qown_t.
>> 
>> Update the signature of dqget, quota_send_warning, dquot_get_dqblk,
>> and dquot_set_dqblk to use enum quota_type and qown_t.
>> 
>> Make minimal changes to gfs2, ocfs2, and xfs to deal with the change
>> in quota structures and signatures.  The ocfs2 changes are larger than
>> most because of the extensive tracing throughout the ocfs2 quota code
>> that prints out dq_id.
>   Otherwise the changes look OK to me, although I didn't check them in
> detail yet (as above suggestions will change the code anyway).
>
> 								Honza

Thanks, 

Eric
