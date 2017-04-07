From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] RDS: IB: ensure an initialized ret is printed in pr_warn
 message
Date: Fri, 7 Apr 2017 17:24:12 +0300
Message-ID: <20170407142412.GA4471@mwanda>
References: <20170407075723.9669-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        Santosh Shilimkar <santosh.shilimkar@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170407075723.9669-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Setting it to zero doesn't seem like the right thing, it should be an
error code.  Oh, heh...  Smatch parses this one correctly.  "ret" is
always initialized but the code is probably buggy in a different way:

net/rds/ib_rdma.c
   539  void *rds_ib_get_mr(struct scatterlist *sg, unsigned long nents,
   540                      struct rds_sock *rs, u32 *key_ret)
   541  {
   542          struct rds_ib_device *rds_ibdev;
   543          struct rds_ib_mr *ibmr = NULL;
   544          struct rds_ib_connection *ic = rs->rs_conn->c_transport_data;
   545          int ret;
   546  
   547          rds_ibdev = rds_ib_get_device(rs->rs_bound_addr);
   548          if (!rds_ibdev) {
   549                  ret = -ENODEV;
   550                  goto out;
   551          }
   552  
   553          if (!rds_ibdev->mr_8k_pool || !rds_ibdev->mr_1m_pool) {
   554                  ret = -ENODEV;
   555                  goto out;
   556          }
   557  
   558          if (rds_ibdev->use_fastreg)
   559                  ibmr = rds_ib_reg_frmr(rds_ibdev, ic, sg, nents, key_ret);
   560          else
   561                  ibmr = rds_ib_reg_fmr(rds_ibdev, sg, nents, key_ret);
   562          if (ibmr)
                    ^^^^
This condition is always true because those functions return ERR_PTRs
not NULLs.

   563                  rds_ibdev = NULL;
   564  
   565   out:
   566          if (!ibmr)
                    ^^^^^
This condition implies that "ret" is set to an error code.

   567                  pr_warn("RDS/IB: rds_ib_get_mr failed (errno=%d)\n", ret);
   568  
   569          if (rds_ibdev)
   570                  rds_ib_dev_put(rds_ibdev);
   571  
   572          return ibmr;
   573  }

regards,
dan carpenter
