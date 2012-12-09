From: "Elena Gurevich" <elena.gurevich@toganetworks.com>
Subject: ixgbe:  pci_get_device() call without counterpart call of pci_dev_put()
Date: Sun, 9 Dec 2012 11:47:37 +0200
Message-ID: <01b301cdd5f2$3a9b2360$afd16a20$@toganetworks.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtpa06-03.prod.phx3.secureserver.net ([173.201.192.104]:41157
	"EHLO p3plsmtpa06-03.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932961Ab2LIJzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2012 04:55:47 -0500
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
I am pioneer in linux device drivers here and using Intel 82599 NIC as
reference model, 
During investigation to drivers sources I found the suspicious code:  

Is code sequence (1)   and (2) the possible device reference count leakage
???


Thanks a lot in advance
Lena

--------snipped from ixgbe_main.c  file function ixgbe_io_error_detected()
-----------

. . . 
		/* Find the pci device of the offending VF */
		vfdev = pci_get_device(PCI_VENDOR_ID_INTEL, device_id,
NULL);
		while (vfdev) {
			if (vfdev->devfn == (req_id & 0xFF))
				break;
<------------------------------      (1) leaves the loop with successful get
call  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

			vfdev = pci_get_device(PCI_VENDOR_ID_INTEL,
					       device_id, vfdev);
		}
		/*
		 * There's a slim chance the VF could have been hot plugged,
		 * so if it is no longer present we don't need to issue the
		 * VFLR.  Just clean up the AER in that case.
		 */
		if (vfdev) {
			e_dev_err("Issuing VFLR to VF %d\n", vf);
			pci_write_config_dword(vfdev, 0xA8, 0x00008000);
		}

		pci_cleanup_aer_uncorrect_error_status(pdev);
	}

	/*
	 * Even though the error may have occurred on the other port
	 * we still need to increment the vf error reference count for
	 * both ports because the I/O resume function will be called
	 * for both of them.
	 */
	adapter->vferr_refcount++;

	return PCI_ERS_RESULT_RECOVERED;
<--------------------------------------------  (2) leaves the function
without put call !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
----------------------------------  snipped
-----------------------------------
