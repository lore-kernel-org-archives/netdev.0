From: Grant Grundler <iod00d@hp.com>
Subject: Re: error compiling kernel...
Date: Mon, 7 Nov 2005 21:59:49 -0800
Message-ID: <20051108055949.GC18222@esmail.cup.hp.com>
References: <b9b9c93f0511041311s423c4ff6x531f211672d2ebcc@mail.gmail.com>
	<20051106105449.GR31134@mellanox.co.il>
	<4370275D.9060001@cse.ohio-state.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <4370275D.9060001@cse.ohio-state.edu>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 07, 2005 at 11:19:41PM -0500, Sayantan Sur wrote:
...
> Has anyone been able to compile gen2 with 2.6.14?

Yes - but I've run into a different problem.
After fixing up include/rdma to point at drivers/infiniband/include/rdma,
I get a symbol missing from from the modules.


iota:/usr/src/linux-2.6.14# make modules_install
...
if [ -r System.map -a -x /sbin/depmod ]; then /sbin/depmod -ae -F System.map  2.
6.14; fi                                                                        
WARNING: /lib/modules/2.6.14/kernel/drivers/infiniband/ulp/sdp/ib_sdp.ko needs u
nknown symbol ip_dev_find                                                       
WARNING: /lib/modules/2.6.14/kernel/drivers/infiniband/core/ib_at.ko needs unkno
wn symbol ip_dev_find                                                           
WARNING: /lib/modules/2.6.14/kernel/drivers/infiniband/core/ib_addr.ko needs unk
nown symbol ip_dev_find                                                         
iota:/usr/src/linux-2.6.14#

ip_dev_find() is not exported by net/ipv4/fib_frontend.c.

However, drivers/infiniband is the only module that needs this.
CONFIG_IP_MROUTE is another configurable user but cannot be enabled
as a module.

Patch below adds EXPORT_SYMBOL() to fib_frontend.c.
I'm not trying to assert this is the Right Thing.
It's just the first obvious solution to the immediate problem.

thanks,
grant

Signed-off-by: Grant Grundler <iod00d@hp.com>

--- linux-2.6.14-ORIG/net/ipv4/fib_frontend.c   2005-10-27 17:02:08.000000000 -0700
+++ linux-2.6.14/net/ipv4/fib_frontend.c        2005-11-07 21:29:22.000000000 -0800
@@ -662,3 +662,4 @@ void __init ip_fib_init(void)
 
 EXPORT_SYMBOL(inet_addr_type);
 EXPORT_SYMBOL(ip_rt_ioctl);
+EXPORT_SYMBOL(ip_dev_find);
