From: Greg <gvrose8192@gmail.com>
Subject: Re: [TSN RFC v2 0/9] TSN driver for the kernel
Date: Fri, 16 Dec 2016 10:12:44 -0800
Message-ID: <1481911964.3572.1.camel@gmail.com>
References: <1481911153-549-1-git-send-email-henrik@austad.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
        Richard Cochran <richardcochran@gmail.com>,
        Henrik Austad <haustad@cisco.com>, linux-media@vger.kernel.org,
        alsa-devel@vger.kernel.org, netdev@vger.kernel.org
To: henrik@austad.us
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481911153-549-1-git-send-email-henrik@austad.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-12-16 at 18:59 +0100, henrik@austad.us wrote:
> From: Henrik Austad <haustad@cisco.com>
> 
> 
> The driver is directed via ConfigFS as we need userspace to handle
> stream-reservation (MSRP), discovery and enumeration (IEEE 1722.1) and
> whatever other management is needed. This also includes running an
> appropriate PTP daemon (TSN favors gPTP).

I suggest using a generic netlink interface to communicate with the
driver to set up and/or configure your drivers.

I think configfs is frowned upon for network drivers.  YMMV.

- Greg

> 
> Once we have all the required attributes, we can create link using
> mkdir, and use write() to set the attributes. Once ready, specify the
> 'shim' (basically a thin wrapper between TSN and another subsystem) and
> we start pushing out frames.
> 
> The network part: it ties directly into the Rx-handler for receive and
> writes skb's using dev_queue_xmit(). This could probably be improved.
> 
> 2 new fields in netdev_ops have been introduced, and the Intel
> igb-driver has been updated (as this an AVB-capable NIC which is
> available as a PCI-e card).
> 
> What remains (tl;dr: a lot) a.k.a "Known problems" or "working on it!"
> - tie to (g)PTP properly, currently using ktime_get() for presentation
>   time
> - get time from shim into TSN
> - let shim create/manage buffer
> - redo parts of the link-stuff using RCUs, the current setup is a bit
>   clumsy.
> - The igb-driver does not work properly when compiled with IGB_TSN, some
>   details in setting the register values needs to be figured out. I am
>   working on this, but as it stands, the best bet is to load tsn using
>   in_debug=1 to bypass the capability-check. I have had e1000 and sky2
>   running for several days without crashing, igb crashes and burns
>   violently.
> - The ALSA driver does not handle multiple devices very well and is a
>   work in progress.
> 
> * v2: changes since v1
> 
> Changes since v1
> - updated to latest upstream kernel (v4.8)
> - set dedicated enabled-attribute and let shim be stored in own (support
>   future plan for enabling per-shim attributes)
> - fixed endianess issue in bitfields used in tsn-structs
> - Updated some of the trace-events to use trace_class
> - Fix various silly typos
> - Handle disabling of link from hrtimer a bit more gracefully (that
>   actually works-ish).
> - use old skb and size of skb when that is set (Reporte by Nikita)
> - Move PCP-codes to NIC and not in the link itself
> - Allow TSN-capable card to be loaded even when in debug-mode (and do
>   not enforce TSN behaviour)
> - Start hooking into ALSA's get_time_info hooks (very much incomplete)
> - use threads for sending frames, wake from hrtimer-callback.
>   This also queues up awaiting timers if we fail to complete the
>   transmit before another timer arrives, it will immediately execute
>   another iteration, so no events should be lost. That being said,
>   should this happen, it is a clear bug as we really should complete
>   well before the next interval.
> - Cleanup link-locking and differentiate between Talker and Listener (as
>   Listener grab link-lock from IRQ context)
> - Change list-lock to spinlock as we may need to take a link-lock whilst
>   holding the master list-lock.
> - Do a more careful dance holding the spinlocks to regions only doing
>   actual update.
> 
> Network driver (I210 only)
> - bring up all Tx-/Rx-queues when igb is in TSN-mode regardless of how
>   many CPUs the system has for I210
> - Correctly calculate the idle_slope in I210's configure hook
> - Update igb-driver with queue-select and return correct queue when
>   sending TSN-frames
> - add IGB_FLAG_QAV_PRIO flag to igb_adapter (to handle proper config of
>   tx-ring when adapter is brought up.
> - add TXDCTL logic (part of preparatory work for TSN) to igb-driver
> - Improve SR(A|B) accountingo
> 
> ALSA Shim
> - Allow userspace to grab much smaller chunks of data (down to a single
>   Class A frame for S16_LE 2ch 48kHz).
> - Create the card with index/id pattern to avoid collision with other
>   cards.
> * v1
> 
> Before reading on - this is not even beta, but I'd really appreciate if
> people would comment on the overall architecture and perhaps provide
> some pointers to where I should improve/fix/update
> - thanks!
> 
> This is a very early RFC for a TSN-driver in the kernel. It has been
> floating around in my repo for a while and I would appreciate some
> feedback on the overall design to avoid doing some major blunders.
> 
> There are at least one AVB-driver (the AV-part of TSN) in the kernel
> already. This driver aims to solve a wider scope as TSN can do much more
> than just audio. A very basic ALSA-driver is added to the end that
> allows you to play music between 2 machines using aplay in one end and
> arecord | aplay on the other (some fiddling required) We have plans for
> doing the same for v4l2 eventually (but there are other fishes to fry
> first). The same goes for a TSN_SOCK type approach as well.
> 
> Henrik Austad (9):
>   igb: add missing fields to TXDCTL-register
>   TSN: add documentation
>   TSN: Add the standard formerly known as AVB to the kernel
>   Adding TSN-driver to Intel I210 controller
>   Add TSN header for the driver
>   Add TSN machinery to drive the traffic from a shim over the network
>   Add TSN event-tracing
>   AVB ALSA - Add ALSA shim for TSN
>   MAINTAINERS: add TSN/AVB-entries
> 
>  Documentation/TSN/tsn.txt                    |  345 ++++++++
>  MAINTAINERS                                  |   14 +
>  drivers/media/Kconfig                        |   15 +
>  drivers/media/Makefile                       |    2 +-
>  drivers/media/avb/Makefile                   |    5 +
>  drivers/media/avb/avb_alsa.c                 |  793 +++++++++++++++++
>  drivers/media/avb/tsn_iec61883.h             |  152 ++++
>  drivers/net/ethernet/intel/Kconfig           |   18 +
>  drivers/net/ethernet/intel/igb/Makefile      |    2 +-
>  drivers/net/ethernet/intel/igb/e1000_82575.h |    4 +
>  drivers/net/ethernet/intel/igb/igb.h         |   26 +
>  drivers/net/ethernet/intel/igb/igb_main.c    |   39 +-
>  drivers/net/ethernet/intel/igb/igb_tsn.c     |  468 ++++++++++
>  include/linux/netdevice.h                    |   44 +
>  include/linux/tsn.h                          |  952 +++++++++++++++++++++
>  include/trace/events/tsn.h                   |  333 ++++++++
>  net/Kconfig                                  |    1 +
>  net/Makefile                                 |    1 +
>  net/tsn/Kconfig                              |   32 +
>  net/tsn/Makefile                             |    6 +
>  net/tsn/tsn_configfs.c                       |  673 +++++++++++++++
>  net/tsn/tsn_core.c                           | 1189 ++++++++++++++++++++++++++
>  net/tsn/tsn_header.c                         |  162 ++++
>  net/tsn/tsn_internal.h                       |  397 +++++++++
>  net/tsn/tsn_net.c                            |  392 +++++++++
>  25 files changed, 6061 insertions(+), 4 deletions(-)
>  create mode 100644 Documentation/TSN/tsn.txt
>  create mode 100644 drivers/media/avb/Makefile
>  create mode 100644 drivers/media/avb/avb_alsa.c
>  create mode 100644 drivers/media/avb/tsn_iec61883.h
>  create mode 100644 drivers/net/ethernet/intel/igb/igb_tsn.c
>  create mode 100644 include/linux/tsn.h
>  create mode 100644 include/trace/events/tsn.h
>  create mode 100644 net/tsn/Kconfig
>  create mode 100644 net/tsn/Makefile
>  create mode 100644 net/tsn/tsn_configfs.c
>  create mode 100644 net/tsn/tsn_core.c
>  create mode 100644 net/tsn/tsn_header.c
>  create mode 100644 net/tsn/tsn_internal.h
>  create mode 100644 net/tsn/tsn_net.c
> 
> --
> 2.7.4
