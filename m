From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 00/40] net: fec: cleanup/fixes
Date: Thu, 28 Jan 2016 14:25:24 -0700
Message-ID: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35381 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675AbcA1V2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:09 -0500
Received: by mail-pa0-f50.google.com with SMTP id ho8so29137344pac.2
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The testing for this series was done on a nitrogen6x.
The base commit was
commit 7a26019fdecdb45ff784ae4e3b7e0cc9045100ca
    Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net

Testing used imx_v6_v7_defconfig + CONFIG_MICREL_PHY.
The processor was running at 996Mhz. The last 2 patches
are independent from this series, but I included here
to have the bench marks in one place. The following
commands were used to get the transfer rates.

On an x86 ubunto system,
iperf -s -i.5 -u


On a nitrogen6x board, running via NFS/Sd card.
I first stopped some background processes

stop cron
stop upstart-file-bridge
stop upstart-socket-bridge
stop upstart-udev-bridge
stop rsyslog
stop dbus
killall dhclient
echo performance >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

taskset 0x2 iperf -c 192.168.0.201 -u -t60 -b500M -r

There is a branch available on github with this series
https://github.com:boundarydevices/linux-imx6.git branch net-next_master


Troy Kisky (40):
NFS      SDCARD
 TX/RX   TX/RX  Mbits/sec
377/406 379/407 before any patches
377/409 379/406 net: fec: stop the "rcv is not +last, " error messages
374/406 374/407 net: fec: fix rx error counts
373/410 377/407 net: fec: fix fec_enet_get_free_txdesc_num
374/408 379/413 net: fec: add struct bufdesc_prop
375/410 379/412 net: fec: add variable reg_desc_active to speed things up
380/413 383/416 net: fec: don't disable FEC_ENET_TS_TIMER interrupt
375/406 379/413 net: fec: don't transfer ownership until descriptor write is complete
373/411 378/414 net: fec: move cbd_bufaddr assignment closer to the mapping function
372/411 377/414 net: fec: only check queue 0 if RXF_0/TXF_0 interrupt is set
375/410 375/412 net: fec: pass rxq to fec_enet_rx_queue instead of queue_id
373/414 377/413 net: fec: pass txq to fec_enet_tx_queue instead of queue_id
380/426 382/425 net: fec: reduce interrupts
378/418 379/417 net: fec: split off napi routine with 3 queues
379/417 379/418 net: fec: don't clear all rx queue bits when just one is being checked
379/420 379/420 net: fec: set cbd_sc without relying on previous value
379/422 379/422 net: fec: eliminate calls to fec_enet_get_prevdesc
379/425 379/424 net: fec: move restart test for efficiency
379/415 379/419 net: fec: clear cbd_sc after transmission to help with debugging
373/420 379/421 net: fec: dump all tx queues in fec_dump
378/425 379/427 net: fec: detect tx int lost
379/416 379/418 net: fec: print more debug info in fec_timeout
379/415 380/415 net: fec: call dma_unmap_single on mapped tx buffers at restart
382/419 384/418 net: fec: don't set cbd_bufaddr unless no mapping error
379/417 380/415 net: fec: return NETDEV_TX_BUSY, when not enough space in ring
379/417 379/417 net: fec: don't free skb until it has been unmapped
378/421 379/425 net: fec: set cbd_esc only once
379/413 380/411 net: fec: enable interrupt on very last descriptor only
381/411 381/411 net: fec: unmap initial buffer on error
379/419 387/417 net: fec: don't free skb when returning busy
384/419 386/418 net: fec: move last_bdp assignment for symmetry
383/420 387/419 net: fec: don't transfer ownership until entire tso is queued
381/424 384/424 net: fec: fix err_release in fec_enet_txq_submit_tso
382/423 383/422 net: fec: shrink the window for 'tx int lost'
387/418 388/420 net: fec: update dirty_tx even if no skb
387/423 390/423 net: fec: rename dirty_tx to pending_tx
388/426 389/423 net: fec: use mac set by bootloader before fuses
379/425 380/432 net: fec: add events device file
379/432 381/429 net: fec: recover from lost rxf_0 interrupt
381/432 381/432 ARM: dts: imx6qdl-nitrogen6x: add phy interrupt to eliminate polling
380/432 380/432 ARM: dts: imx6qdl-nitrogen6_max: add phy interrupt to eliminate
    polling


The same patch set on Freescale's 3.14 release gives
458/619 Mbits/sec with the command modified to

taskset 0x2 iperf -c 192.168.0.201 -u -t60 -b600M -r

The huge difference may be related to the cpuidle driver which isn't
enabled in imx_v6_v7_defconfig and doesn't seem to work if it is enabled.




 arch/arm/boot/dts/imx6qdl-nitrogen6_max.dtsi |   9 +
 arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi    |  11 +
 drivers/net/ethernet/freescale/fec.h         |  59 +-
 drivers/net/ethernet/freescale/fec_main.c    | 921 ++++++++++++++-------------
 4 files changed, 525 insertions(+), 475 deletions(-)
