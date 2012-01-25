From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net] caif: Fix crash due to uninitialized net name-space.
Date: Wed, 25 Jan 2012 21:33:51 +0100
Message-ID: <1327523631-3480-1-git-send-email-sjur.brandeland@stericsson.com>
References: <CA+1xoqe+Qa1OByj7z7XzAPG_g9+BmNj9NPZR=_5b_MTEmc9Chw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, davej@redhat.com, sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: levinsasha928@gmail.com, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+1xoqe+Qa1OByj7z7XzAPG_g9+BmNj9NPZR=_5b_MTEmc9Chw@mail.gmail.com>
References: <CA+1xoqdZapYjS4gPf_uGwEdFQQdZ525mASr7iFKPXJdCBdRLKA@mail.gmail.com> <1327444045-1033-1-git-send-email-sjur.brandeland@stericsson.com> <CA+1xoqe+Qa1OByj7z7XzAPG_g9+BmNj9NPZR=_5b_MTEmc9Chw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net_generic() calls BUG_ON() if called with uninitialized
network name-space. Add check if net is initialized before
calling net_generic(). This fixes the following oops:

[  200.752016] kernel BUG at include/net/netns/generic.h:40!
=2E..
[  200.752016]  [<ffffffff825c3cea>] ? get_cfcnfg+0x3a/0x180
[  200.752016]  [<ffffffff821cf0b0>] ? lockdep_rtnl_is_held+0x10/0x20
[  200.752016]  [<ffffffff825c41be>] caif_device_notify+0x2e/0x530
[  200.752016]  [<ffffffff810d61b7>] notifier_call_chain+0x67/0x110
[  200.752016]  [<ffffffff810d67c1>] raw_notifier_call_chain+0x11/0x20
[  200.752016]  [<ffffffff821bae82>] call_netdevice_notifiers+0x32/0x60
[  200.752016]  [<ffffffff821c2b26>] register_netdevice+0x196/0x300
[  200.752016]  [<ffffffff821c2ca9>] register_netdev+0x19/0x30
[  200.752016]  [<ffffffff81c1c67a>] loopback_net_init+0x4a/0xa0
[  200.752016]  [<ffffffff821b5e62>] ops_init+0x42/0x180
[  200.752016]  [<ffffffff821b600b>] setup_net+0x6b/0x100
[  200.752016]  [<ffffffff821b6466>] copy_net_ns+0x86/0x110
[  200.752016]  [<ffffffff810d5789>] create_new_namespaces+0xd9/0x190

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
Tested-by: Sasha Levin <levinsasha928@gmail.com>

---

Hi Sasha and Dave,

[Sasha]
>Works for me.
Thank you Sasha for reporting this bug and testing my patch,
I appreciate it.

[Dave]
>Please post all networking patches CC:'d
Sorry, I missed the obvious.
I'm resending the same patch as yesterday, this time to:netdev
and with "Tested-by: Sasha". Please apply to net.

Thanks,
Sjur

 net/caif/caif_dev.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 673728a..6110ade 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -371,6 +371,14 @@ static int caif_device_notify(struct notifier_bloc=
k *me, unsigned long what,
 	struct cflayer *layer, *link_support;
 	int head_room =3D 0;
 	struct caif_device_entry_list *caifdevs;
+	int len;
+
+	rcu_read_lock();
+	len =3D rcu_dereference(dev_net(dev)->gen)->len;
+	rcu_read_unlock();
+
+	if (caif_net_id =3D=3D 0 || caif_net_id > len)
+		return 0;
=20
 	cfg =3D get_cfcnfg(dev_net(dev));
 	caifdevs =3D caif_device_list(dev_net(dev));
--=20
1.7.0.4
