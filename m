From: Peter Chubb <peterc@gelato.unsw.edu.au>
Subject: Making the NS83820 usable on IA64
Date: Wed, 17 Mar 2004 14:57:36 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16471.52400.222262.824746@wombat.disy.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-ia64@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi Folks, 

With the current NS83820 driver and IP stack implementation,
the IA64 kernel spends 99.9% of its time in the unaligned access trap
handler when the network starts getting busy.  When I raised this
issue before, the idea of realigning the skbuf data in the driver was
scouted; therefore I submit this patch for your approval.  It makes
the driver usable, and doesn't seem to affect anything else.

The idea is to tell gcc that the IP header is 2-byte aligned,
so it can generate the right code to access it.  Otherwise, it tries
to do a 4-byte load when trying to extract the header length bitfield,
which traps.  As far as I read the C standard, gcc can do almost
whatever it wants as regarding the alignment and underlying storage
size of a bitfield, so it's free to assume 32-bit alignment if it
wants.

Tested on McKinley with gcc 3.3.x


===== linus-2.6.4/include/linux/ip.h 1.12 vs edited =====
--- 1.12/include/linux/ip.h	Fri Jan  2 07:28:33 2004
+++ edited/include/linux/ip.h	Wed Mar 17 11:58:09 2004
@@ -186,7 +186,7 @@
 	__u32	saddr;
 	__u32	daddr;
 	/*The options start here. */
-};
+} __attribute__((packed,aligned(2)));
 
 struct ip_auth_hdr {
 	__u8  nexthdr;


--
Dr Peter Chubb     http://www.gelato.unsw.edu.au  peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories,   all slightly different.
