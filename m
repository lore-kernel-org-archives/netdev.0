From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCH] netns: oops in ip_frag_reasm incrementing stats
Date: Fri, 13 Mar 2009 17:21:08 +0100
Message-ID: <49BA87F4.1090709@dti2.net>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030105020308000009070009"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:2419 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753923AbZCMQ0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 12:26:43 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v9.6.5)
	with ESMTP id md50002645022.msg
	for <netdev@vger.kernel.org>; Fri, 13 Mar 2009 17:21:13 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030105020308000009070009
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

skb->dev can be NULL on ip_frag_reasm for skb's coming from RAW sockets.

Quagga's OSPFD sends fragmented packets on a RAW socket, when netfilter
conntrack reassembles them on the OUTPUT path you hit this code path.

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
  net/ipv4/ip_fragment.c |   14 +++++++-------
  1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 6659ac0..8f150d5 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -84,7 +84,7 @@ int ip_frag_mem(struct net *net)
  	return atomic_read(&net->ipv4.frags.mem);
  }

-static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
+static int ip_frag_reasm(struct net *net, struct ipq *qp, struct 
sk_buff *prev,
  			 struct net_device *dev);

  struct ip4_create_arg {
@@ -296,7 +296,7 @@ static int ip_frag_reinit(struct ipq *qp)
  }

  /* Add new segment to existing queue. */
-static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
+static int ip_frag_queue(struct net *net, struct ipq *qp, struct 
sk_buff *skb)
  {
  	struct sk_buff *prev, *next;
  	struct net_device *dev;
@@ -445,7 +445,7 @@ static int ip_frag_queue(struct ipq *qp, struct 
sk_buff *skb)

  	if (qp->q.last_in == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
  	    qp->q.meat == qp->q.len)
-		return ip_frag_reasm(qp, prev, dev);
+		return ip_frag_reasm(net, qp, prev, dev);

  	write_lock(&ip4_frags.lock);
  	list_move_tail(&qp->q.lru_list, &qp->q.net->lru_list);
@@ -460,7 +460,7 @@ err:

  /* Build a new IP datagram from all its fragments. */

-static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
+static int ip_frag_reasm(struct net *net, struct ipq *qp, struct 
sk_buff *prev,
  			 struct net_device *dev)
  {
  	struct iphdr *iph;
@@ -548,7 +548,7 @@ static int ip_frag_reasm(struct ipq *qp, struct 
sk_buff *prev,
  	iph = ip_hdr(head);
  	iph->frag_off = 0;
  	iph->tot_len = htons(len);
-	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_REASMOKS);
+	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMOKS);
  	qp->q.fragments = NULL;
  	return 0;

@@ -562,7 +562,7 @@ out_oversize:
  		printk(KERN_INFO "Oversized IP packet from %pI4.\n",
  			&qp->saddr);
  out_fail:
-	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_REASMFAILS);
+	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
  	return err;
  }

@@ -585,7 +585,7 @@ int ip_defrag(struct sk_buff *skb, u32 user)

  		spin_lock(&qp->q.lock);

-		ret = ip_frag_queue(qp, skb);
+		ret = ip_frag_queue(net, qp, skb);

  		spin_unlock(&qp->q.lock);
  		ipq_put(qp);
-- 
1.5.6.5


--------------030105020308000009070009
Content-Type: application/mbox;
 name="netns-fragmentation.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="netns-fragmentation.patch"

ZGlmZiAtdU5ycCBsaW51eC0yLjYuMjktcmM4Lm9yaWcvbmV0L2lwdjQvaXBfZnJhZ21lbnQu
YyBrZXJuZWwvbmV0L2lwdjQvaXBfZnJhZ21lbnQuYwotLS0gbGludXgtMi42LjI5LXJjOC5v
cmlnL25ldC9pcHY0L2lwX2ZyYWdtZW50LmMJMjAwOS0wMy0wNiAxNjozNjozMS4zODQzNjE5
MzcgKzAxMDAKKysrIGtlcm5lbC1uZXRucy9uZXQvaXB2NC9pcF9mcmFnbWVudC5jCTIwMDkt
MDMtMDUgMTQ6MzE6MDMuNDQzMjY3NTgyICswMTAwCkBAIC04NCw3ICs4NCw3IEBAIGludCBp
cF9mcmFnX21lbShzdHJ1Y3QgbmV0ICpuZXQpCiAJcmV0dXJuIGF0b21pY19yZWFkKCZuZXQt
PmlwdjQuZnJhZ3MubWVtKTsKIH0KIAotc3RhdGljIGludCBpcF9mcmFnX3JlYXNtKHN0cnVj
dCBpcHEgKnFwLCBzdHJ1Y3Qgc2tfYnVmZiAqcHJldiwKK3N0YXRpYyBpbnQgaXBfZnJhZ19y
ZWFzbShzdHJ1Y3QgbmV0ICpuZXQsIHN0cnVjdCBpcHEgKnFwLCBzdHJ1Y3Qgc2tfYnVmZiAq
cHJldiwKIAkJCSBzdHJ1Y3QgbmV0X2RldmljZSAqZGV2KTsKIAogc3RydWN0IGlwNF9jcmVh
dGVfYXJnIHsKQEAgLTI5Niw3ICsyOTYsNyBAQCBzdGF0aWMgaW50IGlwX2ZyYWdfcmVpbml0
KHN0cnVjdCBpcHEgKnFwCiB9CiAKIC8qIEFkZCBuZXcgc2VnbWVudCB0byBleGlzdGluZyBx
dWV1ZS4gKi8KLXN0YXRpYyBpbnQgaXBfZnJhZ19xdWV1ZShzdHJ1Y3QgaXBxICpxcCwgc3Ry
dWN0IHNrX2J1ZmYgKnNrYikKK3N0YXRpYyBpbnQgaXBfZnJhZ19xdWV1ZShzdHJ1Y3QgbmV0
ICpuZXQsIHN0cnVjdCBpcHEgKnFwLCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiKQogewogCXN0cnVj
dCBza19idWZmICpwcmV2LCAqbmV4dDsKIAlzdHJ1Y3QgbmV0X2RldmljZSAqZGV2OwpAQCAt
NDQ1LDcgKzQ0NSw3IEBAIHN0YXRpYyBpbnQgaXBfZnJhZ19xdWV1ZShzdHJ1Y3QgaXBxICpx
cCwKIAogCWlmIChxcC0+cS5sYXN0X2luID09IChJTkVUX0ZSQUdfRklSU1RfSU4gfCBJTkVU
X0ZSQUdfTEFTVF9JTikgJiYKIAkgICAgcXAtPnEubWVhdCA9PSBxcC0+cS5sZW4pCi0JCXJl
dHVybiBpcF9mcmFnX3JlYXNtKHFwLCBwcmV2LCBkZXYpOworCQlyZXR1cm4gaXBfZnJhZ19y
ZWFzbShuZXQsIHFwLCBwcmV2LCBkZXYpOwogCiAJd3JpdGVfbG9jaygmaXA0X2ZyYWdzLmxv
Y2spOwogCWxpc3RfbW92ZV90YWlsKCZxcC0+cS5scnVfbGlzdCwgJnFwLT5xLm5ldC0+bHJ1
X2xpc3QpOwpAQCAtNDYwLDcgKzQ2MCw3IEBAIGVycjoKIAogLyogQnVpbGQgYSBuZXcgSVAg
ZGF0YWdyYW0gZnJvbSBhbGwgaXRzIGZyYWdtZW50cy4gKi8KIAotc3RhdGljIGludCBpcF9m
cmFnX3JlYXNtKHN0cnVjdCBpcHEgKnFwLCBzdHJ1Y3Qgc2tfYnVmZiAqcHJldiwKK3N0YXRp
YyBpbnQgaXBfZnJhZ19yZWFzbShzdHJ1Y3QgbmV0ICpuZXQsIHN0cnVjdCBpcHEgKnFwLCBz
dHJ1Y3Qgc2tfYnVmZiAqcHJldiwKIAkJCSBzdHJ1Y3QgbmV0X2RldmljZSAqZGV2KQogewog
CXN0cnVjdCBpcGhkciAqaXBoOwpAQCAtNTA5LDcgKzUwOSw2IEBAIHN0YXRpYyBpbnQgaXBf
ZnJhZ19yZWFzbShzdHJ1Y3QgaXBxICpxcCwKIAlpZiAoc2tiX3NoaW5mbyhoZWFkKS0+ZnJh
Z19saXN0KSB7CiAJCXN0cnVjdCBza19idWZmICpjbG9uZTsKIAkJaW50IGksIHBsZW4gPSAw
OwotCiAJCWlmICgoY2xvbmUgPSBhbGxvY19za2IoMCwgR0ZQX0FUT01JQykpID09IE5VTEwp
CiAJCQlnb3RvIG91dF9ub21lbTsKIAkJY2xvbmUtPm5leHQgPSBoZWFkLT5uZXh0OwpAQCAt
NTQ4LDcgKzU0Nyw3IEBAIHN0YXRpYyBpbnQgaXBfZnJhZ19yZWFzbShzdHJ1Y3QgaXBxICpx
cCwKIAlpcGggPSBpcF9oZHIoaGVhZCk7CiAJaXBoLT5mcmFnX29mZiA9IDA7CiAJaXBoLT50
b3RfbGVuID0gaHRvbnMobGVuKTsKLQlJUF9JTkNfU1RBVFNfQkgoZGV2X25ldChkZXYpLCBJ
UFNUQVRTX01JQl9SRUFTTU9LUyk7CisJSVBfSU5DX1NUQVRTX0JIKG5ldCwgSVBTVEFUU19N
SUJfUkVBU01PS1MpOwogCXFwLT5xLmZyYWdtZW50cyA9IE5VTEw7CiAJcmV0dXJuIDA7CiAK
QEAgLTU2Miw3ICs1NjEsNyBAQCBvdXRfb3ZlcnNpemU6CiAJCXByaW50ayhLRVJOX0lORk8g
Ik92ZXJzaXplZCBJUCBwYWNrZXQgZnJvbSAlcEk0LlxuIiwKIAkJCSZxcC0+c2FkZHIpOwog
b3V0X2ZhaWw6Ci0JSVBfSU5DX1NUQVRTX0JIKGRldl9uZXQoZGV2KSwgSVBTVEFUU19NSUJf
UkVBU01GQUlMUyk7CisJSVBfSU5DX1NUQVRTX0JIKG5ldCwgSVBTVEFUU19NSUJfUkVBU01G
QUlMUyk7CiAJcmV0dXJuIGVycjsKIH0KIApAQCAtNTg1LDcgKzU4NCw3IEBAIGludCBpcF9k
ZWZyYWcoc3RydWN0IHNrX2J1ZmYgKnNrYiwgdTMyIHUKIAogCQlzcGluX2xvY2soJnFwLT5x
LmxvY2spOwogCi0JCXJldCA9IGlwX2ZyYWdfcXVldWUocXAsIHNrYik7CisJCXJldCA9IGlw
X2ZyYWdfcXVldWUobmV0LCBxcCwgc2tiKTsKIAogCQlzcGluX3VubG9jaygmcXAtPnEubG9j
ayk7CiAJCWlwcV9wdXQocXApOwo=
--------------030105020308000009070009--

