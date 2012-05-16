From: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [RFC 00/13] USB 3.0 Link Power Management (LPM)
	support
Date: Wed, 16 May 2012 14:54:57 -0700
Message-ID: <cover.1337203535.git.sarah.a.sharp@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Petko Manolov <petkan-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>, users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org,
	Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>, Oliver Neukum <oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org>,
	Hansjoerg Lipp <hjlipp-S0/GAf8tV78@public.gmane.org>, Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>,
	Vasanthakumar Thiagarajan <vthiagar-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Roland Vossen <rvossen-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Jouni Malinen <jouni-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>, Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	Herton Ronaldo Krzesinski <herton-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>, Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	gigaset307x-common@li
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <http://rt2x00.serialmonkey.com/mailman/options/users_rt2x00.serialmonkey.com>,
	<mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=unsubscribe>
List-Archive: <http://rt2x00.serialmonkey.com/pipermail/users_rt2x00.serialmonkey.com>
List-Post: <mailto:users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
List-Help: <mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=help>
List-Subscribe: <http://rt2x00.serialmonkey.com/mailman/listinfo/users_rt2x00.serialmonkey.com>,
	<mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=subscribe>
Errors-To: users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org
Sender: users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org
List-Id: netdev.vger.kernel.org

The USB 3.0 bus specification added a new (optional) low power mechanism
called Link Power Management (LPM).  This mechanism takes advantage of
the fact that USB 3.0 packets are routed, not broadcast across the bus.
It does not help *at all* with USB 2.0 devices.

The idea is that when links between a parent hub and a child hub/device
become idle, they should be put into a lower power state.  When a USB
device goes into this lower power state, it may shut down PLLs or other
circuitry, since it knows it won't receive any transfers until its link
is driven into the active link state (U0).  Isochronous time stamp
packets are also not routed to links in a lower power state.  This
should (theoretically) save power.

There are two lower power link states, U1 and U2.  Each USB device
advertises the amount of time that it will take to power up and come
back to U0, in the U1/U2 Device Exit Latency values in the SuperSpeed
BOS descriptor.  Hubs may also incur an exit latency to bring a
downstream link into U0.  U2 is supposed to provide the deepest power
savings, but it will also have the highest exit latency.

Either a USB device or a parent hub can request that the link go into U1
or U2.  Hubs will only initiate U1 or U2 after the link has been idle
for a software-programmed timeout.

It may not make sense to enable hub-initiated LPM for communications
devices.  These types of devices often exist to send data to the host,
and the device usually knows when a transfer is likely to occur.  So
these devices should know when to enable device-initiated LPM.  On the
other hand, we don't want to introduce any latency for these devices, so
enabling hub-initiated LPM may not make sense.

Introduce a new usb_driver flag to disable hub-initiated USB 3.0 LPM,
and set it for all communications USB drivers.  Let me know if I've
missed any ones.

The policy for how to set the hub-initiated U1/U2 idle timeouts is very
host specific.  It depends on many factors, including endpoint types,
how many hub tiers are between the device and host, and some obscure
knowledge of the hardware's internal bus schedule policy.  Introduce
some new xHCI infrastructure, so that xHCI host vendors can add
functions to implement their own timeout policies.

The only U1/U2 timeout policy I know of is for the Intel xHCI host
controller.  I've tried to make the patchset as host-agnostic as
possible, and there's only about 100 lines of Intel-specific code in the
second to last patch.

This patchset still needs a bit of polish, but the code is stable.  I
need to retest it since refactoring the code a bit, but I think it's
ready for review.

I have verified with a USB 3.0 bus analyzer that the TI USB 3.0 hub
prototype I have does go into U1 and U2 at the request of the xHCI host
after the U1/U2 timeouts expire.  I see the host (or device, it's hard
to tell which on the Lecroy I have) send an LGO_U1 and the partner
respond with an LAU (link accept).

Unfortunately, there aren't very many other devices that do go into U1
or U2.  They don't break, in any obvious way, but when they are sent an
LGO_U1 or LGO_U2, they always refuse by sending an LXU (link reject).


The following changes since commit 87f0194060c191f4149193833636f4fec52cdfd1:

  xhci: Reset reserved command ring TRBs on cleanup. (2012-05-10 10:13:37 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/sarah/xhci.git lpm-usb3-v7

for you to fetch changes up to 3c634afbbe15598cdcbf77bb9393d22ad4bfa373:

  USB: Disable hub-initiated LPM for comms devices. (2012-05-16 14:23:40 -0700)

----------------------------------------------------------------
Sarah Sharp (13):
      xhci: Add roothub code to set U1/U2 timeouts.
      USB: Make sure to fetch the BOS desc for roothubs.
      USB: Refactor code to set LPM support flag.
      USB: Calculate USB 3.0 exit latencies for LPM.
      USB: Allow drivers to disable hub-initiated LPM.
      USB: Add support to enable/disable USB3 link states.
      USB: Disable USB 3.0 LPM in critical sections.
      xhci: Some Evaluate Context commands must succeed.
      xhci: Reserve one command for USB3 LPM disable.
      USB: Add macros for interrupt endpoint types.
      xhci: Add infrastructure for host-specific LPM policies.
      xhci: Add Intel U1/U2 timeout policy.
      USB: Disable hub-initiated LPM for comms devices.

 drivers/bluetooth/ath3k.c                     |    1 +
 drivers/bluetooth/bcm203x.c                   |    1 +
 drivers/bluetooth/bfusb.c                     |    1 +
 drivers/bluetooth/bpa10x.c                    |    1 +
 drivers/bluetooth/btusb.c                     |    1 +
 drivers/isdn/gigaset/bas-gigaset.c            |    1 +
 drivers/isdn/gigaset/usb-gigaset.c            |    1 +
 drivers/isdn/hardware/mISDN/hfcsusb.c         |    1 +
 drivers/isdn/hisax/hfc_usb.c                  |    1 +
 drivers/isdn/hisax/st5481_init.c              |    1 +
 drivers/net/usb/asix.c                        |    1 +
 drivers/net/usb/catc.c                        |    1 +
 drivers/net/usb/cdc-phonet.c                  |    1 +
 drivers/net/usb/cdc_eem.c                     |    1 +
 drivers/net/usb/cdc_ether.c                   |    1 +
 drivers/net/usb/cdc_ncm.c                     |    1 +
 drivers/net/usb/cdc_subset.c                  |    1 +
 drivers/net/usb/cx82310_eth.c                 |    1 +
 drivers/net/usb/dm9601.c                      |    1 +
 drivers/net/usb/gl620a.c                      |    1 +
 drivers/net/usb/hso.c                         |    1 +
 drivers/net/usb/int51x1.c                     |    1 +
 drivers/net/usb/ipheth.c                      |    1 +
 drivers/net/usb/kalmia.c                      |    3 +-
 drivers/net/usb/kaweth.c                      |    1 +
 drivers/net/usb/lg-vl600.c                    |    1 +
 drivers/net/usb/mcs7830.c                     |    1 +
 drivers/net/usb/net1080.c                     |    1 +
 drivers/net/usb/pegasus.c                     |    1 +
 drivers/net/usb/plusb.c                       |    1 +
 drivers/net/usb/qmi_wwan.c                    |    1 +
 drivers/net/usb/rndis_host.c                  |    1 +
 drivers/net/usb/rtl8150.c                     |    3 +-
 drivers/net/usb/sierra_net.c                  |    1 +
 drivers/net/usb/smsc75xx.c                    |    1 +
 drivers/net/usb/smsc95xx.c                    |    1 +
 drivers/net/usb/zaurus.c                      |    1 +
 drivers/net/wireless/at76c50x-usb.c           |    1 +
 drivers/net/wireless/ath/ath6kl/usb.c         |    1 +
 drivers/net/wireless/ath/ath9k/hif_usb.c      |    1 +
 drivers/net/wireless/ath/carl9170/usb.c       |    1 +
 drivers/net/wireless/brcm80211/brcmfmac/usb.c |    1 +
 drivers/net/wireless/libertas/if_usb.c        |    1 +
 drivers/net/wireless/libertas_tf/if_usb.c     |    1 +
 drivers/net/wireless/orinoco/orinoco_usb.c    |    1 +
 drivers/net/wireless/p54/p54usb.c             |    1 +
 drivers/net/wireless/rndis_wlan.c             |    1 +
 drivers/net/wireless/rt2x00/rt2500usb.c       |    1 +
 drivers/net/wireless/rt2x00/rt2800usb.c       |    1 +
 drivers/net/wireless/rt2x00/rt73usb.c         |    1 +
 drivers/net/wireless/rtl818x/rtl8187/dev.c    |    1 +
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c   |    1 +
 drivers/net/wireless/zd1201.c                 |    1 +
 drivers/net/wireless/zd1211rw/zd_usb.c        |    1 +
 drivers/usb/class/cdc-acm.c                   |    1 +
 drivers/usb/class/cdc-wdm.c                   |    1 +
 drivers/usb/core/driver.c                     |   71 +++
 drivers/usb/core/hcd.c                        |    9 +
 drivers/usb/core/hub.c                        |  629 ++++++++++++++++++++++++-
 drivers/usb/core/message.c                    |   47 ++
 drivers/usb/host/xhci-hub.c                   |   19 +
 drivers/usb/host/xhci-mem.c                   |   12 +
 drivers/usb/host/xhci-pci.c                   |   13 +
 drivers/usb/host/xhci-ring.c                  |    4 +-
 drivers/usb/host/xhci.c                       |  454 ++++++++++++++++++-
 drivers/usb/host/xhci.h                       |   14 +-
 include/linux/usb.h                           |   50 ++
 include/linux/usb/ch11.h                      |    2 +
 include/linux/usb/ch9.h                       |   56 +++
 include/linux/usb/hcd.h                       |    9 +
 70 files changed, 1440 insertions(+), 9 deletions(-)
