From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: Re: [PATCH] Add firmware label support to iproute2
Date: Thu, 19 Aug 2010 17:18:50 -0500
Message-ID: <20100819221850.GA20741@auslistsprd01.us.dell.com>
References: <20100812173537.GA29784@auslistsprd01.us.dell.com> <20100812141240.417949e2@s6510> <EDA0A4495861324DA2618B4C45DCB3EE612E34@blrx3m08.blr.amer.dell.com> <20100818144124.33a72453@nehalam> <20100819213314.GA26135@auslistsprd01.us.dell.com> <20100819145308.0fa08522@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Narendra_K@Dell.com, netdev@vger.kernel.org, Charles_Rose@Dell.com,
	Jordan_Hargrave@Dell.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:59167 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236Ab0HSWSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 18:18:51 -0400
Content-Disposition: inline
In-Reply-To: <20100819145308.0fa08522@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 19, 2010 at 02:53:08PM -0700, Stephen Hemminger wrote:
> On Thu, 19 Aug 2010 16:33:14 -0500
> Matt Domsch <Matt_Domsch@Dell.com> wrote:
> 
> > On Wed, Aug 18, 2010 at 02:41:24PM -0700, Stephen Hemminger wrote:
> > > The netdev_alias_to_kernelname should only happen after normal lookup failed.
> > 
> > Stephen, can you enlighten me as to the "right" way to do interface
> > name lookups?  While I can still find examples of parsing
> > /proc/net/dev, or globbing /sys/class/net/*, I expect these aren't the
> > preferred method anymore.  Your own iproute2 suite uses RTM_GETLINK
> > netlink calls, though for the seeming simple case of "give me a list of all
> > interfaces", your path through there is far more capable (and
> > complex) than I would hope to need.
> 
> There is no magic right way. We have to support multiple interfaces.
> I am really concerned that all this alias stuff will turn into a
> disaster when there are 10,000 interfaces (Vlans).  The kernel has
> lots of tables and hashes to handle this but if the utilities
> are doing a dumb scan of all names it will not work.

I believe you proposed a lookup algorithm in each app, something like:

if exists(passed device name)
  use it
else if (kernelname=netdev_alias_to_kernelname(passed device name))
  use kernelname

so I'm looking for the "right" way to do these existance tests.  I
agree iterating through all the interfaces should be avoided.

 
> Also burying logic in an external library seems problematic as
> well. The original sysfs library was a disaster for this.
> I want this to work but it has to have a simple interface that
> is not trying to hide things.

the library right now is all of:

  422 netdevname.c
   38 netdevname.h

with another 100 line app to print the mappings in both directions.

The interface is pretty simple too:

extern int netdev_alias_to_kernelname (const char *alias, char *kernelname);

struct netdev_alias {
        char *name;
        const char *namespace_name;
        int is_descriptive; /* this may disappear yet */
        struct netdev_alias *next;
};
extern int netdev_kernelname_to_aliases (const char *, struct netdev_alias **);
extern void free_netdev_aliases (struct netdev_alias *);

The common app usage will be to call netdev_alias_to_kernelname().
Only those apps that want to display the alternate names would use the
struct or other 2 functions.

Even though it's a small library, I do think it makes sense to make it
a library.  I expect to add additional "namespaces" (e.g. "fw:Embedded
NIC 1" is the name of a device provided by the firmware.  As I
mentioned in my talk at LinuxCon last week (slides at
http://domsch.com/linux/linuxcon10/) there could be other valid name
providers, and we'd like them to be usable without re-patching all the
applications again.

As always, I'm open to ideas.

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
