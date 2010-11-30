From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 1/2] af_packet: use vmalloc_to_page() instead for the
 addresss returned by vmalloc()
Date: Tue, 30 Nov 2010 22:27:48 +0800
Message-ID: <AANLkTi=c=3ZLJmcyN8a=GBKYOcxd1YuDniM+gn0aRdLs@mail.gmail.com>
References: <1291125408-14389-1-git-send-email-xiaosuo@gmail.com> <1291126341.2904.82.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52502 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074Ab0K3O2K convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 09:28:10 -0500
Received: by fxm8 with SMTP id 8so1201517fxm.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 06:28:09 -0800 (PST)
In-Reply-To: <1291126341.2904.82.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 30, 2010 at 10:12 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le mardi 30 novembre 2010 =E0 21:56 +0800, Changli Gao a =E9crit :
>> The following commit causes the pgv->buffer may point to the memory
>> returned by vmalloc(). And we can't use virt_to_page() for the vmall=
oc
>> address.
>>
>> This patch introduces a new inline function pgv_to_page(), which cal=
ls
>> vmalloc_to_page() for the vmalloc address, and virt_to_page() for th=
e
>> __get_free_pages address.
>>
>> =A0 =A0 commit 0e3125c755445664f00ad036e4fc2cd32fd52877
>> =A0 =A0 Author: Neil Horman <nhorman@tuxdriver.com>
>> =A0 =A0 Date: =A0 Tue Nov 16 10:26:47 2010 -0800
>>
>> =A0 =A0 packet: Enhance AF_PACKET implementation to not require high=
 order contiguous memory allocation (v4)
>>
>
> nice catch.
>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> ---
>> =A0net/packet/af_packet.c | =A0 21 ++++++++++++++-------
>> =A01 file changed, 14 insertions(+), 7 deletions(-)
>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> index 422705d..0171b20 100644
>> --- a/net/packet/af_packet.c
>> +++ b/net/packet/af_packet.c
>> @@ -224,6 +224,13 @@ struct packet_skb_cb {
>>
>> =A0#define PACKET_SKB_CB(__skb) ((struct packet_skb_cb *)((__skb)->c=
b))
>>
>> +static inline struct page *pgv_to_page(void *addr)
>> +{
>> + =A0 =A0 if (is_vmalloc_addr(addr))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return vmalloc_to_page(addr);
>
> Hmm, I am wondering if calling vmalloc_to_page(addr) several times fo=
r
> each packet is not too expensive ? I believe it is.
>
> What about caching "struct page *" pointer somewhere ?
>
> Then later we have :
>
>> - =A0 =A0 =A0 =A0 =A0 =A0 p_start =3D virt_to_page(h.raw);
>> - =A0 =A0 =A0 =A0 =A0 =A0 p_end =3D virt_to_page(h_end);
>> + =A0 =A0 =A0 =A0 =A0 =A0 p_start =3D pgv_to_page(h.raw);
>> + =A0 =A0 =A0 =A0 =A0 =A0 p_end =3D pgv_to_page(h_end);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (p_start <=3D p_end) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 flush_dcache_page(p_star=
t);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p_start++;
>
> This was OK before Neil patch... after vmalloc(), assumption that
> p_start can be incremented is completely wrong.
>
> To fix this, we need something else than your patch.
>

Yes, you are right, and tpacket_fill_packet() has the same issue. Thank=
s.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
