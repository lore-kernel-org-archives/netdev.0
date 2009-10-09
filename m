From: Cosmin Ratiu <cratiu@ixiacom.com>
Subject: Re: [Patch-next] Fix the size overflow of addrconf_sysctl array
Date: Fri, 9 Oct 2009 16:11:14 +0300
Message-ID: <200910091611.14701.cratiu@ixiacom.com>
References: <4ACEA207.7010208@np.css.fujitsu.com> <20091008.224415.205034676.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_yZzzKM2QfMHWby+"
Cc: jin.dongming@np.css.fujitsu.com, kaneshige.kenji@jp.fujitsu.com,
	seto.hidetoshi@jp.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:12918 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752749AbZJINMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 09:12:08 -0400
In-Reply-To: <20091008.224415.205034676.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_yZzzKM2QfMHWby+
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit

Shouldn't this be changed too then?

Or better yet, wouldn't a change that eliminates the need of adding a new 
option in two separate places be useful?

I see the only use for that DEVCONF enum is to dump the settings via netlink.
Wouldn't a memcpy suffice?

Cosmin.

On Friday 09 October 2009 08:44:15 David Miller wrote:
> From: Jin Dongming <jin.dongming@np.css.fujitsu.com>
> Date: Fri, 09 Oct 2009 11:37:59 +0900
> 
> Please post networking patches always CC:'d to netdev@vger.kernel.org
> so that it gets added to our networking patch tracking system at:
> 
> 	http://patchwork.ozlabs.org/project/netdev/list/
> 
> Thank you.
> 
> I've applied your fix, thanks!
> 
> > (This patch fixes bug of commit f7734fdf61ec6bb848e0bafc1fb8bad2c124bb50
> >  title "make TLLAO option for NA packets configurable")
> >
> > When the IPV6 conf is used, the function sysctl_set_parent is called and
> > the array addrconf_sysctl is used as a parameter of the function.
> >
> > The above patch added new conf "force_tllao" into the array
> > addrconf_sysctl, but the size of the array was not modified, the static
> > allocated size is DEVCONF_MAX + 1 but the real size is DEVCONF_MAX + 2,
> > so the problem is that the function sysctl_set_parent accessed wrong
> > address.
> >
> > I got the following information.
> > Call Trace:
> >     [<ffffffff8106085d>] sysctl_set_parent+0x29/0x3e
> >     [<ffffffff8106085d>] sysctl_set_parent+0x29/0x3e
> >     [<ffffffff8106085d>] sysctl_set_parent+0x29/0x3e
> >     [<ffffffff8106085d>] sysctl_set_parent+0x29/0x3e
> >     [<ffffffff8106085d>] sysctl_set_parent+0x29/0x3e
> >     [<ffffffff810622d5>] __register_sysctl_paths+0xde/0x272
> >     [<ffffffff8110892d>] ? __kmalloc_track_caller+0x16e/0x180
> >     [<ffffffffa00cfac3>] ? __addrconf_sysctl_register+0xc5/0x144 [ipv6]
> >     [<ffffffff8141f2c9>] register_net_sysctl_table+0x48/0x4b
> >     [<ffffffffa00cfaf5>] __addrconf_sysctl_register+0xf7/0x144 [ipv6]
> >     [<ffffffffa00cfc16>] addrconf_init_net+0xd4/0x104 [ipv6]
> >     [<ffffffff8139195f>] setup_net+0x35/0x82
> >     [<ffffffff81391f6c>] copy_net_ns+0x76/0xe0
> >     [<ffffffff8107ad60>] create_new_namespaces+0xf0/0x16e
> >     [<ffffffff8107afee>] copy_namespaces+0x65/0x9f
> >     [<ffffffff81056dff>] copy_process+0xb2c/0x12c3
> >     [<ffffffff810576e1>] do_fork+0x14b/0x2d2
> >     [<ffffffff8107ac4e>] ? up_read+0xe/0x10
> >     [<ffffffff81438e73>] ? do_page_fault+0x27a/0x2aa
> >     [<ffffffff8101044b>] sys_clone+0x28/0x2a
> >     [<ffffffff81011fb3>] stub_clone+0x13/0x20
> >     [<ffffffff81011c72>] ? system_call_fastpath+0x16/0x1b
> >
> > And the information of IPV6 in .config is as following.
> > IPV6 in .config:
> >     CONFIG_IPV6=m
> >     CONFIG_IPV6_PRIVACY=y
> >     CONFIG_IPV6_ROUTER_PREF=y
> >     CONFIG_IPV6_ROUTE_INFO=y
> >     CONFIG_IPV6_OPTIMISTIC_DAD=y
> >     CONFIG_IPV6_MIP6=m
> >     CONFIG_IPV6_SIT=m
> >     # CONFIG_IPV6_SIT_6RD is not set
> >     CONFIG_IPV6_NDISC_NODETYPE=y
> >     CONFIG_IPV6_TUNNEL=m
> >     CONFIG_IPV6_MULTIPLE_TABLES=y
> >     CONFIG_IPV6_SUBTREES=y
> >     CONFIG_IPV6_MROUTE=y
> >     CONFIG_IPV6_PIMSM_V2=y
> >     # CONFIG_IP_VS_IPV6 is not set
> >     CONFIG_NF_CONNTRACK_IPV6=m
> >     CONFIG_IP6_NF_MATCH_IPV6HEADER=m
> >
> > I confirmed this patch fixes this problem.
> >
> > Signed-off-by: Jin Dongming <jin.dongming@np.css.fujitsu.com>
> > ---
> >  include/linux/ipv6.h |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> >
> > diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> > index ae74ede..5640425 100644
> > --- a/include/linux/ipv6.h
> > +++ b/include/linux/ipv6.h
> > @@ -208,6 +208,7 @@ enum {
> >  	DEVCONF_MC_FORWARDING,
> >  	DEVCONF_DISABLE_IPV6,
> >  	DEVCONF_ACCEPT_DAD,
> > +	DEVCONF_FORCE_TLLAO,
> >  	DEVCONF_MAX
> >  };
> 

--Boundary-00=_yZzzKM2QfMHWby+
Content-Type: text/x-patch;
  charset="UTF-8";
  name="0001-ipv6-fix-devconf-after-adding-force_tllao-option.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="0001-ipv6-fix-devconf-after-adding-force_tllao-option.patch"

=46rom f72949922a102ee9e728a2805287a9bd9a4d2e67 Mon Sep 17 00:00:00 2001
=46rom: Cosmin Ratiu <cratiu@ixiacom.com>
Date: Fri, 9 Oct 2009 15:57:09 +0300
Subject: [PATCH] [ipv6]: fix devconf after adding force_tllao option


Signed-off-by: Cosmin Ratiu <cratiu@ixiacom.com>
=2D--
 net/ipv6/addrconf.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1fd0a3d..a065f40 100644
=2D-- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3708,6 +3708,7 @@ static inline void ipv6_store_devconf(struct ipv6_dev=
conf *cnf,
 #endif
 	array[DEVCONF_DISABLE_IPV6] =3D cnf->disable_ipv6;
 	array[DEVCONF_ACCEPT_DAD] =3D cnf->accept_dad;
+	array[DEVCONF_FORCE_TLLAO] =3D cnf->force_tllao;
 }
=20
 static inline size_t inet6_if_nlmsg_size(void)
=2D-=20
1.6.3.3


--Boundary-00=_yZzzKM2QfMHWby+--
