From: David Dillow <dave@thedillows.org>
Subject: [RFC BK 0/22] xfrm offload v2: Add hardware assist for IPSEC crypto
Date: Mon, 10 Jan 2005 10:36:58 -0500
Message-ID: <20040110014300.01@ori.thedillows.org>
Cc: dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The following patch set adds hardware offload of the crypto operations for
IPv4 IPSEC processing. It gives a noticible speedup on my (admittedly older)
hardware, but given the recent numbers posted, can be a speedup even for
more recent hardware.

There are a few known issues with the current patchset, but I think it is
ready for wider review. This version incorporates a few comments from the
mailing lists, and removes GFP_ATOMIC allocations.

* Only the 3Com 3CR990 family of NICs are supported. I don't have hardware
	or documentation for the Intel cards.
* Doesn't do IPv6. Need someone to implement map_direction(), and
	AH/ESP handling, as well as come up with a card that supports it.
* linux/skbuff.h cannot include net/xfrm.h currently, so there are
	redundant defines (requires some header cleanup, which I'm not
	very inclined to tackle at the moment.)
* TCP Segmentation offload seems broken by firmware 03.001.008. It could be
	my changes to support the offload, but that seems unlikely. I will
	have to investigate this.
* Latency suffers somewhat on smaller packets, it may be advisable to have
	a minimum packet size to offload.
* No real feedback on which xfrm_states have been offloaded or not.
* No individual control over which xfrm_states are allowed to be offloaded.

The patch set will be sent as follow-ups to this post, or is available via:

	bk pull http://typhoon.bkbits.net/ipsec-2.6

If you have pulled from there before, you will need to reclone, as the
repository has been recreated.

It will update the following files:

 Documentation/networking/netdevices.txt |   16 
 drivers/net/typhoon.c                   |  720 +++++++++++++++++++++++++++++++-
 drivers/net/typhoon.h                   |   38 +
 include/linux/ethtool.h                 |    8 
 include/linux/netdevice.h               |   10 
 include/linux/skbuff.h                  |   55 ++
 include/net/dst.h                       |    2 
 include/net/xfrm.h                      |  102 ++++
 net/core/ethtool.c                      |   54 ++
 net/core/skbuff.c                       |   31 +
 net/ipv4/ah4.c                          |   99 ++--
 net/ipv4/esp4.c                         |  102 ++--
 net/ipv4/xfrm4_state.c                  |    9 
 net/ipv6/xfrm6_state.c                  |   10 
 net/xfrm/xfrm_export.c                  |    4 
 net/xfrm/xfrm_policy.c                  |   85 +++
 net/xfrm/xfrm_state.c                   |   99 ++++
 17 files changed, 1329 insertions(+), 115 deletions(-)

If you work from the mailed patches, you will want the netdev-2.6 updates
to the typhoon driver, as the 3CR990B series needs the newest firmware to
correctly offload IPSEC processing. That patch is available from

http://www.thedillows.org/typhoon-netdev-2.6.patch.bz2


The following results were generated using a dual processor PIII 1GHz/512MB
with a 3CR990SVR97 (ori) and an Athlon 550 MHz/256MB with a 3CR990B (tank).
Latency testing was performed with lmbench's lat_tcp, and bandwith testing
was performed with Andrew Morton's zcc/zcs/cyclesoak. I ran the tests
multiple times, and picked the median results to report. There was not much
deviation in the results (+/- 1.5 us +/- 50KBytes/s +/- 1.5% CPU usage).


TCP Latency tests (1 byte msg)

Config					Latency
No IPSEC				196 us
AH/SHA1 (sw)				256 us
AH/SHA1 (hw)				317 us
ESP/3DES,SHA1 (sw)			333 us
ESP/3DES,SHA1 (hw)			347 us
ESP-AH/3DES,SHA1-SHA1 (sw)		387 us
ESP-AH/3DES,SHA1-SHA1 (hw)		467 us

TCP Latency tests (1024 byte msg)

Config					Latency
No IPSEC				625 us
AH/SHA1 (sw)				771 us
AH/SHA1 (hw)				858 us
ESP/3DES,SHA1 (sw)			1999 us
ESP/3DES,SHA1 (hw)			902 us
ESP-AH/3DES,SHA1-SHA1 (sw)		2140 us
ESP-AH/3DES,SHA1-SHA1 (hw)		1131 us

Bandwidth tests

Config (sender -> receiver)		Bandwidth	ori CPU	  tank CPU
No IPSEC (tank->ori)			11494 KB/s	11.9%	  18.7%
No IPSEC (ori->tank)			11492 KB/s	9.5%	  34.3%

AH/SHA1 (sw) (tank->ori)		11303 KB/s	29.2%	  79.3%
AH/SHA1 (sw) (ori->tank)		11302 KB/s	28.6%	  91.1%
ESP/3DES,SHA1 (sw) (tank->ori)		2130 KB/s	29.6%	  100%
ESP/3DES,SHA1 (sw) (ori->tank)		2263 KB/s	29.3%	  99.7%
ESP-AH/3DES,SHA1-SHA1 (sw) (tank->ori)	1906 KB/s	29.1%	  100%
ESP-AH/3DES,SHA1-SHA1 (sw) (ori->tank)	2051 KB/s	29.3%	  99.7%

AH/SHA1 (hw) (tank->ori)		11303 KB/s	14.0%	  30.2%
AH/SHA1 (hw) (ori->tank)		11301 KB/s	14.1%	  39.8%
ESP/3DES,SHA1 (hw) (tank->ori)		11221 KB/s	15.4%	  44.9%
ESP/3DES,SHA1 (hw) (ori->tank)		11220 KB/s	21.5%	  48.1%
ESP-AH/3DES,SHA1-SHA1 (hw) (tank->ori)	5920 KB/s	10.8%	  35.9%
ESP-AH/3DES,SHA1-SHA1 (hw) (ori->tank)	7189 KB/s	14.3%	  35.4%


The last line seems suspicious, and should probably be retested.
