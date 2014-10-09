From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [ovs-dev] [PATCH/RFC repost 7/8] ofproto: translate datapath
 select group action
Date: Thu, 9 Oct 2014 10:14:36 +0900
Message-ID: <20141009011434.GE9339@vergenet.net>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
 <1411005311-11752-8-git-send-email-simon.horman@netronome.com>
 <20140926235725.GB20493@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dev@openvswitch.org, netdev@vger.kernel.org
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:58145 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbaJIBOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 21:14:46 -0400
Received: by mail-ig0-f180.google.com with SMTP id uq10so1203565igb.13
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2014 18:14:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140926235725.GB20493@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 26, 2014 at 04:57:25PM -0700, Ben Pfaff wrote:
> On Thu, Sep 18, 2014 at 10:55:10AM +0900, Simon Horman wrote:
> > This patch is a prototype and has several limitations:
> >=20
> > * It assumes that no actions follow a select group action
> >   because the resulting packet after a select group action may
> >   differ depending on the bucket used. It may be possible
> >   to address this problem using recirculation. Or to not use
> >   the datapath select group in such situations. In any case
> >   this patch does not solve this problem or even prevent it
> >   from occurring.
>=20
> It seems like this limitation in particular is a pretty big one.  Do
> you have a good plan in mind for how to resolve it?

Hi Ben,

it seems to me that this would be somewhat difficult to resolve in the
datapath so I propose not doing so. And I have two ideas on how to
resolve this problem outside of the datapath.

1. Recirculation

   It seems to me that it ought to be possible to handle this by
   recirculating if actions occur after an ODP select group action.

   This could be made slightly more selective by only recirculating
   if the execution different buckets may result in different packet
   contents and the actions after the ODP select group action rely on
   the packet contents (e.g. set actions do but output actions do not).

   My feeling is that this could be implemented by adding a small amoun=
t
   of extra state to action translation in ovs-vswitchd.

2. Fall back to selecting buckets in ovs-vswtichd

   The idea here is to detect cases where there would be a problem
   executing actions after an ODP select group action and in that
   case to select buckets in ovs-vswtichd: that is use the existing buc=
ket
   translation code in ovs-vswtichd.

   Though this seems conceptually simpler than recirculation it
   seems to me that it would be somewhat more difficult to implement
   as it implies a two stage translation process: e.g. one stage to
   determine if an ODP select group may be used; and one to perform
   the translation.

   I seem to recall trying various two stage translation processes
   as part some earlier unrelated work. And my recollection is that
   the result of my previous efforts were not pretty.

Both of the above more or less negate any benefits of ODP select group
action. In particular lowering flow setup cost and potentially allowing
complete offload of select groups from the datapath to hardware. Howeve=
r I
think that this case is not a common one as it requires both of the
following. And I think they are both not usual use cases.

* Different buckets modifying packets in different ways
  - My expectation is that it is common for buckets to be homogeneous i=
n
    regards to packet modifications. But perhaps this is na=C3=AFve in =
the
    context of VLANs, MPLS, and similar tags that can be pushed and pop=
ped.
* Actions that rely on packet contents after
  - My expectation is that it is common to use a select group to output
    packets and that is the final action performed.
