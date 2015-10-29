From: "Miller, Darin J" <darin.j.miller@intel.com>
Subject: RE: [Intel-wired-lan] [net PATCH v2] ixgbe: Reset interface after
	enabling SR-IOV
Date: Thu, 29 Oct 2015 01:32:19 +0000
Message-ID: <A91205FD8A6E14448BD4414C06E9C3D37520DF03@fmsmsx115.amr.corp.intel.com>
References: <20151020202715.2955.88128.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: 'Alexander Duyck' <aduyck@mirantis.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:4499 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751237AbbJ2BcU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 21:32:20 -0400
In-Reply-To: <20151020202715.2955.88128.stgit@ahduyck-vm-fedora22>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-----Original Message-----
From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Alexander Duyck
Sent: Tuesday, October 20, 2015 1:28 PM
To: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org
Subject: [Intel-wired-lan] [net PATCH v2] ixgbe: Reset interface after enabling SR-IOV

Enabling SR-IOV and then bringing the interface up was resulting in the PF MAC addresses getting into a bad state.  Specifically the MAC address was enabled for both VF 0 and the PF.  This resulted in some odd behaviors such as VF 0 receiving a copy of the PFs traffic, which in turn enables the ability for VF 0 to spoof the PF.

A workaround for this issue appears to be to bring up the interface first and then enable SR-IOV as this way the reset is then triggered in the existing code.

In order to correct this I have added a change to ixgbe_setup_tc where if the interface is down we still will at least call ixgbe_reset so that the MAC addresses for the device are reset to the correct pools.

Steps to reproduce issue:
modprobe ixgbe
echo 7 > /sys/bus/pci/devices/0000\:01\:00.1/sriov_numvfs
ifconfig enp1s0f1 up
ethregs -s 1:00.1 | grep MPSAR | grep -v 00000000

Result:
	MPSAR[0]               00000081
	MPSAR[254]             00000001

Expected Result, behavior after patch:
	MPSAR[0]               00000080
	MPSAR[254]             00000080

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---

Tested-by: Darin Miller <darin.j.miller@intel.com>
