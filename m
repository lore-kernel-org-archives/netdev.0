From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Move interface across network namespaces
Date: Thu, 18 Aug 2011 16:12:57 -0700
Message-ID: <m14o1e71qe.fsf@fess.ebiederm.org>
References: <CAChaegkomwjL0X7HnfLi1XH26jDKOL6fCgjfms67cjjU4gRXPg@mail.gmail.com>
	<m1r54s8lq4.fsf@fess.ebiederm.org>
	<CAChaegm2d3LywMAcq66PgPZwF5Fu=_zuqcTh8VdCG6zvhyPJXQ@mail.gmail.com>
	<CAChaeg=1WSU0webhYDpQcnq3cJje17FQ5Z8rypD8sdkyzcLT-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net,
	David Lamparter <equinox@diac24.net>
To: Renato Westphal <renatowestphal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:50110 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268Ab1HRXNH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2011 19:13:07 -0400
In-Reply-To: <CAChaeg=1WSU0webhYDpQcnq3cJje17FQ5Z8rypD8sdkyzcLT-g@mail.gmail.com>
	(Renato Westphal's message of "Mon, 15 Aug 2011 10:10:24 -0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Renato Westphal <renatowestphal@gmail.com> writes:

> I forgot to mention that I'm using kernel v2.6.35 (with a lot of
> backports). For future reference, the commit 3b27e105550f7c4a ("netns=
:
> keep vlan slaves on master netns move", merged into v2.6.37-rc1) fixe=
s
> this problem.

Which makes me silly as I now remember reviewing that patch.

>>>> * The target network namespace sends a RTM_NEWLINK netlink message
>>>> when an interface is moved to it. In the other hand, the source
>>>> network namespace doesn't sends a RTM_DELLINK message when an
>>>> interface is moved from it. This is very annoying because user spa=
ce
>>>> applications (such as zebra) can't detect some interface moving
>>>> operations and then get into an inconsistent state. Anyone knows i=
f
>>>> there's a workaround for this?
>>>
>>> Not getting RTM_DELLINK is a bug. =C2=A0The device registration and
>>> unregistration code has changed since dev_change_net_namespace was
>>> written and apparently one of the changes failed to update
>>> dev_change_net_namespace.
>>>
>>
>> Good, that makes a lot more sense. In the kernel 2.6.32.43 the
>> RTM_DELLINK netlink message is sent when a network interface is move=
d
>> from a network namespace. The same doesn't happens in the kernel
>> 2.6.35.13. I'll try to isolate the problem some more.
>
> Well, this regression was introduced by commit a2835763e130c343ac,
> which was merged into v2.6.34. Reverting parts of this commit makes
> the problem go away but breaks the support of "specifying device flag=
s
> during device creation". I don't know the best way to fix this... any
> ideas?

Everything going through dev_change_net_namespace already needs to be
in the initialized state.  So it looks like we just need to do:

Does the patch below work for you?

Eric

---

diff --git a/net/core/dev.c b/net/core/dev.c
index 17d67b5..bfbde69 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6108,6 +6108,8 @@ int dev_change_net_namespace(struct net_device *d=
ev, struct net *net, const char
 	call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
 	call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH, dev);
=20
+	rtmsg_ifinfo(RTM_DELLINK, dev, ~0U);
+
 	/*
 	 *	Flush the unicast and multicast chains
 	 */
