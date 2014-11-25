From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v3 09/17] bridge: add API to notify bridge
 driver of learned FBD on offloaded device
Date: Tue, 25 Nov 2014 22:36:43 +0000
Message-ID: <20141125223643.GH3912@casper.infradead.org>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-10-git-send-email-jiri@resnulli.us>
 <20141125163853.GJ27416@gospo.rtplab.test>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, jhs@mojatatu.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, bcrl@kvack.org
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56884 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486AbaKYWgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 17:36:48 -0500
Content-Disposition: inline
In-Reply-To: <20141125163853.GJ27416@gospo.rtplab.test>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 at 11:38am, Andy Gospodarek wrote:
> On Tue, Nov 25, 2014 at 11:28:40AM +0100, Jiri Pirko wrote:
> > From: Scott Feldman <sfeldma@gmail.com>
> > 
> > When the swdev device learns a new mac/vlan on a port, it sends some async
> > notification to the driver and the driver installs an FDB in the device.
> > To give a holistic system view, the learned mac/vlan should be reflected
> > in the bridge's FBD table, so the user, using normal iproute2 cmds, can view
> > what is currently learned by the device.  This API on the bridge driver gives
> > a way for the swdev driver to install an FBD entry in the bridge FBD table.
> > (And remove one).
> > 
> > This is equivalent to the device running these cmds:
> > 
> >   bridge fdb [add|del] <mac> dev <dev> vid <vlan id> master
> > 
> > This patch needs some extra eyeballs for review, in paricular around the
> > locking and contexts.
> > 
> > Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> > Signed-off-by: Jiri Pirko <jiri@resnulli.us>

I like the simplicity of this. That said, given we'll have multiple
users of swdev including OVS, shouldn't this be a notifier or a
callback that depends on who is controlling the device?

> > +	spin_lock(&br->hash_lock);
> (Since you asked to check locking...)
> 
> Most of the other fdb_add/delete/insert/update calls take this with
> spin_lock_bh.  Did you try this with lockdep enabled just to see if that
> is needed here?  I suspect that anytime br->hash_lock is taken it will
> need to be with softirqs disabled from this point forward.

At least br_fdb_update() seems to be called from BH context so I would
agree and argue the lock in br_fdb_cleanup() and br_fdb_update() need a
fix too. I'll send a patch.
