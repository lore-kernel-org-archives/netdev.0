From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next V5] net: introduce ethernet teaming device
Date: Wed, 26 Oct 2011 10:49:57 +0200
Message-ID: <20111026084946.GA2030@minipsycho.redhat.com>
References: <1319547821-1045-1-git-send-email-jpirko@redhat.com>
 <1319549255.10883.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com, fbl@redhat.com, benjamin.poirier@gmail.com,
	jzupka@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17884 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932413Ab1JZIuU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Oct 2011 04:50:20 -0400
Content-Disposition: inline
In-Reply-To: <1319549255.10883.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 25, 2011 at 03:27:35PM CEST, eric.dumazet@gmail.com wrote:
>Le mardi 25 octobre 2011 =E0 15:03 +0200, Jiri Pirko a =E9crit :
>> This patch introduces new network device called team. It supposes to=
 be
>> very fast, simple, userspace-driven alternative to existing bonding
>> driver.
>>=20
>> Userspace library called libteam with couple of demo apps is availab=
le
>> here:
>> https://github.com/jpirko/libteam
>> Note it's still in its dipers atm.
>>=20
>> team<->libteam use generic netlink for communication. That and rtnl
>> suppose to be the only way to configure team device, no sysfs etc.
>>=20
>> Python binding basis for libteam was recently introduced (some need
>> still need to be done on it though). Daemon providing arpmon/miimon
>> active-backup functionality will be introduced shortly.
>> All what's necessary is already implemented in kernel team driver.
>>=20
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>=20
>> v4->v5:
>> 	- team_change_mtu() uses team->lock while travesing though port
>> 	  list
>> 	- mac address changes are moved completely to jurisdiction of
>> 	  userspace daemon. This way the daemon can do FOM1, FOM2 and
>> 	  possibly other weird things with mac addresses.
>> 	  Only round-robin mode sets up all ports to bond's address then
>> 	  enslaved.
>> 	- Extended Kconfig text
>
>
>Following is not called under rcu, but rtnl or team spinlock held.
>
>Therefore, team_get_port_by_index_rcu() is not the right thing.

Yes, this is bug, I missed this.

>
>+static void __reconstruct_port_hlist(struct team *team, int rm_index)
>+{
>+       int i;
>+       struct team_port *port;
>+
>+       for (i =3D rm_index + 1; i < team->port_count; i++) {
>+               port =3D team_get_port_by_index_rcu(team, i);
>+               hlist_del_rcu(&port->hlist);
>+               port->index--;
>+               hlist_add_head_rcu(&port->hlist,
>+                                  team_port_index_hash(team, port->in=
dex));
>+       }
>+}
>+
>
>In fact, I claim most of your rcu_read_lock() in management side are
>bogus and obfuscate code.
>
>RCU is an exact science, not a commodity.
>
>When RCU is used, rcu_read_lock()/rcu_read_unlock() are used by reader=
s,
>not managers :
>
>They should use a spin/mutex(rtnl usually in network land)
>and normal reads, no need for rcu_something
>
>Only writes must take care of concurrent readers (aka rcu_assign_point=
er())
>
>For example:
>
>team_nl_fill_port_list_get_changed() should not use
>	list_for_each_entry_rcu(port, &team->port_list, list) {
>but a regular
>	list_for_each_entry(port, &team->port_list, list) {

Nod. This I missed as well.

>
>
>team_nl_team_get() should not play with RCU either.
>	It can use __dev_get_by_index() instead of dev_get_by_index_rcu()

Not true. RTNL is not held here.


>
>Comment in front of team_nl_team_get() is bogus as well :
>
>/*
> * Netlink cmd functions should be locked by following two functions.
> * To ensure team_uninit would not be called in between, hold rcu_read=
_lock
> * all the time.
> */
>
>How can holding rcu_read_lock() can prevent another cpu doing whatever=
 he wants ?
>
>It seems you believe rcu_read_lock() is a read_lock(), but it isnt.

I'm aware. But in this particular case, holding rcu_read_lock
effectively does the thing. Because team_uninit is called from
rollback_registered_many() after synchronize_net is called. The thing i=
s
that holding rcu_read_lock ensures that team->dev does not disappear
until team_nl_team_put() is called.

>
>Using right API is essential to get appropriate LOCKDEP semantic and
>code maintainability.
>
>
>
