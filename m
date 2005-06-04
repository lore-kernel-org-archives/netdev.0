From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Sat, 4 Jun 2005 14:17:31 +0400
Message-ID: <20050604141731.37479347@zanzibar.2ka.mipt.ru>
References: <20050603234623.GA20088@gondor.apana.org.au>
	<20050604135535.3cfb631f@zanzibar.2ka.mipt.ru>
	<20050604095854.GA1003@gondor.apana.org.au>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        James Morris
 <jmorris@redhat.com>,
        Linux Crypto Mailing List
 <linux-crypto@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050604095854.GA1003@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 4 Jun 2005 19:58:54 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Sat, Jun 04, 2005 at 01:55:35PM +0400, Evgeniy Polyakov wrote:
> > 
> > processing code. And you can not easily move away of SA lock due to
> > synchronous problems with the same tfm.
> 
> This is not true.  The tfm context contains no shared state apart
> from the IV.  As the IV can be specified through the *_iv functions,
> this allows crypto API users to process the same cipher tfm on two
> CPUs in parallel.
> 
> If you don't believe me just wait for my upcoming patches to IPsec.

Sure I believe you, in tfm there are no shared objects except data.
But can we catch the situation when we encrypting the same skb?
As far as I can see skb_cow_data() must take care of it.

You are right, encrypting is safe.

Here is part of esp_output() I use for acrypto.
Static scaterlists are not used and new are dinamically allocated.

@@ -95,7 +239,90 @@
 
 	esph->spi = x->id.spi;
 	esph->seq_no = htonl(++x->replay.oseq);
+	
+#ifdef CONFIG_ACRYPTO
+	do {
+		struct crypto_session_initializer ci;
+		struct crypto_data data;
+		struct scatterlist *sg;
+		struct crypto_session *s;
+		u8 *key, *iv;
+		
+		nfrags++; /* key */
+		
+		if (esp->conf.ivlen)
+			nfrags++;
 
+		memset(&ci, 0, sizeof(ci));
+		memset(&data, 0, sizeof(data));
+
+		ci.operation 	= CRYPTO_OP_ENCRYPT;
+		ci.mode 	= crypto_tfm_get_mode(tfm);
+		ci.type 	= crypto_tfm_get_type(tfm);
+		ci.priority 	= 0;
+		ci.callback 	= &esp4_async_callback;
+		
+		if (ci.mode == 0xffff || ci.type == 0xffff)
+			goto sync_crypto;
+
+		sg = kmalloc(sizeof(struct scatterlist)*nfrags, GFP_ATOMIC);
+		if (!sg)
+			goto error;
+		skb_to_sgvec(skb, sg, esph->enc_data+esp->conf.ivlen-skb->data, clen);
+		data.sg_src = data.sg_dst = sg;
+
+		key = kmalloc(crypto_tfm_alg_ivsize(tfm) + esp->conf.key_len, GFP_ATOMIC);
+		if (!key)
+			goto err_out_free_sg;
+
+		iv = key + esp->conf.key_len;
+		
+		if (esp->conf.ivlen) {
+			data.sg_key = &sg[nfrags - 2];
+			data.sg_iv = &sg[nfrags - 1];
+			data.sg_key_num = data.sg_iv_num = 1;
+		} else {
+			data.sg_key = &sg[nfrags - 1];
+			data.sg_iv = NULL;
+			data.sg_key_num = 1;
+			data.sg_iv_num = 0;
+		}
+
+		data.sg_src_num = data.sg_dst_num = nfrags - data.sg_key_num - data.sg_iv_num;
+		
+		memcpy(key, esp->conf.key, esp->conf.key_len);
+		data.sg_key[0].offset = offset_in_page(key);
+		data.sg_key[0].length = esp->conf.key_len;
+		data.sg_key[0].page = virt_to_page(key);
+		
+		if (esp->conf.ivlen) {
+			memcpy(iv, esp->conf.ivec, crypto_tfm_alg_ivsize(tfm));
+			data.sg_iv[0].offset = offset_in_page(iv);
+			data.sg_iv[0].length = crypto_tfm_alg_ivsize(tfm);
+			data.sg_iv[0].page = virt_to_page(iv);
+		}
+
+		data.priv = esp_output_async_prepare(x, skb);
+		if (!data.priv)
+			goto err_out_free_key;
+
+		s = crypto_session_alloc(&ci, &data);
+		if (!s)
+			goto err_out_free_ea;
+
+		return 0;
+
+err_out_free_ea:
+		kfree(data.priv);
+err_out_free_key:
+		kfree(key);
+err_out_free_sg:
+		kfree(sg);
+		goto sync_crypto;
+	} while (0);
+	
+sync_crypto:
+#endif
 	if (esp->conf.ivlen)
 		crypto_cipher_set_iv(tfm, esp->conf.ivec, crypto_tfm_alg_ivsize(tfm));
 


> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt


	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt
