From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] pppoe: fix race at init time
Date: Wed, 29 Jul 2009 18:46:42 +0400
Message-ID: <20090729144642.GA5094@lenovo>
References: <4A6ECA3A.4050309@openvz.org> <4A6EEF69.1050001@cosmosbay.com> <4A6EF0BF.2050801@gmail.com> <4A6EF705.6070403@openvz.org> <4A6EFA35.3060309@gmail.com> <4A6EFB81.4090105@gmail.com> <4A6F017B.4060909@gmail.com> <4A6F397D.6010606@gmail.com> <20090728184834.GD4678@lenovo> <43d009740907282055t44bfa2e2md3afa514d4b2d7e6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Pavel Emelyanov <xemul@openvz.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Igor M Podlesny <for.poige+bugzilla.kernel.org@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:36939 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961AbZG2Ow7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 10:52:59 -0400
Received: by bwz19 with SMTP id 19so11741bwz.37
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 07:52:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <43d009740907282055t44bfa2e2md3afa514d4b2d7e6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Igor M Podlesny - Wed, Jul 29, 2009 at 11:55:45AM +0800]
... 
| 	At last the 3rd patch was also unable to fix the bug.
|
...

Hi Igor,

could you give the following patch a chance please.
Not sure if it help but anyway.

	-- Cyrill
---
net,pppoe: fixup module init/exit subsequent calls

pernet data should allocated first and freed last
on module init/exit routines otherwise it's possible
to have unserialized calls to packet handling routines.

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 drivers/net/pppoe.c |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

Index: linux-2.6.git/drivers/net/pppoe.c
=====================================================================
--- linux-2.6.git.orig/drivers/net/pppoe.c
+++ linux-2.6.git/drivers/net/pppoe.c
@@ -1184,17 +1184,17 @@ static int __init pppoe_init(void)
 {
 	int err;
 
-	err = proto_register(&pppoe_sk_proto, 0);
+	err = register_pernet_gen_device(&pppoe_net_id, &pppoe_net_ops);
 	if (err)
 		goto out;
 
-	err = register_pppox_proto(PX_PROTO_OE, &pppoe_proto);
+	err = proto_register(&pppoe_sk_proto, 0);
 	if (err)
-		goto out_unregister_pppoe_proto;
+		goto out_unregister_net_ops;
 
-	err = register_pernet_gen_device(&pppoe_net_id, &pppoe_net_ops);
+	err = register_pppox_proto(PX_PROTO_OE, &pppoe_proto);
 	if (err)
-		goto out_unregister_pppox_proto;
+		goto out_unregister_pppoe_proto;
 
 	dev_add_pack(&pppoes_ptype);
 	dev_add_pack(&pppoed_ptype);
@@ -1202,22 +1202,22 @@ static int __init pppoe_init(void)
 
 	return 0;
 
-out_unregister_pppox_proto:
-	unregister_pppox_proto(PX_PROTO_OE);
 out_unregister_pppoe_proto:
 	proto_unregister(&pppoe_sk_proto);
+out_unregister_net_ops:
+	unregister_pernet_gen_device(pppoe_net_id, &pppoe_net_ops);
 out:
 	return err;
 }
 
 static void __exit pppoe_exit(void)
 {
-	unregister_pppox_proto(PX_PROTO_OE);
-	dev_remove_pack(&pppoes_ptype);
-	dev_remove_pack(&pppoed_ptype);
 	unregister_netdevice_notifier(&pppoe_notifier);
-	unregister_pernet_gen_device(pppoe_net_id, &pppoe_net_ops);
+	dev_remove_pack(&pppoed_ptype);
+	dev_remove_pack(&pppoes_ptype);
+	unregister_pppox_proto(PX_PROTO_OE);
 	proto_unregister(&pppoe_sk_proto);
+	unregister_pernet_gen_device(pppoe_net_id, &pppoe_net_ops);
 }
 
 module_init(pppoe_init);
