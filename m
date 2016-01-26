From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [PATCH 17/26] mac802154: Use skcipher
Date: Tue, 26 Jan 2016 17:55:02 +0100
Message-ID: <56A7A4E6.4090409@osg.samsung.com>
References: <20160124131021.GA31153@gondor.apana.org.au>
 <E1aNKZ8-0008EN-PU@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
To: Herbert Xu <herbert@gondor.apana.org.au>,
 Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 netdev@vger.kernel.org, devel@driverdev.osuosl.org, dm-devel@redhat.com,
 linux-wireless@vger.kernel.org, linux-cifs@vger.kernel.org,
 ecryptfs@vger.kernel.org, linux-ext4@vger.kernel.org,
 linux-f2fs-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org,
 keyrings@vger.kernel.org, linux-bluetooth@vger.kernel.org,
 ceph-devel@vger.kernel.org, linux-wpan@vger.kernel.org,
 linux-afs@lists.infradead.org, drbd-dev@lists.linbit.com,
 open-iscsi@googlegroups.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <E1aNKZ8-0008EN-PU@gondolin.me.apana.org.au>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Hello.

On 24/01/16 14:18, Herbert Xu wrote:
> This patch replaces uses of blkcipher with skcipher.
>     
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> ---
>
>   net/mac802154/llsec.c |   41 +++++++++++++++++++++++------------------
>   net/mac802154/llsec.h |    3 +--
>   2 files changed, 24 insertions(+), 20 deletions(-)
>
> diff --git a/net/mac802154/llsec.c b/net/mac802154/llsec.c
> index a13d02b..6a3e1c2 100644
> --- a/net/mac802154/llsec.c
> +++ b/net/mac802154/llsec.c
> @@ -17,9 +17,9 @@
>   #include <linux/err.h>
>   #include <linux/bug.h>
>   #include <linux/completion.h>
> -#include <linux/crypto.h>
>   #include <linux/ieee802154.h>
>   #include <crypto/aead.h>
> +#include <crypto/skcipher.h>
>   
>   #include "ieee802154_i.h"
>   #include "llsec.h"
> @@ -144,18 +144,18 @@ llsec_key_alloc(const struct ieee802154_llsec_key *template)
>   			goto err_tfm;
>   	}
>   
> -	key->tfm0 = crypto_alloc_blkcipher("ctr(aes)", 0, CRYPTO_ALG_ASYNC);
> +	key->tfm0 = crypto_alloc_skcipher("ctr(aes)", 0, CRYPTO_ALG_ASYNC);
>   	if (IS_ERR(key->tfm0))
>   		goto err_tfm;
>   
> -	if (crypto_blkcipher_setkey(key->tfm0, template->key,
> -				    IEEE802154_LLSEC_KEY_SIZE))
> +	if (crypto_skcipher_setkey(key->tfm0, template->key,
> +				   IEEE802154_LLSEC_KEY_SIZE))
>   		goto err_tfm0;
>   
>   	return key;
>   
>   err_tfm0:
> -	crypto_free_blkcipher(key->tfm0);
> +	crypto_free_skcipher(key->tfm0);
>   err_tfm:
>   	for (i = 0; i < ARRAY_SIZE(key->tfm); i++)
>   		if (key->tfm[i])
> @@ -175,7 +175,7 @@ static void llsec_key_release(struct kref *ref)
>   	for (i = 0; i < ARRAY_SIZE(key->tfm); i++)
>   		crypto_free_aead(key->tfm[i]);
>   
> -	crypto_free_blkcipher(key->tfm0);
> +	crypto_free_skcipher(key->tfm0);
>   	kzfree(key);
>   }
>   
> @@ -620,15 +620,17 @@ llsec_do_encrypt_unauth(struct sk_buff *skb, const struct mac802154_llsec *sec,
>   {
>   	u8 iv[16];
>   	struct scatterlist src;
> -	struct blkcipher_desc req = {
> -		.tfm = key->tfm0,
> -		.info = iv,
> -		.flags = 0,
> -	};
> +	SKCIPHER_REQUEST_ON_STACK(req, key->tfm0);
> +	int err;
>   
>   	llsec_geniv(iv, sec->params.hwaddr, &hdr->sec);
>   	sg_init_one(&src, skb->data, skb->len);
> -	return crypto_blkcipher_encrypt_iv(&req, &src, &src, skb->len);
> +	skcipher_request_set_tfm(req, key->tfm0);
> +	skcipher_request_set_callback(req, 0, NULL, NULL);
> +	skcipher_request_set_crypt(req, &src, &src, skb->len, iv);
> +	err = crypto_skcipher_encrypt(req);
> +	skcipher_request_zero(req);
> +	return err;
>   }
>   
>   static struct crypto_aead*
> @@ -830,11 +832,8 @@ llsec_do_decrypt_unauth(struct sk_buff *skb, const struct mac802154_llsec *sec,
>   	unsigned char *data;
>   	int datalen;
>   	struct scatterlist src;
> -	struct blkcipher_desc req = {
> -		.tfm = key->tfm0,
> -		.info = iv,
> -		.flags = 0,
> -	};
> +	SKCIPHER_REQUEST_ON_STACK(req, key->tfm0);
> +	int err;
>   
>   	llsec_geniv(iv, dev_addr, &hdr->sec);
>   	data = skb_mac_header(skb) + skb->mac_len;
> @@ -842,7 +841,13 @@ llsec_do_decrypt_unauth(struct sk_buff *skb, const struct mac802154_llsec *sec,
>   
>   	sg_init_one(&src, data, datalen);
>   
> -	return crypto_blkcipher_decrypt_iv(&req, &src, &src, datalen);
> +	skcipher_request_set_tfm(req, key->tfm0);
> +	skcipher_request_set_callback(req, 0, NULL, NULL);
> +	skcipher_request_set_crypt(req, &src, &src, datalen, iv);
> +
> +	err = crypto_skcipher_decrypt(req);
> +	skcipher_request_zero(req);
> +	return err;
>   }
>   
>   static int
> diff --git a/net/mac802154/llsec.h b/net/mac802154/llsec.h
> index 950578e..6f3b658 100644
> --- a/net/mac802154/llsec.h
> +++ b/net/mac802154/llsec.h
> @@ -19,7 +19,6 @@
>   
>   #include <linux/slab.h>
>   #include <linux/hashtable.h>
> -#include <linux/crypto.h>
>   #include <linux/kref.h>
>   #include <linux/spinlock.h>
>   #include <net/af_ieee802154.h>
> @@ -30,7 +29,7 @@ struct mac802154_llsec_key {
>   
>   	/* one tfm for each authsize (4/8/16) */
>   	struct crypto_aead *tfm[3];
> -	struct crypto_blkcipher *tfm0;
> +	struct crypto_skcipher *tfm0;
>   
>   	struct kref ref;
>   };

Reviewed-by: Stefan Schmidt <stefan@osg.samsung.com>

regards
Stefan Schmidt
