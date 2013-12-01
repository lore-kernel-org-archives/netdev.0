From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [B.A.T.M.A.N.] [PATCH] Fix ARM BUILD_BUG_ON() errors with
	batman-adv
Date: Sun, 1 Dec 2013 17:13:09 +0000
Message-ID: <20131201171309.GD16735@n2100.arm.linux.org.uk>
References: <20131130191553.GA16735@n2100.arm.linux.org.uk> <529A46C4.9090906@meshcoding.com> <20131130230518.GC16735@n2100.arm.linux.org.uk> <529A8276.9060002@meshcoding.com> <529B47AA.8060403@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: The list for a Better Approach To Mobile Ad-hoc
	 Networking <b.a.t.m.a.n@lists.open-mesh.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Antonio Quartulli <antonio@meshcoding.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:43775 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035Ab3LARNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Dec 2013 12:13:25 -0500
Content-Disposition: inline
In-Reply-To: <529B47AA.8060403@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 01, 2013 at 03:28:58PM +0100, Antonio Quartulli wrote:
> On 01/12/13 01:27, Antonio Quartulli wrote:
> > On 01/12/13 00:05, Russell King - ARM Linux wrote:
> >> On Sat, Nov 30, 2013 at 09:12:52PM +0100, Antonio Quartulli 
> >> wrote:
> >>> I don't know the ARM architecture at all (I don't know if the 
> >>> other batman-adv developers do), so could you please provide 
> >>> here some more details about why that static check is failing? 
> >>> We would like to address this issue differently rather than 
> >>> re-adding the __packed attribute.
> > 
> >> The reason is this struct becomes a size of 4 bytes, even though 
> >> it only contains three uint8_t members.  This offsets the
> >> members of all structs that this struct is embedded in.
> > 
> >> If you don't wish to fix this, then please make your subsystem 
> >> depend on !ARM because it's otherwise impossible to fix and can 
> >> never work on ARM.
> > 
> > 
> > I'd like to fix this.
> > 
> > Actually I can't really understand your explanation: struct 
> > batadv_header is always used inside another parent structure and 
> > the latter always has a uint8_t following the batadv_header, thus 
> > filling that gap and aligning it to 4bytes. I think this is also 
> > why we don't get this compiler error on any other architecture. Or 
> > am I missing something?
> > 
> > I'll install a toolchain for ARM and I'll try to inspect it
> > better. If we have to make a change we should do it before 3.13 is
> > release since this change could possibly alter the packet layout.
> > 
> > 
> 
> It looks like that the ARM compiler cannot pack the structures properly.

This is not a compiler bug.  This is a bug in how you understand the C
specifications.

> we have the compiler saying that offset_of dest in struct
> batadv_unicast_packet is 5.

Correct.

> This means that struct batadv_header is padded to 4 bytes even if it
> is enclosed in struct batadv_unicast_packet and a proper 1byte member
> is put right after it.
> 
> Am I wrong or this is a problem in the ARM compiler not doing the
> right assumption? On x86 and x86_64 offset_of dest is 4, as expected.

The C standards allow implementations to pad structures as they see fit
for performance reasons.  The only thing which C guarantees is that the
order of the structure members are specified.  Padding is allowed to be
added between members and at the end of the structure.

The ARM compilers have for the last 20 years always aligned the size of
structs to a multiple of 32 bits to ensure that members following a
structure are appropriately aligned.

Changing this behaviour is completely out of the question: that would
be similar to asking for the x86 compiler to change the way it lays out
its structures.

The only solutions are: use the GCC packed attribute, redesign the
structures, or just accept that it won't ever be usable on ARM.

Frankly, I don't care about having this protocol working on ARM.  My
report was just because it was found by one of my randconfig builds.
I've learned my lesson now - don't report bugs...
