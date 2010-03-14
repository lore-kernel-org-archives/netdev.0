From: michael-dev@fami-braun.de
Subject: [PATCH] BUG: unable to handle kernel NULL pointer dereference at
 br_pass_frame_up
Date: Sun, 14 Mar 2010 03:30:07 +0100
Message-ID: <4B9C4A2F.8040203@fami-braun.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig1F1E2C4FE5470F285BEFBE2E"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:64598 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753772Ab0CNCaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Mar 2010 21:30:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1F1E2C4FE5470F285BEFBE2E
Content-Type: multipart/mixed;
 boundary="------------020509030608030006030109"

This is a multi-part message in MIME format.
--------------020509030608030006030109
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi,

I'm currently using linux-next and have been running into an OOPs which
I think might be caused by a patch submitted on 2010-02-27.

It's a linux-next kernel from 2010-03-12 on an x86 system and it
OOPs in the bridge module in br_pass_frame_up (called by
br_handle_frame_finish) because brdev cannot be dereferenced (its set to
a non-null value).

Adding some BUG_ON statements revealed that
 BR_INPUT_SKB_CB(skb)->brdev =3D=3D br-dev
(as set in br_handle_frame_finish first)
only holds until br_forward is called.
The next call to br_pass_frame_up then fails.

Digging deeper it seems that br_forward either frees the skb or passes
it to NF_HOOK which will in turn take care of freeing the skb. The same
is holds for br_pass_frame_ip. So it seems as if two independent skb
allocations are required. As far as I can see, commit
b33084be192ee1e347d98bb5c9e38a53d98d35e2 removed skb duplication and so
likely causes this crash. This crash does not happen on 2.6.33.

I've therefore modified br_forward the same way br_flood has been
modified so that the skb is not freed if skb0 is going to be used
and I can confirm that the attached patch resolves the issue for me.

Please don't hesitate to contact me if there are any questions.

Sincerely,
 M. Braun

// gdb output //

(gdb) bt full

#0  br_pass_frame_up (skb=3D0xcf9627c0) at net/bridge/br_input.c:27

        indev =3D <value optimised out>

        brdev =3D 0x1012
#1  br_handle_frame_finish (skb=3D0xcf9627c0) at net/bridge/br_input.c:99=

        dest =3D 0xcfa59dae "=C9=8AU", <incomplete sequence \307>
        br =3D 0xcec46300
        dst =3D <value optimised out>
        mdst =3D <value optimised out>
        skb2 =3D 0xcf9627c0
#2  0xd0cbfef8 in NF_HOOK_THRESH (p=3D0xcfb3b620, skb=3D0xcf9627c0) at
include/linux/netfilter.h:206
        ret =3D <value optimised out>
#3  NF_HOOK (p=3D0xcfb3b620, skb=3D0xcf9627c0) at include/linux/netfilter=
=2Eh:228
No locals.
#4  br_handle_frame (p=3D0xcfb3b620, skb=3D0xcf9627c0) at
net/bridge/br_input.c:177
        dest =3D 0xcfa59dae "=C9=8AU", <incomplete sequence \307>
#5  0xc035d70f in handle_bridge (skb=3D0xcf9627c0) at net/core/dev.c:2344=

No locals.
#6  netif_receive_skb (skb=3D0xcf9627c0) at net/core/dev.c:2546
        ptype =3D <value optimised out>
        pt_prev =3D 0x0
        orig_dev =3D 0xcfb65020
        null_or_orig =3D 0x0
        null_or_bond =3D 0x0
        ret =3D -810209540
        type =3D <value optimised out>
#7  0xc035d8c5 in process_backlog (napi=3D<value optimised out>,
quota=3D<value optimised out>) at net/core/dev.c:2926
        skb =3D 0x1012
        work =3D 1
        start_time =3D 487863
#8  0xc035da70 in net_rx_action (h=3D<value optimised out>) at
net/core/dev.c:3057
        n =3D 0xc04fea5c
        work =3D 0
        weight =3D 64
        time_limit =3D 487865
        budget =3D 300
#9  0xc0126041 in __do_softirq () at kernel/softirq.c:219
        prev_count =3D 257
        h =3D 0x1012
        pending =3D 1
        max_restart =3D 10
        cpu =3D 0
#10 0xc01260f2 in do_softirq () at kernel/softirq.c:266
        flags =3D 582
#11 0xc035df5f in netif_rx_ni (skb=3D<value optimised out>) at
net/core/dev.c:2241
        err =3D 0
#12 0xd0cdc226 in tun_get_user (iocb=3D<value optimised out>,
iv=3D0xcfb2ff54, count=3D<value optimised out>, pos=3D0) at drivers/net/t=
un.c:666
        len =3D 64
        align =3D 2
        gso =3D {flags =3D 0 '\000', gso_type =3D 0 '\000', hdr_len =3D 0=
,
gso_size =3D 0, csum_start =3D 0, csum_offset =3D 0}
        pi =3D {flags =3D 0, proto =3D 8}
        skb =3D 0xcf9627c0
        offset =3D 0
#13 tun_chr_aio_write (iocb=3D<value optimised out>, iv=3D0xcfb2ff54,
count=3D<value optimised out>, pos=3D0) at drivers/net/tun.c:686
        file =3D <value optimised out>
        tun =3D 0xcfb10300
        result =3D 64
#14 0xc017bb12 in do_sync_write (filp=3D0xcf978300, buf=3D<value optimise=
d
out>, len=3D<value optimised out>, ppos=3D0xcfb2ff98) at fs/read_write.c:=
318
        iov =3D {iov_base =3D 0xbfb4b478, iov_len =3D 64}
        kiocb =3D {ki_run_list =3D {next =3D 0xcfb2fee0, prev =3D 0x4}, k=
i_flags
=3D 0, ki_users =3D 1, ki_key =3D 4294967295, ki_filp =3D 0xcf978300, ki_=
ctx =3D
0x0, ki_cancel =3D 0, ki_retry =3D 0, ki_dtor =3D 0, ki_obj =3D {user =3D=

0xcfb089c0, tsk =3D 0xcfb089c0}, ki_user_data =3D 0, ki_pos =3D 0,
          private =3D 0xc04d9e40, ki_opcode =3D 787, ki_nbytes =3D 348461=
4480,
ki_buf =3D 0xc013c430
"\203\304\024[^_]\303U\211\345WVS\203\354\020\203=3D\fdP\300", ki_left =3D=

64, ki_inline_vec =3D {iov_base =3D 0xcfb2e000, iov_len =3D 0}, ki_iovec =
=3D
0xcfb2ff50, ki_nr_segs =3D 3484614336,
          ki_cur_seg =3D 16, ki_list =3D {next =3D 0xcfb2ff5c, prev =3D 0=
x1},
ki_eventfd =3D 0xcf382730}
        ret =3D <value optimised out>
#15 0xc017c43c in vfs_write (file=3D0xcf978300, buf=3D0xbfb4b478 "",
count=3D3484757756, pos=3D0xcfb2ff98) at fs/read_write.c:347
        ret =3D <value optimised out>
#16 0xc017c561 in sys_write (fd=3D4, buf=3D0xbfb4b478 "", count=3D64) at
fs/read_write.c:399
        pos =3D 0
        file =3D 0xcf978300
        ret =3D -9
        fput_needed =3D 0
#17 0xc03e8471 in ?? () at arch/x86/kernel/entry_32.S:541
No locals.
Backtrace stopped: previous frame inner to this frame (corrupt stack?)
(gdb) print *brdev
**Cannot access memory at address 0x1012**


// commit //
  commit b33084be192ee1e347d98bb5c9e38a53d98d35e2
  Author: Herbert Xu <herbert@gondor.apana.org.au>
  Date:   Sat Feb 27 19:41:41 2010 +0000

    bridge: Avoid unnecessary clone on forward path

    When the packet is delivered to the local bridge device we may
    end up cloning it unnecessarily if no bridge port can receive
    the packet in br_flood.

    This patch avoids this by moving the skb_clone into br_flood.

    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>



--------------020509030608030006030109
Content-Type: text/x-patch;
 name="linux-next-20100313-bridge-utils.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="linux-next-20100313-bridge-utils.diff"

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index d61e6f7..8347916 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -19,6 +19,10 @@
 #include <linux/netfilter_bridge.h>
 #include "br_private.h"
=20
+static int deliver_clone(struct net_bridge_port *prev, struct sk_buff *s=
kb,
+			 void (*__packet_hook)(const struct net_bridge_port *p,
+					       struct sk_buff *skb));
+
 /* Don't forward packets to originating port or forwarding diasabled */
 static inline int should_deliver(const struct net_bridge_port *p,
 				 const struct sk_buff *skb)
@@ -94,14 +98,18 @@ void br_deliver(const struct net_bridge_port *to, str=
uct sk_buff *skb)
 }
=20
 /* called with rcu_read_lock */
-void br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
+void br_forward(const struct net_bridge_port *to, struct sk_buff *skb, s=
truct sk_buff *skb0)
 {
 	if (should_deliver(to, skb)) {
-		__br_forward(to, skb);
+		if (skb0)
+			deliver_clone(to, skb, __br_forward);
+		else
+			__br_forward(to, skb);
 		return;
 	}
=20
-	kfree_skb(skb);
+	if (!skb0)
+		kfree_skb(skb);
 }
=20
 static int deliver_clone(struct net_bridge_port *prev, struct sk_buff *s=
kb,
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 53b3985..08a72e6 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -90,7 +90,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
=20
 	if (skb) {
 		if (dst)
-			br_forward(dst->dst, skb);
+			br_forward(dst->dst, skb, skb2);
 		else
 			br_flood_forward(br, skb, skb2);
 	}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index fef0384..bfb8feb 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -252,7 +252,7 @@ extern void br_deliver(const struct net_bridge_port *=
to,
 		struct sk_buff *skb);
 extern int br_dev_queue_push_xmit(struct sk_buff *skb);
 extern void br_forward(const struct net_bridge_port *to,
-		struct sk_buff *skb);
+		struct sk_buff *skb, struct sk_buff *skb0);
 extern int br_forward_finish(struct sk_buff *skb);
 extern void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb)=
;
 extern void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,=



--------------020509030608030006030109--

--------------enig1F1E2C4FE5470F285BEFBE2E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkucSi8ACgkQ+6sI4XSM4u1MHgCffQ61z+3G1IOon7XQ3jKWxQLl
C/QAn29u5gDCbTeWl2LbsL7qWOwtaGUR
=atw9
-----END PGP SIGNATURE-----

--------------enig1F1E2C4FE5470F285BEFBE2E--
