From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 7/8] net: ip_tunnel: remove 'csum_help' argument
 to iptunnel_handle_offloads
Date: Mon, 11 Jan 2016 08:39:32 -0800
Message-ID: <CAKgT0Ufw9djq-V8YAXjq21gg7rE5=-Dp4o4GmdGk+6Diu4mDNw@mail.gmail.com>
References: <56901197.8040808@solarflare.com>
	<56901244.8060809@solarflare.com>
	<CAKgT0UdQzW2+n7S3YOhAJVZY-q5bjYaQB0jDn7AD3zp2ZrkGZg@mail.gmail.com>
	<CALx6S34MRoLw_JiHuyDANwoF9+u7k9R-UDb_RGP+L-d9D=f3WQ@mail.gmail.com>
	<CAKgT0UeZwSm4oKoydXWU3iWmjL5m6H=K=hJ2wAkp_GugbZJwjA@mail.gmail.com>
	<5693AD25.4020904@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36403 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761161AbcAKQjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 11:39:33 -0500
Received: by mail-io0-f193.google.com with SMTP id q21so26334015iod.3
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 08:39:32 -0800 (PST)
In-Reply-To: <5693AD25.4020904@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2016 at 5:24 AM, Edward Cree <ecree@solarflare.com> wrote:
> On 09/01/16 02:05, Alexander Duyck wrote:
>> If we clear skb->encapsulation if we don't have CHECKSUM_PARTIAL set
>> then we don't have the issue.  Really the addition of the line
>> clearing skb->encapsulation should probably be added to the first
>> patch so that we don't leave skb->encapsulation set when we aren't
>> requesting offloads.
> Next version of series will have (in this patch)
>   if (skb->ip_summed != CHECKSUM_PARTIAL) {
>     skb->ip_summed = CHECKSUM_NONE;
>     skb->encapsulation = 0;
>   }
>
> Will that do, or does it need to be squeezed into an earlier patch in the series (which one?)

Your first patch is probably the best place for it.  Then when you
start setting false it doesn't introduce any errors.

Also I was doing a bit more work on the lco_csum function and think I
have come up with something a bit more elegant that allows for the
function to be easily used in the GSO routine for UDP tunnels.  Here
is a snippet from the patch I am working with below.  Odds are the
formatting will get trashed due to my mail client.  What I will do is
email you the full patch and the GSO patch I have as RFCs to look over
and possibly incorporate into your own.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

---

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6b6bd42d6134..94244ab47e1b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2161,6 +2161,11 @@ static inline int
skb_checksum_start_offset(const struct sk_buff *skb)
        return skb->csum_start - skb_headroom(skb);
 }

+static inline unsigned char *skb_checksum_start(const struct sk_buff *skb)
+{
+       return skb->head + skb->csum_start;
+}
+
 static inline int skb_transport_offset(const struct sk_buff *skb)
 {
        return skb_transport_header(skb) - skb->data;
@@ -3578,6 +3583,17 @@ static inline __sum16 gso_make_checksum(struct
sk_buff *skb, __wsum res)
        return csum_fold(partial);
 }

+static inline __wsum lco_csum(struct sk_buff *skb)
+{
+       unsigned char *csum_start = skb_checksum_start(skb);
+       unsigned char *l4_hdr = skb_transport_header(skb);
+       __wsum partial;
+
+       partial = ~csum_unfold(*(__force __sum16 *)(csum_start +
+                                                   skb->csum_offset));
+       return csum_partial(l4_hdr, csum_start - l4_hdr, partial);
+}
+
 static inline bool skb_is_gso(const struct sk_buff *skb)
 {
        return skb_shinfo(skb)->gso_size;
