From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2.6.32-rc3] net: VMware virtual Ethernet NIC driver:
	vmxnet3
Date: Fri, 9 Oct 2009 14:35:38 -0700
Message-ID: <20091009143538.644844aa@nehalam>
References: <alpine.LRH.2.00.0910061202510.24669@localhost.localdomain>
	<alpine.LRH.2.00.0910081053460.19107@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff@smtp1.linux-foundation.org, pv-drivers <pv-drivers@vmware.com>,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Andrew@smtp1.linux-foundation.org, Wright <chrisw@sous-sol.org>,
        Anthony Liguori <anthony@codemonkey.ws>,
        Greg Kroah-Hartman <greg@kroah.com>, Chris@smtp1.linux-foundation.org,
        Morton <akpm@linux-foundation.org>,
        virtualization <virtualization@lists.linux-foundation.org>,
        Garzik <jgarzik@pobox.com>, "David S. Miller" <davem@davemloft.net>
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <alpine.LRH.2.00.0910081053460.19107@localhost.localdomain>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, 8 Oct 2009 10:59:26 -0700 (PDT)
Shreyas Bhatewara <sbhatewara@vmware.com> wrote:

> Hello all,
> 
> I do not mean to be bothersome but this thread has been unusually silent.
> Could you please review the patch for me and reply with your comments / 
> acks ?
> 
> Thanks.
> ->Shreyas  


Looks fine, but just a minor style nit (can be changed after insertion in mainline).

The code:

static void
vmxnet3_do_poll(struct vmxnet3_adapter *adapter, int budget, int *txd_done,
		int *rxd_done)
{
	if (unlikely(adapter->shared->ecr))
		vmxnet3_process_events(adapter);

	*txd_done = vmxnet3_tq_tx_complete(&adapter->tx_queue, adapter);
	*rxd_done = vmxnet3_rq_rx_complete(&adapter->rx_queue, adapter, budget);
}


static int
vmxnet3_poll(struct napi_struct *napi, int budget)
{
	struct vmxnet3_adapter *adapter = container_of(napi,
					  struct vmxnet3_adapter, napi);
	int rxd_done, txd_done;

	vmxnet3_do_poll(adapter, budget, &txd_done, &rxd_done);

	if (rxd_done < budget) {
		napi_complete(napi);
		vmxnet3_enable_intr(adapter, 0);
	}
	return rxd_done;
}


Is simpler if you just have do_poll return rx done value. Probably Gcc
inline's it all anyway.

static int
vmxnet3_do_poll(struct vmxnet3_adapter *adapter, int budget)
{
	if (unlikely(adapter->shared->ecr))
		vmxnet3_process_events(adapter);

	vmxnet3_tq_tx_complete(&adapter->tx_queue, adapter);
	return vmxnet3_rq_rx_complete(&adapter->rx_queue, adapter, budget);
}


static int
vmxnet3_poll(struct napi_struct *napi, int budget)
{
	struct vmxnet3_adapter *adapter = container_of(napi,
					  struct vmxnet3_adapter, napi);
	int rxd_done;

	rxd_done = vmxnet3_do_poll(adapter, budget);
	if (rxd_done < budget) {
		napi_complete(napi);
		vmxnet3_enable_intr(adapter, 0);
	}
	return rxd_done;
}
