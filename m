From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [v3 PATCH 0/8] crypto: Convert all AEAD users to new interface
Date: Wed, 27 May 2015 11:25:33 +0200
Message-ID: <20150527092533.GC27342@secunet.com>
References: <20150521103938.GA23035@gondor.apana.org.au>
 <20150522082708.GA3507@gondor.apana.org.au>
 <20150527080105.GA26751@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	<netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Stephan Mueller <smueller@chronox.de>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150527080105.GA26751@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 27, 2015 at 04:01:05PM +0800, Herbert Xu wrote:
> Hi:
> 
> The only changes from the last version are that set_ad no longer
> takes a cryptoff argument and testmgr has been updated to always
> supply space for the authentication tag.
> 
> The algif_aead patch has been removed and will be posted separately.
> 
> Series description:
> 
> This series of patches convert all in-tree AEAD users that I
> could find to the new single SG list interface.  For IPsec it
> also adopts the new explicit IV generator scheme.
> 
> To recap, the old AEAD interface takes an associated data (AD)
> SG list in addition to the plain/cipher text SG list(s).  That
> forces the underlying AEAD algorithm implementors to try to stitch
> those two lists together where possible in order to maximise the
> contiguous chunk of memory passed to the ICV/hash function.  Things
> get even more hairy for IPsec as it has a third piece of memory,
> the generated IV (giv) that needs to be hashed.  One look at the
> nasty things authenc does for example is enough to make anyone
> puke :)
> 
> In fact the interface is just getting in our way because for the
> main user IPsec the data is naturally contiguous as the protocol
> was designed with this in mind.
> 
> So the new AEAD interface gets rid of the separate AD SG list
> and instead simply requires the AD to be at the head of the src
> and dst SG lists.
> 
> The conversion of in-tree users is fairly straightforward.  The
> only non-trivial bit is IPsec as I'm taking this opportunity to
> move the IV generation knowledge into IPsec as that's where it
> belongs since we may in future wish to support different generation
> schemes for a single algorithm.

Not sure if I missed something in the flood of patches, but if I
apply your v3 patchset on top of the cryptodev tree, it crashes
like that buring boot:

[    4.668297] ------------[ cut here ]------------
[    4.669143] kernel BUG at /home/klassert/git/linux-stk/include/linux/scatterlist.h:67!
[    4.670457] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[    4.671595] CPU: 0 PID: 1363 Comm: cryptomgr_test Not tainted 4.0.0+ #951
[    4.672025] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
[    4.672025] task: ce9e7300 ti: ceb54000 task.ti: ceb54000
[    4.672025] EIP: 0060:[<c11d45b5>] EFLAGS: 00010206 CPU: 0
[    4.672025] EIP is at scatterwalk_ffwd+0xf5/0x100
[    4.672025] EAX: ceb43b20 EBX: ceb55c94 ECX: 00000014 EDX: c11db23f
[    4.672025] ESI: 00000010 EDI: 00000003 EBP: ceb55c7c ESP: ceb55c6c
[    4.672025]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[    4.672025] CR0: 8005003b CR2: bfbb6fc0 CR3: 0eb26000 CR4: 000006d0
[    4.672025] Stack:
[    4.672025]  cffd28c0 00000014 ceb35400 cea33618 ceb55cd0 c11d45e8 ceb43b20 00000000
[    4.672025]  ceb35438 c11db220 ceb55c9c c11db23f ceb55cac c11da470 ceb35438 ceb353c8
[    4.672025]  ceb55cb4 c11da763 ceb55cd0 c11f2c6f ceb35400 00000200 ceb35358 ceb353c8
[    4.672025] Call Trace:
[    4.672025]  [<c11d45e8>] scatterwalk_map_and_copy+0x28/0xc0
[    4.672025]  [<c11db220>] ? shash_ahash_finup+0x80/0x80
[    4.672025]  [<c11db23f>] ? shash_async_finup+0x1f/0x30
[    4.672025]  [<c11da470>] ? crypto_ahash_op+0x20/0x50
[    4.672025]  [<c11da763>] ? crypto_ahash_finup+0x13/0x20
[    4.672025]  [<c11f2c6f>] ? crypto_authenc_ahash_fb+0xaf/0xd0
[    4.672025]  [<c11f2dfc>] crypto_authenc_genicv+0xfc/0x340
[    4.672025]  [<c11f3526>] crypto_authenc_encrypt+0x96/0xb0
[    4.672025]  [<c11f3490>] ? crypto_authenc_decrypt+0x3e0/0x3e0
[    4.672025]  [<c11d4eb7>] old_crypt+0xa7/0xc0
[    4.672025]  [<c11d4f09>] old_encrypt+0x19/0x20
[    4.672025]  [<c11ddbe8>] __test_aead+0x268/0x1580
[    4.672025]  [<c11d28a7>] ? __crypto_alloc_tfm+0x37/0x120
[    4.672025]  [<c11d28a7>] ? __crypto_alloc_tfm+0x37/0x120
[    4.672025]  [<c11d7742>] ? skcipher_geniv_init+0x22/0x40
[    4.672025]  [<c11d7d73>] ? eseqiv_init+0x43/0x50
[    4.672025]  [<c11d2936>] ? __crypto_alloc_tfm+0xc6/0x120
[    4.672025]  [<c11df101>] test_aead+0x31/0xc0
[    4.672025]  [<c11df1d3>] alg_test_aead+0x43/0xa0
[    4.672025]  [<c11def2e>] ? alg_find_test+0x2e/0x70
[    4.672025]  [<c11dfe42>] alg_test+0xa2/0x240
[    4.672025]  [<c106dd83>] ? finish_task_switch+0x83/0xe0
[    4.672025]  [<c159c002>] ? __schedule+0x412/0x1067
[    4.672025]  [<c1085f57>] ? __wake_up_common+0x47/0x70
[    4.672025]  [<c11dbc10>] ? cryptomgr_notify+0x450/0x450
[    4.672025]  [<c11dbc4f>] cryptomgr_test+0x3f/0x50
[    4.672025]  [<c1066dfb>] kthread+0xab/0xc0
[    4.672025]  [<c15a1a41>] ret_from_kernel_thread+0x21/0x30
[    4.672025]  [<c1066d50>] ? __kthread_parkme+0x80/0x80
[    4.672025] Code: 83 c4 04 5b 5e 5f 5d c3 81 3b 21 43 65 87 75 13 8b 43 04 83 e0 fe 83 c8 02 89 43 04 89 d8 e9 4d ff ff ff 0f 0b 0f 0b 0f 0b 0f 0b <0f> 0b 0f 0b 8d b4 26 00 00 00 00 55 89 e5 57 56 53 83 ec 40 3e
[    4.672025] EIP: [<c11d45b5>] scatterwalk_ffwd+0xf5/0x100 SS:ESP 0068:ceb55c6c
[    4.721562] ---[ end trace 94a02f0816fe7c7f ]---
