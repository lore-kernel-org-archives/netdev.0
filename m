From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [RFC PATCH linux 2/2] fs/proc: use a hash table for the
 directory entries
Date: Thu, 2 Oct 2014 23:06:39 +0300
Message-ID: <20141002200639.GA3497@p183.telecom.by>
References: <20131003.150947.2179820478039260398.davem@davemloft.net>
 <1412263501-6572-1-git-send-email-nicolas.dichtel@6wind.com>
 <1412263501-6572-3-git-send-email-nicolas.dichtel@6wind.com>
 <87h9zmpcz5.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, akpm@linux-foundation.org,
	rui.xiang@huawei.com, viro@zeniv.linux.org.uk, oleg@redhat.com,
	gorcunov@openvz.org, kirill.shutemov@linux.intel.com,
	grant.likely@secretlab.ca, tytso@mit.edu,
	Thierry Herbelot <thierry.herbelot@6wind.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87h9zmpcz5.fsf@x220.int.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 02, 2014 at 11:01:50AM -0700, Eric W. Biederman wrote:
> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
> 
> > From: Thierry Herbelot <thierry.herbelot@6wind.com>
> >
> > The current implementation for the directories in /proc is using a single
> > linked list. This is slow when handling directories with large numbers of
> > entries (eg netdevice-related entries when lots of tunnels are opened).
> >
> > This patch enables multiple linked lists. A hash based on the entry name is
> > used to select the linked list for one given entry.
> >
> > The speed creation of netdevices is faster as shorter linked lists must be
> > scanned when adding a new netdevice.
> 
> Is the directory of primary concern /proc/net/dev/snmp6 ?
> 
> Unless I have configured my networking stack weird by mistake that
> is the only directory under /proc/net that grows when we add an
> interface.
> 
> I just want to make certain I am seeing the same things that you are
> seeing.
> 
> I feel silly for overlooking this directory when the rest of the
> scalability work was done.

Slowdown comes from "duplicate name" check:

        for (tmp = dir->subdir; tmp; tmp = tmp->next)
                if (strcmp(tmp->name, dp->name) == 0) {
                        WARN(1, "proc_dir_entry '%s/%s' already registered\n",
                                dir->name, dp->name);
                        break;
                }

Removal can be made O(1) after switching to doubly-linked list.

	Alexey
