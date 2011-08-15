From: Renato Westphal <renatowestphal@gmail.com>
Subject: Re: Move interface across network namespaces
Date: Mon, 15 Aug 2011 10:10:24 -0300
Message-ID: <CAChaeg=1WSU0webhYDpQcnq3cJje17FQ5Z8rypD8sdkyzcLT-g@mail.gmail.com>
References: <CAChaegkomwjL0X7HnfLi1XH26jDKOL6fCgjfms67cjjU4gRXPg@mail.gmail.com>
	<m1r54s8lq4.fsf@fess.ebiederm.org>
	<CAChaegm2d3LywMAcq66PgPZwF5Fu=_zuqcTh8VdCG6zvhyPJXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net,
	David Lamparter <equinox@diac24.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:40096 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752333Ab1HONKZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 09:10:25 -0400
Received: by vws1 with SMTP id 1so3864515vws.19
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2011 06:10:24 -0700 (PDT)
In-Reply-To: <CAChaegm2d3LywMAcq66PgPZwF5Fu=_zuqcTh8VdCG6zvhyPJXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/8/11 Renato Westphal <renatowestphal@gmail.com>:
> 2011/8/11 Eric W. Biederman <ebiederm@xmission.com>:
>> Renato Westphal <renatowestphal@gmail.com> writes:
>>
>>> Hello,
>>>
>>> I have two questions regarding the process of moving a network
>>> interface across different network namespaces:
>>>
>>> * When I move an interface, all the virtual interfaces attached to =
it
>>> are deleted. Is there any reason for such odd behavior? I would lik=
e
>>> to move some network interfaces and keep the attached vlans untouch=
ed.
>>
>> The defined semantics are that a network device is unregistered from
>> the networking stack in one network namespace and then registered
>> with the networking stack in another. =A0It is an unfortunate fact
>> that when vlan devices see their underlying device being unregistere=
d
>> they decide to delete themselves.
>>
>> A different vlan implementation might be able to have different
>> properties but I can't think of any obvious solution other than
>> don't do move the device that you have your vlans on top of.
>>
>
> Thanks for the info, I can handle with that by modifying my quagga-vr=
f patches.

I forgot to mention that I'm using kernel v2.6.35 (with a lot of
backports). For future reference, the commit 3b27e105550f7c4a ("netns:
keep vlan slaves on master netns move", merged into v2.6.37-rc1) fixes
this problem.

>>> * The target network namespace sends a RTM_NEWLINK netlink message
>>> when an interface is moved to it. In the other hand, the source
>>> network namespace doesn't sends a RTM_DELLINK message when an
>>> interface is moved from it. This is very annoying because user spac=
e
>>> applications (such as zebra) can't detect some interface moving
>>> operations and then get into an inconsistent state. Anyone knows if
>>> there's a workaround for this?
>>
>> Not getting RTM_DELLINK is a bug. =A0The device registration and
>> unregistration code has changed since dev_change_net_namespace was
>> written and apparently one of the changes failed to update
>> dev_change_net_namespace.
>>
>
> Good, that makes a lot more sense. In the kernel 2.6.32.43 the
> RTM_DELLINK netlink message is sent when a network interface is moved
> from a network namespace. The same doesn't happens in the kernel
> 2.6.35.13. I'll try to isolate the problem some more.

Well, this regression was introduced by commit a2835763e130c343ac,
which was merged into v2.6.34. Reverting parts of this commit makes
the problem go away but breaks the support of "specifying device flags
during device creation". I don't know the best way to fix this... any
ideas?

--=20
Renato Westphal
