From: Dave Jones <davej@redhat.com>
Subject: Re: destroy_conntrack GPF in 3.7.9
Date: Wed, 6 Mar 2013 11:44:44 -0500
Message-ID: <20130306164444.GA26521@redhat.com>
References: <20130306155955.GA24215@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fedora Kernel Team <kernel-team@fedoraproject.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41925 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752477Ab3CFQou (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 11:44:50 -0500
Content-Disposition: inline
In-Reply-To: <20130306155955.GA24215@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 06, 2013 at 10:59:55AM -0500, Dave Jones wrote:
 > I know 3.7.9 is EOL, but this code doesn't look like it's changed in current.
 > (unless the cause/fix was in code unrelated to these paths)
 > 
 > A user reported the following GPF..
 > 
 >         /* To make sure we don't get any weird locking issues here:
 >          * destroy_conntrack() MUST NOT be called with a write lock
 >          * to nf_conntrack_lock!!! -HW */
 >         rcu_read_lock();
 >         l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
 >     1378:       0f b6 b3 86 00 00 00    movzbl 0x86(%rbx),%esi
 >     137f:       0f b7 7b 72             movzwl 0x72(%rbx),%edi
 >     1383:       e8 00 00 00 00          callq  1388 <destroy_conntrack+0x78>
 >         if (l4proto && l4proto->destroy)
 >     1388:       48 85 c0                test   %rax,%rax
 >     138b:       74 0e                   je     139b <destroy_conntrack+0x8b>
 >     138d:       48 8b 40 28             mov    0x28(%rax),%rax    <-----  HERE
 >     1391:       48 85 c0                test   %rax,%rax
 >     1394:       74 05                   je     139b <destroy_conntrack+0x8b>
 >                 l4proto->destroy(ct);
 >     1396:       48 89 df                mov    %rbx,%rdi
 >     1399:       ff d0                   callq  *%rax
 > 
 > 
 > l4proto (%rax) is garbage (0x50626b6b7876376c) which looks a little like ascii,
 > but P>kkxv7l doesn't mean much to me.
 > 
 > https://bugzilla.redhat.com/show_bug.cgi?id=917792 is the original report, but
 > there aren't any further details yet.

I just realised I reported this last September against 3.6

https://bugzilla.redhat.com/show_bug.cgi?id=859346
shows what looks like a use after free.  l4proto got freed somewhere.

	Dave
