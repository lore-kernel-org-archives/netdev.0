From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] cls_u32: use skb_copy_bits() to dereference data safely
Date: Wed, 2 Jun 2010 01:47:00 +0800
Message-ID: <AANLkTilkweiJPmQOUv78lKL9ohZo1StzlJcBw0johYi0@mail.gmail.com>
References: <1275272665-19047-1-git-send-email-xiaosuo@gmail.com>
	<1275395667.3587.38.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f185.google.com ([209.85.222.185]:62431 "EHLO
	mail-pz0-f185.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756735Ab0FARrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 13:47:21 -0400
Received: by pzk15 with SMTP id 15so1633247pzk.15
        for <netdev@vger.kernel.org>; Tue, 01 Jun 2010 10:47:20 -0700 (PDT)
In-Reply-To: <1275395667.3587.38.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 1, 2010 at 8:34 PM, jamal <hadi@cyberus.ca> wrote:
> Hi Changli,
>
> On Mon, 2010-05-31 at 10:24 +0800, Changli Gao wrote:
>> use skb_copy_bits() to dereference data safely
>>
>> the original skb->data dereference isn't safe, as there isn't any skb->len or
>> skb_is_nonlinear() check.
>
> I dont see any safety issue in current code in this respect. Do you have
> a specific scenario where this would be unsafe? We inspect in 32 bit
> chunks walking the packet data and stop when there is no more packet
> data.

I added the following debug code into cls_u32.c

                for (i = n->sel.nkeys; i>0; i--, key++) {
+                       int off;
+
+                       off = key->off+(off2&key->offmask) + (ptr - skb->data);
+                       if (off + 4 > skb->len)
+                               printk("skb->len: %d, off: %d\n",
skb->len, off);

                        if
((*(__be32*)(ptr+key->off+(off2&key->offmask))^key->val)&key->mask) {
                                n = n->next;
@@ -179,8 +186,13 @@ check_terminal:

                ht = n->ht_down;
                sel = 0;
-               if (ht->divisor)
+               if (ht->divisor) {
+                       int off = ptr - skb->data + n->sel.hoff;
+                       if (off + 4 > skb->len)
+                               printk("skb->len: %d, off: %d\n", skb->len,
+                                       off);
                        sel =
ht->divisor&u32_hash_fold(*(__be32*)(ptr+n->sel.hoff),
&n->sel,n->fshift);
+               }

the tc filter command is:

tc filter add dev eth0 parent 8001:0 proto ip  u32 match u32
0x00000000 0x0000ffff at 40

Then I execute nc to connect to an UDP port:

localhost linux # nc -u 192.168.235.1 80

localhost linux #

just press enter.

I got these demsg:

[ 7525.330604] skb->len: 43, off: 54

we are trying to access the memory out of this skb.

>
>> skb_copy_bits() is used instead in this patch. And
>> when the skb isn't long enough, we terminate the function u32_classify()
>> immediately with -1.
>>
>
> That could be a very interesting optimization - but i see it as _very
> hard_ to do with current u32 given it has branching and different
> branches would have different lengths etc. You'd have to essentially do
> some math in user space as to what min length would suffice given
> a specified filter and pass that to the kernel.
>

It isn't an optimization, but an error exit. :)

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
