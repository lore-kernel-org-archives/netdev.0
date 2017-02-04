From: Joel Cunningham <joel.cunningham@me.com>
Subject: Re: Understanding mutual exclusion between rtnl_lock and rcu_read_lock
Date: Fri, 03 Feb 2017 21:25:25 -0600
Message-ID: <F7A17A24-4FCC-4036-A7F6-B8374DFD665F@me.com>
References: <FEDE3C6F-2C5C-4BCE-829F-C8E177C2AA36@me.com>
 <CAKgT0Ufy1gii_tQ=puNnPfFeHiE=jti5ObFP3Js0U03ULPFyiQ@mail.gmail.com>
 <096DC091-F762-4401-9AE1-22AF6899BACB@me.com>
 <CAM_iQpU+5JP+tBcDuBnLd_WnY1DuymJ6ukxcJJSq4E3p9Pah=A@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pv38p43im-ztdg05071201.me.com ([17.133.183.8]:34329 "EHLO
        pv38p43im-ztdg05071201.me.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753350AbdBDDZc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 22:25:32 -0500
Received: from process-dkim-sign-daemon.pv38p43im-ztdg05071201.me.com by
 pv38p43im-ztdg05071201.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 id <0OKT00C00YQKYB00@pv38p43im-ztdg05071201.me.com> for
 netdev@vger.kernel.org; Sat, 04 Feb 2017 03:25:28 +0000 (GMT)
In-reply-to: <CAM_iQpU+5JP+tBcDuBnLd_WnY1DuymJ6ukxcJJSq4E3p9Pah=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 3, 2017, at 3:40 PM, Cong Wang <xiyou.wangcong@gmail.com> =
wrote:
>=20
> On Thu, Feb 2, 2017 at 6:05 PM, Joel Cunningham =
<joel.cunningham@me.com> wrote:
>>=20
>> In the case of SIOCSIFHWADDR, we get a pointer to the net_device =
through __dev_get_by_name() and then pass it to dev_set_mac_address() to =
modify through ndo_set_mac_address().  I didn=E2=80=99t see any uses of =
RCU APIs on the writer side and that=E2=80=99s why I figured there was =
something going on with rtnl_lock() that I didn=E2=80=99t understand or =
that the dev_ioctl function wasn=E2=80=99t re-entrant from another CPU
>>=20
>=20
> You are right, that RCU read lock could merely protect the netdevice =
from
> being unregistered concurrently, can't prevent a concurrent =
dev_ifsioc().
>=20
> I don't know why Eric changed it to RCU read lock, it is not a hot =
path, using
> rtnl lock is fine and can guarantee a atomic read.

Thanks for confirming what I was seeing.  I took a look through the =
history and the change happened in =
3710becf8a58a5c6c4e797e3a3c968c161abdb41.  It was previously holding the =
dev_base_lock().

=46rom the documentation in dev.c:
/*
 * The @dev_base_head list is protected by @dev_base_lock and the rtnl
 * semaphore.
 *
 * Pure readers hold dev_base_lock for reading, or rcu_read_lock()
 *
 * Writers must hold the rtnl semaphore while they loop through the
 * dev_base_head list, and hold dev_base_lock for writing when they do =
the
 * actual updates.  This allows pure readers to access the list even
 * while a writer is preparing to update it.
 *
 * To put it another way, dev_base_lock is held for writing only to
 * protect against pure readers; the rtnl semaphore provides the
 * protection against other writers.
 *
 * See, for example usages, register_netdevice() and
 * unregister_netdevice(), which must be called with the rtnl
 * semaphore held.
 */
Is the correct usage is to hold both rtnl_lock() and dev_base_lock when =
modifying a member of a struct net_device?  The wording seems vague as =
to which synchronization issue holding both covers.  What does =E2=80=9Cdo=
 the actual update=E2=80=9D mean, updating the list or structure member? =
 If the latter, then maybe the concurrent dev_ioctl() case has never =
been safe

Joel=
