From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: IPv6 multicast (MLD,IGMP) code bypasses netfilter hooks
Date: Sun, 23 Nov 2003 04:13:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFBBD13E53.65F0744F-ON88256DE7.003D0DE0@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE774DFAE8B708f9e8a93df938690918c07BBE774DFAE8B70"
Cc: netdev@oss.sgi.com,
        Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>, davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE774DFAE8B708f9e8a93df938690918c07BBE774DFAE8B70
Content-type: text/plain; charset=US-ASCII





Here's a patch to add netfilter hooks for MLD v1 & v2. Can you take
quick look at it, Harald?

                        +-DLS

--- linux-2.6.0-test9-bk25/net/ipv6/mcast.c     2003-11-21 19:33:41.000000000 -0800
+++ linux-2.6.0-test9-bk25F1/net/ipv6/mcast.c   2003-11-23 01:32:39.000000000 -0800
@@ -46,6 +46,9 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>

+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv6.h>
+
 #include <net/sock.h>
 #include <net/snmp.h>

@@ -1265,6 +1268,7 @@
      struct mld2_report *pmr = (struct mld2_report *)skb->h.raw;
      int payload_len, mldlen;
      struct inet6_dev *idev = in6_dev_get(skb->dev);
+     int err;

      payload_len = skb->tail - (unsigned char *)skb->nh.ipv6h -
            sizeof(struct ipv6hdr);
@@ -1273,8 +1277,10 @@

      pmr->csum = csum_ipv6_magic(&pip6->saddr, &pip6->daddr, mldlen,
            IPPROTO_ICMPV6, csum_partial(skb->h.raw, mldlen, 0));
-     dev_queue_xmit(skb);
-     ICMP6_INC_STATS(idev,Icmp6OutMsgs);
+     err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dev,
+           dev_queue_xmit);
+     if (!err)
+           ICMP6_INC_STATS(idev,Icmp6OutMsgs);
      if (likely(idev != NULL))
            in6_dev_put(idev);
 }
@@ -1603,12 +1609,15 @@

      idev = in6_dev_get(skb->dev);

-     dev_queue_xmit(skb);
-     if (type == ICMPV6_MGM_REDUCTION)
-           ICMP6_INC_STATS(idev, Icmp6OutGroupMembReductions);
-     else
-           ICMP6_INC_STATS(idev, Icmp6OutGroupMembResponses);
-     ICMP6_INC_STATS(idev, Icmp6OutMsgs);
+     err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dev,
+           dev_queue_xmit);
+     if (!err) {
+           if (type == ICMPV6_MGM_REDUCTION)
+                 ICMP6_INC_STATS(idev, Icmp6OutGroupMembReductions);
+           else
+                 ICMP6_INC_STATS(idev, Icmp6OutGroupMembResponses);
+           ICMP6_INC_STATS(idev, Icmp6OutMsgs);
+     }

      if (likely(idev != NULL))
            in6_dev_put(idev);

(See attached file: MLDNF.patch)
--0__=07BBE774DFAE8B708f9e8a93df938690918c07BBE774DFAE8B70
Content-type: application/octet-stream;
	name="MLDNF.patch"
Content-Disposition: attachment; filename="MLDNF.patch"
Content-transfer-encoding: base64

LS0tIGxpbnV4LTIuNi4wLXRlc3Q5LWJrMjUvbmV0L2lwdjYvbWNhc3QuYwkyMDAzLTExLTIxIDE5
OjMzOjQxLjAwMDAwMDAwMCAtMDgwMAorKysgbGludXgtMi42LjAtdGVzdDktYmsyNUYxL25ldC9p
cHY2L21jYXN0LmMJMjAwMy0xMS0yMyAwMTozMjozOS4wMDAwMDAwMDAgLTA4MDAKQEAgLTQ2LDYg
KzQ2LDkgQEAKICNpbmNsdWRlIDxsaW51eC9wcm9jX2ZzLmg+CiAjaW5jbHVkZSA8bGludXgvc2Vx
X2ZpbGUuaD4KIAorI2luY2x1ZGUgPGxpbnV4L25ldGZpbHRlci5oPgorI2luY2x1ZGUgPGxpbnV4
L25ldGZpbHRlcl9pcHY2Lmg+CisKICNpbmNsdWRlIDxuZXQvc29jay5oPgogI2luY2x1ZGUgPG5l
dC9zbm1wLmg+CiAKQEAgLTEyNjUsNiArMTI2OCw3IEBACiAJc3RydWN0IG1sZDJfcmVwb3J0ICpw
bXIgPSAoc3RydWN0IG1sZDJfcmVwb3J0ICopc2tiLT5oLnJhdzsKIAlpbnQgcGF5bG9hZF9sZW4s
IG1sZGxlbjsKIAlzdHJ1Y3QgaW5ldDZfZGV2ICppZGV2ID0gaW42X2Rldl9nZXQoc2tiLT5kZXYp
OworCWludCBlcnI7CiAKIAlwYXlsb2FkX2xlbiA9IHNrYi0+dGFpbCAtICh1bnNpZ25lZCBjaGFy
ICopc2tiLT5uaC5pcHY2aCAtCiAJCXNpemVvZihzdHJ1Y3QgaXB2Nmhkcik7CkBAIC0xMjczLDgg
KzEyNzcsMTAgQEAKIAogCXBtci0+Y3N1bSA9IGNzdW1faXB2Nl9tYWdpYygmcGlwNi0+c2FkZHIs
ICZwaXA2LT5kYWRkciwgbWxkbGVuLAogCQlJUFBST1RPX0lDTVBWNiwgY3N1bV9wYXJ0aWFsKHNr
Yi0+aC5yYXcsIG1sZGxlbiwgMCkpOwotCWRldl9xdWV1ZV94bWl0KHNrYik7Ci0JSUNNUDZfSU5D
X1NUQVRTKGlkZXYsSWNtcDZPdXRNc2dzKTsKKwllcnIgPSBORl9IT09LKFBGX0lORVQ2LCBORl9J
UDZfTE9DQUxfT1VULCBza2IsIE5VTEwsIHNrYi0+ZGV2LAorCQlkZXZfcXVldWVfeG1pdCk7CisJ
aWYgKCFlcnIpCisJCUlDTVA2X0lOQ19TVEFUUyhpZGV2LEljbXA2T3V0TXNncyk7CiAJaWYgKGxp
a2VseShpZGV2ICE9IE5VTEwpKQogCQlpbjZfZGV2X3B1dChpZGV2KTsKIH0KQEAgLTE2MDMsMTIg
KzE2MDksMTUgQEAKIAogCWlkZXYgPSBpbjZfZGV2X2dldChza2ItPmRldik7CiAKLQlkZXZfcXVl
dWVfeG1pdChza2IpOwotCWlmICh0eXBlID09IElDTVBWNl9NR01fUkVEVUNUSU9OKQotCQlJQ01Q
Nl9JTkNfU1RBVFMoaWRldiwgSWNtcDZPdXRHcm91cE1lbWJSZWR1Y3Rpb25zKTsKLQllbHNlCi0J
CUlDTVA2X0lOQ19TVEFUUyhpZGV2LCBJY21wNk91dEdyb3VwTWVtYlJlc3BvbnNlcyk7Ci0JSUNN
UDZfSU5DX1NUQVRTKGlkZXYsIEljbXA2T3V0TXNncyk7CisJZXJyID0gTkZfSE9PSyhQRl9JTkVU
NiwgTkZfSVA2X0xPQ0FMX09VVCwgc2tiLCBOVUxMLCBza2ItPmRldiwKKwkJZGV2X3F1ZXVlX3ht
aXQpOworCWlmICghZXJyKSB7CisJCWlmICh0eXBlID09IElDTVBWNl9NR01fUkVEVUNUSU9OKQor
CQkJSUNNUDZfSU5DX1NUQVRTKGlkZXYsIEljbXA2T3V0R3JvdXBNZW1iUmVkdWN0aW9ucyk7CisJ
CWVsc2UKKwkJCUlDTVA2X0lOQ19TVEFUUyhpZGV2LCBJY21wNk91dEdyb3VwTWVtYlJlc3BvbnNl
cyk7CisJCUlDTVA2X0lOQ19TVEFUUyhpZGV2LCBJY21wNk91dE1zZ3MpOworCX0KIAogCWlmIChs
aWtlbHkoaWRldiAhPSBOVUxMKSkKIAkJaW42X2Rldl9wdXQoaWRldik7Cg==

--0__=07BBE774DFAE8B708f9e8a93df938690918c07BBE774DFAE8B70--
