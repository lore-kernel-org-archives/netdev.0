From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: netns XFRM preview
Date: Fri, 21 Nov 2008 18:21:06 +0300
Message-ID: <20081121152106.GA29944@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containters@lists.osdl.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:20920 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292AbYKUPRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 10:17:21 -0500
Received: by nf-out-0910.google.com with SMTP id d3so486673nfc.21
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2008 07:17:19 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm several days away from posting netns xfrm patchset which will make IPsec
to work inside netns container. There are still some tricky places which
aren't ready, but, anyway, here is big picture, so hopefully big misdesigns
can be found earlier:

1. add netns pointer to struct xfrm_state, struct xfrm_policy
	like conntracking, set in one place, write-once field,
	avoid many complications, very natural extension for policies.

2. per-netns xfrm_state_all list
3. per-netns xfrm_state_bydst, xfrm_state_bysrc, xfrm_state_byspi hashtables
	this could be stay one hashtable, but we a) get more complex
	"everything flushed" check on netns stop, b) make very, very sure
	iterators skip alien netns states,

	In per-netns case c) slightly more memory per-netns
	d) less state walking, less probable DoS possibilities

4. per-netns xfrm_state_num -- number of xfrm_states
5. per-netns km_waitq -- we don't make spurious wakeup __xfrm_lookup()
6. per-netns xfrm_policy_all list
7. per-netns xfrm_policy_byidx, xfrm_policy_bydst hashes
	see 3)

8. per-netns inexact policies list
9. per-netns policy counts
10. netns parameter in state flushing, policy flushing
	xfrm_state/xfrm_policy doesn't pin netns -- has to cleanup everything
	on netns stop

11. per-netns NETLINK_XFRM kernel socket
12. netns-ready PF_KEY sockets
13. netns-ready ah4, esp4, ah6, esp6
14. per-netns XFRM MIBs
15. per-netns and correct /proc/net/xfrm_stat

Kept as-is:
1. all sorts of locks, mutexes et al
	- not strictly necessary
	- not strictly necessary for first cut
	- relevant only to netns users (both of them :^)
	- when someone will notice contention, easy to make per-netns

2. xfrm_policy_afinfo() -- I'm trying hard to keep it as-is but ->dst_ops and
	garbage collecting can change, they whole idea of per-netns dst_ops
	seems like quite a hack.
3. xfrm_state_afinfo -- big pile of hooks and constant data
4. xfrm types, modes -- enabled by loading modules, system-wide thing
5. xfrm_state_genid -- as I understood it, it simply a cookie, that's only compared
	for equality/lesserness, the fact that it can be bumped by more than 1
	is not interesting.

One dust settles,
42. sysctls
43. policy migration
44. IPcomp

Again, this is a big picture, result is that IPsec traffic was exchanged with
netns container. Stay tuned.
