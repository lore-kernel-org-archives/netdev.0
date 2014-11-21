From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [patch net-next v2 00/10] introduce rocker switch driver with
 hardware accelerated datapath api - phase 1: bridge fdb offload
Date: Thu, 20 Nov 2014 23:20:13 -0800
Message-ID: <546EE7AD.90503@intel.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <5460319B.2010605@mojatatu.com> <20141110034612.GB17246@vergenet.net> <5460391C.3010107@mojatatu.com> <20141110045830.GC17246@vergenet.net> <54613AD3.7030600@gmail.com> <20141113054412.GA31283@vergenet.net> <5464502A.20103@intel.com> <20141121020108.GA1457@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:61421 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751032AbaKUHUa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2014 02:20:30 -0500
In-Reply-To: <20141121020108.GA1457@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/20/2014 06:01 PM, Simon Horman wrote:
> Hi John,
>=20
> On Wed, Nov 12, 2014 at 10:31:06PM -0800, John Fastabend wrote:
>> On 11/12/2014 09:44 PM, Simon Horman wrote:
>>> [snip]
>>>
>>>> Simon, if your feeling adventurous any feedback on the repo link
>>>> would be great. I still need to smash the commit log into somethin=
g
>>>> coherent though at the moment you can see all the errors and rewri=
tes,
>>>> etc as I made them.
>>>
>>> Hi John,
>>>
>>> here is some preliminary feedback:
>>>
>>> * I notice that the parse graph code isn't present yet.
>>>   I suppose this is a difficult piece that naturally follows many
>>>   other piece. None the less it is possibly the piece of most
>>>   interest to me :-)
>>
>> I can add this over the next few days. Also I wanted to publish some
>> more complex examples on top of rocker switch. The nic drivers are
>> interesting but not as complex as some of the switch devices.
>=20
> I see that you have added the header graph, which seems pretty nice
> from my reading so far.

Great. I'm iterating over some other hardware now to be sure it will
work on some more complex configurations. And about ready to start
the rocker implementation.

>=20
> It seems to allow for arbitrary connections between instances
> of net_flow_header_node, including I loops I suppose. This seems
> nice and flexible to me.

Right loops could be supported.


>=20
> I have a very minor update to contribute which helped me to
> read the code. Please feel free to squash/ignore/...
>=20

I like the patch. This sort of cleanup is needed.

> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_pipeline.h b/driv=
ers/net/ethernet/intel/ixgbe/ixgbe_pipeline.h
> index a4818ab..4025a61 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_pipeline.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_pipeline.h
> @@ -412,7 +412,7 @@ struct net_flow_jump_table ixgbe_vlan_inner_jump[=
2] =3D {
>  		   .type =3D NET_FLOW_FIELD_REF_ATTR_TYPE_U16,
>  		   .value_u16 =3D 0x0800,
>  		},
> -		.node =3D 4,
> +		.node =3D HEADER_INSTANCE_IP,
>  	},
>  	{
>  		.field =3D {0},
> @@ -443,7 +443,7 @@ struct net_flow_jump_table ixgbe_ip_jump[2] =3D {
>  		   .type =3D NET_FLOW_FIELD_REF_ATTR_TYPE_U8,
>  		   .value_u8 =3D 0x06,
>  		},
> -		.node =3D 5,
> +		.node =3D HEADER_INSTANCE_TCP,
>  	},
>  	{
>  		.field =3D {0},
>=20
>> There is also the table graph layout which I wanted tweak a bit. At
>> the moment I have hardware that can run tables in parallel and some
>> that executes tables in sequence. It might not be clear from the cod=
e
>> (why I need the cleanup) but the source id is being used to indicate
>> if the tables are executed in parallel or not.
>=20
> Thanks, that was not clear to me.
>=20
>>> * Will del and update flows require flows to already exist?
>>>   And similarly, will add flow require flows with the same match to=
 not
>>>   already exist?  If so, the error handling seems tricky of more th=
an one
>>>   flow is to be deleted/updated. IIRC there was some discussion of =
that
>>>   kind of issue at the (double) round table discussion on the last =
day of
>>>   LPC14 in D=C3=BCsseldorf.
>>
>> I would expect del/updates for flows that don't exist should fail.
>=20
> Am I right in thinking that del and update flow NDOs may take
> a list of flows? If so I think some consideration needs
> to be made for handling failure of e.g. the last element of
> the list when the previous elements succeeded.

Yes the list of add/deletes are needed for user space to push down
bulk commands. At init time or when management software resets or
likely other cases we get large sets of rules being pushed
down doing this in bulk is much better then one-offing the flow command=
s.

>=20
> I suppose that user-space could dump the flow table if an error and
> adjust its state accordingly. But that seems somewhat onerous.

Right we talked about this briefly @ LPC if I recall correctly. I see
a couple ways to do this. Either we do a best effort and return the
first flow to have an error so userspace can learn where the failure
occurred. Another option is to have the driver roll-back and remove any
flows that were added leaving the driver in the same state it was befor=
e
the add flow command started. Or we could support both and let user spa=
ce
tell us if we should use best effort or required modes.

Any thoughts?

>=20
>> I didn't intend to add any checks in the kernel to verify the matche=
s
>> are unique. My opinion on this is that user space shouldn't add new
>> duplicate flows. And if it does hardware resources will be wasted.
>=20
> I don't have any strong opinions on that at this time.
> But it does seem reasonable so long as its clear that is the case.

When I get to document this I'll call it out explicitly. I think we
should have something in ./Documentation/networkin/ for this API.

>=20
>>> * Should the .node_count value of ixgbe_table_node_l2 be 3?
>>>   ixgbe_table_graph_nodes has three elements but perhaps you
>>>   are intentionally excluding the last element ixgbe_table_node_nil=
?
>>>
>>
>> Actually I could just drop the node_count at the moment because I've
>> been null terminating the arrays with null items.
>>
>> I should either add a count field to all the structures or null term=
inate
>> the arrays. For now I mostly null terminate the arrays when I use
>> them. For example matches is null terminates same for actions.
>=20
> It looks like you have move towards the null termination option.
> No objections here.
>=20

yep, the code looked nicer to me at least with this approach.

Thanks for looking it over,
John
