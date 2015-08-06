From: xiakaixu <xiakaixu@huawei.com>
Subject: Re: [PATCH v6 3/4] bpf: Implement function bpf_perf_event_read()
 that get the selected hardware PMU conuter
Date: Thu, 6 Aug 2015 10:49:26 +0800
Message-ID: <55C2CB36.9010804@huawei.com>
References: <1438678696-88289-1-git-send-email-xiakaixu@huawei.com> <1438678696-88289-4-git-send-email-xiakaixu@huawei.com> <20150805100425.GZ25159@twins.programming.kicks-ass.net> <20150805135317.GZ18673@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <ast@plumgrid.com>, <davem@davemloft.net>, <acme@kernel.org>,
	<mingo@redhat.com>, <masami.hiramatsu.pt@hitachi.com>,
	<jolsa@kernel.org>, <daniel@iogearbox.net>, <wangnan0@huawei.com>,
	<linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<hekuang@huawei.com>, <netdev@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150805135317.GZ18673@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2015/8/5 21:53, Peter Zijlstra =E5=86=99=E9=81=93:
> On Wed, Aug 05, 2015 at 12:04:25PM +0200, Peter Zijlstra wrote:
>> Also, you probably want a WARN_ON(in_nmi()) there, this function is
>> _NOT_ NMI safe.
>=20
> I had a wee think about that, and I think the below is safe.
>=20
> (with the obvious problem that WARN from NMI context is not safe)
>=20
> It does not give you up-to-date overcommit times but your version did=
n't
> either so I'm assuming you don't need those, if you do need those it
> needs more but we can do that too.
>=20
> ---
>  include/linux/perf_event.h |  1 +
>  kernel/events/core.c       | 53 ++++++++++++++++++++++++++++++++++++=
++++++++++
>  2 files changed, 54 insertions(+)
>=20
> diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
> index 2027809433b3..64e821dd64f0 100644
> --- a/include/linux/perf_event.h
> +++ b/include/linux/perf_event.h
> @@ -659,6 +659,7 @@ perf_event_create_kernel_counter(struct perf_even=
t_attr *attr,
>  				void *context);
>  extern void perf_pmu_migrate_context(struct pmu *pmu,
>  				int src_cpu, int dst_cpu);
> +extern u64 perf_event_read_local(struct perf_event *event);
>  extern u64 perf_event_read_value(struct perf_event *event,
>  				 u64 *enabled, u64 *running);
> =20
> diff --git a/kernel/events/core.c b/kernel/events/core.c
> index 39753bfd9520..7105d37763c1 100644
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -3222,6 +3222,59 @@ static inline u64 perf_event_count(struct perf=
_event *event)
>  	return __perf_event_count(event);
>  }
> =20
> +/*
> + * NMI-safe method to read a local event, that is an event that
> + * is:
> + *   - either for the current task, or for this CPU
> + *   - does not have inherit set, for inherited task events
> + *     will not be local and we cannot read them atomically
> + *   - must not have a pmu::count method
> + */
> +u64 perf_event_read_local(struct perf_event *event)
> +{
> +	unsigned long flags;
> +	u64 val;
> +
> +	/*
> +	 * Disabling interrupts avoids all counter scheduling (context
> +	 * switches, timer based rotation and IPIs).
> +	 */
> +	local_irq_safe(flags);

s/local_irq_safe/local_irq_save, and I have compiled and tested this fu=
nction
and it is fine. Will use it in the next set.

Thanks.
> +
> +	/* If this is a per-task event, it must be for current */
> +	WARN_ON_ONCE((event->attach_state & PERF_ATTACH_TASK) &&
> +		     event->hw.target !=3D current);
> +
> +	/* If this is a per-CPU event, it must be for this CPU */
> +	WARN_ON_ONCE(!(event->attach_state & PERF_ATTACH_TASK) &&
> +		     event->cpu !=3D smp_processor_id());
> +
> +	/*
> +	 * It must not be an event with inherit set, we cannot read
> +	 * all child counters from atomic context.
> +	 */
> +	WARN_ON_ONCE(event->attr.inherit);
> +
> +	/*
> +	 * It must not have a pmu::count method, those are not
> +	 * NMI safe.
> +	 */
> +	WARN_ON_ONCE(event->pmu->count);
> +
> +	/*
> +	 * If the event is currently on this CPU, its either a per-task eve=
nt,
> +	 * or local to this CPU. Furthermore it means its ACTIVE (otherwise
> +	 * oncpu =3D=3D -1).
> +	 */
> +	if (event->oncpu =3D=3D smp_processor_id())
> +		event->pmu->read(event);
> +
> +	val =3D local64_read(&event->count);
> +	local_irq_restore(flags);
> +
> +	return val;
> +}
> +
>  static u64 perf_event_read(struct perf_event *event)
>  {
>  	/*
>=20
> .
>=20
