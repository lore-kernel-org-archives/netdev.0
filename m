From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Fwd: [RFC PATCH net-next 0/3] virtio_net: add aRFS support
Date: Mon, 20 Jan 2014 14:36:13 +0000
Message-ID: <1390228573.1565.2.camel@bwh-desktop.uk.level5networks.com>
References: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
	 <52D75EA5.1050000@redhat.com>
	 <CAEH94Lg7ygXgHqE8ubE+nuunicDqgmnCfO2AuDSS2nXgv5GikQ@mail.gmail.com>
	 <20140116085253.GA32073@stefanha-thinkpad.redhat.com>
	 <CA+mtBx9PBtYurdnhCKL0MLL8i+_+3yPNWFVj5h6SPJH+YDBCjw@mail.gmail.com>
	 <20140117052229.GE16061@stefanha-thinkpad.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Zhi Yong Wu <zwu.kernel@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"Rusty Russell" <rusty@rustcorp.com.au>,
	Jason Wang <jasowang@redhat.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8178 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751627AbaATOgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 09:36:22 -0500
In-Reply-To: <20140117052229.GE16061@stefanha-thinkpad.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-17 at 13:22 +0800, Stefan Hajnoczi wrote:
> On Thu, Jan 16, 2014 at 09:12:29AM -0800, Tom Herbert wrote:
> > On Thu, Jan 16, 2014 at 12:52 AM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
[...]
> > > If it's not possible or too hard to implement aRFS down the entire
> > > stack, we won't be able to process the packet on the right CPU.
> > > Then we might as well not bother with aRFS and just distribute uniformly
> > > across the rx virtqueues.
> > >
> > > Please post an outline of how rx packets will be steered up the stack so
> > > we can discuss whether aRFS can bring any benefit.
> > >
> > 1. The aRFS interface for the guest to specify which virtual queue to
> > receive a packet on is fairly straight forward.
> > 2. To hook into RFS, we need to match the virtual queue to the real
> > CPU it will processed on, and then program the RFS table for that flow
> > and CPU.
> > 3. NIC aRFS keys off the RFS tables so it can program the HW with the
> > correct queue for the CPU.
> 
> There are a lot of details that are not yet worked out:
> 
> If you want to implement aRFS down the vhost_net + macvtap path
> (probably easiest?) how will Step 2 work?  Do the necessary kernel
> interfaces exist to take the flow information in vhost_net, give them to
> macvtap, and finally push them down to the physical NIC?
>
> Not sure if aRFS will work down the full stack with vhost_net + tap +
> bridge.  Any ideas?
[...]

Currently ARFS identifies the flow to be steered by passing an skb from
that flow to the driver, not just a hash.  This is important for the sfc
driver because we're using perfect filters for ARFS and we need to pick
out the relevant header fields instead of the RSS hash.

If you try to set an ARFS filter synchronously from the guest, this
would require a different driver operation, and if the guest only
provides a hash then sfc probably would not be able to support it.

An alternative would be that the hash is used to update the
rps_flow_table for the physical RX queue and then ARFS on the host can
insert a filter after the *next* packet.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
