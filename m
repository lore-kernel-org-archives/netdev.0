From: sjur.brandeland@stericsson.com
Subject: [PATCH net] caif: Fix access to freed pernet memory
Date: Sun, 15 Jul 2012 22:10:14 +0200
Message-ID: <1342383014-5525-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>, sjurbren@gmail.com,
	Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:51182 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713Ab2GOUKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2012 16:10:23 -0400
Received: by lbbgm6 with SMTP id gm6so7921487lbb.19
        for <netdev@vger.kernel.org>; Sun, 15 Jul 2012 13:10:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

unregister_netdevice_notifier() must be called before
unregister_pernet_subsys() to avoid accessing already freed
pernet memory. This fixes the following oops when doing rmmod:

Call Trace:
 [<ffffffffa0f802bd>] caif_device_notify+0x4d/0x5a0 [caif]
 [<ffffffff81552ba9>] unregister_netdevice_notifier+0xb9/0x100
 [<ffffffffa0f86dcc>] caif_device_exit+0x1c/0x250 [caif]
 [<ffffffff810e7734>] sys_delete_module+0x1a4/0x300
 [<ffffffff810da82d>] ? trace_hardirqs_on_caller+0x15d/0x1e0
 [<ffffffff813517de>] ? trace_hardirqs_on_thunk+0x3a/0x3
 [<ffffffff81696bad>] system_call_fastpath+0x1a/0x1f

RIP
 [<ffffffffa0f7f561>] caif_get+0x51/0xb0 [caif]

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---

Hi Dave,

Can you please queue up this bugfix as appropriate for -net and -stable=
?

I guess this bug has been around since introduction of network
name spaces in CAIF, but it became visible after 3.4 and the commit:
"net: In unregister_netdevice_notifier unregister the netdevices."=20

Thanks,
Sjur

 net/caif/caif_dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 554b312..8c83c17 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -561,9 +561,9 @@ static int __init caif_device_init(void)
=20
 static void __exit caif_device_exit(void)
 {
-	unregister_pernet_subsys(&caif_net_ops);
 	unregister_netdevice_notifier(&caif_device_notifier);
 	dev_remove_pack(&caif_packet_type);
+	unregister_pernet_subsys(&caif_net_ops);
 }
=20
 module_init(caif_device_init);
--=20
1.7.5.4
