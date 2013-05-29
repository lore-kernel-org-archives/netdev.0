From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] vxlan: do real refcnt for vn_sock
Date: Wed, 29 May 2013 10:08:53 +0800
Message-ID: <1369793333.12227.4.camel@cr0>
References: <1369739242-5944-1-git-send-email-amwang@redhat.com>
	 <20130528082237.101a1213@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56400 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934950Ab3E2CJB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 May 2013 22:09:01 -0400
In-Reply-To: <20130528082237.101a1213@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-28 at 08:22 -0700, Stephen Hemminger wrote:
> On Tue, 28 May 2013 19:07:22 +0800
> Cong Wang <amwang@redhat.com> wrote:
> 
> > From: Cong Wang <amwang@redhat.com>
> > 
> > In commit 553675fb5e9ce3d71a (vxlan: listen on multiple ports),
> > we use kfree_rcu() to free ->vn_sock, but a) there is no use
> > of RCU API to access this filed, b) RCU is not enough to do refcnt
> > here, because in vxlan_leave_group() we drop RTNL lock before
> > locking the socket, it could be possible that this field is
> > freed during this period.
> > 
> > So, instead making things complex, just do basic refcnt for
> > the ->vn_sock, like we do for others.
> > 
...
> 
> Not needed all access is under RTNL

I know, this is why I had a patch (not posted) which adds the missing
rtnl_dereference(), but even if we had these, it is still not correct.

As I explained in the changelog, vxlan_leave_group() has a problem,
because it releases rtnl lock before locking the socket, _and_ it is
called after vxlan_dellink() which schedules a work to cleanup the
struct. Therefore the ->vn_sock could be freed right after rtnl lock is
released.

Am I miss anything?
