From: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH] net: rds: don't pretend to use cpu notifiers
Date: Sun, 29 Nov 2015 17:44:43 -0800
Message-ID: <565BAA0B.100@oracle.com>
References: <1448640026-31438-1-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chien Yen <chien.yen@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:46507 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752173AbbK3Bo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 20:44:57 -0500
In-Reply-To: <1448640026-31438-1-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sebastian,

On 11/27/15 8:00 AM, Sebastian Andrzej Siewior wrote:
> It looks like an attempt to use CPU notifier here which was never
> completed. Nobody tried to wire it up completely since 2k9. So I unwind
> this code and get rid of everything not required. Oh look! 19 lines were
> removed while code still does the same thing.
>
Indeed its true that RDS doesn't actually support the hot-plug so am
not surprised with the incompleteness of it.

> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
>   net/rds/page.c | 31 ++++++-------------------------
>   1 file changed, 6 insertions(+), 25 deletions(-)
>
> diff --git a/net/rds/page.c b/net/rds/page.c
> index 9005a2c920ee..5a14e6d6a926 100644
> --- a/net/rds/page.c
> +++ b/net/rds/page.c
> @@ -179,37 +179,18 @@ int rds_page_remainder_alloc(struct scatterlist *scat, unsigned long bytes,
>   }
>   EXPORT_SYMBOL_GPL(rds_page_remainder_alloc);
>
> -static int rds_page_remainder_cpu_notify(struct notifier_block *self,
> -					 unsigned long action, void *hcpu)
> +void rds_page_exit(void)
>   {
> -	struct rds_page_remainder *rem;
> -	long cpu = (long)hcpu;
> +	unsigned int cpu;
>
> -	rem = &per_cpu(rds_page_remainders, cpu);
> +	for_each_possible_cpu(cpu) {
> +		struct rds_page_remainder *rem;
>
> -	rdsdebug("cpu %ld action 0x%lx\n", cpu, action);
> +		rem = &per_cpu(rds_page_remainders, cpu);
> +		rdsdebug("cpu %u\n", cpu);
>
> -	switch (action) {
> -	case CPU_DEAD:
>   		if (rem->r_page)
>   			__free_page(rem->r_page);
>   		rem->r_page = NULL;
> -		break;
>   	}
> -
> -	return 0;
> -}
> -
> -static struct notifier_block rds_page_remainder_nb = {
> -	.notifier_call = rds_page_remainder_cpu_notify,
> -};
> -
> -void rds_page_exit(void)
> -{
> -	int i;
> -
> -	for_each_possible_cpu(i)
> -		rds_page_remainder_cpu_notify(&rds_page_remainder_nb,
> -					      (unsigned long)CPU_DEAD,
> -					      (void *)(long)i);
>   }
>
Thanks for the cleanup. I don't have any objections as such on the
change and patch in general looks ok to me from first look. Just
want to make sure it works on my setup. If all goes well, I will
add this in my RDS queue for 4.5. Thanks !!

Regards,
Santosh
