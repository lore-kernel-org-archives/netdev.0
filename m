From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH 17/21] RDS/IB: Receive datagrams via IB
Date: Wed, 28 Jan 2009 16:05:03 -0800
Message-ID: <ada1vunt1sg.fsf@cisco.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
	<1233022678-9259-18-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1233022678-9259-18-git-send-email-andy.grover@oracle.com> (Andy
	Grover's message of "Mon, 26 Jan 2009 18:17:54 -0800")
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

 > +static int rds_ib_recv_refill_one(struct rds_connection *conn,
 > +				  struct rds_ib_recv_work *recv,
 > +				  gfp_t kptr_gfp, gfp_t page_gfp)
 > +{
 > +	struct rds_ib_connection *ic = conn->c_transport_data;
 > +	dma_addr_t dma_addr;
 > +	struct ib_sge *sge;
 > +	int ret = -ENOMEM;
 > +
 > +	if (recv->r_ibinc == NULL) {
 > +		if (atomic_read(&rds_ib_allocation) >= rds_ib_sysctl_max_recv_allocation) {
 > +			rds_ib_stats_inc(s_ib_rx_alloc_limit);
 > +			goto out;
 > +		}
 > +		recv->r_ibinc = kmem_cache_alloc(rds_ib_incoming_slab,
 > +						 kptr_gfp);
 > +		if (recv->r_ibinc == NULL)
 > +			goto out;
 > +		atomic_inc(&rds_ib_allocation);

This is racy.  You check if you're at the limit, do the allocation, and
then increment the atomic rds_ib_allocation count.  So many threads can
pass the atomic_read() test and then take you over the limit.  If you
want to make it safe then you could do atomic_inc_return() and check if
that took you over the limit.

 - R.
