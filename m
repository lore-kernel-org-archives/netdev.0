From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net v2 5/9] bridge: Fix the way to check if a local fdb
 entry can be deleted
Date: Thu, 19 Dec 2013 09:39:21 -0800
Message-ID: <20131219093921.449c5d62@nehalam.linuxnetplumber.net>
References: <1387281821-21342-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<1387281821-21342-6-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<52B09DB2.7040700@redhat.com>
	<1387341972.3563.71.camel@ubuntu-vm-makita>
	<52B1D9E6.7020201@redhat.com>
	<1387455834.4084.47.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, "David S . Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:53730 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753969Ab3LSRjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 12:39:25 -0500
Received: by mail-pb0-f49.google.com with SMTP id jt11so1423534pbb.8
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 09:39:25 -0800 (PST)
In-Reply-To: <1387455834.4084.47.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Dec 2013 21:23:54 +0900
Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:

> On Wed, 2013-12-18 at 12:22 -0500, Vlad Yasevich wrote:
> > On 12/17/2013 11:46 PM, Toshiaki Makita wrote:
> > > On Tue, 2013-12-17 at 13:53 -0500, Vlad Yasevich wrote:
> > >> On 12/17/2013 07:03 AM, Toshiaki Makita wrote:
> > > ...
> > >>>
> > >>> Note that this is a slight change in behavior where the bridge device can
> > >>> receive the traffic to the old address during the short window between
> > >>> calling br_fdb_changeaddr() and br_stp_recalculate_bridge_id() in
> > >>> br_device_event(). However, it is not a problem because we still have the
> > >>> address on the bridge device.
> > >>
> > >> I think you are understating the significance here a little bit.  The
> > >> change is that for a short period of time after a port has been removed,
> > >> packets addressed to the MAC of that port may be delivered only to
> > >> bridge device instead of being flooded.
> > >>
> > >>>
> > >>> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> > >>> ---
> > >>>  net/bridge/br_fdb.c     | 10 +++++++++-
> > >>>  net/bridge/br_private.h |  6 ++++++
> > >>>  net/bridge/br_vlan.c    | 19 +++++++++++++++++++
> > >>>  3 files changed, 34 insertions(+), 1 deletion(-)
> > >>>
> > >>> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> > >>> index 5f1bd11..cf8b64e 100644
> > >>> --- a/net/bridge/br_fdb.c
> > >>> +++ b/net/bridge/br_fdb.c
> > >>> @@ -114,12 +114,20 @@ void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
> > >>>  					if (op != p &&
> > >>>  					    ether_addr_equal(op->dev->dev_addr,
> > >>>  							     f->addr.addr) &&
> > >>> -					    nbp_vlan_find(op, vid)) {
> > >>> +					    (!vid || nbp_vlan_find(op, vid))) {
> > >>>  						f->dst = op;
> > >>>  						goto skip_delete;
> > >>>  					}
> > >>>  				}
> > >>>  
> > >>> +				/* maybe bridge device has same hw addr? */
> > >>> +				if (ether_addr_equal(br->dev->dev_addr,
> > >>> +						     f->addr.addr) &&
> > >>
> > >> I think this really needs a
> > >>                                     br->dev->addr_assign_type ==
> > >> NET_ADDR_SET &&
> > >>> +				    (!vid || br_vlan_find(br, vid))) {
> > >>
> > >> That way we'll only do this if the user actively set the bridge mac
> > >> to one be the same as one of the ports.
> > > 
> > > Indeed I can do it but it affects patch 8...
> > > If we do, the final condition will be like
> > > 
> > > static void fdb_delete_local(..., bool check_br_addr)
> > > ...
> > >   if (p && ether_addr_equal(br->dev->dev_addr, addr) &&
> > >       (!check_br_addr || br->dev->addr_assign_type == NET_ADDR_SET) &&
> > >       (!vid || br_vlan_find(br, vid)))
> > > 
> > > void br_fdb_delete_by_port(...)
> > > ...
> > >   fdb_delete_local(br, p, f, true);
> > > 
> > > void nbp_vlan_delete(...)
> > > ...
> > >   fdb_delete_local(br, p, f, false);
> > >
> > 
> > Yes, you are right.  It does impact later patches.  I've been trying
> > to think of anyway to avoid that, but haven't found one so far.
> > 
> > > 
> > > And we can't change the order of function calls in br_add_if() in patch
> > > 4, which changes the behavior of traffic as well.
> > 
> > This one is different. First, the window here is a lot shorter
> > since there is no rcu grace period 
> 
> Yes, there is no rcu grace period to wait for.
> 
> > and the notifier to worry
> > about.  
> 
> There is call_netdevice_notifiers() between original position of
> br_fdb_insert() and changed position of it.
> 
> > Second, the change here doesn't result in wrongful delivery
> > of packets.  Any packets matching the new fdb are dropped until the
> > port is enabled.
> 
> Incoming frames from another port will be affected if they dereference
> the new entry during the window. They will be delivered to the bridge
> device instead of flooding.
> 
> > 
> > So, patch 4 causes a 'drop rather then flood' change and the
> > window in which the change is visible is very small.
> > This patch causes 'deliver to bridge rather then flood' change and the
> > window is much larger (synchronize_net + netdev notifier chain overhead).
> 
> As you say, synchronize_net() and notifiers relatively can take longer
> time than other functions in that window.
> 
> So are you worried about the time length of the window?
> At least, we are in RTNL and the window should be short enough, observed
> by human.
> 
> And what do you think is wrong as a bridge?
> It has that address. I can't find the reason flooding is better.
> 
> I'm afraid the code get considerably complicated or ugly if we try to
> get rid of the window, as I showed by pseudo code in previous mail.
> 
> Thanks,
> Toshiaki Makita
> 
> 

Could we make up as set of test case scripts to validate these changes.
Now that FDB table can be manipulated by iproute tools, should be possible
to have set of cases for validation.
