From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] PCI: lock each enable/disable num_vfs operation in
 sysfs
Date: Mon, 9 Jan 2017 10:45:10 +1100
Message-ID: <20170108234510.GA14008@gwshan>
References: <20170106215908.20736.34632.stgit@localhost6.localdomain6>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pci@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        alexander.h.duyck@intel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Emil Tantilov <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:58977 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S934218AbdAHXpQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 18:45:16 -0500
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v08NiKdf123675
        for <netdev@vger.kernel.org>; Sun, 8 Jan 2017 18:45:16 -0500
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
        by mx0b-001b2d01.pphosted.com with ESMTP id 27utp5qrna-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2017 18:45:15 -0500
Received: from localhost
        by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Mon, 9 Jan 2017 09:45:12 +1000
Content-Disposition: inline
In-Reply-To: <20170106215908.20736.34632.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 06, 2017 at 01:59:08PM -0800, Emil Tantilov wrote:
>Enabling/disabling SRIOV via sysfs by echo-ing multiple values
>simultaneously:
>
>echo 63 > /sys/class/net/ethX/device/sriov_numvfs&
>echo 63 > /sys/class/net/ethX/device/sriov_numvfs
>
>sleep 5
>
>echo 0 > /sys/class/net/ethX/device/sriov_numvfs&
>echo 0 > /sys/class/net/ethX/device/sriov_numvfs
>
>Results in the following bug:
>
>kernel BUG at drivers/pci/iov.c:495!
>invalid opcode: 0000 [#1] SMP
>CPU: 1 PID: 8050 Comm: bash Tainted: G   W   4.9.0-rc7-net-next #2092
>RIP: 0010:[<ffffffff813b1647>]
>	  [<ffffffff813b1647>] pci_iov_release+0x57/0x60
>
>Call Trace:
> [<ffffffff81391726>] pci_release_dev+0x26/0x70
> [<ffffffff8155be6e>] device_release+0x3e/0xb0
> [<ffffffff81365ee7>] kobject_cleanup+0x67/0x180
> [<ffffffff81365d9d>] kobject_put+0x2d/0x60
> [<ffffffff8155bc27>] put_device+0x17/0x20
> [<ffffffff8139c08a>] pci_dev_put+0x1a/0x20
> [<ffffffff8139cb6b>] pci_get_dev_by_id+0x5b/0x90
> [<ffffffff8139cca5>] pci_get_subsys+0x35/0x40
> [<ffffffff8139ccc8>] pci_get_device+0x18/0x20
> [<ffffffff8139ccfb>] pci_get_domain_bus_and_slot+0x2b/0x60
> [<ffffffff813b09e7>] pci_iov_remove_virtfn+0x57/0x180
> [<ffffffff813b0b95>] pci_disable_sriov+0x65/0x140
> [<ffffffffa00a1af7>] ixgbe_disable_sriov+0xc7/0x1d0 [ixgbe]
> [<ffffffffa00a1e9d>] ixgbe_pci_sriov_configure+0x3d/0x170 [ixgbe]
> [<ffffffff8139d28c>] sriov_numvfs_store+0xdc/0x130
>...
>RIP  [<ffffffff813b1647>] pci_iov_release+0x57/0x60
>
>Use the existing mutex lock to protect each enable/disable operation.
>
>-v2: move the existing lock from protecting the config of the IOV bus
>to protecting the writes to sriov_numvfs in sysfs without maintaining
>a "locked" version of pci_iov_add/remove_virtfn().
>As suggested by Gavin Shan <gwshan@linux.vnet.ibm.com>
>
>CC: Alexander Duyck <alexander.h.duyck@intel.com>
>Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
>---

Reviewed-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
