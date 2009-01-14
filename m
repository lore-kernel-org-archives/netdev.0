From: Paul Menage <menage@google.com>
Subject: Re: [Devel] Re: [RFC][PATCH] IP address restricting cgroup subsystem
Date: Tue, 13 Jan 2009 18:07:51 -0800
Message-ID: <6599ad830901131807n3acf6936g2028fc5f7edd6264@mail.gmail.com>
References: <20090106230554.GB25228@eskarina.localdomain.pl>
	 <49644526.8030205@cn.fujitsu.com> <20090107073831.GA23648@megiteam.pl>
	 <49646993.6080802@cn.fujitsu.com> <20090107091600.GA17612@megiteam.pl>
	 <496476FD.8090209@cn.fujitsu.com>
	 <6599ad830901091338t38f5d5bav6adcd55ea188e28d@mail.gmail.com>
	 <49682921.4020100@cn.fujitsu.com>
	 <6599ad830901100814g5faeb611v7a36eed987c103ff@mail.gmail.com>
	 <496AA8E0.2070002@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Grzegorz Nosek <root@localdomain.pl>, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:38480 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599AbZANCH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 21:07:57 -0500
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id n0E27sMD017884
	for <netdev@vger.kernel.org>; Wed, 14 Jan 2009 02:07:54 GMT
Received: from rv-out-0506.google.com (rvfb25.prod.google.com [10.140.179.25])
	by wpaz5.hot.corp.google.com with ESMTP id n0E278i7004107
	for <netdev@vger.kernel.org>; Tue, 13 Jan 2009 18:07:51 -0800
Received: by rv-out-0506.google.com with SMTP id b25so309317rvf.43
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2009 18:07:51 -0800 (PST)
In-Reply-To: <496AA8E0.2070002@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> I think the only way to make hierarchy_mutex works for this issue is:
>
> @@ -2403,16 +2403,18 @@ static long cgroup_create(struct cgroup *parent, struct
>        if (notify_on_release(parent))
>                set_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
>
> +       cgroup_lock_hierarchy(root);
> +
>        for_each_subsys(root, ss) {
>                struct cgroup_subsys_state *css = ss->create(ss, cgrp);
>                if (IS_ERR(css)) {
> +                       cgroup_unlock_hierarchy(root);
>                        err = PTR_ERR(css);
>                        goto err_destroy;
>                }
>                init_cgroup_css(css, ss, cgrp);
>        }
>
> -       cgroup_lock_hierarchy(root);
>        list_add(&cgrp->sibling, &cgrp->parent->children);
>        cgroup_unlock_hierarchy(root);
>        root->number_of_cgroups++;
>

That would be possible, but I'm not sure that extending
hierarchy_mutex across all the create calls is a good idea - it's
meant to be very lightweight.

OK, an alternative way to avoid cgroup_lock() is for the
spinlock-protected state in ipcgroup to be the address and the count
of active children.

create() does:

lock parent
css->addr = parent->addr
parent->child_count++;
unlock parent

and write does:

lock css
if (!css->child_count) {
  css->addr = new_addr
} else {
  report error;
}
unlock css

Paul
