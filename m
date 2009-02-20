From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iptables: lock free counters
Date: Thu, 19 Feb 2009 17:03:18 -0800
Message-ID: <20090219170318.3f7d54f2@extreme>
References: <20090218051906.174295181@vyatta.com>
	<20090218052747.321329022@vyatta.com>
	<20090219114719.560999b5@extreme>
	<499DEF49.3040602@cosmosbay.com>
	<499DF1A2.1030405@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34066 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752547AbZBTBDU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 20:03:20 -0500
In-Reply-To: <499DF1A2.1030405@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Feb 2009 15:56:18 -0800
Rick Jones <rick.jones2@hp.com> wrote:

> Eric Dumazet wrote:
> > Stephen Hemminger a =C3=A9crit :
> >=20
> >>The reader/writer lock in ip_tables is acquired in the critical pat=
h of
> >>processing packets and is one of the reasons just loading iptables =
can cause
> >>a 20% performance loss. The rwlock serves two functions:
> >>
> >>1) it prevents changes to table state (xt_replace) while table is i=
n use.
> >>   This is now handled by doing rcu on the xt_table. When table is
> >>   replaced, the new table(s) are put in and the old one table(s) a=
re freed
> >>   after RCU period.
> >>
> >>2) it provides synchronization when accesing the counter values.
> >>   This is now handled by swapping in new table_info entries for ea=
ch cpu
> >>   then summing the old values, and putting the result back onto on=
e
> >>   cpu.  On a busy system it may cause sampling to occur at differe=
nt
> >>   times on each cpu, but no packet/byte counts are lost in the pro=
cess.
> >>
> >>Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >=20
> >=20
> >=20
> > Acked-by: Eric Dumazet <dada1@cosmosbay.com>
> >=20
> > Sucessfully tested on my dual quad core machine too, but iptables o=
nly (no
> > ipv6 here)
> >=20
> > BTW, my new "tbench 8" result is 2450 MB/s, (it was 2150 MB/s not s=
o long ago)
> >=20
> > Thanks Stephen, thats very cool stuff, yet another rwlock out of ke=
rnel :)
>=20
> Do you folks need/want further testing against the 32-core setup?

It would be good to combine all 3 (iptables-rcu, timer change, and conn=
track lock)
to see what the overhead change is.
