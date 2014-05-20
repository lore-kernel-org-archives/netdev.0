From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net-next v2 0/3] net: device features handling fixes
Date: Tue, 20 May 2014 08:29:15 +0200 (CEST)
Message-ID: <cover.1400565116.git.mkubecek@suse.cz>
References: <20140507.140846.1449010184057650775.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Michal Miroslaw <mirq-linux@rere.qmqm.pl>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44335 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750699AbaETG3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2014 02:29:18 -0400
In-Reply-To: <20140507.140846.1449010184057650775.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I think we need to think more about what exact behavior is desired in
> mixed csum feature set cases.  Probably whatever csum offload type is
> the most prevelant should be the one advertised by the master.  It
> means we will do that software checksum fixup for the oddball slaves,
> but it seems the best we can do.

I've been thinking about it some more and I believe what I proposed is
correct: features that are or-ed (ONE_FOR_ALL) should start with 0,
those which are and-ed (ALL_FOR_ALL) with 1.

But once we do that, we have to fix another problem in vlan module:
features of a vlan device are mostly computed as bitwise AND of features
and vlan_features of its underlying device. The problem is checksumming
features don't really behave like independent flags as their main
purpose is to be used in can_checksum_protocol() whose logic is that
HW_CSUM (GEN_CSUM) means "can checksum everything" so that it kind of
contains IP(V6)_CSUM functionality. Therefore intersection of HW_CSUM
and IP(V6)_CSUM should result in the latter.

An alternative approach would be to always set IP(V6)_CSUM once HW_CSUM
(any of GEN_CSUM) is set but as for long time people were taught not to
do that and we even have a warning for it, switching to the exact
opposite could cause a lot of problems.

> Also, like Jay, I agree that whatever we do in bonding needs to be
> done in team too and I'd like the bug fixed at the same time in both
> places.

Agreed. Added a similar patch for teaming driver.

Michal Kubecek (3):
  vlan: more careful checksum features handling
  bonding: fix vlan_features computing
  teaming: fix vlan_features computing

 drivers/net/bonding/bond_main.c |  1 +
 drivers/net/team/team.c         |  2 +-
 include/linux/netdevice.h       | 14 ++++++++++++++
 net/8021q/vlan_dev.c            |  4 ++--
 4 files changed, 18 insertions(+), 3 deletions(-)

-- 
1.8.1.4
