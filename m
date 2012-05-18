From: Samuel Thibault <samuel.thibault@ens-lyon.org>
Subject: e1000 rx emulation bug (Was: [PATCH] e1000: Reset rx
 ring index on receive overrun)
Date: Fri, 18 May 2012 15:51:37 +0200
Message-ID: <20120518135136.GV683@type.famille.thibault.fr>
References: <20120517230140.GZ683@type.famille.thibault.fr>
	<061C8A8601E8EE4CA8D8FD6990CEA891188439E0@ORSMSX102.amr.corp.intel.com>
	<20120517232821.GJ683@type.famille.thibault.fr>
	<20120517233124.GK683@type.famille.thibault.fr>
	<alpine.WNT.2.00.1205171702590.7900@jbrandeb-mobl2.amr.corp.intel.com>
	<20120518001202.GN683@type.famille.thibault.fr>
	<alpine.WNT.2.00.1205171718160.7900@jbrandeb-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	Dean Nelson <dnelson@redhat.com>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, "Ronciak,
	John" <john.ronciak@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, qemu-devel@nongnu.org,
	dlaor@redhat.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <alpine.WNT.2.00.1205171718160.7900@jbrandeb-mobl2.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hello,

There seems to be a bug in qemu in the e1000 emulation, which triggers
an issue with the Linux driver.

What happens in Linux is the following:

- e1000_open 
  - e1000_configure
    - e1000_setup_rctl
      - enables E1000_RCTL_EN
    - e1000_configure_rx
      - sets RDT/RDH to 0
    - alloc_rx_buf
      - pushes buffers to the ring

with bad luck, or on high traffic of small packets, what is observed is
that between setting RDT/RDH and pushing buffers, the ring fills up in
qemu. Here is what happens there on the qemu side:

- e1000_receive
  - e1000_has_rxbufs
    - total_size <= s->rxbuf_size (because it's small)
      return s->mac_reg[RDH] != s->mac_reg[RDT] || !s->check_rxov;

although RDH == RDT == 0, it returns 1, because since RDT/RDH have
just been set to 0, set_rdt has cleared check_rxov. e1000_receive
thus believes there is room, and proceeds with filling the ring.
Unfortunately, since no buffer was pushed, desc.buffer_addr is NULL, and
thus the do loop skips all these nul rx descriptors of the ring, but
marking each of them with E1000_RXD_STAT_DD, and eventually wrapping
around.  From then on, since check_rxov has been set by the do loop,
nothing more is pushed, until the linux driver pushes buffers to the
ring. qemu can then fill some descriptors, and Linux read them, but
since the whole ring was filled with E1000_RXD_STAT_DD, Linux goes on
reading, and thus gets completely desynchronized with the device.

That raises two questions:

- what is the role of the check_rxov flag?  Is hardware really allowed
  to push in some cases, even when RDH==RDT?  Removing it makes things
  work just fine.
- BTW, when skipping a descriptor because of NULL address, does
  E1000_RXD_STAT_DD have to be set?

Samuel

------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
