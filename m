From: Amir Vadai <amir@vadai.me>
Subject: Re: [RFC net-next 0/2] net/sched: cls_flower, act_mirred: VXLAN
 redirect using TC
Date: Mon, 15 Aug 2016 12:08:04 +0300
Message-ID: <20160815090804.GB19058@office.localdomain>
References: <20160814140652.15985-1-amir@vadai.me>
 <CAM_iQpXetPgj_nCdYL73r_2hDRmnCpa0-WrxN-UbwBsdFgouiQ@mail.gmail.com>
 <20160815071121.GA2024@nanopsycho>
 <20160815081740.GA19058@office.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Oded Shanoon <odeds@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34521 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752073AbcHOJIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 05:08:07 -0400
Received: by mail-wm0-f66.google.com with SMTP id q128so10034260wma.1
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 02:08:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160815081740.GA19058@office.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 15, 2016 at 11:17:40AM +0300, Amir Vadai wrote:
> On Mon, Aug 15, 2016 at 09:11:22AM +0200, Jiri Pirko wrote:
> > Sun, Aug 14, 2016 at 07:53:30PM CEST, xiyou.wangcong@gmail.com wrote:
> > >On Sun, Aug 14, 2016 at 7:06 AM, Amir Vadai <amir@vadai.me> wrote:
> > >> tc qdisc add dev $ETH ingress
> > >>
> > >> # ENCAP rule for ARP
> > >> tc filter add dev $ETH protocol 0x806 parent ffff: prio 11 \
> > >>                 flower \
> > >>                 action mirred egress redirect dev $VXLAN enc_src_ip 11.11.0.1 enc_dst_ip 11.11.0.2 enc_key_id 11 enc_dst_port 4789
> > >>
> > >> # ENCAP rule for ICMP
> > >> tc filter add dev $ETH protocol ip parent ffff: prio 10 \
> > >>                 flower ip_proto 1 \
> > >>                 action mirred egress redirect dev $VXLAN enc_src_ip 11.11.0.1 enc_dst_ip 11.11.0.2 enc_key_id 11 enc_dst_port 4789
> > >>
> > >
> > >I don't like this. This makes mirred action unnecessarily
> > >complex, it should really just mirror or redirect packets as
> > >it is, why it should be aware of tunnel information?
> > >
> > >I think you probably need to introduce a new tc action
> > >for these tunnel information and pipe it to mirred.
> > 
> > that is the first thing that I thinked of when I saw the patch. I think
> > you can introduce act_vxlan similar to act_vlan.
> 
> introducing a new action was the first thing I thought of, but it felt
> problematic because the actual encap is done by the redirection to the
> vxlan device. This action is only responsible to supply the metadata and
> work tightly with the mirred. It is not exactly like vlan that the
> push/pop actions can live without mirroring/redirecting.
> But still as all of you said, it makes mirred complex with stuff that
> shouldn't be there. And between the two options it is better to
> introduce a new action.
> 
> I will go in this direction.
> 
> Thanks,
> Amir

Any objection to the following?

# ENCAP rule
tc filter add dev $ETH protocol ip parent ffff: prio 10 \
		flower ip_proto 1 \
		action set_tunnel_key src_ip 11.11.0.1 dst_ip 11.11.0.2 key_id 11 dst_port 4789 \
		action mirred egress redirect dev $VXLAN 

# DECAP rule
tc filter add dev $VXLAN protocol ip parent ffff: prio 10 \
		flower \
			enc_src_ip 11.11.0.2 enc_dst_ip 11.11.0.1 enc_key_id 11 \
			ip_proto 1 \
		action mirred egress redirect dev $ETH
