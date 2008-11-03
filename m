From: Simon Arlott <simon@arlott.org>
Subject: [PATCH] netfilter: Remove warn_if_extra_mangle
Date: Mon, 03 Nov 2008 21:51:56 +0000
Message-ID: <490F727C.6020705@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/x-pkcs7-signature"; micalg=sha1; boundary="------------ms000605040804040909030309"
Cc: netdev <netdev@vger.kernel.org>, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:55481 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751093AbYKCWTR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 17:19:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms000605040804040909030309
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

In net/ipv4/netfilter/nf_nat_rule.c, the function warn_if_extra_mangle was added 
in commit 5b1158e909ecbe1a052203e0d8df15633f829930 (2006-12-02). I have a DNAT 
target in the OUTPUT chain than changes connections with dst 2.0.0.1 to another 
address which I'll substitute with 66.102.9.99 below.

On every boot I get the following message:
[  146.252505] NAT: no longer support implicit source local NAT
[  146.252517] NAT: packet src 66.102.9.99 -> dst 2.0.0.1

As far as I can tell from reading the function doing this, it should warn if the 
source IP for the route to 66.102.9.99 is different from 2.0.0.1 but that is not 
the case. It doesn't make sense to check the DNAT target against the local route 
source.

Either the function should be changed to correctly check the route, or it should 
be removed entirely as it's been nearly 2 years since it was added.

Signed-off-by: Simon Arlott <simon@fire.lp0.eu>
---
 net/ipv4/netfilter/nf_nat_rule.c |   24 ------------------------
 1 files changed, 0 insertions(+), 24 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
index bea54a6..0e8af39 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -86,25 +86,6 @@ ipt_snat_target(struct sk_buff *skb, const struct xt_target_param *par)
 	return nf_nat_setup_info(ct, &mr->range[0], IP_NAT_MANIP_SRC);
 }
 
-/* Before 2.6.11 we did implicit source NAT if required. Warn about change. */
-static void warn_if_extra_mangle(struct net *net, __be32 dstip, __be32 srcip)
-{
-	static int warned = 0;
-	struct flowi fl = { .nl_u = { .ip4_u = { .daddr = dstip } } };
-	struct rtable *rt;
-
-	if (ip_route_output_key(net, &rt, &fl) != 0)
-		return;
-
-	if (rt->rt_src != srcip && !warned) {
-		printk("NAT: no longer support implicit source local NAT\n");
-		printk("NAT: packet src %u.%u.%u.%u -> dst %u.%u.%u.%u\n",
-		       NIPQUAD(srcip), NIPQUAD(dstip));
-		warned = 1;
-	}
-	ip_rt_put(rt);
-}
-
 static unsigned int
 ipt_dnat_target(struct sk_buff *skb, const struct xt_target_param *par)
 {
@@ -120,11 +101,6 @@ ipt_dnat_target(struct sk_buff *skb, const struct xt_target_param *par)
 	/* Connection must be valid and new. */
 	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED));
 
-	if (par->hooknum == NF_INET_LOCAL_OUT &&
-	    mr->range[0].flags & IP_NAT_RANGE_MAP_IPS)
-		warn_if_extra_mangle(dev_net(par->out), ip_hdr(skb)->daddr,
-				     mr->range[0].min_ip);
-
 	return nf_nat_setup_info(ct, &mr->range[0], IP_NAT_MANIP_DST);
 }
 
-- 
1.6.0.2

-- 
Simon Arlott

--------------ms000605040804040909030309
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIKXjCC
BSswggMToAMCAQICAwO7ijANBgkqhkiG9w0BAQUFADB5MRAwDgYDVQQKEwdSb290IENBMR4w
HAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMTGUNBIENlcnQgU2lnbmlu
ZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRAY2FjZXJ0Lm9yZzAeFw0wNzA2
MjYxNzU1MDRaFw0wOTA2MjUxNzU1MDRaMDgxFTATBgNVBAMTDFNpbW9uIEFybG90dDEfMB0G
CSqGSIb3DQEJARYQc2ltb25AYXJsb3R0Lm9yZzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
AQoCggEBALIIK63ZkK5EhTZGUa5tevs/o/KTweoehTe9btmhWX7X4xce1TG6f14ofHL9VHR2
ID1qmau8phtyiu+B2XtFf5Ac8PdKPlsWT9qfkF9IC98rdY9b6v/uqyMRU4ADnFS8NmRI4QlZ
JfFVynjpIJ4GOQxmbo5WHpDmfhxY5uDZPPbLaDniFQIh2Fc0vt7lqXAXuXKsB08uEzaidrEp
2qimmzY5QMc51ZEHtIyIujEDWYnldwNX/9rKzLoyQikR6707y5nI0fTkIfLbuQsjS1D8NKSU
RZEhO6DszajpKy4CpePnADo5xiEroNLhbEtWfIX2A0EBtxQD252+Pa7U3XMCvGECAwEAAaOB
/DCB+TAMBgNVHRMBAf8EAjAAMFYGCWCGSAGG+EIBDQRJFkdUbyBnZXQgeW91ciBvd24gY2Vy
dGlmaWNhdGUgZm9yIEZSRUUgaGVhZCBvdmVyIHRvIGh0dHA6Ly93d3cuQ0FjZXJ0Lm9yZzBA
BgNVHSUEOTA3BggrBgEFBQcDBAYIKwYBBQUHAwIGCisGAQQBgjcKAwQGCisGAQQBgjcKAwMG
CWCGSAGG+EIEATAyBggrBgEFBQcBAQQmMCQwIgYIKwYBBQUHMAGGFmh0dHA6Ly9vY3NwLmNh
Y2VydC5vcmcwGwYDVR0RBBQwEoEQc2ltb25AYXJsb3R0Lm9yZzANBgkqhkiG9w0BAQUFAAOC
AgEAS8DRW/a98sHC7Mqc14VPQGcdHdabYddGTsfGLXbtmek5XjatUgVIv9v7rTMBBBz1rB6V
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
cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5
MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAwO7ijAJBgUrDgMCGgUAoIIB
6DAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0wODExMDMyMTUx
NTZaMCMGCSqGSIb3DQEJBDEWBBS3z5kqP+XP+rW78gew+yEXlBwrADBfBgkqhkiG9w0BCQ8x
UjBQMAsGCWCGSAFlAwQBAjAKBggqhkiG9w0DBzAOBggqhkiG9w0DAgICAIAwDQYIKoZIhvcN
AwICAUAwBwYFKw4DAgcwDQYIKoZIhvcNAwICASgwgZEGCSsGAQQBgjcQBDGBgzCBgDB5MRAw
DgYDVQQKEwdSb290IENBMR4wHAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNV
BAMTGUNBIENlcnQgU2lnbmluZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRA
Y2FjZXJ0Lm9yZwIDA7uKMIGTBgsqhkiG9w0BCRACCzGBg6CBgDB5MRAwDgYDVQQKEwdSb290
IENBMR4wHAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMTGUNBIENlcnQg
U2lnbmluZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRAY2FjZXJ0Lm9yZwID
A7uKMA0GCSqGSIb3DQEBAQUABIIBAJ9cJpsJzLa3Dd6gS91QWiJu4ln7JpGezjB9RRRAdeHH
dGqsdCv+FVikOL1T6Za2vA+hOpNIE25S8QrydtaXwNyWZglkGiyknk+0N+l7ACq0dq6YRNZq
NQVXFqkivPtjdSlvPEOthCI0pLNBf1Iu7A2ZGLA2jlnyxR9L4DDbtBXFOQS48GKr6NoXcSml
zwU3Wwzn7GA92SdEg0bcfHgxknFOt+LW70N9WiFWje1p7YJwFLHvQjRMZw1SwNx2ffpF20uR
+zdN1Qa/ZlCuZiXY04zTTz5i8RP/PaCo6u33SwMt66WDZRbCmXLod5Bd2vKUgKMLZ2/fn2zp
ueW866gka4sAAAAAAAA=
--------------ms000605040804040909030309--
