From: Dean Gehnert <deang@tpi.com>
Subject: Re: [PATCH net 0/2] net: marvell: Fix highmem support on non-TSO
 path
Date: Thu, 22 Jan 2015 15:08:34 -0800
Message-ID: <54C182F2.60004@tpi.com>
References: <1421844850-30886-1-git-send-email-ezequiel.garcia@free-electrons.com> <20150121150159.GS26493@n2100.arm.linux.org.uk> <54C1443C.80909@tpi.com> <20150122210951.GC26493@n2100.arm.linux.org.uk> <54C16B43.5040504@tpi.com> <20150122214910.GD26493@n2100.arm.linux.org.uk>
Reply-To: deang@tpi.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	B38611@freescale.com, fabio.estevam@freescale.com
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpi.com ([74.45.170.26]:44870 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751597AbbAVXIf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 18:08:35 -0500
In-Reply-To: <20150122214910.GD26493@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2015 01:49 PM, Russell King - ARM Linux wrote:
> On Thu, Jan 22, 2015 at 01:27:31PM -0800, Dean Gehnert wrote:
>> On 01/22/2015 01:09 PM, Russell King - ARM Linux wrote:
>>> On Thu, Jan 22, 2015 at 10:41:00AM -0800, Dean Gehnert wrote:
>>>> FYI, I found a way to reproduce the mv643xx_eth transmit corruption without
>>>> using a network filesystem by using SOCAT (should also be able to use NETCAT
>>>> or NC) and I have a bit more information about the corruption that looks
>>>> like it is somehow related to the cache line size.
>>> That's not quite what I'm seeing.  What I'm seeing with NFS is that the
>>> machine is basically unusable.  I have the etna_viv source in a NFS
>>> share (it's shared amongst not only the Dove box but also my collection
>>> of iMX6 based hardware.)
>>>
>>> I'm fairly fully IPv6 enabled here, which includes NFS.
>>>
>>> On the Dove, if I try to build this without any fixes, and then try to
>>> build the etna_viv sources, it will take the machine out to the extent
>>> that I have to reboot it - either the machine will freeze solidly, or
>>> the kernel will oops in the DMA API functions, in a path which was
>>> called from an interrupt handler.  That takes out the entire machine
>>> because we miss acknowleding the interrupt.
>> I am wondering if there is a possibility of the root cause of this being in
>> the arch DMA layer... From my testing with SOCAT and different cache line
>> alignments, I am seeing Ethernet 4 byte transmit corruptions. My fear is
>> this may not be restricted to the Ethernet transmit and maybe the root cause
>> is a DMA / cache issue... I have no way to prove that theory. Your DMA API
>> oops is a bit concerning that maybe there is some corruption going on during
>> DMA operation.
> We're careful in the arch code to do the best we can in all cases; that's
> not to say that drivers aren't buggy (in that, they don't respect the DMA
> API rules) but what I can say is that the ARM arch code gets it right.
Agreed. I have not seen problems like this before on other ARM 
implementations.
>
> Provided the ethernet driver maps the DMA buffer with DMA_TO_DEVICE prior
> to the transfer being initiated, transfers _from_ the Marvell platform(s)
> should be fine.
>
> Provided the ethernet driver maps the DMA buffer with DMA_FROM_DEVICE
> prior to handing it to the device, and then does not write to any cache
> line associated with that DMA buffer before the ethernet driver has
> completed, and then unmaps it with DMA_FROM_DEVICE, then again,
> everything should be fine.
>
> (The detail above "does not write to any cache line associated with
> the DMA buffer" is subtle; what it means is that if the DMA buffer is
> not aligned to a cache line, then nothing must write to the cache lines
> which overlap the buffer, otherwise data corruption will occur.)
I wonder if that is a clue for me to chase... The cache line should be 
completely flushed to hardware before the DMA operation is started. The 
DMA mapping routines should be making sure all the buffers associated 
with the DMA operation are locked down and flushed before completing the 
DMA map operation. However, if there is other code that was modifying 
the DMA buffers after the lock down and before the DMA has completed and 
the buffers have been un-mapped, that would be bad.
>
>> Can you can try the SOCAT test on your Dove platform and see if that passes
>> the non-cache line aligned test case? I think what the SOCAT test does is
>> take the NFS "variable" out of the equation. My theory is that if there is a
>> DMA corruption, then hard telling what kinds of problems will occur. It
>> might be the payload of a file is corrupted, or if the NFS structures are
>> corrupted, it could manifest itself as a problem in the NFS code.
> This is one of the problems of having the TCP/UDP checksums offloaded to
> the adapter - if the data is cocked up at the DMA stage, these checksums
> won't detect it.
I am going to noodle a bit for a way that I could check if the buffer 
has changed between the DMA map and un-map calls... I might be able to 
add some code to checksum the buffer between those calls. If the 
checksum changes. that would indicate that someone is changing the buffer.
>
> Anyway, I'm running the test now, but I had to change the socat line to:
>
> # socat -b$(((1024*10)+1)) -u open:ExpectData.in TCP:192.168.1.212:4000
>
> The receiving end is getting:
>
> 4a4727232209b85badc1ca25ed4df222  -
> 4a4727232209b85badc1ca25ed4df222  -
> 4a4727232209b85badc1ca25ed4df222  -
> 4a4727232209b85badc1ca25ed4df222  -
> 4a4727232209b85badc1ca25ed4df222  -
> ...
>
> and I'm up to over 24 of these without any problem being visible - how
> long does it take to show?
It should show up in the 1st or 2nd and all following iterations. For 
smaller files it seems to work for a while, but with the 256MB file, it 
stresses the system enough that is about guaranteed to occur. It looks 
like the Dove is working correctly. You have TSO enabled, large buffer, 
etc, so your results look good.

Refresh my memory... What version of Marvell Armada is the Dove? I was 
thinking the Dove was later than the Kirkwood and Armada 300 and was 
maybe an early Armada 370 or ???...
>
> For reference, the features on my Dove box are:
>
> Features for eth0:
> rx-checksumming: on
> tx-checksumming: on
>          tx-checksum-ipv4: on
>          tx-checksum-ip-generic: off [fixed]
>          tx-checksum-ipv6: off [fixed]
>          tx-checksum-fcoe-crc: off [fixed]
>          tx-checksum-sctp: off [fixed]
> scatter-gather: on
>          tx-scatter-gather: on
>          tx-scatter-gather-fraglist: off [fixed]
> tcp-segmentation-offload: on
>          tx-tcp-segmentation: on
>          tx-tcp-ecn-segmentation: off [fixed]
>          tx-tcp6-segmentation: off [fixed]
> udp-fragmentation-offload: off [fixed]
> generic-segmentation-offload: on
> generic-receive-offload: on
> large-receive-offload: off [fixed]
> rx-vlan-offload: off [fixed]
> tx-vlan-offload: off [fixed]
> ntuple-filters: off [fixed]
> receive-hashing: off [fixed]
> highdma: off [fixed]
> rx-vlan-filter: off [fixed]
> vlan-challenged: off [fixed]
> tx-lockless: off [fixed]
> netns-local: off [fixed]
> tx-gso-robust: off [fixed]
> tx-fcoe-segmentation: off [fixed]
> tx-gre-segmentation: off [fixed]
> tx-ipip-segmentation: off [fixed]
> tx-sit-segmentation: off [fixed]
> tx-udp_tnl-segmentation: off [fixed]
> tx-mpls-segmentation: off [fixed]
> fcoe-mtu: off [fixed]
> tx-nocache-copy: off
> loopback: off [fixed]
> rx-fcs: off [fixed]
> rx-all: off [fixed]
> tx-vlan-stag-hw-insert: off [fixed]
> rx-vlan-stag-hw-parse: off [fixed]
> rx-vlan-stag-filter: off [fixed]
> l2-fwd-offload: off [fixed]
> busy-poll: off [fixed]
>
>
