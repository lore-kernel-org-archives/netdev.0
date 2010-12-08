From: Christian Benvenuti <benve@cisco.com>
Subject: [RFC][net-next-2.6 PATCH 0/2] rtnetlink: New IFLA_PORT_PROTO_* attr
Date: Tue, 07 Dec 2010 20:29:48 -0800
Message-ID: <20101208042925.16856.89232.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:57754 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753132Ab0LHE3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 23:29:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series add the new IFLA_PORT_PROTO_* nested
protocol attributes to rtnetlink and it updates the enic
driver to support them.

01/2 - Add new protocol nested IFLA_PORT_PROTO_* attrs
02/2 - Update enic driver to support new IFLA_PORT_PROTO_* attrs


Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>

--------------------------------------------
Here is how the text below is organized:

- 1) INTRO
  Describes what 802.1Qbh change led us to propose
  the Netlink changes discussed here.

- 2) REASON FOR THIS CHANGE
  Describe why we think the changes we propose make sense now.

- 3) OUR PROPOSAL
  Describe the changes to the current IFLA_PORT_* attr scheme.

- 4) IFLA_* versus IFLA_PORT_*
  Describe an alternative approach to the one described in
  the previous section (OUR PROPOSAL).

- 5) DUPLICATE PARAMETERS versus INDEPENDENT PARAMETERS
  Describe one more reason why we think it would be useful
  to have per-proto nested attributes.

- 6) PARSING OF PROTOCOL ATTRIBUTES
  Describe how/when the new sub-attributes of the new protocol
  nested attributes are parsed. 

- 7) PRIORITY ORDER FOR "DOUBLE" PARAMETERS
  Describe how to handle the case where the same attribute
  is present both as a common attribute and as a protocol
  private attribute.

- 8) OPT1: MORE CONFIGURATION FLEXIBILITY
  Describe one optional change which can be used to further
  enhance the config flexibility. This change is independent
  from the one discussed in "OUR PROPOSAL".

- 9) OPT2: MORE CHANGES TO THE NETLINK SCHEME
  Describe how to extend the changes described in "OUR PROPOSAL" to
  include the common attributes.

- 10) BACKWARD COMPATIBILITY
  A couple of notes about how backward compatibility would
  be handled.
  
--------------------------------------------------
1) INTRO
--------------------------------------------------

In the current implementation of the network port profile feature
the parameters used by 802.1Qbg and 802.1Qbh IEEE protocols share
the same Netlink attribute scheme.

Here is the list of the currently defined attributes:

enum {
	IFLA_PORT_UNSPEC,
	IFLA_PORT_VF,			/* __u32 */
	IFLA_PORT_PROFILE,		/* string */
	IFLA_PORT_VSI_TYPE,		/* 802.1Qbg (pre-)standard VDP*/
	IFLA_PORT_INSTANCE_UUID,	/* binary UUID */
	IFLA_PORT_HOST_UUID,		/* binary UUID */
	IFLA_PORT_REQUEST,		/* __u8 */
	IFLA_PORT_RESPONSE,		/* __u16, output only */
	__IFLA_PORT_MAX,
};

It is a flat list of attributes:
- some of them are used by 802.1QBH
- some of them are used by 802.1QBG
and
- some others are shared by the two protocols.

In order to be able to scope a port profile, as part of the 802.1Qbh
implementation we would like to add a new attribute: IFLA_PORT_CLUSTER_UUID.
This parameter (perhaps known under a different name) is already in use
(or going to be added) by most Virtual Machine Managers to define migration
domains. In the case of 802.1Qbh a port profile would most likely be scoped
using the same ID used by VM manager to represent the migration domain.

Adding another attribute (IFLA_PORT_CLUSTER_UUID in this case) to the list of
IFLA_PORT_* attributes is an option.
However, we thought that it would be better to 1st re-arrange the current
Netlink attribute scheme in order to better group the IFLA_PORT_* attributes
(for example by protocol).

Patch_1/2 describes the Netlink scheme change, while Patch_2/2 shows how the
enic driver would change to adapt to the new scheme.

Before to post the (trivial) patch that adds support for the new proposed
IFLA_PORT_CLUSTER_UUID attribute, I would like to see if you seen any value
in the change proposed with this patch.

The rest of the email simply describes into more details the patch and the
various options that we can consider. I included this So that we may be able
to converge faster.

--------------------------------------------------
2) REASON FOR THIS CHANGE
--------------------------------------------------
We would like to add one more attribute (IFLA_PORT_CLUSTER_UUID), and the list 
of IFLA_PORT_* attributes may need to grow again due to the changes that may
be required by the two still evolving standard protocols 802.1Qbh/802.1Qbg.
Because of that, if you see a value in the re-organization of the
IFLA_PORT_* attributes that we are proposing, it would be better to address
such changes sooner than later, in order to reduce the impact of backward
compatibility issues later.

--------------------------------------------------
3) OUR PROPOSAL
--------------------------------------------------
Instead of a flat list of attributes, the new scheme that we propose defines
two groups of attributes (one per protocol):

- 802.1Qbh parameters

- 802.1Qbg parameters

Each one of the above groups would be represented by an attribute of type
NLA_NESTED. If there will ever be another protocol coming into the picture we
can simply add a new NLA_NESTED attribute which would represent its set of
attributes.

In other words, this is the current scheme:

enum {
	IFLA_PORT_UNSPEC,
	IFLA_PORT_VF,
	IFLA_PORT_PROFILE,
	IFLA_PORT_VSI_TYPE,
	IFLA_PORT_INSTANCE_UUID,
	IFLA_PORT_HOST_UUID,
	IFLA_PORT_REQUEST,
	IFLA_PORT_RESPONSE,
	__IFLA_PORT_MAX,
};

and this would be the new one:

enum {
	IFLA_PORT_UNSPEC,
	IFLA_PORT_VF,
	IFLA_PORT_PROFILE,  (*)
	IFLA_PORT_VSI_TYPE, (*)
	IFLA_PORT_INSTANCE_UUID,
	IFLA_PORT_HOST_UUID,
	IFLA_PORT_REQUEST,
	IFLA_PORT_RESPONSE,
	IFLA_PORT_PROTO_8021QBG, <--- NEW nested attr
	IFLA_PORT_PROTO_8021QBH, <--- NEW nested attr
	__IFLA_PORT_MAX,
};

The above attributes marked with (*) are protocol specific (while all the
others are common to the two protocols) and therefore would be deprecated
and replaced with new ones, as shown in the scheme below:

[IFLA_PORT_VF]
[IFLA_PORT_INSTANCE_UUID]
[IFLA_PORT_HOST_UUID]
[IFLA_PORT_REQUEST]
[IFLA_PORT_RESPONSE]
[IFLA_PORT_PROTO_8021QBG]
    [IFLA_PORT_8021QBG_VSI_TYPE]  <-- NEW sub attr
[IFLA_PORT_PROTO_8021QBH]
    [IFLA_PORT_8021QBH_PROFILE]   <-- NEW sub attr

In summary:

/* NEW list of 802.1QBG attributes */
enum {
	IFLA_PORT_PROTO_8021QBG_VSI_TYPE,
	__IFLA_PORT_PROTO_8021QBG_MAX,
};

/* NEW list of 802.1QBH attributes */
enum {
	IFLA_PORT_PROTO_8021QBH_PROFILE,
	__IFLA_PORT_PROTO_8021QBH_MAX,
};

enum {
	IFLA_PORT_UNSPEC,
	IFLA_PORT_VF,
	IFLA_PORT_PROFILE,       <--(BH only / deprecated)
	IFLA_PORT_VSI_TYPE,      <--(BG only / deprecated) 
	IFLA_PORT_INSTANCE_UUID, <----(common)
	IFLA_PORT_HOST_UUID,     <----(common)
	IFLA_PORT_REQUEST,       <----(common)
	IFLA_PORT_RESPONSE,      <----(common)
	IFLA_PORT_PROTO_8021QBH, <------ NEW nested attr
	IFLA_PORT_PROTO_8021QBG, <------ NEW nested attr
	__IFLA_PORT_MAX,
};

--------------------------------------------------
4) IFLA_* versus IFLA_PORT_*
--------------------------------------------------

Here is an alternative way to introduce the new Netlink attribute scheme.
We personally like better the previous scheme, but I'll include this one too
should someone find it interesting.

The idea is that we can apply the changes one level higher into the Netlink
attribute hierarchy:

              IFLA_*             (*1)
             /  ... \
            v        v
     IFLA_PORT_*   ....          (*2)

In other words, the previous scheme adds the new attributes at level (*2) while
this alternative solution would add the new attributes at level (*1)

The current scheme at level (*1) uses these two attributes:

	IFLA_VF_PORT
	IFLA_PORT_SELF

while this new one would use these two new attributes:

	IFLA_GEN_VF_PORT
	IFLA_GEN_PORT_SELF

which translates to this:

enum {
	IFLA_UNSPEC,
	...
	IFLA_VF_PORTS,      <--- OLD / deprecated
	IFLA_PORT_SELF,     <--- OLD / deprecated
	IFLA_GEN_VF_PORTS,  <----NEW 
	IFLA_GEN_PORT_SELF, <----NEW 
	__IFLA_MAX
};

With this alternative scheme we would be able to define a new list of
attributes IFLA_PORT_GEN_* which would not include any deprecated attr:

enum {
	IFLA_PORT_GEN_UNSPEC,

      ... common attr here ...

	IFLA_PORT_GEN_PROTO_8021QBH,
	IFLA_PORT_GEN_PROTO_8021QBG,
	__IFLA_PORT_MAX,
};

NOTE: I am not suggesting the use of "_GEN". I used that keyword
      just for the example.

The consumer of the Netling messages can easily distinguish between legacy
attributes (ie, IFLA_VF_PORTS/IFLA_PORT_SELF attributes) and new ones
(ie, IFLA_GEN_VF_PORTS/IFLA_GEN_PORT_SELF attributes)

--------------------------------------------------
5) DUPLICATE PARAMETERS versus INDEPENDENT PARAMETERS
--------------------------------------------------

One more note about the semantic of this new attribute scheme (which
applies to both proposals above).
There may be cases where a group of protocols (ie, 802.1Qbh and 802.1Qbg
as of today) has similar parameters but the latter do not share the same
exact meaning/syntax.

This situation would not be an issue because each protocol would interpret
those parameters independently accordingly to its semantic.

However, what could represent a limitation/issue is that those protocols
may have different data size/type requirements for the same parameter.
For example 802.1Qbg uses ifla_port_vsi.mgr_id to represent something
very similar to the IFLA_PORT_CLUSTER_UUID attribute that we would like
to add for 802.1Qbh. However:

- 802.1Qbg/ifla_port_vsi.mgr_id (which is already in the kernel)
  is a 8-bit field

- 802.1Qbh/CLUSTER_UUID (which we would like to add) requires
  more than 8 bits and could be a string

Here are a couple of options to handle this mismatch in the data type/size
requirements:

OPTION_1: we try to find a compromise and share the same data size/type.
          In the above example, this may require a change in the
          ifla_port_vsi data structure definition (to increase for
          example the size of mgr_id) or, if we leave it the way it is
          defined right now, the new 802.1Qbh cluster UUID would have to
          live with the current 8-bit limitation imposed by
          ifla_port_vsi.mgr_id.

OPTION_2: I'll mention this option for the sake of completeness, but I am
	  not suggesting it.
	  We could remove the mgr_id field from the ifla_port_vsi structure
          and introduce a new shared attribute (ie IFLA_PORT_PROTO_GRP in the
	  example below). This attribute would then use a union to
	  provide different data sizes for the same config parameter, so
	  that we could for example use it to introduce the CLUSTER_UUID
	  needed for 802.1Qbh:

	[IFLA_PORT_PROTO_ALL]
	    [IFLA_PORT_PROTO_ALL_GRP] = { .type = NLA_BINARY,
	                                  .len = sizeof(struct ifla_port_grp)};

	struct ifla_port_grp {
		union {
			struct {
				uint8_t managerID;
			} 8021qbg;
			struct {
				uint8_t cluster_uuid[<size_of_cluster_id_here>];
			} 8021qbh;		
		}	
	};

	The keywords "group"/"cluster"/"domain" are pretty overloaded nowadays.
	In the example above I used "_grp" just for lack of inspiration.
      

OPTION_3: According to the new Netlink attribute scheme that we are
          proposing, each protocol has its own set of attributes and
          therefore it would not be considered superfluous to have the
          same (or a similar) attribute defined for both protocols.
          (in this case it would be manager_ID for 802.1qbg and
          cluster_uuid for 802.1qbh).

To us OPTION_3 looks like the option that offers most flexibility.

This case above (mgr_id versus Cluster UUID) is just an example, however the
possibility of having the two parameters being independent allows for an easier
extendibility/adaptation of the two (still evolving) protocol implementations.

--------------------------------------------------
6) PARSING OF PROTOCOL ATTRIBUTES
--------------------------------------------------

When a device driver (or a generic consumer in kernel space) Receives a netlink
message that carries one of the new IFLA_PORT_PROTO_* attributes, it can use
the _new_ rtnetlink API rtnl_link_parse_port_proto:

rtnetlink::do_setlink
           |
           +--> driver::ndo_set_vf_port
                        |
                        +--> rtnetlink::rtnl_link_parse_port_proto

--------------------------------------------------
7) PRIORITY ORDER FOR "DOUBLE" PARAMETERS
--------------------------------------------------

As part of the semantic of this new Netlink attribute scheme, we would
recommend this additional rule:

   if one parameter is present twice in a Netlink message, that
   is to say it is present both as a shared parameter (ie, in the
   IFLA_PORT_* list of attributes) and as a protocol private parameter
   (ie, in one of the IFLA_PORT_PROTO_* nested attributes), the
   most specific one would win (ie IFLA_PORT_PROTO_* in this case).

This would allow the new scheme to adapt to changes into the scope (and data
type/size) of the parameters without any change to the core code. For example:

Example_1 (shared attr -> private attr):

  Today we have 802.1Qbh and 802.1Qbg in the picture. If tomorrow we add
  a new IFLA_PORT_PROTO_XYZ protocol, the latter may have different
  requirements (with regards to data size and type) for a given parameter,
  and may therefore prefer to add its own (private) version of that
  parameter inside its IFLA_PORT_PROTO_XYZ nested attribute.

Example_2 (private attr -> shared attr):

  This is the reverse case of the previous example. Since the two
  protocols are still evolving, new use case scenarios may drive
  changes to the current data type/size requirements of the parameters.
  Because of this, what is now a protocol private attribute may tomorrow
  be eligible for changing to a shared attribute.
  In such a case, the protocol would simply stop using its private
  attribute (inside IFLA_PORT_PROTO_*) and start using the shared
  one (ie IFLA_PORT_*).

--------------------------------------------------
8) OPT1: MORE CONFIGURATION FLEXIBILITY
--------------------------------------------------
The change described in this section is orthogonal to the ones Discussed above.
We believe it would add value to the new scheme.
We would like to include it as part of the new Netlink scheme (but the current
patch does not include it).

In order to allow device drivers (or a generic consumer of the Netlink messages)
to provide extra features or simple optimizations I would suggest the
introduction of a new nested attribute that I will call IFLA_PORT_DATA for now.

This attribute would allow the use of extra attributes that are not part of
the official protocol specs (802.1Qbg/bh for now) or simply allow device
drivers to start supporting pre-standard parameters that would not be included
in the Netlink scheme before they reach some stability.

In order to keep the implementation as simple as possible and to allow the
different drivers to change/update/version their private attributes without
having to change each time the IFLA_PORT_* list of attributes, I would propose
to define IFLA_PORT_DATA of type NLA_UNSPEC: it is up to the consumer to
interpret/parse it.

Of course, the hypothesis here is that the sender knows who the receiver (ie,
most likely the driver) is, and viceversa (otherwise they would not be able to
agree on a data structure type).
Here is how the previously described scheme would change with the addition of
this new attribute:

enum {
	IFLA_PORT_UNSPEC,
	IFLA_PORT_VF,
	IFLA_PORT_PROFILE,
	IFLA_PORT_VSI_TYPE,
	IFLA_PORT_INSTANCE_UUID,
	IFLA_PORT_HOST_UUID,
	IFLA_PORT_REQUEST,
	IFLA_PORT_RESPONSE,
	IFLA_PORT_DATA, <========== NEW
	IFLA_PORT_PROTO_8021QBH,
	IFLA_PORT_PROTO_8021QBG,
	__IFLA_PORT_MAX,
};

Here are a couple of examples of use.
Let's suppose that driver ABC needed to receive a couple of parameters
more (that are not part of the official 802.1Qbh/bg protocols).
In this case driver ABC can use the new attribute IFLA_PORT_DATA to
receive its two additional parameters without any need to touch/modify
the IFLA_PORT_* list of attributes.

If in the future driver ABC needed to change any of its private
parameters (those it receives through the IFLA_PORT_DATA attribute), it
can do it by updating its parsing routine (of course it would need
to implement a basic versioning scheme for its private attributes), but
no change would be required in the core Netlink code.

I can see one more advantage. If that hypothetical extra feature
provided by driver ABC (which requires the use of IFLA_PORT_ DATA) will
one day become a sort of generic feature that it makes sense to
implement for all drivers (or for a number of them), those attributes
that used to be embedded into the IFLA_PORT_DATA attribute can now be
made visible to the upper (Netlink) layer and be therefore added to
the IFLA_PORT_* list.
This could be the case of a pre-standard config parameter that gets
confirmed and becomes stable.

Of course, the idea is not that of abusing IFLA_PORT_DATA, but rather
that of allowing comsumers (ie, device drivers or user space apps)
to receive extra parameters needed to implement/provide optimizations.

If we do not want to add IFLA_PORT_DATA, an alternative solution would
be that of using a separate control channel to provide that extra
info, for example based on something like the NETLINK_GENERIC Netlink
protocol.
This alternative approach would offer the same flexibility, but I
can see One drawback: this solution would require some extra code
to synchronize the two control channels
(generic NETLINK_ROUTE/IFLA_PORT_XXX and NETLINK_GENERIC/Driver).

--------------------------------------------------
9) OPT2: MORE CHANGES TO THE NETLINK SCHEME
--------------------------------------------------

On top of the new nested protocol attributes discussed already, we
could define an additional one where we can put all common parameters.

>From a logical perspective it would be something like this:

enum {
	IFLA_PORT_UNSPEC,
	IFLA_PORT_VF,
	IFLA_PORT_PROTO_ALL,     <--- NEW nested attr
	IFLA_PORT_PROTO_8021QBG, <--- NEW nested attr
	IFLA_PORT_PROTO_8021QBH, <--- NEW nested attr
	__IFLA_PORT_MAX,
};

But since we cannot remove the obsolete attributes, the real
scheme would be this:

enum {
	IFLA_PORT_UNSPEC,
	IFLA_PORT_VF,
	IFLA_PORT_PROFILE,       <-------(BH only) / deprecated 
	IFLA_PORT_VSI_TYPE,      <-------(BG only) / deprecated 
	IFLA_PORT_INSTANCE_UUID, <-------(common)  / deprecated (*)
	IFLA_PORT_HOST_UUID,     <-------(common)  / deprecated (*)
	IFLA_PORT_REQUEST,       <-------(common)  / deprecated (*)
	IFLA_PORT_RESPONSE,      <-------(common)  / deprecated (*)
	IFLA_PORT_PROTO_ALL,     <-- NEW nested attr
	IFLA_PORT_PROTO_8021QBH, <-- NEW nested attr
	IFLA_PORT_PROTO_8021QBG, <-- NEW nested attr
	__IFLA_PORT_MAX,
};

(*) common parameters that would move inside IFLA_PORT_PROTO_ALL.

This approach would allow us to keep adding shared params
and nested proto attributes without mixing them.
In other words this would NOT be possible:

enum {
	IFLA_PORT_UNSPEC,
	IFLA_PORT_VF,
	IFLA_PORT_PROFILE,
	IFLA_PORT_VSI_TYPE,
	IFLA_PORT_INSTANCE_UUID,
	IFLA_PORT_HOST_UUID,
	IFLA_PORT_REQUEST,
	IFLA_PORT_RESPONSE,
	IFLA_PORT_PROTO_8021QBH,
	IFLA_PORT_PROTO_8021QBG,
	IFLA_PORT_ABCD1,     <---New protos and
	IFLA_PORT_PROTO_XYZ, <---new common parameters
	IFLA_PORT_ABCD2      <---get mixed
	__IFLA_PORT_MAX,
};

I know, it's just a cosmetic detail, but I wanted to mention it
for the sake of completeness.

--------------------------------------------------
10) BACKWARD COMPATIBILITY
--------------------------------------------------
Let me split the comments into two parts: GET vs SET.

a) RTM_SETLINK

   The recipient of the message, for example the enic driver, should
   1st look for the new protocol attributes IFLA_PORT_PROTO_*.
   Only when the latter is not present it should check for the
   deprecated attributes.

   I would suggest making it ILLEGAL to mix new and deprecated
   attributes.

b) RTM_GETLINK

   The recipient of the message, for example the enic driver, should
   return both the deprecated and the new attributes. This would not
   involve much overhead as the number of deprecated attributes is small.
   
When the protocol nested attributes IFLA_PORT_PROTO_* will be
populated with new sub-attributes (like the CLUSTER_UUID we would like
to add), the user space clients will have to adapt to the new
attribute scheme if they want to be able to see/receive the new
attributes (like CLUSTER_UUID).

Thanks
/Christian

