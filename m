From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Null pointer dereference in nf_nat_move_storage(), kernel 2.6.23.1
Date: Thu, 15 Nov 2007 15:06:59 +0300
Message-ID: <20071115120658.GA17667@2ka.mipt.ru>
References: <473B3874.2020104@redhat.com> <473B83DB.5040303@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:54455 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759278AbXKOMGe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 07:06:34 -0500
Content-Disposition: inline
In-Reply-To: <473B83DB.5040303@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Chuck.

On Wed, Nov 14, 2007 at 06:25:15PM -0500, Chuck Ebbert (cebbert@redhat.com) wrote:
> > https://bugzilla.redhat.com/show_bug.cgi?id=259501#c14

> >  [<f8b61643>] __nf_ct_ext_add+0x12f/0x1c4 [nf_conntrack] 

> > nf_nat_move_storage():
> > /usr/src/debug/kernel-2.6.23/linux-2.6.23.i686/net/ipv4/netfilter/nf_nat_core.c:612
> >       87:       f7 47 64 80 01 00 00    testl  $0x180,0x64(%edi)
> >       8e:       74 39                   je     c9 <nf_nat_move_storage+0x65>
> > 
> > line 612:
> >         if (!(ct->status & IPS_NAT_DONE_MASK))
> >                 return;

Please test attached patch.

This routing is called each time hash should be replaced, nf_conn has
extension list which contains pointers to connection tracking users
(like nat, which is right now the only such user), so when replace takes
place it should copy own extensions. Loop above checks for own
extension, but tries to move higer-layer one, which can lead to above
oops.

Not tested, derived from code observation only.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index a1a65a1..cf6ba66 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -109,7 +109,7 @@ void *__nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
 			rcu_read_lock();
 			t = rcu_dereference(nf_ct_ext_types[i]);
 			if (t && t->move)
-				t->move(ct, ct->ext + ct->ext->offset[id]);
+				t->move(ct, ct->ext + ct->ext->offset[i]);
 			rcu_read_unlock();
 		}
 		kfree(ct->ext);

-- 
	Evgeniy Polyakov
