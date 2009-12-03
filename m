From: Stanislav Brabec <sbrabec@suse.cz>
Subject: Re: [PATCH][stable] b44 WOL setup: one-bit-off stack corruption
 kernel panic fix
Date: Thu, 03 Dec 2009 15:56:28 +0100
Message-ID: <1259852188.8163.58.camel@hammer.suse.cz>
References: <1259761547.8709.264.camel@hammer.suse.cz>
	 <1259764520.8709.293.camel@hammer.suse.cz>
	 <20091202.154220.118775778.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zambrano@broadcom.com, linux-kernel@vger.kernel.org,
	stable@kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33518 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756150AbZLCO4M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 09:56:12 -0500
In-Reply-To: <20091202.154220.118775778.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Stanislav Brabec <sbrabec@suse.cz>
> Date: Wed, 02 Dec 2009 15:35:20 +0100
> >>=20
> >> It seems that this problem affects all kernel versions since commi=
t
> >> 725ad800 on 2006-06-20.
> >=20
> > stable@kernel.org may be interested as well. Adding Cc:.
>=20
> netdev@vger.kernel.org is even more interested.  Please post all
> networking patches CC:'d there so they get properly logged
> and tracked in patchwork.

OK, sending again with another Cc::

About 50% of shutdowns of b44 Ethernet adapter ends by kernel panic wit=
h
kernels compiled with stack-protector.

Checking b44_magic_pattern() return values, one call of
b44_magic_pattern() returns 127. It means, that set_bit(128, pmask) was
called on line 1509. It means that bit 0 of 17th byte of pmask was
overwritten. But pmask has only 16 bytes. Stack corruption happens.
=20
It seems that set_bit() on line 1509 always writes one bit off.

The fix does not only solve the stack corruption, but also makes Wake O=
n
LAN working on my onboard B44 on Asus A7V-333X mainboard.

It seems that this problem affects all kernel versions since commit
725ad800 on 2006-06-20.

Signed-off-by: Stanislav Brabec <sbrabec@suse.cz>
Cc: netdev@vger.kernel.org
Cc: stable@kernel.org
Cc: Gary Zambrano <zambrano@broadcom.com>

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 2a91323..4869adb 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1505,8 +1505,7 @@ static int b44_magic_pattern(u8 *macaddr, u8 *ppa=
ttern, u8 *pmask, int offset)
                for (k =3D 0; k< ethaddr_bytes; k++) {
                        ppattern[offset + magicsync +
                                (j * ETH_ALEN) + k] =3D macaddr[k];
-                       len++;
-                       set_bit(len, (unsigned long *) pmask);
+                       set_bit(len++, (unsigned long *) pmask);
                }
        }
        return len - 1;


--=20
Best Regards / S pozdravem,

Stanislav Brabec
software developer
---------------------------------------------------------------------
SUSE LINUX, s. r. o.                          e-mail: sbrabec@suse.cz
Lihovarsk=E1 1060/12           tel: +420 284 028 966, +49 911 740538747
190 00 Praha 9                                  fax: +420 284 028 951
Czech Republic                                    http://www.suse.cz/

