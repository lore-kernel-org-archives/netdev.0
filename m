From: "Amar Mudrankit" <amar.mudrankit@qlogic.com>
Subject: Re: [ofa-general] Re: [PATCH v3 08/13] QLogic VNIC: sysfs interface
	implementation for the driver
Date: Tue, 3 Jun 2008 23:55:00 +0530
Message-ID: <c8028d330806031125x4181d8e3p9cdaf1f4c79e88c6@mail.gmail.com>
References: <20080529095126.9943.84692.stgit@localhost.localdomain>
	<20080529095754.9943.27936.stgit@localhost.localdomain>
	<20080529103003.010c4a08@extreme> <20080529174805.GA10903@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1417654741=="
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	rdreier@cisco.com, general@lists.openfabrics.org,
	poornima.kamath@qlogic.com
To: "Greg KH" <greg@kroah.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080529174805.GA10903@kroah.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Mime-version: 1.0
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

--===============1417654741==
Content-Type: multipart/alternative;
	boundary="----=_Part_19191_22829123.1212517500953"

------=_Part_19191_22829123.1212517500953
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thu, May 29, 2008 at 11:18 PM, Greg KH <greg@kroah.com> wrote:

> On Thu, May 29, 2008 at 10:30:03AM -0700, Stephen Hemminger wrote:
> > On Thu, 29 May 2008 15:27:54 +0530
> > Ramachandra K <ramachandra.kuchimanchi@qlogic.com> wrote:
> >
> > > From: Amar Mudrankit <amar.mudrankit@qlogic.com>
> > >
> > > The sysfs interface for the QLogic VNIC driver is implemented through
> > > this patch.
> > >
> > > Signed-off-by: Amar Mudrankit <amar.mudrankit@qlogic.com>
> > > Signed-off-by: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
> > > Signed-off-by: Poornima Kamath <poornima.kamath@qlogic.com>
> > > ---
> > >
> > >  drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c | 1133
> +++++++++++++++++++++++++++
> > >  drivers/infiniband/ulp/qlgc_vnic/vnic_sys.h |   51 +
> > >  2 files changed, 1184 insertions(+), 0 deletions(-)
> > >  create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c
> > >  create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_sys.h
> > >
> > > diff --git a/drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c
> b/drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c
> > > new file mode 100644
> > > index 0000000..40b3c77
> > > --- /dev/null
> > > +++ b/drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c
> > > @@ -0,0 +1,1133 @@
> > > +/*
> > > + * Copyright (c) 2006 QLogic, Inc.  All rights reserved.
> > > + *
> > > + * This software is available to you under a choice of one of two
> > > + * licenses.  You may choose to be licensed under the terms of the GNU
> > > + * General Public License (GPL) Version 2, available from the file
> > > + * COPYING in the main directory of this source tree, or the
> > > + * OpenIB.org BSD license below:
> > > + *
> > > + *     Redistribution and use in source and binary forms, with or
> > > + *     without modification, are permitted provided that the following
> > > + *     conditions are met:
> > > + *
> > > + *      - Redistributions of source code must retain the above
> > > + *        copyright notice, this list of conditions and the following
> > > + *        disclaimer.
> > > + *
> > > + *      - Redistributions in binary form must reproduce the above
> > > + *        copyright notice, this list of conditions and the following
> > > + *        disclaimer in the documentation and/or other materials
> > > + *        provided with the distribution.
> > > + *
> > > + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> > > + * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> > > + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> > > + * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
> > > + * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
> > > + * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
> > > + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> > > + * SOFTWARE.
> > > + */
> > > +
> > > +#include <linux/netdevice.h>
> > > +#include <linux/parser.h>
> > > +#include <linux/if.h>
> > > +
> > > +#include "vnic_util.h"
> > > +#include "vnic_config.h"
> > > +#include "vnic_ib.h"
> > > +#include "vnic_viport.h"
> > > +#include "vnic_main.h"
> > > +#include "vnic_stats.h"
> > > +
> > > +/*
> > > + * target eiocs are added by writing
> > > + *
> > > + * ioc_guid=<EIOC GUID>,dgid=<dest
> GID>,pkey=<P_key>,name=<interface_name>
> > > + * to the create_primary  sysfs attribute.
> > > + */
> > > +enum {
> > > +   VNIC_OPT_ERR = 0,
> > > +   VNIC_OPT_IOC_GUID = 1 << 0,
> > > +   VNIC_OPT_DGID = 1 << 1,
> > > +   VNIC_OPT_PKEY = 1 << 2,
> > > +   VNIC_OPT_NAME = 1 << 3,
> > > +   VNIC_OPT_INSTANCE = 1 << 4,
> > > +   VNIC_OPT_RXCSUM = 1 << 5,
> > > +   VNIC_OPT_TXCSUM = 1 << 6,
> > > +   VNIC_OPT_HEARTBEAT = 1 << 7,
> > > +   VNIC_OPT_IOC_STRING = 1 << 8,
> > > +   VNIC_OPT_IB_MULTICAST = 1 << 9,
> > > +   VNIC_OPT_ALL = (VNIC_OPT_IOC_GUID |
> > > +                   VNIC_OPT_DGID | VNIC_OPT_NAME | VNIC_OPT_PKEY),
> > > +};
> > > +
> > > +static match_table_t vnic_opt_tokens = {
> > > +   {VNIC_OPT_IOC_GUID, "ioc_guid=%s"},
> > > +   {VNIC_OPT_DGID, "dgid=%s"},
> > > +   {VNIC_OPT_PKEY, "pkey=%x"},
> > > +   {VNIC_OPT_NAME, "name=%s"},
> > > +   {VNIC_OPT_INSTANCE, "instance=%d"},
> > > +   {VNIC_OPT_RXCSUM, "rx_csum=%s"},
> > > +   {VNIC_OPT_TXCSUM, "tx_csum=%s"},
> > > +   {VNIC_OPT_HEARTBEAT, "heartbeat=%d"},
> > > +   {VNIC_OPT_IOC_STRING, "ioc_string=\"%s"},
> > > +   {VNIC_OPT_IB_MULTICAST, "ib_multicast=%s"},
> > > +   {VNIC_OPT_ERR, NULL}
> > > +};
> > >
> >
> > No sysfs is supposed to be one value per file use separate attributes
> > for each one. This also eliminates the parsing code.
>
> And yes, multiple values per sysfs file are not allowed, sorry, please
> change this.  If you need to configure your device through an interface
> like this, consider using configfs instead, that is what it is there
> for.


Documentation/filesystems/configfs/configfs.txt <<snip>>

                  [Using configfs]

                  Like sysfs, attributes should be ASCII text files,
preferably
                  with only one value per file.  The same efficiency caveats
from sysfs
                  apply.  Don't mix more than one attribute in one attribute
file.

It looks like configfs also does not allow multiple attributes per file.
So, in that case, shall we modify our sysfs code to support one value per
sysfs file? With this approach, the impact on user space applications that
we have which depend on the qlgc_vnic driver sysfs interface will be less.

Thanks and Regards,
Amar

>
> _______________________________________________
> general mailing list
> general@lists.openfabrics.org
> http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general
>
> To unsubscribe, please visit
> http://openib.org/mailman/listinfo/openib-general
>

------=_Part_19191_22829123.1212517500953
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

<br><br><div class="gmail_quote">On Thu, May 29, 2008 at 11:18 PM, Greg KH &lt;<a href="mailto:greg@kroah.com">greg@kroah.com</a>&gt; wrote:<br><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
<div><div></div><div class="Wj3C7c">On Thu, May 29, 2008 at 10:30:03AM -0700, Stephen Hemminger wrote:<br>
&gt; On Thu, 29 May 2008 15:27:54 +0530<br>
&gt; Ramachandra K &lt;<a href="mailto:ramachandra.kuchimanchi@qlogic.com">ramachandra.kuchimanchi@qlogic.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; From: Amar Mudrankit &lt;<a href="mailto:amar.mudrankit@qlogic.com">amar.mudrankit@qlogic.com</a>&gt;<br>
&gt; &gt;<br>
&gt; &gt; The sysfs interface for the QLogic VNIC driver is implemented through<br>
&gt; &gt; this patch.<br>
&gt; &gt;<br>
&gt; &gt; Signed-off-by: Amar Mudrankit &lt;<a href="mailto:amar.mudrankit@qlogic.com">amar.mudrankit@qlogic.com</a>&gt;<br>
&gt; &gt; Signed-off-by: Ramachandra K &lt;<a href="mailto:ramachandra.kuchimanchi@qlogic.com">ramachandra.kuchimanchi@qlogic.com</a>&gt;<br>
&gt; &gt; Signed-off-by: Poornima Kamath &lt;<a href="mailto:poornima.kamath@qlogic.com">poornima.kamath@qlogic.com</a>&gt;<br>
&gt; &gt; ---<br>
&gt; &gt;<br>
&gt; &gt; &nbsp;drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c | 1133 +++++++++++++++++++++++++++<br>
&gt; &gt; &nbsp;drivers/infiniband/ulp/qlgc_vnic/vnic_sys.h | &nbsp; 51 +<br>
&gt; &gt; &nbsp;2 files changed, 1184 insertions(+), 0 deletions(-)<br>
&gt; &gt; &nbsp;create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c<br>
&gt; &gt; &nbsp;create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_sys.h<br>
&gt; &gt;<br>
&gt; &gt; diff --git a/drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c b/drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c<br>
&gt; &gt; new file mode 100644<br>
&gt; &gt; index 0000000..40b3c77<br>
&gt; &gt; --- /dev/null<br>
&gt; &gt; +++ b/drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c<br>
&gt; &gt; @@ -0,0 +1,1133 @@<br>
&gt; &gt; +/*<br>
&gt; &gt; + * Copyright (c) 2006 QLogic, Inc. &nbsp;All rights reserved.<br>
&gt; &gt; + *<br>
&gt; &gt; + * This software is available to you under a choice of one of two<br>
&gt; &gt; + * licenses. &nbsp;You may choose to be licensed under the terms of the GNU<br>
&gt; &gt; + * General Public License (GPL) Version 2, available from the file<br>
&gt; &gt; + * COPYING in the main directory of this source tree, or the<br>
&gt; &gt; + * OpenIB.org BSD license below:<br>
&gt; &gt; + *<br>
&gt; &gt; + * &nbsp; &nbsp; Redistribution and use in source and binary forms, with or<br>
&gt; &gt; + * &nbsp; &nbsp; without modification, are permitted provided that the following<br>
&gt; &gt; + * &nbsp; &nbsp; conditions are met:<br>
&gt; &gt; + *<br>
&gt; &gt; + * &nbsp; &nbsp; &nbsp;- Redistributions of source code must retain the above<br>
&gt; &gt; + * &nbsp; &nbsp; &nbsp; &nbsp;copyright notice, this list of conditions and the following<br>
&gt; &gt; + * &nbsp; &nbsp; &nbsp; &nbsp;disclaimer.<br>
&gt; &gt; + *<br>
&gt; &gt; + * &nbsp; &nbsp; &nbsp;- Redistributions in binary form must reproduce the above<br>
&gt; &gt; + * &nbsp; &nbsp; &nbsp; &nbsp;copyright notice, this list of conditions and the following<br>
&gt; &gt; + * &nbsp; &nbsp; &nbsp; &nbsp;disclaimer in the documentation and/or other materials<br>
&gt; &gt; + * &nbsp; &nbsp; &nbsp; &nbsp;provided with the distribution.<br>
&gt; &gt; + *<br>
&gt; &gt; + * THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND,<br>
&gt; &gt; + * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF<br>
&gt; &gt; + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND<br>
&gt; &gt; + * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS<br>
&gt; &gt; + * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN<br>
&gt; &gt; + * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN<br>
&gt; &gt; + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE<br>
&gt; &gt; + * SOFTWARE.<br>
&gt; &gt; + */<br>
&gt; &gt; +<br>
&gt; &gt; +#include &lt;linux/netdevice.h&gt;<br>
&gt; &gt; +#include &lt;linux/parser.h&gt;<br>
&gt; &gt; +#include &lt;linux/if.h&gt;<br>
&gt; &gt; +<br>
&gt; &gt; +#include &quot;vnic_util.h&quot;<br>
&gt; &gt; +#include &quot;vnic_config.h&quot;<br>
&gt; &gt; +#include &quot;vnic_ib.h&quot;<br>
&gt; &gt; +#include &quot;vnic_viport.h&quot;<br>
&gt; &gt; +#include &quot;vnic_main.h&quot;<br>
&gt; &gt; +#include &quot;vnic_stats.h&quot;<br>
&gt; &gt; +<br>
&gt; &gt; +/*<br>
&gt; &gt; + * target eiocs are added by writing<br>
&gt; &gt; + *<br>
&gt; &gt; + * ioc_guid=&lt;EIOC GUID&gt;,dgid=&lt;dest GID&gt;,pkey=&lt;P_key&gt;,name=&lt;interface_name&gt;<br>
&gt; &gt; + * to the create_primary &nbsp;sysfs attribute.<br>
&gt; &gt; + */<br>
&gt; &gt; +enum {<br>
&gt; &gt; + &nbsp; VNIC_OPT_ERR = 0,<br>
&gt; &gt; + &nbsp; VNIC_OPT_IOC_GUID = 1 &lt;&lt; 0,<br>
&gt; &gt; + &nbsp; VNIC_OPT_DGID = 1 &lt;&lt; 1,<br>
&gt; &gt; + &nbsp; VNIC_OPT_PKEY = 1 &lt;&lt; 2,<br>
&gt; &gt; + &nbsp; VNIC_OPT_NAME = 1 &lt;&lt; 3,<br>
&gt; &gt; + &nbsp; VNIC_OPT_INSTANCE = 1 &lt;&lt; 4,<br>
&gt; &gt; + &nbsp; VNIC_OPT_RXCSUM = 1 &lt;&lt; 5,<br>
&gt; &gt; + &nbsp; VNIC_OPT_TXCSUM = 1 &lt;&lt; 6,<br>
&gt; &gt; + &nbsp; VNIC_OPT_HEARTBEAT = 1 &lt;&lt; 7,<br>
&gt; &gt; + &nbsp; VNIC_OPT_IOC_STRING = 1 &lt;&lt; 8,<br>
&gt; &gt; + &nbsp; VNIC_OPT_IB_MULTICAST = 1 &lt;&lt; 9,<br>
&gt; &gt; + &nbsp; VNIC_OPT_ALL = (VNIC_OPT_IOC_GUID |<br>
&gt; &gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; VNIC_OPT_DGID | VNIC_OPT_NAME | VNIC_OPT_PKEY),<br>
&gt; &gt; +};<br>
&gt; &gt; +<br>
&gt; &gt; +static match_table_t vnic_opt_tokens = {<br>
&gt; &gt; + &nbsp; {VNIC_OPT_IOC_GUID, &quot;ioc_guid=%s&quot;},<br>
&gt; &gt; + &nbsp; {VNIC_OPT_DGID, &quot;dgid=%s&quot;},<br>
&gt; &gt; + &nbsp; {VNIC_OPT_PKEY, &quot;pkey=%x&quot;},<br>
&gt; &gt; + &nbsp; {VNIC_OPT_NAME, &quot;name=%s&quot;},<br>
&gt; &gt; + &nbsp; {VNIC_OPT_INSTANCE, &quot;instance=%d&quot;},<br>
&gt; &gt; + &nbsp; {VNIC_OPT_RXCSUM, &quot;rx_csum=%s&quot;},<br>
&gt; &gt; + &nbsp; {VNIC_OPT_TXCSUM, &quot;tx_csum=%s&quot;},<br>
&gt; &gt; + &nbsp; {VNIC_OPT_HEARTBEAT, &quot;heartbeat=%d&quot;},<br>
&gt; &gt; + &nbsp; {VNIC_OPT_IOC_STRING, &quot;ioc_string=\&quot;%s&quot;},<br>
&gt; &gt; + &nbsp; {VNIC_OPT_IB_MULTICAST, &quot;ib_multicast=%s&quot;},<br>
&gt; &gt; + &nbsp; {VNIC_OPT_ERR, NULL}<br>
&gt; &gt; +};<br>
&gt; &gt;<br>
&gt;<br>
&gt; No sysfs is supposed to be one value per file use separate attributes<br>
&gt; for each one. This also eliminates the parsing code.<br></div></div><br>
And yes, multiple values per sysfs file are not allowed, sorry, please<br>
change this. &nbsp;If you need to configure your device through an interface<br>
like this, consider using configfs instead, that is what it is there<br>
for.</blockquote><div>&nbsp;</div><div>Documentation/filesystems/configfs/configfs.txt &lt;&lt;snip&gt;&gt;<br><div><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [Using configfs]<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Like sysfs, attributes should be ASCII text files, preferably<br>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; with only one value per file.&nbsp; The same efficiency caveats from sysfs<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; apply.&nbsp; Don&#39;t mix more than one attribute in one attribute file.<br><br></div>
It looks like configfs also does not allow multiple attributes per
file.&nbsp; So, in that case, shall we modify our sysfs code to support one
value per sysfs file? With this approach, the impact on user space applications that we have which depend on the qlgc_vnic driver sysfs interface will be less.<br>


</div><div><br>Thanks and Regards,<br>Amar&nbsp; <br></div><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;"><br>
<div><div></div><div class="Wj3C7c">_______________________________________________<br>
general mailing list<br>
<a href="mailto:general@lists.openfabrics.org">general@lists.openfabrics.org</a><br>
<a href="http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general" target="_blank">http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general</a><br>
<br>
To unsubscribe, please visit <a href="http://openib.org/mailman/listinfo/openib-general" target="_blank">http://openib.org/mailman/listinfo/openib-general</a><br>
</div></div></blockquote></div><br>

------=_Part_19191_22829123.1212517500953--

--===============1417654741==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1417654741==--
