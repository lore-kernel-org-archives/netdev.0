From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH for-next 03/11] IB/hns: Optimize the logic of allocating
 memory using APIs
Date: Tue, 15 Nov 2016 15:52:46 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F91A7A2371@lhreml503-mbx>
References: <20161104163633.141880-1-salil.mehta@huawei.com>
 <20161104163633.141880-4-salil.mehta@huawei.com>
 <20161109072130.GH27883@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "dledford@redhat.com" <dledford@redhat.com>,
        "Huwei (Xavier)" <xavier.huwei@huawei.com>,
        oulijun <oulijun@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>,
        "Zhangping (ZP)" <zhangping5@huawei.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161109072130.GH27883@leon.nu>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Leon Romanovsky [mailto:leon@kernel.org]
> Sent: Wednesday, November 09, 2016 7:22 AM
> To: Salil Mehta
> Cc: dledford@redhat.com; Huwei (Xavier); oulijun;
> mehta.salil.lnk@gmail.com; linux-rdma@vger.kernel.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Linuxarm;
> Zhangping (ZP)
> Subject: Re: [PATCH for-next 03/11] IB/hns: Optimize the logic of
> allocating memory using APIs
> 
> On Fri, Nov 04, 2016 at 04:36:25PM +0000, Salil Mehta wrote:
> > From: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>
> >
> > This patch modified the logic of allocating memory using APIs in
> > hns RoCE driver. We used kcalloc instead of kmalloc_array and
> > bitmap_zero. And When kcalloc failed, call vzalloc to alloc
> > memory.
> >
> > Signed-off-by: Wei Hu (Xavier) <xavier.huwei@huawei.com>
> > Signed-off-by: Ping Zhang <zhangping5@huawei.com>
> > Signed-off-by: Salil Mehta  <salil.mehta@huawei.com>
> > ---
> >  drivers/infiniband/hw/hns/hns_roce_mr.c |   15 ++++++++-------
> >  1 file changed, 8 insertions(+), 7 deletions(-)
> >
> > diff --git a/drivers/infiniband/hw/hns/hns_roce_mr.c
> b/drivers/infiniband/hw/hns/hns_roce_mr.c
> > index fb87883..d3dfb5f 100644
> > --- a/drivers/infiniband/hw/hns/hns_roce_mr.c
> > +++ b/drivers/infiniband/hw/hns/hns_roce_mr.c
> > @@ -137,11 +137,12 @@ static int hns_roce_buddy_init(struct
> hns_roce_buddy *buddy, int max_order)
> >
> >  	for (i = 0; i <= buddy->max_order; ++i) {
> >  		s = BITS_TO_LONGS(1 << (buddy->max_order - i));
> > -		buddy->bits[i] = kmalloc_array(s, sizeof(long),
> GFP_KERNEL);
> > -		if (!buddy->bits[i])
> > -			goto err_out_free;
> > -
> > -		bitmap_zero(buddy->bits[i], 1 << (buddy->max_order - i));
> > +		buddy->bits[i] = kcalloc(s, sizeof(long), GFP_KERNEL);
> > +		if (!buddy->bits[i]) {
> > +			buddy->bits[i] = vzalloc(s * sizeof(long));
> 
> I wonder, why don't you use directly vzalloc instead of kcalloc
> fallback?
As we know we will have physical contiguous pages if the kcalloc
call succeeds. This will give us a chance to have better performance
over the allocations which are just virtually contiguous through the
function vzalloc(). Therefore, later has only been used as a fallback
when our memory request cannot be entertained through kcalloc.

Are you suggesting that there will not be much performance penalty
if we use just vzalloc ?

> 
> > +			if (!buddy->bits[i])
> > +				goto err_out_free;
> > +		}
> >  	}
