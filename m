From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: XDP redirect measurements, gotchas and tracepoints
Date: Tue, 29 Aug 2017 15:26:01 +0200
Message-ID: <20170829152601.02fdb8a3@redhat.com>
References: <599C7530.2010405@gmail.com>
        <1503426617.2434.5.camel@intel.com>
        <CACKFLimMWLto4FRxNE3tzrO5MU+p67J7wu=n1nmg0t8QGYjgrA@mail.gmail.com>
        <CAKgT0Uf=ZfVeK-wtvNxSyGEVZ3UseUOHiP3ZOg-SrzmqsR=LtQ@mail.gmail.com>
        <CACKFLinJ0N7b8Xhq4ZoHdB80uXp_MU_vVyzZa7Dq11XrXsvDbw@mail.gmail.com>
        <20170823102937.79a9c4ed@redhat.com>
        <CACKFLinGuaDLxYRd=vC99DL5n0mf0rDbPRaDg4ctev=DEAhRSQ@mail.gmail.com>
        <20170825144513.1ee9fbb1@redhat.com>
        <59A03DF5.7070806@gmail.com>
        <CACKFLin-sZEkkCxE2iZRHjgG=K36OJ65B-xrEYVCCSQqhYsH-g@mail.gmail.com>
        <20170828160237.GA70910@C02RW35GFVH8.dhcp.broadcom.net>
        <CAKgT0UeZ5Wn+8qY8kbBef5weORwGAXjq6Qp7jtB1bscmjY_oYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>,
        Michael Chan <michael.chan@broadcom.com>,
        John Fastabend <john.fastabend@gmail.com>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "pstaszewski@itcare.pl" <pstaszewski@itcare.pl>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        "borkmann@iogearbox.net" <borkmann@iogearbox.net>,
        brouer@redhat.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36070 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752141AbdH2N0K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 09:26:10 -0400
In-Reply-To: <CAKgT0UeZ5Wn+8qY8kbBef5weORwGAXjq6Qp7jtB1bscmjY_oYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 28 Aug 2017 09:11:25 -0700 Alexander Duyck <alexander.duyck@gmail.com> wrote:

> My advice would be to not over complicate this. My big concern with
> all this buffer recycling is what happens the first time somebody
> introduces something like mirroring? Are you going to copy the data to
> a new page which would be quite expensive or just have to introduce
> reference counts? You are going to have to deal with stuff like
> reference counts eventually so you might as well bite that bullet now.
> My advice would be to not bother with optimizing for performance right
> now and instead focus on just getting functionality. The approach we
> took in ixgbe for the transmit path should work for almost any other
> driver since all you are looking at is having to free the page
> reference which takes care of reference counting already.

This return API is not about optimizing performance right now.  It is
actually about allowing us to change the underlying memory model per RX
queue for XDP.

If a RX-ring is use for both SKBs and XDP, then the refcnt model is
still enforced.  Although a driver using the 1-packet-per-page model,
should be able to reuse refcnt==1 pages when returned from XDP.

If a RX-ring is _ONLY_ used for XDP, then the driver have freedom to
implement another memory model, with the return-API.  We need to
experiment with the most optimal memory model.  The 1-packet-per-page
model is actually not the fastest, because of PCI-e bottlenecks.  With
HW support for packing descriptors and packets over the PCI-e bus, much
higher rates can be achieved.  Mellanox mlx5-Lx already have the needed HW
support.  And companies like NetCope also have 100G HW that does
similar tricks, and they even have a whitepaper[1][2] how they are
faster than DPDK with their NDP (Netcope Data Plane) API.

We do need the ability/flexibility to change the RX memory model, to
take advantage of this new NIC hardware.

[1] https://www.netcope.com/en/resources/improving-dpdk-performance
[2] https://www.netcope.com/en/company/press-center/press-releases/read-new-netcope-whitepaper-on-dpdk-acceleration

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
