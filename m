From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.4.4/amd64 full interrupt hangs under big nfs copies
Date: Mon, 16 Jul 2012 18:21:57 +0200
Message-ID: <1342455717.2830.14.camel@edumazet-glaptop>
References: <20120409.143710.879746943062854492.davem@davemloft.net>
	 <4F83316F.20504@lwfinger.net> <1333998672.3007.245.camel@edumazet-glaptop>
	 <20120409.153452.1284163346306246866.davem@davemloft.net>
	 <1334030180.13293.98.camel@edumazet-glaptop>
	 <20120410051127.GA32048@merlins.org>
	 <1334038263.2907.1.camel@edumazet-glaptop>
	 <20120411052733.GA17352@merlins.org> <20120715215935.GF24420@merlins.org>
	 <1342419529.3265.12217.camel@edumazet-glaptop>
	 <20120716151826.GA10586@merlins.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Larry.Finger@lwfinger.net,
	bhutchings@solarflare.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Marc MERLIN <marc@merlins.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:43179 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575Ab2GPQWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 12:22:03 -0400
In-Reply-To: <20120716151826.GA10586@merlins.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-16 at 08:18 -0700, Marc MERLIN wrote:
> On Mon, Jul 16, 2012 at 08:18:49AM +0200, Eric Dumazet wrote:
> > > My understanding is that user space calling drivers that shut off all
> > > interrupts for extended periods of time (as least I think so since my mouse
> > > cursor would not move), is still a kernel bug.
> > > 
> > > For what it's worth, copying 1GB of data in lots of small files does not
> > > cause problems, it seems that it's big files that cause a problem since they
> > > likely fill a buffer somewhere while interrupts are disabled.
> > > 
> > > Do you have an idea of how I can find out where my mc process is stuck in
> > > the kernel?
> > > Should I reproduce with specific sysrq output?
> > 
> > Just to clarify, you get this freeze when transferring a big file from a
> > remote NFS server to your PC, (aka a download), not the reverse way ?
>  
> No, it's atually when I'm 'uploading' from my laptop to my server.
> One interesting thing is that my server is running lvm2 with snapshots,
> which makes writes slower than my laptop can push data over the network, so
> it's definitely causing buffers to fill up.
> I just did a download test and got 4.5MB/s sustained without problems.

Hmm, nfs apparently is able to push lot of data, try to reduce
rsize/wsize to sane values, like 32K instead of 512K ?

gargamel:/mnt/dshelf2/ /net/gargamel/mnt/dshelf2 nfs4
rw,nosuid,nodev,relatime,vers=4.0,rsize=524288,wsize=524288,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.205.7,local_lock=none,addr=192.168.205.3 0 0

You could trace svc_sock_setbufsize() and check how large is set
sk_sndbuf

(iwlwifi is unable to use sendpage anyway, since SG is not enabled)
