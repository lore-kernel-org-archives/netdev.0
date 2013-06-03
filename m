From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3 2/2] vxlan: allow specifying multiple
 default destinations
Date: Mon, 3 Jun 2013 08:57:37 -0700
Message-ID: <20130603085737.72b8406f@nehalam.linuxnetplumber.net>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1369821617-29098-3-git-send-email-mike.rapoport@ravellosystems.com>
	<20130530110948.GA10532@casper.infradead.org>
	<CAF1J0HP+Wu9HjEELDaXM2BMREMuKByWr_zz=PwHeNUt=EVbdvw@mail.gmail.com>
	<20130530113739.GB10532@casper.infradead.org>
	<20130531091740.70b3e077@nehalam.linuxnetplumber.net>
	<20130602102942.GA21706@zed>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:34747 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758770Ab3FCP5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 11:57:41 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so1755601pbb.22
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 08:57:41 -0700 (PDT)
In-Reply-To: <20130602102942.GA21706@zed>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2 Jun 2013 13:29:42 +0300
Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:

> On Fri, May 31, 2013 at 7:17 PM, Stephen Hemminger <stephen@networkplumber.org> wrote:
> > Looking at this code in more detail, I see a slew of problems.
> >
> > First the list of destinations isn't really a list. The default one is still
> > embedded in the fdb entry. This means you can't change it safely.
> >
> > Also the notification via netlink only sends back a single destination
> > value.
> >
> > And the lack of locking on the open coded link list means it is not safe since
> > the forwarding table is used with RCU. In order to be safe, proper RCU
> > barriers would be needed or better yet convert to list_rcu..
> >
> > Overall, I feel guilty for not inspecting this more closely and am surprised
> > that others did not catch the lack of locking.
> 
> I've tried to convert remotes list to use hlist_rcu. The patch below implements the conversion, but it does not address the netlink notification issue.


Ok, let me have a go at this.
1. Using list rather than hlist makes more sense for handling simple list
2. The complexity is in how do do the netlink API.

3. If we can't work this out for 3.11, the multiple remotes may have to be reverted;
   I don't want the existing API to be exposed in a release
