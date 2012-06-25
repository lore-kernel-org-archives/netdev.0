From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next (v2) 00/14] default maximal number of RSS queues
 in mq drivers
Date: Mon, 25 Jun 2012 14:45:31 +0300
Message-ID: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Divy Le Ray" <divy@chelsio.com>,
	"Or Gerlitz" <ogerlitz@mellanox.com>,
	"Jon Mason" <jdmason@kudzu.us>,
	"Anirban Chakraborty" <anirban.chakraborty@qlogic.com>,
	"Jitendra Kalsaria" <jitendra.kalsaria@qlogic.com>,
	"Ron Mercer" <ron.mercer@qlogic.com>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	"Jon Mason" <mason@myri.com>,
	"Andrew Gallatin" <gallatin@myri.com>,
	"Sathya Perla" <sathya.perla@emulex.com>,
	"Subbu Seetharaman" <subbu.seetharaman@emulex.com>,
	"Ajit Khaparde" <ajit.khaparde@emulex.com>,
	"Matt Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4190 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756106Ab2FYLrw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2012 07:47:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Different vendors support different number of RSS queues by default. Today,
there exists an ethtool API through which users can change the number of
channels their driver supports; This enables us to pursue the goal of using
a default number of RSS queues in various multi-queue drivers.

This RFC intendeds to achieve the above default, by upper-limiting the number
of interrupts multi-queue drivers request (by default, not via the new API) 
with correlation to the number of cpus on the machine.

After examining multi-queue drivers that call alloc_etherdev_mq[s],
it became evident that most drivers allocate their devices using hard-coded
values. Changing those defaults directly will most likely cause a regression. 

However, (most) multi-queue driver look at the number of online cpus when 
requesting for interrupts. We assume that the number of interrupts the
driver manages to request is propagated across the driver, and the number
of RSS queues it configures is based upon it. 

This RFC modifies said logic - if the number of cpus is large enough, use
a smaller default value instead. This serves 2 main purposes: 
 1. A step forward unity in the number of RSS queues of various drivers.
 2. It prevents wasteful requests for interrupts on machines with many cpus.

Notice no testing was made on this RFC (other than on the bnx2x driver)
except for compilation test.

Drivers identified as multi-queue, handled in this RFC:

* mellanox mlx4
* neterion vxge
* qlogic   qlge
* intel    igb, igbxe igbxevf
* chelsio  cxgb3, cxgb4
* myricom  myri10ge
* emulex   benet
* broadcom tg3, bnx2, bnx2x

Driver identified as multi-queue, no reference to number of online cpus found,
and thus unhandled in this RFC:

* neterion  s2io
* marvell   mv643xx
* freescale gianfar
* ibm       ehea
* ti        cpmac
* sun       niu
* sfc       efx
* chelsio   cxgb4vf

Cheers,
Yuval Mintz

Cc: Divy Le Ray <divy@chelsio.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>
Cc: Jon Mason <jdmason@kudzu.us>
Cc: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Cc: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Cc: Ron Mercer <ron.mercer@qlogic.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Jon Mason <mason@myri.com>
Cc: Andrew Gallatin <gallatin@myri.com>
Cc: Sathya Perla <sathya.perla@emulex.com>
Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
Cc: Matt Carlson <mcarlson@broadcom.com>
Cc: Michael Chan <mchan@broadcom.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
