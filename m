From: Tom Herbert <therbert@google.com>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Wed, 30 Nov 2011 20:06:09 -0800
Message-ID: <CA+mtBx_CUsuGunKONwBNA8qyVni16+RtrRL8w=THYY0mEDcvaA@mail.gmail.com>
References: <CA+mtBx8+sajFaCWqHRr+pY5EAHwN8G61v6cr-HydYhbbdxAgHQ@mail.gmail.com>
	<1322710962.2577.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:34436 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753799Ab1LAEGK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 23:06:10 -0500
Received: by ghrr1 with SMTP id r1so1406979ghr.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 20:06:10 -0800 (PST)
In-Reply-To: <1322710962.2577.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2011 at 7:42 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mercredi 30 novembre 2011 =E0 17:48 -0800, Tom Herbert a =E9crit :
>> I believe that skb->data_len might no be computed correctly in
>> tcp_sendmsg. =A0Specifically, when skb_add_data_nocache (or
>> skb_add_data) is called skb->data_len is not updated (skb_put only
>> updates skb->len). =A0This results in the datalen in the head skbuf
>> being zero so any subsequent uses of the value lead to incorrect
>> results. =A0For instance, skb_headlen returns the length of the head
>> skbu data and not just that of the headers. =A0If I'm reading this
>> correctly, it's a pretty fundamental bug.
>>
>> I don't have a fix for this yet.
>>
>> Tom
>
> On which tree do you see a problem ?
>
> For example net-next seems fine to me :
>
>

On net-next.  Look at skb_add_data_nocache.  This doesn't touch
data_len, and really can't since skb_put wants skb linearized.

Actually, I think I am misinterpreting the meaning of data_len, looks
like it is intended to return the number of bytes in the page buffer
area (comment on the function would be have been nice ;-) ).  It would
seem that e1000e driver might be misinterpreting it also:

        segs =3D skb_shinfo(skb)->gso_segs ? : 1;
        /* multiply data chunks by size of headers */
        bytecount =3D ((segs - 1) * skb_headlen(skb)) + skb->len;

So maybe the bug is  that e1000e is misusing the function (and it
looks like some other drivers would be too)?.
