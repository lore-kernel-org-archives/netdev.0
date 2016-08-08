From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: make net namespace sysctls belong to container's owner
Date: Mon, 08 Aug 2016 16:08:48 -0500
Message-ID: <8737mfotnj.fsf@x220.int.ebiederm.org>
References: <20160802231926.GA8108@dtor-ws>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160802231926.GA8108@dtor-ws> (Dmitry Torokhov's message of
	"Tue, 2 Aug 2016 16:19:26 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry Torokhov <dmitry.torokhov@gmail.com> writes:

> If net namespace is attached to a user namespace let's make container's
> root owner of sysctls affecting said network namespace instead of global
> root.
>
> This also allows us to clean up net_ctl_permissions() because we do not
> need to fudge permissions anymore for the container's owner since it now
> owns the objects in question.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Overall this seems reasonable.  However I am not a fan of your error
handling.

> Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
> ---
>
> This helps when running Android CTS in a container, but I think it makes
> sense regardless.

> +static void net_ctl_set_ownership(struct ctl_table_header *head,
> +				  struct ctl_table *table,
> +				  kuid_t *uid, kgid_t *gid)
> +{
> +	struct net *net = container_of(head->set, struct net, sysctls);
> +
> +	*uid = make_kuid(net->user_ns, 0);
> +	if (!uid_valid(*uid))
> +		*uid = GLOBAL_ROOT_UID;
> +
> +	*gid = make_kgid(net->user_ns, 0);
> +	if (!gid_valid(*gid))
> +		*gid = GLOBAL_ROOT_GID;

This code should eiter be:
	*uid = make_kuid(net->user_ns, 0);
        *gid = make_kgid(net->user_ns, 0);

Or it should be:
	tmp_uid = make_kuid(net->user_ns, 0);
        if (uid_valid(tmp_uid))
        	*uid = tmp_uid;

	tmp_gid = make_kgid(net->user_ns, 0);
        if (gid_valid(tmp_gid))
        	*gid = tmp_gid;

It is just very fragile to assume to know what uid and gid
would be if this code fails.

As of v4.8-rc1 INVALID_UID and INVALID_GID can be set in inode->i_uid
and inode->i_gid without causing horrible vfs confusion (making the
first option viable), but I expect with the mention of Android you want
to backport this so I will ask that you ask to implement the error
handling that doesn't assume you know better than the generic code.

If you don't have a better value to set something to it really should be
left alone.

Eric
