From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 24/29] sysctl: Replace root_list with links between sysctl_table_sets.
Date: Mon, 30 Jan 2012 19:10:04 -0800
Message-ID: <m1mx94efeb.fsf@fess.ebiederm.org>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
	<1327639925-12920-24-git-send-email-ebiederm@xmission.com>
	<CAPLs8y8YV0MiNhR0SnviBHPQb-oMj+_DLvRpJN89Yrbyjsf2xg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org,
	Damien Millescamps <damien.millescamps@6wind.com>
To: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <CAPLs8y8YV0MiNhR0SnviBHPQb-oMj+_DLvRpJN89Yrbyjsf2xg@mail.gmail.com>
	(Lucian Adrian Grijincu's message of "Mon, 30 Jan 2012 02:01:48
	+0200")
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lucian Adrian Grijincu <lucian.grijincu@gmail.com> writes:

> Very nice way to handle netns specific files with links between sets!
>
> You did a much better job than I did at dealing with them.
>
> It took me a while to understand how the code works. I'll try to writ=
e
> something for Documentation/ because the inner workings are a bit
> intertwined.
>
> A few comments bellow.

Thank you for your review.

I'm going to see how many of your comments I can incorporate into the
code.

Since no significant bugs have been seen my plan is to use incremental
patches on top of the existing code, to address the small issues that
have been seen.  That way I don't have to retest yet again.

>> =C2=A0void register_sysctl_root(struct ctl_table_root *root)
>> =C2=A0{
>> - =C2=A0 =C2=A0 =C2=A0 spin_lock(&sysctl_lock);
>> - =C2=A0 =C2=A0 =C2=A0 list_add_tail(&root->root_list, &sysctl_table=
_root.root_list);
>> - =C2=A0 =C2=A0 =C2=A0 spin_unlock(&sysctl_lock);
>> =C2=A0}
>
>
> This function is empty. Can be deleted (there are two callers in
> net/sysctl_net.c.

Agreed.  There might be something useful by registering roots.  Perhaps
initialize the default set.  So I have kept the function for the short
term.  register_sysctl_root makes sense as an interface.  We just don't
have anything for register_sysctl_root to do right now.

>> @@ -400,6 +373,7 @@ static struct dentry *proc_sys_lookup(struct ino=
de *dir, struct dentry *dentry,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct inode *inode;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct dentry *err =3D ERR_PTR(-ENOENT);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ctl_dir *ctl_dir;
>> + =C2=A0 =C2=A0 =C2=A0 int ret;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (IS_ERR(head))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ERR_CA=
ST(head);
>> @@ -410,6 +384,11 @@ static struct dentry *proc_sys_lookup(struct in=
ode *dir, struct dentry *dentry,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!p)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out;
>>
>
>
> "sysctl_follow_link" implies that it will follow the link. I would
> pull out the check whether the header is a link or not. This wouldn't
> save much (a function call), but it would make the code easier to
> read:
>
> 	/* Get out quickly if not a link */
>         if (S_ISLNK(p->mode)) {
> 		ret =3D sysctl_follow_link(&h, &p, current->nsproxy);
> 		err =3D ERR_PTR(ret);
> 		if (ret)
> 		        goto out;
>         }

Good point, and obviousness is part of what I am aiming for.


>> =C2=A0{
>> + =C2=A0 =C2=A0 =C2=A0 struct ctl_table_set *set =3D dir->header.set=
;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ctl_dir *subdir, *new =3D NULL;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&sysctl_lock);
>> - =C2=A0 =C2=A0 =C2=A0 subdir =3D find_subdir(dir->header.set, dir, =
name, namelen);
>> - =C2=A0 =C2=A0 =C2=A0 if (!IS_ERR(subdir))
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto found;
>> - =C2=A0 =C2=A0 =C2=A0 if ((PTR_ERR(subdir) =3D=3D -ENOENT) && set !=
=3D dir->header.set)
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 subdir =3D find_s=
ubdir(set, dir, name, namelen);
>> + =C2=A0 =C2=A0 =C2=A0 subdir =3D find_subdir(dir, name, namelen);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!IS_ERR(subdir))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto found;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PTR_ERR(subdir) !=3D -ENOENT)
>> @@ -817,13 +815,14 @@ static struct ctl_dir *get_subdir(struct ctl_t=
able_set *set,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!new)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto failed;
>>
>> - =C2=A0 =C2=A0 =C2=A0 subdir =3D find_subdir(set, dir, name, namele=
n);
>> + =C2=A0 =C2=A0 =C2=A0 subdir =3D find_subdir(dir, name, namelen);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!IS_ERR(subdir))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto found;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PTR_ERR(subdir) !=3D -ENOENT)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto failed;
>
> I think you're returning the wrong error here. If we got to this poin=
t
> then subdir =3D=3D ERR_PTR(-ENOENT).
> We want to create a new dir here even if one doesn't exist.
> So if we have an error in insert_header() we don't return that error,
> but ENOENT.
>
>>
>> - =C2=A0 =C2=A0 =C2=A0 insert_header(dir, &new->header);
>> + =C2=A0 =C2=A0 =C2=A0 if (insert_header(dir, &new->header))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto failed;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0subdir =3D new;
>
> Something like this would fix it:
>
>         if (subdir =3D insert_header(dir, &new->header))
>
>
>
>> =C2=A0found:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0subdir->header.nreg++;
>> @@ -841,6 +840,57 @@ failed:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return subdir;
>> =C2=A0}
>>
--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
