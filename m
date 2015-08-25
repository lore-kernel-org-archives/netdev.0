From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: vxlan regression: multiple VXLANs on a single multicast group
 broken in kernel 4.1
Date: Tue, 25 Aug 2015 15:52:08 -0300
Message-ID: <55DCB958.3080904@gmail.com>
References: <1F0A5B2B-5C6D-426F-91E9-A7A2F11A98A9@jnielsen.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: John Nielsen <lists@jnielsen.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:34212 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816AbbHYSwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 14:52:15 -0400
Received: by qkfh127 with SMTP id h127so106149523qkf.1
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 11:52:14 -0700 (PDT)
In-Reply-To: <1F0A5B2B-5C6D-426F-91E9-A7A2F11A98A9@jnielsen.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 25-08-2015 14:35, John Nielsen escreveu:
> After updating the kernel on a KVM host, I discovered yesterday that =
I can no longer use more than one vxlan interface on a single multicast=
 group/address. The interfaces can be created but only the first one ma=
y be brought up:
>
> # ip link add vx100 type vxlan id 100 group 239.0.0.1 dev eth0
> # ip link add vx200 type vxlan id 200 group 239.0.0.1 dev eth0
> # ip link set up dev vx100
> # ip link set up dev vx200
> RTNETLINK answers: Address already in use
>
> Using unique group addresses (one VNI per group) still works as expec=
ted. The problem is not present in kernel 4.0.5 but it is in kernel 4.1=
=2E0.
>
> I suspect (but have not verified) that the regression was caused by t=
his commit:
> vxlan: Move socket initialization to within rtnl scope 56ef9c909b4048=
3d2c8cb63fcbf83865f162d5ec
>
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/=
commit/drivers/net/vxlan.c?id=3D56ef9c909b40483d2c8cb63fcbf83865f162d5e=
c
>
> I am working to verify that that is the culprit but I thought I=E2=80=
=99d see in the mean time if anyone else has encountered and/or fixed t=
his, or can at least shed more light on the problem.

Yes that commit is the culprit. Previously it was ignoring igmp_join=20
errors, and now it's not but at the same time, it's trying to double=20
join that group on the socket that is reused.

Will try to cook a patch here, thanks for the report!

If you need a hack for now, just ignore vxlan_igmp_join() return value=20
at vxlan_open() and it should be fine.

   Marcelo
