From: Tom Herbert <therbert@google.com>
Subject: Re: Setting RPS affinities from network driver
Date: Fri, 20 Feb 2015 15:05:11 -0800
Message-ID: <CA+mtBx-ZW3jVzaXicGi5okS5egMkfi8-SaDX_ewy-k5zRONfmg@mail.gmail.com>
References: <CA+sq2CeC89YfaTM18JR9dFOoNAbohGk=gFXSkM_4q2oySB12GA@mail.gmail.com>
	<CA+mtBx9qHdEeXmEGbbWSr_OL3aAQJ37eTbC0mUY_XrTNoZ6iXw@mail.gmail.com>
	<CA+sq2CdYSg4NTnyLOMGyF1bmfr0+h+9UJyjJGO2hKEcq4rED8A@mail.gmail.com>
	<CAPFHKzc1+HTOm4PGAnRJ_svjAdZDrK5fMWpYL9Q0RQcPsXCd+Q@mail.gmail.com>
	<CA+mtBx9inCEq7PS3h02tSThsMLBVv5OUrusDkMg7d-OOvmqdiQ@mail.gmail.com>
	<CAPFHKzc-z4LUkxO+nSB=az25ynr=m5KaudQHYNhYi=VtRafEkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sunil Kovvuri <sunil.kovvuri@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jonathon Reinhart <jonathon.reinhart@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:37673 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754554AbbBTXFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 18:05:12 -0500
Received: by iecrl12 with SMTP id rl12so11547684iec.4
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 15:05:11 -0800 (PST)
In-Reply-To: <CAPFHKzc-z4LUkxO+nSB=az25ynr=m5KaudQHYNhYi=VtRafEkw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 20, 2015 at 2:46 PM, Jonathon Reinhart
<jonathon.reinhart@gmail.com> wrote:
> On Fri, Feb 20, 2015 at 5:30 PM, Tom Herbert <therbert@google.com> wrote:
>> On Thu, Feb 19, 2015 at 6:07 PM, Jonathon Reinhart
>> <jonathon.reinhart@gmail.com> wrote:
>>>
>>> I don't know if this is a good idea. It seems like allowing the driver to
>>> set this default configuration opens the door to a whole slew of driver-
>>> specific config customizations.
>>>
>>> As as user, I wouldn't expect one driver to have a different default
>>> value of rps_cpus than another driver. Furthermore, I could imagine a
>>> case where a user expects rps_cpus to default to zero for all of his
>>> NICs, and has other CPU affinity settings applied (think realtime).
>>>
>>> In my opinion, this should be left to userspace. It's not that hard to
>>> add it to your init scripts.
>>>
>>>
>> In the old days I might have agreed with that-- kernel implements
>> mechanism and policy is handled in user space. However, in this brave
>> new world of hardware offloads for more and more kernel networking,
>> I'm not so sure about this any more. It's starting to look like we may
>> want kernel to do more dynamic resource management under some
>> described policies.
>>
>> In davem's keynote at netdev he mentioned that hardware offload should
>> be transparent to things like ip route, so one implication is that at
>> some point the kernel may need to decide which routes are the best to
>> offload per a policy. Also at netdev, Jesse Brandeburg mentioned that
>> Windows had a capabilities of spinning up RSS queues to handle
>> increased load, and lamented that we couldn't do this easily in Linux.
>> Willem deBruijn made RPS resilient under DOS with RPS flow limit as a
>> step in that direction. We have spent countless hours tuning RPS and
>> interrupt settings per platform, per NIC, and per some major
>> applications-- but the resultant init scripts that result are very
>> convoluted and static. It is an interesting idea if we could just tell
>> kernel to take it's best guess and be adaptive. I suppose something
>> like irqbalance is the alternative to do this sort of stuff in user
>> space, but I don't know if that is well deployed or sufficiently
>> reactive under DOS attack.
>
> I agree with your general sentiment, but does it make sense for this to
> be controlled at a per-driver level? The OP indicates that he wants his
> driver to perform well, so he wants to enable RPS for it by default. If the
> RPS policy is to go into the kernel, shouldn't it be done at the global
> scope?
>
Right, that's what I meant by putting it into a library. RPS is not
something that is driver specific configuration.

> Note that this argument is different from RSS where we're dealing with
> actual hardware queues, so the driver of course has a say in the
> configuration.
>
Assuming that all queues are equal and we have a standard way to
influence the indirection table, even RSS configuration really isn't
driver specific configuration. We just need to know how many queues
are available.

> Going on with what you alluded to, I think if the kernel were to have a say
> in the RPS configuration, there would need to be some sort of global on/off
> switch.

Yes, but I think it's more that an on/off switch. There could be some
canned configurations like "one RX queue per CPU", "one per numa
node", etc. Also, RPS configuration is a part of that. For one queue
per CPU, RPS should probably be off. For one queue per numa node it's
seems common for RPS of that queue to be on the other nodes.

I have no doubt that Sunil didn't bargain for all this in posting his
patches ;-), but it does seem to be seeds for a broader network
resource manager in kernel!

Tom
