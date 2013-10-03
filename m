From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [PATCH RFC 50/77] mlx5: Update MSI/MSI-X interrupts enablement
 code
Date: Thu, 3 Oct 2013 10:14:33 +0300
Message-ID: <20131003071433.GA7299@mtldesk30>
References: <cover.1380703262.git.agordeev@redhat.com>
 <9650a7dfbcfd5f1da21f7b093665abf4b1041071.1380703263.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Michael Ellerman <michael@ellerman.id.au>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Andy King <acking@vmware.com>, Jon Mason <jon.mason@intel.com>,
	Matt Porter <mporter@kernel.crashing.org>,
	linux-pci@vger.kernel.org, linux-mips@linux-mips.org,
	linuxppc-dev@lists.ozlabs.org, linux390@de.ibm.com,
	linux-s390@vger.kernel.org, x86@kernel.org,
	linux-ide@vger.kernel.org, iss_storagedev@hp.com,
	linux-nvme@lists.infradead.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-driver@qlogic.com,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	"VMware, Inc." <pv-dr
To: Alexander Gordeev <agordeev@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9650a7dfbcfd5f1da21f7b093665abf4b1041071.1380703263.git.agordeev@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 02, 2013 at 12:49:06PM +0200, Alexander Gordeev wrote:
>  
> +	err = pci_msix_table_size(dev->pdev);
> +	if (err < 0)
> +		return err;
> +
>  	nvec = dev->caps.num_ports * num_online_cpus() + MLX5_EQ_VEC_COMP_BASE;
>  	nvec = min_t(int, nvec, num_eqs);
> +	nvec = min_t(int, nvec, err);
>  	if (nvec <= MLX5_EQ_VEC_COMP_BASE)
>  		return -ENOSPC;

Making sure we don't request more vectors then the device's is capable
of -- looks good.
>  
> @@ -131,20 +136,15 @@ static int mlx5_enable_msix(struct mlx5_core_dev *dev)
>  	for (i = 0; i < nvec; i++)
>  		table->msix_arr[i].entry = i;
>  
> -retry:
> -	table->num_comp_vectors = nvec - MLX5_EQ_VEC_COMP_BASE;
>  	err = pci_enable_msix(dev->pdev, table->msix_arr, nvec);
> -	if (err <= 0) {
> +	if (err) {
> +		kfree(table->msix_arr);
>  		return err;
> -	} else if (err > MLX5_EQ_VEC_COMP_BASE) {
> -		nvec = err;
> -		goto retry;
>  	}
>  

According to latest sources, pci_enable_msix() may still fail so why
do you want to remove this code?

> -	mlx5_core_dbg(dev, "received %d MSI vectors out of %d requested\n", err, nvec);
> -	kfree(table->msix_arr);
> +	table->num_comp_vectors = nvec - MLX5_EQ_VEC_COMP_BASE;
>  
> -	return -ENOSPC;
> +	return 0;
>  }
>  
>  static void mlx5_disable_msix(struct mlx5_core_dev *dev)
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
