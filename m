From: Vaughan Cao <vaughan.cao@oracle.com>
Subject: Re: error message: VF is not privileged to issue opcode 89-1
Date: Sat, 21 Dec 2013 10:28:40 +0800
Message-ID: <52B4FCD8.50108@oracle.com>
References: <52B41193.6020908@oracle.com> <3BB8C5C6B04A1F4CBE5B241DA98A501E2D56803E@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Ajit Khaparde <Ajit.Khaparde@Emulex.Com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20432 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135Ab3LUC2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 21:28:46 -0500
In-Reply-To: <3BB8C5C6B04A1F4CBE5B241DA98A501E2D56803E@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013=E5=B9=B412=E6=9C=8821=E6=97=A5 00:42, Ajit Khaparde wrote:
>
>>   be2net 0000:30:04.0: VF is not privileged to issue opcode 34-1
>>   be2net 0000:30:04.0: Emulex OneConnect(be3): VF  port 0
>> ...
>>
>> But the module gets loaded and VFs are created.
>> Also when the module is unloaded, below errors are seen in syslog:
>>    be2net 0000:30:04.0: VF is not privileged to issue opcode 89-1
>>
>> I checked the code, this error occurs in be_probe() and the error op=
code
>> 89 is OPCODE_COMMON_SET_INTERRUPT_ENABLE, which is essential for an
>> initializing process IMO. And I also found this thread
>> https://lkml.org/lkml/2013/5/14/690, which shows there is a bug that=
 VFs
>> will be probed before PFs. According to this thread, I guess I may
>> encountered the same error.
>> Anyone can confirm if this is a real error like I guess? Thanks.
> The VFs on Emulex devices are assigned limited privileges unlike PFs.
> Due to this certain commands sent to the firmware end up a response a=
s seen in the logs.
> In most of the cases the log message is informational and does not re=
ally impact normal I/O operations.
>
> But for this particular message pertaining to opcode 89, I will have =
to check with the firmware team as well.
> We will get back to you on that.
>
> Could you send the output of ethtool -i?
> I am interested in the firmware version on the card.
>
> Thanks
Hi Ajit,

Thanks for your explanation. What you requested is below:
# ethtool -i eth4
driver: be2net
version: 4.6.63.0u
firmware-version: 4.1.402.18
bus-info: 0000:30:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: no
supports-priv-flags: no

# cat /sys/class/net/eth4/device/sriov_numvfs
4
# cat /sys/class/net/eth4/device/sriov_totalvfs
16

And Emulex card detail :
30:00.0 Ethernet controller: Emulex Corporation OneConnect 10Gb NIC (be=
3)
(rev 01)
30:00.1 Ethernet controller: Emulex Corporation OneConnect 10Gb NIC (be=
3)
(rev 01)

The whole message when creating SR-IOV VF is here, all VFs report=20
messages like that.

be2net 0000:30:00.0: irq 214 for MSI/MSI-X
  be2net 0000:30:00.0: enabled 1 MSI-x vector(s)
  be2net 0000:30:00.0: created 0 RSS queue(s) and 1 default RX queue
  be2net 0000:30:00.0: created 1 TX queue(s)
  pci 0000:30:04.0: [19a2:0710] type 00 class 0x020000
  pci 0000:30:04.1: [19a2:0710] type 00 class 0x020000
  pci 0000:30:04.2: [19a2:0710] type 00 class 0x020000
  pci 0000:30:04.3: [19a2:0710] type 00 class 0x020000
  be2net 0000:30:00.0: Emulex OneConnect(be3): PF  port 0
  be2net 0000:30:00.1: irq 215 for MSI/MSI-X
  be2net 0000:30:00.1: enabled 1 MSI-x vector(s)
  be2net 0000:30:00.1: created 0 RSS queue(s) and 1 default RX queue
  be2net 0000:30:00.1: created 1 TX queue(s)
  pci 0000:30:06.0: [19a2:0710] type 00 class 0x020000
  pci 0000:30:06.1: [19a2:0710] type 00 class 0x020000
  pci 0000:30:06.2: [19a2:0710] type 00 class 0x020000
  pci 0000:30:06.3: [19a2:0710] type 00 class 0x020000
  be2net 0000:30:00.1: Emulex OneConnect(be3): PF  port 1
  be2net 0000:30:04.0: enabling device (0140 -> 0142)
  be2net 0000:30:04.0: Could not use PCIe error reporting
  be2net 0000:30:04.0: VF is not privileged to issue opcode 89-1
  be2net 0000:30:04.0: VF is not privileged to issue opcode 125-1
  be2net 0000:30:04.0: irq 216 for MSI/MSI-X
  be2net 0000:30:04.0: enabled 1 MSI-x vector(s)
  be2net 0000:30:04.0: created 0 RSS queue(s) and 1 default RX queue
  be2net 0000:30:04.0: created 1 TX queue(s)
  be2net 0000:30:04.0: VF is not privileged to issue opcode 34-1
  be2net 0000:30:04.0: Exhausted multicast HW filters.
  be2net 0000:30:04.0: Disabling HW multicast filtering.
  be2net 0000:30:04.0: VF is not privileged to issue opcode 34-1
  be2net 0000:30:04.0: Emulex OneConnect(be3): VF  port 0
  be2net 0000:30:04.1: enabling device (0140 -> 0142)
  be2net 0000:30:04.1: Could not use PCIe error reporting
  be2net 0000:30:04.1: VF is not privileged to issue opcode 89-1
  be2net 0000:30:04.1: VF is not privileged to issue opcode 125-1
  be2net 0000:30:04.1: irq 217 for MSI/MSI-X
  be2net 0000:30:04.1: enabled 1 MSI-x vector(s)
  be2net 0000:30:04.1: created 0 RSS queue(s) and 1 default RX queue
  be2net 0000:30:04.1: created 1 TX queue(s)
  be2net 0000:30:04.1: VF is not privileged to issue opcode 34-1
  be2net 0000:30:04.1: Exhausted multicast HW filters.
  be2net 0000:30:04.1: Disabling HW multicast filtering.
  be2net 0000:30:04.1: VF is not privileged to issue opcode 34-1
  be2net 0000:30:04.1: Emulex OneConnect(be3): VF  port 0
  be2net 0000:30:04.2: enabling device (0140 -> 0142)
  be2net 0000:30:04.2: Could not use PCIe error reporting
  be2net 0000:30:04.2: VF is not privileged to issue opcode 89-1
  be2net 0000:30:04.2: VF is not privileged to issue opcode 125-1
  be2net 0000:30:04.2: irq 218 for MSI/MSI-X
  be2net 0000:30:04.2: enabled 1 MSI-x vector(s)
  be2net 0000:30:04.2: created 0 RSS queue(s) and 1 default RX queue
  be2net 0000:30:04.2: created 1 TX queue(s)
  be2net 0000:30:04.2: VF is not privileged to issue opcode 34-1
  be2net 0000:30:04.2: Exhausted multicast HW filters.
  be2net 0000:30:04.2: Disabling HW multicast filtering.
  be2net 0000:30:04.2: VF is not privileged to issue opcode 34-1
  be2net 0000:30:04.2: Emulex OneConnect(be3): VF  port 0
  be2net 0000:30:04.3: enabling device (0140 -> 0142)
  be2net 0000:30:04.3: Could not use PCIe error reporting
  be2net 0000:30:04.3: VF is not privileged to issue opcode 89-1
  be2net 0000:30:04.3: VF is not privileged to issue opcode 125-1
  be2net 0000:30:04.3: irq 219 for MSI/MSI-X
  be2net 0000:30:04.3: enabled 1 MSI-x vector(s)
  be2net 0000:30:04.3: created 0 RSS queue(s) and 1 default RX queue
  be2net 0000:30:04.3: created 1 TX queue(s)
  be2net 0000:30:04.3: VF is not privileged to issue opcode 34-1
  be2net 0000:30:04.3: Exhausted multicast HW filters.
  be2net 0000:30:04.3: Disabling HW multicast filtering.
  be2net 0000:30:04.3: VF is not privileged to issue opcode 34-1
  be2net 0000:30:04.3: Emulex OneConnect(be3): VF  port 0
  be2net 0000:30:06.0: enabling device (0140 -> 0142)
  be2net 0000:30:06.0: Could not use PCIe error reporting
  be2net 0000:30:06.0: VF is not privileged to issue opcode 89-1
  be2net 0000:30:06.0: VF is not privileged to issue opcode 125-1
  be2net 0000:30:06.0: irq 220 for MSI/MSI-X
  be2net 0000:30:06.0: enabled 1 MSI-x vector(s)
  be2net 0000:30:06.0: created 0 RSS queue(s) and 1 default RX queue
  be2net 0000:30:06.0: created 1 TX queue(s)
  be2net 0000:30:06.0: VF is not privileged to issue opcode 34-1
  be2net 0000:30:06.0: Exhausted multicast HW filters.
  be2net 0000:30:06.0: Disabling HW multicast filtering.
  be2net 0000:30:06.0: VF is not privileged to issue opcode 34-1
  be2net 0000:30:06.0: Emulex OneConnect(be3): VF  port 1
  be2net 0000:30:06.1: enabling device (0140 -> 0142)
  be2net 0000:30:06.1: Could not use PCIe error reporting
  be2net 0000:30:06.1: VF is not privileged to issue opcode 89-1
  be2net 0000:30:06.1: VF is not privileged to issue opcode 125-1
  be2net 0000:30:06.1: irq 221 for MSI/MSI-X
  be2net 0000:30:06.1: enabled 1 MSI-x vector(s)
  be2net 0000:30:06.1: created 0 RSS queue(s) and 1 default RX queue
  be2net 0000:30:06.1: created 1 TX queue(s)
  be2net 0000:30:06.1: VF is not privileged to issue opcode 34-1
  be2net 0000:30:06.1: Exhausted multicast HW filters.
  be2net 0000:30:06.1: Disabling HW multicast filtering.
  be2net 0000:30:06.1: VF is not privileged to issue opcode 34-1
  be2net 0000:30:06.1: Emulex OneConnect(be3): VF  port 1
  be2net 0000:30:06.2: enabling device (0140 -> 0142)
  be2net 0000:30:06.2: Could not use PCIe error reporting
  be2net 0000:30:06.2: VF is not privileged to issue opcode 89-1
  be2net 0000:30:06.2: VF is not privileged to issue opcode 125-1
  be2net 0000:30:06.2: irq 222 for MSI/MSI-X
  be2net 0000:30:06.2: enabled 1 MSI-x vector(s)
  be2net 0000:30:06.2: created 0 RSS queue(s) and 1 default RX queue
  be2net 0000:30:06.2: created 1 TX queue(s)
  be2net 0000:30:06.2: VF is not privileged to issue opcode 34-1
  be2net 0000:30:06.2: Exhausted multicast HW filters.
  be2net 0000:30:06.2: Disabling HW multicast filtering.
  be2net 0000:30:06.2: VF is not privileged to issue opcode 34-1
  be2net 0000:30:06.2: Emulex OneConnect(be3): VF  port 1
  be2net 0000:30:06.3: enabling device (0140 -> 0142)
  be2net 0000:30:06.3: Could not use PCIe error reporting
  be2net 0000:30:06.3: VF is not privileged to issue opcode 89-1
  be2net 0000:30:06.3: VF is not privileged to issue opcode 125-1
  be2net 0000:30:06.3: irq 223 for MSI/MSI-X
  be2net 0000:30:06.3: enabled 1 MSI-x vector(s)
  be2net 0000:30:06.3: created 0 RSS queue(s) and 1 default RX queue
  be2net 0000:30:06.3: created 1 TX queue(s)
  be2net 0000:30:06.3: VF is not privileged to issue opcode 34-1
  be2net 0000:30:06.3: Exhausted multicast HW filters.
  be2net 0000:30:06.3: Disabling HW multicast filtering.
  be2net 0000:30:06.3: VF is not privileged to issue opcode 34-1
  be2net 0000:30:06.3: Emulex OneConnect(be3): VF  port 1

Vaughan
