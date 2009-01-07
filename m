From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [RFC][PATCH] IP address restricting cgroup subsystem
Date: Wed, 07 Jan 2009 17:33:49 +0800
Message-ID: <496476FD.8090209@cn.fujitsu.com>
References: <20090106230554.GB25228@eskarina.localdomain.pl> <49644526.8030205@cn.fujitsu.com> <20090107073831.GA23648@megiteam.pl> <49646993.6080802@cn.fujitsu.com> <20090107091600.GA17612@megiteam.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: Grzegorz Nosek <root@localdomain.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52422 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754140AbZAGJeq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 04:34:46 -0500
In-Reply-To: <20090107091600.GA17612@megiteam.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grzegorz Nosek wrote:
> On =C5=9Bro, sty 07, 2009 at 04:36:35 +0800, Li Zefan wrote:
>> Grzegorz Nosek wrote:
>>>>> IP addresses are write-once (via /cgroup/.../ipaddr.ipv4 in dotte=
d-quad
>>>> Why they should be write-once ?
>>> No real (technical) reason. Making it read-write would be fine with=
 me.
>>> I wanted to make the restriction a one-way road but I guess I can p=
olice
>>> that in userspace (simply don't write anything to the file twice).
>>>
>> But seems the patch makes it impossible to re-allow a restricted tas=
k to
>> be binded to INADDR_ANY.
>=20
> Yes, my goal is to disallow that but I don't insist to do that in the
> kernel (I'm not currently planning to let untrusted root loose in a
> container).
>=20
>> Firstly, is inheritance necessary ?
>=20
> It would be nice to have when the container's root is untrusted but
> might want to subdivide the container's cgroup for other purposes.
> Without inheritance, they would be able to circumvent the IP address
> restriction. One could argue that a full untrusted-root container wou=
ld
> need a proper network namespace anyway (and giving CAP_SYS_ADMIN ther=
e
> is probably a very bad idea), but still, I'd feel uneasy.
>=20
>> If yes, then how about:
>>
>> The root cgroup is read-only, so the tasks in it always bind to INAD=
DR_ANY.
>> For other cgroups, write is allowed only if it has no children and t=
he
>> parent is INADDR_ANY.
>=20
> Yes, I like that. Will update the patch. I assume that I must check
> list_empty(&cgroup->children)?

Yes.

> Should I use cgroup_lock()/cgroup_unlock()

Yes.

> or other locking? I think it will be safe to do without locks but wou=
ld
> rather get some expert advice.
>=20

No. Without locks, it races with mkdir.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

//cgroup_lock();

if (list_empty(&cgrp->children) &&
    parent->ipv4_addr =3D=3D INADDR_ANY)
					   <--- mkdir()
	ipcgroup->ipv4_addr =3D new_addr;

//cgroup_unlock();

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

In the above case, ipcgroup->ipv4_addr =3D new_addr,
but child_cgroup->ipv4_addr =3D=3D INADDR_ANY, which is not expected.

> Thanks a lot for your comments.
>=20
> Best regards,
>  Grzegorz Nosek
>=20
