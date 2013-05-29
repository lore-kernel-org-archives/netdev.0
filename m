From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch net-next] vxlan: do real refcnt for vn_sock
Date: Tue, 28 May 2013 21:22:00 -0700
Message-ID: <20130528212200.798261d7@nehalam.linuxnetplumber.net>
References: <1369739242-5944-1-git-send-email-amwang@redhat.com>
	<20130528082237.101a1213@nehalam.linuxnetplumber.net>
	<1369793333.12227.4.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:54424 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889Ab3E2EWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 00:22:06 -0400
Received: by mail-pb0-f53.google.com with SMTP id un4so8710262pbc.12
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 21:22:04 -0700 (PDT)
In-Reply-To: <1369793333.12227.4.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 May 2013 10:08:53 +0800
Cong Wang <amwang@redhat.com> wrote:

> On Tue, 2013-05-28 at 08:22 -0700, Stephen Hemminger wrote:
> > On Tue, 28 May 2013 19:07:22 +0800
> > Cong Wang <amwang@redhat.com> wrote:
> > 
> > > From: Cong Wang <amwang@redhat.com>
> > > 
> > > In commit 553675fb5e9ce3d71a (vxlan: listen on multiple ports),
> > > we use kfree_rcu() to free ->vn_sock, but a) there is no use
> > > of RCU API to access this filed, b) RCU is not enough to do refcnt
> > > here, because in vxlan_leave_group() we drop RTNL lock before
> > > locking the socket, it could be possible that this field is
> > > freed during this period.
> > > 
> > > So, instead making things complex, just do basic refcnt for
> > > the ->vn_sock, like we do for others.
> > > 
> ...
> > 
> > Not needed all access is under RTNL
> 
> I know, this is why I had a patch (not posted) which adds the missing
> rtnl_dereference(), but even if we had these, it is still not correct.
> 
> As I explained in the changelog, vxlan_leave_group() has a problem,
> because it releases rtnl lock before locking the socket, _and_ it is
> called after vxlan_dellink() which schedules a work to cleanup the
> struct. Therefore the ->vn_sock could be freed right after rtnl lock is
> released.
> 
> Am I miss anything?

Ignoring your IPv6 code for now...

With IPV4:
   refcnt is incremented when socket is incremented in newlink (RTNL held).
   refcnt is decremented in by dellink (RTNL held) and socket is deleted from list
   leave_group doesn't happen until work queue is fired.

rtnl_dereference is fine, but hardly necessary when the call hierarchy is so obvious.

The problem you describe won't be fixed by just converting it to atomic,
I think you need add a dev_hold()/dev_put to vxlan_stop to prevent
device from being deleted when rtnl_lock is dropped.




   
   
