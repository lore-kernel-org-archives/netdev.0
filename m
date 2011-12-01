From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Thu, 01 Dec 2011 04:42:42 +0100
Message-ID: <1322710962.2577.3.camel@edumazet-laptop>
References: <CA+mtBx8+sajFaCWqHRr+pY5EAHwN8G61v6cr-HydYhbbdxAgHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:58896 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753660Ab1LADmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 22:42:46 -0500
Received: by eaak14 with SMTP id k14so1582453eaa.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 19:42:45 -0800 (PST)
In-Reply-To: <CA+mtBx8+sajFaCWqHRr+pY5EAHwN8G61v6cr-HydYhbbdxAgHQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 30 novembre 2011 =C3=A0 17:48 -0800, Tom Herbert a =C3=A9cr=
it :
> I believe that skb->data_len might no be computed correctly in
> tcp_sendmsg.  Specifically, when skb_add_data_nocache (or
> skb_add_data) is called skb->data_len is not updated (skb_put only
> updates skb->len).  This results in the datalen in the head skbuf
> being zero so any subsequent uses of the value lead to incorrect
> results.  For instance, skb_headlen returns the length of the head
> skbu data and not just that of the headers.  If I'm reading this
> correctly, it's a pretty fundamental bug.
>=20
> I don't have a fix for this yet.
>=20
> Tom

On which tree do you see a problem ?

=46or example net-next seems fine to me :


static inline int skb_copy_to_page_nocache(struct sock *sk, char __user=
 *from,
                                           struct sk_buff *skb,
                                           struct page *page,
                                           int off, int copy)
{
        int err;

        err =3D skb_do_copy_data_nocache(sk, skb, from, page_address(pa=
ge) + off,
                                       copy, skb->len);
        if (err)
                return err;

        skb->len             +=3D copy;
        skb->data_len        +=3D copy;
        skb->truesize        +=3D copy;
        sk->sk_wmem_queued   +=3D copy;
        sk_mem_charge(sk, copy);
        return 0;
}
