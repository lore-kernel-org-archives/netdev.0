From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC 1/4] net: support per queue tx_usecs in sysfs
Date: Tue, 1 Dec 2015 17:57:45 -0800
Message-ID: <CAKgT0Udmm9UbQjC3Zcikykcd7e_yvoPayFXA6Kq+TZ_hbqi-4Q@mail.gmail.com>
References: <1448956892-15509-1-git-send-email-kan.liang@intel.com>
	<565E1B8E.4040603@gmail.com>
	<20151201154454.000041a3@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>, kan.liang@intel.com,
	Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Scott Feldman <sfeldma@gmail.com>,
	andy gospodarek <gospo@cumulusnetworks.com>,
	sasha.levin@oracle.com, David Ahern <dsahern@gmail.com>,
	tj@kernel.org, cascardo@redhat.com, corbet@lwn.net
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:34521 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753637AbbLBB5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 20:57:45 -0500
Received: by ioir85 with SMTP id r85so30610355ioi.1
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 17:57:45 -0800 (PST)
In-Reply-To: <20151201154454.000041a3@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 1, 2015 at 3:44 PM, Jesse Brandeburg
<jesse.brandeburg@intel.com> wrote:
> On Tue, 1 Dec 2015 14:13:34 -0800
> Florian Fainelli <f.fainelli@gmail.com> wrote:
>
>> On 01/12/15 00:01, kan.liang@intel.com wrote:
>> > From: Kan Liang <kan.liang@intel.com>
>> >
>> > Network devices usually have many queues. Each queue has its own
>> > tx_usecs options. Currently, we can only set all the queues with same
>> > value by ethtool. This patch expose the tx_usecs in sysfs. So the user
>> > can set/get per queue coalesce parameter tx_usecs by sysfs.
>>
>> The new interface you propose makes things inconsistent, since we have
>> two separate configuration paths (sysfs and ethtool), and it would seem
>> better to have per-queue awareness in ethtool, since there is a whole
>> bunch of other parameters that could be configured on a per-queue basis.
>>
>> Have you tried to extend existing ethtool interfaces to cover the need
>> for multiple queues?
>
> While I agree that ethtool provides a similar functionality, ethtool
> was designed (particularly the ethtool -C/c commands) around one queue
> NICs.  We can't change the output or functionality of the user
> interface without breaking a bunch of user's scripts and stuff.

Actually it seems like it should be fairly easy to extend the existing
interface.  If for example you were to add a couple new keywords such
as rx-queue or tx-queue what you could do is make it so that you would
then specifically overwrite or access the values of a given Tx queue
or Rx queue instead of doing it generically for the entire device.

> With this effort, Kan is laying groundwork for making further kernel
> changes, and having the kernel call back in to drivers via ethtool
> mechanisms that were designed before multiple queue adapters.
>
> We can also next migrate the legacy ethtool interfaces to use these
> new .ndo_ops should we wish.

Maybe that is the path this should start taking now.  Another thing to
keep in mind is that not all drivers make use of the rx-usecs value
the way the Intel drivers do.  As such we need to be able to still
support all the various interrupt moderation types that are supported
by any NICs that might make use of this feature.

> These patches were provided with the intent of getting some feedback
> about going down this path of making a *consistent* user interface that
> is driver agnostic in sysfs, and supports multiple queue adapters.

If you are truly going for something that is driver agnostic you need
to start looking at other drivers.  For example I don't see how this
current implementation deals with the tx/rx_frames values provided in
the mlx4 drivers for their interrupt moderation.  Also it seems like
the assumption here is that you are going to want to run all of the
queues statically without allowing dynamic interrupt moderation.  I
would think that this might be something that could be managed per
queue as well.
