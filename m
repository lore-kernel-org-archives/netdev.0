From: Greg KH <greg@kroah.com>
Subject: [ofa-general] Re: [PATCH v3 08/13] QLogic VNIC: sysfs interface
	implementation for the driver
Date: Thu, 29 May 2008 10:48:05 -0700
Message-ID: <20080529174805.GA10903@kroah.com>
References: <20080529095126.9943.84692.stgit@localhost.localdomain>
	<20080529095754.9943.27936.stgit@localhost.localdomain>
	<20080529103003.010c4a08@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amar.mudrankit@qlogic.com, netdev@vger.kernel.org, rdreier@cisco.com,
	general@lists.openfabrics.org, poornima.kamath@qlogic.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20080529103003.010c4a08@extreme>
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

On Thu, May 29, 2008 at 10:30:03AM -0700, Stephen Hemminger wrote:
> On Thu, 29 May 2008 15:27:54 +0530
> Ramachandra K <ramachandra.kuchimanchi@qlogic.com> wrote:
> 
> > From: Amar Mudrankit <amar.mudrankit@qlogic.com>
> > 
> > The sysfs interface for the QLogic VNIC driver is implemented through
> > this patch.
> > 
> > Signed-off-by: Amar Mudrankit <amar.mudrankit@qlogic.com>
> > Signed-off-by: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
> > Signed-off-by: Poornima Kamath <poornima.kamath@qlogic.com>
> > ---
> > 
> >  drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c | 1133 +++++++++++++++++++++++++++
> >  drivers/infiniband/ulp/qlgc_vnic/vnic_sys.h |   51 +
> >  2 files changed, 1184 insertions(+), 0 deletions(-)
> >  create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c
> >  create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_sys.h
> > 
> > diff --git a/drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c b/drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c
> > new file mode 100644
> > index 0000000..40b3c77
> > --- /dev/null
> > +++ b/drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c
> > @@ -0,0 +1,1133 @@
> > +/*
> > + * Copyright (c) 2006 QLogic, Inc.  All rights reserved.
> > + *
> > + * This software is available to you under a choice of one of two
> > + * licenses.  You may choose to be licensed under the terms of the GNU
> > + * General Public License (GPL) Version 2, available from the file
> > + * COPYING in the main directory of this source tree, or the
> > + * OpenIB.org BSD license below:
> > + *
> > + *     Redistribution and use in source and binary forms, with or
> > + *     without modification, are permitted provided that the following
> > + *     conditions are met:
> > + *
> > + *      - Redistributions of source code must retain the above
> > + *        copyright notice, this list of conditions and the following
> > + *        disclaimer.
> > + *
> > + *      - Redistributions in binary form must reproduce the above
> > + *        copyright notice, this list of conditions and the following
> > + *        disclaimer in the documentation and/or other materials
> > + *        provided with the distribution.
> > + *
> > + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> > + * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> > + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> > + * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
> > + * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
> > + * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
> > + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> > + * SOFTWARE.
> > + */
> > +
> > +#include <linux/netdevice.h>
> > +#include <linux/parser.h>
> > +#include <linux/if.h>
> > +
> > +#include "vnic_util.h"
> > +#include "vnic_config.h"
> > +#include "vnic_ib.h"
> > +#include "vnic_viport.h"
> > +#include "vnic_main.h"
> > +#include "vnic_stats.h"
> > +
> > +/*
> > + * target eiocs are added by writing
> > + *
> > + * ioc_guid=<EIOC GUID>,dgid=<dest GID>,pkey=<P_key>,name=<interface_name>
> > + * to the create_primary  sysfs attribute.
> > + */
> > +enum {
> > +	VNIC_OPT_ERR = 0,
> > +	VNIC_OPT_IOC_GUID = 1 << 0,
> > +	VNIC_OPT_DGID = 1 << 1,
> > +	VNIC_OPT_PKEY = 1 << 2,
> > +	VNIC_OPT_NAME = 1 << 3,
> > +	VNIC_OPT_INSTANCE = 1 << 4,
> > +	VNIC_OPT_RXCSUM = 1 << 5,
> > +	VNIC_OPT_TXCSUM = 1 << 6,
> > +	VNIC_OPT_HEARTBEAT = 1 << 7,
> > +	VNIC_OPT_IOC_STRING = 1 << 8,
> > +	VNIC_OPT_IB_MULTICAST = 1 << 9,
> > +	VNIC_OPT_ALL = (VNIC_OPT_IOC_GUID |
> > +			VNIC_OPT_DGID | VNIC_OPT_NAME | VNIC_OPT_PKEY),
> > +};
> > +
> > +static match_table_t vnic_opt_tokens = {
> > +	{VNIC_OPT_IOC_GUID, "ioc_guid=%s"},
> > +	{VNIC_OPT_DGID, "dgid=%s"},
> > +	{VNIC_OPT_PKEY, "pkey=%x"},
> > +	{VNIC_OPT_NAME, "name=%s"},
> > +	{VNIC_OPT_INSTANCE, "instance=%d"},
> > +	{VNIC_OPT_RXCSUM, "rx_csum=%s"},
> > +	{VNIC_OPT_TXCSUM, "tx_csum=%s"},
> > +	{VNIC_OPT_HEARTBEAT, "heartbeat=%d"},
> > +	{VNIC_OPT_IOC_STRING, "ioc_string=\"%s"},
> > +	{VNIC_OPT_IB_MULTICAST, "ib_multicast=%s"},
> > +	{VNIC_OPT_ERR, NULL}
> > +};
> >
> 
> No sysfs is supposed to be one value per file use separate attributes
> for each one. This also eliminates the parsing code.

Also, every new sysfs file needs to have an entry in Documentation/ABI/
which shows how to use it and what the contents are.

And yes, multiple values per sysfs file are not allowed, sorry, please
change this.  If you need to configure your device through an interface
like this, consider using configfs instead, that is what it is there
for.

thanks,

greg k-h
