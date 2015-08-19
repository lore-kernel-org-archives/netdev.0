From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH 20/21] net: warn if drivers set tx_queue_len = 0
Date: Wed, 19 Aug 2015 20:39:24 +0200
Message-ID: <20150819183924.GA12537@orbit.nwl.cc>
References: <1439886649-24166-13-git-send-email-phil@nwl.cc>
 <1439886649-24166-14-git-send-email-phil@nwl.cc>
 <1439886649-24166-15-git-send-email-phil@nwl.cc>
 <1439886649-24166-16-git-send-email-phil@nwl.cc>
 <1439886649-24166-17-git-send-email-phil@nwl.cc>
 <1439886649-24166-18-git-send-email-phil@nwl.cc>
 <1439886649-24166-19-git-send-email-phil@nwl.cc>
 <1439886649-24166-20-git-send-email-phil@nwl.cc>
 <1439886649-24166-21-git-send-email-phil@nwl.cc>
 <1439909248.6443.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, brouer@redhat.com, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:60426 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750926AbbHSSj0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 14:39:26 -0400
Content-Disposition: inline
In-Reply-To: <1439909248.6443.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Aug 18, 2015 at 07:47:28AM -0700, Eric Dumazet wrote:
> On Tue, 2015-08-18 at 10:30 +0200, Phil Sutter wrote:
> > Due to the introduction of IFF_NO_QUEUE, there is a better way for
> > drivers to indicate that no qdisc should be attached by default. Though,
> > the old convention can't be dropped since ignoring that setting would
> > break drivers still using it. Instead, add a warning so out-of-tree
> > driver maintainers get a chance to adjust their code before we finally
> > get rid of any special handling of tx_queue_len == 0.
> 
> How an admin can remove qdisc on a regular ethernet device with this
> schem ?
> 
> I was doing :
> 
> tc qdisc replace dev eth0 root pfifo
> ifconfig eth0 txqueuelen 0
> tc qdisc del dev eth0 root

I have a hack wich exports the noqueue qdisc like any other standard
one, so it can be attached to a device. Semantics is a bit odd, though:

| # tc qd show dev eth0
| qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
| # tc qd add dev eth0 root pfifo
| # tc qd show dev eth0
| qdisc pfifo 8003: root refcnt 2 limit 1000p
| # tc qd del dev eth0 root
| # tc qd show dev eth0
| qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
| # tc qd add dev eth0 root noqueue
| # tc qd show dev eth0
| # tc qd del dev eth0 root
| RTNETLINK answers: No such file or directory

So whenn I "add" the noqueue qdisc, it actually leads to no qdisc
attached, and none can be removed afterwards. To recover from this
situation, I have to temporarily attach a different qdisc:

| # tc qd add dev eth0 root pfifo
| # tc qd show dev eth0
| qdisc pfifo 8005: root refcnt 2 limit 1000p
| # tc qd del dev eth0 root
| # tc qd show dev eth0
| qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1

This was the quick'n'dirty approach, and I am not satisfied with the
outcome. Instead, I would suggest to have the following:

- noqueue is really the "no queue" like it says, so 'tc qd del root'
  attaches noqueue, no matter if virtual or physical interface
- physical interfaces get pfifo_fast by default, which can be removed to
  get noqueue

This has a few implications:

- the "default" qdisc (pfifo_fast or noqueue) becomes the "initial"
  qdisc
- pfifo_fast needs to be exported, so users can go back to the "initial"
  qdisc of physical devices after having removed it

I'll start implementing the above immediately, but would appreciate to
hear your comments on it meanwhile. I wonder especially what makes the
difference between pfifo and pfifo_fast and why the latter can't be
selected explicitly by a user yet. Are there any good reasons for it
aside from it being the "default" and therefore selecting it can be done
by having tx_queue_len > 0 and removing the root qdisc?

Thanks, Phil
