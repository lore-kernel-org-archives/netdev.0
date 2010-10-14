From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2.6.35-rc6] net-next: Add multiqueue support to vmxnet3
 driver
Date: Thu, 14 Oct 2010 17:31:08 +0100
Message-ID: <1287073868.2258.13.camel@achroite.uk.solarflarecom.com>
References: <alpine.LRH.2.00.1009290104130.464@sbhatewara-dev1.eng.vmware.com>
	 <alpine.LRH.2.00.1010131445080.25989@sbhatewara-dev1.eng.vmware.com>
	 <20101013145732.7d69d0f3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pv-drivers@vmware.com,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101013145732.7d69d0f3@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-10-13 at 14:57 -0700, Stephen Hemminger wrote:
> On Wed, 13 Oct 2010 14:47:05 -0700 (PDT)
> Shreyas Bhatewara <sbhatewara@vmware.com> wrote:
> 
> > #ifdef VMXNET3_RSS
> > +static unsigned int num_rss_entries;
> > +#define VMXNET3_MAX_DEVICES 10
> > +
> > +static int rss_ind_table[VMXNET3_MAX_DEVICES *
> > +			 VMXNET3_RSS_IND_TABLE_SIZE + 1] = {
> > +	[0 ... VMXNET3_MAX_DEVICES * VMXNET3_RSS_IND_TABLE_SIZE] = -1 };
> > +#endif
> > +static int num_tqs[VMXNET3_MAX_DEVICES + 1] = {
> > +	[0 ... VMXNET3_MAX_DEVICES] = 1 };
> > +static int num_rqs[VMXNET3_MAX_DEVICES + 1] = {
> > +	[0 ... VMXNET3_MAX_DEVICES] = 1 };
> > +static int share_tx_intr[VMXNET3_MAX_DEVICES + 1] = {
> > +	[0 ... VMXNET3_MAX_DEVICES] = 0 };
> > +static int buddy_intr[VMXNET3_MAX_DEVICES + 1] = {
> > +	[0 ... VMXNET3_MAX_DEVICES] = 1 };
> > +
> > +static unsigned int num_adapters;
> > +module_param_array(share_tx_intr, int, &num_adapters, 0400);
> > +MODULE_PARM_DESC(share_tx_intr, "Share one IRQ among all tx queue completions. "
> > +		 "Comma separated list of 1s and 0s - one for each NIC. "
> > +		 "1 to share, 0 to not, default is 0");
> > +module_param_array(buddy_intr, int, &num_adapters, 0400);
> > +MODULE_PARM_DESC(buddy_intr, "Share one IRQ among corresponding tx and rx "
> > +		 "queues. Comma separated list of 1s and 0s - one for each "
> > +		 "NIC. 1 to share, 0 to not, default is 1");
> > +module_param_array(num_tqs, int, &num_adapters, 0400);
> > +MODULE_PARM_DESC(num_tqs, "Number of transmit queues in each adapter. Comma "
> > +		 "separated list of integers. Setting this to 0 makes number"
> > +		 " of queues same as number of CPUs. Default is 1.");
> > +
> > +#ifdef VMXNET3_RSS
> > +module_param_array(rss_ind_table, int, &num_rss_entries, 0400);
> > +MODULE_PARM_DESC(rss_ind_table, "RSS Indirection table. Number of entries "
> > +		 "per NIC should be 32. Each integer in a comma separated list"
> > +		 " is an rx queue number starting with 0. Repeat the same for"
> > +		 " all NICs.");
> > +module_param_array(num_rqs, int, &num_adapters, 0400);
> > +MODULE_PARM_DESC(num_rqs, "Number of receive queues in each adapter. Comma "
> > +		 " separated list of integers. Setting this to 0 makes number"
> > +		 " of queues same as number of CPUs. Default is 1.");
> 
> Module parameters are not right for this. They lead to different API
> for interacting with each driver vendor. Is there a another better API?
> Does it have to be this tweakable in a production environment.

The ethtool commands ETHTOOL_{G,S}RXFHINDIR cover the RSS indirection
table.  These are new in 2.6.36 but already supported in the ethtool
utility.

As for numbers of queues and association of their completions with
interrupts, we currently have nothing except ETHTOOL_GRXRINGS to get the
number of RX queues.  I did post a tentative definition of an ethtool
interface for this in
<http://article.gmane.org/gmane.linux.network/172386> though it wouldn't
provide quite as much control as these module parameters.  It is also
significantly more difficult to support changing numbers of queues after
an interface has been created, and I have not yet attempted to implement
the 'set' command myself.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
