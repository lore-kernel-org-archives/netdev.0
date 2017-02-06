From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Understanding mutual exclusion between rtnl_lock and rcu_read_lock
Date: Sun, 5 Feb 2017 22:29:07 -0800
Message-ID: <CAM_iQpW_yg+=rqz90vicP5LcPdGiXA0X4_zqQ-gp1zFR5rn=bQ@mail.gmail.com>
References: <FEDE3C6F-2C5C-4BCE-829F-C8E177C2AA36@me.com> <CAKgT0Ufy1gii_tQ=puNnPfFeHiE=jti5ObFP3Js0U03ULPFyiQ@mail.gmail.com>
 <096DC091-F762-4401-9AE1-22AF6899BACB@me.com> <CAM_iQpU+5JP+tBcDuBnLd_WnY1DuymJ6ukxcJJSq4E3p9Pah=A@mail.gmail.com>
 <F7A17A24-4FCC-4036-A7F6-B8374DFD665F@me.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Joel Cunningham <joel.cunningham@me.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36103 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750962AbdBFG32 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 01:29:28 -0500
Received: by mail-wm0-f66.google.com with SMTP id r18so19767038wmd.3
        for <netdev@vger.kernel.org>; Sun, 05 Feb 2017 22:29:28 -0800 (PST)
In-Reply-To: <F7A17A24-4FCC-4036-A7F6-B8374DFD665F@me.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 3, 2017 at 7:25 PM, Joel Cunningham <joel.cunningham@me.com> wr=
ote:
> From the documentation in dev.c:
> /*
>  * The @dev_base_head list is protected by @dev_base_lock and the rtnl
>  * semaphore.
>  *
>  * Pure readers hold dev_base_lock for reading, or rcu_read_lock()
>  *
>  * Writers must hold the rtnl semaphore while they loop through the
>  * dev_base_head list, and hold dev_base_lock for writing when they do th=
e
>  * actual updates.  This allows pure readers to access the list even
>  * while a writer is preparing to update it.
>  *
>  * To put it another way, dev_base_lock is held for writing only to
>  * protect against pure readers; the rtnl semaphore provides the
>  * protection against other writers.
>  *
>  * See, for example usages, register_netdevice() and
>  * unregister_netdevice(), which must be called with the rtnl
>  * semaphore held.
>  */

This comment is pretty old, it was added prior to git history.


> Is the correct usage is to hold both rtnl_lock() and dev_base_lock when m=
odifying a member of a struct net_device?  The wording seems vague as to wh=
ich synchronization issue holding both covers.  What does =E2=80=9Cdo the a=
ctual update=E2=80=9D mean, updating the list or structure member?  If the =
latter, then maybe the concurrent dev_ioctl() case has never been safe
>

I think dev_base_lock is supposed to speed up the readers when
we only read one or a few fields from netdevice, otherwise it would
be pretty pointless since we already have the RTNL lock.

Unfortunately, as you noticed, not all of these fields are protected
by dev_base_lock, therefore the readers who only take this read
lock is not enough to read an atomic result.

RCU doesn't seem to be the solution here, since it still requires
a whole copy of netdevice even we only update, for example MTU.
This is very inconvenient.

It is also kinda messy due to the mix of dev_base_lock, RCU,
and RTNL. Sigh...
