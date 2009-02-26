From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH v2] bonding: move IPv6 support into a separate kernel module
Date: Thu, 26 Feb 2009 13:56:37 -0800
Message-ID: <22047.1235685397@death.nxdomain.ibm.com>
References: <49A5ADB3.2010709@hp.com> <28797.1235599858@death.nxdomain.ibm.com> <20090225.141430.166906161.davem@davemloft.net> <49A6C6ED.3070801@hp.com> <22876.1235672073@death.nxdomain.ibm.com> <49A6ED6D.3090508@hp.com> <7418.1235679608@death.nxdomain.ibm.com> <49A70245.9010405@hp.com>
Cc: Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>, arvidjaar@mail.ru,
	chuck.lever@oracle.com, tytso@mit.edu, Valdis.Kletnieks@vt.edu,
	rjw@sisk.pl, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, jamagallon@ono.com,
	linux-kernel@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:45696 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149AbZBZV4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 16:56:35 -0500
In-reply-to: <49A70245.9010405@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Yasevich <vladislav.yasevich@hp.com> wrote:

>Jay Vosburgh wrote:
[...]
>> Brian Haley <brian.haley@hp.com> wrote:
[...]
>>> I think changing ipv6 to support a disable_ipv6 module parameter like Vlad
>>> suggested would work, as long as we're not worried about someone opening
>>> an AF_INET6 socket - even if they do they won't get anywhere.  That, along
>>> with the patch below to actually not add the addresses, would work (sorry
>>> in advance for using an attachment).  I'll get started on that...
>> 
>> 	I agree that it would work, and could even be set up such that
>> opening sockets doesn't work, either (if ipv6 never registered via
>> sock_register, for example).  I'm sticking some on the opening sockets
>> failure behavior because it's the current behavior if ipv6 is aliased
>> out.  It just seems like a logical place for the permission denial to
>> occur, rather than later, and is consistent with what happens if ipv6
>> isn't loaded at all or is not configured in the kernel.
>> 
>> 	I still tend to like the bitmask to disable address family
>> gizmo.  It's not specific to one particular protocol (although it would
>> likely need a check in the protocols for things like addrconf).  As
>> somebody pointed out, there are likely to be (if not now, then
>> relatively soon) users somewhere that want to turn off ipv4 and run ipv6
>> only.
>
>Yes.  The bitmask to disable certain family can be useful, but it's orthogonal
>the issue of IPv6 support.  As you said, it can be used to disable
>any address family that user wishes.  The slight issue with this might
>be, should the settings affect already create sockets?

	Unless I'm misunderstanding your position, I don't think the
bitmask method is really orthogonal, since it can be used to disable
IPv6 (AF_INET6).  More on that below.

	I'd also argue that such a method should affect the entirety of
the protocol family, so extant sockets would cease to function.  That
may or may not be practical or necessary.

>I guess it comes down how many levels of control to do we want to provide.
>Things that have been suggested so far:
>	1) Global on/off switch (i.e module parameter)
>	2) Per interface on/off switch (currently exists, but has bugs).
>	3) Socket on/off switch (i.e blocker bitmask)
>
>I think numbers 1 and 2 turn off the IPv6 protocol on the wire, while number
>3 turns off the interface to the user.  The two can be done independent.

	Yes, I think this reaches the crux of the matter: disabling the
protocol vs. disabling the interface.  Any of the knobs (1 - 3, above)
can potentially do either one or both of these.

	My feeling is that, for consistency of behavior, whatever knob
is turned should act like ipv6 was never loaded.  That might or might
not be the right answer in the grand scheme of things, but it's the
expected behavior of the users currently aliasing out ipv6 in
/etc/modprobe.conf.

	When The Knob (however it ends up being done) is turned, why
should the "ipv6 off" behavior be any different than what is currently
observed when aliasing out ipv6 or compiling a kernel without
CONFIG_IPV6?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
