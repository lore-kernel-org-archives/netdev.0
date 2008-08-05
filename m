From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: Warning when unloading the nf_conntack module (regression?)
Date: Tue, 5 Aug 2008 03:08:17 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0808050301400.29400@bizon.gios.gov.pl>
References: <20080803143730.7747e9a8@infradead.org>
 <Pine.LNX.4.64.0808032344510.16818@bizon.gios.gov.pl>
 <Pine.LNX.4.64.0808042027080.4338@bizon.gios.gov.pl>
 <Pine.LNX.4.64.0808042039400.4338@bizon.gios.gov.pl>
 <Pine.LNX.4.64.0808042130570.23688@bizon.gios.gov.pl>
 <20080804200058.GX28946@ZenIV.linux.org.uk> <20080804203021.GY28946@ZenIV.linux.org.uk>
 <Pine.LNX.4.64.0808042258370.29400@bizon.gios.gov.pl>
 <20080804215649.GZ28946@ZenIV.linux.org.uk> <Pine.LNX.4.64.0808050000360.29400@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-2037592239-1217898497=:29400"
Cc: Arjan van de Ven <arjan@infradead.org>, netdev@vger.kernel.org,
	kaber@trash.net
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:37760 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764107AbYHEBI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 21:08:27 -0400
In-Reply-To: <Pine.LNX.4.64.0808050000360.29400@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-2037592239-1217898497=:29400
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Tue, 5 Aug 2008, Krzysztof Oledzki wrote:

>
>
> On Mon, 4 Aug 2008, Al Viro wrote:
>
>> On Mon, Aug 04, 2008 at 11:16:07PM +0200, Krzysztof Oledzki wrote:
>>=20
>>> Solves partially: no more WARNING, however entries are still missing &
>>> duplicated:
>>>=20
>>> # sysctl -a 2>/dev/null|grep net.netfilter
>>> net.netfilter.nf_conntrack_generic_timeout =3D 600
>>> net.netfilter.nf_conntrack_acct =3D 1
>>> net.netfilter.nf_conntrack_generic_timeout =3D 600
>>> net.netfilter.nf_conntrack_acct =3D 1
>>=20
>> Very interesting.  Could you see at which point duplicates appear?  I.e.
>> in which sequence do you get registrations, at least on the level of "th=
is
>> module is loaded first, no duplicates, this one comes after, etc."
>
> All I need to do is to load a single "nf_conntrack" module.
>
>> =09... ah, hell.  I see what's going on.  The trouble is in
>> nf_conntrack_standalone; you get a table that has _both_ net.netfilter.*=
=20
>> and
>> net.nf_conntrack_max, which means that it's attached to unified tree at
>> net; if we already have something with net.netfilter, you've got trouble=
 -
>> which entry net.netfilter will come from?
>
> Indeed.
>
>> _All_ this crap comes from lousy historical API; it's too much for this
>> cycle, but for .28 I'm going to clean that mess up.  For now, split that
>> table in two and register them separately.  I.e. register=20
>> nf_ct_sysctl_table[]
>> at nf_net_netfilter_sysctl_path *and* remove the "netfilter" entry from
>> nf_ct_netfilter_table[].
>
> Will do. Thanks.
>
>> I'm really going down right now; will follow up after I get some sleep..=
=2E
>
> Right. I'll try to prepare and test your ideas at that time. Thank you ag=
ain.

Both good and bad news. The good one is with two above fixes the netfilter=
=20
issue seems to be now solved. However, starting from the
9043476f726802f4b00c96d0c4f418dde48d1304, even with NETFILNER=3Dn, there ar=
e=20
other duplicated entries:

# find /proc/sys -type d |sort|uniq -d

/proc/sys/net/core
/proc/sys/net/ipv4/route
/proc/sys/net/ipv6
/proc/sys/net/ipv6/conf
/proc/sys/net/ipv6/conf/all
/proc/sys/net/ipv6/conf/bond0
/proc/sys/net/ipv6/conf/default
/proc/sys/net/ipv6/conf/dummy0
/proc/sys/net/ipv6/conf/eth0
/proc/sys/net/ipv6/conf/eth1
/proc/sys/net/ipv6/conf/eth2
/proc/sys/net/ipv6/conf/gre0
/proc/sys/net/ipv6/conf/ip6tnl0
/proc/sys/net/ipv6/conf/lo
/proc/sys/net/ipv6/conf/sit0
/proc/sys/net/ipv6/conf/tunl0
/proc/sys/net/ipv6/conf/vlan1
/proc/sys/net/ipv6/conf/vlan33
/proc/sys/net/ipv6/icmp
/proc/sys/net/ipv6/neigh
/proc/sys/net/ipv6/neigh/bond0
/proc/sys/net/ipv6/neigh/default
/proc/sys/net/ipv6/neigh/dummy0
/proc/sys/net/ipv6/neigh/eth0
/proc/sys/net/ipv6/neigh/eth1
/proc/sys/net/ipv6/neigh/eth2
/proc/sys/net/ipv6/neigh/gre0
/proc/sys/net/ipv6/neigh/ip6tnl0
/proc/sys/net/ipv6/neigh/lo
/proc/sys/net/ipv6/neigh/sit0
/proc/sys/net/ipv6/neigh/tunl0
/proc/sys/net/ipv6/neigh/vlan1
/proc/sys/net/ipv6/neigh/vlan33
/proc/sys/net/ipv6/route

Best regards,

 =09=09=09Krzysztof Ol=EAdzki
---187430788-2037592239-1217898497=:29400--
