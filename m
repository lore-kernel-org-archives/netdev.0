From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 0/2] tun: lockless xmit
Date: Wed, 13 Apr 2016 05:50:17 -0700
Message-ID: <1460551817.10638.7.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1460393493.git.pabeni@redhat.com>
	 <20160413132816-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	Jason Wang <jasowang@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33919 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760433AbcDMMuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 08:50:20 -0400
Received: by mail-pf0-f174.google.com with SMTP id c20so33744098pfc.1
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 05:50:19 -0700 (PDT)
In-Reply-To: <20160413132816-mutt-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-13 at 14:08 +0300, Michael S. Tsirkin wrote:
> On Wed, Apr 13, 2016 at 11:04:45AM +0200, Paolo Abeni wrote:
> > This patch series try to remove the need for any lock in the tun device
> > xmit path, significantly improving the forwarding performance when multiple
> > processes are accessing the tun device (i.e. in a nic->bridge->tun->vm scenario).
> > 
> > The lockless xmit is obtained explicitly setting the NETIF_F_LLTX feature bit
> > and removing the default qdisc.
> > 
> > Unlikely most virtual devices, the tun driver has featured a default qdisc
> > for a long period, but it already lost such feature in linux 4.3.
> 
> Thanks -  I think it's a good idea to reduce the
> lock contention there.
> 
> But I think it's unfortunate that it requires
> bypassing the qdisc completely: this means
> that anyone trying to do traffic shaping will
> get back the contention.
> 
> Can we solve the lock contention for qdisc?
> E.g. add a small lockless queue in front of it,
> whoever has the qdisc lock would be
> responsible for moving things from there to qdisc
> proper.
> 
> Thoughts? Is there a chance this might work reasonably well?

Adding any new queue in front of qdisc is problematic :
- Adds a new buffer, with extra latencies.
- If you want to implement priorities properly for X COS, you need X
queues.
- Who is going to service this extra buffer and feed the qdisc ?
- If the innocent guy is RT thread, maybe the extra latency will hurt.
- Adding another set of atomic ops.

We have such a schem here at Google (called holdq), but it was a
nightmare to tune.

We never tried to upstream this beast, it is kind of ugly, and were
expecting something better. Problem is : If you use HTB on a bonding
device, you want still to properly use MQ on the slaves.

HTB queue. 20 netperf generating UDP packets 
lpaa23:~# ./super_netperf 20 -H lpaa24 -t UDP_STREAM -l 3000 -- -m 100 &
[1] 181993


With the holdq feature turned on : about 1 Mpps

lpaa23:~# sar -n DEV 1 10|grep eth0|grep Average
Average:         eth0     28.50 999071.60      3.07 138542.64      0.00
0.00      0.60

holdq turned off : about 620 Kpps

lpaa23:~# sar -n DEV 1 10|grep eth0|grep Average
Average:         eth0     39.00 617765.40      4.73  85667.42      0.00
0.00      0.90
