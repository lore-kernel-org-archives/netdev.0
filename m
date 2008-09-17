From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/3] enic: add main netdev file with
	moduleinfrastructure
Date: Wed, 17 Sep 2008 12:47:38 +0100
Message-ID: <1221652058.3244.84.camel@achroite>
References: <1221248871.3244.69.camel@achroite>
	 <Pine.LNX.4.64.0809161821580.31710@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:48286 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752254AbYIQLrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2008 07:47:42 -0400
In-Reply-To: <Pine.LNX.4.64.0809161821580.31710@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-09-16 at 18:49 -0700, Scott Feldman wrote:
[...]
> >> +static int enic_get_skb_header(struct sk_buff *skb, void **iphdr,
> >> +	void **tcph, u64 *hdr_flags, void *priv)
> >> +{
> >> +	struct cq_enet_rq_desc *cq_desc = priv;
> >> +	unsigned int ip_len;
> >> +	struct iphdr *iph;
> >> +
> >> +	u8 type, color, eop, sop, ingress_port, vlan_stripped;
> >> +	u8 fcoe, fcoe_sof, fcoe_fc_crc_ok, fcoe_enc_error, fcoe_eof;
> >> +	u8 tcp_udp_csum_ok, udp, tcp, ipv4_csum_ok;
> >> +	u8 ipv6, ipv4, ipv4_fragment, fcs_ok, rss_type, csum_not_calc;
> >> +	u8 packet_error;
> >> +	u16 q_number, completed_index, bytes_written, vlan, checksum;
> >> +	u32 rss_hash;
> >> +
> >> +	cq_enet_rq_desc_dec(cq_desc,
> >> +		&type, &color, &q_number, &completed_index,
> >> +		&ingress_port, &fcoe, &eop, &sop, &rss_type,
> >> +		&csum_not_calc, &rss_hash, &bytes_written,
> >> +		&packet_error, &vlan_stripped, &vlan, &checksum,
> >> +		&fcoe_sof, &fcoe_fc_crc_ok, &fcoe_enc_error,
> >> +		&fcoe_eof, &tcp_udp_csum_ok, &udp, &tcp,
> >> +		&ipv4_csum_ok, &ipv6, &ipv4, &ipv4_fragment,
> >> +		&fcs_ok);
> >
> > I don't know where that function is defined, but it's badly designed.
> > It will be easy to get the order of arguments wrong and the compiler
> > will probably not help because most of them have the same type.  It is
> > probably better to define a structure to hold all these attributes.
> 
> I know it's not ideal as-is but a structure overlay on the descriptor 
> doesn't work either because some of the fields are bit-fields and a 
> structure with bit-fields isn't that portable.

I wasn't suggesting a structure overlay as I'm aware that's a recipe for
portability problems, but something like:

struct cq_enet_rq_desc {
	u8 type, color, eop, sop, ...;
	u16 q_number, completed_index, ...;
	u32 rss_hash;
};

struct cq_enet_rq_desc desc_fields;
cq_enet_rq_desc_dec(cq_desc, &desc_fields);

> > [...]
> >> +static void enic_notify_timer(unsigned long data)
> >> +{
> >> +	struct enic *enic = (struct enic *)data;
> >> +
> >> +	enic_notify_check(enic);
> >> +
> >> +	mod_timer(&enic->notify_timer, round_jiffies(ENIC_NOTIFY_TIMER_PERIOD));
> >
> > You want round_jiffies_relative() not round_jiffies().
> 
> No, I want round_jiffies().
[...]

The kernel-doc says:
"round_jiffies() rounds an absolute time in the future (in jiffies)
up or down to (approximately) full seconds. This is useful for timers
for which the exact time they fire does not matter too much, as long as
they fire approximately every X seconds."

You're passing in ENIC_NOTIFY_TIMER_PERIOD which is a relative time.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

