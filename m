From: "Miller, Darin J" <darin.j.miller@intel.com>
Subject: RE: [Intel-wired-lan] [net-next PATCH 1/3] ixgbe: Refactor MAC
 address	configuration code
Date: Wed, 11 Nov 2015 23:34:26 +0000
Message-ID: <A91205FD8A6E14448BD4414C06E9C3D37522189C@fmsmsx115.amr.corp.intel.com>
References: <20151022232228.24612.81341.stgit@ahduyck-vm-fedora22>
 <20151022232630.24612.50134.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: 'Alexander Duyck' <aduyck@mirantis.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:31658 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751152AbbKKXeg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 18:34:36 -0500
In-Reply-To: <20151022232630.24612.50134.stgit@ahduyck-vm-fedora22>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-----Original Message-----
From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Alexander Duyck
Sent: Thursday, October 22, 2015 4:27 PM
To: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org; Kirsher, Jeffrey T
Subject: [Intel-wired-lan] [net-next PATCH 1/3] ixgbe: Refactor MAC address configuration code

In the process of tracking down a memory leak when adding/removing fdb entries I had to go through the MAC address configuration code for ixgbe.
In the process of doing so I found a number of issues that impacted readability and performance.  This change updates the code in general to clean it up so it becomes clear what each step is doing.  From what I can tell there a couple of bugs cleaned up in this code.

First is the fact that the MAC addresses were being double counted for the PF.  As a result once entries up to 63 had been used you could no longer add additional filters.

A simple test case for this:
  for i in `seq 0 96`
  do
    ip link add link ens8 name mv$i type macvlan
    ip link set dev mv$i up
  done

Test script:
  ethregs -s 0:8.0 | grep -e "RAH" | grep 8000....$

When things are working correctly RAL/H registers 1 - 97 will be consumed.
In the failing case it will stop at 63 and prevent any further filters from being added.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    7 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  163 +++++++++++++++----------
 2 files changed, 100 insertions(+), 70 deletions(-)

Tested-by: Darin Miller <darin.j.miller@intel.com>
