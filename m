From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Fwd: [PATCH 1/1] team: remove unnecessary lock
Date: Fri, 27 May 2016 16:57:57 +0200
Message-ID: <20160527145757.GA2151@nanopsycho>
References: <1464280752-30995-1-git-send-email-shandong_liny@163.com>
 <CAD=hENfU8_qQHV6=Zp1y1xYq-AVB5E6Q7pmfpJxNio=MtnnF+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33129 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755176AbcE0O6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 10:58:01 -0400
Received: by mail-wm0-f66.google.com with SMTP id a136so15696726wme.0
        for <netdev@vger.kernel.org>; Fri, 27 May 2016 07:58:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAD=hENfU8_qQHV6=Zp1y1xYq-AVB5E6Q7pmfpJxNio=MtnnF+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, May 27, 2016 at 04:25:29AM CEST, zyjzyj2000@gmail.com wrote:
>Hi, Jiri
>
>I delved into the source code of team. And I found that the function
>team_add_slave actually works in the protection of rtnl lock. So in my
>humble opinion, it is not necessary to use the mutex lock to protect
>team_port_add again.
>
>And I made tests in ubuntu 16.04 server, without the mutex lock, the
>team_add_slave can also work well.
>The steps:
>
>1.
>nmcli con add type team con-name team0 ifname team0 config
>'{"runner":{"name":"activebackup"}}'
>2.
>nmcli con add type team-slave con-name team0-port1 ifname eno16777736
>master team0
>nmcli con add type team-slave con-name team0-port2 ifname eno33554960
>master team0
>
>The above test can work well without the mutex lock. So I made the
>following patch, please comment on this patch.

Well, team lock could be replaced by rtnl and removed. Removing just
this tiny usage solves nothing. I decided to use team-specific lock to
do not overload rtnl at the beginning.


>
>Thanks a lot.
>Zhu Yanjun
>
>From: Zhu Yanjun<zyjzyj2000@gmail.com>
>
>The function team_add_slave works in the context of the rtnl lock.
>It is not necessary to use the mutex lock since the rtnl lock is
>enough.
>
>Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
>---
> drivers/net/team/team.c | 2 --
> 1 file changed, 2 deletions(-)
>
>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>index a0f64cb..ad84069 100644
>--- a/drivers/net/team/team.c
>+++ b/drivers/net/team/team.c
>@@ -1936,9 +1936,7 @@ static int team_add_slave(struct net_device *dev,
>struct net_device *port_dev)
>        struct team *team = netdev_priv(dev);
>        int err;
>
>-       mutex_lock(&team->lock);
>        err = team_port_add(team, port_dev);
>-       mutex_unlock(&team->lock);
>        return err;
> }
>
>--
>1.9.1
