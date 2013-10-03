From: Alexander Gordeev <agordeev@redhat.com>
Subject: Re: [PATCH RFC 50/77] mlx5: Update MSI/MSI-X interrupts enablement
 code
Date: Thu, 3 Oct 2013 21:48:39 +0200
Message-ID: <20131003194837.GA27636@dhcp-26-207.brq.redhat.com>
References: <cover.1380703262.git.agordeev@redhat.com>
 <9650a7dfbcfd5f1da21f7b093665abf4b1041071.1380703263.git.agordeev@redhat.com>
 <20131003071433.GA7299@mtldesk30>
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
        linux-dr
To: Eli Cohen <eli@dev.mellanox.co.il>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <20131003071433.GA7299@mtldesk30>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On Thu, Oct 03, 2013 at 10:14:33AM +0300, Eli Cohen wrote:
> On Wed, Oct 02, 2013 at 12:49:06PM +0200, Alexander Gordeev wrote:
> >  
> > +	err = pci_msix_table_size(dev->pdev);
> > +	if (err < 0)
> > +		return err;
> > +
> >  	nvec = dev->caps.num_ports * num_online_cpus() + MLX5_EQ_VEC_COMP_BASE;
> >  	nvec = min_t(int, nvec, num_eqs);
> > +	nvec = min_t(int, nvec, err);
> >  	if (nvec <= MLX5_EQ_VEC_COMP_BASE)
> >  		return -ENOSPC;
> 
> Making sure we don't request more vectors then the device's is capable
> of -- looks good.
> >  
> > @@ -131,20 +136,15 @@ static int mlx5_enable_msix(struct mlx5_core_dev *dev)
> >  	for (i = 0; i < nvec; i++)
> >  		table->msix_arr[i].entry = i;
> >  
> > -retry:
> > -	table->num_comp_vectors = nvec - MLX5_EQ_VEC_COMP_BASE;
> >  	err = pci_enable_msix(dev->pdev, table->msix_arr, nvec);
> > -	if (err <= 0) {
> > +	if (err) {
> > +		kfree(table->msix_arr);
> >  		return err;
> > -	} else if (err > MLX5_EQ_VEC_COMP_BASE) {
> > -		nvec = err;
> > -		goto retry;
> >  	}
> >  
> 
> According to latest sources, pci_enable_msix() may still fail so why
> do you want to remove this code?

pci_enable_msix() may fail, but it can not return a positive number.

We first calculate how many MSI-Xs we need, adjust to what we can get,
check if that is enough and only then go for it.

> > -	mlx5_core_dbg(dev, "received %d MSI vectors out of %d requested\n", err, nvec);
> > -	kfree(table->msix_arr);
> > +	table->num_comp_vectors = nvec - MLX5_EQ_VEC_COMP_BASE;
> >  
> > -	return -ENOSPC;
> > +	return 0;
> >  }
> >  
> >  static void mlx5_disable_msix(struct mlx5_core_dev *dev)

-- 
Regards,
Alexander Gordeev
agordeev@redhat.com
