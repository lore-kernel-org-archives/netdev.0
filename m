From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v4 2/2] vxlan: allow specifying multiple
 default destinations
Date: Mon, 24 Jun 2013 13:24:27 -0700
Message-ID: <20130624132427.56b6284f@nehalam.linuxnetplumber.net>
References: <1372004543-24675-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1372004543-24675-3-git-send-email-mike.rapoport@ravellosystems.com>
	<20130623171440.439356b7@nehalam.linuxnetplumber.net>
	<CAF1J0HOKKZhjs+M++d0LwYBYSexD9Cx84t7MUmu6Gk39PDfXrw@mail.gmail.com>
	<20130624083505.59bd806e@nehalam.linuxnetplumber.net>
	<CAF1J0HMTigLsg3KUMtOUmR0Vyp1nbG3n9pr1JSDLnrDxThAXOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Thomas Graf <tgraf@suug.ch>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f68.google.com ([209.85.160.68]:42634 "EHLO
	mail-pb0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445Ab3FXUYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 16:24:32 -0400
Received: by mail-pb0-f68.google.com with SMTP id jt11so5668145pbb.11
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 13:24:31 -0700 (PDT)
In-Reply-To: <CAF1J0HMTigLsg3KUMtOUmR0Vyp1nbG3n9pr1JSDLnrDxThAXOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Jun 2013 22:52:09 +0300
Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:

> On Mon, Jun 24, 2013 at 6:35 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> > On Mon, 24 Jun 2013 08:57:55 +0300
> > Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
> >
> >> On Mon, Jun 24, 2013 at 3:14 AM, Stephen Hemminger
> >> <stephen@networkplumber.org> wrote:
> >> > On Sun, 23 Jun 2013 19:22:23 +0300
> >> > Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
> >> >
> >> >> A list of multiple default destinations can be used in environments that
> >> >> disable multicast on the infrastructure level, e.g. public clouds.
> >> >>
> >> >> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
> >> >> ---
> >> >>  drivers/net/vxlan.c          | 268 +++++++++++++++++++++++++++++++++++++++++--
> >> >>  include/uapi/linux/if_link.h |  17 +++
> >> >>  2 files changed, 276 insertions(+), 9 deletions(-)
> >> >>
> >> >> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> >> >> index e5fb6568..f57a0d94 100644
> >> >> --- a/drivers/net/vxlan.c
> >> >> +++ b/drivers/net/vxlan.c
> >> >> @@ -103,6 +103,7 @@ struct vxlan_rdst {
> >> >>       u32                      remote_vni;
> >> >>       u32                      remote_ifindex;
> >> >>       struct list_head         list;
> >> >> +     struct rcu_head          rcu;
> >> >>  };
> >> >
> >> > The use of remotes_cnt here is not SMP safe.
> >> > You are using remotes_cnt to size the buffer for dumping, but then the list
> >> > of remotes might change during the dump.
> >>
> >> The remotes_cnt is used only in netlink callbacks with rtnl_lock held
> >> and it cannot be modified otherwise, so I don't see why it is not SMP
> >> safe.
> >>
> >> > There a a couple of alternatives here:
> >> > 1. Put a hard limit on the number of remotes per MAC.
> >> > 2. When there are multiple destnations, just dump multiple entries, like
> >> >    multipath routing does.
> >> >
> >> > I prefer #2 because it also allows for a cleaner API on creation.
> >> >
> >>
> >
> > After a few more hours of review, I think the API still needs more work.
> > The API uses attributes IFLA_VXLAN_REMOTE_NEW and IFLA_VXLAN_REMOTE_DEL to
> > implement adding and deleting entries. This is contrary to other uses of attributes
> > in Linux netlink. The convention is that attributes are are descriptors of objects
> > not verbs. The attributes are reported and used on creation.
> >
> > The API needs to use the netlink message flags to indicate create, replace and delete
> > instead. It may mean changes to net/core/rtnetlink.c. I would rather see VXLAN follow
> > convention as close as possible.
> 
> Just to make sure I've got your point here, the API should use
> RTM_NEWSOMETHING, RTM_DELSOMETHING and RTM_GETSOMETHING message types
> with attribute SOME_PREFIX_VXLAN_REMOTE, and the attribute itself may
> contain sub-attributes, such as remote address, port, vni etc...
> 
> If this assumption is correct I could think of the following alternatives:
> 
> 1) Add RTM_NEWVXLANDST, which seems to me somewhat overkill
> 2) Add RTA_VXLAN_REMOTE to rtattr_type_t. This way that creation API
> will be similar to multipath routing, but I'm not sure that adding
> VXLAN specific attribute type to rtattr_type_t is appropriate.
> 3) Allow zero mac address in rtnl_fdb_{add,del} and than make the
> default destinations part of the fdb, as David Stevens suggested (1).
> In this case fdb deletion should be reworked so that at least one
> default destination will be always kept.

API should look like adding, deleting, modifying routes.
Ideally, it should all work using existing tools with out lots of special pain.
An example would be:

# bridge fdb add 6a:ee:bc:af:7e:4a dev vxlan0 dst 172.30.42.11
# bridge fdb append 6a:ee:bc:af:7e:4a dev vxlan0 dst 172.30.42.12
# bridge fdb show dev vxlan0
6a:ee:bc:af:7e:4a dst 172.30.42.11 self permanent
6a:ee:bc:af:7e:4a dst 172.30.42.12 self permanent

# bridge fdb delete 6a:ee:bc:af:7e:4a dev vxlan0 dst 172.30.42.11
# bridge fdb show dev vxlan0
6a:ee:bc:af:7e:4a dst 172.30.42.12 self permanent

Right now the netlink flags for NLM_F_EXCL and NLM_F_APPEND have no
meaning so it doesn't work that way.

If you delete all destinations, then just delete the entry.
No point in keeping a default if all remote hops are gone.
