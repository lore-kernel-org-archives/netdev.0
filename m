From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] Revert "ipv4: make net_protocol const"
Date: Mon, 28 Aug 2017 14:18:13 -0700
Message-ID: <20170828141813.74c007ac@xeon-e3>
References: <1503951789-31836-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, bhumirks@gmail.com, davem@davemloft.net
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:33922 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751190AbdH1VSP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 17:18:15 -0400
Received: by mail-pg0-f45.google.com with SMTP id y15so4904591pgc.1
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 14:18:15 -0700 (PDT)
In-Reply-To: <1503951789-31836-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Aug 2017 13:23:09 -0700
David Ahern <dsahern@gmail.com> wrote:

> This reverts commit aa8db499ea67cff1f5f049033810ffede2fe5ae4.
>=20
> Early demux structs can not be made const. Doing so results in:
> [   84.967355] BUG: unable to handle kernel paging request at ffffffff816=
84b10
> [   84.969272] IP: proc_configure_early_demux+0x1e/0x3d
> [   84.970544] PGD 1a0a067
> [   84.970546] P4D 1a0a067
> [   84.971212] PUD 1a0b063
> [   84.971733] PMD 80000000016001e1
>=20
> [   84.972669] Oops: 0003 [#1] SMP
> [   84.973065] Modules linked in: ip6table_filter ip6_tables veth vrf
> [   84.973833] CPU: 0 PID: 955 Comm: sysctl Not tainted 4.13.0-rc6+ #22
> [   84.974612] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIO=
S 1.7.5-20140531_083030-gandalf 04/01/2014
> [   84.975855] task: ffff88003854ce00 task.stack: ffffc900005a4000
> [   84.976580] RIP: 0010:proc_configure_early_demux+0x1e/0x3d
> [   84.977253] RSP: 0018:ffffc900005a7dd0 EFLAGS: 00010246
> [   84.977891] RAX: ffffffff81684b10 RBX: 0000000000000001 RCX: 000000000=
0000000
> [   84.978759] RDX: 0000000000000000 RSI: 0000000000000006 RDI: 000000000=
0000000
> [   84.979628] RBP: ffffc900005a7dd0 R08: 0000000000000000 R09: 000000000=
0000000
> [   84.980501] R10: 0000000000000001 R11: 0000000000000008 R12: 000000000=
0000001
> [   84.981373] R13: ffffffffffffffea R14: ffffffff81a9b4c0 R15: 000000000=
0000002
> [   84.982249] FS:  00007feb237b7700(0000) GS:ffff88003fc00000(0000) knlG=
S:0000000000000000
> [   84.983231] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   84.983941] CR2: ffffffff81684b10 CR3: 0000000038492000 CR4: 000000000=
00406f0
> [   84.984817] Call Trace:
> [   84.985133]  proc_tcp_early_demux+0x29/0x30
>=20
> I think this is the second time such a patch has been reverted.
>=20
> Cc: Bhumika Goyal <bhumirks@gmail.com>
> Signed-off-by: David Ahern <dsahern@gmail.com>

This would have been caught at compile time if you tried setting inet_proto=
s to const.
Start with that if you want to give it a try.



diff --git a/include/net/protocol.h b/include/net/protocol.h
index 65ba335b0e7e..373fa92d33ff 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -93,7 +93,7 @@ struct inet_protosw {
 #define INET_PROTOSW_PERMANENT 0x02  /* Permanent protocols are unremovabl=
e. */
 #define INET_PROTOSW_ICSK      0x04  /* Is this an inet_connection_sock? */
=20
-extern struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS];
+extern const struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS];
 extern const struct net_offload __rcu *inet_offloads[MAX_INET_PROTOS];
 extern const struct net_offload __rcu *inet6_offloads[MAX_INET_PROTOS];
=20
diff --git a/net/ipv4/protocol.c b/net/ipv4/protocol.c
index 32a691b7ce2c..4b7c0ec65251 100644
--- a/net/ipv4/protocol.c
+++ b/net/ipv4/protocol.c
@@ -28,7 +28,7 @@
 #include <linux/spinlock.h>
 #include <net/protocol.h>
=20
-struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS] __read_mostly;
+const struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS] __read_mostl=
y;
 const struct net_offload __rcu *inet_offloads[MAX_INET_PROTOS] __read_most=
ly;
 EXPORT_SYMBOL(inet_offloads);


net/ipv4/sysctl_net_ipv4.c: In function =E2=80=98proc_configure_early_demux=
=E2=80=99:
net/ipv4/sysctl_net_ipv4.c:310:9: warning: assignment discards =E2=80=98con=
st=E2=80=99 qualifier from pointer target type [-Wdiscarded-qualifiers]
  ipprot =3D rcu_dereference(inet_protos[protocol]);
