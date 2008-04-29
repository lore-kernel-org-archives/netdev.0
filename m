From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC XFRM]: esp: fix scatterlist of out bounds access with crypto_eseqiv
Date: Tue, 29 Apr 2008 07:09:39 +0200
Message-ID: <4816AD93.5090404@trash.net>
References: <48161D99.5070303@trash.net> <20080429014107.GA16700@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070400080800050008010201"
Cc: linux-crypto@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20080429014107.GA16700@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070400080800050008010201
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> Hi Patrick:
> 
> On Mon, Apr 28, 2008 at 08:55:21PM +0200, Patrick McHardy wrote:
>> I ran into occasional BUGs in scatterlist.h, which turned
>> out the be caused by accessing an uninitialized scatterlist
>> entry from eseqiv. I'm not sure whether this patch is correct
>> since I'm seeing invalid packets with and without this patch
>> (probably related to HIFN though) and I don't understand why
>> scatterwalk_sg_next() returns either a scatterlist or a
>> struct page dependant on the length, but at least it fixes
>> the BUG() for me :)
> 
> Can you attach the BUG output please?


I've attached two traces, the one from eseqiv and a similar
one from authenc (I've manually overriden eseqiv by chainiv
to test whether its responsible for the broken packets I was
seeing, which turned out to be the case. I'll look into that).


--------------070400080800050008010201
Content-Type: text/plain;
 name="eseqiv.oops"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="eseqiv.oops"

------------[ cut here ]------------
kernel BUG at include/linux/scatterlist.h:96!
invalid opcode: 0000 [#1] PREEMPT DEBUG_PAGEALLOC
Modules linked in: authenc esp4 aead xfrm4_mode_tunnel sha1_generic hmac crypto_hash cryptomgr]

Pid: 1548, comm: ping Not tainted (2.6.25 #75)
EIP: 0060:[<dc81e69b>] EFLAGS: 00010213 CPU: 0
EIP is at eseqiv_chain+0x21/0x90 [crypto_blkcipher]
EAX: 0000006c EBX: dba27da8 ECX: 00000001 EDX: dba27e88
ESI: 00374300 EDI: dba27da8 EBP: daa32ba0 ESP: daa32b9c
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Process ping (pid: 1548, ti=daa32000 task=da9f4000 task.ti=daa32000)
Stack: 00000010 daa32bf8 dc81e905 daa32bd2 dba27e08 dba27d70 db9ea930 dba27e20 
       dc92d4fa dba27d40 dba27e70 dba27e70 c0153e57 dba1848c dba1849c dba1849c 
       0000048c dba1849c 00000060 daa32bf8 db9ea900 dba27d70 00000060 daa32c08 
Call Trace:
 [<dc81e905>] ? eseqiv_givencrypt+0x19c/0x2c1 [crypto_blkcipher]
 [<dc92d4fa>] ? crypto_authenc_givencrypt_done+0x0/0x24 [authenc]
 [<c0153e57>] ? __slab_alloc+0x389/0x3f5
 [<dc81ea9e>] ? eseqiv_givencrypt_first+0x4a/0x50 [crypto_blkcipher]
 [<dc92d649>] ? crypto_authenc_givencrypt+0x65/0x80 [authenc]
 [<dc92a9d1>] ? esp_output+0x283/0x2ae [esp4]
 [<c025878e>] ? xfrm_output_resume+0x24a/0x339
 [<c025888a>] ? xfrm_output2+0xd/0xf
 [<c0258954>] ? xfrm_output+0xc8/0xd4
 [<c0251efe>] ? xfrm4_output+0xe/0x10
 [<c022dbea>] ? ip_local_out+0x18/0x1b
 [<c022df1b>] ? ip_push_pending_frames+0x24f/0x2b6
 [<c0244297>] ? raw_sendmsg+0x53f/0x5b7
 [<c024a873>] ? inet_sendmsg+0x3b/0x48
 [<c020f230>] ? sock_sendmsg+0xc9/0xe0
 [<c012841f>] ? autoremove_wake_function+0x0/0x30
 [<c01146f5>] ? __wake_up_common+0x2e/0x54
 [<c01168fe>] ? __wake_up+0x1d/0x3d
 [<c01e132a>] ? n_tty_receive_buf+0xd2f/0xd7a
 [<c01b04fa>] ? copy_from_user+0x2c/0x4f
 [<c021523d>] ? verify_iovec+0x40/0x6f
 [<c020f394>] ? sys_sendmsg+0x14d/0x1a8
 [<c0115a80>] ? hrtick_set+0x7b/0xcb
 [<c013b439>] ? find_lock_page+0x28/0xb1
 [<c013d1ff>] ? filemap_fault+0x1ee/0x345
 [<c013b350>] ? unlock_page+0x24/0x27
 [<c014566e>] ? __do_fault+0x2cd/0x307
 [<c0263bed>] ? __lock_text_start+0x25/0x27
 [<c0160955>] ? vfs_ioctl+0x55/0x67
 [<c0210086>] ? sys_socketcall+0x146/0x15e
 [<c01038c5>] ? sysenter_past_esp+0x6a/0x91
 =======================
Code: 10 89 f2 ff 53 18 5b 5e 5d c3 55 85 c9 89 e5 53 89 c3 74 2b 8b 42 0c 83 c2 18 01 43 0c 8 
EIP: [<dc81e69b>] eseqiv_chain+0x21/0x90 [crypto_blkcipher] SS:ESP 0068:daa32b9c
---[ end trace 99e8b865243b3a33 ]---


--------------070400080800050008010201
Content-Type: text/plain;
 name="authenc.oops"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="authenc.oops"

Pid: 1536, comm: ping Not tainted (2.6.25 #74)
EIP: 0060:[<dc92d04b>] EFLAGS: 00010213 CPU: 0
EIP is at authenc_chain+0x21/0x90 [authenc]
EAX: 0000006c EBX: c033df20 ECX: 00000001 EDX: db99dcd0
ESI: db99dcb8 EDI: dba228ec EBP: c033df00 ESP: c033defc
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Process ping (pid: 1536, ti=c033d000 task=da9ee380 task.ti=daa35000)
Stack: 1ba22000 c033df5c dc92d223 00000000 db99dc00 000008fc da9e5150 00000010 
       c1001000 87654321 c1375440 000008ec 0000007c 00000000 00000000 87654321 
       00000002 00000000 00000000 00000000 00000000 db99dc68 db9fb240 dbb61720 
Call Trace:
 [<dc92d223>] ? crypto_authenc_genicv+0xcb/0x109 [authenc]
 [<dc92d511>] ? crypto_authenc_givencrypt_done+0x17/0x24 [authenc]
 [<dc844a63>] ? hifn_process_ready+0x22f/0x237 [hifn_795x]
 [<dc845722>] ? hifn_check_for_completion+0x4d/0xa6 [hifn_795x]
 [<c011fee0>] ? run_timer_softirq+0x14/0x176
 [<dc845785>] ? hifn_tasklet_callback+0xa/0xc [hifn_795x]
 [<c011d046>] ? tasklet_action+0x3f/0x66
 [<c011d230>] ? __do_softirq+0x38/0x7a
 [<c0105a5f>] ? do_softirq+0x3e/0x71
 [<c0139e1f>] ? handle_fasteoi_irq+0x0/0xbf
 [<c011d17c>] ? irq_exit+0x2c/0x65
 [<c0105b27>] ? do_IRQ+0x95/0xaa
 [<c01042b7>] ? common_interrupt+0x23/0x28
 [<c0262ad2>] ? schedule_timeout+0x1/0x91
 [<c0215954>] ? __skb_recv_datagram+0x15f/0x1b7
 [<c012841f>] ? autoremove_wake_function+0x0/0x30
 [<c02159cc>] ? skb_recv_datagram+0x20/0x25
 [<c0243c88>] ? raw_recvmsg+0x5e/0x12e
 [<c021050c>] ? sock_common_recvmsg+0x31/0x4a
 [<c020f14f>] ? sock_recvmsg+0xd0/0xe8
 [<c012841f>] ? autoremove_wake_function+0x0/0x30
 [<c01e132a>] ? n_tty_receive_buf+0xd2f/0xd7a
 [<c01b04fa>] ? copy_from_user+0x2c/0x4f
 [<c021523d>] ? verify_iovec+0x40/0x6f
 [<c020fb97>] ? sys_recvmsg+0xf2/0x17f
 [<c0115a80>] ? hrtick_set+0x7b/0xcb
 [<c0103611>] ? do_notify_resume+0x6ef/0x703
 [<c013b350>] ? unlock_page+0x24/0x27
 [<c014566e>] ? __do_fault+0x2cd/0x307
 [<c0263bed>] ? __lock_text_start+0x25/0x27
 [<c0160955>] ? vfs_ioctl+0x55/0x67
 [<c0210092>] ? sys_socketcall+0x152/0x15e
 [<c01038c5>] ? sysenter_past_esp+0x6a/0x91
 =======================
Code: d8 e8 c6 70 82 e3 5b 5e 5d c3 55 85 c9 89 e5 53 89 c3 74 2b 8b 42 0c 83 c2 18 01 43 0c 8 
EIP: [<dc92d04b>] authenc_chain+0x21/0x90 [authenc] SS:ESP 0068:c033defc
Kernel panic - not syncing: Fatal exception in interrupt


--------------070400080800050008010201--
