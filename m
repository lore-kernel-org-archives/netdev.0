From: Richard Weinberger <richard@nod.at>
Subject: bridge-utils: wrong sysfs path odds
Date: Wed, 25 Nov 2015 01:15:15 +0100
Message-ID: <5654FD93.1070706@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Ralf Baechle <ralf@linux-mips.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	manty@debian.org
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.ns.miles-group.at ([95.130.255.143]:11949 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755455AbbKYAPT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 19:15:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Today I was hunting down an issue where "brctl stp br0 off"
always failed on mips64be with n32 userland.

It turned out that the ioctl(fd, SIOCDEVPRIVATE, &ifr) with BRCTL_SET_BRIDGE_STP_STATE
returned -EOPNOTSUPP.
First I thought that this is a plain ABI issue on mips as in old_dev_ioctl()
the ioctl() argument was 0x1 instead of the expected BRCTL_SET_BRIDGE_STP_STATE (0x14)

Further investigation showed that brctl first tries to open the sysfs file
"/sys/class/net/br0/stp_state" and falls back to the legacy ioctl() upon failure.

On my mips setup old_dev_ioctl() seems not to work. And the function's comment
is correct:
/*
 * Legacy ioctl's through SIOCDEVPRIVATE
 * This interface is deprecated because it was too difficult to
 * to do the translation for 32/64bit ioctl compatibility.
 */

Later I've realized that the sysfs path is wrong, the "bridge/" directory
part is missing.
On most setups nobody would notice as the fallback ioctl() works.

Debian's bridge-utils package carries a patch which fixes the sysfs paths.
Can we please have this patch also in upstream bridge-utils?

Thanks,
//richard
