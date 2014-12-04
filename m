From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 4/7] fs/proc/task_mmu.c: shift mm_access() from
 m_start() to proc_maps_open()
Date: Thu, 4 Dec 2014 18:17:32 +0200
Message-ID: <20141204161732.GA8545@node.dhcp.inet.fi>
References: <20140805194627.GA30693@redhat.com>
 <20140805194655.GA30728@redhat.com>
 <20141203141433.GA25683@node.dhcp.inet.fi>
 <87fvcwk6sy.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oleg Nesterov <oleg@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	David Howells <dhowells@redhat.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Sasha Levin <levinsasha928@gmail.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87fvcwk6sy.fsf@x220.int.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 03, 2014 at 10:59:57AM -0600, Eric W. Biederman wrote:
> "Kirill A. Shutemov" <kirill@shutemov.name> writes:
> 
> > On Tue, Aug 05, 2014 at 09:46:55PM +0200, Oleg Nesterov wrote:
> >> A simple test-case from Kirill Shutemov
> >> 
> >> 	cat /proc/self/maps >/dev/null
> >> 	chmod +x /proc/self/net/packet
> >> 	exec /proc/self/net/packet
> >> 
> >> makes lockdep unhappy, cat/exec take seq_file->lock + cred_guard_mutex in
> >> the opposite order.
> >
> > Oleg, I see it again with almost the same test-case:
> >
> > 	cat /proc/self/stack >/dev/null
> > 	chmod +x /proc/self/net/packet
> > 	exec /proc/self/net/packet
> >
> > Looks like bunch of proc files were converted to use seq_file by Alexey
> > Dobriyan around the same time you've fixed the issue for /proc/pid/maps.
> >
> > More generic test-case:
> >
> > 	find /proc/self/ -type f -exec dd if='{}' of=/dev/null bs=1 count=1 ';' 2>/dev/null
> > 	chmod +x /proc/self/net/packet
> > 	exec /proc/self/net/packet
> >
> > David, any justification for allowing chmod +x for files under
> > /proc/pid/net?
> 
> I don't think there are any good reasons for allowing chmod +x for the
> proc generic files.   Certainly executing any of them is nonsense.
> 
> I do recall some weird conner cases existing.  I think they resulted
> in a need to preserve chmod if not chmod +x.  This is just me saying
> tread carefully before you change anything.
> 
> It really should be safe to tweak proc_notify_change to not allow
> messing with the executable bits of proc files.

BTW, we have MS_NOSUID and MS_NOEXEC set in ->s_flags for procfs since
2006 -- see 92d032855e64.

But there's no code which would translate them into vfsmount->mnt_flags |=
MNT_NOSUID/MNT_NOEXEC and we bypast nosuid/noexec checks on exec path.

Hm?..

-- 
 Kirill A. Shutemov
