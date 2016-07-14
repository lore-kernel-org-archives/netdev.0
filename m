From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v5 01/32] bluetooth: Switch SMP to crypto_cipher_encrypt_one()
Date: Thu, 14 Jul 2016 12:10:45 -0700
Message-ID: <CALCETrXYNM_b41J30eSuuhKtPRUANFpTh6bfuHM4-_RYGuZbZw@mail.gmail.com>
References: <cover.1468270393.git.luto@kernel.org> <264af59a3060c2bc2a725cfc66a8fa68219d1c4a.1468270393.git.luto@kernel.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: X86 ML <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>,
	Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>,
	Brian Gerst <brgerst@gmail.com>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
	Linus Torvalds <torvalds@linux-foundation.org>, Josh Poimboeuf <jpoimboe@redhat.com>,
	Jann Horn <jann@thejh.net>, Heiko Carstens <heiko.carstens@de.ibm.com>,
	Marcel Holtmann <marcel@holtmann.org>, Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>, linux-bluetooth@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@kernel.org>, "David S. Miller" <davem@davemloft.net>
Return-path: <kernel-hardening-return-3980-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <264af59a3060c2bc2a725cfc66a8fa68219d1c4a.1468270393.git.luto@kernel.org>
List-Id: netdev.vger.kernel.org

On Mon, Jul 11, 2016 at 1:53 PM, Andy Lutomirski <luto@kernel.org> wrote:
> SMP does ECB crypto on stack buffers.  This is complicated and
> fragile, and it will not work if the stack is virtually allocated.
>
> Switch to the crypto_cipher interface, which is simpler and safer.

Hi Dave-

It looks like we're delaying virtually mapped stacks to 4.9.  That
means that there's time for this to go in through net-next.  Could you
queue it up?

--Andy

>
> Cc: Marcel Holtmann <marcel@holtmann.org>
> Cc: Gustavo Padovan <gustavo@padovan.org>
> Cc: Johan Hedberg <johan.hedberg@gmail.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: linux-bluetooth@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> Acked-and-tested-by: Johan Hedberg <johan.hedberg@intel.com>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  net/bluetooth/smp.c | 67 ++++++++++++++++++++++-------------------------------
>  1 file changed, 28 insertions(+), 39 deletions(-)
>
> diff --git a/net/bluetooth/smp.c b/net/bluetooth/smp.c
> index 50976a6481f3..4c1a16a96ae5 100644
> --- a/net/bluetooth/smp.c
> +++ b/net/bluetooth/smp.c
> @@ -22,9 +22,9 @@
>
>  #include <linux/debugfs.h>
>  #include <linux/scatterlist.h>
> +#include <linux/crypto.h>
>  #include <crypto/b128ops.h>
>  #include <crypto/hash.h>
> -#include <crypto/skcipher.h>
>
>  #include <net/bluetooth/bluetooth.h>
>  #include <net/bluetooth/hci_core.h>
> @@ -88,7 +88,7 @@ struct smp_dev {
>         u8                      min_key_size;
>         u8                      max_key_size;
>
> -       struct crypto_skcipher  *tfm_aes;
> +       struct crypto_cipher    *tfm_aes;
>         struct crypto_shash     *tfm_cmac;
>  };
>
> @@ -127,7 +127,7 @@ struct smp_chan {
>         u8                      dhkey[32];
>         u8                      mackey[16];
>
> -       struct crypto_skcipher  *tfm_aes;
> +       struct crypto_cipher    *tfm_aes;
>         struct crypto_shash     *tfm_cmac;
>  };
>
> @@ -361,10 +361,8 @@ static int smp_h6(struct crypto_shash *tfm_cmac, const u8 w[16],
>   * s1 and ah.
>   */
>
> -static int smp_e(struct crypto_skcipher *tfm, const u8 *k, u8 *r)
> +static int smp_e(struct crypto_cipher *tfm, const u8 *k, u8 *r)
>  {
> -       SKCIPHER_REQUEST_ON_STACK(req, tfm);
> -       struct scatterlist sg;
>         uint8_t tmp[16], data[16];
>         int err;
>
> @@ -378,7 +376,7 @@ static int smp_e(struct crypto_skcipher *tfm, const u8 *k, u8 *r)
>         /* The most significant octet of key corresponds to k[0] */
>         swap_buf(k, tmp, 16);
>
> -       err = crypto_skcipher_setkey(tfm, tmp, 16);
> +       err = crypto_cipher_setkey(tfm, tmp, 16);
>         if (err) {
>                 BT_ERR("cipher setkey failed: %d", err);
>                 return err;
> @@ -387,16 +385,7 @@ static int smp_e(struct crypto_skcipher *tfm, const u8 *k, u8 *r)
>         /* Most significant octet of plaintextData corresponds to data[0] */
>         swap_buf(r, data, 16);
>
> -       sg_init_one(&sg, data, 16);
> -
> -       skcipher_request_set_tfm(req, tfm);
> -       skcipher_request_set_callback(req, 0, NULL, NULL);
> -       skcipher_request_set_crypt(req, &sg, &sg, 16, NULL);
> -
> -       err = crypto_skcipher_encrypt(req);
> -       skcipher_request_zero(req);
> -       if (err)
> -               BT_ERR("Encrypt data error %d", err);
> +       crypto_cipher_encrypt_one(tfm, data, data);
>
>         /* Most significant octet of encryptedData corresponds to data[0] */
>         swap_buf(data, r, 16);
> @@ -406,7 +395,7 @@ static int smp_e(struct crypto_skcipher *tfm, const u8 *k, u8 *r)
>         return err;
>  }
>
> -static int smp_c1(struct crypto_skcipher *tfm_aes, const u8 k[16],
> +static int smp_c1(struct crypto_cipher *tfm_aes, const u8 k[16],
>                   const u8 r[16], const u8 preq[7], const u8 pres[7], u8 _iat,
>                   const bdaddr_t *ia, u8 _rat, const bdaddr_t *ra, u8 res[16])
>  {
> @@ -455,7 +444,7 @@ static int smp_c1(struct crypto_skcipher *tfm_aes, const u8 k[16],
>         return err;
>  }
>
> -static int smp_s1(struct crypto_skcipher *tfm_aes, const u8 k[16],
> +static int smp_s1(struct crypto_cipher *tfm_aes, const u8 k[16],
>                   const u8 r1[16], const u8 r2[16], u8 _r[16])
>  {
>         int err;
> @@ -471,7 +460,7 @@ static int smp_s1(struct crypto_skcipher *tfm_aes, const u8 k[16],
>         return err;
>  }
>
> -static int smp_ah(struct crypto_skcipher *tfm, const u8 irk[16],
> +static int smp_ah(struct crypto_cipher *tfm, const u8 irk[16],
>                   const u8 r[3], u8 res[3])
>  {
>         u8 _res[16];
> @@ -759,7 +748,7 @@ static void smp_chan_destroy(struct l2cap_conn *conn)
>         kzfree(smp->slave_csrk);
>         kzfree(smp->link_key);
>
> -       crypto_free_skcipher(smp->tfm_aes);
> +       crypto_free_cipher(smp->tfm_aes);
>         crypto_free_shash(smp->tfm_cmac);
>
>         /* Ensure that we don't leave any debug key around if debug key
> @@ -1359,9 +1348,9 @@ static struct smp_chan *smp_chan_create(struct l2cap_conn *conn)
>         if (!smp)
>                 return NULL;
>
> -       smp->tfm_aes = crypto_alloc_skcipher("ecb(aes)", 0, CRYPTO_ALG_ASYNC);
> +       smp->tfm_aes = crypto_alloc_cipher("aes", 0, CRYPTO_ALG_ASYNC);
>         if (IS_ERR(smp->tfm_aes)) {
> -               BT_ERR("Unable to create ECB crypto context");
> +               BT_ERR("Unable to create AES crypto context");
>                 kzfree(smp);
>                 return NULL;
>         }
> @@ -1369,7 +1358,7 @@ static struct smp_chan *smp_chan_create(struct l2cap_conn *conn)
>         smp->tfm_cmac = crypto_alloc_shash("cmac(aes)", 0, 0);
>         if (IS_ERR(smp->tfm_cmac)) {
>                 BT_ERR("Unable to create CMAC crypto context");
> -               crypto_free_skcipher(smp->tfm_aes);
> +               crypto_free_cipher(smp->tfm_aes);
>                 kzfree(smp);
>                 return NULL;
>         }
> @@ -3120,7 +3109,7 @@ static struct l2cap_chan *smp_add_cid(struct hci_dev *hdev, u16 cid)
>  {
>         struct l2cap_chan *chan;
>         struct smp_dev *smp;
> -       struct crypto_skcipher *tfm_aes;
> +       struct crypto_cipher *tfm_aes;
>         struct crypto_shash *tfm_cmac;
>
>         if (cid == L2CAP_CID_SMP_BREDR) {
> @@ -3132,9 +3121,9 @@ static struct l2cap_chan *smp_add_cid(struct hci_dev *hdev, u16 cid)
>         if (!smp)
>                 return ERR_PTR(-ENOMEM);
>
> -       tfm_aes = crypto_alloc_skcipher("ecb(aes)", 0, CRYPTO_ALG_ASYNC);
> +       tfm_aes = crypto_alloc_cipher("aes", 0, CRYPTO_ALG_ASYNC);
>         if (IS_ERR(tfm_aes)) {
> -               BT_ERR("Unable to create ECB crypto context");
> +               BT_ERR("Unable to create AES crypto context");
>                 kzfree(smp);
>                 return ERR_CAST(tfm_aes);
>         }
> @@ -3142,7 +3131,7 @@ static struct l2cap_chan *smp_add_cid(struct hci_dev *hdev, u16 cid)
>         tfm_cmac = crypto_alloc_shash("cmac(aes)", 0, 0);
>         if (IS_ERR(tfm_cmac)) {
>                 BT_ERR("Unable to create CMAC crypto context");
> -               crypto_free_skcipher(tfm_aes);
> +               crypto_free_cipher(tfm_aes);
>                 kzfree(smp);
>                 return ERR_CAST(tfm_cmac);
>         }
> @@ -3156,7 +3145,7 @@ create_chan:
>         chan = l2cap_chan_create();
>         if (!chan) {
>                 if (smp) {
> -                       crypto_free_skcipher(smp->tfm_aes);
> +                       crypto_free_cipher(smp->tfm_aes);
>                         crypto_free_shash(smp->tfm_cmac);
>                         kzfree(smp);
>                 }
> @@ -3203,7 +3192,7 @@ static void smp_del_chan(struct l2cap_chan *chan)
>         smp = chan->data;
>         if (smp) {
>                 chan->data = NULL;
> -               crypto_free_skcipher(smp->tfm_aes);
> +               crypto_free_cipher(smp->tfm_aes);
>                 crypto_free_shash(smp->tfm_cmac);
>                 kzfree(smp);
>         }
> @@ -3440,7 +3429,7 @@ void smp_unregister(struct hci_dev *hdev)
>
>  #if IS_ENABLED(CONFIG_BT_SELFTEST_SMP)
>
> -static int __init test_ah(struct crypto_skcipher *tfm_aes)
> +static int __init test_ah(struct crypto_cipher *tfm_aes)
>  {
>         const u8 irk[16] = {
>                         0x9b, 0x7d, 0x39, 0x0a, 0xa6, 0x10, 0x10, 0x34,
> @@ -3460,7 +3449,7 @@ static int __init test_ah(struct crypto_skcipher *tfm_aes)
>         return 0;
>  }
>
> -static int __init test_c1(struct crypto_skcipher *tfm_aes)
> +static int __init test_c1(struct crypto_cipher *tfm_aes)
>  {
>         const u8 k[16] = {
>                         0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
> @@ -3490,7 +3479,7 @@ static int __init test_c1(struct crypto_skcipher *tfm_aes)
>         return 0;
>  }
>
> -static int __init test_s1(struct crypto_skcipher *tfm_aes)
> +static int __init test_s1(struct crypto_cipher *tfm_aes)
>  {
>         const u8 k[16] = {
>                         0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
> @@ -3686,7 +3675,7 @@ static const struct file_operations test_smp_fops = {
>         .llseek         = default_llseek,
>  };
>
> -static int __init run_selftests(struct crypto_skcipher *tfm_aes,
> +static int __init run_selftests(struct crypto_cipher *tfm_aes,
>                                 struct crypto_shash *tfm_cmac)
>  {
>         ktime_t calltime, delta, rettime;
> @@ -3764,27 +3753,27 @@ done:
>
>  int __init bt_selftest_smp(void)
>  {
> -       struct crypto_skcipher *tfm_aes;
> +       struct crypto_cipher *tfm_aes;
>         struct crypto_shash *tfm_cmac;
>         int err;
>
> -       tfm_aes = crypto_alloc_skcipher("ecb(aes)", 0, CRYPTO_ALG_ASYNC);
> +       tfm_aes = crypto_alloc_cipher("aes", 0, CRYPTO_ALG_ASYNC);
>         if (IS_ERR(tfm_aes)) {
> -               BT_ERR("Unable to create ECB crypto context");
> +               BT_ERR("Unable to create AES crypto context");
>                 return PTR_ERR(tfm_aes);
>         }
>
>         tfm_cmac = crypto_alloc_shash("cmac(aes)", 0, CRYPTO_ALG_ASYNC);
>         if (IS_ERR(tfm_cmac)) {
>                 BT_ERR("Unable to create CMAC crypto context");
> -               crypto_free_skcipher(tfm_aes);
> +               crypto_free_cipher(tfm_aes);
>                 return PTR_ERR(tfm_cmac);
>         }
>
>         err = run_selftests(tfm_aes, tfm_cmac);
>
>         crypto_free_shash(tfm_cmac);
> -       crypto_free_skcipher(tfm_aes);
> +       crypto_free_cipher(tfm_aes);
>
>         return err;
>  }
> --
> 2.7.4
>



-- 
Andy Lutomirski
AMA Capital Management, LLC
