From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 08/16] net/devlink: Add E-Switch mode control
Date: Thu, 30 Jun 2016 00:33:49 +0300
Message-ID: <CAJ3xEMgGCW_P-sb3pe1KqMVoKe4BWKoO88_O364nwEU6bDnaoA@mail.gmail.com>
References: <1467043649-28594-1-git-send-email-saeedm@mellanox.com>
 <1467043649-28594-9-git-send-email-saeedm@mellanox.com> <577211E2.90802@gmail.com>
 <28223ec8-f105-d598-39ad-5dc93598dc64@mellanox.com> <5772A397.3010905@gmail.com>
 <5772B18A.9000300@gmail.com> <20160628184655.GB2089@nanopsycho.orion>
 <5772CA20.4030002@intel.com> <20160628191230.GC2089@nanopsycho.orion>
 <5772D091.9030709@gmail.com> <0327b6de-dfdf-8db2-1354-b7a4144dbc02@mellanox.com>
 <5773F8CC.4090300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>, Jiri Pirko <jiri@resnulli.us>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Ido Schimmel <idosch@mellanox.com>,
	Tal Anker <Ankertal@mellanox.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:36686 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751997AbcF2Vdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 17:33:51 -0400
Received: by mail-ob0-f172.google.com with SMTP id mu6so44728235obc.3
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 14:33:51 -0700 (PDT)
In-Reply-To: <5773F8CC.4090300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 29, 2016 at 7:35 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> On 16-06-29 07:48 AM, Or Gerlitz wrote:
>> On 6/28/2016 10:31 PM, John Fastabend wrote:
>>> On 16-06-28 12:12 PM, Jiri Pirko wrote:

>>>> Why?! Please, leave legacy be legacy. Use the new mode for
>>>> implementing new features. Don't make things any more complicated :(

[...]
>>> Maybe I'm reading to much into the devlink flag names and if instead
>>> you use a switch like the following,

>>>    VF representer : enable/disable the creation VF netdev's to represent
>>>                     the virtual functions on the PF

>>> Much less complicated then magic switching between forwarding logic IMO
>>> and you don't whack a default configuration that an entire stack (e.g.
>>> libvirt) has been built to use.

>> Re letting the user to observe/modify the rules added by the
>> driver/firmware while legacy mode. Even if possible with bridge/fdb, it
>> will be really pragmatical and doesn't make sense to get that donefor
>> the TC subsystem. So this isn't a well defined solution and anyway, as
>> you said, legacy mode enhancements is a different exercise. Personally,
>> I agree with Jiri, that we should legacy be legacyand focus on adding
>> the new model.

> The ixgbe driver already supports bridge and tc commands without the VF
> representer.  Adding the VF representer to these drivers just extends
> the existing support so we have an identifier for VFs and now the
> redirect action works and the fdb commands can specify the VF netdevs.
> I don't see this as a problem because we already do it today with
> 'ip' and bridge tools.

To be precise, for both ixgbe and mlx5, the existing tc support
(u32/ixgbe, flower/mlx5) is not for switching functionality but rather
for NIC-ish one, e.g drop, mark, etc. Indeed in ixgbe you added
redirect to VF, but this is only for south --> north (wire --> VF)
traffic, w.o the VF rep you can't do the other way around.

Just to clarify, to what exact bridge command support did you refer for ixgbe?

The forwarding done in the legacy mode is not well defined, and
different across vendors, adding there the VF reps will not make it
any better b/c some steering rules will be set by tc/bridge offloads
while other rules will be put by the driver.
I don't see how this takes us to better place.

> We are also slightly in disagreement about what the default should be
> with VF netdevs. I think the default should be the same L2 mac/vlan
> switch behavior and see no reason to change it by default just because
> we added VF netdevs. The infrastructure libvirt/openstack/etc are built
> around this default today. But I guess nothing in this series specifies
> what the defaults of any given driver will be. VF netdevs are still
> useful even on older hardware that only supports mac/vlan forwarding to
> expose statistics and send/receive control frames such as lldp.

Again, this is not about default engineering... and using the VF reps
(not VF netdevs) in legacy mode only make it more cryptic to my
opinion. I agree some changes would be needed in openstack to support
the new model, but this is how progress is made... you can't always
make all layer above you unchanged. Note that the VF reps behave the
same as tap devices (v-switch doing xmit on tap --> recv in VM, VM
sends --> recv on tap into the v-switch), so the change in open-stack
would not be that big.

[...]

> Why I think the VF representer is a per port ethtool flag and not a
> devlink option is my use case might be to assign a PF into a VM or
> namespace where I don't want VF netdevs.

again, we think the correct place to set how the eswitch is managed is
through eswitch manager PCI devices and not net devices and hence
ethtool is not the way to go.

Also, how do you want your e-switch to be managed in this case?
