From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] net: ipv6: Allow netlink to set IPv6 address scope
Date: Mon, 17 Oct 2011 11:26:39 +0900
Message-ID: <CAKD1Yr0mnSM5EyVhJDPyq3Obe2WNiEjgQ=0uQ-r39Fg9WTsVmw@mail.gmail.com>
References: <20111005201559.E544016A599@drone1.mtv.corp.google.com>
 <4E931A46.1040905@hp.com> <CAKD1Yr29dAC+_=bT5-_W3XuTzoxMiEzOhpHvwrAzyA8NdcCjSQ@mail.gmail.com>
 <4E98981D.6080908@hp.com> <CAKD1Yr0EQ0P8e1V7pw48F2LMPCFKuZHm0DGoq8VM+LeKO_aZhQ@mail.gmail.com>
 <4E9B7A9F.7000302@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maze@google.com, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:22774 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753798Ab1JQC1E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Oct 2011 22:27:04 -0400
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p9H2R0r0015680
	for <netdev@vger.kernel.org>; Sun, 16 Oct 2011 19:27:01 -0700
Received: from yxk36 (yxk36.prod.google.com [10.190.3.164])
	by wpaz17.hot.corp.google.com with ESMTP id p9H2PQw0013438
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 16 Oct 2011 19:26:59 -0700
Received: by yxk36 with SMTP id 36so3900393yxk.3
        for <netdev@vger.kernel.org>; Sun, 16 Oct 2011 19:26:59 -0700 (PDT)
In-Reply-To: <4E9B7A9F.7000302@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2011 at 09:45, Brian Haley <brian.haley@hp.com> wrote:
>
> I think this goes against the intent of RFC 3879 (Deprecating Site Lo=
cal
> Addresses), and it assumes that the user has some knowledge of the ne=
twork
> topology. =A0When we send something out the carrier interface, we don=
't know why
> it didn't make it to it's final destination - firewall, network link =
down,
> congestion - we might not get the ICMP reason back.

Absolutely yes, this assumes that the user has knowledge of network
topology. But
we already know that, because in order for this code to be exercised,
the user must
have explicitly specified a non-global scope in the code that he ran
(or in the "ip
addr add" command that he executed). The only difference with this patc=
h is that
the kernel does what the user asked for instead of making its own decis=
ion.

The way things would work in this scenario is that whatever userspace
code creates
the IPv6 address on the carrier interface would create it with
site-local scope.=A0That
code knows perfectly well that the interface should not be used when
connecting to
globally scoped addresses and would tell the kernel not to use it. The =
kernel
currently refuses to do so because it thinks it knows better, but
since it doesn't, the
user's connections hang.=A0I don't think this is a good idea.

RFC 3879 deprecated site-local addresses because the were non-unique an=
d thus
ambiguous, and if they leak, they cause problems. This is not an issue
in the use
case I presented, because the addresses are syntactically global
addresses - they
just don't have global reachability.

> The MIF problem statement (in the RFC editor's queue) talks about thi=
s problem,
> http://tools.ietf.org/html/draft-ietf-mif-problem-statement-15 - perh=
aps it's
> better to work there to develop a more generic solution (using DHCPv6=
, RA
> options, etc) before making this change?

I don't think it's a good idea. Waiting for an IETF working group to
produce a standard
when it doesn't even have a problem statement finalized could take year=
s.

Is there another reason why we shouldn't enable userspace to do what it=
 wants?
