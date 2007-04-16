From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8320] New: replacing route in kernel doesn't
 send netlink message
Date: Mon, 16 Apr 2007 06:59:06 +0200
Message-ID: <4623029A.2090906@trash.net>
References: <200704110937.l3B9b1Kp001053@fire-2.osdl.org>	 <20070411094740.e7c04b49.akpm@linux-foundation.org>	 <461D26CB.3010508@trash.net> <1176400428.24446.40.camel@nt.wq.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: =?ISO-8859-15?Q?Milan_Koci=E1n?= <milon@wq.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63921 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbXDPFBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 01:01:08 -0400
In-Reply-To: <1176400428.24446.40.camel@nt.wq.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Milan Koci=E1n wrote:
> On Wed, 2007-04-11 at 20:19 +0200, Patrick McHardy wrote:
>=20
>=20
>>I think having notifications for this case makes sense (IIRC I used
>>to use a similar patch some time ago, but can't find it right now).
>>But we need to indicate somehow that it is a replacement and not a
>>completely new route, either by sending a RTM_DELROUTE for the old
>>route first (which would match what devinet does for addresses)
>>or by echoing the NLM_F_REPLACE flag. The former would probably be
>>easier for userspace to understand since it wouldn't need to
>>replicate the replacement logic just to find out which rule got
>>replaced.
>>
>>
>=20
>=20
> Hard to tell what is better. I slightly tried to test my patch with
> quagga routing daemon. And then I tested second case: send RTM_DELROU=
TE
> before RTM_NEWROUTE. Quagga updates internal rib in both cases (as I =
saw
> in debug logs). I was in fear that quagga will try to install sefl ro=
ute
> but it doesn't catch.
> So from my point of view is all the same :).


Looking at some old code of mine, it would treat a simple RTM_NEWROUTE
without deletion in advance incorrectly, but it also would ignore
NLM_F_REPLACE. Quagga doing the right thing seems to be a result of
the fact that it doesn't care about some of the routes attributes and
treats NEWROUTE messages as replacements as long as the attributes it
cares about match.

RTM_DELROUTE + RTM_NEWROUTE seem to be safer, although you're correct
that it might cause userspace to perform some action upon receiving
the DELROUTE message since the update is non-atomic. So I really don't
know, I'm in favour of having notifications for replacements, but I
fear we might break something.

