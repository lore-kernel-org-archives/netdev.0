From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v3 2/7] socket: initial cgroup code.
Date: Wed, 21 Sep 2011 11:47:29 -0700
Message-ID: <CAHH2K0YgkG2J_bO+U9zbZYhTTqSLvr6NtxKxN8dRtfHs=iB8iA@mail.gmail.com>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com> <1316393805-3005-3-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org,
	lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com,
	ebiederm@xmission.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-mm@kvack.org, kirill@shutemov.name
To: Glauber Costa <glommer@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:54175 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077Ab1IUSu6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 14:50:58 -0400
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p8LIowrT020265
	for <netdev@vger.kernel.org>; Wed, 21 Sep 2011 11:50:58 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by wpaz9.hot.corp.google.com with ESMTP id p8LIhnWt009781
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 21 Sep 2011 11:50:58 -0700
Received: by qyk7 with SMTP id 7so2030208qyk.19
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2011 11:50:58 -0700 (PDT)
In-Reply-To: <1316393805-3005-3-git-send-email-glommer@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 18, 2011 at 5:56 PM, Glauber Costa <glommer@parallels.com> =
wrote:
> We aim to control the amount of kernel memory pinned at any
> time by tcp sockets. To lay the foundations for this work,
> this patch adds a pointer to the kmem_cgroup to the socket
> structure.
>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>
=2E..
> +void sock_update_memcg(struct sock *sk)
> +{
> + =A0 =A0 =A0 /* right now a socket spends its whole life in the same=
 cgroup */
> + =A0 =A0 =A0 BUG_ON(sk->sk_cgrp);
> +
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 sk->sk_cgrp =3D mem_cgroup_from_task(current);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* We don't need to protect against anything task-rel=
ated, because
> + =A0 =A0 =A0 =A0* we are basically stuck with the sock pointer that =
won't change,
> + =A0 =A0 =A0 =A0* even if the task that originated the socket change=
s cgroups.
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* What we do have to guarantee, is that the chain le=
ading us to
> + =A0 =A0 =A0 =A0* the top level won't change under our noses. Increm=
enting the
> + =A0 =A0 =A0 =A0* reference count via cgroup_exclude_rmdir guarantee=
s that.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 cgroup_exclude_rmdir(mem_cgroup_css(sk->sk_cgrp));

This grabs a css_get() reference, which prevents rmdir (will return
-EBUSY).  How long is this reference held?  I wonder about the case
where a process creates a socket in memcg M1 and later is moved into
memcg M2.  At that point an admin would expect to be able to 'rmdir
M1'.  I think this rmdir would return -EBUSY and I suspect it would be
difficult for the admin to understand why the rmdir of M1 failed.  It
seems that to rmdir a memcg, an admin would have to kill all processes
that allocated sockets while in M1.  Such processes may not still be
in M1.

> + =A0 =A0 =A0 rcu_read_unlock();
> +}
