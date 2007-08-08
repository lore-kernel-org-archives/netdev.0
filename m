From: David Miller <davem@davemloft.net>
Subject: Re: TCP's initial cwnd setting correct?...
Date: Tue, 07 Aug 2007 22:01:27 -0700 (PDT)
Message-ID: <20070807.220127.98862306.davem@davemloft.net>
References: <Pine.LNX.4.64.0708061508070.8788@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54324
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751299AbXHHFBc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 01:01:32 -0400
In-Reply-To: <Pine.LNX.4.64.0708061508070.8788@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 6 Aug 2007 15:37:15 +0300 (EEST)

> ...Another thing that makes me wonder, is the tp->mss_cache > 1460 ch=
eck=20
> as based on rfc3390 (and also it's precursor rfc2414) with up to 2190=
=20
> bytes MSS TCP can use 3 as initial cwnd...

I did the research and my memory was at least partially right.

Below is an old bogus change of mine and the later revert with
Alexey's explanation.

This seems to be dealing with receive window calculation issues,
rather than snd_cwnd.  But they might be related and you should
consider this very seriously.

commit 6b251858d377196b8cea20e65cae60f584a42735
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Wed Sep 28 16:31:48 2005 -0700

    [TCP]: Fix init_cwnd calculations in tcp_select_initial_window()
   =20
    Match it up to what RFC2414 really specifies.
    Noticed by Rick Jones.
   =20
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d6e3d26..caf2e2c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -190,15 +190,16 @@ void tcp_select_initial_window(int __space, __u32=
 mss,
 	}
=20
 	/* Set initial window to value enough for senders,
-	 * following RFC1414. Senders, not following this RFC,
+	 * following RFC2414. Senders, not following this RFC,
 	 * will be satisfied with 2.
 	 */
 	if (mss > (1<<*rcv_wscale)) {
-		int init_cwnd =3D 4;
-		if (mss > 1460*3)
+		int init_cwnd;
+
+		if (mss > 1460)
 			init_cwnd =3D 2;
-		else if (mss > 1460)
-			init_cwnd =3D 3;
+		else
+			init_cwnd =3D (mss > 1095) ? 3 : 4;
 		if (*rcv_wnd > init_cwnd*mss)
 			*rcv_wnd =3D init_cwnd*mss;
 	}
--------------------
commit 01ff367e62f0474e4d39aa5812cbe2a30d96e1e9
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Thu Sep 29 17:07:20 2005 -0700

    [TCP]: Revert 6b251858d377196b8cea20e65cae60f584a42735
   =20
    But retain the comment fix.
   =20
    Alexey Kuznetsov has explained the situation as follows:
   =20
    --------------------
   =20
    I think the fix is incorrect. Look, the RFC function init_cwnd(mss)=
 is
    not continuous: f.e. for mss=3D1095 it needs initial window 1095*4,=
 but
    for mss=3D1096 it is 1096*3. We do not know exactly what mss sender=
 used
    for calculations. If we advertised 1096 (and calculate initial wind=
ow
    3*1096), the sender could limit it to some value < 1096 and then it
    will need window his_mss*4 > 3*1096 to send initial burst.
   =20
    See?
   =20
    So, the honest function for inital rcv_wnd derived from
    tcp_init_cwnd() is:
   =20
    	init_rcv_wnd(mss)=3D
    	  min { init_cwnd(mss1)*mss1 for mss1 <=3D mss }
   =20
    It is something sort of:
   =20
    	if (mss < 1096)
    		return mss*4;
    	if (mss < 1096*2)
    		return 1096*4;
    	return mss*2;
   =20
    (I just scrablled a graph of piece of paper, it is difficult to see=
 or
    to explain without this)
   =20
    I selected it differently giving more window than it is strictly
    required.  Initial receive window must be large enough to allow sen=
der
    following to the rfc (or just setting initial cwnd to 2) to send
    initial burst.  But besides that it is arbitrary, so I decided to g=
ive
    slack space of one segment.
   =20
    Actually, the logic was:
   =20
    If mss is low/normal (<=3Dethernet), set window to receive more tha=
n
    initial burst allowed by rfc under the worst conditions
    i.e. mss*4. This gives slack space of 1 segment for ethernet frames=
=2E
   =20
    For msses slighlty more than ethernet frame, take 3. Try to give sl=
ack
    space of 1 frame again.
   =20
    If mss is huge, force 2*mss. No slack space.
   =20
    Value 1460*3 is really confusing. Minimal one is 1096*2, but beside=
s
    that it is an arbitrary value. It was meant to be ~4096. 1460*3 is
    just the magic number from RFC, 1460*3 =3D 1095*4 is the magic :-),=
 so
    that I guess hands typed this themselves.
   =20
    --------------------
   =20
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index caf2e2c..c5b911f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -194,12 +194,11 @@ void tcp_select_initial_window(int __space, __u32=
 mss,
 	 * will be satisfied with 2.
 	 */
 	if (mss > (1<<*rcv_wscale)) {
-		int init_cwnd;
-
-		if (mss > 1460)
+		int init_cwnd =3D 4;
+		if (mss > 1460*3)
 			init_cwnd =3D 2;
-		else
-			init_cwnd =3D (mss > 1095) ? 3 : 4;
+		else if (mss > 1460)
+			init_cwnd =3D 3;
 		if (*rcv_wnd > init_cwnd*mss)
 			*rcv_wnd =3D init_cwnd*mss;
 	}
