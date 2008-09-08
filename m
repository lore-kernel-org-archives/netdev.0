From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: New distributed storage release.
Date: Mon, 8 Sep 2008 21:43:24 +0400
Message-ID: <20080908174324.GA18400@2ka.mipt.ru>
References: <20080908152201.GA14015@2ka.mipt.ru> <alpine.LNX.2.00.0809081818001.19109@titan.stealer.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Sven Wegener <sven.wegener@stealer.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.0809081818001.19109@titan.stealer.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sven.

Thanks for the review.

On Mon, Sep 08, 2008 at 07:19:49PM +0200, Sven Wegener (sven.wegener@stealer.net) wrote:
> Some warnings:
> 
>   CC [M]  drivers/block/dst/state.o
> drivers/block/dst/state.c: In function 'dst_recv_bio':
> drivers/block/dst/state.c:396: warning: format '%llu' expects type 'long long unsigned int', but argument 3 has type 'sector_t'
> drivers/block/dst/state.c: In function 'dst_process_io_response':
> drivers/block/dst/state.c:434: warning: format '%llu' expects type 'long long unsigned int', but argument 3 has type 'sector_t'
>   CC [M]  drivers/block/dst/export.o
> drivers/block/dst/export.c: In function 'dst_accept':
> drivers/block/dst/export.c:249: warning: 'main' is usually a function
> drivers/block/dst/export.c: In function 'dst_export_read_request':
> drivers/block/dst/export.c:405: warning: format '%llu' expects type 'long long unsigned int', but argument 3 has type 'sector_t'
> drivers/block/dst/export.c: In function 'dst_process_io':
> drivers/block/dst/export.c:520: warning: format '%llu' expects type 'long long unsigned int', but argument 3 has type 'sector_t'
> drivers/block/dst/export.c: In function 'dst_export_send_bio':
> drivers/block/dst/export.c:541: warning: format '%llu' expects type 'long long unsigned int', but argument 4 has type 'sector_t'
>   CC [M]  drivers/block/dst/crypto.o
> drivers/block/dst/crypto.c: In function 'dst_export_crypto_action':
> drivers/block/dst/crypto.c:623: warning: format '%llu' expects type 'long long unsigned int', but argument 5 has type 'sector_t'
>   CC [M]  drivers/block/dst/trans.o
> drivers/block/dst/trans.c: In function 'dst_trans_insert':
> drivers/block/dst/trans.c:87: warning: format '%llu' expects type 'long long unsigned int', but argument 4 has type 'sector_t'
> drivers/block/dst/trans.c:87: warning: format '%llu' expects type 'long long unsigned int', but argument 8 has type 'sector_t'
> drivers/block/dst/trans.c:95: warning: format '%llu' expects type 'long long unsigned int', but argument 4 has type 'sector_t'
> drivers/block/dst/trans.c: In function 'dst_process_bio':
> drivers/block/dst/trans.c:160: warning: format '%llu' expects type 'long long unsigned int', but argument 4 has type 'sector_t'

Yup, sector_t is diffrent depending on arch and config options (u64 vs unsigned long),
so it is not possible to represent it correctly without dereferencing
to another type.

> > diff --git a/drivers/block/dst/Kconfig b/drivers/block/dst/Kconfig
> > new file mode 100644
> > index 0000000..0b641f0
> > --- /dev/null
> > +++ b/drivers/block/dst/Kconfig
> > @@ -0,0 +1,18 @@
> > +menuconfig DST
> 
> uhm, menuconfig, and then just the debug option there seems wrong.

In case of extended functionality there will be no need to change config
options, now it looks like single string in the higher layer config.

> > +	ctl->crypto_attached_size = crypto_hash_digestsize(hash);
> > +
> > +	dprintk("%s: keysize: %u, key: ", __func__, ctl->hash_keysize);
> > +	for (err = 0; err < ctl->hash_keysize; ++err)
> > +		printk("%02x ", key[err]);
> > +	printk("\n");
> 
> You don't want to print the key unconditional.

Debug prints are not supposed to be turned on except on very serious
conditions. In this case we do need to have as much info as possible (like
non-matching keys on different nodes for someone who cares).

> > +static struct crypto_ablkcipher *dst_init_cipher(struct dst_crypto_ctl *ctl, u8 *key)
> > +{
> > +	int err = -EINVAL;
> 
> Needless initialization. There are more in the code.
> 
> > +	struct crypto_ablkcipher *cipher;
> > +
> > +	if (!ctl->cipher_keysize)
> > +		goto err_out_exit;

No, it is needed here.

> > +static int dst_crypt(struct dst_crypto_engine *e, struct bio *bio)
> > +{
> > +	struct ablkcipher_request *req = e->data;
> > +
> > +	memset(req, 0, sizeof(struct ablkcipher_request));
> 
> sizeof(*req) is preferred, likewise for other sizeof() uses in the code.

No, I do belive that grepping over |struct ablkcipher_request| when
something is about to be changed is more convenient, than searching for
the structure name and then object name itself.
It is matter of a taste though.

> > +void dst_node_crypto_exit(struct dst_node *n)
> > +{
> > +	struct dst_crypto_ctl *ctl = &n->crypto;
> > +
> > +	if (ctl->cipher_algo[0] || ctl->hash_algo[0]) {
> 
> other code uses hash_keysize and cipher_keysize for checking

It is possible to use hash without key, so I need to use algo name.

> > +int pohmelfs_crypto_init(struct pohmelfs_sb *psb)
> > +{
> > +	int err;
> > +
> > +	if (!psb->cipher_algo && !psb->hash_algo)
> > +		return 0;
> > +
> > +	err = pohmelfs_crypto_init_handshake(psb);
> > +	if (err)
> > +		return err;
> > +
> > +	err = pohmelfs_sys_crypto_init(psb);
> > +	if (err)
> > +		return err;
> > +
> > +	return 0;
> > +}
> > +#endif
> 
> Guess this code can be removed, instead of #if 0.

I guess so. Commented code was used for older crypto initialization and
crypto handshake, which is not used currently (but can be added though).

> > +static char dst_name[] = "Succumbed to live ant.";
> 
> const

Yup. I also need to change the name.

> > +static int dst_create_node_attributes(struct dst_node *n)
> > +{
> > +	int err, i;
> > +
> > +	for (i=0; i<ARRAY_SIZE(dst_node_attrs); ++i)
> > +		err = device_create_file(&n->device,
> > +				&dst_node_attrs[i]);
> 
> If you really want to ignore the return value, use
> 
> (void) device_create_file(...)

I just want to shut up the compiler, since failing to register
informational attribute is not critical. But it could also be
used to fall the initialization.

> > +	err = dst_commands[ctl->cmd](n, ctl, msg->data + sizeof(struct dst_ctl),
> > +			msg->len - sizeof(struct dst_ctl));
> > +
> > +	dst_node_put(n);
> > +out:
> > +	ack = kmalloc(sizeof(struct dst_ctl_ack), GFP_KERNEL);
> 
> struct dst_ctl_ack seems to be quite small, guess there's no need for
> dynamic allocation.

36 bytes iirc - not that small for stack allocation I think.

> > +static int dst_sysfs_init(void)
> 
> __init

Yup.

> > +void thread_pool_del_worker(struct thread_pool *p)
> > +{
> > +	struct thread_pool_worker *w = NULL;
> > +
> > +	while (!w) {
> > +		wait_event(p->wait, !list_empty(&p->ready_list) || !p->thread_num);
> > +
> > +		dprintk("%s: locking list_empty: %d, thread_num: %d.\n",
> > +				__func__, list_empty(&p->ready_list), p->thread_num);
> > +
> > +		mutex_lock(&p->thread_lock);
> > +		if (!list_empty(&p->ready_list)) {
> > +			w = list_first_entry(&p->ready_list,
> > +					struct thread_pool_worker,
> > +					worker_entry);
> > +
> > +			dprintk("%s: deleting w: %p, thread_num: %d, list: %p [%p.%p].\n",
> > +					__func__, w, p->thread_num, &p->ready_list,
> > +					p->ready_list.prev, p->ready_list.next);
> > +
> > +			p->thread_num--;
> > +			list_del(&w->worker_entry);
> > +		}
> > +		mutex_unlock(&p->thread_lock);
> > +	}
> > +
> > +	if (w)
> > +		thread_pool_exit_worker(w);
> > +	dprintk("%s: deleted w: %p, thread_num: %d.\n", __func__, w, p->thread_num);
> > +}
> > +
> > +void thread_pool_del_worker_id(struct thread_pool *p, unsigned int id)
> > +{
> > +	struct thread_pool_worker *w, *tmp;
> > +	int found = 0;
> > +
> > +	mutex_lock(&p->thread_lock);
> > +	list_for_each_entry_safe(w, tmp, &p->ready_list, worker_entry) {
> > +		if (w->id == id) {
> > +			found = 1;
> > +			p->thread_num--;
> > +			list_del(&w->worker_entry);
> > +			break;
> 
> I don't think you need the safe loop version, if you directly break the
> loop.
> 
> > +		}
> > +	}
> > +
> > +	if (!found) {
> > +		list_for_each_entry_safe(w, tmp, &p->active_list, worker_entry) {
> 
> You don't modify the list inside the loop, no need for the safe version.

It was just copy-pasted :)

-- 
	Evgeniy Polyakov
