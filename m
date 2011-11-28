From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH v2 net-next] af_unix: dont send SCM_CREDENTIALS by default
Date: Mon, 28 Nov 2011 14:23:05 +0100
Message-ID: <4ED38B39.5010206@redhat.com>
References: <1315488497.2456.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <1315473888.2301.21.camel@schen9-mobl>  <1315544777.5410.19.camel@edumazet-laptop>  <20110918.210758.2207266633127640132.davem@davemloft.net>  <1316406528.2521.15.camel@edumazet-laptop>  <1316444524.2539.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <1316447547.2539.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <1316468398.4680.6.camel@schen9-DESK>  <6030.1316484637@turing-police.cc.vt.edu> <1316492170.2455.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, Tim Chen <tim.c.chen@linux.intel.com>,
	David Miller <davem@davemloft.net>, zheng.z.yan@intel.com,
	yanzheng@21cn.com, netdev@vger.kernel.org, sfr@canb.auug.org.au,
	jirislaby@gmail.com, sedat.dilek@gmail.com, alex.shi@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9216 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751975Ab1K1NXc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 08:23:32 -0500
In-Reply-To: <1316492170.2455.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/2011 06:16 AM, Eric Dumazet wrote:
> Note : The man page does states :
>
> "To receive a struct ucred message the SO_PASSCRED option  must  be
> enabled  on  the socket."
>
> But it doesnt say if the SO_PASSCRED option must be enabled before the
> sender sends its message, or before receiver attempts to read it.
>
> Once a message is queued on an unix socket, flipping SO_PASSCRED cant
> change its content (adding or removing credentials), since sender might
> already have disappeared.
>
> So current code includes credentials in all sent messages, just in case
> receiver actually fetch credentials.
>
> There are probably programs that assume they can set SO_PASSCRED right
> before calling recvmsg(). Are we taking risk to break them, or are we
> gentle and provide a sysctl option to ease the transition, I dont
> know...

Such a case has just appeared:
https://bugzilla.redhat.com/show_bug.cgi?id=757628

systemd allows on-demand socket activation of services. It creates a 
listening socket without the SO_PASSCRED flag. When the first message 
arrives to the socket, systemd spawns the service and passes the 
socket's fd to it. The service sets SO_PASSCRED before actually 
receiving the message.

I can fix that in systemd, but there may be more cases like this.

Michal
