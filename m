From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Asynchronous crypto layer.
Date: Tue, 2 Nov 2004 18:24:15 +0300
Message-ID: <20041102182415.61f5e8a4@zanzibar.2ka.mipt.ru>
References: <1099030958.4944.148.camel@uganda>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Tue__2_Nov_2004_18_24_15_+0300_SHM75zEMLqjdT6mC"
Cc: netdev@oss.sgi.com, cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>, James Morris <jmorris@redhat.com>,
        Michal
 Ludvig <michal@logix.cz>
In-Reply-To: <1099030958.4944.148.camel@uganda>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart=_Tue__2_Nov_2004_18_24_15_+0300_SHM75zEMLqjdT6mC
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

Here we go.
Numbers.

Actually nothing excitement:
since ecryption/decryption was made in a one thread
(please see dirty hack in sync_provider.c:89 to allow
crypto_cipher_{en,de}crypt() work in _bh context, BUG()
in crypto_yeld() can be reproduced by removing hack).

UP with HT badly broken Xeon(800 mhz) 2 parallel running scripts:
rnd=$RANDOM
file=/mnt/$rnd

for ((i=0; i<20; ++i)); do
        echo -en "."
        dd if=/dev/zero of=$file bs=1M count=40 > /dev/null 2>&1
        rm -f $file
done
echo

Pure sync mode: 
0.07user 14.87system 0:16.49elapsed 90%CPU (0avgtext+0avgdata 0maxresident)k
0inputs+0outputs (0major+6840minor)pagefaults 0swaps

Pseudo async mode(data ecnryption/decryption is done synchronous thread,
only pre/post processing is asynchronous):
0.08user 11.66system 0:17.03elapsed 68%CPU (0avgtext+0avgdata 0maxresident)k
0inputs+0outputs (0major+6870minor)pagefaults 0swaps

Attached synchronous and asynchronous crypto providers and purely in-memory 
block device.
Usage:
Async mode:
cd crypto
sudo ./i
cd ../block
sudo ./i
term1$ sudo time ./start
term2$ sudo time ./start

Sync mode:
cd block
sudo ./r
cd ../crypto
sudo ./r
cd ../block
sudo ./i 1
term1$ sudo time ./start
term2$ sudo time ./start

I will send updated asynchronous crypto patch in a next e-mail.

	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt

--Multipart=_Tue__2_Nov_2004_18_24_15_+0300_SHM75zEMLqjdT6mC
Content-Type: text/x-csrc;
 name="async_provider.c"
Content-Disposition: attachment;
 filename="async_provider.c"
Content-Transfer-Encoding: 7bit

/*
 * 	async_provider.c
 *
 * Copyright (c) 2004 Evgeniy Polyakov <johnpol@2ka.mipt.ru>
 * 
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/types.h>
#include <linux/list.h>
#include <linux/slab.h>
#include <linux/interrupt.h>
#include <linux/spinlock.h>
#include <linux/workqueue.h>
#include <linux/err.h>
#include <linux/crypto.h>
#include <linux/mm.h>
#include <linux/blkdev.h>

#include "../crypto/acrypto.h"
#include "../crypto/crypto_stat.h"
#include "../crypto/crypto_def.h"

static void prov_data_ready(struct crypto_device *);
static void async_callback(struct crypto_session_initializer *, struct crypto_data *);

static struct crypto_capability prov_caps[] = 	{
		{CRYPTO_OP_ENCRYPT, CRYPTO_TYPE_AES_128, CRYPTO_MODE_ECB, 10000},
		{CRYPTO_OP_DECRYPT, CRYPTO_TYPE_AES_128, CRYPTO_MODE_ECB, 10000},
};
static int prov_cap_number = sizeof(prov_caps)/sizeof(prov_caps[0]);

static struct completion thread_exited;
static DECLARE_WAIT_QUEUE_HEAD(async_wait_queue);
static int need_exit;
static struct crypto_tfm *tfm;
static char async_algo[] = "aes";
static char async_key[] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f};
static struct crypto_session_initializer ci = 
{
	.operation		= CRYPTO_OP_ENCRYPT,
	.mode			= CRYPTO_MODE_ECB,
	.type			= CRYPTO_TYPE_AES_128,
	.callback		= async_callback,
};

static struct crypto_device pdev =
{
	.name			= "async_provider",
	.data_ready		= prov_data_ready,
	.cap			= &prov_caps[0],
};

static void async_callback(struct crypto_session_initializer *ci, struct crypto_data *data)
{
	struct request *req = data->priv;
	
	dprintk("%s: req=%p, req->q=%p.\n", __func__, req, req->q);

	(unsigned long)req->special--;

	if ((unsigned long)req->special == 0 && req->q)
	{
		spinlock_t *l = req->q->queue_lock;
		
		dprintk("Finishing request for req=%p [%lu].\n", req, (unsigned long)req->special);
		
		spin_lock_irq(l);
		(unsigned long)req->special = 0;
		if (!end_that_request_first(req, 1, req->nr_sectors));
			end_that_request_last(req);
		spin_unlock_irq(l);
	}
}

static __inline__ void async_prepare(struct crypto_data *data, void *src, void *dst, unsigned long size, void *priv)
{		
	struct request *req = priv;
	
	(unsigned long)req->special++;

	dprintk("%s: req=%p, refcnt=%lu.\n",
			__func__, req, (unsigned long)req->special);
	
	data->sg_src.page 	= virt_to_page(src);
	data->sg_src.offset	= offset_in_page(src);
	data->sg_src.length	= size;
	
	data->sg_dst.page 	= virt_to_page(dst);
	data->sg_dst.offset	= offset_in_page(dst);
	data->sg_dst.length	= size;
	
	data->sg_key.page 	= virt_to_page(async_key);
	data->sg_key.offset	= offset_in_page(async_key);
	data->sg_key.length	= sizeof(async_key);

	data->priv		= priv;
	data->priv_size		= 0;
}

void bd_encrypt(void *src, void *dst, u64 size, void *priv)
{
	struct crypto_data data;
	struct crypto_session *sp;

	async_prepare(&data, src, dst, size, priv);
	
	ci.operation = CRYPTO_OP_ENCRYPT;
	sp = crypto_session_alloc(&ci, &data);
	BUG_ON(!sp);
	
	wake_up_interruptible(&async_wait_queue);
}

void bd_decrypt(void *src, void *dst, u64 size, void *priv)
{
	struct crypto_data data;
	struct crypto_session *sp;

	async_prepare(&data, src, dst, size, priv);
	
	ci.operation = CRYPTO_OP_DECRYPT;
	sp = crypto_session_alloc(&ci, &data);
	BUG_ON(!sp);
	
	wake_up_interruptible(&async_wait_queue);
}

static void prov_data_ready(struct crypto_device *dev)
{
	wake_up_interruptible(&async_wait_queue);
}

static int async_thread(void *data)
{
	struct crypto_device *dev = (struct crypto_device *)data;
	struct crypto_session *s, *n;
	
	daemonize("%s", dev->name);
	allow_signal(SIGTERM);

	while (!need_exit)
	{
		int num, pnum;
		
		interruptible_sleep_on_timeout(&async_wait_queue, 100);

		if (need_exit)
			break;

		num = pnum = 0;
		list_for_each_entry_safe(s, n, &dev->session_list, dev_queue_entry)
		{
			num++;
			
			if (session_completed(s))
				continue;

			pnum++;

			start_process_session(s);

			if (s->ci.operation == CRYPTO_OP_ENCRYPT)
				crypto_cipher_encrypt(tfm, &s->data.sg_dst, &s->data.sg_src, s->data.sg_src.length);
			else
				crypto_cipher_decrypt(tfm, &s->data.sg_dst, &s->data.sg_src, s->data.sg_src.length);
				
			dprintk("%lu: Completing session %llu [%llu] in %s.\n", 
					jiffies, s->ci.id, s->ci.dev_id, pdev.name);

			crypto_stat_complete_inc(s);
			complete_session(s);
			stop_process_session(s);
		}

		dprintk("%lu: %s: %d sessions, %d processed.\n", jiffies, dev->name, num, pnum);
	}
	
	complete_and_exit(&thread_exited, 0);
}

int prov_init(void)
{
	int err, pid;

	tfm = crypto_alloc_tfm(async_algo, 0);
	if (!tfm)
	{
		dprintk(KERN_ERR "Failed to allocate %s tfm.\n", async_algo);
		return -EINVAL;
	}
	
	err = crypto_cipher_setkey(tfm, async_key, sizeof(async_key));
	if (err)
	{
		dprintk("Failed to set key [keylen=%d]: err=%d.\n",
				sizeof(async_key), err);
		goto err_out_free_tfm;
	}
	
	init_completion(&thread_exited);
	pid = kernel_thread(async_thread, &pdev, CLONE_FS | CLONE_FILES);
	if (IS_ERR((void *)pid))
	{
		err = -EINVAL;
		dprintk(KERN_ERR "Failed to create kernel load balancing thread.\n");
		goto err_out_free_tfm;
	}
	
	pdev.cap_number = prov_cap_number;

	err = crypto_device_add(&pdev);
	if (err)
		goto err_out_remove_thread;

	dprintk(KERN_INFO "Test crypto provider module %s is loaded.\n", pdev.name);

	return 0;

err_out_remove_thread:
	need_exit = 1;
	wake_up(&async_wait_queue);
	wait_for_completion(&thread_exited);
err_out_free_tfm:
	crypto_free_tfm(tfm);

	return err;
}

void prov_fini(void)
{
	need_exit = 1;
	wake_up(&async_wait_queue);
	wait_for_completion(&thread_exited);

	crypto_device_remove(&pdev);
	crypto_free_tfm(tfm);
	
	dprintk(KERN_INFO "Test crypto provider module %s is unloaded.\n", pdev.name);
}

module_init(prov_init);
module_exit(prov_fini);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Evgeniy Polyakov <johnpol@2ka.mipt.ru>");
MODULE_DESCRIPTION("Test crypto module provider.");

EXPORT_SYMBOL(bd_encrypt);
EXPORT_SYMBOL(bd_decrypt);

--Multipart=_Tue__2_Nov_2004_18_24_15_+0300_SHM75zEMLqjdT6mC
Content-Type: application/octet-stream;
 name="Makefile"
Content-Disposition: attachment;
 filename="Makefile"
Content-Transfer-Encoding: base64

b2JqLW0JCTo9IGJkLm8KCktESVIJOj0gL2xpYi9tb2R1bGVzLyQoc2hlbGwgdW5hbWUgLXIpL2J1
aWxkCiNLRElSCTo9IC91c3IvbG9jYWwvc3JjL2xpbnV4LTIuNi9saW51eC0yLjYKUFdECTo9ICQo
c2hlbGwgcHdkKQoKZGVmYXVsdDoKCSQoTUFLRSkgLUMgJChLRElSKSBTVUJESVJTPSQoUFdEKSBt
b2R1bGVzCgpjbGVhbjoKCXJtIC1mICoubyAqLmtvICoubW9kLiogLiouY21kICp+CglybSAtcmYg
LnRtcF92ZXJzaW9ucwo=

--Multipart=_Tue__2_Nov_2004_18_24_15_+0300_SHM75zEMLqjdT6mC
Content-Type: text/x-csrc;
 name="bd.c"
Content-Disposition: attachment;
 filename="bd.c"
Content-Transfer-Encoding: 7bit

/*
 * 	bd.c
 *
 * Copyright (c) 2004 Evgeniy Polyakov <johnpol@2ka.mipt.ru>
 * 
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/spinlock.h>
#include <linux/blkdev.h>
#include <linux/fs.h>
#include <linux/bio.h>
#include <linux/init.h>

//#define BD_DEBUG

#ifdef BD_DEBUG
#define dprintk(f, a...) printk(KERN_EMERG f, ##a)
#else
#define dprintk(f, a...) do {} while(0)
#endif

#define BD_READ		0
#define BD_WRITE	1

static char bd_name[] = "bd";

static unsigned int bd_major = 123;
module_param(bd_major, uint, 0);

static unsigned int bd_sector_size = 512;
module_param(bd_sector_size, uint, 0);

static unsigned int bd_max_request_size = 1024*1024*50;
module_param(bd_max_request_size, uint, 0);

static int sync_mode = 0;
module_param(sync_mode, uint, 0);

static void *bd_request_data;
static spinlock_t bd_lock = SPIN_LOCK_UNLOCKED;
static struct gendisk *bd_disk;

static unsigned long req_counter = 1;

extern void bd_encrypt(void *src, void *dst, u64 size, void *priv);
extern void bd_decrypt(void *src, void *dst, u64 size, void *priv);

static int bd_ioctl(struct inode *, struct file *, unsigned int, unsigned long);

static struct block_device_operations bd_fops =
{
	.owner =	THIS_MODULE,
	.ioctl =	bd_ioctl,
};

static int bd_ioctl(struct inode *inode, struct file *file,
		     unsigned int cmd, unsigned long arg)
{
	dprintk("%s: cmd=%u, arg=%ld.\n", __func__, cmd, arg);

	return 0;
}

static int bd_process_data(int cmd, void *buf, u64 off, u64 size, void *priv)
{
	if (size > bd_max_request_size)
	{
		dprintk("Too big size %llu, setting to %u.\n",
				size, bd_max_request_size);
		size = bd_max_request_size;
	}
	if (off + size > bd_max_request_size)
	{
		dprintk("Too big size %llu or offset %llu, exiting.\n",
				size, off);
		size = bd_max_request_size;
	}

	switch (cmd)
	{
		case BD_READ:
			bd_decrypt(((char *)bd_request_data) + off, buf, size, priv);
			break;
		case BD_WRITE:
			bd_encrypt(buf, ((char *)bd_request_data) + off, size, priv);
			break;
	}

	dprintk("%s finished cmd=%s, size=%llu, off=%llu.\n", 
			__func__, 
			(cmd == BD_WRITE)?"WRITE":"READ",
			size, off);

	return 0;
}

static __inline__ int bd_process_bvec(int cmd, struct bio_vec *bvec, u64 off, void *priv)
{
	int err;
	char *kaddr;
	void *buf;
	u64 size;
	
       	kaddr = page_address(bvec->bv_page);
	buf = kaddr + bvec->bv_offset;
	size = bvec->bv_len;
	
	err = bd_process_data(cmd, buf, off, size, priv);
	
	return err;
}

static void bd_request(request_queue_t * q)
{
	struct request *req;
	u64 size, off;
	int err, cmd, bad_bio;
	struct bio *bio;
	
	while ((req = elv_next_request(q)) != NULL) 
	{
		blkdev_dequeue_request(req);
		
		(unsigned long)req->special = 0;

		off = req->sector * bd_sector_size;
		size = req->nr_sectors * bd_sector_size;

		cmd = (rq_data_dir(req) == 1)?BD_WRITE:BD_READ;

		dprintk("%s: TRANSFER: req=%p [%lu], cmd=%s, off=%llu [sector=%llu], size=%llu [nr_sectors=%lu], flags=%lx.\n", 
				bd_name, req, (unsigned long)req->special,
				(cmd == BD_WRITE)?"WRITE":"READ",
				off, req->sector,
				size, req->nr_sectors,
				req->flags);
		
		bad_bio = 0;
		if (!(req->flags & REQ_CMD))
		{
			dprintk("%s: wrong command.\n", bd_name);
			goto err_out_wrong_command;
		}
		
		rq_for_each_bio(bio, req) 
		{
			struct bio_vec *bvec;
			int i;
				
			dprintk("BIO: bi_size=%u, bvec=%p.\n", bio->bi_size, bio->bi_io_vec);

			if (!bio->bi_size || !bio->bi_io_vec)
			{
				bad_bio = 1;
				continue;
			}
			
			bio_for_each_segment(bvec, bio, i) {
				dprintk("%s: i=%d, req=%p, size=%d.\n",
						bd_disk->disk_name, i, 
						req, bvec->bv_len);

				err = bd_process_bvec(cmd, bvec, off, req);
				if (err)
				{
					bad_bio = 1;
					continue;
				}

				off += bvec->bv_len;
				size -= bvec->bv_len;

			}
			
			/*
			 * bio->bi_end_io = NULL;	
			 * bio_endio(bio, bio->bi_size, (bad_bio)?-EIO:0);
			 */
		}
		
		dprintk("cmd=%s has been processed: err=%d\n", 
				(cmd == BD_WRITE)?"WRITE":"READ",
				req->errors);
err_out_wrong_command:	
		if (sync_mode)
		{
			if (!end_that_request_first(req, (bad_bio)?0:1, req->nr_sectors));
				end_that_request_last(req);
		}
	}
}

static void bd_setup(struct gendisk *d)
{
	request_queue_t *q;
	
	d->major 		= bd_major;
	d->first_minor		= 0;
	d->fops			= &bd_fops;
	d->private_data		= NULL;
	d->flags		= GENHD_FL_SUPPRESS_PARTITION_INFO;

	sprintf(d->disk_name, "%s%d", bd_name, 0);

	q = d->queue;

	blk_queue_hardsect_size(q, bd_sector_size);

	set_capacity(d, bd_max_request_size/bd_sector_size);

	add_disk(d);
}

int __devinit bd_init(void)
{
	int err;

	bd_request_data = vmalloc(bd_max_request_size);
	if (!bd_request_data)
	{
		dprintk("Failed to allocate %d bytes for %s requests.\n",
				bd_max_request_size, bd_name);
		return -ENOMEM;
	}
	
	err = register_blkdev(bd_major, bd_name);
	if (err)
	{
		dprintk("Failed to register blkdev with major %u: err=%d.\n",
				bd_major, err);
		return err;
	}

	bd_disk = alloc_disk(1);
	if (!bd_disk)
	{
		dprintk("Failed to allocate a disk.\n");
		goto err_out_unregister_blkdev;
	}
	
	bd_disk->queue = blk_init_queue(bd_request, &bd_lock);
	if (!bd_disk->queue)
	{
		dprintk("Failed to initialize blk queue: err=%d.\n", err);
		goto err_out_free_disk;
	}

	bd_setup(bd_disk);
	
	dprintk("%s has beed successfully added.\n", bd_name);

	return 0;
	
err_out_free_disk:
	put_disk(bd_disk);
err_out_unregister_blkdev:
	unregister_blkdev(bd_major, "bd");

	vfree(bd_request_data);

	return -EINVAL;
}

void __devexit bd_fini(void)
{
	del_gendisk(bd_disk);
	blk_cleanup_queue(bd_disk->queue);
	put_disk(bd_disk);
	unregister_blkdev(bd_major, "bd");
	vfree(bd_request_data);

	dprintk("%s has beed successfully removed.\n", bd_name);
}

module_init(bd_init);
module_exit(bd_fini);

MODULE_AUTHOR("Evgeniy Polyakov <johnpol@2ka.mipt.ru>");
MODULE_LICENSE("GPL");

--Multipart=_Tue__2_Nov_2004_18_24_15_+0300_SHM75zEMLqjdT6mC
Content-Type: application/octet-stream;
 name="i"
Content-Disposition: attachment;
 filename="i"
Content-Transfer-Encoding: base64

IyEvYmluL3NoCgpudW09JCMKCmRldl9maWxlPS9kZXYvYmQwCnN5bmNfbW9kZT0wOwoKaWYgWyAk
bnVtICE9IDAgXTsgdGhlbgoJc3luY19tb2RlPSQxCmZpCgppZiBbICRzeW5jX21vZGUgIT0gMCBd
OyB0aGVuCglpbnNtb2QgLi9zeW5jX3Byb3ZpZGVyLmtvCmVsc2UKCWluc21vZCAuL2FzeW5jX3By
b3ZpZGVyLmtvCmZpCmluc21vZCAuL2JkLmtvIHN5bmNfbW9kZT0kc3luY19tb2RlCgppZiBbICEg
LWYgJGRldl9maWxlIF07IHRoZW4KCW1rbm9kICRkZXZfZmlsZSBiIDEyMyAwCmZpCgpta2ZzLmV4
dDIgJGRldl9maWxlCm1vdW50ICRkZXZfZmlsZSAvbW50Cg==

--Multipart=_Tue__2_Nov_2004_18_24_15_+0300_SHM75zEMLqjdT6mC
Content-Type: application/octet-stream;
 name="r"
Content-Disposition: attachment;
 filename="r"
Content-Transfer-Encoding: base64

ZGV2X2ZpbGU9L2Rldi9iZDAKCnVtb3VudCAvbW50CnJtbW9kIGJkCnJtbW9kIGFzeW5jX3Byb3Zp
ZGVyCnJtbW9kIHN5bmNfcHJvdmlkZXIK

--Multipart=_Tue__2_Nov_2004_18_24_15_+0300_SHM75zEMLqjdT6mC
Content-Type: text/x-csrc;
 name="sync_provider.c"
Content-Disposition: attachment;
 filename="sync_provider.c"
Content-Transfer-Encoding: 7bit

/*
 * 	sync_provider.c
 *
 * Copyright (c) 2004 Evgeniy Polyakov <johnpol@2ka.mipt.ru>
 * 
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/spinlock.h>
#include <linux/blkdev.h>
#include <linux/fs.h>
#include <linux/bio.h>
#include <linux/init.h>
#include <linux/crypto.h>
#include <linux/hardirq.h>

#include <asm/scatterlist.h>

//#define SYNC_DEBUG

#ifdef SYNC_DEBUG
#define dprintk(f, a...) printk(KERN_EMERG f, ##a)
#else
#define dprintk(f, a...) do {} while(0)
#endif

#define OP_ENCRYPT		0
#define OP_DECRYPT		1

static char sync_algo[] = "aes";
static char sync_key[] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f};
static struct crypto_tfm *tfm;

void bd_encrypt(void *src, void *dst, u64 size, void *priv)
{
	struct scatterlist s, d;
	s.page 		= virt_to_page(src);
	s.offset	= offset_in_page(src);
	s.length	= size;
	
	d.page 		= virt_to_page(dst);
	d.offset	= offset_in_page(dst);
	d.length	= size;
	
	/*
	 * A hack to fool crypto layer - it thinks that we can sleep here...
	 * Sigh.
	 *
	 * preempt_count() |= SOFTIRQ_MASK;
	 */
	
	preempt_count() |= SOFTIRQ_MASK;
	crypto_cipher_encrypt(tfm, &d, &s, size);
	preempt_count() &= ~SOFTIRQ_MASK;
}
void bd_decrypt(void *src, void *dst, u64 size, void *priv)
{
	struct scatterlist s, d;
	s.page 		= virt_to_page(src);
	s.offset	= offset_in_page(src);
	s.length	= size;
	
	d.page 		= virt_to_page(dst);
	d.offset	= offset_in_page(dst);
	d.length	= size;
	
	/*
	 * A hack to fool crypto layer - it thinks that we can sleep here...
	 * Sigh.
	 *
	 * preempt_count() |= SOFTIRQ_MASK;
	 */
	preempt_count() |= SOFTIRQ_MASK;
	crypto_cipher_decrypt(tfm, &d, &s, size);
	preempt_count() &= ~SOFTIRQ_MASK;
}

int __devinit sync_init(void)
{
	int err;

	err = -ENODEV;
	tfm = crypto_alloc_tfm(sync_algo, 0);
	if (!tfm)
	{
		dprintk("Failed to allocate %s tfm.\n", sync_algo);
		goto err_out_exit;
	}

	err = crypto_cipher_setkey(tfm, sync_key, sizeof(sync_key));
	if (err)
	{
		dprintk("Failed to set key [keylen=%d]: err=%d.\n",
				sizeof(sync_key), err);
		goto err_out_free_tfm;
	}
	
	return 0;
	
err_out_free_tfm:
	crypto_free_tfm(tfm);
err_out_exit:
	return err;
}

void __devexit sync_fini(void)
{
	crypto_free_tfm(tfm);
}

module_init(sync_init);
module_exit(sync_fini);

MODULE_AUTHOR("Evgeniy Polyakov <johnpol@2ka.mipt.ru>");
MODULE_LICENSE("GPL");

EXPORT_SYMBOL(bd_encrypt);
EXPORT_SYMBOL(bd_decrypt);

--Multipart=_Tue__2_Nov_2004_18_24_15_+0300_SHM75zEMLqjdT6mC
Content-Type: application/octet-stream;
 name="start"
Content-Disposition: attachment;
 filename="start"
Content-Transfer-Encoding: base64

cm5kPSRSQU5ET00KZmlsZT0vbW50LyRybmQKCmZvciAoKGk9MDsgaTwyMDsgKytpKSk7IGRvCgll
Y2hvIC1lbiAiLiIKCWRkIGlmPS9kZXYvemVybyBvZj0kZmlsZSBicz0xTSBjb3VudD00MCA+IC9k
ZXYvbnVsbCAyPiYxCglybSAtZiAkZmlsZQpkb25lCmVjaG8K

--Multipart=_Tue__2_Nov_2004_18_24_15_+0300_SHM75zEMLqjdT6mC--
