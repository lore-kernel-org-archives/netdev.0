From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: Re: [PATCH][IPsec] fix process of error from crypto module
Date: Thu, 27 Jan 2005 13:51:52 +0900
Message-ID: <41F87368.7060909@miyazawa.org>
References: <E1Cttr8-0005S6-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1Cttr8-0005S6-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> MIYAZAWA Kazunori <kazunori@miyazawa.org> wrote:
> 
>>This patch fixes the process under the case that the crypto module
>>returns error because of its weak keys or etc.
> 
> 
> Good catch.
> 
> 
>>diff -ur a/net/ipv6/esp6.c b/net/ipv6/esp6.c
>>--- a/net/ipv6/esp6.c 2004-12-25 06:35:01.000000000 +0900
>>+++ b/net/ipv6/esp6.c 2005-01-26 18:57:04.000000000 +0900
>>@@ -364,7 +364,8 @@
>>   goto error;
>>  get_random_bytes(esp->conf.ivec, esp->conf.ivlen);
>> }
>>- crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len);
>>+ if (crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len))
>>+  goto error;
>> x->props.header_len = sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen;
>> if (x->props.mode)
>>  x->props.header_len += sizeof(struct ipv6hdr);
> 
> 
> You need to free esp->conf.ivec here.
> 
> Cheers,

Thank you for your check, Herbert.
I send the fixed patch.
BTW, esp6_destroy seem to be similar to esp_destroy.
Should we export esp_destroy and IPv4 and IPv6 use it?
Do we have any reason to define the functions separately?

diff -ruN a/net/ipv4/esp4.c b/net/ipv4/esp4.c
--- a/net/ipv4/esp4.c	2004-12-25 06:34:58.000000000 +0900
+++ b/net/ipv4/esp4.c	2005-01-26 18:57:18.000000000 +0900
@@ -427,7 +427,8 @@
 			goto error;
 		get_random_bytes(esp->conf.ivec, esp->conf.ivlen);
 	}
-	crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len);
+	if (crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len))
+		goto error;
 	x->props.header_len = sizeof(struct ip_esp_hdr) + esp->conf.ivlen;
 	if (x->props.mode)
 		x->props.header_len += sizeof(struct iphdr);
diff -ruN a/net/ipv6/esp6.c b/net/ipv6/esp6.c
--- a/net/ipv6/esp6.c	2004-12-25 06:35:01.000000000 +0900
+++ b/net/ipv6/esp6.c	2005-01-27 00:55:34.000000000 +0900
@@ -364,7 +364,8 @@
 			goto error;
 		get_random_bytes(esp->conf.ivec, esp->conf.ivlen);
 	}
-	crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len);
+	if (crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len))
+		goto error;
 	x->props.header_len = sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen;
 	if (x->props.mode)
 		x->props.header_len += sizeof(struct ipv6hdr);
@@ -372,15 +373,9 @@
 	return 0;

 error:
-	if (esp) {
-		if (esp->auth.tfm)
-			crypto_free_tfm(esp->auth.tfm);
-		if (esp->auth.work_icv)
-			kfree(esp->auth.work_icv);
-		if (esp->conf.tfm)
-			crypto_free_tfm(esp->conf.tfm);
-		kfree(esp);
-	}
+	x->data = esp;
+	esp6_destroy(x);
+	x->data = NULL;
 	return -EINVAL;
 }
