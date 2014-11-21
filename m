From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [patch net-next v2 00/10] introduce rocker switch driver with
 hardware accelerated datapath api - phase 1: bridge fdb offload
Date: Fri, 21 Nov 2014 11:01:11 +0900
Message-ID: <20141121020108.GA1457@vergenet.net>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
 <5460319B.2010605@mojatatu.com>
 <20141110034612.GB17246@vergenet.net>
 <5460391C.3010107@mojatatu.com>
 <20141110045830.GC17246@vergenet.net>
 <54613AD3.7030600@gmail.com>
 <20141113054412.GA31283@vergenet.net>
 <5464502A.20103@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.fastabend@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, edumazet@google.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, alexander.h.duyck@redhat.com,
	john.ronciak@intel.com, mleitner@redhat.com, shrijeet@gmail.com,
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:53055 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756700AbaKUCBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 21:01:37 -0500
Received: by mail-pa0-f45.google.com with SMTP id lj1so3787851pab.4
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 18:01:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <5464502A.20103@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

On Wed, Nov 12, 2014 at 10:31:06PM -0800, John Fastabend wrote:
> On 11/12/2014 09:44 PM, Simon Horman wrote:
> > [snip]
> >=20
> >> Simon, if your feeling adventurous any feedback on the repo link
> >> would be great. I still need to smash the commit log into somethin=
g
> >> coherent though at the moment you can see all the errors and rewri=
tes,
> >> etc as I made them.
> >=20
> > Hi John,
> >=20
> > here is some preliminary feedback:
> >=20
> > * I notice that the parse graph code isn't present yet.
> >   I suppose this is a difficult piece that naturally follows many
> >   other piece. None the less it is possibly the piece of most
> >   interest to me :-)
>=20
> I can add this over the next few days. Also I wanted to publish some
> more complex examples on top of rocker switch. The nic drivers are
> interesting but not as complex as some of the switch devices.

I see that you have added the header graph, which seems pretty nice
from my reading so far.

It seems to allow for arbitrary connections between instances
of net_flow_header_node, including I loops I suppose. This seems
nice and flexible to me.

I have a very minor update to contribute which helped me to
read the code. Please feel free to squash/ignore/...

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_pipeline.h b/driver=
s/net/ethernet/intel/ixgbe/ixgbe_pipeline.h
index a4818ab..4025a61 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_pipeline.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_pipeline.h
@@ -412,7 +412,7 @@ struct net_flow_jump_table ixgbe_vlan_inner_jump[2]=
 =3D {
 		   .type =3D NET_FLOW_FIELD_REF_ATTR_TYPE_U16,
 		   .value_u16 =3D 0x0800,
 		},
-		.node =3D 4,
+		.node =3D HEADER_INSTANCE_IP,
 	},
 	{
 		.field =3D {0},
@@ -443,7 +443,7 @@ struct net_flow_jump_table ixgbe_ip_jump[2] =3D {
 		   .type =3D NET_FLOW_FIELD_REF_ATTR_TYPE_U8,
 		   .value_u8 =3D 0x06,
 		},
-		.node =3D 5,
+		.node =3D HEADER_INSTANCE_TCP,
 	},
 	{
 		.field =3D {0},

> There is also the table graph layout which I wanted tweak a bit. At
> the moment I have hardware that can run tables in parallel and some
> that executes tables in sequence. It might not be clear from the code
> (why I need the cleanup) but the source id is being used to indicate
> if the tables are executed in parallel or not.

Thanks, that was not clear to me.

> > * Will del and update flows require flows to already exist?
> >   And similarly, will add flow require flows with the same match to=
 not
> >   already exist?  If so, the error handling seems tricky of more th=
an one
> >   flow is to be deleted/updated. IIRC there was some discussion of =
that
> >   kind of issue at the (double) round table discussion on the last =
day of
> >   LPC14 in D=C3=BCsseldorf.
>=20
> I would expect del/updates for flows that don't exist should fail.

Am I right in thinking that del and update flow NDOs may take
a list of flows? If so I think some consideration needs
to be made for handling failure of e.g. the last element of
the list when the previous elements succeeded.

I suppose that user-space could dump the flow table if an error and
adjust its state accordingly. But that seems somewhat onerous.

> I didn't intend to add any checks in the kernel to verify the matches
> are unique. My opinion on this is that user space shouldn't add new
> duplicate flows. And if it does hardware resources will be wasted.

I don't have any strong opinions on that at this time.
But it does seem reasonable so long as its clear that is the case.

> > * Should the .node_count value of ixgbe_table_node_l2 be 3?
> >   ixgbe_table_graph_nodes has three elements but perhaps you
> >   are intentionally excluding the last element ixgbe_table_node_nil=
?
> >=20
>=20
> Actually I could just drop the node_count at the moment because I've
> been null terminating the arrays with null items.
>=20
> I should either add a count field to all the structures or null termi=
nate
> the arrays. For now I mostly null terminate the arrays when I use
> them. For example matches is null terminates same for actions.

It looks like you have move towards the null termination option.
No objections here.
