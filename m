From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Suspicious RCU usage in bridge with Linux
 v4.0-9362-g1fc149933fd4
Date: Mon, 04 May 2015 13:49:32 -0700
Message-ID: <1430772572.27254.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+5PVA5gE_pG5iPKBgugsEjLsOYvq9bWKfB+2OeEujjdOb+URg@mail.gmail.com>
	 <20150504133943.GA17043@x131e>
	 <CAHA+R7PAzzz+CZfnOoweBdeLY8tRkr2bSDEpQgdtEKUeaZbWpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dominick Grift <dac.override@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:36553 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbbEDUte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 16:49:34 -0400
Received: by igblo3 with SMTP id lo3so94820752igb.1
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 13:49:34 -0700 (PDT)
In-Reply-To: <CAHA+R7PAzzz+CZfnOoweBdeLY8tRkr2bSDEpQgdtEKUeaZbWpQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-04 at 11:45 -0700, Cong Wang wrote:
> On Mon, May 4, 2015 at 6:39 AM, Dominick Grift <dac.override@gmail.com> wrote:
> > On Thu, Apr 23, 2015 at 01:07:45PM -0400, Josh Boyer wrote:
> >> Hi All,
> >>
> >> We've had a user report the following backtrace from the bridge module
> >> with a recent Linus' tree.  Has anything like this been reported yet?
> >> If you have any questions on setup, the user is CC'd.
> >>
> >> josh
> >>
> >> [   29.382235] br0: port 1(tap0) entered forwarding state
> >>
> >> [   29.382286] ===============================
> >> [   29.382315] [ INFO: suspicious RCU usage. ]
> >> [   29.382344] 4.1.0-0.rc0.git11.1.fc23.x86_64 #1 Not tainted
> >> [   29.382380] -------------------------------
> >> [   29.382409] net/bridge/br_private.h:626 suspicious
> >> rcu_dereference_check() usage!
> >
> > <snip>
> >
> > With 4.1.0-0.rc1.git1.1.fc23.x86_64 the situation seems to have slightly changed:
> >
> 
> Should be the same issue. Please give the attached patch a try,
> it is compile-tested only.
> 
> Thanks!

Please send inline patches, otherwise its hard for us to review them and
give feedback.

At first glance, it is way too complicated.

br_get_vlan_info() change is not needed :

rcu_dereference_rtnl() can already be used from RCU or RTNL protected
code.

(Quite different from rtnl_dereference())

What about :

diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
index 4fcaa67750fda845ad0a180332c4cd96a9524086..7caf7fae2d5b8aa369b924e1c87a47c343fb8954 100644
--- a/net/bridge/br_stp_timer.c
+++ b/net/bridge/br_stp_timer.c
@@ -97,7 +97,9 @@ static void br_forward_delay_timer_expired(unsigned long arg)
 		netif_carrier_on(br->dev);
 	}
 	br_log_state(p);
+	rcu_read_lock();
 	br_ifinfo_notify(RTM_NEWLINK, p);
+	rcu_read_unlock();
 	spin_unlock(&br->lock);
 }
 
