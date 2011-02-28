From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: Re: net-next: warnings from sysctl_net_exit
Date: Mon, 28 Feb 2011 02:49:22 +0200
Message-ID: <AANLkTimTskppr-FVOaUT-ZQ=oGtVz6fjCx7XabKF-V0P@mail.gmail.com>
References: <AANLkTi=mhj3Ftq8hFPPzZYJvp8mgOeV89oX_vHZVxwzY@mail.gmail.com> <20110227.153418.245395393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:55885 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029Ab1B1Atn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Feb 2011 19:49:43 -0500
Received: by iwn34 with SMTP id 34so2663808iwn.19
        for <netdev@vger.kernel.org>; Sun, 27 Feb 2011 16:49:42 -0800 (PST)
In-Reply-To: <20110227.153418.245395393.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 28, 2011 at 1:34 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
>> David: it looks like someone registered a /proc/sys table with
>> register_net_sysctl_table but forgot to remove it (or someone wrote
>> something in the 'struct net*' and buffer overflowed into
>> &net->sysctls.list).
>
> Hmmm, we might therefore want to inspect this commit carefully:
>
> commit bf36076a67db6d7423d09d861a072337866f0dd9
> Author: Eric W. Biederman <ebiederm@xmission.com>
> Date: =C2=A0 Mon Jan 31 20:54:17 2011 -0800
>
> =C2=A0 =C2=A0net: Fix ipv6 neighbour unregister_sysctl_table warning


I'm not sure why we need that empty entry in the sysctl table anyway.

I just ran a net-next with the next patch and
register_net_sysctl_table managed to add /proc/sys/net/ipv6/neigh/
because we add 'default' and 'all' entries, followed by 'lo' for every
netns.


diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 7cb65ef..8e8b107 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -37,12 +37,6 @@ static ctl_table ipv6_table_template[] =3D {
                .mode           =3D 0644,
                .proc_handler   =3D proc_dointvec
        },
-       {
-               .procname       =3D "neigh",
-               .maxlen         =3D 0,
-               .mode           =3D 0555,
-               .child          =3D empty,
-       },
        { }
 };



What are the benefits of this empty entry?

Is there an assumption that we add this empty
'/proc/sys/net/ipv6/neigh/' entry *before* adding entries for
"/proc/sys/net/ipv6/neigh/default/" or
"/proc/sys/net/ipv6/neigh/all/"?

Because we register the empty '/proc/sys/net/ipv6/neigh/' entry
*after* registering these two of it's children, and I'm not sure how
this will affect the attachment of ctl_table_header corresponding to
these ctl_table trees.


With the following patch I get this ordering (for both init_net and a n=
ew net):
  CALL addrconf_init_net (create default/all)
  CALL ipv6_sysctl_net_init (create empty entry).


diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3daaf3c..5fe402e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4564,6 +4564,8 @@ static int __net_init addrconf_init_net(struct ne=
t *net)
 	int err;
 	struct ipv6_devconf *all, *dflt;

+	printk(KERN_ALERT "CALL addrconf_init_net\n");
+
 	err =3D -ENOMEM;
 	all =3D &ipv6_devconf;
 	dflt =3D &ipv6_devconf_dflt;
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 7cb65ef..880d64a 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -71,6 +65,8 @@ static int __net_init ipv6_sysctl_net_init(struct net=
 *net)
 	struct ctl_table *ipv6_icmp_table;
 	int err;

+	printk(KERN_ALERT "CALL ipv6_sysctl_net_init\n");
+
 	err =3D -ENOMEM;
 	ipv6_table =3D kmemdup(ipv6_table_template, sizeof(ipv6_table_templat=
e),
 			     GFP_KERNEL);


--=20
=C2=A0.
=2E.: Lucian
