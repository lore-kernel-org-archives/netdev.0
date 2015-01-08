From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [RFC net-next 0/3] devconf: New infrastructure for setting pre-load
 parameters for a module
Date: Thu, 8 Jan 2015 19:11:04 +0200
Message-ID: <54AEBA28.1030301@mellanox.com>
References: <1420730220-20224-1-git-send-email-hadarh@mellanox.com>
 <20150108164618.GA11696@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	"Or Gerlitz" <ogerlitz@mellanox.com>,
	"shannon.nelson@intel.com" <shannon.nelson@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	"greearb@candelatech.com" <greearb@candelatech.com>
To: Greg KH <gregkh@linuxfoundation.org>,
	Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0059.outbound.protection.outlook.com ([157.56.112.59]:26729
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754724AbbAHRMG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2015 12:12:06 -0500
In-Reply-To: <20150108164618.GA11696@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/8/2015 6:46 PM, Greg KH wrote:
> On Thu, Jan 08, 2015 at 05:16:57PM +0200, Hadar Hen Zion wrote:
>> Hi,
>>     
>> When configuring a device at an early boot stage, most kernel drivers
>> use module parameters (the parameters' settings can be determined in
>> modprobe.d config files).
> 
> Which is a bad idea, as you have learned :)
> 
>> These parameters are difficult to manage, and one of the reasons is that
>> module parameters are set per driver and not per device (NICs using the
>> same driver cannot be set with different configurations).
>> Furthermore, using other existing configuration tools like ethtool,
>> ifconfig, ip link commands or sysfs entries is not applicable, since
>> they all rely on having a netdev already set up.
>>
>> In the past, 'request_firmware' solution for configuration parameters
>> was suggested by Shannon Nelson from Intel[1]. The idea was rejected by
>> Greg KH, who claimed it was abusive of the request_firmware mechanism.
>> Greg suggested using configfs for device configuration instead (as done
>> by the USB gadget driver).
>>
>> As a solution, we introduce a new kernel infrastructure using configfs
>> to allow the configuration of the device. The goal is to set low-level
>> device functionality that needs to be sorted out before a module is
>> loaded.
> 
> Ick, really?  drivers should never need to be configured like this, if
> so, then something is wrong, they should "just work" by default.  What
> are you needing to "configure" that can't be determined by something
> like a device tree?
Ick indeed - but we can't find anything better.

For example, we have devices that can act as either netdev or as an
Infiniband device.
The driver consists of a core to handle the hardware, and higher layer
drivers - one for Ethernet and one for Infiniband.
Today the selection is done through a module parameter. according to it
the relevant higher level driver is loaded, and the device is
initialized. You don't want to have a default of netdev, and in every
installation that needs Infiniband, a netdev will be created, removed
and only then the Infiniband device will appear.
This is only one example to configuration that needs to be known before
the hardware is initialized, and be persistent across boots.

We can have a 2 stages loading. First load the core, wait for user
input, and only then configure the device and load the right upper layer
driver according to the user input (configfs/sysfs).
Since other vendors seems to need this capability too, we thought it
would be better to make it generic - and this is this what this RFC is
about.

Amir




> 
> greg k-h
> 
