From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Asynchronous crypto layer.
Date: Sun, 31 Oct 2004 00:37:49 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041031003749.2026b156@zanzibar.2ka.mipt.ru>
References: <1099030958.4944.148.camel@uganda>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Sun__31_Oct_2004_00_37_49_+0400_a+IT5K62.Lt7UdpI"
Cc: netdev@oss.sgi.com, cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>, Michal Ludvig <michal@logix.cz>
In-Reply-To: <1099030958.4944.148.camel@uganda>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart=_Sun__31_Oct_2004_00_37_49_+0400_a+IT5K62.Lt7UdpI
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

Sorry, no numbers today.
I've attached block device driver, synchronous driver which is needed 
for block device and asycnhronous one, first two works as expected, but
either I too tiread after climbing or one of the two, but
asynchronous driver hangs on mounting.
Michal, please test block device with your PCI adapter with attached 
scripts and synchronous driver adapter and report numbers.
Tomorrow I will finish software asynchronous driver and then we can
test it on SMP where I expect some speed increase.

Thank you.

P.S. While digging into my test trees I found very usefull patch that
I forget to apply. It converts _bh locking into _irq{save,restore}
since session allocation and processing can occure with any kind 
of interrupt state. Patch is also attached.

	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt

--Multipart=_Sun__31_Oct_2004_00_37_49_+0400_a+IT5K62.Lt7UdpI
Content-Type: application/octet-stream;
 name="Makefile"
Content-Disposition: attachment;
 filename="Makefile"
Content-Transfer-Encoding: base64

b2JqLW0JCTo9IGJkLm8gCm9iai1tCQkrPSBzeW5jX3Byb3ZpZGVyLm8Kb2JqLW0JCSs9IGFzeW5j
X3Byb3ZpZGVyLm8KCiNLRElSCTo9IC9saWIvbW9kdWxlcy8kKHNoZWxsIHVuYW1lIC1yKS9idWls
ZApLRElSCTo9IC91c3IvbG9jYWwvc3JjL2xpbnV4L3NvZWtyaXMvdG1wL2xpbnV4LTIuNgpQV0QJ
Oj0gJChzaGVsbCBwd2QpCgpkZWZhdWx0OgoJJChNQUtFKSAtQyAkKEtESVIpIFNVQkRJUlM9JChQ
V0QpIG1vZHVsZXMKCmNsZWFuOgoJcm0gLWYgKi5vICoua28gKi5tb2QuKiAuKi5jbWQgKn4KCXJt
IC1yZiAudG1wX3ZlcnNpb25zCg==

--Multipart=_Sun__31_Oct_2004_00_37_49_+0400_a+IT5K62.Lt7UdpI
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
		{CRYPTO_OP_ENCRYPT, CRYPTO_TYPE_AES_128, CRYPTO_MODE_ECB, 1000},
		{CRYPTO_OP_DECRYPT, CRYPTO_TYPE_AES_128, CRYPTO_MODE_ECB, 1000},
};
static int prov_cap_number = sizeof(prov_caps)/sizeof(prov_caps[0]);

static struct completion thread_exited;
static DECLARE_WAIT_QUEUE_HEAD(async_wait_queue);
static int need_exit;
static struct crypto_tfm *tfm;
struct crypto_session *sp;
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
	
	dprintk("%s: req=%p\n", __func__, req);
	
	(unsigned long)req->special--;

	if (((unsigned long)req->special) == 0)
	{
		spinlock_t *l = req->q->queue_lock;
		
		dprintk("Finishing request for req=%p.\n", req);
		
		spin_lock_irq(l);
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

void bd_encrypt(void *src, void *dst, unsigned long size, void *priv)
{
	struct crypto_session *session;
	struct crypto_data data;

	async_prepare(&data, src, dst, size, priv);
	
	ci.operation = CRYPTO_OP_ENCRYPT;
	session = crypto_session_alloc(&ci, &data);
	if (!session)
		WARN_ON(1);

	wake_up(&async_wait_queue);
}

void bd_decrypt(void *src, void *dst, unsigned long size, void *priv)
{
	struct crypto_session *session;
	struct crypto_data data;

	async_prepare(&data, src, dst, size, priv);
	
	ci.operation = CRYPTO_OP_DECRYPT;
	session = crypto_session_alloc(&ci, &data);
	if (!session)
		WARN_ON(1);

	wake_up(&async_wait_queue);
}

static void prov_data_ready(struct crypto_device *dev)
{
	struct crypto_session *s, *n;

	list_for_each_entry_safe(s, n, &dev->session_list, dev_queue_entry)
	{
		if (!session_completed(s))
		{
			sp = s;
			wake_up(&async_wait_queue);
			break;
		}
	}
}

static int async_thread(void *data)
{
	struct crypto_device *dev = (struct crypto_device *)data;
	
	daemonize("%s", dev->name);
	allow_signal(SIGTERM);

	while (!need_exit)
	{
		interruptible_sleep_on(&async_wait_queue);

		if (need_exit)
			break;
		if (!sp)
			continue;

		start_process_session(sp);

		if (sp->ci.operation == CRYPTO_OP_ENCRYPT)
			crypto_cipher_encrypt(tfm, &sp->data.sg_dst, &sp->data.sg_src, sp->data.sg_src.length);
		else
			crypto_cipher_decrypt(tfm, &sp->data.sg_dst, &sp->data.sg_src, sp->data.sg_src.length);
			
		dprintk("Completing session %llu [%llu] in %s.\n", 
				sp->ci.id, sp->ci.dev_id, pdev.name);

		//crypto_stat_complete_inc(sp);
		complete_session(sp);
		stop_process_session(sp);

		prov_data_ready(dev);
		
		sp = NULL;
	}
	
	complete_and_exit(&thread_exited, 0);
}

int prov_init(void)
{
	int err, pid;

	tfm = crypto_alloc_tfm(async_algo, 0);
	if (!tfm)
	{
		printk(KERN_ERR "Failed to allocate SHA1 tfm.\n");
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

--Multipart=_Sun__31_Oct_2004_00_37_49_+0400_a+IT5K62.Lt7UdpI
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

static void *bd_request_data;
static spinlock_t bd_lock = SPIN_LOCK_UNLOCKED;
static struct gendisk *bd_disk;

extern void bd_encrypt(void *src, void *dst, unsigned long size, void *priv);
extern void bd_decrypt(void *src, void *dst, unsigned long size, void *priv);

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

static int bd_process_data(int cmd, void *buf, unsigned long off, unsigned int size, void *priv)
{
	if (size > bd_max_request_size)
	{
		dprintk("Too big size %u, setting to %u.\n",
				size, bd_max_request_size);
		size = bd_max_request_size;
	}
	if (off + size > bd_max_request_size)
	{
		dprintk("Too big size %u or offset %lu, exiting.\n",
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

	dprintk("%s finished cmd=%s, size=%u, off=%lu.\n", 
			__func__, 
			(cmd == BD_WRITE)?"WRITE":"READ",
			size, off);

	return 0;
}

static __inline__ int bd_process_bvec(int cmd, struct bio_vec *bvec, unsigned long off, void *priv)
{
	int err;
	char *kaddr;
	void *buf;
	unsigned int size;
	
       	kaddr = page_address(bvec->bv_page);
	buf = kaddr + bvec->bv_offset;
	size = bvec->bv_len;
	
	err = bd_process_data(cmd, buf, off, size, priv);
	
	return err;
}

static void bd_request(request_queue_t * q)
{
	struct request *req;
	unsigned long off, size;
	int err, cmd, bad_bio;
	struct bio *bio;
	
	while ((req = elv_next_request(q)) != NULL) 
	{
		blkdev_dequeue_request(req);

		(unsigned long)req->special = 0;

		off = req->sector * bd_sector_size;
		size = req->nr_sectors * bd_sector_size;

		cmd = (rq_data_dir(req) == 1)?BD_WRITE:BD_READ;

		dprintk("%s: TRANSFER: cmd=%s, off=%lu [sector=%ld], size=%lu [nr_sectors=%lu], flags=%lx.\n", 
				bd_name, 
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
#if 1	
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
			
			//bio->bi_end_io = NULL;	
			//bio_endio(bio, bio->bi_size, (bad_bio)?-EIO:0);
		}
#else
		err = bd_process_data(cmd, req->buffer, off, size);
		if (err)
			bad_bio = 1;
#endif
		dprintk("cmd=%s has been processed: err=%d\n", 
				(cmd == BD_WRITE)?"WRITE":"READ",
				req->errors);
err_out_wrong_command:	
		if (!end_that_request_first(req, (bad_bio)?0:1, req->nr_sectors));
			//end_that_request_last(req);
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

--Multipart=_Sun__31_Oct_2004_00_37_49_+0400_a+IT5K62.Lt7UdpI
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

void bd_encrypt(void *src, void *dst, unsigned long size, void *priv)
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
void bd_decrypt(void *src, void *dst, unsigned long size, void *priv)
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

--Multipart=_Sun__31_Oct_2004_00_37_49_+0400_a+IT5K62.Lt7UdpI
Content-Type: application/octet-stream;
 name="bd_i"
Content-Disposition: attachment;
 filename="bd_i"
Content-Transfer-Encoding: base64

bW9kX3BhdGg9L2xpYi9tb2R1bGVzL2B1bmFtZSAtcmAva2VybmVsCgppbnNtb2QgJG1vZF9wYXRo
L2FyY2gvaTM4Ni9jcnlwdG8vYWVzLWk1ODYua28KI2luc21vZCAkbW9kX3BhdGgvZHJpdmVycy9i
bG9jay9zeW5jX3Byb3ZpZGVyLmtvCmluc21vZCAkbW9kX3BhdGgvZHJpdmVycy9ibG9jay9hc3lu
Y19wcm92aWRlci5rbwppbnNtb2QgJG1vZF9wYXRoL2RyaXZlcnMvYmxvY2svYmQua28gYmRfbWF4
X3JlcXVlc3Rfc2l6ZT01MjQyODgwMApta2ZzLmV4dDIgL2Rldi9iZDAKbW91bnQgL2Rldi9iZDAg
L21udAoKI3RpbWUgZGQgaWY9L2Rldi96ZXJvIG9mPS9tbnQvZmlsZSBicz0xTSBjb3VudD0xMAoj
dGltZSBkZCBpZj0vZGV2L3plcm8gb2Y9L2Rldi9iZDAgYnM9MU0gY291bnQ9MzAK

--Multipart=_Sun__31_Oct_2004_00_37_49_+0400_a+IT5K62.Lt7UdpI
Content-Type: application/octet-stream;
 name="crypto"
Content-Disposition: attachment;
 filename="crypto"
Content-Transfer-Encoding: base64

aW5zbW9kIC9saWIvbW9kdWxlcy8yLjYuOS1yYzQva2VybmVsL2RyaXZlcnMvY29ubmVjdG9yL2Nu
LmtvCmluc21vZCAvbGliL21vZHVsZXMvMi42LjktcmM0L2tlcm5lbC9kcml2ZXJzL2NyeXB0by9h
Y3J5cHRvLmtvIGZvcmNlX2xiX3JlbW92ZT0xCmluc21vZCAvbGliL21vZHVsZXMvMi42LjktcmM0
L2tlcm5lbC9kcml2ZXJzL2NyeXB0by9zaW1wbGVfbGIua28gCiNpbnNtb2QgL2xpYi9tb2R1bGVz
LzIuNi45LXJjNC9rZXJuZWwvZHJpdmVycy9jcnlwdG8vcHJvdmlkZXIua28gCiNpbnNtb2QgL2xp
Yi9tb2R1bGVzLzIuNi45LXJjNC9rZXJuZWwvZHJpdmVycy9jcnlwdG8vc2xvd19wcm92aWRlci5r
byAKI2luc21vZCAvbGliL21vZHVsZXMvMi42LjktcmM0L2tlcm5lbC9kcml2ZXJzL2NyeXB0by9j
b25zdW1lci5rbyAKI2luc21vZCAvbGliL21vZHVsZXMvMi42LjktcmM0L2tlcm5lbC9kcml2ZXJz
L2NyeXB0by9zbG93X2NvbnN1bWVyLmtvIAoK

--Multipart=_Sun__31_Oct_2004_00_37_49_+0400_a+IT5K62.Lt7UdpI
Content-Type: application/octet-stream;
 name="start"
Content-Disposition: attachment;
 filename="start"
Content-Transfer-Encoding: base64

cmFuZD0kUkFORE9NCmZpbGU9L21udC8kcmFuZAoKZm9yICgoaT0wOyBpPDEwOyArK2kpKTsgZG8K
CWVjaG8gLWVuICIuIgoJZGQgaWY9L2Rldi96ZXJvIG9mPSRmaWxlIGJzPTFNIGNvdW50PTEwID4g
L2Rldi9udWxsIDI+JjEKCXJtIC1mICRmaWxlCmRvbmUKZWNobwo=

--Multipart=_Sun__31_Oct_2004_00_37_49_+0400_a+IT5K62.Lt7UdpI
Content-Type: application/octet-stream;
 name="crypto.patch"
Content-Disposition: attachment;
 filename="crypto.patch"
Content-Transfer-Encoding: base64

LS0tIG9yaWcvY3J5cHRvX2xiLmMKKysrIG1vZC9jcnlwdG9fbGIuYwpAQCAtODMsMTIgKzgzLDEz
IEBACiBzdGF0aWMgaW5saW5lIHZvaWQgbGJfc2V0X2N1cnJlbnQoc3RydWN0IGNyeXB0b19sYiAq
bCkKIHsKIAlzdHJ1Y3QgY3J5cHRvX2xiICpjID0gY3VycmVudF9sYjsKKwl1bnNpZ25lZCBsb25n
IGZsYWdzOwogCQogCWlmIChjKQogCXsKLQkJc3Bpbl9sb2NrX2JoKCZjLT5sb2NrKTsKKwkJc3Bp
bl9sb2NrX2lycXNhdmUoJmMtPmxvY2ssIGZsYWdzKTsKIAkJX19sYl9zZXRfY3VycmVudChsKTsK
LQkJc3Bpbl91bmxvY2tfYmgoJmMtPmxvY2spOworCQlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZj
LT5sb2NrLCBmbGFncyk7CiAJfQogCWVsc2UKIAkJX19sYl9zZXRfY3VycmVudChsKTsKQEAgLTEw
MiwxMiArMTAzLDEzIEBACiBzdGF0aWMgaW5saW5lIHZvaWQgbGJfc2V0X2RlZmF1bHQoc3RydWN0
IGNyeXB0b19sYiAqbCkKIHsKIAlzdHJ1Y3QgY3J5cHRvX2xiICpjID0gZGVmYXVsdF9sYjsKKwl1
bnNpZ25lZCBsb25nIGZsYWdzOwogCiAJaWYgKGMpCiAJewotCQlzcGluX2xvY2tfYmgoJmMtPmxv
Y2spOworCQlzcGluX2xvY2tfaXJxc2F2ZSgmYy0+bG9jaywgZmxhZ3MpOwogCQlfX2xiX3NldF9k
ZWZhdWx0KGwpOwotCQlzcGluX3VubG9ja19iaCgmYy0+bG9jayk7CisJCXNwaW5fdW5sb2NrX2ly
cXJlc3RvcmUoJmMtPmxvY2ssIGZsYWdzKTsKIAl9CiAJZWxzZQogCQlfX2xiX3NldF9kZWZhdWx0
KGwpOwpAQCAtMTgzLDggKzE4NSw5IEBACiB7CiAJc3RydWN0IGNyeXB0b19sYiAqbGI7CiAJaW50
IG9mZiA9IDA7CisJdW5zaWduZWQgbG9uZyBmbGFnczsKIAotCXNwaW5fbG9ja19iaCgmY3J5cHRv
X2xiX2xvY2spOworCXNwaW5fbG9ja19pcnFzYXZlKCZjcnlwdG9fbGJfbG9jaywgZmxhZ3MpOwog
CWxpc3RfZm9yX2VhY2hfZW50cnkobGIsICZjcnlwdG9fbGJfbGlzdCwgbGJfZW50cnkpCiAJewog
CQlpZiAobGJfaXNfY3VycmVudChsYikpCkBAIC0xOTcsNyArMjAwLDcgQEAKIAkJaWYgKGxiX2lz
X2N1cnJlbnQobGIpKQogCQkJb2ZmICs9IHNwcmludGYoYnVmK29mZiwgIl0iKTsKIAl9Ci0Jc3Bp
bl91bmxvY2tfYmgoJmNyeXB0b19sYl9sb2NrKTsKKwlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZj
cnlwdG9fbGJfbG9jaywgZmxhZ3MpOwogCiAJaWYgKCFvZmYpCiAJCW9mZiA9IHNwcmludGYoYnVm
LCAiTm8gbG9hZCBiYWxhbmNlcnMgcmVnaXRlcmVkIHlldC4iKTsKQEAgLTIwOSw4ICsyMTIsOSBA
QAogc3RhdGljIHNzaXplX3QgY3VycmVudF9zdG9yZShzdHJ1Y3QgY2xhc3NfZGV2aWNlICpkZXYs
IGNvbnN0IGNoYXIgKmJ1Ziwgc2l6ZV90IGNvdW50KQogewogCXN0cnVjdCBjcnlwdG9fbGIgKmxi
OworCXVuc2lnbmVkIGxvbmcgZmxhZ3M7CiAKLQlzcGluX2xvY2tfYmgoJmNyeXB0b19sYl9sb2Nr
KTsKKwlzcGluX2xvY2tfaXJxc2F2ZSgmY3J5cHRvX2xiX2xvY2ssIGZsYWdzKTsKIAlsaXN0X2Zv
cl9lYWNoX2VudHJ5KGxiLCAmY3J5cHRvX2xiX2xpc3QsIGxiX2VudHJ5KQogCXsKIAkJaWYgKGNv
dW50ID09IHN0cmxlbihsYi0+bmFtZSkgJiYgIXN0cmNtcChidWYsIGxiLT5uYW1lKSkKQEAgLTIy
NCw3ICsyMjgsNyBAQAogCQkJYnJlYWs7CiAJCX0KIAl9Ci0Jc3Bpbl91bmxvY2tfYmgoJmNyeXB0
b19sYl9sb2NrKTsKKwlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZjcnlwdG9fbGJfbG9jaywgZmxh
Z3MpOwogCiAJcmV0dXJuIGNvdW50OwogfQpAQCAtMjUyLDEyICsyNTYsMTQgQEAKIAogaW5saW5l
IHZvaWQgY3J5cHRvX2xiX3JlaGFzaCh2b2lkKQogeworCXVuc2lnbmVkIGxvbmcgZmxhZ3M7CisJ
CiAJaWYgKCFjdXJyZW50X2xiKQogCQlyZXR1cm47CiAKLQlzcGluX2xvY2tfYmgoJmN1cnJlbnRf
bGItPmxvY2spOworCXNwaW5fbG9ja19pcnFzYXZlKCZjdXJyZW50X2xiLT5sb2NrLCBmbGFncyk7
CiAJY3VycmVudF9sYi0+cmVoYXNoKGN1cnJlbnRfbGIpOwotCXNwaW5fdW5sb2NrX2JoKCZjdXJy
ZW50X2xiLT5sb2NrKTsKKwlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZjdXJyZW50X2xiLT5sb2Nr
LCBmbGFncyk7CiAKIAl3YWtlX3VwX2ludGVycnVwdGlibGUoJmNyeXB0b19sYl93YWl0X3F1ZXVl
KTsKIH0KQEAgLTI2NSw2ICsyNzEsNyBAQAogc3RydWN0IGNyeXB0b19kZXZpY2UgKmNyeXB0b19s
Yl9maW5kX2RldmljZShzdHJ1Y3QgY3J5cHRvX3Nlc3Npb25faW5pdGlhbGl6ZXIgKmNpKQogewog
CXN0cnVjdCBjcnlwdG9fZGV2aWNlICpkZXY7CisJdW5zaWduZWQgbG9uZyBmbGFnczsKIAkKIAlp
ZiAoIWN1cnJlbnRfbGIpCiAJCXJldHVybiBOVUxMOwpAQCAtMjczLDcgKzI4MCw3IEBACiAJewog
CQlpbnQgZm91bmQgPSAwOwogCQkKLQkJc3Bpbl9sb2NrX2JoKGNyeXB0b19kZXZpY2VfbG9jayk7
CisJCXNwaW5fbG9ja19pcnFzYXZlKGNyeXB0b19kZXZpY2VfbG9jaywgZmxhZ3MpOwogCQlsaXN0
X2Zvcl9lYWNoX2VudHJ5KGRldiwgY3J5cHRvX2RldmljZV9saXN0LCBjZGV2X2VudHJ5KQogCQl7
CiAJCQlpZiAoZGV2LT5pZCA9PSBjaS0+YmRldikKQEAgLTI4MiwxMiArMjg5LDEyIEBACiAJCQkJ
YnJlYWs7CiAJCQl9CiAJCX0KLQkJc3Bpbl91bmxvY2tfYmgoY3J5cHRvX2RldmljZV9sb2NrKTsK
KwkJc3Bpbl91bmxvY2tfaXJxcmVzdG9yZShjcnlwdG9fZGV2aWNlX2xvY2ssIGZsYWdzKTsKIAog
CQlyZXR1cm4gKGZvdW5kKT9kZXY6TlVMTDsKIAl9CiAJCi0Jc3Bpbl9sb2NrX2JoKCZjdXJyZW50
X2xiLT5sb2NrKTsKKwlzcGluX2xvY2tfaXJxc2F2ZSgmY3VycmVudF9sYi0+bG9jaywgZmxhZ3Mp
OwogCQogCWN1cnJlbnRfbGItPnJlaGFzaChjdXJyZW50X2xiKTsKIApAQCAtMjk4LDcgKzMwNSw3
IEBACiAJCWNyeXB0b19kZXZpY2VfZ2V0KGRldik7CiAJCiAJc3Bpbl91bmxvY2soY3J5cHRvX2Rl
dmljZV9sb2NrKTsKLQlzcGluX3VubG9ja19iaCgmY3VycmVudF9sYi0+bG9jayk7CisJc3Bpbl91
bmxvY2tfaXJxcmVzdG9yZSgmY3VycmVudF9sYi0+bG9jaywgZmxhZ3MpOwogCQogCXdha2VfdXBf
aW50ZXJydXB0aWJsZSgmY3J5cHRvX2xiX3dhaXRfcXVldWUpOwogCQpAQCAtMzU2LDggKzM2Myw5
IEBACiB7CiAJc3RydWN0IGNyeXB0b19sYiAqX19sYjsKIAlpbnQgZXJyOworCXVuc2lnbmVkIGxv
bmcgZmxhZ3M7CiAJCi0Jc3Bpbl9sb2NrX2JoKCZjcnlwdG9fbGJfbG9jayk7CisJc3Bpbl9sb2Nr
X2lycXNhdmUoJmNyeXB0b19sYl9sb2NrLCBmbGFncyk7CiAJbGlzdF9mb3JfZWFjaF9lbnRyeShf
X2xiLCAmY3J5cHRvX2xiX2xpc3QsIGxiX2VudHJ5KQogCXsKIAkJaWYgKHVubGlrZWx5KGNvbXBh
cmVfbGIoX19sYiwgbGIpKSkKQEAgLTM2OSwxNCArMzc3LDE0IEBACiAJfQogCiAJbGlzdF9hZGQo
JmxiLT5sYl9lbnRyeSwgJmNyeXB0b19sYl9saXN0KTsKLQlzcGluX3VubG9ja19iaCgmY3J5cHRv
X2xiX2xvY2spOworCXNwaW5fdW5sb2NrX2lycXJlc3RvcmUoJmNyeXB0b19sYl9sb2NrLCBmbGFn
cyk7CiAJCiAJZXJyID0gX19jcnlwdG9fbGJfcmVnaXN0ZXIobGIpOwogCWlmIChlcnIpCiAJewot
CQlzcGluX2xvY2tfYmgoJmNyeXB0b19sYl9sb2NrKTsKKwkJc3Bpbl9sb2NrX2lycXNhdmUoJmNy
eXB0b19sYl9sb2NrLCBmbGFncyk7CiAJCWxpc3RfZGVsKCZsYi0+bGJfZW50cnkpOwotCQlzcGlu
X3VubG9ja19iaCgmY3J5cHRvX2xiX2xvY2spOworCQlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZj
cnlwdG9fbGJfbG9jaywgZmxhZ3MpOwogCiAJCXJldHVybiBlcnI7CiAJfQpAQCAtNDAwLDYgKzQw
OCw3IEBACiB2b2lkIGNyeXB0b19sYl91bnJlZ2lzdGVyKHN0cnVjdCBjcnlwdG9fbGIgKmxiKQog
ewogCXN0cnVjdCBjcnlwdG9fbGIgKl9fbGIsICpuOworCXVuc2lnbmVkIGxvbmcgZmxhZ3M7CiAK
IAlpZiAobGJfbnVtID09IDEpCiAJewpAQCAtNDE5LDcgKzQyOCw3IEBACiAKIAlfX2NyeXB0b19s
Yl91bnJlZ2lzdGVyKGxiKTsKIAkKLQlzcGluX2xvY2tfYmgoJmNyeXB0b19sYl9sb2NrKTsKKwlz
cGluX2xvY2tfaXJxc2F2ZSgmY3J5cHRvX2xiX2xvY2ssIGZsYWdzKTsKIAlsaXN0X2Zvcl9lYWNo
X2VudHJ5X3NhZmUoX19sYiwgbiwgJmNyeXB0b19sYl9saXN0LCBsYl9lbnRyeSkKIAl7CiAJCWlm
IChjb21wYXJlX2xiKF9fbGIsIGxiKSkKQEAgLTQzNyw3ICs0NDYsNyBAQAogCQkJCWxiX3NldF9j
dXJyZW50KGRlZmF1bHRfbGIpOwogCQl9CiAJfQotCXNwaW5fdW5sb2NrX2JoKCZjcnlwdG9fbGJf
bG9jayk7CisJc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmY3J5cHRvX2xiX2xvY2ssIGZsYWdzKTsK
IH0KIAogc3RhdGljIHZvaWQgY3J5cHRvX2xiX3F1ZXVlX3dyYXBwZXIodm9pZCAqZGF0YSkKQEAg
LTQ5MCwxNSArNDk5LDE2IEBACiB7CiAJc3RydWN0IGNyeXB0b19yb3V0ZSAqcnQ7CiAJc3RydWN0
IGNyeXB0b19kZXZpY2UgKmRldjsKKwl1bnNpZ25lZCBsb25nIGZsYWdzOwogCiAJcnQgPSBjcnlw
dG9fcm91dGVfZGVxdWV1ZShzKTsKIAlpZiAocnQpCiAJewogCQlkZXYgPSBydC0+ZGV2OwogCi0J
CXNwaW5fbG9ja19iaCgmZGV2LT5zZXNzaW9uX2xvY2spOworCQlzcGluX2xvY2tfaXJxc2F2ZSgm
ZGV2LT5zZXNzaW9uX2xvY2ssIGZsYWdzKTsKIAkJbGlzdF9kZWwoJnMtPmRldl9xdWV1ZV9lbnRy
eSk7Ci0JCXNwaW5fdW5sb2NrX2JoKCZkZXYtPnNlc3Npb25fbG9jayk7CisJCXNwaW5fdW5sb2Nr
X2lycXJlc3RvcmUoJmRldi0+c2Vzc2lvbl9sb2NrLCBmbGFncyk7CiAJCWNyeXB0b19yb3V0ZV9m
cmVlKHJ0KTsKIAogCQlkZXYgPSBjcnlwdG9fcm91dGVfZ2V0X2N1cnJlbnRfZGV2aWNlKHMpOwpA
QCAtNTIzLDEzICs1MzMsMTQgQEAKIHsKIAlzdHJ1Y3QgY3J5cHRvX3Nlc3Npb24gKnMsICpuOwog
CXN0cnVjdCBjcnlwdG9fZGV2aWNlICpkZXYgPSAoc3RydWN0IGNyeXB0b19kZXZpY2UgKilkYXRh
OworCXVuc2lnbmVkIGxvbmcgZmxhZ3M7CiAJCiAJZGFlbW9uaXplKCIlcyIsIGRldi0+bmFtZSk7
CiAJYWxsb3dfc2lnbmFsKFNJR1RFUk0pOwogCiAJd2hpbGUgKCFuZWVkX2V4aXQpCiAJewotCQlz
cGluX2xvY2tfYmgoJmRldi0+c2Vzc2lvbl9sb2NrKTsKKwkJc3Bpbl9sb2NrX2lycXNhdmUoJmRl
di0+c2Vzc2lvbl9sb2NrLCBmbGFncyk7CiAJCWxpc3RfZm9yX2VhY2hfZW50cnlfc2FmZShzLCBu
LCAmZGV2LT5zZXNzaW9uX2xpc3QsIG1haW5fcXVldWVfZW50cnkpCiAJCXsKIAkJCXByaW50aygi
c2Vzc2lvbiAlbGx1IFslbGx1XTogZmxhZ3M9JXgsIHJvdXRlX251bT0lZCwgJXMsJXMsJXMsJXMu
XG4iLCAKQEAgLTU3Miw3ICs1ODMsNyBAQAogdW5sb2NrOgogCQkJc3Bpbl91bmxvY2soJnMtPmxv
Y2spOwogCQl9Ci0JCXNwaW5fdW5sb2NrX2JoKCZkZXYtPnNlc3Npb25fbG9jayk7CisJCXNwaW5f
dW5sb2NrX2lycXJlc3RvcmUoJmRldi0+c2Vzc2lvbl9sb2NrLCBmbGFncyk7CiAKIAkJaW50ZXJy
dXB0aWJsZV9zbGVlcF9vbl90aW1lb3V0KCZjcnlwdG9fbGJfd2FpdF9xdWV1ZSwgMTAwMCk7CiAJ
fQotLS0gb3JpZy9jcnlwdG9fZGV2LmMKKysrIG1vZC9jcnlwdG9fZGV2LmMKQEAgLTExMiwxMyAr
MTEyLDE0IEBACiB7CiAJc3RydWN0IGNyeXB0b19kZXZpY2UgKmQ7CiAJaW50IG9mZiA9IDA7CisJ
dW5zaWduZWQgbG9uZyBmbGFnczsKIAotCXNwaW5fbG9ja19iaCgmY2Rldl9sb2NrKTsKKwlzcGlu
X2xvY2tfaXJxc2F2ZSgmY2Rldl9sb2NrLCBmbGFncyk7CiAJbGlzdF9mb3JfZWFjaF9lbnRyeShk
LCAmY2Rldl9saXN0LCBjZGV2X2VudHJ5KQogCXsKIAkJb2ZmICs9IHNwcmludGYoYnVmK29mZiwg
IiVzICIsIGQtPm5hbWUpOwogCX0KLQlzcGluX3VubG9ja19iaCgmY2Rldl9sb2NrKTsKKwlzcGlu
X3VubG9ja19pcnFyZXN0b3JlKCZjZGV2X2xvY2ssIGZsYWdzKTsKIAogCWlmICghb2ZmKQogCQlv
ZmYgPSBzcHJpbnRmKGJ1ZiwgIk5vIGRldmljZXMgcmVnaXN0ZXJlZCB5ZXQuIik7CkBAIC0yMjcs
OCArMjI4LDkgQEAKIHsKIAlzdHJ1Y3QgY3J5cHRvX2RldmljZSAqZGV2OwogCWludCBmb3VuZCA9
IDA7CisJdW5zaWduZWQgbG9uZyBmbGFnczsKIAkKLQlzcGluX2xvY2tfYmgoJmNkZXZfbG9jayk7
CisJc3Bpbl9sb2NrX2lycXNhdmUoJmNkZXZfbG9jaywgZmxhZ3MpOwogCWxpc3RfZm9yX2VhY2hf
ZW50cnkoZGV2LCAmY2Rldl9saXN0LCBjZGV2X2VudHJ5KQogCXsKIAkJaWYgKCFzdHJjbXAoZGV2
LT5uYW1lLCBuYW1lKSkKQEAgLTIzOCw3ICsyNDAsNyBAQAogCQkJYnJlYWs7CiAJCX0KIAl9Ci0J
c3Bpbl91bmxvY2tfYmgoJmNkZXZfbG9jayk7CisJc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmY2Rl
dl9sb2NrLCBmbGFncyk7CiAKIAlpZiAoIWZvdW5kKQogCQlyZXR1cm4gTlVMTDsKQEAgLTMwNSwx
NSArMzA3LDE2IEBACiBpbnQgY3J5cHRvX2RldmljZV9hZGQoc3RydWN0IGNyeXB0b19kZXZpY2Ug
KmRldikKIHsKIAlpbnQgZXJyOworCXVuc2lnbmVkIGxvbmcgZmxhZ3M7CiAKIAllcnIgPSBfX2Ny
eXB0b19kZXZpY2VfYWRkKGRldik7CiAJaWYgKGVycikKIAkJcmV0dXJuIGVycjsKIAotCXNwaW5f
bG9ja19iaCgmY2Rldl9sb2NrKTsKKwlzcGluX2xvY2tfaXJxc2F2ZSgmY2Rldl9sb2NrLCBmbGFn
cyk7CiAJbGlzdF9hZGQoJmRldi0+Y2Rldl9lbnRyeSwgJmNkZXZfbGlzdCk7CiAJZGV2LT5pZCA9
ICsrY2Rldl9pZHM7Ci0Jc3Bpbl91bmxvY2tfYmgoJmNkZXZfbG9jayk7CisJc3Bpbl91bmxvY2tf
aXJxcmVzdG9yZSgmY2Rldl9sb2NrLCBmbGFncyk7CiAKIAlkcHJpbnRrKEtFUk5fSU5GTyAiQ3J5
cHRvIGRldmljZSAlcyB3YXMgcmVnaXN0ZXJlZCB3aXRoIElEPSV4LlxuIiwgZGV2LT5uYW1lLCBk
ZXYtPmlkKTsKIAotLS0gb3JpZy9jcnlwdG9fbWFpbi5jCisrKyBtb2QvY3J5cHRvX21haW4uYwpA
QCAtODYsOCArODYsOSBAQAogaW5saW5lIHZvaWQgY3J5cHRvX3Nlc3Npb25faW5zZXJ0X21haW4o
c3RydWN0IGNyeXB0b19kZXZpY2UgKmRldiwgc3RydWN0IGNyeXB0b19zZXNzaW9uICpzKQogewog
CXN0cnVjdCBjcnlwdG9fc2Vzc2lvbiAqX19zOworCXVuc2lnbmVkIGxvbmcgZmxhZ3M7CiAKLQlz
cGluX2xvY2tfYmgoJmRldi0+c2Vzc2lvbl9sb2NrKTsKKwlzcGluX2xvY2tfaXJxc2F2ZSgmZGV2
LT5zZXNzaW9uX2xvY2ssIGZsYWdzKTsKIAljcnlwdG9fZGV2aWNlX2dldChkZXYpOwogCWlmICh1
bmxpa2VseShsaXN0X2VtcHR5KCZkZXYtPnNlc3Npb25fbGlzdCkpKQogCXsKQEAgLTExMCw3ICsx
MTEsNyBAQAogCQlpZiAoIWluc2VydGVkKQogCQkJbGlzdF9hZGRfdGFpbCgmcy0+bWFpbl9xdWV1
ZV9lbnRyeSwgJmRldi0+c2Vzc2lvbl9saXN0KTsKIAl9Ci0Jc3Bpbl91bmxvY2tfYmgoJmRldi0+
c2Vzc2lvbl9sb2NrKTsKKwlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZkZXYtPnNlc3Npb25fbG9j
aywgZmxhZ3MpOwogCQogCWR1bXBfY2koJnMtPmNpKTsKIAlkcHJpbnRrKCIgYWRkZWQgdG8gbWFp
biBjcnlwdG8gZGV2aWNlICVzIFslZF0uXG4iLCBkZXYtPm5hbWUsIGF0b21pY19yZWFkKCZkZXYt
PnJlZmNudCkpOwpAQCAtMTE4LDkgKzExOSwxMSBAQAogCiBpbmxpbmUgdm9pZCBjcnlwdG9fc2Vz
c2lvbl9pbnNlcnQoc3RydWN0IGNyeXB0b19kZXZpY2UgKmRldiwgc3RydWN0IGNyeXB0b19zZXNz
aW9uICpzKQogewotCXNwaW5fbG9ja19iaCgmZGV2LT5zZXNzaW9uX2xvY2spOworCXVuc2lnbmVk
IGxvbmcgZmxhZ3M7CisJCisJc3Bpbl9sb2NrX2lycXNhdmUoJmRldi0+c2Vzc2lvbl9sb2NrLCBm
bGFncyk7CiAJX19jcnlwdG9fc2Vzc2lvbl9pbnNlcnQoZGV2LCBzKTsKLQlzcGluX3VubG9ja19i
aCgmZGV2LT5zZXNzaW9uX2xvY2spOworCXNwaW5fdW5sb2NrX2lycXJlc3RvcmUoJmRldi0+c2Vz
c2lvbl9sb2NrLCBmbGFncyk7CiAJCiAJaWYgKGRldi0+ZGF0YV9yZWFkeSkKIAkJZGV2LT5kYXRh
X3JlYWR5KGRldik7CkBAIC0xOTksNiArMjAyLDcgQEAKIHsKIAlzdHJ1Y3QgY3J5cHRvX3JvdXRl
ICpydDsKIAlzdHJ1Y3QgY3J5cHRvX2RldmljZSAqZGV2OworCXVuc2lnbmVkIGxvbmcgZmxhZ3M7
CiAJCiAJQlVHX09OKGNyeXB0b19yb3V0ZV9xdWV1ZV9sZW4ocykgPiAxKTsKIAkKQEAgLTIwOCw5
ICsyMTIsOSBAQAogCiAJCWRwcmludGsoS0VSTl9JTkZPICJSZW1vdmluZyByb3V0ZSBlbnRyeSBm
b3IgZGV2aWNlICVzLlxuIiwgZGV2LT5uYW1lKTsKIAotCQlzcGluX2xvY2tfYmgoJmRldi0+c2Vz
c2lvbl9sb2NrKTsKKwkJc3Bpbl9sb2NrX2lycXNhdmUoJmRldi0+c2Vzc2lvbl9sb2NrLCBmbGFn
cyk7CiAJCWxpc3RfZGVsKCZzLT5kZXZfcXVldWVfZW50cnkpOwotCQlzcGluX3VubG9ja19iaCgm
ZGV2LT5zZXNzaW9uX2xvY2spOworCQlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZkZXYtPnNlc3Np
b25fbG9jaywgZmxhZ3MpOwogCiAJCWNyeXB0b19yb3V0ZV9mcmVlKHJ0KTsKIAl9CkBAIC0yMjcs
MTAgKzIzMSwxMSBAQAogaW5saW5lIHZvaWQgY3J5cHRvX3Nlc3Npb25fZGVxdWV1ZV9tYWluKHN0
cnVjdCBjcnlwdG9fc2Vzc2lvbiAqcykKIHsKIAlzdHJ1Y3QgY3J5cHRvX2RldmljZSAqZGV2ID0g
Jm1haW5fY3J5cHRvX2RldmljZTsKKwl1bnNpZ25lZCBsb25nIGZsYWdzOwogCQotCXNwaW5fbG9j
a19iaCgmZGV2LT5zZXNzaW9uX2xvY2spOworCXNwaW5fbG9ja19pcnFzYXZlKCZkZXYtPnNlc3Np
b25fbG9jaywgZmxhZ3MpOwogCV9fY3J5cHRvX3Nlc3Npb25fZGVxdWV1ZV9tYWluKHMpOwotCXNw
aW5fdW5sb2NrX2JoKCZkZXYtPnNlc3Npb25fbG9jayk7CisJc3Bpbl91bmxvY2tfaXJxcmVzdG9y
ZSgmZGV2LT5zZXNzaW9uX2xvY2ssIGZsYWdzKTsKIH0KIAogaW50IF9fZGV2aW5pdCBjbWFpbl9p
bml0KHZvaWQpCi0tLSBvcmlnL2NyeXB0b19yb3V0ZS5oCisrKyBtb2QvY3J5cHRvX3JvdXRlLmgK
QEAgLTc3LDEzICs3NywxNCBAQAogc3RhdGljIGlubGluZSB2b2lkIGNyeXB0b19yb3V0ZV9kZWwo
c3RydWN0IGNyeXB0b19yb3V0ZSAqcnQpCiB7CiAJc3RydWN0IGNyeXB0b19yb3V0ZV9oZWFkICps
aXN0ID0gcnQtPmxpc3Q7CisJdW5zaWduZWQgbG9uZyBmbGFnczsKIAogCWlmIChsaXN0KQogCXsK
LQkJc3Bpbl9sb2NrX2JoKCZsaXN0LT5sb2NrKTsKKwkJc3Bpbl9sb2NrX2lycXNhdmUoJmxpc3Qt
PmxvY2ssIGZsYWdzKTsKIAkJaWYgKGxpc3QgPT0gcnQtPmxpc3QpCiAJCQlfX2NyeXB0b19yb3V0
ZV9kZWwocnQsIHJ0LT5saXN0KTsKLQkJc3Bpbl91bmxvY2tfYmgoJmxpc3QtPmxvY2spOworCQlz
cGluX3VubG9ja19pcnFyZXN0b3JlKCZsaXN0LT5sb2NrLCBmbGFncyk7CiAKIAkJY3J5cHRvX3Jv
dXRlX2ZyZWUocnQpOwogCX0KQEAgLTExMSwxMCArMTEyLDExIEBACiBzdGF0aWMgaW5saW5lIHN0
cnVjdCBjcnlwdG9fcm91dGUgKmNyeXB0b19yb3V0ZV9kZXF1ZXVlKHN0cnVjdCBjcnlwdG9fc2Vz
c2lvbiAqcykKIHsKIAlzdHJ1Y3QgY3J5cHRvX3JvdXRlICpydDsKKwl1bnNpZ25lZCBsb25nIGZs
YWdzOwogCQotCXNwaW5fbG9ja19iaCgmcy0+cm91dGVfbGlzdC5sb2NrKTsKKwlzcGluX2xvY2tf
aXJxc2F2ZSgmcy0+cm91dGVfbGlzdC5sb2NrLCBmbGFncyk7CiAJcnQgPSBfX2NyeXB0b19yb3V0
ZV9kZXF1ZXVlKCZzLT5yb3V0ZV9saXN0KTsKLQlzcGluX3VubG9ja19iaCgmcy0+cm91dGVfbGlz
dC5sb2NrKTsKKwlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZzLT5yb3V0ZV9saXN0LmxvY2ssIGZs
YWdzKTsKIAogCXJldHVybiBydDsKIH0KQEAgLTEzNCw5ICsxMzYsMTEgQEAKIAogc3RhdGljIGlu
bGluZSB2b2lkIGNyeXB0b19yb3V0ZV9xdWV1ZShzdHJ1Y3QgY3J5cHRvX3JvdXRlICpydCwgc3Ry
dWN0IGNyeXB0b19zZXNzaW9uICpzKQogewotCXNwaW5fbG9ja19iaCgmcy0+cm91dGVfbGlzdC5s
b2NrKTsKKwl1bnNpZ25lZCBsb25nIGZsYWdzOworCQorCXNwaW5fbG9ja19pcnFzYXZlKCZzLT5y
b3V0ZV9saXN0LmxvY2ssIGZsYWdzKTsKIAlfX2NyeXB0b19yb3V0ZV9xdWV1ZShydCwgJnMtPnJv
dXRlX2xpc3QpOwotCXNwaW5fdW5sb2NrX2JoKCZzLT5yb3V0ZV9saXN0LmxvY2spOworCXNwaW5f
dW5sb2NrX2lycXJlc3RvcmUoJnMtPnJvdXRlX2xpc3QubG9jaywgZmxhZ3MpOwogfQogCiBzdGF0
aWMgaW5saW5lIGludCBjcnlwdG9fcm91dGVfYWRkKHN0cnVjdCBjcnlwdG9fZGV2aWNlICpkZXYs
IHN0cnVjdCBjcnlwdG9fc2Vzc2lvbiAqcywgc3RydWN0IGNyeXB0b19zZXNzaW9uX2luaXRpYWxp
emVyICpjaSkKQEAgLTE4MSwxNCArMTg1LDE1IEBACiB7CiAJc3RydWN0IGNyeXB0b19yb3V0ZV9o
ZWFkICpsaXN0OwogCXN0cnVjdCBjcnlwdG9fcm91dGUgKnJ0ID0gTlVMTDsKKwl1bnNpZ25lZCBs
b25nIGZsYWdzOwogCiAJbGlzdCA9ICZzLT5yb3V0ZV9saXN0OwogCiAJaWYgKGxpc3QpCiAJewot
CQlzcGluX2xvY2tfYmgoJmxpc3QtPmxvY2spOworCQlzcGluX2xvY2tfaXJxc2F2ZSgmbGlzdC0+
bG9jaywgZmxhZ3MpOwogCQlydCA9IF9fY3J5cHRvX3JvdXRlX2N1cnJlbnQobGlzdCk7Ci0JCXNw
aW5fdW5sb2NrX2JoKCZsaXN0LT5sb2NrKTsKKwkJc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmbGlz
dC0+bG9jaywgZmxhZ3MpOwogCX0KIAogCXJldHVybiBydDsKQEAgLTE5OSwxNiArMjA0LDE2IEBA
CiAJc3RydWN0IGNyeXB0b19yb3V0ZSAqcnQgPSBOVUxMOwogCXN0cnVjdCBjcnlwdG9fZGV2aWNl
ICpkZXYgPSBOVUxMOwogCXN0cnVjdCBjcnlwdG9fcm91dGVfaGVhZCAqbGlzdCA9ICZzLT5yb3V0
ZV9saXN0OworCXVuc2lnbmVkIGxvbmcgZmxhZ3M7CiAKLQlzcGluX2xvY2tfYmgoJmxpc3QtPmxv
Y2spOworCXNwaW5fbG9ja19pcnFzYXZlKCZsaXN0LT5sb2NrLCBmbGFncyk7CiAJcnQgPSBfX2Ny
eXB0b19yb3V0ZV9jdXJyZW50KGxpc3QpOwogCWlmIChydCkKIAl7CiAJCWRldiA9IHJ0LT5kZXY7
CiAJCWNyeXB0b19kZXZpY2VfZ2V0KGRldik7CiAJfQotCXNwaW5fdW5sb2NrX2JoKCZsaXN0LT5s
b2NrKTsKLQkKKwlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZsaXN0LT5sb2NrLCBmbGFncyk7CiAJ
cmV0dXJuIGRldjsKIH0KIAotLS0gb3JpZy9jcnlwdG9fc3RhdC5jCisrKyBtb2QvY3J5cHRvX3N0
YXQuYwpAQCAtMzQsMTMgKzM0LDE0IEBACiBpbmxpbmUgdm9pZCBjcnlwdG9fc3RhdF9zdGFydF9p
bmMoc3RydWN0IGNyeXB0b19zZXNzaW9uICpzKQogewogCXN0cnVjdCBjcnlwdG9fZGV2aWNlICpk
ZXY7CisJdW5zaWduZWQgbG9uZyBmbGFnczsKIAogCWRldiA9IGNyeXB0b19yb3V0ZV9nZXRfY3Vy
cmVudF9kZXZpY2Uocyk7CiAJaWYgKGRldikKIAl7Ci0JCXNwaW5fbG9ja19iaCgmZGV2LT5zdGF0
X2xvY2spOworCQlzcGluX2xvY2tfaXJxc2F2ZSgmZGV2LT5zdGF0X2xvY2ssIGZsYWdzKTsKIAkJ
ZGV2LT5zdGF0LnNzdGFydGVkKys7Ci0JCXNwaW5fdW5sb2NrX2JoKCZkZXYtPnN0YXRfbG9jayk7
CisJCXNwaW5fdW5sb2NrX2lycXJlc3RvcmUoJmRldi0+c3RhdF9sb2NrLCBmbGFncyk7CiAKIAkJ
Y3J5cHRvX2RldmljZV9wdXQoZGV2KTsKIAl9CkBAIC00OSwxMyArNTAsMTQgQEAKIGlubGluZSB2
b2lkIGNyeXB0b19zdGF0X2ZpbmlzaF9pbmMoc3RydWN0IGNyeXB0b19zZXNzaW9uICpzKQogewog
CXN0cnVjdCBjcnlwdG9fZGV2aWNlICpkZXY7CisJdW5zaWduZWQgbG9uZyBmbGFnczsKIAogCWRl
diA9IGNyeXB0b19yb3V0ZV9nZXRfY3VycmVudF9kZXZpY2Uocyk7CiAJaWYgKGRldikKIAl7Ci0J
CXNwaW5fbG9ja19iaCgmZGV2LT5zdGF0X2xvY2spOworCQlzcGluX2xvY2tfaXJxc2F2ZSgmZGV2
LT5zdGF0X2xvY2ssIGZsYWdzKTsKIAkJZGV2LT5zdGF0LnNmaW5pc2hlZCsrOwotCQlzcGluX3Vu
bG9ja19iaCgmZGV2LT5zdGF0X2xvY2spOworCQlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZkZXYt
PnN0YXRfbG9jaywgZmxhZ3MpOwogCiAJCWNyeXB0b19kZXZpY2VfcHV0KGRldik7CiAJfQpAQCAt
NjQsMTMgKzY2LDE0IEBACiBpbmxpbmUgdm9pZCBjcnlwdG9fc3RhdF9jb21wbGV0ZV9pbmMoc3Ry
dWN0IGNyeXB0b19zZXNzaW9uICpzKQogewogCXN0cnVjdCBjcnlwdG9fZGV2aWNlICpkZXY7CisJ
dW5zaWduZWQgbG9uZyBmbGFnczsKIAogCWRldiA9IGNyeXB0b19yb3V0ZV9nZXRfY3VycmVudF9k
ZXZpY2Uocyk7CiAJaWYgKGRldikKIAl7Ci0JCXNwaW5fbG9ja19iaCgmZGV2LT5zdGF0X2xvY2sp
OworCQlzcGluX2xvY2tfaXJxc2F2ZSgmZGV2LT5zdGF0X2xvY2ssIGZsYWdzKTsKIAkJZGV2LT5z
dGF0LnNjb21wbGV0ZWQrKzsKLQkJc3Bpbl91bmxvY2tfYmgoJmRldi0+c3RhdF9sb2NrKTsKKwkJ
c3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmZGV2LT5zdGF0X2xvY2ssIGZsYWdzKTsKIAogCQljcnlw
dG9fZGV2aWNlX3B1dChkZXYpOwogCX0KKiBsb29raW5nIGZvciBqb2hucG9sQDJrYS5taXB0LnJ1
LTIwMDQvY3J5cHRvLS1tYWluLS0wLS1wYXRjaC01MiB0byBjb21wYXJlIHdpdGgKKiBjb21wYXJp
bmcgdG8gam9obnBvbEAya2EubWlwdC5ydS0yMDA0L2NyeXB0by0tbWFpbi0tMC0tcGF0Y2gtNTIK
TSAgY3J5cHRvX21haW4uYwpNICBhY3J5cHRvLmgKTSAgY3J5cHRvX2xiLmMKTSAgY3J5cHRvX2Nv
bm4uYwoKKiBtb2RpZmllZCBmaWxlcwoKLS0tIG9yaWcvYWNyeXB0by5oCisrKyBtb2QvYWNyeXB0
by5oCkBAIC0xMDQsNyArMTA0LDcgQEAKIAogI2luY2x1ZGUgPGFzbS9zY2F0dGVybGlzdC5oPgog
Ci0jZGVmaW5lIERFQlVHCisvLyNkZWZpbmUgREVCVUcKICNpZmRlZiBERUJVRwogI2RlZmluZSBk
cHJpbnRrKGYsIGEuLi4pIHByaW50ayhLRVJOX0VNRVJHIGYsICMjYSkKICNlbHNlCgoKLS0tIG9y
aWcvY3J5cHRvX2Nvbm4uYworKysgbW9kL2NyeXB0b19jb25uLmMKQEAgLTQ0LDYgKzQ0LDcgQEAK
IAlzdHJ1Y3QgY3J5cHRvX2Nvbm5fZGF0YSAqZCwgKmNtZDsKIAlzdHJ1Y3QgY3J5cHRvX2Rldmlj
ZSAqZGV2OwogCXUzMiBzZXNzaW9uczsKKwl1bnNpZ25lZCBsb25nIGZsYWdzOwogCiAgICAgICAg
CW1zZyA9IChzdHJ1Y3QgY25fbXNnICopZGF0YTsKICAgICAgICAJZCA9IChzdHJ1Y3QgY3J5cHRv
X2Nvbm5fZGF0YSAqKW1zZy0+ZGF0YTsKQEAgLTExNiw3ICsxMTcsNyBAQAogCQkJcHRyID0gKHN0
cnVjdCBjcnlwdG9fc2Vzc2lvbl9pbml0aWFsaXplciAqKShjbWQrMSk7CiAKIAkJCXNlc3Npb25z
ID0gMDsKLQkJCXNwaW5fbG9ja19iaCgmZGV2LT5zZXNzaW9uX2xvY2spOworCQkJc3Bpbl9sb2Nr
X2lycXNhdmUoJmRldi0+c2Vzc2lvbl9sb2NrLCBmbGFncyk7CiAJCQlsaXN0X2Zvcl9lYWNoX2Vu
dHJ5KHMsICZkZXYtPnNlc3Npb25fbGlzdCwgZGV2X3F1ZXVlX2VudHJ5KQogCQkJewogCQkJCW1l
bWNweShwdHIsICZzLT5jaSwgc2l6ZW9mKCpwdHIpKTsKQEAgLTEyNiw3ICsxMjcsNyBAQAogCQkJ
CWlmIChzZXNzaW9ucyA+PSAxMDI0KQogCQkJCQlicmVhazsKIAkJCX0KLQkJCXNwaW5fdW5sb2Nr
X2JoKCZkZXYtPnNlc3Npb25fbG9jayk7CisJCQlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZkZXYt
PnNlc3Npb25fbG9jaywgZmxhZ3MpOwogCQkJCiAJCQljbWQtPmxlbiA9IHNpemVvZigqcHRyKSpz
ZXNzaW9uczsKIAkJCXJlcGx5LT5sZW4gPSBzaXplb2YoKmNtZCkgKyBjbWQtPmxlbjsKCgotLS0g
b3JpZy9jcnlwdG9fbGIuYworKysgbW9kL2NyeXB0b19sYi5jCkBAIC0zNzAsNyArMzcwLDcgQEAK
IAl7CiAJCWlmICh1bmxpa2VseShjb21wYXJlX2xiKF9fbGIsIGxiKSkpCiAJCXsKLQkJCXNwaW5f
dW5sb2NrX2JoKCZjcnlwdG9fbGJfbG9jayk7CisJCQlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZj
cnlwdG9fbGJfbG9jaywgZmxhZ3MpOwogCQkJZHByaW50ayhLRVJOX0VSUiAiQ3J5cHRvIGxvYWQg
YmFsYW5jZXIgJXMgaXMgYWxyZWFkeSByZWdpc3RlcmVkLlxuIiwgbGItPm5hbWUpOwogCQkJcmV0
dXJuIC1FSU5WQUw7CiAJCX0KQEAgLTU0Myw3ICs1NDMsNyBAQAogCQlzcGluX2xvY2tfaXJxc2F2
ZSgmZGV2LT5zZXNzaW9uX2xvY2ssIGZsYWdzKTsKIAkJbGlzdF9mb3JfZWFjaF9lbnRyeV9zYWZl
KHMsIG4sICZkZXYtPnNlc3Npb25fbGlzdCwgbWFpbl9xdWV1ZV9lbnRyeSkKIAkJewotCQkJcHJp
bnRrKCJzZXNzaW9uICVsbHUgWyVsbHVdOiBmbGFncz0leCwgcm91dGVfbnVtPSVkLCAlcywlcywl
cywlcy5cbiIsIAorCQkJZHByaW50aygic2Vzc2lvbiAlbGx1IFslbGx1XTogZmxhZ3M9JXgsIHJv
dXRlX251bT0lZCwgJXMsJXMsJXMsJXMuXG4iLCAKIAkJCQkJcy0+Y2kuaWQsIHMtPmNpLmRldl9p
ZCwgcy0+Y2kuZmxhZ3MsIAogCQkJCQljcnlwdG9fcm91dGVfcXVldWVfbGVuKHMpLAogCQkJCQko
c2Vzc2lvbl9jb21wbGV0ZWQocykpPyJjb21wbGV0ZWQiOiAibm90IGNvbXBsZXRlZCIsCgoKLS0t
IG9yaWcvY3J5cHRvX21haW4uYworKysgbW9kL2NyeXB0b19tYWluLmMKQEAgLTE2OSw4ICsxNjks
NiBAQAogCQlpZiAoZC0+cHJpdikKIAkJCW1lbWNweShzLT5kYXRhLnByaXYsIGQtPnByaXYsIGQt
PnByaXZfc2l6ZSk7CiAJfQotCWVsc2UKLQkJcy0+ZGF0YS5wcml2ID0gTlVMTDsKIAogCXMtPmNp
LmlkIAk9IGRldi0+c2lkKys7CiAJcy0+Y2kuZGV2X2lkIAk9IGxkZXYtPnNpZCsrOwoKCgo=

--Multipart=_Sun__31_Oct_2004_00_37_49_+0400_a+IT5K62.Lt7UdpI--
