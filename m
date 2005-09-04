From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Kernel 2.6.13 breaks libpcap (and tcpdump).
Date: Mon, 05 Sep 2005 08:09:40 +1000
Message-ID: <E1EC2gG-0006hm-00@gondolin.me.apana.org.au>
References: <431B2F6E.9070401@trash.net>
Cc: herbert@gondor.apana.org.au, akpm@osdl.org, jmcgowan@inch.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932093AbVIDWJq@vger.kernel.org>
To: kaber@trash.net (Patrick McHardy)
In-Reply-To: <431B2F6E.9070401@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> wrote:
> 
> Never mind, I got it, we never fall through to the second switch
> statement anymore. I think we could simply break when load_pointer
> returns NULL. The switch statement will fall through to the default
> case and return 0 for all cases but 0 > k >= SKF_AD_OFF.

Thanks Patrick, that's a much better idea.  Here's a patch to do just
that.

I left BPF_MSH alone because it's really a hack to calculate the IP
header length, which makes no sense when applied to the special data.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

BTW, you should be able to send me mail now.  Sorry about that.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/core/filter.c b/net/core/filter.c
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -182,7 +182,7 @@ int sk_run_filter(struct sk_buff *skb, s
 				A = ntohl(*(u32 *)ptr);
 				continue;
 			}
-			return 0;
+			break;
 		case BPF_LD|BPF_H|BPF_ABS:
 			k = fentry->k;
  load_h:
@@ -191,7 +191,7 @@ int sk_run_filter(struct sk_buff *skb, s
 				A = ntohs(*(u16 *)ptr);
 				continue;
 			}
-			return 0;
+			break;
 		case BPF_LD|BPF_B|BPF_ABS:
 			k = fentry->k;
 load_b:
@@ -200,7 +200,7 @@ load_b:
 				A = *(u8 *)ptr;
 				continue;
 			}
-			return 0;
+			break;
 		case BPF_LD|BPF_W|BPF_LEN:
 			A = skb->len;
 			continue;
