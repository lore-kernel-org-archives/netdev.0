From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: commit 16ecba59 breaks 82574L under heavy load.
Date: Tue, 18 Jul 2017 10:21:09 -0400
Message-ID: <20170718142109.GO18556@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Len Sorensen <lsorense@csclub.uwaterloo.ca>,
        netdev@vger.kernel.org, Benjamin Poirier <bpoirier@suse.com>,
        intel-wired-lan@lists.osuosl.org,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 16ecba59bc333d6282ee057fb02339f77a880beb has apparently broken
at least the 82574L under heavy load (as in load heavy enough to cause
packet drops).  In this case, when running in MSI-X mode, the Other
Causes interrupt fires about 3000 times per second, but not due to link
state changes.  Unfortunately this commit changed the driver to assume
that the Other Causes interrupt can only mean link state change and
hence sets the flag that (unfortunately) means both link is down and link
state should be checked.  Since this now happens 3000 times per second,
the chances of it happening while the watchdog_task is checking the link
state becomes pretty high, and it if does happen to coincice, then the
watchdog_task will reset the adapter, which causes a real loss of link.

Reverting the commit makes everything work fine again (of course packets
are still dropped, but at least the link stays up, the adapter isn't
reset, and most packets make it through).

I tried checking what the bits in the ICR actually were under these
conditions, and it would appear that the only bit set is 24 (the Other
Causes interrupt bit).  So I don't know what the real cause is although
rx buffer overrun would be my guess, and in fact I see nothing in the
datasheet indicating that you can actually disable the rx buffer overrun
from generating an interrupt.

Prior to this commit, the interrupt handler explicitly checked that the
interrupt was caused by a link state change and only then did it trigger
a recheck which worked fine and did not cause incorrect adapter resets,
although it of course still had lots of undesired interrupts to deal with.

Of course ideally there would be a way to make these 3000 pointless
interrupts per second not happen, but unless there is a way to determine
that, I think this commit needs reverting, since it apparently causes
link failures on actual hardware that exists.

The ports are onboard intel 82574L on a Supermicro X7SPA-HF-D525 with
1.2a BIOS (upgrading to 1.2b to check if it makes a difference is not
an option unfortunately).

-- 
Len Sorensen
