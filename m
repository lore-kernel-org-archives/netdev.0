From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Problem removing netns
Date: Wed, 22 Aug 2012 16:59:58 -0700
Message-ID: <87393epjep.fsf@xmission.com>
References: <CAJO99T=qtzw_4LZOg9eXmPrjKELDzxCHKBEabwd50N9unS7kbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?utf-8?Q?Bj=C3=B8rnar?= Ness <bjornar.ness@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:51364 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757211Ab2HWAAI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 20:00:08 -0400
In-Reply-To: <CAJO99T=qtzw_4LZOg9eXmPrjKELDzxCHKBEabwd50N9unS7kbw@mail.gmail.com>
	(=?utf-8?Q?=22Bj=C3=B8rnar?= Ness"'s message of "Wed, 22 Aug 2012 13:59:25
 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rnar Ness <bjornar.ness@gmail.com> writes:

> I am experimenting with netns (Linux precision 3.2.0-0.bpo.2-amd64 #1
> SMP Sun Jun 3 21:40:57 UTC 2012 x86_64 GNU/Linux)
> and have problems removing unused namespace, this is what I do:
>
> ip netns add netns_one
> ip netns add netns_two
> ip link add name if_one type veth peer name if_one_peer
> ip link add name if_two type veth peer name if_two_peer
> ip link set dev if_one_peer netns netns_one
> ip link set dev if_two_peer netns netns_two
>
> ip netns exec netns_one bash
>
> # in other terminal:
>
> ip netns delete netns_two
>
> # =3D> Cannot remove /var/run/netns/netns_two: Device or resource bus=
y
>
> Is this expected  behaviour? If so, what is the correct process to
> actually remove a namespace?

This is unintended but "correct" behavior.

The linux VFS won't let you remove an a file or directory that has
something mounted on it.=20

Cloning the mount namespace creates a copy of all of the mounts.

With the result that your long running processe created with
ip netns exec (or anything else that clones the mount namespace)
will continue to hold a references to mounted that keesp the network
namespace alive.

In my usage patterns I haven't tripped over this.

Probably the simplest fix would be to take advantage of mount propogate
so that when we unmount the network namespace in one mount namespace it
get unmounted in all of them.  I don't expect I will be able to look at
implementing anything like that for a while, although it shouldn't take
much work to implement that.

Eric
