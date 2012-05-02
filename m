From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [V2 PATCH 0/9] vhost/macvtap zeropcopy fixes
Date: Wed, 02 May 2012 14:54:37 -0700
Message-ID: <87txzyb65e.fsf@xmission.com>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<20120502055008.GA29319@redhat.com>
	<20120502.024427.22049954455309204.davem@davemloft.net>
	<20120502081141.GA30549@redhat.com> <87pqammkvs.fsf@xmission.com>
	<20120502213128.GB8266@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jasowang@redhat.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Basil Gor <basil.gor@gmail.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120502213128.GB8266@redhat.com> (Michael S. Tsirkin's message
	of "Thu, 3 May 2012 00:31:29 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> writes:

> On Wed, May 02, 2012 at 12:40:55PM -0700, Eric W. Biederman wrote:
>> 
>> Side question.  Are you aware that macvtap/vhost net is broken
>> in the presence of  vlan accelleration and that vlan accelleration
>> is not optional if you are using vlan headers?
>> 
>> Eric
>
> I didn't know. Could you explain please?

It is worth looking at the netdev history for some recent patches by
Basil Gor, as he has been hit by this issue and has been trying to come
up with a clean fix.  I was burned by this issue in other parts of the
networking stack and so have been doing some basic review.

The short version is that on any normal path through the networking
stack we implement vlan header accelleration in hardware or emulation
in software.  The result is that the ethernet vlan header is not
on the packet and is instead in the skb->tci field.

When coming on out the pf_packet sockets we don't include the vlan
header in the packet but instead the vlan header is put in aux data.

The result of all of this is that vhost/net.c looses the vlan
header when coming from pf_packet socket.

Furthermore macvtap_recvmsg does not act like pf_packet sockets
when there is a vlan header persent so weirdness ensues.  Especially
when the packet is coming from a path where the vlan header has
been stripped and placed in skb->tci.

Eric
