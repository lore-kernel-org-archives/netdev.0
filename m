From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] endianness issues in drivers/net/ethernet/qlogic/qed
Date: Sun, 24 Sep 2017 16:30:18 +0100
Message-ID: <20170924153018.GT32076@ZenIV.linux.org.uk>
References: <20170918174940.GB32076@ZenIV.linux.org.uk>
 <BN3PR0701MB15918FECAEB8503920850A7580650@BN3PR0701MB1591.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Elior, Ariel" <Ariel.Elior@cavium.com>,
        David Miller <davem@davemloft.net>
To: "Tayar, Tomer" <Tomer.Tayar@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:39224 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752368AbdIXPaW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 24 Sep 2017 11:30:22 -0400
Content-Disposition: inline
In-Reply-To: <BN3PR0701MB15918FECAEB8503920850A7580650@BN3PR0701MB1591.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 24, 2017 at 02:34:19PM +0000, Tayar, Tomer wrote:
> 
> > 	"qed: Utilize FW 8.10.3.0" has attempted some endianness annotations
> > in that driver; unfortunately, either annotations are BS or the driver is genuinely
> > broken on big-endian hosts.
> [...]
> > Is that driver intended to be used on big-endian hosts at all?
> 
> Thanks for taking the time to review our driver and pointing out these mistakes.
> Support for BE machines is planned to be added but currently it is not available.
> However, the structures which are used to abstract the HW carry endianity annotations.
> Obviously, there are some misses and some annotations were added when not required.
> We will prepare a patch that fixes the issues you pointed out and similar ones.

OK...  sparse is pretty good at spotting the problems; if you have any questions - just
ask.  A bit of random braindump concerning that kind of work:

	* bitfields and fixed-endian data do not mix.  It's much better to have just
__le32 (or __le64, etc.) in the structure and use GET_FIELD/SET_FIELD or similar for
accesses.  Another safe technics is something like
	if ((foo->bar & cpu_to_le32(BAR_MASK)) == cpu_to_le32(BAR_THIS << BAR_SHIFT))
instead of
	if (get_bar(foo) == BAR_THIS))
since that keeps shift and endianness conversion on the constant size.  The same goes
for
	if ((foo->bar ^ baz->bar) & cpu_to_le32(BAR_MASK))
instead of
	if (get_bar(foo) != get_bar(baz))
If would be nice if compiler had recognized that kind of stuff and transformed the
latter into the former on its own, but...

	* swab... is a Bloody Bad Idea(tm) in almost all situations.  Keeping track of
whether given data is little-endian or host-endian is much easier than keeping track of
how many times have we flipped it.

	* don't mix little-endian and host-endian in the same variable.  See the previous
point for the reasons - static typing is much safer and easier to reason about.  Code
doing
	n = cpu_to_le32(n);
is asking for trouble.  For local variables it's not even an optimization - compiler
is generally pretty good at spotting two local variables that are never live at the
same point and reusing memory.  And for anything non-local you are introducing a hidden
piece of state - "is that field in this structure little-endian or host-endian at the
moment?", making it very easy to screw up a few months down the road.  Brittle and
hell to debug...

	* one very common source of noise is cpu_to_le32() when le32_to_cpu() was
intended.  Sure, they do the same transformation on anything even remotely plausible
(something like V0 V2 V3 V1 is not a byte order likely to happen on any hardware),
but the choice documents what kind of values do you have before and after the
conversion.  Both the human readers and automated typechecking (sparse) have much
easier life if those are accurate.  Again, see the point re keeping track of the
number of flips vs. keeping track of what's host-endian and what's little-endian.
The latter is local, the former takes reasoning about control flow.

	* for situations like "use this le32 value as search key in binary tree",
where you are really OK with having differently-shaped trees on l-e and b-e hosts,
use something like
	if ((__force __u32) key > node->key)
preferably with a comment explaining why treating this value that way is OK.
