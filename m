From: tndave <tushar.n.dave@oracle.com>
Subject: i40e: Errors while turning off TSO
Date: Mon, 16 May 2016 12:34:33 -0700
Message-ID: <573A20C9.90803@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: intel-wired-lan@lists.osuosl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	netdev <netdev@vger.kernel.org>, carolyn.wyborny@intel.com,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	mitch.a.williams@intel.com,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:37228 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754651AbcEPTel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 15:34:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On systems with 128 CPUs, turning off TSO results in errors.

Errors:
i40e 0000:03:00.0: failed to get tracking for 1 vectors for VSI 400, err=-12
i40e 0000:03:00.0: Couldn't create FDir VSI
i40e 0000:03:00.0: i40e_ptp_init: PTP not supported on eth0
i40e 0000:03:00.0: couldn't add VEB, err I40E_ERR_ADMIN_QUEUE_ERROR
aq_err I40E_AQ_RC_ENOENT
i40e 0000:03:00.0: rebuild of switch failed: -1, will try to set up
simple PF connection
i40e 0000:03:00.0 eth0: adding 00:10:e0:8a:24:b6 vid=0


 From kernel log:
i40e: Intel(R) Ethernet Connection XL710 Network Driver - version 1.4.8-k
i40e: Copyright (c) 2013 - 2014 Intel Corporation.
i40e 0000:03:00.0: fw 4.40.35115 api 1.4 nvm 4.53 0x80001e8c 0.0.0
i40e 0000:03:00.0: MAC address: 00:10:e0:8a:24:b6
i40e 0000:03:00.0: i40e_ptp_init: PTP not supported on eth0
i40e 0000:03:00.0: PCI-Express: Speed 8.0GT/s Width x8
i40e 0000:03:00.0: Features: PF-id[0] VFs: 32 VSIs: 34 QP: 128 RX: 1BUF
RSS FD_ATR VxLAN VEPA

As per the log above, feature FD_SB (sideband flow director)) is not
enabled. Because there are no enough MSI-X vectors available.
(Device function caps report 129 MSI-X vectors in this case. And driver
reserved 1 of them for misc interrupt and rest 128 for 128 QP. So no
vector left for FD_SB. Therefore driver disables FD_SB)

However turning off TSO invokes i40e_set_ntuple()
that enables FD_SB and returns true, issues reset in i40e_set_features()
i.e i40e_do_reset.

Later during reset, driver fails to find irq for FD_SB from irq pile
(and it won't because there was no irq vector assigned for FD_SB).
This results in the very first error,
'i40e 0000:03:00.0: failed to get tracking for 1 vectors for VSI 400,
err=-12'

I believe before enabling FD_SB in i40e_set_ntuple(), driver should
check if MSI-X vector available for FD_SB.

Sending patch in separate email.

(FWIW, if number of CPUs reduced to 64, I don't see the issue
described above because in that case out of 129 MSI-X vectors only
64 get assigned to QP. Remaining are used for features like FD_SB)

-Tushar
