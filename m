From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: Warning when unloading the nf_conntack module (regression?)
Date: Mon, 4 Aug 2008 21:41:10 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0808042130570.23688@bizon.gios.gov.pl>
References: <20080803143730.7747e9a8@infradead.org>
 <Pine.LNX.4.64.0808032344510.16818@bizon.gios.gov.pl>
 <Pine.LNX.4.64.0808042027080.4338@bizon.gios.gov.pl>
 <Pine.LNX.4.64.0808042039400.4338@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-2068841399-1217878870=:23688"
Cc: netdev@vger.kernel.org, kaber@trash.net,
	Al Viro <viro@zeniv.linux.org.uk>
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:56612 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753155AbYHDTlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 15:41:22 -0400
In-Reply-To: <Pine.LNX.4.64.0808042039400.4338@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-2068841399-1217878870=:23688
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Mon, 4 Aug 2008, Krzysztof Oledzki wrote:

>
>
> On Mon, 4 Aug 2008, Krzysztof Oledzki wrote:
>
>>=20
>>=20
>> On Sun, 3 Aug 2008, Krzysztof Oledzki wrote:
>>=20
>>>=20
>>>=20
>>> On Sun, 3 Aug 2008, Arjan van de Ven wrote:
>>>=20
>>>> The warning below started showing up on kerneloops.org in the top 20 a=
nd=20
>>>> it appears to
>>>> be new in 2.6.27-rc (e.g. a regression)...
>>>>=20
>>>> It happens when nf_conntrack is rmmod'd
>>>>=20
>>>>=20
>>>> The reports:
>>>> http://www.kerneloops.org/search.php?search=3Dnf_conntrack_acct_fini
>>>>=20
>>>> The warning:
>>>>=20
>>>> WARNING: at kernel/sysctl.c:1966 unregister_sysctl_table+0xcc/0x103()
>>>>=20
>>>> Modules : nf_conntrack(-)
>>>>=20
>>>> Call Trace:
>>>> [<ffffffff81043bc8>] warn_on_slowpath+0x65/0x98
>>>> [<ffffffff8104abdf>] unregister_sysctl_table+0xcc/0x103
>>>> [<ffffffffa0306655>] nf_conntrack_acct_fini+0x15/0x23 [nf_conntrack]
>>>> [<ffffffffa03018a1>] nf_conntrack_cleanup+0x84/0x86 [nf_conntrack]
>>>> [<ffffffffa0306944>] nf_conntrack_standalone_fini+0x40/0x42=20
>>>> [nf_conntrack]
>>>> [<ffffffff810700d0>] sys_delete_module+0x202/0x263
>>>> [<ffffffff8101034a>] system_call_fastpath+0x16/0x1b
>>>=20
>>> Thanks. It seems I'm the person who introduced it. I'll look at it ASAP=
=2E
>>=20
>> Probably spoken too fast. This problem was introduced in 2.6.26-git15,=
=20
>> about one week after my accounting rework had been included. Obviously=
=20
>> there is something wrong with netfilter sysctl handling, as starting=20
>> with this kernel version sysctl reports duplicated net.netfilter:
>>=20
>> # find /proc/sys/net/|grep net/netf
>> /proc/sys/net/netfilter
>> /proc/sys/net/netfilter/nf_conntrack_generic_timeout
>> /proc/sys/net/netfilter/nf_conntrack_acct
>> /proc/sys/net/netfilter
>> /proc/sys/net/netfilter/nf_conntrack_generic_timeout
>> /proc/sys/net/netfilter/nf_conntrack_acct
>>=20
>> # sysctl -a|grep net.netfilter
>> net.netfilter.nf_conntrack_generic_timeout =3D 600
>> net.netfilter.nf_conntrack_acct =3D 1
>> net.netfilter.nf_conntrack_generic_timeout =3D 600
>> net.netfilter.nf_conntrack_acct =3D 1
>>=20
>> Still investigating.
>
> BTW: It also happens when I revert my patch:
>
> sysctl -a|grep net.netfilter
>
> net.netfilter.nf_conntrack_generic_timeout =3D 600
> net.netfilter.nf_conntrack_generic_timeout =3D 600

And the winner is... 9043476f726802f4b00c96d0c4f418dde48d1304:

[PATCH] sanitize proc_sysctl

* keep references to ctl_table_head and ctl_table in /proc/sys inodes
* grab the former during operations, use the latter for access to
   entry if that succeeds
* have ->d_compare() check if table should be seen for one who does lookup;
   that allows us to avoid flipping inodes - if we have the same name resol=
ve
   to different things, we'll just keep several dentries and ->d_compare()
   will reject the wrong ones.
* have ->lookup() and ->readdir() scan the table of our inode first, then
   walk all ctl_table_header and scan ->attached_by for those that are
   attached to our directory.
* implement ->getattr().
* get rid of insane amounts of tree-walking
* get rid of the need to know dentry in ->permission() and of the contortio=
ns
   induced by that.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

With this patch "sysctl -a|grep net.netfilter" shows only=20
net.netfilter.nf_conntrack_generic_timeout and=20
net.netfilter.nf_conntrack_acct, both are duplicate btw:

# sysctl -a 2>/dev/null|grep netf
net.ipv4.netfilter.ip_conntrack_generic_timeout =3D 600
net.netfilter.nf_conntrack_generic_timeout =3D 600
net.netfilter.nf_conntrack_acct =3D 1
net.netfilter.nf_conntrack_generic_timeout =3D 600
net.netfilter.nf_conntrack_acct =3D 1

Without that commit I get full sysctl tree:

# sysctl -a 2>/dev/null|grep netf
net.ipv4.netfilter.ip_conntrack_generic_timeout =3D 600
net.netfilter.nf_conntrack_generic_timeout =3D 600
net.netfilter.nf_conntrack_acct =3D 1
net.netfilter.nf_conntrack_max =3D 32768
net.netfilter.nf_conntrack_count =3D 0
net.netfilter.nf_conntrack_buckets =3D 8192
net.netfilter.nf_conntrack_checksum =3D 1
net.netfilter.nf_conntrack_log_invalid =3D 0
net.netfilter.nf_conntrack_expect_max =3D 128

And of course no WARNING at unloading as it comes from that patch=20
directly:

-       for (i =3D 1; table && (i <=3D depth); i++) {
-               ancestor =3D proc_sys_ancestor(dentry, i);
-               table =3D proc_sys_lookup_table_one(table, &ancestor->d_nam=
e);
-               if (table)
-                       table =3D table->child;
+       if (table && !table->child) {
+               WARN_ON(1);
+               goto out;
         }

OK, how we should proceed next? Is sysctl API misused somewhere in the=20
netfilter code and/or in my 584015727a3b88b46602b20077b46cd04f8b4ab3=20
patch? Or maybe 9043476f726802f4b00c96d0c4f418dde48d1304 commit is buggy?

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-2068841399-1217878870=:23688--
