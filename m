From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v3 09/17] bridge: add API to notify bridge driver
 of learned FBD on offloaded device
Date: Tue, 25 Nov 2014 15:48:04 -1000
Message-ID: <CAE4R7bApe59sT6G2oORWP=jOOy=h=Da=EQq98fzR1s+ESZOGFQ@mail.gmail.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
	<1416911328-10979-10-git-send-email-jiri@resnulli.us>
	<20141125163853.GJ27416@gospo.rtplab.test>
	<20141125223643.GH3912@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cu
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:65131 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146AbaKZBsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 20:48:06 -0500
Received: by mail-wi0-f175.google.com with SMTP id l15so11028231wiw.2
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 17:48:05 -0800 (PST)
In-Reply-To: <20141125223643.GH3912@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 12:36 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 11/25/14 at 11:38am, Andy Gospodarek wrote:
>> On Tue, Nov 25, 2014 at 11:28:40AM +0100, Jiri Pirko wrote:
>> > From: Scott Feldman <sfeldma@gmail.com>
>> >
>> > When the swdev device learns a new mac/vlan on a port, it sends some async
>> > notification to the driver and the driver installs an FDB in the device.
>> > To give a holistic system view, the learned mac/vlan should be reflected
>> > in the bridge's FBD table, so the user, using normal iproute2 cmds, can view
>> > what is currently learned by the device.  This API on the bridge driver gives
>> > a way for the swdev driver to install an FBD entry in the bridge FBD table.
>> > (And remove one).
>> >
>> > This is equivalent to the device running these cmds:
>> >
>> >   bridge fdb [add|del] <mac> dev <dev> vid <vlan id> master
>> >
>> > This patch needs some extra eyeballs for review, in paricular around the
>> > locking and contexts.
>> >
>> > Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> > Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
> I like the simplicity of this. That said, given we'll have multiple
> users of swdev including OVS, shouldn't this be a notifier or a
> callback that depends on who is controlling the device?

I like the idea.  When the switch port joins Linux bridge or OVS
datapath, a callback is registered with the driver.  That way the
driver doesn't really care if the port is a bridge member or an OVS
vport in a datapath.  It's just passing up the FDB entry
(port/mac/vlan) details to the container device.  Can we hold this
idea until this patchset sticks?  I think once OVS support comes back
into the swdev model would be the time to address this.

>
>> > +   spin_lock(&br->hash_lock);
>> (Since you asked to check locking...)
>>
>> Most of the other fdb_add/delete/insert/update calls take this with
>> spin_lock_bh.  Did you try this with lockdep enabled just to see if that
>> is needed here?  I suspect that anytime br->hash_lock is taken it will
>> need to be with softirqs disabled from this point forward.
>
> At least br_fdb_update() seems to be called from BH context so I would
> agree and argue the lock in br_fdb_cleanup() and br_fdb_update() need a
> fix too. I'll send a patch.
