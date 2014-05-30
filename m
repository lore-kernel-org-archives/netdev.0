From: Stefan Bader <stefan.bader@canonical.com>
Subject: Re: [PATCH net-next] xen-netfront: try linearizing SKB if it occupies
 too many slots
Date: Fri, 30 May 2014 10:06:48 +0200
Message-ID: <53883C18.2050708@canonical.com>
References: <1400238496-2471-1-git-send-email-wei.liu2@citrix.com> <1400245474.7973.154.camel@edumazet-glaptop2.roam.corp.google.com> <20140516131145.GK18551@zion.uk.xensource.com> <1400250068.7973.171.camel@edumazet-glaptop2.roam.corp.google.com> <20140516143653.GL18551@zion.uk.xensource.com> <1400253739.7973.183.camel@edumazet-glaptop2.roam.corp.google.com> <20140516153452.GM18551@zion.uk.xensource.com> <53763CD1.6060500@citrix.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="vvw3gCFSp9D1E683H3gqCAFeiw4pjuQR2"
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	David Vrabel <david.vrabel@citrix.com>,
	Konrad Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:45502 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbaE3IG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 04:06:57 -0400
In-Reply-To: <53763CD1.6060500@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--vvw3gCFSp9D1E683H3gqCAFeiw4pjuQR2
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 16.05.2014 18:29, Zoltan Kiss wrote:
> On 16/05/14 16:34, Wei Liu wrote:
>> On Fri, May 16, 2014 at 08:22:19AM -0700, Eric Dumazet wrote:
>>> On Fri, 2014-05-16 at 15:36 +0100, Wei Liu wrote:
>>>> On Fri, May 16, 2014 at 07:21:08AM -0700, Eric Dumazet wrote:
>>>>> On Fri, 2014-05-16 at 14:11 +0100, Wei Liu wrote:
>>>>>
>>>>>> It's not that common to trigger this, I only saw a few reports. In=
 fact
>>>>>> Stefan's report is the first one that comes with a method to repro=
duce
>>>>>> it.
>>>>>>
>>>>>> I tested with redis-benchmark on a guest with 256MB RAM and only s=
aw a
>>>>>> few "failed to linearize", never saw a single one with 1GB guest.
>>>>>
>>>>> Well, I am just saying. This is asking order-5 allocations, and yes=
,
>>>>> this is going to fail after few days of uptime, no matter what you =
try.
>>>>>
>>>>
>>>> Hmm... I see what you mean -- memory fragmentation leads to allocati=
on
>>>> failure. Thanks.
>>>
>>> In the mean time, have you tried to lower gso_max_size ?
>>>
>>> Setting it witk netif_set_gso_max_size() to something like 56000 migh=
t
>>> avoid the problem.
>>>
>>> (Not sure if it is applicable in your case)
>>>
>>
>> It works, at least in this Redis testcase. Could you explain a bit whe=
re
>> this 56000 magic number comes from? :-)
>>
>> Presumably I can derive it from some constant in core network code?
>=20
> I guess it just makes more unlikely to have packets with problematic la=
yout. But the following packet would still fail:
> linear buffer : 80 bytes, on 2 pages
> 17 frags, 80 bytes each, each spanning over page boundary.
>=20
> I just had an idea: a modified version of xenvif_handle_frag_list funct=
ion from netback would be useful for us here. It recreates the frags arra=
y on fully utilized 4k pages. Plus we can use pskb_expand_head to reduce =
the page number on the linear buffer (although it might not work, see my =
comment in the patch)
> The worst case linear buffer then spans N+1 pages, and has N*PAGE_SIZE+=
1 bytes. Then the frags after this coalescing should have 16*PAGE_SIZE - =
(N*PAGE_SIZE+2) bytes at most, which is 16-N pages. Altogether that's 16+=
1 page, which should definitely fit!
> This is what I mean:
>

I had been idly wondering about this onwards. And trying to understand th=
e whole
skb handling environment, I tried to come up with some idea as well. It m=
ay be
totally stupid and using the wrong assumptions. It seems to work in the s=
ense
that things did not blow up into my face immediately and somehow I did no=
t see
dropped packages due to the number of slots either.
But again, I am not sure I am doing the right thing. The idea was to just=
 try to
get rid of so many compound pages (which I believe are the only ones that=
 can
have an offset big enough to allow some alignment savings)...

-Stefan


=46rom 8571b106643b32296e58526e2fbe97c330877ac8 Mon Sep 17 00:00:00 2001
From: Stefan Bader <stefan.bader@canonical.com>
Date: Thu, 29 May 2014 12:18:01 +0200
Subject: [PATCH] xen-netfront: Align frags to fit max slots

In cases where the frags in a skb require more than MAX_SKB_FRAGS + 1
(=3D 18) 4K pages of grant pages, try to reduce the footprint by moving
the data to new pages and have it aligned to the beginning.
Then replace the page in the frag and release the old one. This sure is
more expensive in compute but should happen not too often and sounds
better than to just drop the packet in that case.

Signed-off-by: Stefan Bader <stefan.bader@canonical.com>
---
 drivers/net/xen-netfront.c | 65 ++++++++++++++++++++++++++++++++++++++++=
+++---
 1 file changed, 62 insertions(+), 3 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 158b5e6..ad71e5c 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -544,6 +544,61 @@ static int xennet_count_skb_frag_slots(struct sk_buf=
f *skb)
 	return pages;
 }

+/*
+ * Align data to new pages in order to save slots required to
+ * transmit this buffer.
+ * @skb - socket buffer
+ * @target - number of pages to save
+ * returns the number of pages the fragments have been reduced of
+ */
+static int xennet_align_frags(struct sk_buff *skb, int target)
+{
+	int i, frags =3D skb_shinfo(skb)->nr_frags;
+	int reduced =3D 0;
+
+	for (i =3D 0; i < frags; i++) {
+		skb_frag_t *frag =3D skb_shinfo(skb)->frags + i;
+		struct page *fpage =3D skb_frag_page(frag);
+		struct page *npage;
+		unsigned long size;
+		unsigned long offset;
+		gfp_t gfp;
+		int order;
+
+		if (!PageCompound(fpage))
+			continue;
+
+		size =3D skb_frag_size(frag);
+		offset =3D frag->page_offset & ~PAGE_MASK;
+
+		/*
+		 * If the length of data in the last subpage of a compound
+		 * page is smaller than the offset into the first data sub-
+		 * page, we can save a subpage by copying data around.
+		 */
+		if ( ((offset + size) & ~PAGE_MASK) > offset )
+			continue;
+
+		gfp =3D GFP_ATOMIC | __GFP_COLD;
+		order =3D PFN_UP(size);
+		if (order)
+			gfp |=3D __GFP_COMP | __GFP_NOWARN;
+
+		npage =3D alloc_pages(gfp, order);
+		if (!npage)
+			break;
+		memcpy(page_address(npage), skb_frag_address(frag), size);
+		frag->page.p =3D npage;
+		frag->page_offset =3D 0;
+		put_page(fpage);
+
+		if (++reduced >=3D target)
+			break;
+	}
+
+	return reduced;
+}
+
 static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev=
)
 {
 	unsigned short id;
@@ -573,9 +628,13 @@ static int xennet_start_xmit(struct sk_buff *skb, st=
ruct
net_device *dev)
 	slots =3D DIV_ROUND_UP(offset + len, PAGE_SIZE) +
 		xennet_count_skb_frag_slots(skb);
 	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
-		net_alert_ratelimited(
-			"xennet: skb rides the rocket: %d slots\n", slots);
-		goto drop;
+		slots -=3D xennet_align_frags(skb, slots - (MAX_SKB_FRAGS + 1));
+		if (slots > MAX_SKB_FRAGS + 1) {
+			net_alert_ratelimited(
+				"xennet: skb rides the rocket: %d slots\n",
+				slots);
+			goto drop;
+		}
 	}

 	spin_lock_irqsave(&np->tx_lock, flags);
--=20
1.9.1




--vvw3gCFSp9D1E683H3gqCAFeiw4pjuQR2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCgAGBQJTiDwYAAoJEOhnXe7L7s6jr8EQAK8ac6qO5FOtqfyDnKOazdAx
9qy/mYj0hehOK1Fi2RGR7GqgJmu2DhIr3sfr0vKaiGdQYBEWFxvmQdd7hb1oXTKl
xeo8xggl04TkqFjvK5SBlkxJntUSz84T2MbjnlF+4pTpb04IDOIOeLxWMGgn0m8F
TtB2GG3QnJwCBq5D4brVMOpmiExTpTvRqo6ZIa80ZyD52QZ0pHLJXage8LhR6O0k
Ij0cfNfw+POx7VCwMpseLhKzVRWYXANXVd/2UtaOlQMdpLSGWlha5noU4oW7mGZ9
ID6caYMKCsYDopX78MXaZ06az9u5tgxgrVxfwdvXvZY3RoCw3lwglL97S51EqHCb
7cuBysQkKKWuv5A4Ywj9JdZQeQl4G3LYTcHNJxmlVbDwDiJyTAiVSIbqgRne6IMD
2c+Pniv3lShJPtz319hyjmes6+JiZ2OSS7jt97ryCWbJvM1pfucS9zP9Fv1ZEtt7
RmN58ZUcVVxJyfydkuW+7EdqryqHpwibtpC06w9rWlHSNNTQQ/8zxW66UOa5H97L
vADyUZks0nz56aTugZcJO13nxhwLB0aIT5U05YaK6Ooqrw/8CmWRwY6hLmweuRV6
v2Ti9ibcv0ymeRt9R5HdxjeydhK7maI4UmMJhoYsqu8ZX/ddAkRETokLWPFO1Avs
fxLrjZ18kQ3R8EjFo3n7
=0Xj/
-----END PGP SIGNATURE-----

--vvw3gCFSp9D1E683H3gqCAFeiw4pjuQR2--
