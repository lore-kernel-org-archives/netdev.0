From: Vijay Pandurangan <vijayp@vijayp.ca>
Subject: =?UTF-8?Q?Re=3A_veth_regression_with_=22don=E2=80=99t_modify_ip=5Fsummed=3B_?=
	=?UTF-8?Q?doing_so_treats_packets_with_bad_checksums_as_good=2E=22?=
Date: Thu, 7 Apr 2016 11:11:48 -0400
Message-ID: <CAKUBDd_2sC45FW72g1nWzM0k0+EeBUk0LoOMzVwuBfLWHUh-KA@mail.gmail.com>
References: <56F463D6.7080406@candelatech.com> <CAM_iQpWv_iP1ZtsRQT0YsztMrf6rdaXN2V57PUu5oBe5kR56AQ@mail.gmail.com>
 <56F4810A.9060904@candelatech.com> <56F49036.8050902@candelatech.com>
 <56F490B2.3090603@candelatech.com> <CAKUBDd9TjFTvXSEL=+J02PVndNG-gcrMOpRo_MFp4J-oOnLrvQ@mail.gmail.com>
 <56F4BFF1.8010806@candelatech.com> <CAM_iQpUaBD-HmHVAcEBCRw38PbecjYk2to+DO9TNkLY93u2_NA@mail.gmail.com>
 <56F4C8FD.7030907@candelatech.com> <CAM_iQpWwch3+6u+X0DBGyVSWttd7Nz2COdmq2q=G9BxisW52bA@mail.gmail.com>
 <56F5A618.9070206@candelatech.com> <CAKUBDd844=BTpK2B2izzRGqwKQV5RtsFAO9nFQ5CJqDENLFW5A@mail.gmail.com>
 <56F5BA45.2030706@candelatech.com> <CAKUBDd8FGh3mhDmoyH70WvNGyofPVbjdROPKzenm+6DLfALyqg@mail.gmail.com>
 <56F5CDE4.7010306@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>, Evan Jones <ej@evanjones.ca>,
	Cong Wang <cwang@twopensource.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:34018 "EHLO
	mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991AbcDGPMJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 11:12:09 -0400
Received: by mail-vk0-f52.google.com with SMTP id e185so102918519vkb.1
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 08:12:09 -0700 (PDT)
In-Reply-To: <56F5CDE4.7010306@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 25, 2016 at 7:46 PM, Ben Greear <greearb@candelatech.com> w=
rote:
> A real NIC can either do hardware checksums, or it cannot.  If it
> cannot, then the host must do it on the CPU for both transmit and
> receive.
>
> Veth is not a real NIC, and it cannot do hardware checksum offloading=
=2E
>
> So, we either lie and pretend it does, or we eat massive amounts
> of CPU usage to calculate and check checksums when sending across
> a veth pair.
>

That's a good point. Does anyone know what the overhead actually is the=
se days?

>>> Any frame sent from a socket can be considered to be a local packet=
 in my
>>> opinion.
>>
>>
>> I'm not sure that's totally right. Your bridge is adding a delay to
>> your packets; it could just as easily be simulating corruption by
>> corrupting 5% of packets going through it. If this change allows
>> corrupt packets to be delivered to an application when they could no=
t
>> be delivered if the packets were routed via physical eths, I think
>> that is a bug.
>
>
> I actually do support corrupting the frame, but what I normally do is
> corrupt the contents
> of the packet, and then recalculate the IP checksum (and TCP if it ap=
plies)
> and send it on its way.  The receiving NIC and stack will pass the fr=
ame up
> to
> the application since the checksums match, and it would be up the
> application
> to deal with it.  So, I can easily cause an application to receive co=
rrupted
> frames over physical eths.
>
> I can also corrupt without updating the checksums in case you want to
> test another systems NIC and/or stack.
>
> But, if I am purposely corrupting a frame destined for veth, then the=
 only
> reason
> I would want the stack to check the checksums is if I were testing my=
 own
> stack's checksum logic, and that seems to be a pretty limited use.


In the common case you're 100% right.  OTOH, there's something
disconcerting about an abstraction layer lying and behaving
unexpectedly.  Most traffic that originates on a machine can have its
checksums safely ignored.  Whatever the reason is (maybe, as you say
you're testing checksums =E2=80=93 on the other hand maybe there's a bu=
g in
your code somewhere), I really feel like we should try to figure out a
way to ensure that this optimization is at the very least opt-in=E2=80=A6

>
>
> Thanks,
> Ben
>
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
>
