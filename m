From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Subject: Re: [RFC 02/10] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) Bus driver
Date: Mon, 21 Nov 2016 13:30:17 -0800
Message-ID: <20161121213017.GB67872@knc-06.sc.intel.com>
References: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1479508938-63799-3-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161119190445.GG22775@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org,
        Dennis Dalessandro <dennis.dalessandro@intel.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:49678 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752077AbcKUVal (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 16:30:41 -0500
Content-Disposition: inline
In-Reply-To: <20161119190445.GG22775@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 19, 2016 at 12:04:45PM -0700, Jason Gunthorpe wrote:
>On Fri, Nov 18, 2016 at 02:42:10PM -0800, Vishwanathapura, Niranjana wrote:
>> +HFI-VNIC DRIVER
>> +M:	Dennis Dalessandro <dennis.dalessandro@intel.com>
>> +M:	Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>
>> +L:	linux-rdma@vger.kernel.org
>> +S:	Supported
>> +F:	drivers/infiniband/sw/intel/vnic
>
>This is either a net driver or a ULP, no idea why it should go in this
>directory!?
>
>It sounds like an ethernet driver, so you should probably put it
>there...
>

The hfi_vnic is an Ethernet driver. It is similar to ULP like ipoib, but 
instead it is Ethernet over Omni-path here.
The VNIC Ethernet (hfi_vnic) driver encapsulates Ethernet packets in an 
Omni-path header.
The hfi_vnic Ethernet driver do not access the HW. It interfaces with HFI1 
driver which sends/receives Omni-Path encapsulated Ethernet frames from HW.
Also, the VNIC control path driver (VEMA) is an IB MAD agent which should be 
under drivers/infiniband/.. .
Putting the VNIC Ethernet driver and the VNIC control driver together under a 
single module (hfi_vnic.ko) provided a simpler interface between them.

So, we have put the driver under drivers/infiniband/sw/intel for two reasons:
a) We have VNIC control driver (VEMA) which is an IB mad agent.
b) hfi_vnic Ethernet driver is dependent on HFI1 driver for sending/receving 
Omni-path encapsulated Ethernet packets from HW.

>> +/* hfi_vnic_bus_init - initialize the hfi vnic bus drvier */
>> +static int hfi_vnic_bus_init(void)
>> +{
>> +	int rc;
>> +
>> +	ida_init(&hfi_vnic_ctrl_ida);
>> +	idr_init(&hfi_vnic_idr);
>> +
>> +	rc = bus_register(&hfi_vnic_bus);
>
>Why on earth do we need this? Didn't I give you enough grief for the
>psm stuff and now you want to create an entire subystem hidden away!?
>
>Use some netlink scheme to control your vnic like the rest of the net
>stack..
>

The hfi_vnic_bus is only abstracting the HW independent functionality (like 
Ethernet interface, encapsulation, IB MAD interface etc) with the HW dependent 
functionality (sending/receiving packets on the wire).
Thus providing a cleaner interface between HW independent hfi_vnic Ethernet and 
Control drivers and the HW dependent HFI1 driver.

There is no other User interface here other than the standard Ethernet 
interface through network stack.

HFI1 driver creates VNIC devices on the hfi_vnic_bus as below and the hfi_vnic 
Ethernet and Control drivers drive them.

#ls /sys/bus/hfi_vnic_bus/devices/
    hfi_vnic_ctrl_00         /* control device for HFI instance 0 */
    hfi_vnic_00.01.00        /* first VNIC port on HFI instance 0, port 1 */
    hfi_vnic_00.01.01        /* second VNIC port on HFI instance 0, port 1 */

The design is as shown in the below diagram.

	+-------------------+ +----------------------+
	|                   | |       Linux          |
	|     IB MAD        | |      Network         |
	|                   | |       Stack          |
	+-------------------+ +----------------------+
		 |                       |
		 |                       |
	+--------------------------------------------+
	|                                            |
	|             HFI VNIC Module                |
	|    (HFI VNIC Netdev and EMA drivers)       |
	|              (HW independent)              |
	+--------------------------------------------+
			     |
			     |
	+--------------------------------------------+
	|              HFI VNIC Bus                  |
	+--------------------------------------------+
			     |
			     |
	+--------------------------------------------+
	|                                            |
	|      HFI1 Driver with VNIC support         |
	|               (HW dependent)               |
	+--------------------------------------------+

Niranjana

>Jason
