From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] vxlan: force user to set port value
Date: Wed, 15 May 2013 15:01:33 -0700
Message-ID: <20130515150133.1066e1a5@nehalam.linuxnetplumber.net>
References: <1368616270-5775-1-git-send-email-amwang@redhat.com>
	<OFA8084FAB.8443890D-ON85257B6C.003F1FAB-85257B6C.003F65F2@us.ibm.com>
	<20130515095322.275c9b2f@nehalam.linuxnetplumber.net>
	<20130515.132213.120685330795916926.davem@davemloft.net>
	<20130515134818.18b2c710@nehalam.linuxnetplumber.net>
	<519404E2.5000300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dlstevens@us.ibm.com,
	amwang@redhat.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Sridhar Samudrala <samudrala.sridhar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f52.google.com ([209.85.210.52]:48011 "EHLO
	mail-da0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751991Ab3EOWBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 18:01:37 -0400
Received: by mail-da0-f52.google.com with SMTP id o9so1236242dan.11
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 15:01:36 -0700 (PDT)
In-Reply-To: <519404E2.5000300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 May 2013 14:57:54 -0700
Sridhar Samudrala <samudrala.sridhar@gmail.com> wrote:

> On 5/15/2013 1:48 PM, Stephen Hemminger wrote:
> > This change shifts burden onto the users to choose the UDP port value.
> > There is no default value, the destination port must be specified.
> >
> > This is a migration compromise. The initial development of VXLAN
> > used UDP port 5287 but now there is an official assigned port for
> The original and current kernel default is 8472.
> > VXLAN.  The kernel can't change because of legacy compatibility
> > but new deployments should not use the legacy port value.
> >
> > ---
> >   ip/iplink_vxlan.c |   13 ++++++++++++-
> >   1 file changed, 12 insertions(+), 1 deletion(-)
> >
> > diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
> > index 2d93ee2..263feca 100644
> > --- a/ip/iplink_vxlan.c
> > +++ b/ip/iplink_vxlan.c
> > @@ -53,7 +53,8 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
> >   	__u8 noage = 0;
> >   	__u32 age = 0;
> >   	__u32 maxaddr = 0;
> > -	__u16 dstport = 4789;
> > +	__u16 dstport = 0;
> > +	int dst_port_set = 0;
> >   	struct ifla_vxlan_port_range range = { 0, 0 };
> >   
> >   	while (argc > 0) {
> > @@ -131,6 +132,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
> >   			NEXT_ARG();
> >   			if (get_u16(&dstport, *argv, 0))
> >   				invarg("dst port", *argv);
> > +			dst_port_set = 1;
> >   		} else if (!matches(*argv, "nolearning")) {
> >   			learning = 0;
> >   		} else if (!matches(*argv, "learning")) {
> > @@ -161,10 +163,18 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
> >   		}
> >   		argc--, argv++;
> >   	}
> > +
> >   	if (!vni_set) {
> >   		fprintf(stderr, "vxlan: missing virtual network identifier\n");
> >   		return -1;
> >   	}
> > +
> > +	if (!dst_port_set) {
> > +		fprintf(stderr, "vxlan: destination port not specified\n"
> > +			"Use 'dstport 4789' to get the IANA assigned value\n");
> > +		return -1;
> > +	}
> Just setting the dstport 4789 is not enough. The user has to make sure 
> that the
> vxlan module is loaded with a module  parameter 'udp_port' set to 4789.

With this (and other fix) the kernel parameter is irrelevant.
