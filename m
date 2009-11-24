From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2] irq: Add node_affinity CPU masks for smarter irqbalance
 hints
Date: Tue, 24 Nov 2009 12:07:35 +0100 (CET)
Message-ID: <alpine.LFD.2.00.0911241151360.24119@localhost.localdomain>
References: <20091124093518.3909.16435.stgit@ppwaskie-hc2.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, arjan@linux.jf.intel.com,
	mingo@elte.hu, yong.zhang0@gmail.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932760AbZKXLIE@vger.kernel.org>
In-Reply-To: <20091124093518.3909.16435.stgit@ppwaskie-hc2.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Nov 2009, Peter P Waskiewicz Jr wrote:

> This patchset adds a new CPU mask for SMP systems to the irq_desc
> struct.  It also exposes an API for underlying device drivers to
> assist irqbalance in making smarter decisions when balancing, especially
> in a NUMA environment.  For example, an ethernet driver with MSI-X may
> wish to limit the CPUs that an interrupt can be balanced within to
> stay on a single NUMA node.  Current irqbalance operation can move the
> interrupt off the node, resulting in cross-node memory accesses and
> locks.
> 
> The API is a get/set API within the kernel, along with a /proc entry
> for the interrupt.

And what does the kernel do with this information and why are we not
using the existing device/numa_node information ?
 
> +extern int irq_set_node_affinity(unsigned int irq,
> +                                 const struct cpumask *cpumask);

A node can be described with a single integer, right ?

> +static int irq_node_affinity_proc_show(struct seq_file *m, void *v)
> +{
> +	struct irq_desc *desc = irq_to_desc((long)m->private);
> +	const struct cpumask *mask = desc->node_affinity;
> +
> +	seq_cpumask(m, mask);
> +	seq_putc(m, '\n');
> +	return 0;
> +}
> +
>  #ifndef is_affinity_mask_valid
>  #define is_affinity_mask_valid(val) 1
>  #endif
> @@ -78,11 +88,46 @@ free_cpumask:
>  	return err;
>  }
>  
> +static ssize_t irq_node_affinity_proc_write(struct file *file,
> +		const char __user *buffer, size_t count, loff_t *pos)
> +{
> +	unsigned int irq = (int)(long)PDE(file->f_path.dentry->d_inode)->data;
> +	cpumask_var_t new_value;
> +	int err;
> +
> +	if (no_irq_affinity || irq_balancing_disabled(irq))
> +		return -EIO;

Yikes. Why should user space be allowed to write to that file ? And
the whole business is what for ? Storing that value in the irq_desc
data structure for use space to read out again ?

Cool design. We provide storage space for user space applications in
the kernel now ?

See also my earlier reply in the thread. This patch is just adding
code and memory bloat while not solving anything at all. 

Again, this is going nowhere else than into /dev/null.

Thanks,

	tglx
