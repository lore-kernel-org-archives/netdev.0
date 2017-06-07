From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Wed, 7 Jun 2017 13:21:32 -0600
Message-ID: <20170607192132.GA10929@obsidianresearch.com>
References: <AM4PR0501MB194037FF8F17466BC9ECC73DDBF30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <AM4PR0501MB19409139227E11A4A7F82F0FDBF30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170601153704.GA1680@obsidianresearch.com>
 <AM4PR0501MB19404B83A69B87AFB1326B45DBF50@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170605151724.GA20182@obsidianresearch.com>
 <AM4PR0501MB194008AAABEB6AAAA2ADFC82DBCB0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
 <20170606161709.GA8671@obsidianresearch.com>
 <CALzJLG9Rdjme2piWX+CDeHZZebWArM_wGjLJPh8=COOxBHuFkw@mail.gmail.com>
 <20170607154858.GA30124@obsidianresearch.com>
 <CALzJLG8epxWp1pmTd_fxOUfzXF5YoOFfnrRBJ0-YZVL1Gi_yOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilan Tayari <ilant@mellanox.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "jsorensen@fb.com" <jsorensen@fb.com>,
        Andy Shevchenko <andy.shevchenko@gmail.com>,
        "linux-fpga@vger.kernel.org" <linux-fpga@vger.kernel.org>,
        Alan Tull <atull@opensource.altera.com>,
        "yi1.li@linux.intel.com" <yi1.li@linux.intel.com>,
        Boris Pismenny <borisp@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:47630 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751877AbdFGTVo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 15:21:44 -0400
Content-Disposition: inline
In-Reply-To: <CALzJLG8epxWp1pmTd_fxOUfzXF5YoOFfnrRBJ0-YZVL1Gi_yOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 07, 2017 at 10:13:43PM +0300, Saeed Mahameed wrote:
> On Wed, Jun 7, 2017 at 6:48 PM, Jason Gunthorpe
> <jgunthorpe@obsidianresearch.com> wrote:
> > On Wed, Jun 07, 2017 at 07:16:42AM +0300, Saeed Mahameed wrote:
> >> On Tue, Jun 6, 2017 at 7:17 PM, Jason Gunthorpe
> >> <jgunthorpe@obsidianresearch.com> wrote:
> >> > On Tue, Jun 06, 2017 at 06:52:15AM +0000, Ilan Tayari wrote:
> >> >
> >> >> So neither the host stack nor the network are aware of them.
> >> >> They exist momentarily only on the internal traces on the board and not
> >> >> anywhere else.
> >> >
> >> > Is that really true? If you are creating rocee QPs' then the RDMA
> >> > stack sees this stuff and now we have buried a RDMA ULP inside an
> >> > ethernet driver which seems really wonky..
> >>
> >> It is not an ethernet driver, mlx5_core provides both RDMA and
> >> ethernet interfaces to both mlx5_ib and the mlx5e netdevice.
> >>
> >> so it is perfectly capable of creating QPs on its own, after all it is
> >> the one creating QPs for the RDMA stack :).
> >>
> >> rdma_create_qp->mlx5_ib_create_qp->mlx5_core_create_qp.
> >
> > Wait, so you built a RDMA ULP inside your driver without using the
> > RDMA API?
> >
> 
> No !!
> I am just showing you that the ib_core eventually will end up calling
> mlx5_core to create a QP.
> so mlx5_core can create the QP it self since it is the one eventually
> creating QPs.
> we just call mlx5_core_create_qp directly.

Which is building a RDMA ULP inside a driver without using the core
code :(

> > This keep getting more ugly :(
> >
> > What about security? What if user space sends some raw packets to the
> > FPGA - can it reprogram the ISPEC settings or worse?
> >
> 
> No such thing. This QP is only for internal driver/HW communications,
> as it is faster from the existing command interface.
> it is not meant to be exposed for any raw user space usages at all,
> without proper standard API adapter of course.

I'm not asking about the QP, I'm asking what happens after the NIC
part. You use ROCE packets to control the FPGA. What prevents
userspace from forcibly constructing roce packets and sending them to
the FPGA. How does the FPGA know for certain the packet came from the
kernel QP and not someplace else.

This is especially true for mlx nics as there are many raw packet
bypass mechanisms available to userspace.

Jason
