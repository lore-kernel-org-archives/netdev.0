From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH linux 2/2] fs/proc: use a hash table for the
 directory entries
Date: Thu, 2 Oct 2014 14:27:03 -0700
Message-ID: <20141002142703.10325f4f@urahara>
References: <20131003.150947.2179820478039260398.davem@davemloft.net>
	<1412263501-6572-1-git-send-email-nicolas.dichtel@6wind.com>
	<1412263501-6572-3-git-send-email-nicolas.dichtel@6wind.com>
	<87h9zmpcz5.fsf@x220.int.ebiederm.org>
	<20141002200639.GA3497@p183.telecom.by>
	<87h9zmji3q.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, akpm@linux-foundation.org,
	rui.xiang@huawei.com, viro@zeniv.linux.org.uk, oleg@redhat.com,
	gorcunov@openvz.org, kirill.shutemov@linux.intel.com,
	grant.likely@secretlab.ca, tytso@mit.edu,
	Thierry Herbelot <thierry.herbelot@6wind.com>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87h9zmji3q.fsf@x220.int.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 02 Oct 2014 14:07:37 -0700
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Alexey Dobriyan <adobriyan@gmail.com> writes:
> 
> > On Thu, Oct 02, 2014 at 11:01:50AM -0700, Eric W. Biederman wrote:
> >> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
> >> 
> >> > From: Thierry Herbelot <thierry.herbelot@6wind.com>
> >> >
> >> > The current implementation for the directories in /proc is using a single
> >> > linked list. This is slow when handling directories with large numbers of
> >> > entries (eg netdevice-related entries when lots of tunnels are opened).
> >> >
> >> > This patch enables multiple linked lists. A hash based on the entry name is
> >> > used to select the linked list for one given entry.
> >> >
> >> > The speed creation of netdevices is faster as shorter linked lists must be
> >> > scanned when adding a new netdevice.
> >> 
> >> Is the directory of primary concern /proc/net/dev/snmp6 ?
> >> 
> >> Unless I have configured my networking stack weird by mistake that
> >> is the only directory under /proc/net that grows when we add an
> >> interface.
> >> 
> >> I just want to make certain I am seeing the same things that you are
> >> seeing.
> >> 
> >> I feel silly for overlooking this directory when the rest of the
> >> scalability work was done.
> >
> > Slowdown comes from "duplicate name" check:
> >
> >         for (tmp = dir->subdir; tmp; tmp = tmp->next)
> >                 if (strcmp(tmp->name, dp->name) == 0) {
> >                         WARN(1, "proc_dir_entry '%s/%s' already registered\n",
> >                                 dir->name, dp->name);
> >                         break;
> >                 }
> >
> > Removal can be made O(1) after switching to doubly-linked list.
> 
> Yes.  There is the however unfortunate fact that proc directories exist
> to be used.  If we don't switch to a better data structure than a linked
> list the actual use will then opening of the files under
> /proc/net/dev/snmp6/ will become O(N^2).  Which doesn't help much
> (assuming those files are good for something).
> 
> If those files aren't actually useful we should just make registering
> them a config option.  Deprecate them strongly and let only people who
> need extreme backwards compatibility enable them.

Net-snmp uses them (agent/mibgroup/mibII/kernel_linux.c)
