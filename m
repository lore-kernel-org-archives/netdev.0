From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Re: O/M flags against 2.6.0-test1
Date: Fri, 05 Sep 2003 11:26:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F58D567.2050201@us.ibm.com>
References: <20030730220223.4c25fcfe.davem@redhat.com>	<Pine.LNX.4.44.0307311330200.27478-100000@DYN318430> <20030804165746.133f370a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
   Krishna Kumar <krkumar@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030804165746.133f370a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

 > Krishna is away, but let us make more progress on this patch.

I have just got back and I didn't see any follow up on this. I also found
that it is not yet in the 2.6.0-test4 kernel, so would like to find  out what
needs to be done to get it included.

To answer your comments :

 > Ok, how does this actually work?  The code does RTA_PUT(...IFLA_INET6_*...)
 > but IFLA_PROTINFO is not actually used anywhere.  This cannot work, it makes
 > these RTA attributes just look like whatever IFLA_* ones have the
 > same values as the inet6 ones in this enumeration.

The inet6_fill_ifinfo adds a IFLA_PROTINFO msg to the skb and then adds the
sub-attribute like IFLA_INET6_FLAGS, IFLA_INET6_CONF, sets the length of
sub-attr, etc. Code snippet :

	subattr = (struct rtattr*)skb->tail;
	RTA_PUT(skb, IFLA_PROTINFO, 0, NULL);
	/* return the device flags */
	RTA_PUT(skb, IFLA_INET6_FLAGS, sizeof(__u32), &idev->if_flags);

 > > +		 /* return the device sysctl params */
 > > +		 if ((array = kmalloc(DEVCONF_MAX * sizeof(*array), GFP_KERNEL)) == NULL)
 > > +		 		 goto rtattr_failure;
 > > +		 ipv6_store_devconf(&idev->cnf, array);
 > > +		 RTA_PUT(skb, IFLA_INET6_CONF, DEVCONF_MAX * sizeof(*array), array);

 > This is what I'm talking about.  Maybe there is something I'm missing.
 > How does APP know to interpret IFLA_INET6_CONF as "sub-attribute"
 > of IFLA_PROTINFO?

I think this is answered above. Please correct me if I have missed something.

 > Also, missing "memset(array, 0, sizeof(*array));" else we leak
 > uninitialized kernel memory into user space.

Is that needed since the array allocated is exactly DEVCONF_MAX sized and the
ipv6_store_devconf writes exactly DEVCONF_MAX entries and the rta_len is marked
accordinging to finish at the end of the array. But I can still add it for
clarity...

 > Another bug, GFP_KERNEL memory allocation with dev_base_lock held.

Yes, that should be changed to GFP_ATOMIC.

 > Otherwise I am OK with the patch.

OK, should I fix these two bugs and re-submit against test4 kernel ?

Dave, I would like to get the prefix list and O/M flags information included
in 2.4 kernel too, are you OK with that ?

Thanks,

- KK
