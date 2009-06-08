From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [Security, resend] Instant crash with rtl8169 and large packets
Date: Tue, 09 Jun 2009 01:27:55 +0400
Message-ID: <4A2D825B.6090409@msgid.tls.msk.ru>
References: <4A2D1147.8020101@msgid.tls.msk.ru> <4A2D1FE4.5030100@gmail.com> <4A2D25F6.9080300@msgid.tls.msk.ru> <4A2D2906.6090002@gmail.com> <4A2D301D.9040301@msgid.tls.msk.ru> <4A2D3568.6010901@gmail.com> <4A2D3BC6.3040904@msgid.tls.msk.ru> <4A2D4AA7.6020204@gmail.com> <4A2D6D0C.6060206@msgid.tls.msk.ru> <4A2D7FFE.9070701@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([81.13.33.159]:57965 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753069AbZFHV1z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2009 17:27:55 -0400
In-Reply-To: <4A2D7FFE.9070701@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Michael Tokarev a =C3=A9crit :
>> Eric Dumazet wrote:
>> []
>>> OK I suspect driver is buggy since 2.6.10 days :)
>>>
>>> Could you try this patch ?
>> Tried it, and it appears to work.  Tried various MTU combinations
>> and packet sizes.  Checked iperf too, with and without the patch
>> and with different MTU too, to be sure the patch does not introduce
>> any slowdowns - everything looks sane.  In case the incoming packet
>> is larger than the RX buffer size, `errors' and `frames' RX stats
>> gets incremented.
>>
>> The only somewhat odd thing is that rx path accepts packets larger
>> than MTU by 3 bytes.  For example, if I set mtu to 2000, the
>> largest packet I can send is 2003 bytes; with mtu=3D2002, largest
>> actual packet size is 2005 bytes.  This is complete frame - in
>> terms of ping size (ping -s) it's 1975 and 1977 bytes.  That to
>> say, maybe we still have some corner case somewhere, for packets
>> larger than mtu by 1, 2 or 3 bytes.
>>
>> Also I didn't try MTU < 1500.
>>
>> Other than that,
>>
>> Tested-By: Michael Tokarev <mjt@tls.msk.ru>
>=20
> Could you confirm this last patch was ok without former two patches ?

Yes, it's the last patch without former two which were for
debugging as I understand them.  Got fresh 2.6.29.4 source
and applied your last patch to it, recompiled.  All the testing
above were done this way.

>> And by the way, your email client uses quoted-printable encoding.
>> I had to use trivial perl one-liner to convert your patches to
>> plaintext.  JFYI.
>=20
> Ah yes, this is when I reply to one of your mail, thank you for the h=
int.
>=20
> When submitting a new mail, my thunderbird agent uses a regular "Cont=
ent-Transfer-Encoding: 7bit"

Heh.  I know why it's this way.  Due to your
"Michael Tokarev a =C3=A9crit" in first line.  Which
gets added by Thunderbird, and which causes it
to force quoted-printable instead of 7bit, because
of this "=C3=A9".  Mine offers "=D0=BF=D0=B8=D1=88=D0=B5=D1=82" instead=
 of "=C3=A9crit"
("wrote" in English) and the result is similar.

> BTW, this driver uses NAPI, but still calls dev_kfree_skb_irq() in rt=
l8169_tx_interrupt()
>=20
> You probably can get better performance calling dev_kfree_skb(tx_skb-=
>skb); instead
>=20
> @@ -3372,7 +3372,7 @@ static void rtl8169_tx_interrupt(struct net_dev=
ice *dev,
>                 rtl8169_unmap_tx_skb(tp->pci_dev, tx_skb, tp->TxDescA=
rray + entry);
>=20
>                 if (status & LastFrag) {
> -                       dev_kfree_skb_irq(tx_skb->skb);
> +                       dev_kfree_skb(tx_skb->skb);
>                         tx_skb->skb =3D NULL;
>                 }
>                 dirty_tx++;

Well, the performance is quite good -- 935Mb/sec according to iperf
for TCP.  With UDP I got 1.05Gb/sec, but CPU usage is 100% during
all test time (for TCP test the CPU is in use for less than 5%).
I'll try the change tomorrow (it's 01:27 here now already).

Thank you for the good work!

/mjt
