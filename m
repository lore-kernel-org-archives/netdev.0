From: Shan Wei <shanwei88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/9] net: openvswitch: use this_cpu_ptr
	per-cpu helper
Date: Thu, 01 Nov 2012 18:07:03 +0800
Message-ID: <509249C7.3080000@gmail.com>
References: <50910A04.5000003@gmail.com>
	<0000013ab7e86f8a-4adb8b81-19be-4264-96f1-924aaf3819f2-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel-Maillist <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <0000013ab7e86f8a-4adb8b81-19be-4264-96f1-924aaf3819f2-000000-p/GC64/jrecnJqMo6gzdpkEOCMrvLtNR@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Christoph Lameter said, at 2012/11/1 1:39:
> On Wed, 31 Oct 2012, Shan Wei wrote:
> 
>> --- a/net/openvswitch/datapath.c
>> +++ b/net/openvswitch/datapath.c
>> @@ -208,7 +208,7 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
>>  	int error;
>>  	int key_len;
>>
>> -	stats = per_cpu_ptr(dp->stats_percpu, smp_processor_id());
>> +	stats = this_cpu_ptr(dp->stats_percpu);
> 
> Well this is an improvement and may be ok if the preemption is disabled at
> this point. There is another possibility here to use this_cpu_read/add/inc
> instead of determining the pointer to the local cpu first and then
> performing operations on the fields. The pointer relocation with
> this_cpu_xxx ops is implicit in the instructions and safe against changing
> of processors. It would also save us the determination of a pointer to the
> current cpus stats structure.

yes, this_cpu_ptr just locate the point to current cpu per-cpu data domain.
and then operating [read/write/inc/sub] fields of this per-cpu variable
maybe on other cpu because task is rescheduled for preemption, interrupt.

But for different field in same per-cpu variable, how to guarantee n_missed
and n_hit are from same cpu? 
this_cpu_read(dp->stats_percpu->n_missed);
[processor changed]
this_cpu_read(dp->stats_percpu->n_hit);


In addition, following usage of per_cpu_ptr can be replaced by this_cpu_read.

cpu=get_cpu()
....
*per_cpu_ptr(p,cpu)
....
....
put_cpu()
