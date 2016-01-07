From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [ovs-dev] [PATCH net 0/2] vxlan: Set a large MTU on ovs-created
 vxlan devices
Date: Thu, 7 Jan 2016 12:49:35 +0100
Message-ID: <20160107114935.GJ32456@pox.localdomain>
References: <1452087186-12926-1-git-send-email-david@weave.works>
 <20160106.155950.1007160228570301281.davem@davemloft.net>
 <8660z6qohn.fsf@weave.works>
 <CAEh+42iWSZOyikNydU2Bs8meqYfrKfUJLDGFJ8HzQ06k64LP0g@mail.gmail.com>
 <568DADEE.1050206@stressinduktion.org>
 <CAEh+42h_dH5-AYBN+L=+LMfNLXhSfs-AwWh_aZ_oLfZ1NV48Zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Wragg <david@weave.works>,
	David Miller <davem@davemloft.net>, dev@openvswitch.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37174 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbcAGLti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 06:49:38 -0500
Received: by mail-wm0-f43.google.com with SMTP id f206so119233968wmf.0
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 03:49:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAEh+42h_dH5-AYBN+L=+LMfNLXhSfs-AwWh_aZ_oLfZ1NV48Zg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/16 at 04:46pm, Jesse Gross wrote:
> On Wed, Jan 6, 2016 at 4:14 PM, Hannes Frederic Sowa
> > I don't see any other way as to make MTUs part of the flow if we want to
> > have correct ip_local_error notifications. And those must also work across
> > VMs, so openvswitch in quasi brouting mode would need to emit ICMP PtBs
> > (hopefully with a correct source address, otherwise uRPF kills them before
> > reaching the applications) or do error signaling via virtio_net.
> 
> I actually implemented this a long time ago and then there was some
> additional discussion on this about a year ago. I agree it's the right
> solution overall but it's not entirely clearly to me how to get the
> details correct.

When I looked into this last, the wildcard flow model of OVS  made this
difficult to get 100% right. That said, I don't think we have to do
the actual dropping in OVS itself but the signaling has to back to OVS
and ultimately the source. We don't want to replicate the entire flow
cache model in OVS.

A simple start could be to add a new return code for > MTU drops in
the dev_queue_xmit() path and check for NET_XMIT_DROP_MTU in
ovs_vport_send() and emit proper ICMPs.
