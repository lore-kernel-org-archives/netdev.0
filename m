From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Mon, 20 Aug 2012 21:57:26 +0300
Message-ID: <20120820185625.GA5234@redhat.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
 <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com>
 <87boitz044.fsf@xmission.com>
 <20120805185031.GA18640@redhat.com>
 <CAJZOPZKtdvxTGvrxj+T896mEexb=yN9s1cCuqUmhhzCOvUPEnA@mail.gmail.com>
 <20120812102240.GG1421@redhat.com>
 <5027AC88.2020509@mellanox.com>
 <20120812135544.GB6003@redhat.com>
 <5027BA17.6010503@mellanox.com>
 <20120812205457.GA14081@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, davem@davemloft.net,
	roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, Erez Shitrit <erezsh@mellanox.co.il>,
	Doug Ledford <dledford@redhat.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1238 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752537Ab2HTS4o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 14:56:44 -0400
Content-Disposition: inline
In-Reply-To: <20120812205457.GA14081@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 12, 2012 at 11:54:57PM +0300, Michael S. Tsirkin wrote:
> > and remember that
> > this code (VM through eipoib) can talk to any IPoIB element on the
> > fabric, native,
> > virtualized,  HW/SW gateways, etc etc.
> > 
> > Or.
> 
> If you want this, then you really want a limited form of IPoIB bridging.


And to clarify that statement, here is how I would make such
IPoIB "bridging" work:

Guest side:

- Implement virtio-ipoib. This would be a device like virtio-net,
  but instead of ethernet packets, it would pass packets
  that consist of:
	IPoIB destination address
	IP packet

- this is passed to/from host without modifications, possibly with addition
  of header such as virtio net header

- flags such as broadcast can also be added to header

- like virtio net get capabilities from host and expose
  as netdev capabilities

Host side:
- create macvtap -passthrough like device that can sit on top of an
  ipoib interface
- expose this device QPN and GID to guest as hardware address
- as we get packet forward it on UD QPN or CM as appropriate
  depending on size,checksum and admin preference
- expose capabilities such as TSO
- can expose capability such as max MTU to guest too

Above means hardware address changes with migration.
So we need to notify guest when this happens.

This can be addressed from host by notifying all
neighbours.

Alternatively guest can notify all neighbours.

Notification can be done by broadcast.
This second option seems preferable.

this ipoib-vtap can support two modes
	- bridge like mode:
	  guest to guest and guest to host packets
	  can be detected by macvtap and passed
	  to/from guest directly like macvlan bridge mode

	- vepa like mode
	  guest to guest and guest to host packets
	  are sent out and looped back by IB switch
	  like macvlan vepa mode

As compared to the custom protocol I sent, it has -
Advantages: interoperates cleanly with ipoib
Disadvantages: no support for legacy (ethernet-only) guest

-- 
MST
