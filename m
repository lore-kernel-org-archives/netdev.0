From: jamal <hadi@cyberus.ca>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Fri, 29 Jun 2007 07:17:15 -0400
Message-ID: <1183115835.5156.37.camel@localhost>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1179831825.4121.30.camel@localhost>
	 <1180258853.7707.53.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
	 <1181820510.4091.9.camel@localhost>
	 <1181869285.5411.39.camel@localhost.localdomain>
	 <1182178882.4063.11.camel@localhost>
	 <1182223964.5411.76.camel@localhost.localdomain>
	 <1182811210.6644.22.camel@johannes.berg>
	 <1182986681.5155.55.camel@localhost>
	 <1183023939.4769.76.camel@johannes.berg>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Zhang Rui <rui.zhang@intel.com>, netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1183023939.4769.76.camel@johannes.berg>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-28-06 at 11:45 +0200, Johannes Berg wrote:

> No, the controller is the only other generic netlink multicast user
> according to what I've found. :)

Scanning the code - true ;-> Iam a little suprised that the task
accounting folks didnt use it to periodically dump stats. 

> actually didn't you just say that groups don't run out at 32-bit because
> the groups bitmap can be extended? You wouldn't be able to sign up for
> the groups >31 at bind() time but with ioctls you can bind higher group
> numbers after the fact. And the dynamic groups mean you need to bind
> later anyway since you don't know the ID when you create the socket.

Sorry i meant there are 2^16 families (-1 considering controller)
There are 2^32 groups (-1 considering controller) for the same number of
families. i.e i see those items as being global within genetlink.

> > c) Use a global hash table to store all the genl_multicast_groups;
> > I think this (handwaving) should be searchable by i) name ii)ID and iii)
> > family. 
> 
> Yeah, makes sense, I never liked the bitmap stuff I did there.
> 

It may be needed and better than how we keep track of the families - I
was just making a handwaving suggestion; when you code/test it will
become obvious.


> >  we use a simple scheme in the case of families; once all
> > IDs are consumed we dont alloc more - in the case of mcast grps this is
> > not necessary IMO i.e it doesnt matter if there is collision when you
> > run out. You return errors at the moment.
> 
> Are you saying I should double-allocate groups? 

I am not sure "double-allocate" would be the right description.
It sort of like shared-irq or a netdevice running in promisc/bcast mode.
More below.

> I really don't want that
> since I plan to add permission checks on top of this.

It is just a boundary condition policy. When there are no more groups
left (Note: it will take a lot of effort to hit that), then what do you
do?
Your current approach seems to say "return an error". My suggestion is 
to just reuse the first or last allocated one or reserve some groups for
sharing and always make sure someone is guaranteed they will get a group
when they ask for it. Infact you can even let the family tell you on
registration whether it is willing to share (and fail allocation if
nothing shareable is available).
Each family when using a shared group will always have a unique name to
itself, so discovery from user space still works - but the id will be
unique across multiple groups. User space code will be like promisc 
mode in networking, it will have to filter out the noise. If i ask the
controller to tell me about a family - it will show all group name/id
and a tag whether it is shared or not (that way my user space code knows
it needs to ignore noise it sees).
I am begining to wonder if Evgeniy's connector actually does this - i
dont remember. I am almost certain TIPC also does something similar.
In any case, this is a corner case - the suggestion is how to deal with
it. You can skin it many ways. Toss a coin - pick one.

> > > --- wireless-dev.orig/include/linux/genetlink.h	2007-06-25 23:56:19.895732308 +0200
> > > +++ wireless-dev/include/linux/genetlink.h	2007-06-26 00:33:36.785732308 +0200
> > > @@ -52,6 +52,9 @@ enum {
> > >  	CTRL_ATTR_HDRSIZE,
> > >  	CTRL_ATTR_MAXATTR,
> > >  	CTRL_ATTR_OPS,
> > > +	CTRL_ATTR_MCAST_GROUPS,
> > > +	CTRL_ATTR_MCAST_GRP_NAME,
> > > +	CTRL_ATTR_MCAST_GRP_ID,
> > 
> > Dont think those last two belong in the same namespace. i.e  they should
> > be a separate enum; even more the name/id pair probably belong in one
> > TLV under the struct genl_multicast_group that is exported to user
> > space.
> 
> Hm? Not sure I understand this. These are attributes for the generic
> netlink controller messages, 

Group name/id are nested into CTRL_ATTR_MCAST_GROUPS. Once you nest, you
are starting to a new namespace i.e as good practice you start counting
from 0. 

> where else should I put them? 

A new enum.

> Why give them
> numbers from a different namespace because they're used inside nested
> attributes?

Sorry - i should have read up to here ;-> Yes, it is because of the
nesting. Again consider the suggestion of sending just one TLV.

> > Overall: I think you are on the right path. Good stuff.
> > I see user space doing a discovery of which groups a family belongs to
> > or even doing a bind-by-name in which the underlying user-space code
> > does a discovery to find the id, then does a bind to that id.
> 
> Yeah, that's what I was thinking of, although the bind-by-name needs
> (family-id, group-name) and nost just group-name

Well, you can hide that from the user in the form of a library etc. They
dont have to know; what they know is group named "link-events" is where
they can join to listen to link events (and your abstraction generic
code does all the dirty work). 

cheers,
jamal


