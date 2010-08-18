From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 1/1] ehea: Allocate stats buffer with GFP_KERNEL
Date: Wed, 18 Aug 2010 10:49:41 -0700
Message-ID: <29190.1282153781@death>
References: <201006302159.o5ULx8ow025348@d01av03.pok.ibm.com> <20100701.224805.221588889.davem@davemloft.net> <1282140652.2194.90.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, brking@linux.vnet.ibm.com,
	ossthema@de.ibm.com, osstklei@de.ibm.com, raisch@de.ibm.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:49844 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751168Ab0HRRts convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 13:49:48 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7IHZ5Fr030280
	for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 13:35:05 -0400
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7IHnlEm091332
	for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 13:49:47 -0400
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7IHnk9k011052
	for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 11:49:47 -0600
In-reply-to: <1282140652.2194.90.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:

>Le jeudi 01 juillet 2010 =C3=A0 22:48 -0700, David Miller a =C3=A9crit=
 :
>> From: Brian King <brking@linux.vnet.ibm.com>
>> Date: Wed, 30 Jun 2010 16:59:12 -0500
>>=20
>> >=20
>> > Since ehea_get_stats calls ehea_h_query_ehea_port, which
>> > can sleep, we can also sleep when allocating a page in
>> > this function. This fixes some memory allocation failure
>> > warnings seen under low memory conditions.
>> >=20
>> > Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
>>=20
>> Applied to net-next-2.6
>> --
>
>I believe there is a problem with this patch and/or bonding.
>
>If we say ndo_get_stats() methods are allowed to sleep, then=20
>bond_get_stats() should be updated, because it currently calls
>dev_get_stats() from a read_lock_bh(&bond->lock); section.
>
>Are we allowed to sleep inside a read_lock_bh() ?

	Nope.

	And bonding's not the only call site that holds a lock over the
call to ndo_get_stats / dev_get_stats; net/core/net-sysfs.c:netstat_sho=
w
does it as well.

	I presume that bonding and netstat_show are holding a lock to
keep a list of interfaces from changing, since there's no other locking
that's guaranteed to be held for a call to dev_get_stats.

	In any event, ehea is doing an hcall to the hypervisor, which
may return "long busy," after which ehea sleeps for however long the
hypervisor told it to wait before trying again.

	So, the real question is whether the ndo_get_stats* functions
are permitted to sleep.  If they are, then bonding and netstat_show bot=
h
need to change.  If not, then ehea needs to change.  Ehea is probably
not alone in this; I poked around a bit, and it looks like mlx4 may als=
o
sleep in ndo_get_stats.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
