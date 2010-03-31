From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/6] sysfs: Basic support for multiple super blocks
Date: Tue, 30 Mar 2010 22:51:35 -0700
Message-ID: <m1634d82e0.fsf@fess.ebiederm.org>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
	<1269973889-25260-1-git-send-email-ebiederm@xmission.com>
	<4BB2E098.7030202@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	linux-kernel@vger.kernel.org,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:36935 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754272Ab0CaFvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 01:51:42 -0400
In-Reply-To: <4BB2E098.7030202@kernel.org> (Tejun Heo's message of "Wed\, 31 Mar 2010 14\:41\:44 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tejun Heo <tj@kernel.org> writes:

> Hello, Eric.
>
> On 03/31/2010 03:31 AM, Eric W. Biederman wrote:
>> From: Eric W. Biederman <ebiederm@xmission.com>
>> 
>> Add all of the necessary bioler plate to support
>                            boiler :-)
>
>> +static int sysfs_test_super(struct super_block *sb, void *data)
>> +{
>> +	struct sysfs_super_info *sb_info = sysfs_info(sb);
>> +	struct sysfs_super_info *info = data;
>> +	int found = 1;
>> +	return found;
>> +}
>
> Can you please make it return bool?

Nope.  That would mean I could not use it with sget.

>>  static int sysfs_get_sb(struct file_system_type *fs_type,
>>  	int flags, const char *dev_name, void *data, struct vfsmount *mnt)
>>  {
>> -	return get_sb_single(fs_type, flags, data, sysfs_fill_super, mnt);
>> +	struct sysfs_super_info *info;
>> +	struct super_block *sb;
>> +	int error;
>> +
>> +	error = -ENOMEM;
>> +	info = kzalloc(sizeof(*info), GFP_KERNEL);
>> +	if (!info)
>> +		goto out;
>> +	sb = sget(fs_type, sysfs_test_super, sysfs_set_super, info);
>> +	if (IS_ERR(sb) || sb->s_fs_info != info)
>> +		kfree(info);
>> +	if (IS_ERR(sb)) {
>> +		kfree(info);
>> +		error = PTR_ERR(sb);
>> +		goto out;
>> +	}
>> +	if (!sb->s_root) {
>> +		sb->s_flags = flags;
>> +		error = sysfs_fill_super(sb, data, flags & MS_SILENT ? 1 : 0);
>> +		if (error) {
>> +			deactivate_locked_super(sb);
>> +			goto out;
>> +		}
>> +		sb->s_flags |= MS_ACTIVE;
>> +	}
>> +
>> +	simple_set_mnt(mnt, sb);
>> +	error = 0;
>> +out:
>> +	return error;
>> +}
>
> I haven't looked at later patches but I suppose this is gonna be
> filled with more meaningful stuff later. 

Yes it will.

> One (possibly silly) thing
> that stands out compared to get_sb_single() is missing remount
> handling.  Is it intended?

There is nothing for a remount to do so I ignore it.   The only
thing that would possibly be meaningful is a read-only mount,
and nothing I know of sysfs suggests read-only mounts of sysfs
work, or make any sense.

>> index 30f5a44..030a39d 100644
>> --- a/fs/sysfs/sysfs.h
>> +++ b/fs/sysfs/sysfs.h
>> @@ -114,6 +114,9 @@ struct sysfs_addrm_cxt {
>>  /*
>>   * mount.c
>>   */
>> +struct sysfs_super_info {
>> +};
>> +#define sysfs_info(SB) ((struct sysfs_super_info *)(SB->s_fs_info))
>
> Another nit picking.  It would be better to wrap SB in the macro
> definition.  Also, wouldn't an inline function be better?

Good spotting.  That doesn't bite today but it will certainly bite
someday if it isn't fixed.

I wonder how that has slipped through the review all of this time.

Eric
