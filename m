From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Fri, 09 Jun 2017 18:24:01 -0400
Message-ID: <1497047041.7171.234.camel@redhat.com>
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
         <20170607192132.GA10929@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "jsorensen-b10kYP2dOMg@public.gmane.org" <jsorensen-b10kYP2dOMg@public.gmane.org>,
        Andy Shevchenko <andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "linux-fpga-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-fpga-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Alan Tull <atull-yzvPICuk2ABMcg4IHK0kFoH6Mc4MB0Vx@public.gmane.org>,
        "yi1.li-VuQAYsv1563Yd54FQh9/CA@public.gmane.org" <yi1.li-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
        Boris Pismenny <borisp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170607192132.GA10929-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-06-07 at 13:21 -0600, Jason Gunthorpe wrote:
> On Wed, Jun 07, 2017 at 10:13:43PM +0300, Saeed Mahameed wrote:
> > 
> > No !!
> > I am just showing you that the ib_core eventually will end up
> > calling
> > mlx5_core to create a QP.
> > so mlx5_core can create the QP it self since it is the one
> > eventually
> > creating QPs.
> > we just call mlx5_core_create_qp directly.
> 
> Which is building a RDMA ULP inside a driver without using the core
> code :(

Aren't the transmit/receive queues of the Ethernet netdevice on
mlx4/mlx5 hardware QPs too?  Those bypass the RDMA subsystem entirely.
 Just because something uses a QP on hardware that does *everything*
via QPs doesn't necessarily mean it must go through the RDMA subsystem.

Now, the fact that the content of the packets is basically a RoCE
packet does make things a bit fuzzier, but if their packets are
specially crafted RoCE packets that aren't really intended to be fully
RoCE spec compliant (maybe they don't support all the options as normal
RoCE QPs), then I can see hiding them from the larger RoCE portion of
the RDMA stack.

> > 
> > > 
> > > This keep getting more ugly :(
> > > 
> > > What about security? What if user space sends some raw packets to
> > > the
> > > FPGA - can it reprogram the ISPEC settings or worse?
> > > 
> > 
> > No such thing. This QP is only for internal driver/HW
> > communications,
> > as it is faster from the existing command interface.
> > it is not meant to be exposed for any raw user space usages at all,
> > without proper standard API adapter of course.
> 
> I'm not asking about the QP, I'm asking what happens after the NIC
> part. You use ROCE packets to control the FPGA. What prevents
> userspace from forcibly constructing roce packets and sending them to
> the FPGA. How does the FPGA know for certain the packet came from the
> kernel QP and not someplace else.

This is a valid concern.

> This is especially true for mlx nics as there are many raw packet
> bypass mechanisms available to userspace.

Right.  The question becomes: Does the firmware filter outgoing raw ETH
QPs such that a nefarious user could not send a crafted RoCE packet
that the bump on the wire would intercept and accept?

-- 
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
