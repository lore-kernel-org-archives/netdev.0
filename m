From: Ivan Delalande <colona@arista.com>
Subject: Bug in netlink_bind
Date: Thu, 29 Jan 2015 00:46:46 +0100
Message-ID: <20150128234646.GA23945@ycc.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:45510 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753854AbbA2B0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 20:26:05 -0500
Received: by mail-wi0-f170.google.com with SMTP id bs8so2417351wib.1
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 17:26:04 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I=E2=80=99ve been trying to debug some of our tests that began failing =
when
upgrading to 3.18. Our actual failure is caused by the condition added
in commit 97840cb to nfnetlink_bind but the bug has probably been
introduced by 0329274.

Our tests execute the following code, at some point:

	localAddr.nl_groups =3D
		  NF_NETLINK_CONNTRACK_NEW
		| NF_NETLINK_CONNTRACK_UPDATE
		| NF_NETLINK_CONNTRACK_DESTROY;
	int ret =3D bind(sd, (sockaddr*)&localAddr, sizeof(localAddr));

these constants are from include/uapi/linux/netfilter/nfnetlink_compat.=
h
and used as a bit set:

	#define NF_NETLINK_CONNTRACK_NEW        0x00000001
	#define NF_NETLINK_CONNTRACK_UPDATE     0x00000002
	#define NF_NETLINK_CONNTRACK_DESTROY    0x00000004

but, if I understand correctly, internally, constants from
include/uapi/linux/netfilter/nfnetlink.h are used instead:

	enum nfnetlink_groups {
		NFNLGRP_NONE,
		NFNLGRP_CONNTRACK_NEW,
		NFNLGRP_CONNTRACK_UPDATE,
		NFNLGRP_CONNTRACK_DESTROY,

	...

	static const int nfnl_group2type[NFNLGRP_MAX+1] =3D {
		[NFNLGRP_CONNTRACK_NEW]     =3D NFNL_SUBSYS_CTNETLINK,
		[NFNLGRP_CONNTRACK_UPDATE]  =3D NFNL_SUBSYS_CTNETLINK,
		[NFNLGRP_CONNTRACK_DESTROY] =3D NFNL_SUBSYS_CTNETLINK,

Now in netlink_bind (net/netlink/af_netlink.c), our localAddr.nl_groups
value is assigned to the groups variable and tested with test_bit:

	for (group =3D 0; group < nlk->ngroups; group++) {
		if (!test_bit(group, &groups)) {
			continue;
		}
		err =3D nlk->netlink_bind(group);

In our case, for group =3D 0, bit 0 is indeed set because nl_groups was
ORed with NF_NETLINK_CONNTRACK_NEW (=3D 1), so nlk->netlink_bind is cal=
led
with 0, that is nfnetlink_bind(0) (net/netfilter/nfnetlink.c):

	if (group <=3D NFNLGRP_NONE || group > NFNLGRP_MAX)
		return -EINVAL;

	type =3D nfnl_group2type[group];

And so, with this condition added by 97840cb, the syscall fails with
EINVAL. But it means that, before this commit, we would have tried to
get nfnl_group2type[0].
In the same way, with NF_NETLINK_CONNTRACK_UPDATE (=3D 2),
nfnetlink_bind(1) would have been called and fetched nfnl_group2type[1]=
,
which is declared as nfnl_group2type[NFNLGRP_CONNTRACK_NEW] =3D
NFNL_SUBSYS_CTNETLINK, and so on.

So, am I missing something or are the group values incorrectly
interpreted differently between netlink_bind and nfnetlink_bind, with a
difference of one? I tried a really naive patch and it made this part o=
f
ours tests pass:

	diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
	index b6bf8e8..d2c65b0 100644
	--- a/net/netlink/af_netlink.c
	+++ b/net/netlink/af_netlink.c
	@@ -1479,7 +1479,7 @@ static int netlink_bind(struct socket *sock, str=
uct sockaddr *addr,
			for (group =3D 0; group < nlk->ngroups; group++) {
				if (!test_bit(group, &groups))
					continue;
	-                       err =3D nlk->netlink_bind(group);
	+                       err =3D nlk->netlink_bind(group + 1);
				if (!err)
					continue;
				netlink_unbind(group, groups, nlk);


But that was really to test if this would fix my problem, I haven=E2=80=
=99t
really looked if the value nlk->ngroups was still correct with that or
if there was any other nlk->netlink_bind than netlink_bind that would b=
e
affected.

Thanks,
--=20
Ivan "Colona" Delalande
Arista Networks
