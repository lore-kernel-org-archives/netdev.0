From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [Security, resend] Instant crash with rtl8169 and large packets
Date: Mon, 08 Jun 2009 23:17:50 +0200
Message-ID: <4A2D7FFE.9070701@cosmosbay.com>
References: <4A2D1147.8020101@msgid.tls.msk.ru> <4A2D1FE4.5030100@gmail.com> <4A2D25F6.9080300@msgid.tls.msk.ru> <4A2D2906.6090002@gmail.com> <4A2D301D.9040301@msgid.tls.msk.ru> <4A2D3568.6010901@gmail.com> <4A2D3BC6.3040904@msgid.tls.msk.ru> <4A2D4AA7.6020204@gmail.com> <4A2D6D0C.6060206@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43920 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbZFHVR5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 17:17:57 -0400
In-Reply-To: <4A2D6D0C.6060206@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Tokarev a =E9crit :
> Eric Dumazet wrote:
> []
>> OK I suspect driver is buggy since 2.6.10 days :)
>>
>> Could you try this patch ?
>=20
> Tried it, and it appears to work.  Tried various MTU combinations
> and packet sizes.  Checked iperf too, with and without the patch
> and with different MTU too, to be sure the patch does not introduce
> any slowdowns - everything looks sane.  In case the incoming packet
> is larger than the RX buffer size, `errors' and `frames' RX stats
> gets incremented.
>=20
> The only somewhat odd thing is that rx path accepts packets larger
> than MTU by 3 bytes.  For example, if I set mtu to 2000, the
> largest packet I can send is 2003 bytes; with mtu=3D2002, largest
> actual packet size is 2005 bytes.  This is complete frame - in
> terms of ping size (ping -s) it's 1975 and 1977 bytes.  That to
> say, maybe we still have some corner case somewhere, for packets
> larger than mtu by 1, 2 or 3 bytes.
>=20
> Also I didn't try MTU < 1500.
>=20
> Other than that,
>=20
> Tested-By: Michael Tokarev <mjt@tls.msk.ru>

Could you confirm this last patch was ok without former two patches ?

>=20
> And by the way, your email client uses quoted-printable encoding.
> I had to use trivial perl one-liner to convert your patches to
> plaintext.  JFYI.

Ah yes, this is when I reply to one of your mail, thank you for the hin=
t.

When submitting a new mail, my thunderbird agent uses a regular "Conten=
t-Transfer-Encoding: 7bit"


BTW, this driver uses NAPI, but still calls dev_kfree_skb_irq() in rtl8=
169_tx_interrupt()

You probably can get better performance calling dev_kfree_skb(tx_skb->s=
kb); instead

@@ -3372,7 +3372,7 @@ static void rtl8169_tx_interrupt(struct net_devic=
e *dev,
                rtl8169_unmap_tx_skb(tp->pci_dev, tx_skb, tp->TxDescArr=
ay + entry);

                if (status & LastFrag) {
-                       dev_kfree_skb_irq(tx_skb->skb);
+                       dev_kfree_skb(tx_skb->skb);
                        tx_skb->skb =3D NULL;
                }
                dirty_tx++;



