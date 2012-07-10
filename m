From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH v2] fail dentry revalidation after namespace change
Date: Mon, 09 Jul 2012 17:30:48 -0700
Message-ID: <87txxgxxs7.fsf@xmission.com>
References: <1341565747-15374-1-git-send-email-glommer@parallels.com>
	<20120709161336.0ec23592.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Glauber Costa <glommer@parallels.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Greg Thelen <gthelen@google.com>,
	Serge Hallyn <serge.hallyn@canonical.com>,
	Tejun Heo <tj@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120709161336.0ec23592.akpm@linux-foundation.org> (Andrew
	Morton's message of "Mon, 9 Jul 2012 16:13:36 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:

>>  {
>>  	struct sysfs_dirent *sd;
>>  	int is_dir;
>> +	int type;
>>  
>>  	if (nd->flags & LOOKUP_RCU)
>>  		return -ECHILD;
>> @@ -326,6 +327,13 @@ static int sysfs_dentry_revalidate(struct dentry *dentry, struct nameidata *nd)
>>  	if (strcmp(dentry->d_name.name, sd->s_name) != 0)
>>  		goto out_bad;
>>  
>> +	/* The sysfs dirent has been moved to a different namespace */
>> +	type = KOBJ_NS_TYPE_NONE;
>> +	if (sd->s_parent)
>> +		type = sysfs_ns_type(sd->s_parent);
>> +	if (type && (sysfs_info(dentry->d_sb)->ns[type] != sd->s_ns))
>
> eww, the code is assuming that KOBJ_NS_TYPE_NONE has a value of zero. 
> Don't do that; it smells bad.

Gag.  An incomplete change in idiom.

KOBJ_NS_TYPE_NONE is explicitly defined as 0 so that it can be used
this way, and every where else in fs/sysfs/dir.c uses this idiom.

Furthermore your change below takes one line of readable code and turns
it into something inappropriate to talk about in polite company.

If you want the code to be perfect type should be defined as
"enum kobj_ns_type type" instead of "int kobj_ns_type".

Of course the truly perfect solution is to rework the sysfs
code in a manner similar to proc, with magic internal symlinks
and multiple parallel tress for the different namespaces.
For the users of sysfs semantically there would be no changes
but in the implementation there would many fewer special cases
for namespaces.   The only special case would be reduced to
the internal sysfs symlink that lookup would have to know
about.

> @@ -329,10 +329,12 @@ static int sysfs_dentry_revalidate(struc
>  
>  	/* The sysfs dirent has been moved to a different namespace */
>  	type = KOBJ_NS_TYPE_NONE;
> -	if (sd->s_parent)
> +	if (sd->s_parent) {
>  		type = sysfs_ns_type(sd->s_parent);
> -	if (type && (sysfs_info(dentry->d_sb)->ns[type] != sd->s_ns))
> -		goto out_bad;
> +		if (type != KOBJ_NS_TYPE_NONE &&
> +				sysfs_info(dentry->d_sb)->ns[type] != sd->s_ns)
> +			goto out_bad;
> +	}

Pray tell in what parallel universe is that monstrosity above more
readable than the line it replaces?

Eric
