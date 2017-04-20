From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: XDP question: best API for returning/setting egress port?
Date: Thu, 20 Apr 2017 08:39:29 +0200
Message-ID: <20170420083929.3eec20ee@redhat.com>
References: <20170418215856.5fda7127@redhat.com>
        <20170419200259.GK4730@C02RW35GFVH8.dhcp.broadcom.net>
        <58F7E9F3.5090604@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>, brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50672 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966233AbdDTGjh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 02:39:37 -0400
In-Reply-To: <58F7E9F3.5090604@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Apr 2017 00:51:31 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 04/19/2017 10:02 PM, Andy Gospodarek wrote:
> [...]
> > and then lookup this dest in a table we have the option to make that
> > dest an ifindex/socket/other.
> >
> > I did also look at JohnF's patch and I do like the simplicity of the redirect
> > action and new ndo_xdp_xmit and how it moves towards a way to transmit the
> > frame.  The downside is that it presumes an ifindex, so it might not be ideal
> > we want the lookup to return something other than an ifindex.
> >  
> [...]
> > would be handled.  If we are ultimately going to need a new netdev op to
> > handle the redirect then what may be the issue with not providing the
> > destination port the return code and the option proposed by JohnF looks
> > good to me with maybe a small tweak to not presume ifindex in some manner.  
> 
> Is there a concrete reason that all the proposed future cases like sockets
> have to be handled within the very same XDP_REDIRECT return code? F.e. why
> not XDP_TX_NIC that only assumes ifindex as proposed in the patch, and future
> ones would get a different return code f.e. XDP_TX_SK only handling sockets
> when we get there implementation-wise?

The concrete reason for an "unified" return code is to simplify changes
needed in the drivers.  The purpose is moving code out of the drivers
into the core.  IMHO we should keep drivers as simple as possible and
stop adding more return action codes. XDP_REDIRECT combined with a
port-table should be the last action-code needed in the drivers.
As the port table will know the "type" of the port.

Keeping action XDP_DROP and XDP_TX inside the drivers make sense,
because it allow for driver level optimizations. Actions that want to
transfer the packet/xdp_buff "outside" the driver should call a core
function (given it will be called with the xdp_buff struct, you can
hide all your extra extensions there without changing the driver code).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
