From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH next v3 2/6] bonding: implement bond_poll_controller()
Date: Sun, 15 Feb 2015 06:51:14 -0800
Message-ID: <15770.1424011874@nyx>
References: <1423715065-9304-1-git-send-email-maheshb@google.com> <23063.1423777544@famine> <CAF2d9jgXqRM7CtLVyCuKSt3gi-2_uixDUQbDkAoEVTbUKJpGTw@mail.gmail.com>
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:42304 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755009AbbBOOvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 09:51:21 -0500
In-reply-to: <CAF2d9jgXqRM7CtLVyCuKSt3gi-2_uixDUQbDkAoEVTbUKJpGTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mahesh Bandewar <maheshb@google.com> wrote:

>On Thu, Feb 12, 2015 at 1:45 PM, Jay Vosburgh <jay.vosburgh@canonical.com>
>wrote:
[...]
>    >+ if (BOND_MODE(bond) == BOND_MODE_8023AD)
>    >+ if (bond_3ad_get_active_agg_info(bond, &ad_info))
>    >+ return;
>    >+
>    >+ bond_for_each_slave(bond, slave, iter) {
>    >+ ops = slave->dev->netdev_ops;
>    >+ if (!bond_slave_is_up(slave) || !ops->ndo_poll_controller)
>    >+ continue;
>    >+
>    >+ if (BOND_MODE(bond) == BOND_MODE_8023AD) {
>    >+ struct aggregator *agg =
>    >+ SLAVE_AD_INFO(slave)->port.aggregator;
>    >+
>    >+ if (agg && agg->aggregator_identifier !=
>    >+ ad_info.aggregator_id)
>    >+ continue;
>    >+ if (!bond_3ad_port_is_active(slave) || ad_info.ports != 1)
>    >+ continue;
>    
>    
>    The above will exclude slaves that are in an aggregator with
>    more than one member, which is likely to be the usual case. Is that
>    intentional?
>    
>    
>
>The idea is to use all the ports in the aggregator. In a situation where
>there is only one port but is not active, then *only* use it. So from that
>perspective this logic needs '&&' instead of '||'.

	If you want to use any port from the active aggregator, then I
think logic to first find the active agg, then cycle through its ports
would be better.  This would also eliminate the concern from your other
reply regarding the following:

> >+static int bond_3ad_port_operational(struct slave *slave)
> >+{
> >+      port_t *port = &SLAVE_AD_INFO(slave)->port;
> >+
> >+      return bond_slave_can_tx(slave) &&
> >+             (port->actor_oper_port_state & port->partner_oper.port_state &
> >+              BOND_3AD_PORT_OPERATIONAL) == BOND_3AD_PORT_OPERATIONAL;
> >+}

	needing to test the port_state; if the logic cycles through the
ports of the active aggregator, then it shouldn't need to check the
state.  Any port in the active aggregator should be able to transmit,
even if it is in the "no LACP peer" fallback situation (with one
exception, noted below).

	I think something like:

	first_slave = bond_first_slave_rcu(bond);
	agg = __get_active_agg(&(SLAVE_AD_INFO(first_slave)->aggregator));
	for (port = agg->lag_ports; port;
	     port = port->next_port_in_aggregator) {
		if (bond_slave_can_tx(port->slave))
			/* use this one */
	}

	would do roughly what you're describing, although it will always
choose the first available port of the active aggregator, even if there
are more than one.

	Generally, slaves that are not up will not remain in the active
aggregator, but the slave_can_tx test will cover the window between when
a slave goes carrier down and the 3ad logic removes it from the active
agg.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
