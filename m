From: Dean Nelson <dnelson@redhat.com>
Subject: [PATCH net-next-2.6] e1000: don't enable dma receives until after dma address has been setup
Date: Wed, 14 Sep 2011 20:31:38 -0400
Message-ID: <20110915003138.4279.19020.email-sent-by-dnelson@localhost6.localdomain6>
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44494 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751519Ab1IOAbl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Sep 2011 20:31:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Doing an 'ifconfig ethN down' followed by an 'ifconfig ethN up' on a qemu-kvm
guest system configured with two e1000 NICs can result in an 'unable to handle
kernel paging request at 0000000100000000' or 'bad page map in process ...' or
something similar.

These result from a 4096-byte page being corrupted with the following two-word
pattern (16-bytes) repeated throughout the entire page:

  0x0000000000000000
  0x0000000100000000

There can be other bits set as well. What is a constant is that the 2nd word
has the 32nd bit set. So one could see:

        :
  0x0000000000000000
  0x0000000100000000
  0x0000000000000000
  0x0000000172adc067    <<< bad pte
  0x800000006ec60067
  0x0000000700000040
  0x0000000000000000
  0x0000000100000000
        :

Which came from from a process' page table I dumped out when the marked line
was seen as bad by print_bad_pte().

The repeating pattern represents the e1000's two-word receive descriptor:

struct e1000_rx_desc {
        __le64 buffer_addr;   /* Address of the descriptor's data buffer */
        __le16 length;        /* Length of data DMAed into data buffer */
        __le16 csum;          /* Packet checksum */
        u8 status;            /* Descriptor status */
        u8 errors;            /* Descriptor Errors */
        __le16 special;
};

And the 32nd bit of the 2nd word maps to the 'u8 status' member, and
corresponds to E1000_RXD_STAT_DD which indicates the descriptor is done.

The corruption appears to result from the following...

 . An 'ifconfig ethN down' gets us into e1000_close(), which through a number
   of subfunctions results in:
     1. E1000_RCTL_EN being cleared in RCTL register.  [e1000_down()]
     2. dma_free_coherent() being called.  [e1000_free_rx_resources()]

 . An 'ifconfig ethN up' gets us into e1000_open(), which through a number of
   subfunctions results in:
     1. dma_alloc_coherent() being called.  [e1000_setup_rx_resources()]
     2. E1000_RCTL_EN being set in RCTL register.  [e1000_setup_rctl()]
     3. E1000_RCTL_EN being cleared in RCTL register.  [e1000_configure_rx()]
     4. RDLEN, RDBAH and RDBAL registers being set to reflect the dma page
        allocated in step 1.  [e1000_configure_rx()]
     5. E1000_RCTL_EN being set in RCTL register.  [e1000_configure_rx()]

During the 'ifconfig ethN up' there is a window opened, starting in step 2
where the receives are enabled up until they are disabled in step 3, in which
the address of the receive descriptor dma page known by the NIC is still the
previous one which was freed during the 'ifconfig ethN down'. If this memory
has been reallocated for some other use and the NIC feels so inclined, it will
write to that former dma page with predictably unpleasant results.

I realize that in the guest, we're dealing with an e1000 NIC that is software
emulated by qemu-kvm. The problem doesn't appear to occur on bare-metal. Andy
suspects that this is because in the emulator link-up is essentially instant
and traffic can start flowing immediately. Whereas on bare-metal, link-up
usually seems to take at least a few milliseconds. And this might be enough
to prevent traffic from flowing into the device inside the window where
E1000_RCTL_EN is set.

So perhaps a modification needs to be made to the qemu-kvm e1000 NIC emulator
to delay the link-up. But in defense of the emulator, it seems like a bad idea
to enable dma operations before the address of the memory to be involved has
been made known.

The following patch no longer enables receives in e1000_setup_rctl() but leaves
them however they were. It only enables receives in e1000_configure_rx(), and
only after the dma address has been made known to the hardware.

There are two places where e1000_setup_rctl() gets called. The one in
e1000_configure() is followed immediately by a call to e1000_configure_rx(), so
there's really no change functionally (except for the removal of the problem
window. The other is in __e1000_shutdown() and is not followed by a call to
e1000_configure_rx(), so there is a change functionally. But consider...

 . An 'ifconfig ethN down' (just as described above).

 . A 'suspend' of the system, which (I'm assuming) will find its way into
   e1000_suspend() which calls __e1000_shutdown() resulting in:
     1. E1000_RCTL_EN being set in RCTL register.  [e1000_setup_rctl()]

And again we've re-opened the problem window for some unknown amount of time.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Dean Nelson <dnelson@redhat.com>

---
The patch below is Andy's version of a patch I came up with to address this
problem. I liked his version better. Functionally there was no difference
between the two.

Running my version of the patch, the reproducer (see script below) ran for 5
days without issue before I stopped it. Without the patch, former dma pages
were corrupted in a very short timeframe and fairly frequently (relatively
speaking). Note that I'm also running with a debug patch that after step 5 has
completed (mentioned above under an 'ifconfig ethN up'...), the previous dma
page is scanned to see if it had been 'corrupted'. So I found a higher
percentage of occurrences then one would find if one waits for a kernel BUG.

The reproducer for this problem is:
cat > reproducer.sh <<EOF
#!/bin/bash
typeset -i i=0
echo eth1:down
ifconfig eth1 down
sleep 2
while :; do
  i=$i+1
  ifconfig eth0 down& ifconfig eth1 up&
  echo "$i | eth0:down eth1:up"
  wait
  sleep 2
  ifconfig eth0 up& ifconfig eth1 down&
  echo "$i | eth0:up eth1:down"
  wait
  sleep 2
done
EOF

The e1000e looks to have the same issue. I don't know about igb. But I'm not
aware of either having hardware emulation in qemu-kvm. So unless this issue is
reproducible on bare-metal... it's probably not a big deal for them.

 drivers/net/ethernet/intel/e1000/e1000_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 4a32c15..cd26a0a 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1814,8 +1814,8 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 
 	rctl &= ~(3 << E1000_RCTL_MO_SHIFT);
 
-	rctl |= E1000_RCTL_EN | E1000_RCTL_BAM |
-		E1000_RCTL_LBM_NO | E1000_RCTL_RDMTS_HALF |
+	rctl |= E1000_RCTL_BAM | E1000_RCTL_LBM_NO |
+		E1000_RCTL_RDMTS_HALF |
 		(hw->mc_filter_type << E1000_RCTL_MO_SHIFT);
 
 	if (hw->tbi_compatibility_on == 1)
@@ -1917,7 +1917,7 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	}
 
 	/* Enable Receives */
-	ew32(RCTL, rctl);
+	ew32(RCTL, rctl | E1000_RCTL_EN);
 }
 
 /**
