From: Jeff Garzik <jgarzik@pobox.com>
Subject: netdev4 posted
Date: Tue, 13 Jan 2004 18:16:42 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40047C5A.3090604@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060909000208080600020605"
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060909000208080600020605
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


Key e100 fix, that possibly wants fixing in eepro100 too.

Patch:
http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/2.6.1-bk1-netdev4.patch.bz2

Full changelog:
http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/2.6.1-bk1-netdev4.log

Broken out:
http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/broken-out/

Changelog delta attached.


--------------060909000208080600020605
Content-Type: text/plain;
 name="changelog.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="changelog.txt"

ChangeSet@1.1510.9.19, 2004-01-13 16:43:24-05:00, romieu@fr.zoreil.com
  [netdrvr r8169] fix phy initialization loop init

ChangeSet@1.1510.8.7, 2004-01-13 15:30:03-05:00, scott.feldman@intel.com
  [netdrvr e100] copyright + trailing blanks + misc
  
  * Misc: 2004 copyright, remove trailing white space, remove some
    unused symbols.

ChangeSet@1.1510.8.6, 2004-01-13 15:29:55-05:00, scott.feldman@intel.com
  [netdrvr e100] fix slab corruption
  
  * Addresses two problems, both resulting in slab corruption: 1)
    driver indicating skb while HW is still DMA'ing (ouch!), 2)
    driver not stopping receiver activity before downing i/f.
    Fix is 1) wait for RNR (receiver-no-resources) interrupt
    before restarting receiver, 2) reseting HW to stop receiver
    before stopping i/f.
  
  This issue was also reproducible with eepro100.  You need to turn off
  the copybreak, and reduce the number of descriptors to 4.  Then bang on
  it with pktgen with 60-byte packets, with slab debugging enabled.
  
  For e100-3.0.x, the issue was a lot easier to reproduce with NAPI,
  because NAPI polls independently of where the HW is at, so it's easier
  for us to catch HW in the middle of finishing off the last Rx (as
  it runs out of resources) and asking HW if it's idle.  Checking the
  RU status is not-reliable!  That's the problem, and the mistake both
  eepro100 and e100-3.0.x were making.
  
  The solution is rely on RNR interrupts as the only indicator that HW is
  truly done, and then we're ready to restart the RU.  We should only get
  RNR interrupts when we overrun the Rx ring.  With NAPI, if the ring is
  overrun, we'll post RNR, but not restart the RU until we're out of
  polling.  Without NAPI, we'll restart the RU as soon as we get RNR.
  
  I ran some 24-hour tests with and without NAPI (with 4 descriptors)
  and didn't get any corruption.  Prior to this patch, I would get many
  errors about slab corruption.
  
  Also, the patch is larger than you might expect, but I initially thought
  I was doing something wrong with managing the <list.h> ring, so I that
  code using old fashion double-link list.  The ring management wasn't the
  problem, after all, but I prefer the old-fashion d-link implementation
  as it's easier to read.


--------------060909000208080600020605--
