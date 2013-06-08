From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net-next 03/10] vxlan: move IGMP join/leave to work queue
Date: Sat, 8 Jun 2013 11:23:27 +0300
Message-ID: <CAF1J0HN5k5=kJtcX_enDYBqnAf2HAH5s84nBOb9QjShWnvwmug@mail.gmail.com>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
	<1370406254-6341-3-git-send-email-stephen@networkplumber.org>
	<kommuo$ma8$1@ger.gmane.org>
	<CAF1J0HODhf3Mtg-XupN8K3oXWYV4GKWptDOgWsvvkSX-embfbw@mail.gmail.com>
	<20130605084116.4eb9dc94@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog103.obsmtp.com ([74.125.245.74]:42513 "HELO
	na3sys010aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751496Ab3FHIX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jun 2013 04:23:29 -0400
Received: by mail-ob0-f178.google.com with SMTP id fb19so7753552obc.37
        for <netdev@vger.kernel.org>; Sat, 08 Jun 2013 01:23:28 -0700 (PDT)
In-Reply-To: <20130605084116.4eb9dc94@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 5, 2013 at 6:41 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Wed, 5 Jun 2013 10:29:10 +0300
> Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
>
>> On Wed, Jun 5, 2013 at 9:47 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> > On Wed, 05 Jun 2013 at 04:24 GMT, Stephen Hemminger <stephen@networkplumber.org> wrote:
>> >> Do join/leave from work queue to avoid lock inversion problems
>> >> between normal socket and RTNL. The code comes out cleaner
>> >> as well.
>> >>
>> >> Uses Cong Wang's suggestion to turn refcnt into a real atomic
>> >> since now need to handle case where last use of socket is IGMP
>> >> worker.
>> >>
>> >> Also fixes race where vxlan_stop could be called after
>> >> device was deleted on module removal. The call to rtnl_link_unregister
>> >> would call dellink while vxlan device was still up. Reordering
>> >> the calls fixes it.
>> >>
>> >
>> > After the first 3 patches applied, I got:
>> >
>> > [   55.010954] general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC
>> > [   55.013309] CPU: 1 PID: 163 Comm: kworker/1:2 Not tainted
>> > 3.10.0-rc2+ #1150
>> > [   55.013309] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
>> > [   55.013309] Workqueue: events vxlan_igmp_work
>>
>> I think the problem happens because vxlan_dellink does
>> unregister_netdevice_queue and then immediately calls
>> vxlan_sock_release and thus vs_sock is released before igmp_work
>> starts
>
> This is handled because a refcount is acquired before the igmp_work
> is scheduled.

As far as I can tell, the vxlan_sock_release in vxlan_dellink call
occurs before vxlan_stop is invoked, and therefore before refcount is
acquired for igmp_work.
When I tried to use unregister_netdevice_queue(dev, NULL) I haven't
seen crashes.


--
Sincerely yours,
Mike.
