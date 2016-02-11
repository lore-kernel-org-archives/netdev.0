From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next] lwt: fix rx checksum setting for lwt devices
 tunneling over ipv6
Date: Thu, 11 Feb 2016 12:38:51 +0100
Message-ID: <1455190731.4855.50.camel@redhat.com>
References: <8d2a6ece65b17ae61343dce27f3709d3cd249832.1455118911.git.pabeni@redhat.com>
	 <20160211114124.17ae429a@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Pravin Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>, Jesse Gross <jesse@kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47273 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751140AbcBKLi4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2016 06:38:56 -0500
In-Reply-To: <20160211114124.17ae429a@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-02-11 at 11:41 +0100, Jiri Benc wrote:
> On Wed, 10 Feb 2016 16:47:21 +0100, Paolo Abeni wrote:
> > --- a/drivers/net/geneve.c
> > +++ b/drivers/net/geneve.c
> > @@ -1441,7 +1441,8 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
> >  		return dev;
> >  
> >  	err = geneve_configure(net, dev, &geneve_remote_unspec,
> > -			       0, 0, 0, htons(dst_port), true, 0);
> > +			       0, 0, 0, htons(dst_port), true,
> > +			       GENEVE_F_UDP_ZERO_CSUM6_RX);
> >  	if (err) {
> >  		free_netdev(dev);
> >  		return ERR_PTR(err);
> > diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
> > index 1605691..d933cb8 100644
> > --- a/net/openvswitch/vport-vxlan.c
> > +++ b/net/openvswitch/vport-vxlan.c
> > @@ -90,7 +90,7 @@ static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
> >  	int err;
> >  	struct vxlan_config conf = {
> >  		.no_share = true,
> > -		.flags = VXLAN_F_COLLECT_METADATA,
> > +		.flags = VXLAN_F_COLLECT_METADATA | VXLAN_F_UDP_ZERO_CSUM6_RX,
> 
> I'm afraid this looks wrong, we should not default to zero UDP checksum
> over IPv6. See RFC 2460, section 8.1:
> 
>       o  Unlike IPv4, when UDP packets are originated by an IPv6 node,
>          the UDP checksum is not optional.  That is, whenever
>          originating a UDP packet, an IPv6 node must compute a UDP
>          checksum over the packet and the pseudo-header, and, if that
>          computation yields a result of zero, it must be changed to hex
>          FFFF for placement in the UDP header.  IPv6 receivers must
>          discard UDP packets containing a zero checksum, and should log
>          the error.
> 
> One may argue that with tunneling, the situation is different but
> that's the reason why we have the IPv6 checksum flag and why it has
> opposite meaning to the IPv4 one. We shouldn't default to non-RFC
> behavior by default.

Agreed. As far as I can understand RFC 6936, Section 5 do allows
specific tunneling protocol to accept zero UDP checksum on specific
ports.

We are already sending by default zero UDP checksum when tunneling over
vxlan/geneve light weight tunnel since the commit 35e2d1152b22
("tunnels: Allow IPv6 UDP checksums to be correctly controlled.").

Currently, geneve/vxlan lwt pairs tunneling over ipv6 are not able to
talk each-other with default setting since the sender will set zero UDP
checksum in the external header and the receiver will discard such
packets.

This commit is intended to address the above issue.

Such issue could be addressed also by defaulting all lwt geneve/vxlan
flows (comprising those tunneling over ipv4) to set the external UDP
checksum, but a single lwt tunnel device can be used to terminate flows
with different checksum settings.

Paolo
