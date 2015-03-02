From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH 04/16] drivers: fix up obsolete cpu function usage.
Date: Mon, 02 Mar 2015 23:23:11 +0100
Message-ID: <1716022.2VrWkhJkMW@vostro.rjw.lan>
References: <1425296150-4722-1-git-send-email-rusty@rustcorp.com.au> <1425296150-4722-4-git-send-email-rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Jason Cooper <jason@lakedaemon.net>,
	Chris Metcalf <cmetcalf@ezchip.com>, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425296150-4722-4-git-send-email-rusty@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, March 02, 2015 10:05:45 PM Rusty Russell wrote:
> Thanks to spatch, plus manual removal of "&*".  Then a sweep for
> for_each_cpu_mask => for_each_cpu.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Jason Cooper <jason@lakedaemon.net>
> Cc: Chris Metcalf <cmetcalf@ezchip.com>
> Cc: netdev@vger.kernel.org

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

for the cpuidle part.  Thanks!

> ---
>  drivers/clocksource/dw_apb_timer.c | 3 ++-
>  drivers/cpuidle/coupled.c          | 6 +++---
>  drivers/crypto/n2_core.c           | 4 ++--
>  drivers/irqchip/irq-gic-v3.c       | 2 +-
>  drivers/irqchip/irq-mips-gic.c     | 6 +++---
>  drivers/net/ethernet/tile/tilegx.c | 4 ++--
>  6 files changed, 13 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/clocksource/dw_apb_timer.c b/drivers/clocksource/dw_apb_timer.c
> index f3656a6b0382..35a88097af3c 100644
> --- a/drivers/clocksource/dw_apb_timer.c
> +++ b/drivers/clocksource/dw_apb_timer.c
> @@ -117,7 +117,8 @@ static void apbt_set_mode(enum clock_event_mode mode,
>  	unsigned long period;
>  	struct dw_apb_clock_event_device *dw_ced = ced_to_dw_apb_ced(evt);
>  
> -	pr_debug("%s CPU %d mode=%d\n", __func__, first_cpu(*evt->cpumask),
> +	pr_debug("%s CPU %d mode=%d\n", __func__,
> +		 cpumask_first(evt->cpumask),
>  		 mode);
>  
>  	switch (mode) {
> diff --git a/drivers/cpuidle/coupled.c b/drivers/cpuidle/coupled.c
> index 73fe2f8d7f96..7936dce4b878 100644
> --- a/drivers/cpuidle/coupled.c
> +++ b/drivers/cpuidle/coupled.c
> @@ -292,7 +292,7 @@ static inline int cpuidle_coupled_get_state(struct cpuidle_device *dev,
>  	 */
>  	smp_rmb();
>  
> -	for_each_cpu_mask(i, coupled->coupled_cpus)
> +	for_each_cpu(i, &coupled->coupled_cpus)
>  		if (cpu_online(i) && coupled->requested_state[i] < state)
>  			state = coupled->requested_state[i];
>  
> @@ -338,7 +338,7 @@ static void cpuidle_coupled_poke_others(int this_cpu,
>  {
>  	int cpu;
>  
> -	for_each_cpu_mask(cpu, coupled->coupled_cpus)
> +	for_each_cpu(cpu, &coupled->coupled_cpus)
>  		if (cpu != this_cpu && cpu_online(cpu))
>  			cpuidle_coupled_poke(cpu);
>  }
> @@ -638,7 +638,7 @@ int cpuidle_coupled_register_device(struct cpuidle_device *dev)
>  	if (cpumask_empty(&dev->coupled_cpus))
>  		return 0;
>  
> -	for_each_cpu_mask(cpu, dev->coupled_cpus) {
> +	for_each_cpu(cpu, &dev->coupled_cpus) {
>  		other_dev = per_cpu(cpuidle_devices, cpu);
>  		if (other_dev && other_dev->coupled) {
>  			coupled = other_dev->coupled;
> diff --git a/drivers/crypto/n2_core.c b/drivers/crypto/n2_core.c
> index afd136b45f49..10a9aeff1666 100644
> --- a/drivers/crypto/n2_core.c
> +++ b/drivers/crypto/n2_core.c
> @@ -1754,7 +1754,7 @@ static int spu_mdesc_walk_arcs(struct mdesc_handle *mdesc,
>  				dev->dev.of_node->full_name);
>  			return -EINVAL;
>  		}
> -		cpu_set(*id, p->sharing);
> +		cpumask_set_cpu(*id, &p->sharing);
>  		table[*id] = p;
>  	}
>  	return 0;
> @@ -1776,7 +1776,7 @@ static int handle_exec_unit(struct spu_mdesc_info *ip, struct list_head *list,
>  		return -ENOMEM;
>  	}
>  
> -	cpus_clear(p->sharing);
> +	cpumask_clear(&p->sharing);
>  	spin_lock_init(&p->lock);
>  	p->q_type = q_type;
>  	INIT_LIST_HEAD(&p->jobs);
> diff --git a/drivers/irqchip/irq-gic-v3.c b/drivers/irqchip/irq-gic-v3.c
> index 1c6dea2fbc34..04b6f0732c1a 100644
> --- a/drivers/irqchip/irq-gic-v3.c
> +++ b/drivers/irqchip/irq-gic-v3.c
> @@ -512,7 +512,7 @@ static void gic_raise_softirq(const struct cpumask *mask, unsigned int irq)
>  	 */
>  	smp_wmb();
>  
> -	for_each_cpu_mask(cpu, *mask) {
> +	for_each_cpu(cpu, mask) {
>  		u64 cluster_id = cpu_logical_map(cpu) & ~0xffUL;
>  		u16 tlist;
>  
> diff --git a/drivers/irqchip/irq-mips-gic.c b/drivers/irqchip/irq-mips-gic.c
> index 9acdc080e7ec..f26307908a2a 100644
> --- a/drivers/irqchip/irq-mips-gic.c
> +++ b/drivers/irqchip/irq-mips-gic.c
> @@ -345,19 +345,19 @@ static int gic_set_affinity(struct irq_data *d, const struct cpumask *cpumask,
>  	int		i;
>  
>  	cpumask_and(&tmp, cpumask, cpu_online_mask);
> -	if (cpus_empty(tmp))
> +	if (cpumask_empty(&tmp))
>  		return -EINVAL;
>  
>  	/* Assumption : cpumask refers to a single CPU */
>  	spin_lock_irqsave(&gic_lock, flags);
>  
>  	/* Re-route this IRQ */
> -	gic_map_to_vpe(irq, first_cpu(tmp));
> +	gic_map_to_vpe(irq, cpumask_first(&tmp));
>  
>  	/* Update the pcpu_masks */
>  	for (i = 0; i < NR_CPUS; i++)
>  		clear_bit(irq, pcpu_masks[i].pcpu_mask);
> -	set_bit(irq, pcpu_masks[first_cpu(tmp)].pcpu_mask);
> +	set_bit(irq, pcpu_masks[cpumask_first(&tmp)].pcpu_mask);
>  
>  	cpumask_copy(d->affinity, cpumask);
>  	spin_unlock_irqrestore(&gic_lock, flags);
> diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
> index bea8cd2bb56c..deac41498c6e 100644
> --- a/drivers/net/ethernet/tile/tilegx.c
> +++ b/drivers/net/ethernet/tile/tilegx.c
> @@ -1122,7 +1122,7 @@ static int alloc_percpu_mpipe_resources(struct net_device *dev,
>  			addr + i * sizeof(struct tile_net_comps);
>  
>  	/* If this is a network cpu, create an iqueue. */
> -	if (cpu_isset(cpu, network_cpus_map)) {
> +	if (cpumask_test_cpu(cpu, &network_cpus_map)) {
>  		order = get_order(NOTIF_RING_SIZE);
>  		page = homecache_alloc_pages(GFP_KERNEL, order, cpu);
>  		if (page == NULL) {
> @@ -1298,7 +1298,7 @@ static int tile_net_init_mpipe(struct net_device *dev)
>  	int first_ring, ring;
>  	int instance = mpipe_instance(dev);
>  	struct mpipe_data *md = &mpipe_data[instance];
> -	int network_cpus_count = cpus_weight(network_cpus_map);
> +	int network_cpus_count = cpumask_weight(&network_cpus_map);
>  
>  	if (!hash_default) {
>  		netdev_err(dev, "Networking requires hash_default!\n");
> 

-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
