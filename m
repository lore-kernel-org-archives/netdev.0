From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] af_key: fix netns ops ordering on module load/unload
Date: Sat, 30 Jan 2010 14:53:27 +0200
Message-ID: <20100130125327.GA4258@x200>
References: <20100129094822.GA8294@nb-core2.darkstar.lan>
 <b6fcc0a1001290217l4edb0a0btbafa0c26b6f14ad5@mail.gmail.com>
 <1264778549.3184.28.camel@edumazet-laptop>
 <1264782806.3184.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Luca Tettamanti <kronos.it@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753424Ab0A3M6j@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1264782806.3184.42.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 29, 2010 at 05:33:26PM +0100, Eric Dumazet wrote:
> @@ -3807,21 +3807,24 @@ static int __init ipsec_pfkey_init(void)
>  	if (err != 0)
>  		goto out;
>  
> -	err = sock_register(&pfkey_family_ops);
> -	if (err != 0)
> -		goto out_unregister_key_proto;
>  	err = xfrm_register_km(&pfkeyv2_mgr);
>  	if (err != 0)
> -		goto out_sock_unregister;
> +		goto out_unregister_key_proto;
> +
>  	err = register_pernet_subsys(&pfkey_net_ops);
>  	if (err != 0)
>  		goto out_xfrm_unregister_km;
> +
> +	err = sock_register(&pfkey_family_ops);
> +	if (err != 0)
> +		goto out_unregister_pernet;
>  out:
>  	return err;
> +
> +out_unregister_pernet:
> +	unregister_pernet_subsys(&pfkey_net_ops);
>  out_xfrm_unregister_km:
>  	xfrm_unregister_km(&pfkeyv2_mgr);
> -out_sock_unregister:
> -	sock_unregister(PF_KEY);
>  out_unregister_key_proto:
>  	proto_unregister(&key_proto);
>  	goto out;

ACK analysis, except this is not enough.

Here is patch which survived netns start/stop/modprobe/rmmod cycles.

	Alexey, who still doesn't get why bug reproduces so easily for bug reporter.

Luca, please confirm.

Audit for the rest of the modules pending.

[PATCH] af_key: fix netns ops ordering on module load/unload

1. After sock_register() returns, it's possible to create sockets,
   even if module still not initialized fully (blame generic module code
   for that!)
2. Consequently, pfkey_create() can be called with pfkey_net_id still not
   initialized which will BUG_ON in net_generic():
	kernel BUG at include/net/netns/generic.h:43!
3. During netns shutdown, netns ops should be unregistered after
   key manager unregistered because key manager calls can be triggered
   from xfrm_user module:

   	general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
	pfkey_broadcast+0x111/0x210 [af_key]
	pfkey_send_notify+0x16a/0x300 [af_key]
	km_state_notify+0x41/0x70
	xfrm_flush_sa+0x75/0x90 [xfrm_user]
4. Unregister netns ops after socket ops just in case and for symmetry.

Reported by Luca Tettamanti.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/key/af_key.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3794,9 +3794,9 @@ static struct pernet_operations pfkey_net_ops = {
 
 static void __exit ipsec_pfkey_exit(void)
 {
-	unregister_pernet_subsys(&pfkey_net_ops);
 	xfrm_unregister_km(&pfkeyv2_mgr);
 	sock_unregister(PF_KEY);
+	unregister_pernet_subsys(&pfkey_net_ops);
 	proto_unregister(&key_proto);
 }
 
@@ -3807,21 +3807,22 @@ static int __init ipsec_pfkey_init(void)
 	if (err != 0)
 		goto out;
 
-	err = sock_register(&pfkey_family_ops);
+	err = register_pernet_subsys(&pfkey_net_ops);
 	if (err != 0)
 		goto out_unregister_key_proto;
+	err = sock_register(&pfkey_family_ops);
+	if (err != 0)
+		goto out_unregister_pernet;
 	err = xfrm_register_km(&pfkeyv2_mgr);
 	if (err != 0)
 		goto out_sock_unregister;
-	err = register_pernet_subsys(&pfkey_net_ops);
-	if (err != 0)
-		goto out_xfrm_unregister_km;
 out:
 	return err;
-out_xfrm_unregister_km:
-	xfrm_unregister_km(&pfkeyv2_mgr);
+
 out_sock_unregister:
 	sock_unregister(PF_KEY);
+out_unregister_pernet:
+	unregister_pernet_subsys(&pfkey_net_ops);
 out_unregister_key_proto:
 	proto_unregister(&key_proto);
 	goto out;
