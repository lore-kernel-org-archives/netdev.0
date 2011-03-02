From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [question] bond_set_slave_inactive_flags
Date: Wed, 02 Mar 2011 13:41:29 -0800
Message-ID: <12609.1299102089@death>
References: <20110301074318.GF2855@psychotron.redhat.com>
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:60852 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756922Ab1CBVld (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 16:41:33 -0500
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p22LLUeL022451
	for <netdev@vger.kernel.org>; Wed, 2 Mar 2011 16:21:30 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 057036E8036
	for <netdev@vger.kernel.org>; Wed,  2 Mar 2011 16:41:33 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p22LfWjq391714
	for <netdev@vger.kernel.org>; Wed, 2 Mar 2011 16:41:32 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p22LfWfZ025544
	for <netdev@vger.kernel.org>; Wed, 2 Mar 2011 16:41:32 -0500
In-reply-to: <20110301074318.GF2855@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> wrote:

>Jay,
>
>Looking at function bond_set_slave_inactive_flags:
>
>static inline void bond_set_slave_inactive_flags(struct slave *slave)
>{
>        struct bonding *bond = netdev_priv(slave->dev->master);
>        if (!bond_is_lb(bond))
>                slave->state = BOND_STATE_BACKUP;
>        if (!bond->params.all_slaves_active)
>                slave->dev->priv_flags |= IFF_SLAVE_INACTIVE;
>        if (slave_do_arp_validate(bond, slave))
>                slave->dev->priv_flags |= IFF_SLAVE_NEEDARP;
>}
>
>Why BOND_STATE_BACKUP is set only for non-lb bonds?
>This was introduced by 8f903c708fcc2b579ebf16542bf6109bad593a1d but
>I do not see why.

	It broke something to have slaves in alb or tlb mode (what
"bond_is_lb" means) set to state == BACKUP; I'm trying to remember what
it was.  I know it would mess up some text messages (calling alb/tlb
slaves "backup", for example), but I think also broke the alb/tlb modes
themselves because SLAVE_IS_OK returns false if state != ACTIVE.

	For alb/tlb, there is an "active" slave, and that's the one that
handles multicast and broadcast.  The others are "inactive," but not
really; they still send and receive regular traffic, but not bcast /
mcast.  The IFF_SLAVE_INACTIVE flag is used to exclude the bcast / mcast
traffic from the "inactive" slaves.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
