From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@gmail.com>
Subject: Re: Regression: "rtnetlink: Compute and store minimum ifinfo dump
 size" breaks glibc's getifaddrs()
Date: Fri, 27 Jan 2012 23:26:02 +0100
Message-ID: <CAGsizzKC_qnV_WdW+4vDLkE69615atHz3rm4Bj7o0wLJnd92rQ@mail.gmail.com>
References: <4F229A5F.4050600@citrix.com> <20120127.165357.462031319592012792.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: david.vrabel@citrix.com, netdev@vger.kernel.org,
	gregory.v.rose@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:49625 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752125Ab2A0W0W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 17:26:22 -0500
Received: by dadi2 with SMTP id i2so1784995dad.19
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2012 14:26:22 -0800 (PST)
In-Reply-To: <20120127.165357.462031319592012792.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/27 David Miller <davem@davemloft.net>:
> From: David Vrabel <david.vrabel@citrix.com>
> Date: Fri, 27 Jan 2012 12:36:47 +0000
>
>> Changeset c7ac8679bec9397afe8918f788cbcef88c38da54 (rtnetlink: Compu=
te
>> and store minimum ifinfo dump size) applied to 3.1 increased the max=
imum
>> size of the RTM_GETLINK message response.
>>
>> glibc's getifaddrs() function uses a page sized (4 KiB) buffer for t=
he
>> RTM_GETLINK response and returns a failure if the message is truncat=
ed.
>> This buffer is not large enough if there is a network card with many
>> virtual functions.
>>
>> What do you recommend to resolve this regression?
>
> Actually, glibc technically uses the CPP define value "PAGE_SIZE" if
> available, which is potentially different from the system page size.
>
> Using a statically defined PAGE_SIZE is wrong if the program is
> subsequently executed on a system with a different page size.
>
> On sparc, and powerpc I believe, this happens commonly. =A0A 32-bit
> executable will see a PAGE_SIZE value of 4K, but when executed on a
> 64-bit system the page size is actually 8K or larger. =A0That's why
> __getpagesize() should always be used.
>
> Anyways, if the page sizes are correct we're in a bit of a pickle.
>
> Do you have any idea what the computed value of min_ifinfo_dump_size
> is at the time of the failure?
>
> Greg, I think we're kind of screwed. =A0The defined minimum appropria=
te
> buffer size for a recvmsg() call on a netlink socket is defined as:
>
> =A0 =A0 =A0 =A0getpagesize() < 8192 ? getpagesize() : 8192
>
> and glibc essentially abides by this by unconditionally using page
> size, and therefore if an interface with many virtual interfaces take=
s
> us over this limit, we break basically every properly written piece o=
f
> netlink code out there.
>
> iproute2 is funny, it uses a static 16K buffer size for netlink
> message reception, which tends to paper over this problem :-/
>
> Stefan, this plays into your work too, we're starting to create
> situations which are going to cause very serious problems. =A0Imagine
> an interface with lots of these new macvlan source rules, it would
> potentially exceed the limit in the above equation as well.
>
> Thanks.
I can theoretically avoid this situation by using multiple small
rtnetlink messages instead of one huge. I believe that ipset code is
using that approach - just have to figure out proper changes to my
macvlan code. But this doesn't solves the issue you are mentioning, it
only prohibits to happen for macvlan code as one page size will be
more than enough to allocate buffer....
