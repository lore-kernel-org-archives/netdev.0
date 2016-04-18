From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] macsec: fix crypto Kconfig dependency
Date: Mon, 18 Apr 2016 12:23:42 +0200
Message-ID: <11585265.Dbvl2xi4u3@wuerfel>
References: <20160418080202.GA18155@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, sd@queasysnail.net,
	hannes@stressinduktion.org, johannes@sipsolutions.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160418080202.GA18155@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 18 April 2016 16:02:02 Herbert Xu wrote:
> Arnd Bergmann <arnd@arndb.de> wrote:
> > The new MACsec driver uses the AES crypto algorithm, but can be configured
> > even if CONFIG_CRYPTO is disabled, leading to a build error:
> > 
> > warning: (MAC80211 && MACSEC) selects CRYPTO_GCM which has unmet direct dependencies (CRYPTO)
> > warning: (BT && CEPH_LIB && INET && MAC802154 && MAC80211 && BLK_DEV_RBD && MACSEC && AIRO_CS && LIBIPW && HOSTAP && USB_WUSB && RTLLIB_CRYPTO_CCMP && FS_ENCRYPTION && EXT4_ENCRYPTION && CEPH_FS && BIG_KEYS && ENCRYPTED_KEYS) selects CRYPTO_AES which has unmet direct dependencies (CRYPTO)
> > crypto/built-in.o: In function `gcm_enc_copy_hash':
> > aes_generic.c:(.text+0x2b8): undefined reference to `crypto_xor'
> > aes_generic.c:(.text+0x2dc): undefined reference to `scatterwalk_map_and_copy'
> > 
> > This adds an explicit 'select CRYPTO' statement the way that other
> > drivers handle it.
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
> 
> Thnis patch is bogus.  The build error is coming from the fact
> that GCM is built-in but CRYPTO_ALGAPI is (presumably) only built
> as a module.  The patch in question does nothing to address that
> AFAICS.

No, that is not the problem.

These are the options from the randconfig file that showed the error:

# CONFIG_MODULES is not set
# CONFIG_CRYPTO is not set
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_AES=y
CONFIG_MACSEC=y
# CONFIG_CFG80211 is not set

As you can see, none of them are modules, and CRYPTO is completely
disabled.

> In fact this strikes me as a kbuild bug because CRYPTO_GCM already
> selects (indirectly) CRYPTO_ALGAPI so why is this happening at all?

As I tried to explain, the first two lines of the output show that
CRYPTO_GCM and CRYPTO_AES got 'select'ed while its dependencies (CRYPTO)
is not met, meaning this is the result of an incorrect Kconfig file.

Kconfig (the tool) at this point gives up, and intentionally ignores
all 'select' statements from the symbols that were wrongly selected.
I believe this is a reasonable failure mode, as following the other
selects tends to cause more problems than it solves.

As far as I can tell, my patch is correct and follows the model used by
the CONFIG_MAC80211. See below for the full output that I truncated
in order to make the changelog message more readable.

	Arnd

----
[1]
warning: (MAC80211 && MACSEC) selects CRYPTO_GCM which has unmet direct dependencies (CRYPTO)
warning: (BT && CEPH_LIB && INET && MAC802154 && MAC80211 && BLK_DEV_RBD && MACSEC && AIRO_CS && LIBIPW && HOSTAP && USB_WUSB && RTLLIB_CRYPTO_CCMP && FS_ENCRYPTION && EXT4_ENCRYPTION && CEPH_FS && BIG_KEYS && ENCRYPTED_KEYS) selects CRYPTO_AES which has unmet direct dependencies (CRYPTO)
warning: (MAC80211 && MACSEC) selects CRYPTO_GCM which has unmet direct dependencies (CRYPTO)
warning: (BT && CEPH_LIB && INET && MAC802154 && MAC80211 && BLK_DEV_RBD && MACSEC && AIRO_CS && LIBIPW && HOSTAP && USB_WUSB && RTLLIB_CRYPTO_CCMP && FS_ENCRYPTION && EXT4_ENCRYPTION && CEPH_FS && BIG_KEYS && ENCRYPTED_KEYS) selects CRYPTO_AES which has unmet direct dependencies (CRYPTO)
crypto/built-in.o: In function `gcm_enc_copy_hash':
aes_generic.c:(.text+0x2b8): undefined reference to `crypto_xor'
aes_generic.c:(.text+0x2dc): undefined reference to `scatterwalk_map_and_copy'
crypto/built-in.o: In function `crypto_gcm_verify':
aes_generic.c:(.text+0x328): undefined reference to `crypto_xor'
aes_generic.c:(.text+0x34c): undefined reference to `scatterwalk_map_and_copy'
aes_generic.c:(.text+0x35c): undefined reference to `__crypto_memneq'
crypto/built-in.o: In function `crypto_gcm_init_common':
aes_generic.c:(.text+0x520): undefined reference to `scatterwalk_ffwd'
aes_generic.c:(.text+0x5dc): undefined reference to `scatterwalk_ffwd'
crypto/built-in.o: In function `crypto_rfc4106_crypt':
aes_generic.c:(.text+0x668): undefined reference to `scatterwalk_map_and_copy'
aes_generic.c:(.text+0x750): undefined reference to `scatterwalk_ffwd'
aes_generic.c:(.text+0x81c): undefined reference to `scatterwalk_ffwd'
crypto/built-in.o: In function `gcm_hash_crypt_remain_continue':
aes_generic.c:(.text+0x9c4): undefined reference to `crypto_ahash_finup'
crypto/built-in.o: In function `crypto_gcm_exit_tfm':
aes_generic.c:(.text+0xba8): undefined reference to `crypto_destroy_tfm'
aes_generic.c:(.text+0xbb8): undefined reference to `crypto_destroy_tfm'
crypto/built-in.o: In function `crypto_rfc4106_exit_tfm':
aes_generic.c:(.text+0xbc4): undefined reference to `crypto_destroy_tfm'
crypto/built-in.o: In function `crypto_rfc4106_init_tfm':
aes_generic.c:(.text+0xbd8): undefined reference to `crypto_spawn_tfm2'
crypto/built-in.o: In function `crypto_gcm_init_tfm':
aes_generic.c:(.text+0xc24): undefined reference to `crypto_spawn_tfm2'
aes_generic.c:(.text+0xc44): undefined reference to `crypto_spawn_tfm'
aes_generic.c:(.text+0xc9c): undefined reference to `crypto_destroy_tfm'
crypto/built-in.o: In function `crypto_gcm_setkey':
aes_generic.c:(.text+0xdf8): undefined reference to `crypto_ahash_setkey'
crypto/built-in.o: In function `crypto_gcm_free':
aes_generic.c:(.text+0xe48): undefined reference to `crypto_drop_spawn'
aes_generic.c:(.text+0xe50): undefined reference to `crypto_drop_spawn'
crypto/built-in.o: In function `crypto_rfc4543_free':
aes_generic.c:(.text+0xe6c): undefined reference to `crypto_drop_spawn'
crypto/built-in.o: In function `crypto_gcm_create_common':
aes_generic.c:(.text+0xe98): undefined reference to `crypto_get_attr_type'
aes_generic.c:(.text+0xed4): undefined reference to `crypto_find_alg'
aes_generic.c:(.text+0xf1c): undefined reference to `crypto_init_ahash_spawn'
aes_generic.c:(.text+0xf60): undefined reference to `crypto_grab_skcipher'
aes_generic.c:(.text+0x1060): undefined reference to `aead_register_instance'
aes_generic.c:(.text+0x1070): undefined reference to `crypto_mod_put'
aes_generic.c:(.text+0x1084): undefined reference to `crypto_drop_spawn'
aes_generic.c:(.text+0x108c): undefined reference to `crypto_drop_spawn'
aes_generic.c:(.text+0x109c): undefined reference to `crypto_ahash_type'
crypto/built-in.o: In function `crypto_gcm_base_create':
aes_generic.c:(.text+0x10dc): undefined reference to `crypto_attr_alg_name'
aes_generic.c:(.text+0x10f0): undefined reference to `crypto_attr_alg_name'
crypto/built-in.o: In function `crypto_gcm_create':
aes_generic.c:(.text+0x115c): undefined reference to `crypto_attr_alg_name'
crypto/built-in.o: In function `crypto_rfc4106_create':
aes_generic.c:(.text+0x11ec): undefined reference to `crypto_get_attr_type'
aes_generic.c:(.text+0x121c): undefined reference to `crypto_attr_alg_name'
aes_generic.c:(.text+0x1274): undefined reference to `crypto_grab_aead'
aes_generic.c:(.text+0x12c0): undefined reference to `crypto_drop_spawn'
aes_generic.c:(.text+0x1360): undefined reference to `aead_register_instance'
crypto/built-in.o: In function `crypto_rfc4543_create':
aes_generic.c:(.text+0x13b4): undefined reference to `crypto_get_attr_type'
aes_generic.c:(.text+0x13e4): undefined reference to `crypto_attr_alg_name'
aes_generic.c:(.text+0x143c): undefined reference to `crypto_grab_aead'
aes_generic.c:(.text+0x1488): undefined reference to `crypto_drop_spawn'
aes_generic.c:(.text+0x1528): undefined reference to `aead_register_instance'
crypto/built-in.o: In function `crypto_rfc4106_setauthsize':
aes_generic.c:(.text+0x1588): undefined reference to `crypto_aead_setauthsize'
crypto/built-in.o: In function `crypto_rfc4543_setauthsize':
aes_generic.c:(.text+0x15a0): undefined reference to `crypto_aead_setauthsize'
crypto/built-in.o: In function `crypto_rfc4106_setkey':
aes_generic.c:(.text+0x1608): undefined reference to `crypto_aead_setkey'
crypto/built-in.o: In function `crypto_rfc4543_setkey':
aes_generic.c:(.text+0x1690): undefined reference to `crypto_aead_setkey'
crypto/built-in.o: In function `crypto_rfc4543_exit_tfm':
aes_generic.c:(.text+0x16c8): undefined reference to `crypto_destroy_tfm'
aes_generic.c:(.text+0x16d0): undefined reference to `crypto_put_default_null_skcipher'
crypto/built-in.o: In function `crypto_rfc4543_init_tfm':
aes_generic.c:(.text+0x16e4): undefined reference to `crypto_spawn_tfm2'
aes_generic.c:(.text+0x16f8): undefined reference to `crypto_get_default_null_skcipher'
aes_generic.c:(.text+0x1744): undefined reference to `crypto_destroy_tfm'
crypto/built-in.o: In function `crypto_gcm_module_init':
aes_generic.c:(.init.text+0x40): undefined reference to `crypto_register_template'
aes_generic.c:(.init.text+0x50): undefined reference to `crypto_register_template'
aes_generic.c:(.init.text+0x60): undefined reference to `crypto_register_template'
aes_generic.c:(.init.text+0x70): undefined reference to `crypto_register_template'
aes_generic.c:(.init.text+0x80): undefined reference to `crypto_unregister_template'
aes_generic.c:(.init.text+0x88): undefined reference to `crypto_unregister_template'
aes_generic.c:(.init.text+0x90): undefined reference to `crypto_unregister_template'
crypto/built-in.o: In function `aes_init':
aes_generic.c:(.init.text+0xc4): undefined reference to `crypto_register_alg'
drivers/net/built-in.o: In function `free_rxsa':
dlci.c:(.text+0xebc): undefined reference to `crypto_destroy_tfm'
drivers/net/built-in.o: In function `free_txsa':
dlci.c:(.text+0xeec): undefined reference to `crypto_destroy_tfm'
drivers/net/built-in.o: In function `macsec_alloc_tfm':
dlci.c:(.text+0x2418): undefined reference to `crypto_alloc_aead'
dlci.c:(.text+0x2434): undefined reference to `crypto_aead_setkey'
dlci.c:(.text+0x2448): undefined reference to `crypto_destroy_tfm'
dlci.c:(.text+0x245c): undefined reference to `crypto_aead_setauthsize'
make[2]: *** [vmlinux] Error 1
make[2]: Target `_all' not remade because of errors.
make[1]: *** [sub-make] Error 2
make[1]: Target `_all' not remade because of errors.
