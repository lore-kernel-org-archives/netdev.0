From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 4/4] [SK_BUFF]: Use offsets for skb->{mac,network,transport}_header on 64bit architectures
Date: Fri, 16 Mar 2007 17:54:32 -0300
Message-ID: <39e6f6c70703161354h71e929cfr553e441e9f6e61a6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_84481_4228795.1174078472345"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:2086 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965919AbXCPUyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 16:54:35 -0400
Received: by nf-out-0910.google.com with SMTP id o25so397294nfa
        for <netdev@vger.kernel.org>; Fri, 16 Mar 2007 13:54:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_84481_4228795.1174078472345
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

With this we save 8 bytes per network packet, leaving a 4 bytes hole to be used
in further shrinking work, likely with the offsetization of other pointers,
such as ->{data,tail,end}, at the cost of adds, that were minimized by the
usual practice of setting skb->{mac,nh,n}.raw to a local variable that is then
accessed multiple times in each function, it also is not more expensive than
before with regards to most of the handling of such headers, like setting one
of these headers to another (transport to network, etc), or subtracting, adding
to/from it, comparing them, etc.

Now we have this layout for sk_buff on a x86_64 machine:

[acme@mica net-2.6.22]$ pahole vmlinux sk_buff
struct sk_buff {
	struct sk_buff *       next;             /*   0   8 */
	struct sk_buff *       prev;             /*   8   8 */
	struct rb_node         rb;               /*  16  24 */
	struct sock *          sk;               /*  40   8 */
	ktime_t                tstamp;           /*  48   8 */
	struct net_device *    dev;              /*  56   8 */
	/* --- cacheline 1 boundary (64 bytes) --- */
	struct net_device *    input_dev;        /*  64   8 */
	sk_buff_data_t         transport_header; /*  72   4 */
	sk_buff_data_t         network_header;   /*  76   4 */
	sk_buff_data_t         mac_header;       /*  80   4 */

	/* XXX 4 bytes hole, try to pack */

	struct dst_entry *     dst;              /*  88   8 */
	struct sec_path *      sp;               /*  96   8 */
	char                   cb[48];           /* 104  48 */
	/* cacheline 2 boundary (128 bytes) was 24 bytes ago*/
	unsigned int           len;              /* 152   4 */
	unsigned int           data_len;         /* 156   4 */
	unsigned int           mac_len;          /* 160   4 */
	union {
		__wsum         csum;             /*       4 */
		__u32          csum_offset;      /*       4 */
	};                                       /* 164   4 */
	__u32                  priority;         /* 168   4 */
	__u8                   local_df:1;       /* 172   1 */
	__u8                   cloned:1;         /* 172   1 */
	__u8                   ip_summed:2;      /* 172   1 */
	__u8                   nohdr:1;          /* 172   1 */
	__u8                   nfctinfo:3;       /* 172   1 */
	__u8                   pkt_type:3;       /* 173   1 */
	__u8                   fclone:2;         /* 173   1 */
	__u8                   ipvs_property:1;  /* 173   1 */

	/* XXX 2 bits hole, try to pack */

	__be16                 protocol;         /* 174   2 */
	void    (*destructor)(struct sk_buff *); /* 176   8 */
	struct nf_conntrack *  nfct;             /* 184   8 */
	/* --- cacheline 3 boundary (192 bytes) --- */
	struct sk_buff *       nfct_reasm;       /* 192   8 */
	struct nf_bridge_info *nf_bridge;        /* 200   8 */
	__u16                  tc_index;         /* 208   2 */
	__u16                  tc_verd;          /* 210   2 */
	dma_cookie_t           dma_cookie;       /* 212   4 */
	__u32                  secmark;          /* 216   4 */
	__u32                  mark;             /* 220   4 */
	unsigned int           truesize;         /* 224   4 */
	atomic_t               users;            /* 228   4 */
	unsigned char *        head;             /* 232   8 */
	unsigned char *        data;             /* 240   8 */
	unsigned char *        tail;             /* 248   8 */
	/* --- cacheline 4 boundary (256 bytes) --- */
	unsigned char *        end;              /* 256   8 */
}; /* size: 264, cachelines: 5 */
   /* sum members: 260, holes: 1, sum holes: 4 */
   /* bit holes: 1, sum bit holes: 2 bits */
   /* last cacheline: 8 bytes */

On 32 bits nothing changes, and pointers continue to be used with the compiler
turning all this abstraction layer into dust. But there are some sk_buff
validation tricks that are now possible, humm... :-)

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/linux/skbuff.h     |  104 ++++++++++++++++++++++++++++++++++++--------
 net/ipv4/ipvs/ip_vs_xmit.c |    2 +-
 net/sctp/input.c           |    4 +-
 net/sctp/ipv6.c            |    2 +-
 4 files changed, 90 insertions(+), 22 deletions(-)

------=_Part_84481_4228795.1174078472345
Content-Type: text/x-patch;
	name=0004-SK_BUFF-Use-offsets-for-skb-mac-network-transpo.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ezd3yn7y
Content-Disposition: attachment; filename="0004-SK_BUFF-Use-offsets-for-skb-mac-network-transpo.patch"

RnJvbSAzMzY0YzFiNDUwYzQ3NzVhY2E4MGM0NGIwYzZhMDhkMmEyOWU0MzkyIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogRnJpLCAxNiBNYXIgMjAwNyAxNzo0MjoxMiAtMDMwMApTdWJqZWN0OiBbUEFU
Q0ggNC80XSBbU0tfQlVGRl06IFVzZSBvZmZzZXRzIGZvciBza2ItPnttYWMsbmV0d29yayx0cmFu
c3BvcnR9X2hlYWRlciBvbiA2NGJpdCBhcmNoaXRlY3R1cmVzCgpXaXRoIHRoaXMgd2Ugc2F2ZSA4
IGJ5dGVzIHBlciBuZXR3b3JrIHBhY2tldCwgbGVhdmluZyBhIDQgYnl0ZXMgaG9sZSB0byBiZSB1
c2VkCmluIGZ1cnRoZXIgc2hyaW5raW5nIHdvcmssIGxpa2VseSB3aXRoIHRoZSBvZmZzZXRpemF0
aW9uIG9mIG90aGVyIHBvaW50ZXJzLApzdWNoIGFzIC0+e2RhdGEsdGFpbCxlbmR9LCBhdCB0aGUg
Y29zdCBvZiBhZGRzLCB0aGF0IHdlcmUgbWluaW1pemVkIGJ5IHRoZQp1c3VhbCBwcmFjdGljZSBv
ZiBzZXR0aW5nIHNrYi0+e21hYyxuaCxufS5yYXcgdG8gYSBsb2NhbCB2YXJpYWJsZSB0aGF0IGlz
IHRoZW4KYWNjZXNzZWQgbXVsdGlwbGUgdGltZXMgaW4gZWFjaCBmdW5jdGlvbiwgaXQgYWxzbyBp
cyBub3QgbW9yZSBleHBlbnNpdmUgdGhhbgpiZWZvcmUgd2l0aCByZWdhcmRzIHRvIG1vc3Qgb2Yg
dGhlIGhhbmRsaW5nIG9mIHN1Y2ggaGVhZGVycywgbGlrZSBzZXR0aW5nIG9uZQpvZiB0aGVzZSBo
ZWFkZXJzIHRvIGFub3RoZXIgKHRyYW5zcG9ydCB0byBuZXR3b3JrLCBldGMpLCBvciBzdWJ0cmFj
dGluZywgYWRkaW5nCnRvL2Zyb20gaXQsIGNvbXBhcmluZyB0aGVtLCBldGMuCgpOb3cgd2UgaGF2
ZSB0aGlzIGxheW91dCBmb3Igc2tfYnVmZiBvbiBhIHg4Nl82NCBtYWNoaW5lOgoKW2FjbWVAbWlj
YSBuZXQtMi42LjIyXSQgcGFob2xlIHZtbGludXggc2tfYnVmZgpzdHJ1Y3Qgc2tfYnVmZiB7Cglz
dHJ1Y3Qgc2tfYnVmZiAqICAgICAgIG5leHQ7ICAgICAgICAgICAgIC8qICAgMCAgIDggKi8KCXN0
cnVjdCBza19idWZmICogICAgICAgcHJldjsgICAgICAgICAgICAgLyogICA4ICAgOCAqLwoJc3Ry
dWN0IHJiX25vZGUgICAgICAgICByYjsgICAgICAgICAgICAgICAvKiAgMTYgIDI0ICovCglzdHJ1
Y3Qgc29jayAqICAgICAgICAgIHNrOyAgICAgICAgICAgICAgIC8qICA0MCAgIDggKi8KCWt0aW1l
X3QgICAgICAgICAgICAgICAgdHN0YW1wOyAgICAgICAgICAgLyogIDQ4ICAgOCAqLwoJc3RydWN0
IG5ldF9kZXZpY2UgKiAgICBkZXY7ICAgICAgICAgICAgICAvKiAgNTYgICA4ICovCgkvKiAtLS0g
Y2FjaGVsaW5lIDEgYm91bmRhcnkgKDY0IGJ5dGVzKSAtLS0gKi8KCXN0cnVjdCBuZXRfZGV2aWNl
ICogICAgaW5wdXRfZGV2OyAgICAgICAgLyogIDY0ICAgOCAqLwoJc2tfYnVmZl9kYXRhX3QgICAg
ICAgICB0cmFuc3BvcnRfaGVhZGVyOyAvKiAgNzIgICA0ICovCglza19idWZmX2RhdGFfdCAgICAg
ICAgIG5ldHdvcmtfaGVhZGVyOyAgIC8qICA3NiAgIDQgKi8KCXNrX2J1ZmZfZGF0YV90ICAgICAg
ICAgbWFjX2hlYWRlcjsgICAgICAgLyogIDgwICAgNCAqLwoKCS8qIFhYWCA0IGJ5dGVzIGhvbGUs
IHRyeSB0byBwYWNrICovCgoJc3RydWN0IGRzdF9lbnRyeSAqICAgICBkc3Q7ICAgICAgICAgICAg
ICAvKiAgODggICA4ICovCglzdHJ1Y3Qgc2VjX3BhdGggKiAgICAgIHNwOyAgICAgICAgICAgICAg
IC8qICA5NiAgIDggKi8KCWNoYXIgICAgICAgICAgICAgICAgICAgY2JbNDhdOyAgICAgICAgICAg
LyogMTA0ICA0OCAqLwoJLyogY2FjaGVsaW5lIDIgYm91bmRhcnkgKDEyOCBieXRlcykgd2FzIDI0
IGJ5dGVzIGFnbyovCgl1bnNpZ25lZCBpbnQgICAgICAgICAgIGxlbjsgICAgICAgICAgICAgIC8q
IDE1MiAgIDQgKi8KCXVuc2lnbmVkIGludCAgICAgICAgICAgZGF0YV9sZW47ICAgICAgICAgLyog
MTU2ICAgNCAqLwoJdW5zaWduZWQgaW50ICAgICAgICAgICBtYWNfbGVuOyAgICAgICAgICAvKiAx
NjAgICA0ICovCgl1bmlvbiB7CgkJX193c3VtICAgICAgICAgY3N1bTsgICAgICAgICAgICAgLyog
ICAgICAgNCAqLwoJCV9fdTMyICAgICAgICAgIGNzdW1fb2Zmc2V0OyAgICAgIC8qICAgICAgIDQg
Ki8KCX07ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgLyogMTY0ICAgNCAq
LwoJX191MzIgICAgICAgICAgICAgICAgICBwcmlvcml0eTsgICAgICAgICAvKiAxNjggICA0ICov
CglfX3U4ICAgICAgICAgICAgICAgICAgIGxvY2FsX2RmOjE7ICAgICAgIC8qIDE3MiAgIDEgKi8K
CV9fdTggICAgICAgICAgICAgICAgICAgY2xvbmVkOjE7ICAgICAgICAgLyogMTcyICAgMSAqLwoJ
X191OCAgICAgICAgICAgICAgICAgICBpcF9zdW1tZWQ6MjsgICAgICAvKiAxNzIgICAxICovCglf
X3U4ICAgICAgICAgICAgICAgICAgIG5vaGRyOjE7ICAgICAgICAgIC8qIDE3MiAgIDEgKi8KCV9f
dTggICAgICAgICAgICAgICAgICAgbmZjdGluZm86MzsgICAgICAgLyogMTcyICAgMSAqLwoJX191
OCAgICAgICAgICAgICAgICAgICBwa3RfdHlwZTozOyAgICAgICAvKiAxNzMgICAxICovCglfX3U4
ICAgICAgICAgICAgICAgICAgIGZjbG9uZToyOyAgICAgICAgIC8qIDE3MyAgIDEgKi8KCV9fdTgg
ICAgICAgICAgICAgICAgICAgaXB2c19wcm9wZXJ0eToxOyAgLyogMTczICAgMSAqLwoKCS8qIFhY
WCAyIGJpdHMgaG9sZSwgdHJ5IHRvIHBhY2sgKi8KCglfX2JlMTYgICAgICAgICAgICAgICAgIHBy
b3RvY29sOyAgICAgICAgIC8qIDE3NCAgIDIgKi8KCXZvaWQgICAgKCpkZXN0cnVjdG9yKShzdHJ1
Y3Qgc2tfYnVmZiAqKTsgLyogMTc2ICAgOCAqLwoJc3RydWN0IG5mX2Nvbm50cmFjayAqICBuZmN0
OyAgICAgICAgICAgICAvKiAxODQgICA4ICovCgkvKiAtLS0gY2FjaGVsaW5lIDMgYm91bmRhcnkg
KDE5MiBieXRlcykgLS0tICovCglzdHJ1Y3Qgc2tfYnVmZiAqICAgICAgIG5mY3RfcmVhc207ICAg
ICAgIC8qIDE5MiAgIDggKi8KCXN0cnVjdCBuZl9icmlkZ2VfaW5mbyAqbmZfYnJpZGdlOyAgICAg
ICAgLyogMjAwICAgOCAqLwoJX191MTYgICAgICAgICAgICAgICAgICB0Y19pbmRleDsgICAgICAg
ICAvKiAyMDggICAyICovCglfX3UxNiAgICAgICAgICAgICAgICAgIHRjX3ZlcmQ7ICAgICAgICAg
IC8qIDIxMCAgIDIgKi8KCWRtYV9jb29raWVfdCAgICAgICAgICAgZG1hX2Nvb2tpZTsgICAgICAg
LyogMjEyICAgNCAqLwoJX191MzIgICAgICAgICAgICAgICAgICBzZWNtYXJrOyAgICAgICAgICAv
KiAyMTYgICA0ICovCglfX3UzMiAgICAgICAgICAgICAgICAgIG1hcms7ICAgICAgICAgICAgIC8q
IDIyMCAgIDQgKi8KCXVuc2lnbmVkIGludCAgICAgICAgICAgdHJ1ZXNpemU7ICAgICAgICAgLyog
MjI0ICAgNCAqLwoJYXRvbWljX3QgICAgICAgICAgICAgICB1c2VyczsgICAgICAgICAgICAvKiAy
MjggICA0ICovCgl1bnNpZ25lZCBjaGFyICogICAgICAgIGhlYWQ7ICAgICAgICAgICAgIC8qIDIz
MiAgIDggKi8KCXVuc2lnbmVkIGNoYXIgKiAgICAgICAgZGF0YTsgICAgICAgICAgICAgLyogMjQw
ICAgOCAqLwoJdW5zaWduZWQgY2hhciAqICAgICAgICB0YWlsOyAgICAgICAgICAgICAvKiAyNDgg
ICA4ICovCgkvKiAtLS0gY2FjaGVsaW5lIDQgYm91bmRhcnkgKDI1NiBieXRlcykgLS0tICovCgl1
bnNpZ25lZCBjaGFyICogICAgICAgIGVuZDsgICAgICAgICAgICAgIC8qIDI1NiAgIDggKi8KfTsg
Lyogc2l6ZTogMjY0LCBjYWNoZWxpbmVzOiA1ICovCiAgIC8qIHN1bSBtZW1iZXJzOiAyNjAsIGhv
bGVzOiAxLCBzdW0gaG9sZXM6IDQgKi8KICAgLyogYml0IGhvbGVzOiAxLCBzdW0gYml0IGhvbGVz
OiAyIGJpdHMgKi8KICAgLyogbGFzdCBjYWNoZWxpbmU6IDggYnl0ZXMgKi8KCk9uIDMyIGJpdHMg
bm90aGluZyBjaGFuZ2VzLCBhbmQgcG9pbnRlcnMgY29udGludWUgdG8gYmUgdXNlZCB3aXRoIHRo
ZSBjb21waWxlcgp0dXJuaW5nIGFsbCB0aGlzIGFic3RyYWN0aW9uIGxheWVyIGludG8gZHVzdC4g
QnV0IHRoZXJlIGFyZSBzb21lIHNrX2J1ZmYKdmFsaWRhdGlvbiB0cmlja3MgdGhhdCBhcmUgbm93
IHBvc3NpYmxlLCBodW1tLi4uIDotKQoKU2lnbmVkLW9mZi1ieTogQXJuYWxkbyBDYXJ2YWxobyBk
ZSBNZWxvIDxhY21lQHJlZGhhdC5jb20+Ci0tLQogaW5jbHVkZS9saW51eC9za2J1ZmYuaCAgICAg
fCAgMTA0ICsrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKy0tLS0tLS0tCiBuZXQv
aXB2NC9pcHZzL2lwX3ZzX3htaXQuYyB8ICAgIDIgKy0KIG5ldC9zY3RwL2lucHV0LmMgICAgICAg
ICAgIHwgICAgNCArLQogbmV0L3NjdHAvaXB2Ni5jICAgICAgICAgICAgfCAgICAyICstCiA0IGZp
bGVzIGNoYW5nZWQsIDkwIGluc2VydGlvbnMoKyksIDIyIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdp
dCBhL2luY2x1ZGUvbGludXgvc2tidWZmLmggYi9pbmNsdWRlL2xpbnV4L3NrYnVmZi5oCmluZGV4
IDUwNWMzZmUuLjNlNGEyYmQgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgvc2tidWZmLmgKKysr
IGIvaW5jbHVkZS9saW51eC9za2J1ZmYuaApAQCAtMTgwLDYgKzE4MCwxNiBAQCBlbnVtIHsKIAlT
S0JfR1NPX1RDUFY2ID0gMSA8PCA0LAogfTsKIAorI2lmIEJJVFNfUEVSX0xPTkcgPiAzMgorI2Rl
ZmluZSBORVRfU0tCVUZGX0RBVEFfVVNFU19PRkZTRVQgMQorI2VuZGlmCisKKyNpZmRlZiBORVRf
U0tCVUZGX0RBVEFfVVNFU19PRkZTRVQKK3R5cGVkZWYgdW5zaWduZWQgaW50IHNrX2J1ZmZfZGF0
YV90OworI2Vsc2UKK3R5cGVkZWYgdW5zaWduZWQgY2hhciAqc2tfYnVmZl9kYXRhX3Q7CisjZW5k
aWYKKwogLyoqIAogICoJc3RydWN0IHNrX2J1ZmYgLSBzb2NrZXQgYnVmZmVyCiAgKglAbmV4dDog
TmV4dCBidWZmZXIgaW4gbGlzdApAQCAtMjM4LDkgKzI0OCw5IEBAIHN0cnVjdCBza19idWZmIHsK
IAlzdHJ1Y3QgbmV0X2RldmljZQkqZGV2OwogCXN0cnVjdCBuZXRfZGV2aWNlCSppbnB1dF9kZXY7
CiAKLQl1bnNpZ25lZCBjaGFyCQkqdHJhbnNwb3J0X2hlYWRlcjsKLQl1bnNpZ25lZCBjaGFyCQkq
bmV0d29ya19oZWFkZXI7Ci0JdW5zaWduZWQgY2hhcgkJKm1hY19oZWFkZXI7CisJc2tfYnVmZl9k
YXRhX3QJCXRyYW5zcG9ydF9oZWFkZXI7CisJc2tfYnVmZl9kYXRhX3QJCW5ldHdvcmtfaGVhZGVy
OworCXNrX2J1ZmZfZGF0YV90CQltYWNfaGVhZGVyOwogCXN0cnVjdCAgZHN0X2VudHJ5CSpkc3Q7
CiAJc3RydWN0CXNlY19wYXRoCSpzcDsKIApAQCAtOTQwLDUwICs5NTAsOTIgQEAgc3RhdGljIGlu
bGluZSB2b2lkIHNrYl9yZXNlcnZlKHN0cnVjdCBza19idWZmICpza2IsIGludCBsZW4pCiAJc2ti
LT50YWlsICs9IGxlbjsKIH0KIAorI2lmZGVmIE5FVF9TS0JVRkZfREFUQV9VU0VTX09GRlNFVAog
c3RhdGljIGlubGluZSB1bnNpZ25lZCBjaGFyICpza2JfdHJhbnNwb3J0X2hlYWRlcihjb25zdCBz
dHJ1Y3Qgc2tfYnVmZiAqc2tiKQogewotCXJldHVybiBza2ItPnRyYW5zcG9ydF9oZWFkZXI7CisJ
cmV0dXJuIHNrYi0+aGVhZCArIHNrYi0+dHJhbnNwb3J0X2hlYWRlcjsKIH0KIAogc3RhdGljIGlu
bGluZSB2b2lkIHNrYl9yZXNldF90cmFuc3BvcnRfaGVhZGVyKHN0cnVjdCBza19idWZmICpza2Ip
CiB7Ci0Jc2tiLT50cmFuc3BvcnRfaGVhZGVyID0gc2tiLT5kYXRhOworCXNrYi0+dHJhbnNwb3J0
X2hlYWRlciA9IHNrYi0+ZGF0YSAtIHNrYi0+aGVhZDsKIH0KIAogc3RhdGljIGlubGluZSB2b2lk
IHNrYl9zZXRfdHJhbnNwb3J0X2hlYWRlcihzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAogCQkJCQkgICAg
Y29uc3QgaW50IG9mZnNldCkKIHsKLQlza2ItPnRyYW5zcG9ydF9oZWFkZXIgPSBza2ItPmRhdGEg
KyBvZmZzZXQ7Ci19Ci0KLXN0YXRpYyBpbmxpbmUgaW50IHNrYl90cmFuc3BvcnRfb2Zmc2V0KGNv
bnN0IHN0cnVjdCBza19idWZmICpza2IpCi17Ci0JcmV0dXJuIHNrYi0+dHJhbnNwb3J0X2hlYWRl
ciAtIHNrYi0+ZGF0YTsKKwlza2JfcmVzZXRfdHJhbnNwb3J0X2hlYWRlcihza2IpOworCXNrYi0+
dHJhbnNwb3J0X2hlYWRlciArPSBvZmZzZXQ7CiB9CiAKIHN0YXRpYyBpbmxpbmUgdW5zaWduZWQg
Y2hhciAqc2tiX25ldHdvcmtfaGVhZGVyKGNvbnN0IHN0cnVjdCBza19idWZmICpza2IpCiB7Ci0J
cmV0dXJuIHNrYi0+bmV0d29ya19oZWFkZXI7CisJcmV0dXJuIHNrYi0+aGVhZCArIHNrYi0+bmV0
d29ya19oZWFkZXI7CiB9CiAKIHN0YXRpYyBpbmxpbmUgdm9pZCBza2JfcmVzZXRfbmV0d29ya19o
ZWFkZXIoc3RydWN0IHNrX2J1ZmYgKnNrYikKIHsKLQlza2ItPm5ldHdvcmtfaGVhZGVyID0gc2ti
LT5kYXRhOworCXNrYi0+bmV0d29ya19oZWFkZXIgPSBza2ItPmRhdGEgLSBza2ItPmhlYWQ7CiB9
CiAKIHN0YXRpYyBpbmxpbmUgdm9pZCBza2Jfc2V0X25ldHdvcmtfaGVhZGVyKHN0cnVjdCBza19i
dWZmICpza2IsIGNvbnN0IGludCBvZmZzZXQpCiB7Ci0Jc2tiLT5uZXR3b3JrX2hlYWRlciA9IHNr
Yi0+ZGF0YSArIG9mZnNldDsKKwlza2JfcmVzZXRfbmV0d29ya19oZWFkZXIoc2tiKTsKKwlza2It
Pm5ldHdvcmtfaGVhZGVyICs9IG9mZnNldDsKIH0KIAotc3RhdGljIGlubGluZSBpbnQgc2tiX25l
dHdvcmtfb2Zmc2V0KGNvbnN0IHN0cnVjdCBza19idWZmICpza2IpCitzdGF0aWMgaW5saW5lIHVu
c2lnbmVkIGNoYXIgKnNrYl9tYWNfaGVhZGVyKGNvbnN0IHN0cnVjdCBza19idWZmICpza2IpCiB7
Ci0JcmV0dXJuIHNrYi0+bmV0d29ya19oZWFkZXIgLSBza2ItPmRhdGE7CisJcmV0dXJuIHNrYi0+
aGVhZCArIHNrYi0+bWFjX2hlYWRlcjsKIH0KIAotc3RhdGljIGlubGluZSB1MzIgc2tiX25ldHdv
cmtfaGVhZGVyX2xlbihjb25zdCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiKQorc3RhdGljIGlubGluZSBp
bnQgc2tiX21hY19oZWFkZXJfd2FzX3NldChjb25zdCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiKQogewot
CXJldHVybiBza2ItPnRyYW5zcG9ydF9oZWFkZXIgLSBza2ItPm5ldHdvcmtfaGVhZGVyOworCXJl
dHVybiBza2ItPm1hY19oZWFkZXIgIT0gfjBVOworfQorCitzdGF0aWMgaW5saW5lIHZvaWQgc2ti
X3Jlc2V0X21hY19oZWFkZXIoc3RydWN0IHNrX2J1ZmYgKnNrYikKK3sKKwlza2ItPm1hY19oZWFk
ZXIgPSBza2ItPmRhdGEgLSBza2ItPmhlYWQ7Cit9CisKK3N0YXRpYyBpbmxpbmUgdm9pZCBza2Jf
c2V0X21hY19oZWFkZXIoc3RydWN0IHNrX2J1ZmYgKnNrYiwgY29uc3QgaW50IG9mZnNldCkKK3sK
Kwlza2JfcmVzZXRfbWFjX2hlYWRlcihza2IpOworCXNrYi0+bWFjX2hlYWRlciArPSBvZmZzZXQ7
Cit9CisKKyNlbHNlIC8qIE5FVF9TS0JVRkZfREFUQV9VU0VTX09GRlNFVCAqLworCitzdGF0aWMg
aW5saW5lIHVuc2lnbmVkIGNoYXIgKnNrYl90cmFuc3BvcnRfaGVhZGVyKGNvbnN0IHN0cnVjdCBz
a19idWZmICpza2IpCit7CisJcmV0dXJuIHNrYi0+dHJhbnNwb3J0X2hlYWRlcjsKK30KKworc3Rh
dGljIGlubGluZSB2b2lkIHNrYl9yZXNldF90cmFuc3BvcnRfaGVhZGVyKHN0cnVjdCBza19idWZm
ICpza2IpCit7CisJc2tiLT50cmFuc3BvcnRfaGVhZGVyID0gc2tiLT5kYXRhOworfQorCitzdGF0
aWMgaW5saW5lIHZvaWQgc2tiX3NldF90cmFuc3BvcnRfaGVhZGVyKHN0cnVjdCBza19idWZmICpz
a2IsCisJCQkJCSAgICBjb25zdCBpbnQgb2Zmc2V0KQoreworCXNrYi0+dHJhbnNwb3J0X2hlYWRl
ciA9IHNrYi0+ZGF0YSArIG9mZnNldDsKK30KKworc3RhdGljIGlubGluZSB1bnNpZ25lZCBjaGFy
ICpza2JfbmV0d29ya19oZWFkZXIoY29uc3Qgc3RydWN0IHNrX2J1ZmYgKnNrYikKK3sKKwlyZXR1
cm4gc2tiLT5uZXR3b3JrX2hlYWRlcjsKK30KKworc3RhdGljIGlubGluZSB2b2lkIHNrYl9yZXNl
dF9uZXR3b3JrX2hlYWRlcihzdHJ1Y3Qgc2tfYnVmZiAqc2tiKQoreworCXNrYi0+bmV0d29ya19o
ZWFkZXIgPSBza2ItPmRhdGE7Cit9CisKK3N0YXRpYyBpbmxpbmUgdm9pZCBza2Jfc2V0X25ldHdv
cmtfaGVhZGVyKHN0cnVjdCBza19idWZmICpza2IsIGNvbnN0IGludCBvZmZzZXQpCit7CisJc2ti
LT5uZXR3b3JrX2hlYWRlciA9IHNrYi0+ZGF0YSArIG9mZnNldDsKIH0KIAogc3RhdGljIGlubGlu
ZSB1bnNpZ25lZCBjaGFyICpza2JfbWFjX2hlYWRlcihjb25zdCBzdHJ1Y3Qgc2tfYnVmZiAqc2ti
KQpAQCAtMTAwNSw2ICsxMDU3LDIyIEBAIHN0YXRpYyBpbmxpbmUgdm9pZCBza2Jfc2V0X21hY19o
ZWFkZXIoc3RydWN0IHNrX2J1ZmYgKnNrYiwgY29uc3QgaW50IG9mZnNldCkKIHsKIAlza2ItPm1h
Y19oZWFkZXIgPSBza2ItPmRhdGEgKyBvZmZzZXQ7CiB9CisjZW5kaWYgLyogTkVUX1NLQlVGRl9E
QVRBX1VTRVNfT0ZGU0VUICovCisKK3N0YXRpYyBpbmxpbmUgaW50IHNrYl90cmFuc3BvcnRfb2Zm
c2V0KGNvbnN0IHN0cnVjdCBza19idWZmICpza2IpCit7CisJcmV0dXJuIHNrYl90cmFuc3BvcnRf
aGVhZGVyKHNrYikgLSBza2ItPmRhdGE7Cit9CisKK3N0YXRpYyBpbmxpbmUgdTMyIHNrYl9uZXR3
b3JrX2hlYWRlcl9sZW4oY29uc3Qgc3RydWN0IHNrX2J1ZmYgKnNrYikKK3sKKwlyZXR1cm4gc2ti
LT50cmFuc3BvcnRfaGVhZGVyIC0gc2tiLT5uZXR3b3JrX2hlYWRlcjsKK30KKworc3RhdGljIGlu
bGluZSBpbnQgc2tiX25ldHdvcmtfb2Zmc2V0KGNvbnN0IHN0cnVjdCBza19idWZmICpza2IpCit7
CisJcmV0dXJuIHNrYl9uZXR3b3JrX2hlYWRlcihza2IpIC0gc2tiLT5kYXRhOworfQogCiAvKgog
ICogQ1BVcyBvZnRlbiB0YWtlIGEgcGVyZm9ybWFuY2UgaGl0IHdoZW4gYWNjZXNzaW5nIHVuYWxp
Z25lZCBtZW1vcnkKZGlmZiAtLWdpdCBhL25ldC9pcHY0L2lwdnMvaXBfdnNfeG1pdC5jIGIvbmV0
L2lwdjQvaXB2cy9pcF92c194bWl0LmMKaW5kZXggZmRlZDliMi4uOTAwY2UyOSAxMDA2NDQKLS0t
IGEvbmV0L2lwdjQvaXB2cy9pcF92c194bWl0LmMKKysrIGIvbmV0L2lwdjQvaXB2cy9pcF92c194
bWl0LmMKQEAgLTMyMyw3ICszMjMsNyBAQCBpcF92c190dW5uZWxfeG1pdChzdHJ1Y3Qgc2tfYnVm
ZiAqc2tiLCBzdHJ1Y3QgaXBfdnNfY29ubiAqY3AsCiAJc3RydWN0IGlwaGRyICAqb2xkX2lwaCA9
IGlwX2hkcihza2IpOwogCXU4ICAgICB0b3MgPSBvbGRfaXBoLT50b3M7CiAJX19iZTE2IGRmID0g
b2xkX2lwaC0+ZnJhZ19vZmY7Ci0JdW5zaWduZWQgY2hhciAqb2xkX3RyYW5zcG9ydF9oZWFkZXIg
PSBza2ItPnRyYW5zcG9ydF9oZWFkZXI7CisJc2tfYnVmZl9kYXRhX3Qgb2xkX3RyYW5zcG9ydF9o
ZWFkZXIgPSBza2ItPnRyYW5zcG9ydF9oZWFkZXI7CiAJc3RydWN0IGlwaGRyICAqaXBoOwkJCS8q
IE91ciBuZXcgSVAgaGVhZGVyICovCiAJaW50ICAgIG1heF9oZWFkcm9vbTsJCQkvKiBUaGUgZXh0
cmEgaGVhZGVyIHNwYWNlIG5lZWRlZCAqLwogCWludCAgICBtdHU7CmRpZmYgLS1naXQgYS9uZXQv
c2N0cC9pbnB1dC5jIGIvbmV0L3NjdHAvaW5wdXQuYwppbmRleCA4N2ZlZWUxLi4xZmY0N2IxIDEw
MDY0NAotLS0gYS9uZXQvc2N0cC9pbnB1dC5jCisrKyBiL25ldC9zY3RwL2lucHV0LmMKQEAgLTUx
Myw3ICs1MTMsNyBAQCB2b2lkIHNjdHBfdjRfZXJyKHN0cnVjdCBza19idWZmICpza2IsIF9fdTMy
IGluZm8pCiAJc3RydWN0IHNjdHBfYXNzb2NpYXRpb24gKmFzb2MgPSBOVUxMOwogCXN0cnVjdCBz
Y3RwX3RyYW5zcG9ydCAqdHJhbnNwb3J0OwogCXN0cnVjdCBpbmV0X3NvY2sgKmluZXQ7Ci0JY2hh
ciAqc2F2ZWlwLCAqc2F2ZXNjdHA7CisJc2tfYnVmZl9kYXRhX3Qgc2F2ZWlwLCBzYXZlc2N0cDsK
IAlpbnQgZXJyOwogCiAJaWYgKHNrYi0+bGVuIDwgaWhsZW4gKyA4KSB7CkBAIC01MjcsNyArNTI3
LDcgQEAgdm9pZCBzY3RwX3Y0X2VycihzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBfX3UzMiBpbmZvKQog
CXNrYl9yZXNldF9uZXR3b3JrX2hlYWRlcihza2IpOwogCXNrYl9zZXRfdHJhbnNwb3J0X2hlYWRl
cihza2IsIGlobGVuKTsKIAlzayA9IHNjdHBfZXJyX2xvb2t1cChBRl9JTkVULCBza2IsIHNjdHBf
aGRyKHNrYiksICZhc29jLCAmdHJhbnNwb3J0KTsKLQkvKiBQdXQgYmFjaywgdGhlIG9yaWdpbmFs
IHBvaW50ZXJzLiAqLworCS8qIFB1dCBiYWNrLCB0aGUgb3JpZ2luYWwgdmFsdWVzLiAqLwogCXNr
Yi0+bmV0d29ya19oZWFkZXIgPSBzYXZlaXA7CiAJc2tiLT50cmFuc3BvcnRfaGVhZGVyID0gc2F2
ZXNjdHA7CiAJaWYgKCFzaykgewpkaWZmIC0tZ2l0IGEvbmV0L3NjdHAvaXB2Ni5jIGIvbmV0L3Nj
dHAvaXB2Ni5jCmluZGV4IDhiN2NjMTQuLjhmYWY3M2UgMTAwNjQ0Ci0tLSBhL25ldC9zY3RwL2lw
djYuYworKysgYi9uZXQvc2N0cC9pcHY2LmMKQEAgLTEyNiw3ICsxMjYsNyBAQCBTQ1RQX1NUQVRJ
QyB2b2lkIHNjdHBfdjZfZXJyKHN0cnVjdCBza19idWZmICpza2IsIHN0cnVjdCBpbmV0Nl9za2Jf
cGFybSAqb3B0LAogCXN0cnVjdCBzY3RwX2Fzc29jaWF0aW9uICphc29jOwogCXN0cnVjdCBzY3Rw
X3RyYW5zcG9ydCAqdHJhbnNwb3J0OwogCXN0cnVjdCBpcHY2X3BpbmZvICpucDsKLQljaGFyICpz
YXZlaXAsICpzYXZlc2N0cDsKKwlza19idWZmX2RhdGFfdCBzYXZlaXAsIHNhdmVzY3RwOwogCWlu
dCBlcnI7CiAKIAlpZGV2ID0gaW42X2Rldl9nZXQoc2tiLT5kZXYpOwotLSAKMS41LjAuMwoK
------=_Part_84481_4228795.1174078472345--
