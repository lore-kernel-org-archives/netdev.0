From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next V5] net: introduce ethernet teaming device
Date: Tue, 25 Oct 2011 15:27:35 +0200
Message-ID: <1319549255.10883.16.camel@edumazet-laptop>
References: <1319547821-1045-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com, fbl@redhat.com, benjamin.poirier@gmail.com,
	jzupka@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:33748 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933399Ab1JYN1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 09:27:43 -0400
Received: by bkbzt19 with SMTP id zt19so505221bkb.19
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2011 06:27:42 -0700 (PDT)
In-Reply-To: <1319547821-1045-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 25 octobre 2011 =C3=A0 15:03 +0200, Jiri Pirko a =C3=A9crit :
> This patch introduces new network device called team. It supposes to =
be
> very fast, simple, userspace-driven alternative to existing bonding
> driver.
>=20
> Userspace library called libteam with couple of demo apps is availabl=
e
> here:
> https://github.com/jpirko/libteam
> Note it's still in its dipers atm.
>=20
> team<->libteam use generic netlink for communication. That and rtnl
> suppose to be the only way to configure team device, no sysfs etc.
>=20
> Python binding basis for libteam was recently introduced (some need
> still need to be done on it though). Daemon providing arpmon/miimon
> active-backup functionality will be introduced shortly.
> All what's necessary is already implemented in kernel team driver.
>=20
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>=20
> v4->v5:
> 	- team_change_mtu() uses team->lock while travesing though port
> 	  list
> 	- mac address changes are moved completely to jurisdiction of
> 	  userspace daemon. This way the daemon can do FOM1, FOM2 and
> 	  possibly other weird things with mac addresses.
> 	  Only round-robin mode sets up all ports to bond's address then
> 	  enslaved.
> 	- Extended Kconfig text


=46ollowing is not called under rcu, but rtnl or team spinlock held.

Therefore, team_get_port_by_index_rcu() is not the right thing.

+static void __reconstruct_port_hlist(struct team *team, int rm_index)
+{
+       int i;
+       struct team_port *port;
+
+       for (i =3D rm_index + 1; i < team->port_count; i++) {
+               port =3D team_get_port_by_index_rcu(team, i);
+               hlist_del_rcu(&port->hlist);
+               port->index--;
+               hlist_add_head_rcu(&port->hlist,
+                                  team_port_index_hash(team, port->ind=
ex));
+       }
+}
+

In fact, I claim most of your rcu_read_lock() in management side are
bogus and obfuscate code.

RCU is an exact science, not a commodity.

When RCU is used, rcu_read_lock()/rcu_read_unlock() are used by readers=
,
not managers :

They should use a spin/mutex(rtnl usually in network land)
and normal reads, no need for rcu_something

Only writes must take care of concurrent readers (aka rcu_assign_pointe=
r())

=46or example:

team_nl_fill_port_list_get_changed() should not use
	list_for_each_entry_rcu(port, &team->port_list, list) {
but a regular
	list_for_each_entry(port, &team->port_list, list) {


team_nl_team_get() should not play with RCU either.
	It can use __dev_get_by_index() instead of dev_get_by_index_rcu()

Comment in front of team_nl_team_get() is bogus as well :

/*
 * Netlink cmd functions should be locked by following two functions.
 * To ensure team_uninit would not be called in between, hold rcu_read_=
lock
 * all the time.
 */

How can holding rcu_read_lock() can prevent another cpu doing whatever =
he wants ?

It seems you believe rcu_read_lock() is a read_lock(), but it isnt.

Using right API is essential to get appropriate LOCKDEP semantic and
code maintainability.
