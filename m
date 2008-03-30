From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [AX25] kernel panic
Date: Sun, 30 Mar 2008 20:49:06 +0200
Message-ID: <20080330184906.GB5133@ami.dom.local>
References: <47E68CA1.2040904@free.fr> <20080324205104.GA3721@ami.dom.local> <47E8FCE2.6000308@free.fr> <20080326183538.GA14266@ami.dom.local> <20080328120721.GA11060@ami.dom.local> <47EE3040.3050208@free.fr> <20080329122452.GB3407@ami.dom.local> <47EF529B.8060108@free.fr> <20080330091636.GA2847@ami.dom.local> <47EFD02B.8080006@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@o2.pl>
To: Bernard Pidoux <bpidoux@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:12333 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbYC3Skr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Mar 2008 14:40:47 -0400
Received: by nf-out-0910.google.com with SMTP id g13so418966nfb.21
        for <netdev@vger.kernel.org>; Sun, 30 Mar 2008 11:40:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <47EFD02B.8080006@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 30, 2008 at 07:38:51PM +0200, Bernard Pidoux wrote:
...
> There is no more warnings and no more ax25_frames_acked or
> sk_ax25_debug.
>
> We only get ax25_create and ax25_release data, plus ax25_make_new when  
> there is an AX25 connexion.
>
> cat /var/log/messages | grep 'Mar 30 17' | grep AX...
> Mar 30 17:00:58 f6bvp-9 kernel: AX25+ ax25_create, 866, c73a6738, c3300040
> Mar 30 17:00:58 f6bvp-9 kernel: AX25- ax25_release, 959, c73a6738, c3300040
> Mar 30 17:00:58 f6bvp-9 kernel: AX25+ ax25_create, 866, c73a6738, c3300040
> Mar 30 17:00:58 f6bvp-9 kernel: AX25- ax25_release, 959, c73a6738, c3300040
> Mar 30 17:01:23 f6bvp-9 kernel: AX25; ax25_make_new, 943, c73a6738, c762a820
> Mar 30 17:01:23 f6bvp-9 kernel: AX25= ax25_accept, 1386, c73a6738,  
> c762a820, c3300040
> Mar 30 17:01:58 f6bvp-9 kernel: AX25+ ax25_create, 866, c73a6f68, c7673ac0
> Mar 30 17:01:58 f6bvp-9 kernel: AX25- ax25_release, 959, c73a6f68, c7673ac0
> Mar 30 17:01:58 f6bvp-9 kernel: AX25+ ax25_create, 866, c73a6f68, c7673ac0

Yes, if it's only like this, it's OK.
>
>
> Please excuse the following questions if you find they are too naive.
> Could you tell us how did you suspect ROSE socket from the data  
> collected ? and why improperly released ROSE sockets could interfere  
> with AX25 ?

No problem! Patch #3 added to "sk_ax25_debug =" sk->sk_family as the
2nd number, and 11 according to include/linux/socket.h means AF_ROSE.

sock_def_write() function in net/core/sock.c where the OOPs triggered
runs some cleaning on sockets when their skbs are kfreed, but this
shouldn't be done after socket had been closed (sock_orphan() removes
some pointers). When ROSE sends it's skbs with ax25_send_frame(), they
are added to AX25 queues, and kfreed after transmitting. If it's after
ROSE socket had been released, but not properly updated, the cleaning
is done on kfreed memory not used by the socket anymore.

Cheers,
Jarek P.
