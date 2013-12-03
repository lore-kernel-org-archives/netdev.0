From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net 1/7] bridge: Fix the way finding the old local fdb
 entry in br_fdb_changeaddr
Date: Tue, 03 Dec 2013 21:55:26 +0900
Message-ID: <1386075326.4038.66.camel@ubuntu-vm-makita>
References: <1385966439-26526-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <1385966439-26526-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <20131202180917.1e844dde@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:46172 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753478Ab3LCMzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 07:55:33 -0500
In-Reply-To: <20131202180917.1e844dde@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-02 at 18:09 -0800, Stephen Hemminger wrote:
> On Mon,  2 Dec 2013 15:40:32 +0900
> Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:
> 
> > br_fdb_changeaddr() assumes that there is at most one local entry per port
> > per vlan. It used to be true, but since commit 36fd2b63e3b4 ("bridge: allow
> > creating/deleting fdb entries via netlink"), it has been not.
> > Therefore, the function might fail to search a correct previous address
> > to be deleted and delete an arbitrary local entry if user has added local
> > entries manually.
...
> > diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> > index 229d820..0902658 100644
> > --- a/net/bridge/br_private.h
> > +++ b/net/bridge/br_private.h
> > @@ -195,6 +195,7 @@ struct net_bridge_port
> >  #ifdef CONFIG_BRIDGE_VLAN_FILTERING
> >  	struct net_port_vlans __rcu	*vlan_info;
> >  #endif
> > +	mac_addr			prev_addr;
> >  };
> 
> There must be a better way without all this extra book keeping which risks
> getting out of sync.

Another approach I can conceive is:
- Make fdb entries be able to be differentiated from those user added
  by introducing a flag in struct net_bridge_fdb_entry. 

Though this approach will be less efficient, it doesn't require to track
address changes. It will need to set a flag only when adding fdb
entries.

How do you think about it?

> IT seems to me that NETDEV_CHANGEADDR should not
> be notified (from core) if old == new address.

I'm afraid that user space will be affected if doing so because
br_device_event() notifies RTM_NEWLINK when receiving NETDEV_CHANGEADDR
and another subsystem might do that though I'm not sure.
So I think that checking old==new should be done in bridge code.

Thanks,
Toshiaki Makita
