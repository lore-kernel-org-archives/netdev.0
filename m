From: Joel Cunningham <joel.cunningham@me.com>
Subject: Re: Understanding mutual exclusion between rtnl_lock and rcu_read_lock
Date: Thu, 02 Feb 2017 20:05:19 -0600
Message-ID: <096DC091-F762-4401-9AE1-22AF6899BACB@me.com>
References: <FEDE3C6F-2C5C-4BCE-829F-C8E177C2AA36@me.com>
 <CAKgT0Ufy1gii_tQ=puNnPfFeHiE=jti5ObFP3Js0U03ULPFyiQ@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pv38p43im-ztdg05071201.me.com ([17.133.183.8]:46455 "EHLO
        pv38p43im-ztdg05071201.me.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751944AbdBCCFV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 21:05:21 -0500
Received: from process-dkim-sign-daemon.pv38p43im-ztdg05071201.me.com by
 pv38p43im-ztdg05071201.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 id <0OKS00O000DTDH00@pv38p43im-ztdg05071201.me.com> for
 netdev@vger.kernel.org; Fri, 03 Feb 2017 02:05:20 +0000 (GMT)
In-reply-to: <CAKgT0Ufy1gii_tQ=puNnPfFeHiE=jti5ObFP3Js0U03ULPFyiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 2, 2017, at 5:52 PM, Alexander Duyck =
<alexander.duyck@gmail.com> wrote:
>=20
> On Thu, Feb 2, 2017 at 3:47 PM, Joel Cunningham =
<joel.cunningham@me.com> wrote:
>> Hi,
>>=20
>> I=E2=80=99m studying the synchronization used on different parts of =
struct net_device and I=E2=80=99m struggling to understand how structure =
member modifications in dev_ioctl are synchronized.  Getters in =
dev_ifsioc_locked() are only holding rcu_read_lock() while setters in =
dev_ifsioc() are holding rtnl_lock, but not using RCU APIs.  I was =
specifically looking at SIOCGIFHWADDR/SIOCSIFHWADDR.  What=E2=80=99s to =
prevent one CPU from executing a getter and another CPU from executing a =
setter resulting in possibly a torn read/write?  I didn=E2=80=99t see =
anything in rtnl_lock() that would wait for any rcu_reader_lock() =
critical sections (on other CPUs) to finish before acquiring the mutex.
>>=20
>> Is there something about dev_ioctl that prevents parallel execution? =
or maybe something I still don=E2=80=99t understand about the RCU =
implementation?
>>=20
>> Thanks,
>>=20
>> Joel
>=20
> My advice would be to spend more time familiarizing yourself with RCU.
> The advantage of RCU is that it allows for updates while other threads
> are accessing the data.

Thanks for the follow up!

I have been trying to find more examples of RCU where the writer updates =
the structure in-place without using RCU APIs, but so far haven=E2=80=99t =
found anything

In the case of SIOCSIFHWADDR, we get a pointer to the net_device through =
__dev_get_by_name() and then pass it to dev_set_mac_address() to modify =
through ndo_set_mac_address().  I didn=E2=80=99t see any uses of RCU =
APIs on the writer side and that=E2=80=99s why I figured there was =
something going on with rtnl_lock() that I didn=E2=80=99t understand or =
that the dev_ioctl function wasn=E2=80=99t re-entrant from another CPU

> The rtnl_lock is just meant to prevent
> multiple writers from updating the data simultaneously.  So between
> writers the rtnl_lock is used to keep things synchronized, but between
> writers and readers the mechanism that is meant to protect the data
> and keep it sane is RCU.

Your description of rtnl_lock make sense.  I=E2=80=99m still confused =
with how the setter side code (in dev_ifsioc) is using RCU since I =
don=E2=80=99t see any APIs called.

Thanks,

Joel
