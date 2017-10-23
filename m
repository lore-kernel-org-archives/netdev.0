From: Steve Lin <steven.lin1@broadcom.com>
Subject: Re: [PATCH net-next v2 5/6] devlink: Adding num MSI-X vectors per VF
 NVRAM config param
Date: Mon, 23 Oct 2017 12:35:32 -0400
Message-ID: <CA+Jmh7F-8JXoHG78W-Pn_XndzDGK3MQ2QSMRkiU3g73zDA=AhQ@mail.gmail.com>
References: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
 <1508440630-25830-6-git-send-email-steven.lin1@broadcom.com>
 <AM0PR0502MB368347E87E48F7EB04AF1513BF420@AM0PR0502MB3683.eurprd05.prod.outlook.com>
 <20171019213955.GG1978@nanopsycho.orion> <CA+Jmh7HCC-CgU16E8vSm541KnNUKZUgWfT0tPVx73cJxREC0Ag@mail.gmail.com>
 <20171020141010.GB1994@nanopsycho.orion> <CA+Jmh7FT789PfH908KK+x1+ehrvbiaaovori1w9yWe7+CFhFTg@mail.gmail.com>
 <AM0PR0502MB368337378712D3A48EDEF6C8BF400@AM0PR0502MB3683.eurprd05.prod.outlook.com>
 <CA+Jmh7H3QD4W6OrVwny7CXVppGZ4R6GeTh30Sm9sTikk7560dQ@mail.gmail.com> <AM0PR0502MB3683E269475F183C7953B8B3BF460@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jiri Pirko <jiri@resnulli.us>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "michael.chan@broadcom.com" <michael.chan@broadcom.com>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "gospo@broadcom.com" <gospo@broadcom.com>
To: Yuval Mintz <yuvalm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:43411 "EHLO
        mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751695AbdJWQfy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 12:35:54 -0400
Received: by mail-qk0-f171.google.com with SMTP id w134so22743941qkb.0
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 09:35:53 -0700 (PDT)
In-Reply-To: <AM0PR0502MB3683E269475F183C7953B8B3BF460@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 23, 2017 at 10:37 AM, Yuval Mintz <yuvalm@mellanox.com> wrote:
>> >> On Fri, Oct 20, 2017 at 10:10 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> >> > Fri, Oct 20, 2017 at 04:03:55PM CEST, steven.lin1@broadcom.com wrote:
>> >> >>On Thu, Oct 19, 2017 at 5:39 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> >> >>> Thu, Oct 19, 2017 at 10:32:21PM CEST, yuvalm@mellanox.com wrote:
>> >> >>>>> Adding DEVLINK_PERM_CONFIG_MSIX_VECTORS_PER_VF
>> >> permanent
>> >> >>>>> config
>> >> >>>>> parameter.  Defines number of MSI-X vectors allocated per VF.
>> >> >>>>> Value is permanent (stored in NVRAM), so becomes the new
>> default
>> >> >>>>> value for this device.
>> >> >>>>
>> >> >>>>Sounds like you're having this enforce the same configuration for all
>> >> child VFs.
>> >> >>>
>> >> >>> Yeah, this sounds like per-port config.
>> >> >>>
>> >> >>
>> >> >>Well, it gets a little tricky here.  I assume some cards handle this
>> >> >>per-port.  Other cards might handle this per PF, where PF may not
>> >> >>always correspond 1:1 with a port.  And some cards maybe just allow a
>> >> >>single value for this parameter for the entire card, covering all
>> >> >>ports/PFs.
>> >> >>
>> >> >>To keep things simple and as general as possible, it made sense to set
>> >> >>all parameters on a per-PCI device level.  As I mentioned in my
>> >> >>cover-letter, the devices most likely to use these proposed commands
>> >> >>do not have a single "whole asic" PCI b/d/f with internal mechanism
>> >> >>for accessing ports - most expose each port (and each function on each
>> >> >>port) as a separate PCI b/d/f, with no separate "whole asic" PCI
>> >> >>b/d/f.  That's how the BCM cards work, and I think that's how the
>> MLNX
>> >> >>cards work, and others that would be likely to use these cmds.
>> >> >>
>> >> >>So, to summarize, you direct the command to the PCI b/d/f you want
>> to
>> >> >>target.  Does this make sense?
>> >> >
>> >> > So you plan to have 1 devlink instance for each vf? Not sure that
>> >> > does sound right to me :/
>> >> >
>> >>
>> >> For the commands proposed in this patchset, AFAIK they all apply on a
>> >> per-PF or broader, i.e. per-port or whole-card, granularity, since
>> >> they affect permanent config that applies at boot-up.  So, no, the VFs
>> >> don't really come into play here.
>> >
>> > Regardless of whether you're planning on having VFs as devlink instances,
>> > the actual attribute question remains -
>> > you're proposing an attribute that forces all VFs to have the same value.
>> > This probably suits your PCI core limitations but other vendors might have
>> > a different capability set, and accepting this design limitation now would
>> > muck all future extension attempts of such attributes.
>> >
>> > I think VF configurations should be planned in advance for supporting a
>> > per-VF Configuration whenever it's possible - even if not required
>> [/possible]
>> > by the one pushing the new attribute.
>> >
>>
>> The commands being added in this patch are for permanent (i.e. NVRAM)
>> config - essentially setting the new default values for various
>> features of the device at boot-up.  At that initialization time, no
>> VFs are yet instantiated.
>>
>> So my perspective was, in general (not just for our specific device /
>> design), it doesn't seem like permanent config parameters would be set
>> on individual VFs.  That was what my previous comment was trying to
>> convey.
>
> That's an odd assumption; Why should you assume there's some device
> that allows configuring persistent behavior for all VFs but think no other
> would set the same on a per-VF basis?
>
>> If that assumption is wrong, though, and there is some device that has
>> NVRAM config that is set per-VF, I assume the user would instantiate
>> the VF and then call the devlink API on the pci device corresponding
>> to the VF they with to affect, and I think the model proposed still
>> works.
>
> What would be the purpose of re-configuring a value reflected in the
> PCI device for an already instantiated VF?
>
>> Are you suggesting adding a mechanism to set NVRAM parameters on a
>> per-VF basis, without instantiating the VF first?  I would prefer not
>> adding such a mechanism unless/until there's a use case for it.
>
> The thing is that you're suggesting a new UAPI; We don't have the leisure
> of pushing a partial implementation and changing it later on.

I hope we're not talking past each other because I'm not sure we're
saying the same thing.  But if you have a device which has NVRAM
config on an individual VF basis, and you want to be able to get/set
that configuration without instantiating the VF first (i.e. without a
PCI device to operate on), then one way to handle this is with a new
attribute, DEVLINK_ATTR_PERM_CONFIG_VF_INDEX, for example.

It could be sent in the nested DEVLINK_ATTR_PERM_CONFIG attribute,
along with the existing DEVLINK_ATTR_PERM_CONFIG_PARAMETER and _VALUE,
to indicate a specific VF within the PF that you are targeting.

That seems like the type of thing that could be added later, if/when
such a device needed support, without breaking the UAPI, couldn't it?
