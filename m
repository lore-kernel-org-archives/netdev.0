From: jamal <hadi@cyberus.ca>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Wed, 27 Jun 2007 19:24:41 -0400
Message-ID: <1182986681.5155.55.camel@localhost>
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
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Zhang Rui <rui.zhang@intel.com>, netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.238]:1878 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759341AbXF0XYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 19:24:45 -0400
Received: by wx-out-0506.google.com with SMTP id h31so337084wxd
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2007 16:24:44 -0700 (PDT)
In-Reply-To: <1182811210.6644.22.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 2007-26-06 at 00:40 +0200, Johannes Berg wrote:

> I wonder if we should hold off on this API until we've worked out the
> multicast issue.

Even if the ACPI thing goes in first, you will have to change a few
others that are existing in-kernel that need to be changed sooner or
later. So either way is fine.

> My proposition for the actual dynamic registration interface would be to
> add a .groups array to pointers to struct genl_family with that just
> being
> 
> struct genl_multicast_group {
> 	char *name;
> 	u32 id;
> }

heres some feedback:
- I think you should use the same approach as we use for ops. 
a) i.e other than the reserved group for controller (which you seem to
be taking care of), every other genetlink user has to explicitly
register when they need a mcast group. 
b) While the names may vary on a per-family basis, the Grpids should be
unique (e.g when you run out of group ids - it would take a lot more
allocations than there are families; 32 bit vs 16 bit for that to
happen)
c) Use a global hash table to store all the genl_multicast_groups;
I think this (handwaving) should be searchable by i) name ii)ID and iii)
family. 

> --- wireless-dev.orig/include/net/genetlink.h	2007-06-25 23:56:59.085732308 +0200
> +++ wireless-dev/include/net/genetlink.h	2007-06-26 00:01:43.935732308 +0200
> @@ -5,12 +5,26 @@
>  #include <net/netlink.h>
>  
>  /**
> + * struct genl_multicast_group - generic netlink multicast group
> + * @name: name of the multicast group, names are per-family
> + * @id: multicast group ID, assigned by the core, to use with
> + *      genlmsg_multicast().
> + */
> +struct genl_multicast_group
> +{
> +	char	name[GENL_NAMSIZ];
> +	u32	id;
> +};

Add the list constructs on the struct - look at the way commands are
done.
We do use hash tables for global storage of families for example.
 
> +/**
>   * struct genl_family - generic netlink family
>   * @id: protocol family idenfitier
>   * @hdrsize: length of user specific header in bytes
>   * @name: name of family
>   * @version: protocol version
>   * @maxattr: maximum number of attributes supported
> + * @multicast_groups: multicast groups to be registered
> + *	for this family (%NULL-terminated array)
>   * @attrbuf: buffer to store parsed attributes
>   * @ops_list: list of all assigned operations
>   * @family_list: family list
> @@ -22,6 +36,7 @@ struct genl_family
>  	char			name[GENL_NAMSIZ];
>  	unsigned int		version;
>  	unsigned int		maxattr;
> +	struct genl_multicast_group **multicast_groups;

If you do the lists (struct list_head) you wont need this.


> +static unsigned long mcast_group_start = 0x3;
> +static unsigned long *multicast_groups = &mcast_group_start;
> +static unsigned long multicast_group_bits = BITS_PER_LONG;

I think if you used a hash table you wont need to keep track of the
above; maybe not - You may still need the above to keep track of which
IDs are in use and where holes in multicast group ID space exist
(assuming some are going to be unregistered over time etc) 


> +
> +static int genl_register_mcast_groups(struct genl_family *family)
> +{

 we use a simple scheme in the case of families; once all
IDs are consumed we dont alloc more - in the case of mcast grps this is
not necessary IMO i.e it doesnt matter if there is collision when you
run out. You return errors at the moment.


> --- wireless-dev.orig/include/linux/genetlink.h	2007-06-25 23:56:19.895732308 +0200
> +++ wireless-dev/include/linux/genetlink.h	2007-06-26 00:33:36.785732308 +0200
> @@ -52,6 +52,9 @@ enum {
>  	CTRL_ATTR_HDRSIZE,
>  	CTRL_ATTR_MAXATTR,
>  	CTRL_ATTR_OPS,
> +	CTRL_ATTR_MCAST_GROUPS,
> +	CTRL_ATTR_MCAST_GRP_NAME,
> +	CTRL_ATTR_MCAST_GRP_ID,

Dont think those last two belong in the same namespace. i.e  they should
be a separate enum; even more the name/id pair probably belong in one
TLV under the struct genl_multicast_group that is exported to user
space.

Overall: I think you are on the right path. Good stuff.
I see user space doing a discovery of which groups a family belongs to
or even doing a bind-by-name in which the underlying user-space code
does a discovery to find the id, then does a bind to that id.

cheers,
jamal

