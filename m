From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] poll: Avoid extra wakeups in select/poll
Date: Wed, 29 Apr 2009 12:27:34 +0200
Message-ID: <20090429102734.GC2373@elte.hu>
References: <alpine.DEB.1.10.0904241554100.29995@qirst.com> <49F3308B.1030507@cosmosbay.com> <20090426.020411.157511269.davem@davemloft.net> <49F43B8F.2050907@cosmosbay.com> <87ab60rh8t.fsf@basil.nowhere.org> <49F71B63.8010503@cosmosbay.com> <20090429091637.GA29874@elte.hu> <49F81FB9.50504@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux kernel <linux-kernel@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, cl@linux.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	haoki@redhat.com, mchan@broadcom.com, davidel@xmailserver.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:53103 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751929AbZD2K2F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2009 06:28:05 -0400
Content-Disposition: inline
In-Reply-To: <49F81FB9.50504@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Eric Dumazet <dada1@cosmosbay.com> wrote:

> Ingo Molnar a =E9crit :
> > * Eric Dumazet <dada1@cosmosbay.com> wrote:
> >=20
> >> @@ -418,8 +429,16 @@ int do_select(int n, fd_set_bits *fds, struct=
 timespec *end_time)
> >>  				if (file) {
> >>  					f_op =3D file->f_op;
> >>  					mask =3D DEFAULT_POLLMASK;
> >> -					if (f_op && f_op->poll)
> >> +					if (f_op && f_op->poll) {
> >> +						if (wait) {
> >> +							wait->key =3D POLLEX_SET;
> >> +							if (in & bit)
> >> +								wait->key |=3D POLLIN_SET;
> >> +							if (out & bit)
> >> +								wait->key |=3D POLLOUT_SET;
> >> +						}
> >>  						mask =3D (*f_op->poll)(file, retval ? NULL : wait);
> >> +					}
> >>  					fput_light(file, fput_needed);
> >>  					if ((mask & POLLIN_SET) && (in & bit)) {
> >>  						res_in |=3D bit;
> >=20
> > Please factor this whole 'if (file)' branch out into a helper.=20
> > Typical indentation levels go from 1 to 3 tabs - 4 should be avoide=
d=20
> > if possible and 5 is pretty excessive already. This goes to eight.
> >=20
>=20
> Thanks Ingo,
>=20
> Here is v3 of patch, with your Acked-by included :)
>=20
> This is IMHO clearer since helper immediatly follows POLLIN_SET / POL=
LOUT_SET /
> POLLEX_SET defines.
>=20
> [PATCH] poll: Avoid extra wakeups in select/poll
>=20
> After introduction of keyed wakeups Davide Libenzi did on epoll, we
> are able to avoid spurious wakeups in poll()/select() code too.
>=20
> For example, typical use of poll()/select() is to wait for incoming
> network frames on many sockets. But TX completion for UDP/TCP=20
> frames call sock_wfree() which in turn schedules thread.
>=20
> When scheduled, thread does a full scan of all polled fds and
> can sleep again, because nothing is really available. If number
> of fds is large, this cause significant load.
>=20
> This patch makes select()/poll() aware of keyed wakeups and
> useless wakeups are avoided. This reduces number of context
> switches by about 50% on some setups, and work performed
> by sofirq handlers.
>=20
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> Acked-by: David S. Miller <davem@davemloft.net>
> Acked-by: Andi Kleen <ak@linux.intel.com>
> Acked-by: Ingo Molnar <mingo@elte.hu>

> ---
>  fs/select.c          |   40 ++++++++++++++++++++++++++++++++++++----
>  include/linux/poll.h |    3 +++
>  2 files changed, 39 insertions(+), 4 deletions(-)
>=20
> diff --git a/fs/select.c b/fs/select.c
> index 0fe0e14..ba068ad 100644
> --- a/fs/select.c
> +++ b/fs/select.c
> @@ -168,7 +168,7 @@ static struct poll_table_entry *poll_get_entry(st=
ruct poll_wqueues *p)
>  	return table->entry++;
>  }
> =20
> -static int pollwake(wait_queue_t *wait, unsigned mode, int sync, voi=
d *key)
> +static int __pollwake(wait_queue_t *wait, unsigned mode, int sync, v=
oid *key)
>  {
>  	struct poll_wqueues *pwq =3D wait->private;
>  	DECLARE_WAITQUEUE(dummy_wait, pwq->polling_task);
> @@ -194,6 +194,16 @@ static int pollwake(wait_queue_t *wait, unsigned=
 mode, int sync, void *key)
>  	return default_wake_function(&dummy_wait, mode, sync, key);
>  }
> =20
> +static int pollwake(wait_queue_t *wait, unsigned mode, int sync, voi=
d *key)
> +{
> +	struct poll_table_entry *entry;
> +
> +	entry =3D container_of(wait, struct poll_table_entry, wait);
> +	if (key && !((unsigned long)key & entry->key))
> +		return 0;
> +	return __pollwake(wait, mode, sync, key);
> +}
> +
>  /* Add a new entry */
>  static void __pollwait(struct file *filp, wait_queue_head_t *wait_ad=
dress,
>  				poll_table *p)
> @@ -205,6 +215,7 @@ static void __pollwait(struct file *filp, wait_qu=
eue_head_t *wait_address,
>  	get_file(filp);
>  	entry->filp =3D filp;
>  	entry->wait_address =3D wait_address;
> +	entry->key =3D p->key;
>  	init_waitqueue_func_entry(&entry->wait, pollwake);
>  	entry->wait.private =3D pwq;
>  	add_wait_queue(wait_address, &entry->wait);
> @@ -362,6 +373,18 @@ get_max:
>  #define POLLOUT_SET (POLLWRBAND | POLLWRNORM | POLLOUT | POLLERR)
>  #define POLLEX_SET (POLLPRI)
> =20
> +static void wait_key_set(poll_table *wait, unsigned long in,
> +			 unsigned long out, unsigned long bit)
> +{
> +	if (wait) {
> +		wait->key =3D POLLEX_SET;
> +		if (in & bit)
> +			wait->key |=3D POLLIN_SET;
> +		if (out & bit)
> +			wait->key |=3D POLLOUT_SET;
> +	}
> +}

should be inline perhaps?

> +
>  int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
>  {
>  	ktime_t expire, *to =3D NULL;
> @@ -418,20 +441,25 @@ int do_select(int n, fd_set_bits *fds, struct t=
imespec *end_time)
>  				if (file) {
>  					f_op =3D file->f_op;
>  					mask =3D DEFAULT_POLLMASK;
> -					if (f_op && f_op->poll)
> -						mask =3D (*f_op->poll)(file, retval ? NULL : wait);
> +					if (f_op && f_op->poll) {
> +						wait_key_set(wait, in, out, bit);
> +						mask =3D (*f_op->poll)(file, wait);
> +					}
>  					fput_light(file, fput_needed);
>  					if ((mask & POLLIN_SET) && (in & bit)) {
>  						res_in |=3D bit;
>  						retval++;
> +						wait =3D NULL;
>  					}
>  					if ((mask & POLLOUT_SET) && (out & bit)) {
>  						res_out |=3D bit;
>  						retval++;
> +						wait =3D NULL;
>  					}
>  					if ((mask & POLLEX_SET) && (ex & bit)) {
>  						res_ex |=3D bit;
>  						retval++;
> +						wait =3D NULL;
>  					}
>  				}
>  			}

Looks much nicer now!  [ I'd still suggest to factor out the guts of=20
do_select() as its nesting is excessive that hurts its reviewability=20
quite a bit - but now your patch does not make the situation any=20
worse. ]

Even-More-Acked-by: Ingo Molnar <mingo@elte.hu>

	Ingo
