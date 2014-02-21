From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: linux 3.13: problems with isatap tunnel device and UFO
Date: Thu, 20 Feb 2014 16:43:41 -0800
Message-ID: <CAM_iQpW0ai2NMyVV1FGpDn5qKDUxYoqsXZ-GutfccQp92SyKwQ@mail.gmail.com>
References: <1682505.dP4nT04FC9@h2o.as.studentenwerk.mhn.de>
	<1581659.JtJ1UQaXJr@h2o.as.studentenwerk.mhn.de>
	<20140211024403.GE11150@order.stressinduktion.org>
	<5911515.kv7YDRiZP1@h2o.as.studentenwerk.mhn.de>
	<20140217160916.GE22833@order.stressinduktion.org>
	<20140220024418.GG1179@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=089e0116059cd9c9e204f2dfe940
To: Wolfgang Walter <linux@stwm.de>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:57909 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755393AbaBUAnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 19:43:42 -0500
Received: by mail-oa0-f42.google.com with SMTP id j17so956745oag.29
        for <netdev@vger.kernel.org>; Thu, 20 Feb 2014 16:43:41 -0800 (PST)
In-Reply-To: <20140220024418.GG1179@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--089e0116059cd9c9e204f2dfe940
Content-Type: text/plain; charset=UTF-8

On Wed, Feb 19, 2014 at 6:44 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Mon, Feb 17, 2014 at 05:09:16PM +0100, Hannes Frederic Sowa wrote:
>> [+Cc Cong Wang]
>>
>> Hi Cong!
>>
>> In commit d949d826c09fb ("ipv6: Add generic UDP Tunnel segmentation") you
>> patched ip6_offload.c:
>>
>> @@ -126,7 +128,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
>>                 ipv6h = ipv6_hdr(skb);
>>                 ipv6h->payload_len = htons(skb->len - skb->mac_len -
>>                                            sizeof(*ipv6h));
>> -               if (proto == IPPROTO_UDP) {
>> +               if (!tunnel && proto == IPPROTO_UDP) {
>>                         unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
>>                         fptr = (struct frag_hdr *)(skb_network_header(skb) +
>>                                 unfrag_ip6hlen);
>>
>>
>> I wonder about the !tunnel exception. This now seems to be a problem in sit
>> ufo output path, where we don't update fragmentation offsets any more thus
>> generating invalid frames.
>>
>> I am not too firm with segmentation in case of tunnels but don't we need to
>> always update the fragmentation offset no matter what, if upper gso callback
>> produced more segments?
>
> Not perfect nor clean (well, I don't know).
>
> The idea is to have the segmentation at the first guessed tunnel
> header cut. I don't know how to deal with stacked tunnels yet, I guess
> we need to have a bit more state in the skb. Just to maybe keep the discussion
> going...

Does the following patch help?

--089e0116059cd9c9e204f2dfe940
Content-Type: text/plain; charset=US-ASCII; name="tmp.diff"
Content-Disposition: attachment; filename="tmp.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hrwqjiy50

ZGlmZiAtLWdpdCBhL25ldC9pcHY2L2lwNl9vZmZsb2FkLmMgYi9uZXQvaXB2Ni9pcDZfb2ZmbG9h
ZC5jCmluZGV4IDFlODY4M2IuLjUxNmI4ODkgMTAwNjQ0Ci0tLSBhL25ldC9pcHY2L2lwNl9vZmZs
b2FkLmMKKysrIGIvbmV0L2lwdjYvaXA2X29mZmxvYWQuYwpAQCAtODksNyArODksNyBAQCBzdGF0
aWMgc3RydWN0IHNrX2J1ZmYgKmlwdjZfZ3NvX3NlZ21lbnQoc3RydWN0IHNrX2J1ZmYgKnNrYiwK
IAl1bnNpZ25lZCBpbnQgdW5mcmFnX2lwNmhsZW47CiAJdTggKnByZXZoZHI7CiAJaW50IG9mZnNl
dCA9IDA7Ci0JYm9vbCB0dW5uZWw7CisJYm9vbCB1ZHBmcmFnLCBlbmNhcDsKIAlpbnQgbmhvZmY7
CiAKIAlpZiAodW5saWtlbHkoc2tiX3NoaW5mbyhza2IpLT5nc29fdHlwZSAmCkBAIC0xMTAsOCAr
MTEwLDggQEAgc3RhdGljIHN0cnVjdCBza19idWZmICppcHY2X2dzb19zZWdtZW50KHN0cnVjdCBz
a19idWZmICpza2IsCiAJaWYgKHVubGlrZWx5KCFwc2tiX21heV9wdWxsKHNrYiwgc2l6ZW9mKCpp
cHY2aCkpKSkKIAkJZ290byBvdXQ7CiAKLQl0dW5uZWwgPSBTS0JfR1NPX0NCKHNrYiktPmVuY2Fw
X2xldmVsID4gMDsKLQlpZiAodHVubmVsKQorCWVuY2FwID0gU0tCX0dTT19DQihza2IpLT5lbmNh
cF9sZXZlbCA+IDA7CisJaWYgKGVuY2FwKQogCQlmZWF0dXJlcyA9IHNrYi0+ZGV2LT5od19lbmNf
ZmVhdHVyZXMgJiBuZXRpZl9za2JfZmVhdHVyZXMoc2tiKTsKIAlTS0JfR1NPX0NCKHNrYiktPmVu
Y2FwX2xldmVsICs9IHNpemVvZigqaXB2NmgpOwogCkBAIC0xMzAsMTYgKzEzMCwxNyBAQCBzdGF0
aWMgc3RydWN0IHNrX2J1ZmYgKmlwdjZfZ3NvX3NlZ21lbnQoc3RydWN0IHNrX2J1ZmYgKnNrYiwK
IAlpZiAoSVNfRVJSKHNlZ3MpKQogCQlnb3RvIG91dDsKIAorCXVkcGZyYWcgPSAhIXNrYi0+ZW5j
YXBzdWxhdGlvbiAmJiBwcm90byA9PSBJUFBST1RPX1VEUDsKIAlmb3IgKHNrYiA9IHNlZ3M7IHNr
Yjsgc2tiID0gc2tiLT5uZXh0KSB7CiAJCWlwdjZoID0gKHN0cnVjdCBpcHY2aGRyICopKHNrYl9t
YWNfaGVhZGVyKHNrYikgKyBuaG9mZik7CiAJCWlwdjZoLT5wYXlsb2FkX2xlbiA9IGh0b25zKHNr
Yi0+bGVuIC0gbmhvZmYgLSBzaXplb2YoKmlwdjZoKSk7Ci0JCWlmICh0dW5uZWwpIHsKKwkJaWYg
KGVuY2FwKSB7CiAJCQlza2JfcmVzZXRfaW5uZXJfaGVhZGVycyhza2IpOwogCQkJc2tiLT5lbmNh
cHN1bGF0aW9uID0gMTsKIAkJfQogCQlza2ItPm5ldHdvcmtfaGVhZGVyID0gKHU4ICopaXB2Nmgg
LSBza2ItPmhlYWQ7CiAKLQkJaWYgKCF0dW5uZWwgJiYgcHJvdG8gPT0gSVBQUk9UT19VRFApIHsK
KwkJaWYgKHVkcGZyYWcpIHsKIAkJCXVuZnJhZ19pcDZobGVuID0gaXA2X2ZpbmRfMXN0ZnJhZ29w
dChza2IsICZwcmV2aGRyKTsKIAkJCWZwdHIgPSAoc3RydWN0IGZyYWdfaGRyICopKCh1OCAqKWlw
djZoICsgdW5mcmFnX2lwNmhsZW4pOwogCQkJZnB0ci0+ZnJhZ19vZmYgPSBodG9ucyhvZmZzZXQp
Owo=
--089e0116059cd9c9e204f2dfe940--
