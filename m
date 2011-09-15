From: Dean Nelson <dnelson@redhat.com>
Subject: Re: [PATCH net-next-2.6] e1000: don't enable dma receives until after
 dma address has been setup
Date: Thu, 15 Sep 2011 13:22:31 -0500
Message-ID: <4E724267.2020205@redhat.com>
References: <20110915003138.4279.19020.email-sent-by-dnelson@localhost6.localdomain6> <20110915102112.0000146b@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	tushar.n.dave@intel.com, e1000-devel@lists.sourceforge.net
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23700 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934275Ab1IOSWm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Sep 2011 14:22:42 -0400
In-Reply-To: <20110915102112.0000146b@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/15/2011 12:21 PM, Jesse Brandeburg wrote:
> On Wed, 14 Sep 2011 17:31:38 -0700
> Dean Nelson<dnelson@redhat.com>  wrote:
>
>> Doing an 'ifconfig ethN down' followed by an 'ifconfig ethN up' on a
>> qemu-kvm guest system configured with two e1000 NICs can result in an
>> 'unable to handle kernel paging request at 0000000100000000' or 'bad
>> page map in process ...' or something similar.
>
> <snip>
>
>> The corruption appears to result from the following...
>>
<snip>
>>
>> I realize that in the guest, we're dealing with an e1000 NIC that is
>> software emulated by qemu-kvm. The problem doesn't appear to occur on
>> bare-metal. Andy suspects that this is because in the emulator
>> link-up is essentially instant and traffic can start flowing
>> immediately. Whereas on bare-metal, link-up usually seems to take at
>> least a few milliseconds. And this might be enough to prevent traffic
>> from flowing into the device inside the window where E1000_RCTL_EN is
>> set.
>
> nice analysis dean, yes, we shouldn't enable rx before we have the
> hardware all ready.

Thank you.


> You didn't mention however that the hardware is reset in e1000_down,
> which will clear the RDBAL/RDBAH in real hardware.

You are correct, I did fail to mention the reset. And the clearing of
RDBAL/RDHAH was definitely not happening in the qemu-kvm emulator.


>> So perhaps a modification needs to be made to the qemu-kvm e1000 NIC
>> emulator to delay the link-up. But in defense of the emulator, it
>> seems like a bad idea to enable dma operations before the address of
>> the memory to be involved has been made known.
>
> the hardware reset code in kvm should also reset to default many
> registers (almost all of them in fact) which may also end up solving
> the problem.

Agreed.


>> The following patch no longer enables receives in e1000_setup_rctl()
>> but leaves them however they were. It only enables receives in
>> e1000_configure_rx(), and only after the dma address has been made
>> known to the hardware.
>
> I still like your patch better as it is more correct.  We could also
> correct the kvm virtual hardware driver.

The hardware emulator should definitely be doing a proper hardware reset.


>> There are two places where e1000_setup_rctl() gets called. The one in
<snip>
>>
>> The e1000e looks to have the same issue. I don't know about igb. But
>> I'm not aware of either having hardware emulation in qemu-kvm. So
>> unless this issue is reproducible on bare-metal... it's probably not
>> a big deal for them.
>>
<snip>
>
> generally i like the patch.  We should take it in and test it, and I
> don't really see any problems with it.

Thanks.

As mentioned above, the e1000e has a similar algorithm, but the
FLAG2_NO_DISABLE_RX complicates it a bit. I have no idea what happens
if receives are enabled while setting RDBAL and RDBAH. Is there any
possibility that the hardware could try to make use of a half-baked
address?

Thanks much for your review of the patch.

Dean
