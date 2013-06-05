From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 03/10] vxlan: move IGMP join/leave to work
 queue
Date: Wed, 5 Jun 2013 08:41:16 -0700
Message-ID: <20130605084116.4eb9dc94@nehalam.linuxnetplumber.net>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
	<1370406254-6341-3-git-send-email-stephen@networkplumber.org>
	<kommuo$ma8$1@ger.gmane.org>
	<CAF1J0HODhf3Mtg-XupN8K3oXWYV4GKWptDOgWsvvkSX-embfbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:34713 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755634Ab3FEPlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 11:41:21 -0400
Received: by mail-pb0-f50.google.com with SMTP id wy17so1970940pbc.37
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 08:41:20 -0700 (PDT)
In-Reply-To: <CAF1J0HODhf3Mtg-XupN8K3oXWYV4GKWptDOgWsvvkSX-embfbw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 5 Jun 2013 10:29:10 +0300
Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:

> On Wed, Jun 5, 2013 at 9:47 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> > On Wed, 05 Jun 2013 at 04:24 GMT, Stephen Hemminger <stephen@networkplumber.org> wrote:
> >> Do join/leave from work queue to avoid lock inversion problems
> >> between normal socket and RTNL. The code comes out cleaner
> >> as well.
> >>
> >> Uses Cong Wang's suggestion to turn refcnt into a real atomic
> >> since now need to handle case where last use of socket is IGMP
> >> worker.
> >>
> >> Also fixes race where vxlan_stop could be called after
> >> device was deleted on module removal. The call to rtnl_link_unregister
> >> would call dellink while vxlan device was still up. Reordering
> >> the calls fixes it.
> >>
> >
> > After the first 3 patches applied, I got:
> >
> > [   55.010954] general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC
> > [   55.013309] CPU: 1 PID: 163 Comm: kworker/1:2 Not tainted
> > 3.10.0-rc2+ #1150
> > [   55.013309] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
> > [   55.013309] Workqueue: events vxlan_igmp_work
> 
> I think the problem happens because vxlan_dellink does
> unregister_netdevice_queue and then immediately calls
> vxlan_sock_release and thus vs_sock is released before igmp_work
> starts

This is handled because a refcount is acquired before the igmp_work
is scheduled.
