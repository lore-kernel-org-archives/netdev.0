From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 net-next 0/4]: Allow head adjustment in XDP prog
Date: Mon, 5 Dec 2016 19:25:32 +0100
Message-ID: <20161205192532.7cc9d5dd@redhat.com>
References: <1480821446-4122277-1-git-send-email-kafai@fb.com>
        <20161205175302.0d5d4fa7@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>, brouer@redhat.com
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52060 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751623AbcLESZj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 13:25:39 -0500
In-Reply-To: <20161205175302.0d5d4fa7@jkicinski-Precision-T1700>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 5 Dec 2016 17:53:02 +0000
Jakub Kicinski <kubakici@wp.pl> wrote:

> On Sat, 3 Dec 2016 19:17:22 -0800, Martin KaFai Lau wrote:
> > This series adds a helper to allow head adjusting in XDP prog.  mlx4
> > driver has been modified to support this feature.  An example is written
> > to encapsulate a packet with an IPv4/v6 header and then XDP_TX it
> > out.  
> 
> Can we just add a feature to one of four drivers which support XDP
> today and AFAICT leave it completely broken on remaining tree?
> 
> I'm not seeing any way for the drivers to inform the stack about their
> capabilities, would that not be a pre-requisite?

Thank you for bringing this up Jakub, very good point. I do think it
must be a pre-requisite that we have a capabilities negotiation
interface for XDP ... before adding new features.

As I've also documented here, and below:
 https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/design/design.html#ref-prog-negotiation

Capabilities negotiation
========================

.. Warning:: This interface is missing in the implementation

XDP has hooks and feature dependencies in the device drivers.
Planning for extendability, not all device drivers will necessarily
support all of the future features of XDP, and new feature adoption
in device drivers will occur at different development rates.

Thus, there is a need for the device driver to express what XDP
capabilities or features it provides.

When attaching/loading an XDP program into the kernel, a feature or
capabilities negotiation should be conducted.  This implies that an
XDP program needs to express what features it wants to use.

If an XDP program being loaded requests features that the given device
driver does not support, the program load should simply be rejected.

.. note:: I'm undecided on whether to have an query interface, because
   users could just use the regular load-interface to probe for
   supported options.  The downside of probing is the issues SElinux
   runs into, of false alarms, when glibc tries to probe for
   capabilities.


Implementation issue
--------------------

The current implementation is missing this interface.  Worse, the two
actions :ref:`XDP_DROP` and :ref:`XDP_TX` should have been expressed
as two different capabilities, because XDP_TX requires more changes to
the device driver than a simple drop like XDP_DROP.

One can (easily) imagine that an older driver only wants to implement
the XDP_DROP facility.  The reason is that XDP_TX would require
changing too much driver code, which is a concern for an old, stable
and time-proven driver.


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
