From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 3/3] packet: use percpu mmap tx frame pending
 refcount
Date: Mon, 13 Jan 2014 12:19:01 +0100
Message-ID: <52D3CBA5.4080301@redhat.com>
References: <1389543768-20234-1-git-send-email-dborkman@redhat.com> <1389543768-20234-4-git-send-email-dborkman@redhat.com> <CAHA+R7NnaxXgOGW=jTEGkeMByO7wXVr9bGR-J9rLzwL4ne52bA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5414 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751476AbaAMLTM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jan 2014 06:19:12 -0500
In-Reply-To: <CAHA+R7NnaxXgOGW=jTEGkeMByO7wXVr9bGR-J9rLzwL4ne52bA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2014 06:51 AM, Cong Wang wrote:
> On Sun, Jan 12, 2014 at 8:22 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> +static void packet_inc_pending(struct packet_ring_buffer *rb)
>> +{
>> +       this_cpu_inc(*rb->pending_refcnt);
>> +}
>> +
>> +static void packet_dec_pending(struct packet_ring_buffer *rb)
>> +{
>> +       this_cpu_dec(*rb->pending_refcnt);
>> +}
>> +
>> +static int packet_read_pending(const struct packet_ring_buffer *rb)
>> +{
>> +       int i, refcnt = 0;
>> +
>> +       /* We don't use pending refcount in rx_ring. */
>> +       if (rb->pending_refcnt == NULL)
>> +               return 0;
>> +
>> +       for_each_possible_cpu(i)
>> +               refcnt += *per_cpu_ptr(rb->pending_refcnt, i);
>> +
>> +       return refcnt;
>> +}
>
> How is this supposed to work? Since there is no lock,
> you can't read accurate refcnt. Take a look at lib/percpu_counter.c.
>
> I guess for some reason you don't care the accuracy?

Yep, not per se. Look at how we do net device reference counting.
The reason is that we call packet_read_pending() *only* after we
finished processing all frames in TX_RING and we wait for
completion in case MSG_DONTWAIT is *not set*, when that happens
we're back to 0.

But I think I found a different problem with this idea. It could
happen with net devices as well, but probably less likely as there
might be a better distribution of hold/puts among CPUs. However,
for TX_RING, if we pin the process to a particular CPU, and since
the destructor is invoked through ksoftirqd, we could end up with
a misbalance and if the process runs long enough eventually
overflow for one particular CPU. We could work around that, but I
think it's not worth the effort.

Dave, please drop the 3rd patch of the series, thanks.

> Then at least you need to comment in the code.
>
> Thanks.
>
