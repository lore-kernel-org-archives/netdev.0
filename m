From: Alexander Graf <agraf@suse.de>
Subject: Re: [PATCH] igb: Indicate failure on vf reset for empty mac address
Date: Thu, 09 Oct 2014 01:45:08 +0200
Message-ID: <5435CC84.401@suse.de>
References: <1412803407-10621-1-git-send-email-agraf@suse.de> <1412807355.2260.17.camel@jtkirshe-mobl.jf.intel.com> <4F8303E0-EA1B-4D93-B898-10ACD072F404@suse.de> <AAEA33E297BCAC4B9BB20A7C2DF0AB8D65765AC1@FMSMSX113.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Stefan Assmann <sassmann@kpanic.de>,
	"Brown, Aaron F" <aaron.f.brown@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:59922 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752229AbaJHXpL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2014 19:45:11 -0400
In-Reply-To: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D65765AC1@FMSMSX113.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09.10.14 01:33, Williams, Mitch A wrote:
> 
> 
>> -----Original Message-----
>> From: Alexander Graf [mailto:agraf@suse.de]
>> Sent: Wednesday, October 08, 2014 3:39 PM
>> To: Kirsher, Jeffrey T
>> Cc: David S. Miller; netdev@vger.kernel.org; Williams, Mitch A; Andy
>> Gospodarek; Stefan Assmann; Brown, Aaron F; Rose, Gregory V; Ronciak, John
>> Subject: Re: [PATCH] igb: Indicate failure on vf reset for empty mac address
>>
>>
>>
>>
>>> Am 09.10.2014 um 00:29 schrieb Jeff Kirsher <jeffrey.t.kirsher@intel.com>:
>>>
>>>> On Wed, 2014-10-08 at 23:23 +0200, Alexander Graf wrote:
>>>> Commit 5ac6f91d changed the igb driver to expose a zero (empty) mac
>>>> address to the VF on reset rather than a random one.
>>>>
>>>> However, that behavioral change also requires igbvf driver changes
>>>> which can be hard especially when we want to talk to proprietary
>>>> guest OSs.
>>>>
>>>> Looking at the code previous to the commit in Linux that made igbvf
>>>> work with empty mac addresses (8d56b6d), we can see that on reset
>>>> failure the driver will try to generate a new mac address with both
>>>> the old and the new code.
>>>>
>>>> Furthermore, ixgbe does send reset failure when it detects an empty
>>>> mac address (35055928c).
>>>>
>>>> So I think it's safe to make igb behave the same. With this patch I
>>>> can successfully run a Windows 8.1 guest with an empty mac address
>>>> and an assigned igbvf device that has no mac address set by the host.
>>>>
>>>> If anyone is aware of a guest driver that chokes on NACK returns of
>>>> VF RESET commands, please speak up.
>>>>
>>>> Signed-off-by: Alexander Graf <agraf@suse.de>
>>>> ---
>>>> drivers/net/ethernet/intel/igb/igb_main.c | 8 ++++++--
>>>> 1 file changed, 6 insertions(+), 2 deletions(-)
>>>
>>> Actually after further review of this patch and the reported bug in
>>> SuSE's bugzilla, we are NACK'ing this patch.
>>>
>>> If the reset has not failed, why are we indicating that it has?
>>
>> Very good question. It's what the ixgbe driver does and older Linux, newer
>> Linux as well as Windows seem to interpret it as "I need to generate a mac
>> address".
>>
>> I have no idea whether that's the intended meaning of a reset nack, but if
>> it isn't, ixgbe probably shouldn't nack it either then.
>>
>> Is the mbox message protocol documented anywhere? I could only find
>> references to register layouts so far, but nothing about the comminucation
>> on top of them.
>>
>>> We
>>> originally supplied the VF with a NULL MAC, so we should supply it
>>> again.  That way, the VF can choose to either regenerate a new random
>>> MAC or keep using the one that it had.
>>
>> Where is this documented? And why doesn't ixgbe adhere to this?
>>
>>> The current method was a fix that was requested by the community in the
>>> first place, also we cannot take into account "proprietary guest OS's".
>>
>> I don't think I understand this comment. "The community" is a very broad
>> term in Linux ;). Also, this patch merely moves igb to behave identically to
>> ixgbe in how it tells an igbvf driver that the mac address is empty. Nothing
>> changes wrt the original change to not generate random mac addresses. That
>> stays identical.
>>
>>
>> Alex
> 
> Alex, I can't speak for ixgbe - I've never worked on that driver. However, for igb and igbvf, I was the one who changed the MAC address generation code, at the request of the Linux networking community. In general, the PF driver provides a valid MAC to the VF driver if and only if the user has assigned a fixed MAC address for that VF on the command line. Otherwise, the VF driver gets all zeros, and it knows to generate its own random MAC address. This was done so that the VF would know when it was using a random MAC address and be able to inform the stack (and, eventually, udev). This kept udev from creating a new interface name each time the VF was booted.

Yup, makes a lot of sense.

> 
> On a reset, the PF should not generate a new MAC address for the VF driver. It shouldn't do anything with the VF MAC, except report what it knows to the VF driver - either all zeros, or the address assigned by the user. It's up to the VF driver to know what to do.

Well, semantically you want to tell the guest "I don't have a mac
address" or "this is your mac address". Whether the former is encoded in
an empty mac address is really an implementation detail I suppose.

> 
> And the PF should not lie to the VF driver and tell it that reset failed. That's just incorrect.
> 
> Yes, there are some older Linux and Windows VF drivers that don't know what to do in this situation. But we made this change almost two years ago, and all of our current drivers (both Windows and Linux) do the right thing.
> 
> If you have a bug to report against a current Windows or Linux VF driver, please let us know. We will be happy to help. 

Sure! So what I did was that I picked a recent Windows 8.1 installation
and ran it in a VM. Then I assigned the VF to it and it just borked at
me ;).

Apparently 2 years weren't enough for the driver to trickle into the
latest released version of Windows.

> 
> If you have another proprietary OS that doesn't work, then you need to fix that VF driver, not the PF driver. The Linux kernel community will not accept a change that is only made to support a non-Linux guest.

The interface in question is a guest interface. Breaking it in the first
place was probably not a very good decision. Instead, it would've been
better to enhance the protocol so that instead of sending a "1" command,
you would send another command that indicates to the PF driver that the
guest knows how to react to an empty mac address. For the old "1"
command you could've returned randomly generated mac addresses still, or
failed the request altogether (which coincidentally would've made it
work too). But it's probably too late for that :).

> In any case, this patch is not correct, so we have responded with a NAK.

So we're stuck in a nasty situation here. There are 2 problems that I
can see:

  1) User experience is horrible. There is no way mortals will find out
why their VFs don't work in VMs with Windows. It's good for our business
model of paid support, but probably not in Intel's best interest ;)

  2) Igb and ixgbe implement an incredibly similar protocol between VF
and PF, yet are inconsistent in how they react to the reset function. I
dislike inconsistencies :)

I agree that failing the reset sounds odd, but why does the ixgbe driver
do it? And why do the Linux and Windows drivers recover properly from
that failure? Someone must've thought of that case, no?


Alex
