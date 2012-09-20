From: Patrick McHardy <kaber@trash.net>
Subject: Re: Oops with latest (netfilter) nf-next tree, when unloading
 iptable_nat
Date: Thu, 20 Sep 2012 08:57:04 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1209200855500.8409@stinky-local.trash.net>
References: <1347357081.3928.32.camel@localhost>  <20120912213627.GJ14750@breakpoint.cc>
 <20120914120750.GA5764@1984>  <Pine.GSO.4.63.1209141511020.11622@stinky-local.trash.net>
 <1348058791.2761.94.camel@localhost>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-559023410-1804928587-1348124224=:8409"
Cc: Pablo Neira Ayuso <pablo@gnumonks.org>,
	Florian Westphal <fw@strlen.de>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, yongjun_wei@trendmicro.com.cn
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1348058791.2761.94.camel@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---559023410-1804928587-1348124224=:8409
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed

On Wed, 19 Sep 2012, Jesper Dangaard Brouer wrote:

> On Fri, 2012-09-14 at 15:15 +0200, Patrick McHardy wrote:
>> On Fri, 14 Sep 2012, Pablo Neira Ayuso wrote:
>>
> [...cut...]
>>>> Patrick, any other idea?
>>>
> [...cut...]
>>>>
>>> We can add nf_nat_iterate_cleanup that can iterate over the NAT
>>> hashtable to replace current usage of nf_ct_iterate_cleanup.
>>
>> Lets just bail out when IPS_SRC_NAT_DONE is not set, that should also fix
>> it. Could you try this patch please?
>
> On Fri, 2012-09-14 at 15:15 +0200, Patrick McHardy wrote:
> diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
>> index 29d4452..8b5d220 100644
>> --- a/net/netfilter/nf_nat_core.c
>> +++ b/net/netfilter/nf_nat_core.c
>> @@ -481,6 +481,8 @@ static int nf_nat_proto_clean(struct nf_conn *i,
> void *data)
>>
>>         if (!nat)
>>                 return 0;
>> +       if (!(i->status & IPS_SRC_NAT_DONE))
>> +               return 0;
>>         if ((clean->l3proto && nf_ct_l3num(i) != clean->l3proto) ||
>>             (clean->l4proto && nf_ct_protonum(i) != clean->l4proto))
>>                 return 0;
>>
>
> No it does not work :-(

Ok I think I understand the problem now, we're invoking the NAT cleanup
callback twice with clean->hash = true, once for each direction of the
conntrack.

Does this patch fix the problem?
---559023410-1804928587-1348124224=:8409
Content-Type: TEXT/PLAIN; charset=US-ASCII; name=nat-oops.diff
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.GSO.4.63.1209200857040.8409@stinky-local.trash.net>
Content-Description: 
Content-Disposition: attachment; filename=nat-oops.diff

Y29tbWl0IDZjNDZhM2JmYjI3NzZjYTA5ODU2NWRhZjdlODcyYTMyODNkMTRl
MGQNCkF1dGhvcjogUGF0cmljayBNY0hhcmR5IDxrYWJlckB0cmFzaC5uZXQ+
DQpEYXRlOiAgIFRodSBTZXAgMjAgMDg6NDM6MDIgMjAxMiArMDIwMA0KDQog
ICAgbmV0ZmlsdGVyOiBuZl9uYXQ6IGZpeCBvb3BzIHdoZW4gdW5sb2FkaW5n
IHByb3RvY29sIG1vZHVsZXMNCiAgICANCiAgICBXaGVuIHVubG9hZGluZyBh
IHByb3RvY29sIG1vZHVsZSBuZl9jdF9pdGVyYXRlX2NsZWFudXAoKSBpcyB1
c2VkIHRvDQogICAgcmVtb3ZlIGFsbCBjb25udHJhY2tzIHVzaW5nIHRoZSBw
cm90b2NvbCBmcm9tIHRoZSBieXNvdXJjZSBoYXNoIGFuZA0KICAgIGNsZWFu
IHRoZWlyIE5BVCBzZWN0aW9ucy4gU2luY2UgdGhlIGNvbm50cmFjayBpc24n
dCBhY3R1YWxseSBraWxsZWQsDQogICAgdGhlIE5BVCBjYWxsYmFjayBpcyBp
bnZva2VkIHR3aWNlLCBvbmNlIGZvciBlYWNoIGRpcmVjdGlvbiwgd2hpY2gN
CiAgICBjYXVzZXMgYW4gb29wcyB3aGVuIHRyeWluZyB0byBkZWxldGUgaXQg
ZnJvbSB0aGUgYnlzb3VyY2UgaGFzaCBmb3INCiAgICB0aGUgc2Vjb25kIHRp
bWUuDQogICAgDQogICAgVGhlIHNhbWUgb29wcyBjYW4gYWxzbyBoYXBwZW4g
d2hlbiByZW1vdmluZyBib3RoIGFuIEwzIGFuZCBMNCBwcm90b2NvbA0KICAg
IHNpbmNlIHRoZSBjbGVhbnVwIGZ1bmN0aW9uIGRvZXNuJ3QgY2hlY2sgd2hl
dGhlciB0aGUgY29ubnRyYWNrIGhhcw0KICAgIGFscmVhZHkgYmVlbiBjbGVh
bmVkIHVwLg0KICAgIA0KICAgIFBpZDogNDA1MiwgY29tbTogbW9kcHJvYmUg
Tm90IHRhaW50ZWQgMy42LjAtcmMzLXRlc3QtbmF0LXVubG9hZC1maXgrICMz
MiBSZWQgSGF0IEtWTQ0KICAgIFJJUDogMDAxMDpbPGZmZmZmZmZmYTAwMmMz
MDM+XSAgWzxmZmZmZmZmZmEwMDJjMzAzPl0gbmZfbmF0X3Byb3RvX2NsZWFu
KzB4NzMvMHhkMCBbbmZfbmF0XQ0KICAgIFJTUDogMDAxODpmZmZmODgwMDc4
MDhmZTE4ICBFRkxBR1M6IDAwMDEwMjQ2DQogICAgUkFYOiAwMDAwMDAwMDAw
MDAwMDAwIFJCWDogZmZmZjg4MDA3Mjg1NTBjMCBSQ1g6IGZmZmY4ODAwNzU2
Mjg4YjANCiAgICBSRFg6IGRlYWQwMDAwMDAyMDAyMDAgUlNJOiBmZmZmODgw
MDc4MDhmZTg4IFJESTogZmZmZmZmZmZhMDAyZjIwOA0KICAgIFJCUDogZmZm
Zjg4MDA3ODA4ZmUyOCBSMDg6IGZmZmY4ODAwNzgwOGUwMDAgUjA5OiAwMDAw
MDAwMDAwMDAwMDAwDQogICAgUjEwOiBkZWFkMDAwMDAwMjAwMjAwIFIxMTog
ZGVhZDAwMDAwMDEwMDEwMCBSMTI6IGZmZmZmZmZmODFjNmRjMDANCiAgICBS
MTM6IGZmZmY4ODAwNzg3NTgyYjggUjE0OiBmZmZmODgwMDc4NzU4Mjc4IFIx
NTogZmZmZjg4MDA3ODA4ZmU4OA0KICAgIEZTOiAgMDAwMDdmNTE1OTg1ZDcw
MCgwMDAwKSBHUzpmZmZmODgwMDdjZDAwMDAwKDAwMDApIGtubEdTOjAwMDAw
MDAwMDAwMDAwMDANCiAgICBDUzogIDAwMTAgRFM6IDAwMDAgRVM6IDAwMDAg
Q1IwOiAwMDAwMDAwMDgwMDUwMDNiDQogICAgQ1IyOiAwMDAwN2Y1MTU5ODZh
MDAwIENSMzogMDAwMDAwMDA3ODY3YTAwMCBDUjQ6IDAwMDAwMDAwMDAwMDA2
ZTANCiAgICBEUjA6IDAwMDAwMDAwMDAwMDAwMDAgRFIxOiAwMDAwMDAwMDAw
MDAwMDAwIERSMjogMDAwMDAwMDAwMDAwMDAwMA0KICAgIERSMzogMDAwMDAw
MDAwMDAwMDAwMCBEUjY6IDAwMDAwMDAwZmZmZjBmZjAgRFI3OiAwMDAwMDAw
MDAwMDAwNDAwDQogICAgUHJvY2VzcyBtb2Rwcm9iZSAocGlkOiA0MDUyLCB0
aHJlYWRpbmZvIGZmZmY4ODAwNzgwOGUwMDAsIHRhc2sgZmZmZjg4MDA3NTYy
ODhiMCkNCiAgICBTdGFjazoNCiAgICAgZmZmZjg4MDA3ODA4ZmU2OCBmZmZm
ZmZmZmEwMDJjMjkwIGZmZmY4ODAwNzgwOGZlNzggZmZmZmZmZmY4MTU2MTRl
Mw0KICAgICBmZmZmZmZmZjAwMDAwMDAwIDAwMDAwYWViMDAwMDAyNDYgZmZm
Zjg4MDA3ODA4ZmU2OCBmZmZmZmZmZjgxYzZkYzAwDQogICAgIGZmZmY4ODAw
NzgwOGZlODggZmZmZmZmZmZhMDAzNThhMCAwMDAwMDAwMDAwMDAwMDAwIDAw
MDAwMDAwMDA0MGY1YjANCiAgICBDYWxsIFRyYWNlOg0KICAgICBbPGZmZmZm
ZmZmYTAwMmMyOTA+XSA/IG5mX25hdF9uZXRfZXhpdCsweDUwLzB4NTAgW25m
X25hdF0NCiAgICAgWzxmZmZmZmZmZjgxNTYxNGUzPl0gbmZfY3RfaXRlcmF0
ZV9jbGVhbnVwKzB4YzMvMHgxNzANCiAgICAgWzxmZmZmZmZmZmEwMDJjNTVh
Pl0gbmZfbmF0X2wzcHJvdG9fdW5yZWdpc3RlcisweDhhLzB4MTAwIFtuZl9u
YXRdDQogICAgIFs8ZmZmZmZmZmY4MTJhMDMwMz5dID8gY29tcGF0X3ByZXBh
cmVfdGltZW91dCsweDEzLzB4YjANCiAgICAgWzxmZmZmZmZmZmEwMDM1ODQ4
Pl0gbmZfbmF0X2wzcHJvdG9faXB2NF9leGl0KzB4MTAvMHgyMyBbbmZfbmF0
X2lwdjRdDQogICAgIC4uLg0KICAgIA0KICAgIFRvIGZpeCB0aGlzLA0KICAg
IA0KICAgIC0gY2hlY2sgd2hldGhlciB0aGUgY29ubnRyYWNrIGhhcyBhbHJl
YWR5IGJlZW4gY2xlYW5lZCB1cCBpbg0KICAgICAgbmZfbmF0X3Byb3RvX2Ns
ZWFuDQogICAgDQogICAgLSBjaGFuZ2UgbmZfY3RfaXRlcmF0ZV9jbGVhbnVw
KCkgdG8gb25seSBpbnZva2UgdGhlIGNhbGxiYWNrIGZ1bmN0aW9uDQogICAg
ICBvbmNlIGZvciBlYWNoIGNvbm50cmFjayAoSVBfQ1RfRElSX09SSUdJTkFM
KS4NCiAgICANCiAgICBUaGUgc2Vjb25kIGNoYW5nZSBkb2Vzbid0IGFmZmVj
dCBvdGhlciBjYWxsZXJzIHNpbmNlIHdoZW4gY29ubnRyYWNrcyBhcmUNCiAg
ICBhY3R1YWxseSBraWxsZWQsIGJvdGggZGlyZWN0aW9ucyBhcmUgcmVtb3Zl
ZCBmcm9tIHRoZSBoYXNoIGltbWVkaWF0ZWx5DQogICAgYW5kIHRoZSBjYWxs
YmFjayBpcyBhbHJlYWR5IG9ubHkgaW52b2tlZCBvbmNlLiBJZiBpdCBpcyBu
b3Qga2lsbGVkLCB0aGUNCiAgICBzZWNvbmQgY2FsbGJhY2sgaW52b2NhdGlv
biB3aWxsIGFsd2F5cyByZXR1cm4gdGhlIHNhbWUgZGVjaXNpb24gbm90IHRv
DQogICAga2lsbCBpdC4NCiAgICANCiAgICBSZXBvcnRlZC1ieTogSmVzcGVy
IERhbmdhYXJkIEJyb3VlciA8YnJvdWVyQHJlZGhhdC5jb20+DQogICAgU2ln
bmVkLW9mZi1ieTogUGF0cmljayBNY0hhcmR5IDxrYWJlckB0cmFzaC5uZXQ+
DQoNCmRpZmYgLS1naXQgYS9uZXQvbmV0ZmlsdGVyL25mX2Nvbm50cmFja19j
b3JlLmMgYi9uZXQvbmV0ZmlsdGVyL25mX2Nvbm50cmFja19jb3JlLmMNCmlu
ZGV4IGRjYjI3OTEuLjBmMjQxYmUgMTAwNjQ0DQotLS0gYS9uZXQvbmV0Zmls
dGVyL25mX2Nvbm50cmFja19jb3JlLmMNCisrKyBiL25ldC9uZXRmaWx0ZXIv
bmZfY29ubnRyYWNrX2NvcmUuYw0KQEAgLTEyMjQsNiArMTIyNCw4IEBAIGdl
dF9uZXh0X2NvcnBzZShzdHJ1Y3QgbmV0ICpuZXQsIGludCAoKml0ZXIpKHN0
cnVjdCBuZl9jb25uICppLCB2b2lkICpkYXRhKSwNCiAJc3Bpbl9sb2NrX2Jo
KCZuZl9jb25udHJhY2tfbG9jayk7DQogCWZvciAoOyAqYnVja2V0IDwgbmV0
LT5jdC5odGFibGVfc2l6ZTsgKCpidWNrZXQpKyspIHsNCiAJCWhsaXN0X251
bGxzX2Zvcl9lYWNoX2VudHJ5KGgsIG4sICZuZXQtPmN0Lmhhc2hbKmJ1Y2tl
dF0sIGhubm9kZSkgew0KKwkJCWlmIChORl9DVF9ESVJFQ1RJT04oaCkgIT0g
SVBfQ1RfRElSX09SSUdJTkFMKQ0KKwkJCQljb250aW51ZTsNCiAJCQljdCA9
IG5mX2N0X3R1cGxlaGFzaF90b19jdHJhY2soaCk7DQogCQkJaWYgKGl0ZXIo
Y3QsIGRhdGEpKQ0KIAkJCQlnb3RvIGZvdW5kOw0KZGlmZiAtLWdpdCBhL25l
dC9uZXRmaWx0ZXIvbmZfbmF0X2NvcmUuYyBiL25ldC9uZXRmaWx0ZXIvbmZf
bmF0X2NvcmUuYw0KaW5kZXggMTgxNmFkMy4uNjVjZjY5NCAxMDA2NDQNCi0t
LSBhL25ldC9uZXRmaWx0ZXIvbmZfbmF0X2NvcmUuYw0KKysrIGIvbmV0L25l
dGZpbHRlci9uZl9uYXRfY29yZS5jDQpAQCAtNDgxLDYgKzQ4MSw4IEBAIHN0
YXRpYyBpbnQgbmZfbmF0X3Byb3RvX2NsZWFuKHN0cnVjdCBuZl9jb25uICpp
LCB2b2lkICpkYXRhKQ0KIA0KIAlpZiAoIW5hdCkNCiAJCXJldHVybiAwOw0K
KwlpZiAoIShpLT5zdGF0dXMgJiBJUFNfU1JDX05BVF9ET05FKSkNCisJCXJl
dHVybiAwOw0KIAlpZiAoKGNsZWFuLT5sM3Byb3RvICYmIG5mX2N0X2wzbnVt
KGkpICE9IGNsZWFuLT5sM3Byb3RvKSB8fA0KIAkgICAgKGNsZWFuLT5sNHBy
b3RvICYmIG5mX2N0X3Byb3RvbnVtKGkpICE9IGNsZWFuLT5sNHByb3RvKSkN
CiAJCXJldHVybiAwOw0K

---559023410-1804928587-1348124224=:8409--
