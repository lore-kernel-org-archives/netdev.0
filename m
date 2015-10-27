From: xiakaixu <xiakaixu@huawei.com>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Tue, 27 Oct 2015 14:43:45 +0800
Message-ID: <562F1D21.1050607@huawei.com>
References: <56279634.5000606@huawei.com> <20151021134951.GH3604@twins.programming.kicks-ass.net> <1D2C9396-01CB-4981-B493-EA311F0457E7@163.com> <20151021140921.GI3604@twins.programming.kicks-ass.net> <586A5B33-C9C9-433D-B6E9-019264BF7DDB@163.com> <20151021165758.GK3604@twins.programming.kicks-ass.net> <56280175.8060404@plumgrid.com> <20151022090632.GK2508@worktop.programming.kicks-ass.net> <5628BA46.8060307@huawei.com> <20151023125211.GB17308@twins.programming.kicks-ass.net> <20151023151205.GW11639@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Wangnan (F)" <wangnan0@huawei.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	pi3orama <pi3orama@163.com>, <davem@davemloft.net>,
	<acme@kernel.org>, <mingo@redhat.com>,
	<masami.hiramatsu.pt@hitachi.com>, <jolsa@kernel.org>,
	<daniel@iogearbox.net>, <linux-kernel@vger.kernel.org>,
	<hekuang@huawei.com>, <netdev@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:17466 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493AbbJ0Goj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 02:44:39 -0400
In-Reply-To: <20151023151205.GW11639@twins.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015/10/23 23:12, Peter Zijlstra =E5=86=99=E9=81=93:
> On Fri, Oct 23, 2015 at 02:52:11PM +0200, Peter Zijlstra wrote:
>> On Thu, Oct 22, 2015 at 06:28:22PM +0800, Wangnan (F) wrote:
>>> information to analysis when glitch happen. Another way we are tryi=
ng to
>>> implement
>>> now is to dynamically turn events on and off, or at least enable/di=
sable
>>> sampling dynamically because the overhead of copying those samples
>>> is a big part of perf's total overhead. After that we can trace as =
many
>>> event as possible, but only fetch data from them when we detect a g=
litch.
>>
>> So why don't you 'fix' the flight recorder mode and just leave the d=
ata
>> in memory and not bother copying it out until a glitch happens?
>>
>> Something like this:
>>
>> lkml.kernel.org/r/20130708121557.GA17211@twins.programming.kicks-ass=
=2Enet
>>
>> it appears we never quite finished that.
>=20
> Updated to current sources, compile tested only.
>=20
> It obviously needs testing and performance numbers..  and some
> userspace.
>=20
> ---
> Subject: perf: Update event buffer tail when overwriting old events
> From: Peter Zijlstra <peterz@infradead.org>
>=20
>> From: "Yan, Zheng" <zheng.z.yan@intel.com>
>>
>> If perf event buffer is in overwrite mode, the kernel only updates
>> the data head when it overwrites old samples. The program that owns
>> the buffer need periodically check the buffer and update a variable
>> that tracks the date tail. If the program fails to do this in time,
>> the data tail can be overwritted by new samples. The program has to
>> rewind the buffer because it does not know where is the first vaild
>> sample.
>>
>> This patch makes the kernel update the date tail when it overwrites
>> old events. So the program that owns the event buffer can always
>> read the latest samples. This is convenient for programs that use
>> perf to do branch tracing. One use case is GDB branch tracing:
>> (http://sourceware.org/ml/gdb-patches/2012-06/msg00172.html)
>> It uses perf interface to read BTS, but only cares the branches
>> before the ptrace event.
>=20
> Original-patch-by: "Yan, Zheng" <zheng.z.yan@intel.com>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
>  arch/x86/kernel/cpu/perf_event_intel_ds.c |    2=20
>  include/linux/perf_event.h                |    6 --
>  kernel/events/core.c                      |   56 +++++++++++++++++--=
--
>  kernel/events/internal.h                  |    2=20
>  kernel/events/ring_buffer.c               |   77 +++++++++++++++++++=
++---------
>  5 files changed, 107 insertions(+), 36 deletions(-)
>=20
> --- a/arch/x86/kernel/cpu/perf_event_intel_ds.c
> +++ b/arch/x86/kernel/cpu/perf_event_intel_ds.c
> @@ -1140,7 +1140,7 @@ static void __intel_pmu_pebs_event(struc
> =20
>  	while (count > 1) {
>  		setup_pebs_sample_data(event, iregs, at, &data, &regs);
> -		perf_event_output(event, &data, &regs);
> +		event->overflow_handler(event, &data, &regs);
>  		at +=3D x86_pmu.pebs_record_size;
>  		at =3D get_next_pebs_record_by_bit(at, top, bit);
>  		count--;
> --- a/include/linux/perf_event.h
> +++ b/include/linux/perf_event.h
> @@ -828,10 +828,6 @@ extern int perf_event_overflow(struct pe
>  				 struct perf_sample_data *data,
>  				 struct pt_regs *regs);
> =20
> -extern void perf_event_output(struct perf_event *event,
> -				struct perf_sample_data *data,
> -				struct pt_regs *regs);
> -
>  extern void
>  perf_event_header__init_id(struct perf_event_header *header,
>  			   struct perf_sample_data *data,
> @@ -1032,6 +1028,8 @@ static inline bool has_aux(struct perf_e
> =20
>  extern int perf_output_begin(struct perf_output_handle *handle,
>  			     struct perf_event *event, unsigned int size);
> +extern int perf_output_begin_overwrite(struct perf_output_handle *ha=
ndle,
> +			     struct perf_event *event, unsigned int size);
>  extern void perf_output_end(struct perf_output_handle *handle);
>  extern unsigned int perf_output_copy(struct perf_output_handle *hand=
le,
>  			     const void *buf, unsigned int len);
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -4515,6 +4515,8 @@ static int perf_mmap_fault(struct vm_are
>  	return ret;
>  }
> =20
> +static void perf_event_set_overflow(struct perf_event *event, struct=
 ring_buffer *rb);
> +
>  static void ring_buffer_attach(struct perf_event *event,
>  			       struct ring_buffer *rb)
>  {
> @@ -4546,6 +4548,8 @@ static void ring_buffer_attach(struct pe
>  		spin_lock_irqsave(&rb->event_lock, flags);
>  		list_add_rcu(&event->rb_entry, &rb->event_list);
>  		spin_unlock_irqrestore(&rb->event_lock, flags);
> +
> +		perf_event_set_overflow(event, rb);
>  	}
> =20
>  	rcu_assign_pointer(event->rb, rb);
> @@ -5579,9 +5583,12 @@ void perf_prepare_sample(struct perf_eve
>  	}
>  }
> =20
> -void perf_event_output(struct perf_event *event,
> -			struct perf_sample_data *data,
> -			struct pt_regs *regs)
> +static __always_inline void
> +__perf_event_output(struct perf_event *event,
> +		    struct perf_sample_data *data,
> +		    struct pt_regs *regs,
> +		    int (*output_begin)(struct perf_output_handle *,
> +			                struct perf_event *, unsigned int))
>  {
>  	struct perf_output_handle handle;
>  	struct perf_event_header header;
> @@ -5591,7 +5598,7 @@ void perf_event_output(struct perf_event
> =20
>  	perf_prepare_sample(&header, data, event, regs);
> =20
> -	if (perf_output_begin(&handle, event, header.size))
> +	if (output_begin(&handle, event, header.size))
>  		goto exit;
> =20
>  	perf_output_sample(&handle, &header, data, event);
> @@ -5602,6 +5609,33 @@ void perf_event_output(struct perf_event
>  	rcu_read_unlock();
>  }
> =20
> +static void perf_event_output(struct perf_event *event,
> +				struct perf_sample_data *data,
> +				struct pt_regs *regs)
> +{
> +	__perf_event_output(event, data, regs, perf_output_begin);
> +}
> +
> +static void perf_event_output_overwrite(struct perf_event *event,
> +				struct perf_sample_data *data,
> +				struct pt_regs *regs)
> +{
> +	__perf_event_output(event, data, regs, perf_output_begin_overwrite)=
;
> +}
> +
> +static void
> +perf_event_set_overflow(struct perf_event *event, struct ring_buffer=
 *rb)
> +{
> +	if (event->overflow_handler !=3D perf_event_output &&
> +	    event->overflow_handler !=3D perf_event_output_overwrite)
> +		return;
> +
> +	if (rb->overwrite)
> +		event->overflow_handler =3D perf_event_output_overwrite;
> +	else
> +		event->overflow_handler =3D perf_event_output;
> +}
> +
>  /*
>   * read event_id
>   */
> @@ -6426,10 +6460,7 @@ static int __perf_event_overflow(struct
>  		irq_work_queue(&event->pending);
>  	}
> =20
> -	if (event->overflow_handler)
> -		event->overflow_handler(event, data, regs);
> -	else
> -		perf_event_output(event, data, regs);
> +	event->overflow_handler(event, data, regs);
> =20
>  	if (*perf_event_fasync(event) && event->pending_kill) {
>  		event->pending_wakeup =3D 1;
> @@ -7904,8 +7935,13 @@ perf_event_alloc(struct perf_event_attr
>  		context =3D parent_event->overflow_handler_context;
>  	}
> =20
> -	event->overflow_handler	=3D overflow_handler;
> -	event->overflow_handler_context =3D context;
> +	if (overflow_handler) {
> +		event->overflow_handler	=3D overflow_handler;
> +		event->overflow_handler_context =3D context;
> +	} else {
> +		event->overflow_handler =3D perf_event_output;
> +		event->overflow_handler_context =3D NULL;
> +	}
> =20
>  	perf_event__state_init(event);
> =20
> --- a/kernel/events/internal.h
> +++ b/kernel/events/internal.h
> @@ -21,6 +21,8 @@ struct ring_buffer {
> =20
>  	atomic_t			poll;		/* POLL_ for wakeups */
> =20
> +	local_t				tail;		/* read position     */
> +	local_t				next_tail;	/* next read position */
>  	local_t				head;		/* write position    */
>  	local_t				nest;		/* nested writers    */
>  	local_t				events;		/* event limit       */
> --- a/kernel/events/ring_buffer.c
> +++ b/kernel/events/ring_buffer.c
> @@ -102,11 +102,11 @@ static void perf_output_put_handle(struc
>  	preempt_enable();
>  }
> =20
> -int perf_output_begin(struct perf_output_handle *handle,
> -		      struct perf_event *event, unsigned int size)
> +static __always_inline int __perf_output_begin(struct perf_output_ha=
ndle *handle,
> +		      struct perf_event *event, unsigned int size, bool overwrite)
>  {
>  	struct ring_buffer *rb;
> -	unsigned long tail, offset, head;
> +	unsigned long tail, offset, head, max_size;
>  	int have_lost, page_shift;
>  	struct {
>  		struct perf_event_header header;
> @@ -125,7 +125,8 @@ int perf_output_begin(struct perf_output
>  	if (unlikely(!rb))
>  		goto out;
> =20
> -	if (unlikely(!rb->nr_pages))
> +	max_size =3D perf_data_size(rb);
> +	if (unlikely(size > max_size))
>  		goto out;
> =20
>  	handle->rb    =3D rb;
> @@ -140,27 +141,49 @@ int perf_output_begin(struct perf_output
> =20
>  	perf_output_get_handle(handle);
> =20
> -	do {
> -		tail =3D READ_ONCE_CTRL(rb->user_page->data_tail);
> -		offset =3D head =3D local_read(&rb->head);
> -		if (!rb->overwrite &&
> -		    unlikely(CIRC_SPACE(head, tail, perf_data_size(rb)) < size))
> -			goto fail;
> +	if (overwrite) {
> +		do {
> +			tail =3D local_read(&rb->tail);
> +			offset =3D local_read(&rb->head);
> +			head =3D offset + size;
> +			if (unlikely(CIRC_SPACE(head, tail, max_size) < size)) {
Should be 'if (unlikely(CIRC_SPACE(offset, tail, max_size) < size))'?

> +				tail =3D local_read(&rb->next_tail);
> +				local_set(&rb->tail, tail);
> +				rb->user_page->data_tail =3D tail;
> +			}
> +		} while (local_cmpxchg(&rb->head, offset, head) !=3D offset);
> =20
>  		/*
> -		 * The above forms a control dependency barrier separating the
> -		 * @tail load above from the data stores below. Since the @tail
> -		 * load is required to compute the branch to fail below.
> -		 *
> -		 * A, matches D; the full memory barrier userspace SHOULD issue
> -		 * after reading the data and before storing the new tail
> -		 * position.
> -		 *
> -		 * See perf_output_put_handle().
> +		 * Save the start of next event when half of the buffer
> +		 * has been filled. Later when the event buffer overflows,
> +		 * update the tail pointer to point to it.
>  		 */
> +		if (tail =3D=3D local_read(&rb->next_tail) &&
> +		    CIRC_CNT(head, tail, max_size) >=3D (max_size / 2))
> +			local_cmpxchg(&rb->next_tail, tail, head);
> +	} else {
> +		do {
> +			tail =3D READ_ONCE_CTRL(rb->user_page->data_tail);
> +			offset =3D head =3D local_read(&rb->head);
> +			if (!rb->overwrite &&
> +			    unlikely(CIRC_SPACE(head, tail, perf_data_size(rb)) < size))
> +				goto fail;
> +
> +			/*
> +			 * The above forms a control dependency barrier separating the
> +			 * @tail load above from the data stores below. Since the @tail
> +			 * load is required to compute the branch to fail below.
> +			 *
> +			 * A, matches D; the full memory barrier userspace SHOULD issue
> +			 * after reading the data and before storing the new tail
> +			 * position.
> +			 *
> +			 * See perf_output_put_handle().
> +			 */
> =20
> -		head +=3D size;
> -	} while (local_cmpxchg(&rb->head, offset, head) !=3D offset);
> +			head +=3D size;
> +		} while (local_cmpxchg(&rb->head, offset, head) !=3D offset);
> +	}
> =20
>  	/*
>  	 * We rely on the implied barrier() by local_cmpxchg() to ensure
> @@ -203,6 +226,18 @@ int perf_output_begin(struct perf_output
>  	return -ENOSPC;
>  }
> =20
> +int perf_output_begin(struct perf_output_handle *handle,
> +		      struct perf_event *event, unsigned int size)
> +{
> +	return __perf_output_begin(handle, event, size, false);
> +}
> +
> +int perf_output_begin_overwrite(struct perf_output_handle *handle,
> +		      struct perf_event *event, unsigned int size)
> +{
> +	return __perf_output_begin(handle, event, size, true);
> +}
> +
>  unsigned int perf_output_copy(struct perf_output_handle *handle,
>  		      const void *buf, unsigned int len)
>  {
>=20
> .
>=20


--=20
Regards
Kaixu Xia
