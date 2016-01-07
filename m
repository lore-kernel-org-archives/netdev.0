From: Konstantin Khlebnikov <koct9i@gmail.com>
Subject: Re: [BUG] skb corruption and kernel panic at forwarding with fragmentation
Date: Thu, 7 Jan 2016 14:38:21 +0300
Message-ID: <CALYGNiN-cGxcEwiN-aPH7W1Pa7bLc2UY5LY98mXr+yZK+q5_BA@mail.gmail.com>
References: <CALYGNiP-0MZ-FExV2HutTvE9U-QQtkKSoE--KN=JQE5STYsjAA@mail.gmail.com>
	<CAM_iQpWsx6w2tFvSAy66M69FNi5iSp===EFCrO=4EPjy7y3iSg@mail.gmail.com>
	<CALYGNiOjeh4Jfvmc6fJHaZYJyinXmZjTHXcacNreBXvzB1ajtQ@mail.gmail.com>
	<20160106210532.GE27290@indiana.gru.redhat.com>
	<20160106220334.GA23789@breakpoint.cc>
	<20160106234943.GB23789@breakpoint.cc>
	<CALYGNiObS1fuDNi7Q69BwoWmU8xOnndzy7Z-m35aphjQWUuEnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a113fb8446eb6ee0528bce852
Cc: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALYGNiObS1fuDNi7Q69BwoWmU8xOnndzy7Z-m35aphjQWUuEnQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a113fb8446eb6ee0528bce852
Content-Type: text/plain; charset=UTF-8

On Thu, Jan 7, 2016 at 2:00 PM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> On Thu, Jan 7, 2016 at 2:49 AM, Florian Westphal <fw@strlen.de> wrote:
>> Florian Westphal <fw@strlen.de> wrote:
>>> Thadeu Lima de Souza Cascardo <cascardo@redhat.com> wrote:
>>> > On Wed, Jan 06, 2016 at 11:11:41PM +0300, Konstantin Khlebnikov wrote:
>>
>> [ skb_gso_segment uses skb->cb[], causes oops if ip_fragment is invoked
>>   on segmented skbs ]
>>
>>> > I have hit this as well, this fixes it for me on an older kernel. Can you try it
>>> > on latest kernel?
>>>
>>> > diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
>>> > index d8a1745..f44bc91 100644
>>> > --- a/net/ipv4/ip_output.c
>>> > +++ b/net/ipv4/ip_output.c
>>> > @@ -216,6 +216,7 @@ static int ip_finish_output_gso(struct sk_buff *skb)
>>> >     netdev_features_t features;
>>> >     struct sk_buff *segs;
>>> >     int ret = 0;
>>> > +   struct inet_skb_parm ipcb;
>>> >
>>> >     if (skb_gso_network_seglen(skb) <= ip_skb_dst_mtu(skb))
>>> >             return ip_finish_output2(skb);
>>> > @@ -227,6 +228,10 @@ static int ip_finish_output_gso(struct sk_buff *skb)
>>> >      * 2) skb arrived via virtio-net, we thus get TSO/GSO skbs directly
>>> >      * from host network stack.
>>> >      */
>>> > +   /* We need to save IPCB here because skb_gso_segment will use
>>> > +    * SKB_GSO_CB.
>>> > +    */
>>> > +   ipcb = *IPCB(skb);
>>> >     features = netif_skb_features(skb);
>>> >     segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);
>>> >     if (IS_ERR_OR_NULL(segs)) {
>>> > @@ -241,6 +246,7 @@ static int ip_finish_output_gso(struct sk_buff *skb)
>>> >             int err;
>>> >
>>> >             segs->next = NULL;
>>> > +           *IPCB(segs) = ipcb;
>>> >             err = ip_fragment(segs, ip_finish_output2);
>>> >
>>> >             if (err && ret == 0)
>>>
>>> I'm worried that this doesn't solve all cases. f.e. xfrm may also
>>> call skb_gso_segment(), and it will call into ipv4/ipv6 netfilter
>>> postrouting + ipv4 output functions...
>>>
>>> nfqnl_enqueue_packet() is also affected.
>>
>> ... but it seems that those three are the only affected callers
>> of skb_gso_segment (tbf is ok since skb isn't owned by anyone,
>> ovs does save/restore already).
>>
>> I think this patch is the right way, we just need similar
>> save/restore in nfqnl_enqueue_packet and xfrm_output_gso().
>
> Which CB could be here? at this point skb isn't owned by netlink yet.
>
>>
>> The latter two can be used by either ipv4 or ipv6 so it might
>> be preferable to just save/restore sizeof(struct skb_gso_cb);
>> or a union of inet_skb_parm+inet6_skb_parm.
>
> Or just shift GSO CB and add couple checks like
> BUILD_BUG_ON(sizeof(SKB_GSO_CB(skb)->room) < sizeof(*IPCB(skb)));

Somethin like this (in attachment)

Also I've found strange thing: reason of expanding skb->cb from 40 to
48 bypes in 2006
3e3850e989c5d2eb1aab6f0fd9257759f0f4cbc6 was that struct inet6_skb_parm does
not fit. But it's is only 24 bytes. Does some arches add pad after
each _u16 field?

--001a113fb8446eb6ee0528bce852
Content-Type: application/octet-stream;
	name=net-preserve-lower-bytes-of-skb-cb-during-gso-segmentation
Content-Disposition: attachment;
	filename=net-preserve-lower-bytes-of-skb-cb-during-gso-segmentation
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ij46cdpa0

bmV0OiBwcmVzZXJ2ZSBsb3dlciBieXRlcyBvZiBza2IgQ0IgZHVyaW5nIEdTTyBzZWdtZW50YXRp
b24KCkZyb206IEtvbnN0YW50aW4gS2hsZWJuaWtvdiA8a29jdDlpQGdtYWlsLmNvbT4KClNrYl9n
c29fc2VnbWVudCgpIHVzZXMgc2tiIGNvbnRyb2wgYmxvY2sgZHVyaW5nIHNlZ21lbnRhdGlvbi4K
VGhpcyBwYXRjaCBhZGRzIDMyLWJ5dGVzIHJvb20gZm9yIHByZXZpb3VzIGNvbnRyb2wgYmxvY2sg
d2hpY2gKd2lsbCBiZSBjb3BpZWQgaW50byBhbGwgcmVzdWx0aW5nIHNlZ21lbnRzLgoKVGhpcyBw
YXRjaCBmaXhlcyBrZXJuZWwgY3Jhc2ggZHVyaW5nIGZyYWdtZW50aW5nIGZvcndhcmRlZCBwYWNr
ZXRzCmJlY2F1c2UgZnJhZ21lbnRhdGlvbiByZWxpZXMgb24gdmFsaWQgSVBDQiBzdGF0ZSBidXQg
R1NPIHNlZ21lbnRhdGlvbi4KQWxzbyBpdCByZW1vdmVzIGN1c3RvbSBzYXZlL3Jlc3RvcmUgaW4g
b3ZzIGNvZGUsIG5vdyB0aGlzIGlzIHJlZHVuZGFudC4KClNpZ25lZC1vZmYtYnk6IEtvbnN0YW50
aW4gS2hsZWJuaWtvdiA8a29jdDlpQGdtYWlsLmNvbT4KTGluazogaHR0cDovL2xrbWwua2VybmVs
Lm9yZy9yL0NBTFlHTmlQLTBNWi1GRXhWMkh1dFR2RTlVLVFRdGtLU29FLS1LTj1KUUU1U1RZc2pB
QUBtYWlsLmdtYWlsLmNvbQotLS0KIGluY2x1ZGUvbGludXgvc2tidWZmLmggICAgIHwgICAgMSAr
CiBuZXQvY29yZS9kZXYuYyAgICAgICAgICAgICB8ICAgIDIgKysKIG5ldC9pcHY0L2lwX291dHB1
dC5jICAgICAgIHwgICAgMSArCiBuZXQvb3BlbnZzd2l0Y2gvZGF0YXBhdGguYyB8ICAgIDQgKy0t
LQogbmV0L3hmcm0veGZybV9vdXRwdXQuYyAgICAgfCAgICAyICsrCiA1IGZpbGVzIGNoYW5nZWQs
IDcgaW5zZXJ0aW9ucygrKSwgMyBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9pbmNsdWRlL2xp
bnV4L3NrYnVmZi5oIGIvaW5jbHVkZS9saW51eC9za2J1ZmYuaAppbmRleCA0MzA3ZTIwYTRhNGEu
LmFlYmYxNTAxZGIyNSAxMDA2NDQKLS0tIGEvaW5jbHVkZS9saW51eC9za2J1ZmYuaAorKysgYi9p
bmNsdWRlL2xpbnV4L3NrYnVmZi5oCkBAIC0zMzE2LDYgKzMzMTYsNyBAQCBzdGF0aWMgaW5saW5l
IHN0cnVjdCBzZWNfcGF0aCAqc2tiX3NlY19wYXRoKHN0cnVjdCBza19idWZmICpza2IpCiAgKiBL
ZWVwcyB0cmFjayBvZiBsZXZlbCBvZiBlbmNhcHN1bGF0aW9uIG9mIG5ldHdvcmsgaGVhZGVycy4K
ICAqLwogc3RydWN0IHNrYl9nc29fY2IgeworCWNoYXIJcHJldl9jYlszMl07CiAJaW50CW1hY19v
ZmZzZXQ7CiAJaW50CWVuY2FwX2xldmVsOwogCV9fdTE2CWNzdW1fc3RhcnQ7CmRpZmYgLS1naXQg
YS9uZXQvY29yZS9kZXYuYyBiL25ldC9jb3JlL2Rldi5jCmluZGV4IGE0MmIyMzI4MDVhNS4uZTY0
ZWVmYTMxYTJkIDEwMDY0NAotLS0gYS9uZXQvY29yZS9kZXYuYworKysgYi9uZXQvY29yZS9kZXYu
YwpAQCAtMjQ3OSw2ICsyNDc5LDggQEAgc3RhdGljIGlubGluZSBib29sIHNrYl9uZWVkc19jaGVj
ayhzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBib29sIHR4X3BhdGgpCiAgKgogICoJSXQgbWF5IHJldHVy
biBOVUxMIGlmIHRoZSBza2IgcmVxdWlyZXMgbm8gc2VnbWVudGF0aW9uLiAgVGhpcyBpcwogICoJ
b25seSBwb3NzaWJsZSB3aGVuIEdTTyBpcyB1c2VkIGZvciB2ZXJpZnlpbmcgaGVhZGVyIGludGVn
cml0eS4KKyAqCisgKglTZWdtZW50YXRpb24gcHJlc2VydmVzIGxvd2VyIGJ5dGVzIG9mIG9yaWdp
bmFsIGNvbnRyb2wgYmxvY2suCiAgKi8KIHN0cnVjdCBza19idWZmICpfX3NrYl9nc29fc2VnbWVu
dChzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAogCQkJCSAgbmV0ZGV2X2ZlYXR1cmVzX3QgZmVhdHVyZXMs
IGJvb2wgdHhfcGF0aCkKZGlmZiAtLWdpdCBhL25ldC9pcHY0L2lwX291dHB1dC5jIGIvbmV0L2lw
djQvaXBfb3V0cHV0LmMKaW5kZXggYzY1YjkzYTdiNzExLi5iZDk0YmE0ZDk5MzcgMTAwNjQ0Ci0t
LSBhL25ldC9pcHY0L2lwX291dHB1dC5jCisrKyBiL25ldC9pcHY0L2lwX291dHB1dC5jCkBAIC0y
MzUsNiArMjM1LDcgQEAgc3RhdGljIGludCBpcF9maW5pc2hfb3V0cHV0X2dzbyhzdHJ1Y3Qgc29j
ayAqc2ssIHN0cnVjdCBza19idWZmICpza2IpCiAJICogZnJvbSBob3N0IG5ldHdvcmsgc3RhY2su
CiAJICovCiAJZmVhdHVyZXMgPSBuZXRpZl9za2JfZmVhdHVyZXMoc2tiKTsKKwlCVUlMRF9CVUdf
T04oc2l6ZW9mKFNLQl9HU09fQ0Ioc2tiKS0+cHJldl9jYikgPCBzaXplb2YoKklQQ0Ioc2tiKSkp
OwogCXNlZ3MgPSBza2JfZ3NvX3NlZ21lbnQoc2tiLCBmZWF0dXJlcyAmIH5ORVRJRl9GX0dTT19N
QVNLKTsKIAlpZiAoSVNfRVJSX09SX05VTEwoc2VncykpIHsKIAkJa2ZyZWVfc2tiKHNrYik7CmRp
ZmYgLS1naXQgYS9uZXQvb3BlbnZzd2l0Y2gvZGF0YXBhdGguYyBiL25ldC9vcGVudnN3aXRjaC9k
YXRhcGF0aC5jCmluZGV4IDI3ZTE0OTYyYjUwNC4uNWQwNDllZmRiMDE1IDEwMDY0NAotLS0gYS9u
ZXQvb3BlbnZzd2l0Y2gvZGF0YXBhdGguYworKysgYi9uZXQvb3BlbnZzd2l0Y2gvZGF0YXBhdGgu
YwpAQCAtMzM3LDEyICszMzcsMTAgQEAgc3RhdGljIGludCBxdWV1ZV9nc29fcGFja2V0cyhzdHJ1
Y3QgZGF0YXBhdGggKmRwLCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAogCXVuc2lnbmVkIHNob3J0IGdz
b190eXBlID0gc2tiX3NoaW5mbyhza2IpLT5nc29fdHlwZTsKIAlzdHJ1Y3Qgc3dfZmxvd19rZXkg
bGF0ZXJfa2V5OwogCXN0cnVjdCBza19idWZmICpzZWdzLCAqbnNrYjsKLQlzdHJ1Y3Qgb3ZzX3Nr
Yl9jYiBvdnNfY2I7CiAJaW50IGVycjsKIAotCW92c19jYiA9ICpPVlNfQ0Ioc2tiKTsKKwlCVUlM
RF9CVUdfT04oc2l6ZW9mKFNLQl9HU09fQ0Ioc2tiKS0+cHJldl9jYikgPCBzaXplb2YoKk9WU19D
Qihza2IpKSk7CiAJc2VncyA9IF9fc2tiX2dzb19zZWdtZW50KHNrYiwgTkVUSUZfRl9TRywgZmFs
c2UpOwotCSpPVlNfQ0Ioc2tiKSA9IG92c19jYjsKIAlpZiAoSVNfRVJSKHNlZ3MpKQogCQlyZXR1
cm4gUFRSX0VSUihzZWdzKTsKIAlpZiAoc2VncyA9PSBOVUxMKQpkaWZmIC0tZ2l0IGEvbmV0L3hm
cm0veGZybV9vdXRwdXQuYyBiL25ldC94ZnJtL3hmcm1fb3V0cHV0LmMKaW5kZXggZmJjZWRiZTMz
MTkwLi4wMDQwMWRjMWMwZTYgMTAwNjQ0Ci0tLSBhL25ldC94ZnJtL3hmcm1fb3V0cHV0LmMKKysr
IGIvbmV0L3hmcm0veGZybV9vdXRwdXQuYwpAQCAtMTUzLDYgKzE1Myw4IEBAIHN0YXRpYyBpbnQg
eGZybV9vdXRwdXRfZ3NvKHN0cnVjdCBzb2NrICpzaywgc3RydWN0IHNrX2J1ZmYgKnNrYikKIHsK
IAlzdHJ1Y3Qgc2tfYnVmZiAqc2VnczsKIAorCUJVSUxEX0JVR19PTihzaXplb2YoU0tCX0dTT19D
Qihza2IpLT5wcmV2X2NiKSA8IHNpemVvZigqSVBDQihza2IpKSk7CisJQlVJTERfQlVHX09OKHNp
emVvZihTS0JfR1NPX0NCKHNrYiktPnByZXZfY2IpIDwgc2l6ZW9mKCpJUDZDQihza2IpKSk7CiAJ
c2VncyA9IHNrYl9nc29fc2VnbWVudChza2IsIDApOwogCWtmcmVlX3NrYihza2IpOwogCWlmIChJ
U19FUlIoc2VncykpCg==
--001a113fb8446eb6ee0528bce852--
