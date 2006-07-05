From: "Angelo P. Castellani" <angelo.castellani@gmail.com>
Subject: [TCP] window reduction fix
Date: Wed, 5 Jul 2006 18:24:30 +0200
Message-ID: <8dd26e70607050924q48954801h8fd4c32efa37929@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_177737_18163775.1152116670885"
Cc: vacirca@infocom.uniroma1.it,
	"Andrea Baiocchi" <andrea.baiocchi@uniroma1.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:51932 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964843AbWGEQYc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 12:24:32 -0400
Received: by nf-out-0910.google.com with SMTP id m18so517940nfc
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2006 09:24:31 -0700 (PDT)
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_177737_18163775.1152116670885
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I forward the message because it seems hasn't get through to mailing
list (removing references to a word that seems blocking the message).

The previous message "[TCP] window update during recovery (continuing
on window reduction)" references this one

Regards,
Angelo P. Castellani
---------- Forwarded message ----------
From: Angelo P. Castellani <angelo.castellani+lkml@gmail.com>
Date: 5-lug-2006 16.22
Subject: [TCP] window reduction fix
To: netdev <netdev@vger.kernel.org>
Cc: Francesco Vacirca <francesco@net.infocom.uniroma1.it>, Andrea
Baiocchi <andrea.baiocchi@uniroma1.it>


When the receiver buffer is filling up, it should reduce the allowed
receive window value piggybacked in the acks, according to the free
space actually left in the buffer.

So it should send in the tcp acks returning to the sender a window
field with a value not higher than the space available to store
incoming segments.

The attached patch addresses this issue, requests to the sender a
window size not bigger than the free space for incoming data.

Regards,
Angelo P. Castellani

------=_Part_177737_18163775.1152116670885
Content-Type: text/x-patch; name=fix_win_reduction.diff; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
X-Attachment-Id: f_ep9s3ai6
Content-Disposition: attachment; filename="fix_win_reduction.diff"

diff -urd linux-2.6.16-orig/net/ipv4/tcp_output.c linux-2.6.16-winreduction=
/net/ipv4/tcp_output.c
--- linux-2.6.16-orig/net/ipv4/tcp_output.c=092006-05-16 14:53:02.000000000=
 +0200
+++ linux-2.6.16-winreduction/net/ipv4/tcp_output.c=092006-07-05 16:35:55.0=
00000000 +0200
@@ -218,18 +218,15 @@
 =09u32 cur_win =3D tcp_receive_window(tp);
 =09u32 new_win =3D __tcp_select_window(sk);
=20
-=09/* Never shrink the offered window */
-=09if(new_win < cur_win) {
-=09=09/* Danger Will Robinson!
-=09=09 * Don't update rcv_wup/rcv_wnd here or else
-=09=09 * we will not be able to advertise a zero
-=09=09 * window in time.  --DaveM
-=09=09 *
-=09=09 * Relax Will Robinson.
-=09=09 */
-=09=09new_win =3D cur_win;
-=09}
-=09tp->rcv_wnd =3D new_win;
+=09/* Danger Will Robinson!
+=09 * Don't update rcv_wup/rcv_wnd here or else
+=09 * we will not be able to advertise a zero
+=09 * window in time.  --DaveM
+=09 *
+=09 * Relax Will Robinson.
+=09 */
+=09// Anyway let's send the right window reduction to the sender.
+=09tp->rcv_wnd =3D max( new_win, cur_win );
 =09tp->rcv_wup =3D tp->rcv_nxt;
=20
 =09/* Make sure we do not exceed the maximum possible





------=_Part_177737_18163775.1152116670885--
