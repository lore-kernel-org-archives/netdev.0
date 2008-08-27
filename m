From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: [sky2, solved] transmit timeouts and firmware update...
Date: Thu, 28 Aug 2008 00:16:17 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808280014460.1320@bizon.gios.gov.pl>
References: <6278d2220808250742r4a2b377al13a516fa0c6b53a9@mail.gmail.com>  <alpine.LNX.1.10.0808252048440.25225@bizon.gios.gov.pl>  <20080825152206.2d554cf7@speedy> <20080827132727.1851cfba@extreme>  <6278d2220808271437r1d6851dbg84e26054d4f3deed@mail.gmail.com>
  <20080827144218.5c1d2439@extreme>  <6278d2220808271448h155494a0kfdcd155f0de18ee0@mail.gmail.com> <6278d2220808271458i3109d9a1l2529ec6f60ff1421@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1144830174-241411354-1219875377=:1320"
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Linux Netdev <netdev@vger.kernel.org>,
	Linux Networking <linux-net@vger.kernel.org>
To: Daniel J Blueman <daniel.blueman@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:55518 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874AbYH0Wbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 18:31:43 -0400
In-Reply-To: <6278d2220808271458i3109d9a1l2529ec6f60ff1421@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1144830174-241411354-1219875377=:1320
Content-Type: TEXT/PLAIN; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 8BIT



On Wed, 27 Aug 2008, Daniel J Blueman wrote:

> On Wed, Aug 27, 2008 at 10:48 PM, Daniel J Blueman
> <daniel.blueman@gmail.com> wrote:
>> On Wed, Aug 27, 2008 at 10:42 PM, Stephen Hemminger
>> <shemminger@vyatta.com> wrote:
>>> On Wed, 27 Aug 2008 22:37:51 +0100
>>> "Daniel J Blueman" <daniel.blueman@gmail.com> wrote:
>>>
>>>> On Wed, Aug 27, 2008 at 9:27 PM, Stephen Hemminger
>>>> <shemminger@vyatta.com> wrote:
>>>>> On Mon, 25 Aug 2008 15:22:06 -0400
>>>>> Stephen Hemminger <shemminger@vyatta.com> wrote:
>>>>>
>>>>>> On Mon, 25 Aug 2008 21:03:25 +0200 (CEST)
>>>>>> Krzysztof Oledzki <ole@ans.pl> wrote:
>>>>>>
>>>>>>>
>>>>>>>
>>>>>>> On Mon, 25 Aug 2008, Daniel J Blueman wrote:
>>>>>>>
>>>>>>>> I (and a lot of other users) have been experiencing the frequent sky2
>>>>>>>> transmit timeout problem [1] (on 88E8053/Yukon2 EC gig hardware); this
>>>>>>>> is a result of the embedded NIC controller locking up, and I've found
>>>>>>>> that updating the firmware addresses this issue. I'm still seeing a
>>>>>>>> previous and different issue [2] from time to time though (silicon
>>>>>>>> bug?).
>>>>>>>
>>>>>>> Thanks for the info. I've been dealing with this problem for some long
>>>>>>> time, hopefully sky driver from the latest kernels is able to recover
>>>>>>> from such hangs, so it is not that critical problem now.
>>>>>>>
>>>>>>>> Marvell shipping broken firmware is completely unpublicised or
>>>>>>>> acknowledged, however updated firmware is available through your
>>>>>>>> motherboard vendor, so all hope it not lost after all...
>>>>>>>
>>>>>>> Unfortunately not through all vendors. :( Or maybe not *yet*?
>>>>>>>
>>>>>>>> My 8053/EC is using firmware 2.2 (previously 1.9) - you can check in
>>>>>>>> DOS with 'yukondg.exe' from
>>>>>>>> http://www.marvell.com/drivers/files/yukondg_v6.53.4.3.zip .
>>>>>>>
>>>>>>> Stephen, is it possible for sky2 driver to check and print the
>>>>>>> firmware version?
>>>>>>
>>>>>> It is possible to dump and program eeprom from linux, and the version
>>>>>> maybe buried in the VPD, but some hardware has non-functional VPD.
>>>>>
>>>>> The revision number in the VPD matches the revision number (from PCI)
>>>>> that is already printed by the driver. Since I don't have enough documentation
>>>>> on the firmware to know the format, there is no way to print anything
>>>>> really useful.
>>>>
>>>> $ lspci -d11ab:
>>>> 02:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053
>>>> PCI-E Gigabit Ethernet Controller (rev 22)
>>>> 07:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8036
>>>> PCI-E Fast Ethernet Controller (rev 15)
>>>>
>>>> $ dmesg | grep sky2.*rev
>>>> [   33.998133] sky2 0000:02:00.0: v1.20 addr 0xd6000000 irq 16
>>>> Yukon-EC (0xb6) rev 2
>>>> [   33.999085] sky2 0000:07:00.0: v1.20 addr 0xd8000000 irq 18
>>>> Yukon-FE (0xb7) rev 1
>>>>
>>>> The 'rev' reported by the driver is from:
>>>>
>>>>         hw->chip_rev = (sky2_read8(hw, B2_MAC_CFG) & CFG_CHIP_R_MSK) >> 4;
>>>>
>>>> which is the chip/silicon revision, whereas the rev reported by the
>>>> PCI device is the firmware revision, as you've found.
>>>>
>>>> How about:
>>>>
>>>> 02:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053
>>>> PCI-E Gigabit Ethernet Controller (silicon rev 2, firmware/PCI rev 22)
>>>>
>>>> This introduces perhaps something even more useful - we know there are
>>>> really major issues with (eg) 88E8053 before firmware 2.2; is it worth
>>>> adding a warning, such as:
>>>>
>>>> sky2: firmware earlier than rev 2.2 detected - if you experience
>>>> transmit timeouts, ask vendor for 88E8053 firmware update
>>>>
>>>> There are a lot of bug reports on the web pointing the finger at the
>>>> sky2 driver, and waiting for a 'fixed' version, but the issue is
>>>> elsewhere...part of the problem, if there is (almost) no
>>>> documentation/evidence of this problem posted anywhere.
>>>>
>>>> Many thanks,
>>>>   Daniel
>>>
>>> lspci reports PCI rev.  driver reports chip rev.
>>
>> But the PCI revision is also the firmware revision - I didn't know
>> this until you mentioned it, so it would be handy to make it explicit
>> in the driver's output; also we don't always have the 'lspci' output
>> in bug reports. Let me know if you'd like a patch...
>
> Here [1] it is.
>
> Signed-off-by: Daniel J Blueman <daniel.blueman@gmail.com>
> Description: Differentiate and print PCI and firmware revision against
> silicon/chip revision
>
> --- [1]
>
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index e24b25c..676a22f 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -4206,6 +4206,7 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
> 	struct sky2_hw *hw;
> 	int err, using_dac = 0, wol_default;
> 	char buf1[16];
> +	unsigned char pci_rev;
>
> 	err = pci_enable_device(pdev);
> 	if (err) {
> @@ -4276,10 +4277,11 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
> 	if (err)
> 		goto err_out_iounmap;
>
> -	dev_info(&pdev->dev, "v%s addr 0x%llx irq %d Yukon-2 %s rev %d\n",
> +	pci_read_config_byte(pdev, PCI_REVISION_ID, &pci_rev);
> +	dev_info(&pdev->dev, "v%s addr 0x%llx irq %d Yukon-2 %s silicon rev %d, firmware/PCI rev %d\n",
...rev %u.%u\n"?


> 		 DRV_VERSION, (unsigned long long)pci_resource_start(pdev, 0),
> 		 pdev->irq, sky2_name(hw->chip_id, buf1, sizeof(buf1)),
> -		 hw->chip_rev);
> +		 hw->chip_rev, pci_rev);
pci_rev/10, pci_rev%10?

Best regards,

 				Krzysztof Olêdzki
---1144830174-241411354-1219875377=:1320--
